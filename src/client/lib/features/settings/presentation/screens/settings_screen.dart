import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../shared/presentation/widgets/projects_sidebar.dart';
import '../providers/settings_provider.dart';

/// SettingsScreen - Application settings and configuration
/// Features left sidebar for navigation and comprehensive settings UI
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Row(
        children: [
          // Left Sidebar
          const SizedBox(
            width: 64,
            height: double.infinity,
            child: ProjectsSidebar(),
          ),

          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Configuración',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE6EDF3),
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Personaliza tu experiencia en SoftArchitect AI',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8b949e),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Settings Sections

                  // --- NUEVA SECCIÓN: ALMACENAMIENTO ---
                  _buildStorageSection(context),
                  const SizedBox(height: 32),

                  _buildAppearanceSection(ref, settings),
                  const SizedBox(height: 32),
                  _buildAccessibilitySection(ref, settings),
                  const SizedBox(height: 32),
                  _buildPerformanceSection(ref, settings),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- NUEVA SECCIÓN IMPLEMENTADA ---
  Widget _buildStorageSection(BuildContext context) => _SettingsCard(
    title: 'Almacenamiento (DEMO)',
    icon: Icons.folder_special,
    children: [
      _SettingItem(
        title: 'Directorio de proyectos',
        subtitle: 'Ubicación por defecto para guardar nuevos proyectos',
        child: Row(
          children: [
            // Visualización de la ruta (Simulada)
            Container(
              width: 220,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1117), // Fondo más oscuro
                border: Border.all(color: const Color(0xFF30363d)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                '~/Documents/SoftArchitect',
                style: TextStyle(
                  color: Color(0xFF8b949e),
                  fontSize: 12,
                  fontFamily: 'Courier', // Fuente monoespaciada para rutas
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            // Botón de acción
            IconButton(
              onPressed: () {
                // TODO: Implementar file_picker para seleccionar directorio por defecto
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('TODO: Implementar selector de directorio'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              icon: const Icon(Icons.folder_open, size: 20),
              color: const Color(0xFF58A6FF),
              tooltip: 'Cambiar directorio',
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF21262D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: const BorderSide(color: Color(0xFF30363d)),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _buildAppearanceSection(WidgetRef ref, AppSettings settings) =>
      _SettingsCard(
        title: 'Apariencia (DEMO)',
        icon: Icons.palette,
        children: [
          _SettingItem(
            title: 'Tema',
            subtitle: 'Cambia entre tema claro y oscuro',
            child: Switch(
              value: settings.themeMode == ThemeMode.dark,
              onChanged: (value) => ref
                  .read(settingsProvider.notifier)
                  .updateTheme(value ? ThemeMode.dark : ThemeMode.light),
              activeThumbColor: const Color(0xFF58A6FF),
            ),
          ),
          const Divider(color: Color(0xFF30363d)),
          _SettingItem(
            title: 'Tamaño de fuente',
            subtitle: 'Ajusta el tamaño del texto en la aplicación',
            child: SizedBox(
              width: 200,
              child: Slider(
                value: settings.fontSize,
                min: 0.8,
                max: 1.4,
                divisions: 6,
                onChanged: (value) =>
                    ref.read(settingsProvider.notifier).updateFontSize(value),
                activeColor: const Color(0xFF58A6FF),
                inactiveColor: const Color(0xFF30363d),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: Text(
              '${(settings.fontSize * 100).round()}%',
              style: const TextStyle(fontSize: 12, color: Color(0xFF8b949e)),
            ),
          ),
        ],
      );

  Widget _buildAccessibilitySection(WidgetRef ref, AppSettings settings) =>
      _SettingsCard(
        title: 'Accesibilidad (DEMO)',
        icon: Icons.accessibility,
        children: [
          _SettingItem(
            title: 'Zoom global',
            subtitle: 'Ajusta el zoom de toda la aplicación',
            child: SizedBox(
              width: 200,
              child: Slider(
                value: settings.globalZoom,
                min: 0.5,
                max: 2,
                divisions: 15,
                onChanged: (value) =>
                    ref.read(settingsProvider.notifier).updateGlobalZoom(value),
                activeColor: const Color(0xFF58A6FF),
                inactiveColor: const Color(0xFF30363d),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: Text(
              '${(settings.globalZoom * 100).round()}%',
              style: const TextStyle(fontSize: 12, color: Color(0xFF8b949e)),
            ),
          ),
          const Divider(color: Color(0xFF30363d)),
          _SettingItem(
            title: 'Atajos de teclado para zoom',
            subtitle: 'Ctrl + / Ctrl - para zoom, Ctrl + 0 para reset',
            child: Switch(
              value: settings.enableZoomShortcuts,
              onChanged: (value) => ref
                  .read(settingsProvider.notifier)
                  .updateZoomShortcuts(enableZoomShortcuts: value),
              activeThumbColor: const Color(0xFF58A6FF),
            ),
          ),
        ],
      );

  Widget _buildPerformanceSection(WidgetRef ref, AppSettings settings) =>
      _SettingsCard(
        title: 'Rendimiento',
        icon: Icons.speed,
        children: [
          _SettingItem(
            title: 'Animaciones',
            subtitle: 'Habilita o deshabilita las animaciones de la UI',
            child: Switch(
              value: settings.enableAnimations,
              onChanged: (value) => ref
                  .read(settingsProvider.notifier)
                  .updateAnimations(enableAnimations: value),
              activeThumbColor: const Color(0xFF58A6FF),
            ),
          ),
          const Divider(color: Color(0xFF30363d)),
          _SettingItem(
            title: 'Optimización de memoria',
            subtitle:
                'Libera memoria automáticamente cuando sea necesario (DEMO)',
            child: Switch(
              value: settings.enableMemoryOptimization,
              onChanged: (value) => ref
                  .read(settingsProvider.notifier)
                  .updateMemoryOptimization(enableMemoryOptimization: value),
              activeThumbColor: const Color(0xFF58A6FF),
            ),
          ),
        ],
      );
}

/// Custom settings card widget
class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: const Color(0xFF161B22),
      border: Border.all(color: const Color(0xFF30363d)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card Header
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon, size: 24, color: const Color(0xFF58A6FF)),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFE6EDF3),
                ),
              ),
            ],
          ),
        ),
        const Divider(color: Color(0xFF30363d), height: 1),
        // Card Content
        ...children,
      ],
    ),
  );
}

/// Individual setting item widget
class _SettingItem extends StatelessWidget {
  const _SettingItem({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFE6EDF3),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Color(0xFF8b949e)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        child,
      ],
    ),
  );
}
