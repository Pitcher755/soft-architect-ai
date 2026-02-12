import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:softarchitect_ai/features/project_shell/domain/models/project_phase.dart';
import 'package:softarchitect_ai/core/theme/app_colors.dart';

void main() {
  group('ProjectPhase', () {
    test('contains all expected phases and total file count', () {
      expect(ProjectPhase.all.length, 7);
      expect(ProjectPhase.totalFileCount, 25);
      expect(ProjectPhase.root.order, 0);
      expect(ProjectPhase.meta.order, 6);
    });

    test('getById returns correct phase and null when not found', () {
      expect(ProjectPhase.getById('ROOT'), ProjectPhase.root);
      expect(ProjectPhase.getById('CONTEXT'), ProjectPhase.context);
      expect(ProjectPhase.getById('UNKNOWN'), isNull);
    });

    test('getByOrder returns correct phase and null when not found', () {
      expect(ProjectPhase.getByOrder(0), ProjectPhase.root);
      expect(ProjectPhase.getByOrder(3), ProjectPhase.architecture);
      expect(ProjectPhase.getByOrder(999), isNull);
    });

    test('equality/hashCode are based on id', () {
      const a = ProjectPhase.root;
      const b = ProjectPhase(
        id: 'ROOT',
        name: 'Otra',
        icon: Icons.home,
        color: AppColors.dirRoot,
        fileCount: 0,
        order: 99,
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('toString includes id and name', () {
      expect(ProjectPhase.root.toString(), contains('ROOT'));
      expect(ProjectPhase.root.toString(), contains('Raíz'));
    });
  });
}
