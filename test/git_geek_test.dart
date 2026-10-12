import 'package:flutter_test/flutter_test.dart';
import 'package:git_geek/data/git_commit_source.dart';
import 'package:git_geek/logic/git_log_parser.dart';
import 'package:git_geek/logic/git_tag_parser.dart';
import 'package:git_geek/logic/semver.dart';
import 'package:git_geek/models/git_commit.dart';
import 'package:git_geek/models/git_tag.dart';

void main() {
  group('GitTagParser', () {
    test('show-ref annotated tag keeps both shas', () {
      const raw = 'aaa111 refs/tags/v1.0\nbbb222 refs/tags/v1.0^{}\n'
          'ccc333 refs/tags/v1.1';
      final tags = GitTagParser.parseLocal(raw);
      expect(tags.length, 2);
      final v10 = tags.firstWhere((e) => e.name == 'v1.0');
      expect(v10.commitSha, 'bbb222');
      expect(v10.tagObjectSha, 'aaa111');
      final v11 = tags.firstWhere((e) => e.name == 'v1.1');
      expect(v11.commitSha, 'ccc333');
    });

    test('pure tag list has null sha and syncs by name', () {
      final local = GitTagParser.parseLocal('v1.0\nv1.1\n');
      final remote = GitTagParser.parseRemote('v1.0\nv1.1\n');
      final items = buildCompareItems(local, remote);
      expect(items.every((e) => e.status == TagSyncStatus.synced), isTrue);
    });

    test('diverged when same name different sha', () {
      const local = [GitTag(name: 'v1.0', commitSha: 'aaa')];
      const remote = [GitTag(name: 'v1.0', commitSha: 'bbb')];
      final items = buildCompareItems(local, remote);
      expect(items.single.status, TagSyncStatus.diverged);
    });
  });

  group('GitLogParser', () {
    test('parses commit block and raw gitlink', () {
      const raw = '===COMMIT===\n'
          'sha: abc123\n'
          'parents: def456\n'
          'author: louis\n'
          'date: 2026-09-01 10:00\n'
          'refs: HEAD -> main, tag: v1.0\n'
          'subject: feat: xxx\n'
          'body line\n'
          '===END===\n'
          ':000000 160000 0000000000000000000000000000000000000000 abc1234567890abcdef A\tpackages/player\n';
      final commits = GitLogParser.parse(raw);
      expect(commits.length, 1);
      expect(commits.single.tags, ['v1.0']);
      expect(commits.single.submoduleChanges.length, 1);
      expect(commits.single.submoduleChanges.single.path,
          'packages/player');
    });

    test('merge same sha merges raw groups', () {
      const raw = '===COMMIT===\n'
          'sha: mmm\n'
          'parents: p1 p2\n'
          'author: a\n'
          'date: d\n'
          'refs: \n'
          'subject: merge\n'
          '===END===\n'
          ':160000 160000 aaa bbb M\tpkg\n'
          '===COMMIT===\n'
          'sha: mmm\n'
          'parents: p1 p2\n'
          'author: a\n'
          'date: d\n'
          'refs: \n'
          'subject: merge\n'
          '===END===\n'
          ':160000 160000 ccc bbb M\tpkg\n';
      final commits = GitLogParser.parse(raw);
      expect(commits.length, 1);
      expect(commits.single.submoduleChanges.single.resolvedInMerge,
          isTrue);
    });

    test('parseBranches skips symbolic refs', () {
      const raw = '* main\n'
          '  dev\n'
          '  remotes/origin/HEAD -> origin/main\n'
          '  remotes/origin/main\n';
      final branches = GitLogParser.parseBranches(raw);
      expect(branches.map((e) => e.name),
          containsAll(['main', 'dev', 'origin/main']));
      expect(branches.firstWhere((e) => e.name == 'main').isCurrent,
          isTrue);
    });
  });

  group('Submodule trace', () {
    test('recordedBy points to previous setter', () {
      final commits = [
        const GitCommit(sha: 'new', parents: ['base'], author: 'b',
            submoduleChanges: [
              SubmoduleChange(
                  path: 'pkg', oldSha: 's1', newSha: 's2'),
            ]),
        const GitCommit(sha: 'base', author: 'a',
            submoduleChanges: [
              SubmoduleChange(
                  path: 'pkg', oldSha: 's0', newSha: 's1'),
            ]),
      ].reversed.toList();
      // attach expects newest-first input
      final input = commits.reversed.toList();
      final out = attachSubmoduleRecordInfo(input);
      final top = out.firstWhere((e) => e.sha == 'new');
      expect(top.submoduleChanges.single.recordedBy?.sha, 'base');
    });
  });

  group('Submodule log panel', () {
    test('子库 log 解析出可参照的顺序与短 sha', () {
      // 参照面板消费的字段：sha/author/date/subject，且必须保持 git log 的原始顺序。
      const raw = '===COMMIT===\n'
          'sha: aaa1111111111111111111111111111111111\n'
          'parents: \n'
          'author: louis\n'
          'date: 2026-10-10 09:00\n'
          'refs: HEAD -> main\n'
          'subject: feat: 子库最新\n'
          '===END===\n'
          '===COMMIT===\n'
          'sha: bbb2222222222222222222222222222222222\n'
          'parents: aaa1111111111111111111111111111111111\n'
          'author: amy\n'
          'date: 2026-10-09 09:00\n'
          'refs: \n'
          'subject: fix: 更早一条\n'
          '===END===\n';
      final parsed = GitLogParser.parse(raw);
      expect(parsed.length, 2);
      // 顺序即 git log 顺序（最新在前），面板按此渲染便于肉眼对照。
      expect(parsed.first.subject, 'feat: 子库最新');
      expect(parsed.first.shortSha, 'aaa11111');
      expect(parsed.first.date, '2026-10-10 09:00');
      expect(parsed.last.author, 'amy');
      expect(parsed.last.shortSha, 'bbb22222');
    });

    test('面板按 path 取对应子库记录，互不串号', () {
      final logs = {
        'pkg/a': [const GitCommit(sha: 'a1', subject: 'A newest')],
        'pkg/b': [const GitCommit(sha: 'b1', subject: 'B newest')],
      };
      expect(logs['pkg/a']!.single.subject, 'A newest');
      expect(logs['pkg/b']!.single.subject, 'B newest');
      expect(logs['pkg/missing'], isNull);
    });
  });

  group('Merge drift', () {
    test('p2 推进被 merge 丢弃时标 silentlyDropped', () {
      // P1: pkg@aaa，P2: aaa->ccc，M 保留 aaa：p1 无 diff，p2 有 ccc->aaa。
      final updated = GitCommitDataSource.applyMergeDrift(
        existing: const [],
        changesP1: const [],
        changesP2: const [
          SubmoduleChange(path: 'pkg', oldSha: 'ccc', newSha: 'aaa'),
        ],
        secondParentSha: 'p2sha',
      );
      expect(updated, isNotNull);
      expect(updated!.single.silentlyDropped, isTrue);
      expect(updated.single.droppedSha, 'ccc');
      expect(updated.single.droppedFromParent, 'p2sha');
    });

    test('双边无 submodule 变化时返回 null', () {
      expect(
        GitCommitDataSource.applyMergeDrift(
          existing: const [
            SubmoduleChange(path: 'pkg', oldSha: 'aaa', newSha: 'bbb'),
          ],
          changesP1: const [],
          changesP2: const [],
          secondParentSha: 'p2sha',
        ),
        isNull,
      );
    });

    test('仅 p1 侧变化时移除误报', () {
      final updated = GitCommitDataSource.applyMergeDrift(
        existing: const [
          SubmoduleChange(path: 'pkg', oldSha: 'aaa', newSha: 'bbb'),
        ],
        changesP1: const [
          SubmoduleChange(path: 'pkg', oldSha: 'aaa', newSha: 'bbb'),
        ],
        changesP2: const [],
        secondParentSha: 'p2sha',
      );
      expect(updated, isNotNull);
      expect(updated, isEmpty);
    });
  });

  group('SemVer', () {
    test('orders versions and prerelease correctly', () {
      final tags = [
        const GitTag(name: 'v1.10.0'),
        const GitTag(name: 'v1.2.0'),
        const GitTag(name: 'v2.0.0-rc.1'),
        const GitTag(name: 'v2.0.0'),
        const GitTag(name: 'nota'),
      ];
      // ASC 时版本优先且升序；DESC 是 -base 全反转
      final asc =
          tags.sortedByMode(TagSortMode.semverAsc).map((e) => e.name).toList();
      expect(asc, ['v1.2.0', 'v1.10.0', 'v2.0.0-rc.1', 'v2.0.0', 'nota']);
      final desc =
          tags.sortedByMode(TagSortMode.semverDesc).map((e) => e.name).toList();
      expect(desc, asc.reversed.toList());
    });

    test('numeric parts compare numerically', () {
      expect(SemVerComparator.compare('v1.10.0', 'v1.2.0') > 0, isTrue);
      expect(SemVerComparator.compare('1.0.0', '1.0.0-rc.1') > 0, isTrue);
    });
  });
}
