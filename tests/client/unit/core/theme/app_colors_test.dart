import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/core/theme/app_colors.dart';

void main() {
  group('AppColors', () {
    test('should have primary color defined', () {
      expect(AppColors.primary, isNotNull);
      expect(AppColors.primary, isA<Color>());
    });

    test('should have primaryLight color variant', () {
      expect(AppColors.primaryLight, isNotNull);
      expect(AppColors.primaryLight, isA<Color>());
    });

    test('should have primaryDark color variant', () {
      expect(AppColors.primaryDark, isNotNull);
      expect(AppColors.primaryDark, isA<Color>());
    });

    test('should have mainBg background color', () {
      expect(AppColors.mainBg, isNotNull);
      expect(AppColors.mainBg, isA<Color>());
    });

    test('should have surfaceBg surface color', () {
      expect(AppColors.surfaceBg, isNotNull);
      expect(AppColors.surfaceBg, isA<Color>());
    });

    test('should have surfaceLight surface variant', () {
      expect(AppColors.surfaceLight, isNotNull);
      expect(AppColors.surfaceLight, isA<Color>());
    });

    test('should have border color defined', () {
      expect(AppColors.border, isNotNull);
      expect(AppColors.border, isA<Color>());
    });

    test('should have borderLight border variant', () {
      expect(AppColors.borderLight, isNotNull);
      expect(AppColors.borderLight, isA<Color>());
    });

    test('all defined colors are valid Color instances', () {
      final colors = [
        AppColors.primary,
        AppColors.primaryLight,
        AppColors.primaryDark,
        AppColors.mainBg,
        AppColors.surfaceBg,
        AppColors.surfaceLight,
        AppColors.border,
        AppColors.borderLight,
      ];

      for (final color in colors) {
        expect(color, isA<Color>());
        expect(color.toARGB32(), isA<int>());
      }
    });
  });
}
