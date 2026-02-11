import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softarchitect_ai/features/settings/data/datasources/last_project_local_datasource.dart';

import '../../../../../test_helpers/shared_preferences_mock.dart';

void main() {
  late LastProjectLocalDataSource dataSource;

  setUp(() async {
    // Mock SharedPreferences
    initMockSharedPreferences({});
    dataSource = LastProjectLocalDataSource();
  });

  group('LastProjectLocalDataSource', () {
    test('should load last project path from SharedPreferences', () async {
      // Arrange
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lastProject.path', '/home/user/projects/alpha');

      // Act
      final result = await dataSource.loadLastProjectPath();

      // Assert
      expect(result, '/home/user/projects/alpha');
    });

    test('should save last project path to SharedPreferences', () async {
      // Arrange
      const path = '/home/user/projects/beta';

      // Act
      await dataSource.saveLastProjectPath(path);

      // Assert
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('lastProject.path');
      expect(saved, path);
    });

    test('should clear last project path from SharedPreferences', () async {
      // Arrange
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lastProject.path', '/home/user/projects/gamma');

      // Act
      await dataSource.clearLastProjectPath();

      // Assert
      final cleared = prefs.getString('lastProject.path');
      expect(cleared, isNull);
    });
  });
}
