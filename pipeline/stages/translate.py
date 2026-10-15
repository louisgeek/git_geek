"""阶段 5：翻译。

Provider 可插拔。默认 `mock` 供离线跑通与单测；接真实模型实现
`Provider.translate(prompt) -> str` 即可，管线其余部分不变。
"""

from __future__ import annotations

import json
import os
import urllib.error
import urllib.request
from typing import Protocol

from ..models import Entry, Translation
from .assemble import AssembledPrompt, build_prompt


class Provider(Protocol):
    name: str

    def translate(self, prompt: AssembledPrompt, entry: Entry) -> str: ...


class MockProvider:
    """离线占位实现。按术语表产出可预期的译文，用于验证管线全链路。"""

    name = "mock"

    def __init__(self, glossary=None):
        self.glossary = glossary
        self.calls = 0

    def translate(self, prompt: AssembledPrompt, entry: Entry) -> str:
        self.calls += 1
        out = entry.source
        if self.glossary is not None:
            for term in prompt.hit_terms:
                std = term.translation_for(prompt.locale)
                if std:
                    out = out.replace(term.term, std)
        return out


class OpenAICompatProvider:
    """OpenAI 兼容 /chat/completions。兼容大多数自建与第三方网关。"""

    name = "openai_compat"

    def __init__(
        self,
        base_url: str,
        api_key: str,
        model: str,
        timeout: int = 60,
        temperature: float = 0.0,
    ):
        self.base_url = base_url.rstrip("/")
        self.api_key = api_key
        self.model = model
        self.timeout = timeout
        self.temperature = temperature
        self.tokens_in = 0
        self.tokens_out = 0

    @classmethod
    def from_env(cls) -> "OpenAICompatProvider":
        base = os.environ.get("PIPELINE_LLM_BASE_URL", "https://api.openai.com/v1")
        key = os.environ.get("PIPELINE_LLM_API_KEY", "")
        model = os.environ.get("PIPELINE_LLM_MODEL", "gpt-4o-mini")
        if not key:
            raise RuntimeError(
                "未配置 PIPELINE_LLM_API_KEY。离线跑通用 --provider mock。"
            )
        return cls(base_url=base, api_key=key, model=model)

    def translate(self, prompt: AssembledPrompt, entry: Entry) -> str:
        payload = {
            "model": self.model,
            "temperature": self.temperature,
            "messages": [
                {"role": "system", "content": prompt.system},
                {"role": "user", "content": prompt.user},
            ],
        }
        req = urllib.request.Request(
            f"{self.base_url}/chat/completions",
            data=json.dumps(payload).encode("utf-8"),
            headers={
                "Content-Type": "application/json",
                "Authorization": f"Bearer {self.api_key}",
            },
            method="POST",
        )
        try:
            with urllib.request.urlopen(req, timeout=self.timeout) as resp:
                data = json.loads(resp.read().decode("utf-8"))
        except urllib.error.URLError as e:
            raise RuntimeError(f"LLM 调用失败: {e}") from e

        usage = data.get("usage", {})
        self.tokens_in += usage.get("prompt_tokens", 0)
        self.tokens_out += usage.get("completion_tokens", 0)
        return (data["choices"][0]["message"]["content"] or "").strip()


def get_provider(kind: str, glossary=None) -> Provider:
    if kind == "mock":
        return MockProvider(glossary)
    if kind in ("openai", "openai_compat", "llm"):
        return OpenAICompatProvider.from_env()
    if kind == "dictionary":
        from .provider_dict import DictionaryProvider

        return DictionaryProvider(glossary)
    raise ValueError(
        f"未知 provider {kind!r}；可用: mock / dictionary / openai"
    )


def translate_entries(
    entries: list[Entry],
    locale: str,
    brief,
    glossary,
    provider: Provider,
    tm=None,
) -> list[Translation]:
    """逐条翻译。批量化可在此层之上做（并发/合批），此处保持可读与可测。"""
    out: list[Translation] = []
    for entry in entries:
        prompt = build_prompt(entry, locale, brief, glossary, tm)
        target = provider.translate(prompt, entry)
        out.append(
            Translation(
                key=entry.key,
                target=target,
                locale=locale,
                origin="llm",
                provider=provider.name,
                glossary_terms=tuple(t.term for t in prompt.hit_terms),
                source_hash=entry.source_hash,
            )
        )
    return out