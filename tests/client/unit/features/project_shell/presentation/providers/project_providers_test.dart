import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softarchitect_ai/features/project_shell/presentation/providers/project_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<List<dynamic>> waitForProjects(ProviderContainer container) async {
    final completer = Completer<List<dynamic>>();
    final sub = container.listen<List<dynamic>>(projectsProvider, (_, next) {
      if (next.isNotEmpty && !completer.isCompleted) {
        completer.complete(next);
      }
    }, fireImmediately: true);

    try {
      final current = container.read(projectsProvider);
      if (current.isNotEmpty) {
        return current;
      }

      return await completer.future.timeout(const Duration(seconds: 2));
    } finally {
      sub.close();
    }
  }

  group('projectsProvider / ProjectsNotifier', () {
    setUp(() {
      // ignore: invalid_use_of_visible_for_testing_member
      SharedPreferences.setMockInitialValues({});
    });

    test('loads with guide project always present', () async {
      final container = ProviderContainer();
      final projects = await waitForProjects(container);

      expect(projects, isNotEmpty);
      expect(projects.first.path.toString().startsWith('mock://'), isTrue);
    });

    test('loads persisted user projects from prefs', () async {
      final stored = [
        jsonEncode({
          'id': '1',
          'name': 'A',
          'path': '/tmp/a',
          'createdAt': DateTime(2026, 1, 1).toIso8601String(),
          'lastOpened': DateTime(2026, 1, 2).toIso8601String(),
        }),
      ];

      // ignore: invalid_use_of_visible_for_testing_member
      SharedPreferences.setMockInitialValues({'user_projects_v2': stored});

      final container = ProviderContainer();
      final projects = await waitForProjects(container);

      expect(projects.any((p) => p.id == '1'), isTrue);
    });

    test('addProject updates state and persists to prefs', () async {
      final container = ProviderContainer();
      await waitForProjects(container);
      await container
          .read(projectsProvider.notifier)
          .addProject('Nuevo', '/tmp/new', 'desc');

      final projects = container.read(projectsProvider);
      expect(projects.any((p) => p.name == 'Nuevo'), isTrue);

      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList('user_projects_v2');
      expect(saved, isNotNull);
      expect(saved!.isNotEmpty, isTrue);
    });

    test('ignores malformed persisted entries', () async {
      // ignore: invalid_use_of_visible_for_testing_member
      SharedPreferences.setMockInitialValues({
        'user_projects_v2': [
          '{bad json}',
          jsonEncode({
            'id': 'ok',
            'name': 'OK',
            'path': '/tmp/ok',
            'createdAt': DateTime(2026, 1, 1).toIso8601String(),
            'lastOpened': null,
          }),
        ],
      });

      final container = ProviderContainer();
      final projects = await waitForProjects(container);

      expect(projects.any((p) => p.id == 'ok'), isTrue);
    });
  });
}
