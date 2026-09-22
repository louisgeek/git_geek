import 'package:flutter_test/flutter_test.dart';
import 'package:git_geek/src/logic/git_log_parser.dart';
import 'package:git_geek/src/logic/git_tag_parser.dart';
import 'package:git_geek/src/logic/semver.dart';
import 'package:git_geek/src/models/git_commit.dart';
import 'package:git_geek/src/models/git_tag.dart';

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

  group('SemVer', () {
    test('orders versions and prerelease correctly', () {
      final tags = [
        const GitTag(name: 'v1.10.0'),
        const GitTag(name: 'v1.2.0'),
        const GitTag(name: 'v2.0.0-rc.1'),
        const GitTag(name: 'v2.0.0'),
        const GitTag(name: 'nota'),
      ];
      // 原语义：ASC 时版本优先且升序；DESC 是 -base 全反转
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
