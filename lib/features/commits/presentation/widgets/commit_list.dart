import 'package:flutter/material.dart';
import 'package:git_geek/l10n/gen/app_localizations.dart';
import 'package:git_geek/core/widgets/empty_hint.dart';
import 'package:git_geek/features/commits/presentation/commits_state.dart';
import 'package:git_geek/features/commits/presentation/widgets/commit_rows.dart';

/// 提交列表（原 GitTagPage._buildList 的 commits 分支，原样迁移仅换调用方式）。
class CommitList extends StatelessWidget {
  final CommitsState cs;
  final AppLocalizations t;
  final ValueChanged<String> onTagClick;
  final void Function(String path, String? sha) onSubmoduleClick;
  final ValueChanged<String> onCopy;

  const CommitList({
    super.key,
    required this.cs,
    required this.t,
    required this.onTagClick,
    required this.onSubmoduleClick,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    if (cs.visibleCommits.isEmpty) {
      return EmptyHint(text: t.emptyCommits);
    }
    return Column(
      children: [
        for (final c in cs.visibleCommits)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: CommitRow(
              commit: c,
              t: t,
              onTagClick: onTagClick,
              onSubmoduleClick: onSubmoduleClick,
              onCopy: onCopy,
            ),
          ),
      ],
    );
  }
}
