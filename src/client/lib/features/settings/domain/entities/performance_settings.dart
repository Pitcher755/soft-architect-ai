import 'package:flutter/foundation.dart';

/// Performance settings for the application.
///
/// Immutable value object containing all performance-related preferences
/// such as cache limits, memory management, and optimization flags.
///
/// Example:
/// ```dart
/// final settings = PerformanceSettings(
///   cacheSize: 512,
///   memoryLimit: 1024,
///   enableCaching: true,
/// );
/// ```
@immutable
class PerformanceSettings {
  /// Creates a [PerformanceSettings] instance.
  ///
  /// All parameters have sensible defaults for balanced performance.
  const PerformanceSettings({
    this.cacheSize = 256,
    this.memoryLimit = 512,
    this.enableCaching = true,
    this.enablePreloading = true,
    this.maxConcurrentRequests = 4,
  });

  /// Creates a default [PerformanceSettings] with balanced values.
  ///
  /// Suitable for mid-range systems with adequate RAM and storage.
  factory PerformanceSettings.defaultSettings() => const PerformanceSettings();

  /// Creates a low-performance preset for resource-constrained systems.
  ///
  /// Reduces cache size, memory limit, and disables preloading.
  factory PerformanceSettings.lowPerformance() => const PerformanceSettings(
    cacheSize: 128,
    memoryLimit: 256,
    enablePreloading: false,
    maxConcurrentRequests: 2,
  );

  /// Creates a high-performance preset for powerful systems.
  ///
  /// Increases cache size, memory limit, and enables all optimizations.
  factory PerformanceSettings.highPerformance() => const PerformanceSettings(
    cacheSize: 1024,
    memoryLimit: 2048,
    maxConcurrentRequests: 8,
  );

  /// Creates a [PerformanceSettings] from a JSON map.
  ///
  /// Returns default settings if JSON is invalid or missing fields.
  factory PerformanceSettings.fromJson(Map<String, dynamic> json) =>
      PerformanceSettings(
        cacheSize: json['cacheSize'] as int? ?? 256,
        memoryLimit: json['memoryLimit'] as int? ?? 512,
        enableCaching: json['enableCaching'] as bool? ?? true,
        enablePreloading: json['enablePreloading'] as bool? ?? true,
        maxConcurrentRequests: json['maxConcurrentRequests'] as int? ?? 4,
      );

  /// Maximum cache size in MB (megabytes).
  ///
  /// Range: 0 - 2048 MB (default: 256 MB)
  /// Controls how much disk space can be used for caching RAG data,
  /// embeddings, and temporary files.
  final int cacheSize;

  /// Maximum memory usage in MB (megabytes).
  ///
  /// Range: 256 - 4096 MB (default: 512 MB)
  /// Sets the soft limit for RAM consumption by the application.
  /// Helps prevent memory exhaustion on low-end systems.
  final int memoryLimit;

  /// Enables caching of frequently accessed data.
  ///
  /// When enabled, stores embeddings, RAG results, and UI state
  /// in local cache for faster retrieval.
  final bool enableCaching;

  /// Enables background preloading of project data.
  ///
  /// When enabled, preloads project context and embeddings
  /// in the background to reduce latency on user interactions.
  final bool enablePreloading;

  /// Maximum number of concurrent HTTP/API requests.
  ///
  /// Range: 1 - 16 (default: 4)
  /// Controls parallelism for external API calls (e.g., Groq, Ollama).
  /// Lower values reduce network/CPU load, higher values improve throughput.
  final int maxConcurrentRequests;

  /// Creates a copy of this settings with optional overrides.
  ///
  /// Example:
  /// ```dart
  /// final newSettings = settings.copyWith(cacheSize: 512);
  /// ```
  PerformanceSettings copyWith({
    int? cacheSize,
    int? memoryLimit,
    bool? enableCaching,
    bool? enablePreloading,
    int? maxConcurrentRequests,
  }) => PerformanceSettings(
    cacheSize: cacheSize ?? this.cacheSize,
    memoryLimit: memoryLimit ?? this.memoryLimit,
    enableCaching: enableCaching ?? this.enableCaching,
    enablePreloading: enablePreloading ?? this.enablePreloading,
    maxConcurrentRequests: maxConcurrentRequests ?? this.maxConcurrentRequests,
  );

  /// Converts this settings object to a JSON map.
  ///
  /// Used for serialization to storage (SharedPreferences, JSON files).
  Map<String, dynamic> toJson() => {
    'cacheSize': cacheSize,
    'memoryLimit': memoryLimit,
    'enableCaching': enableCaching,
    'enablePreloading': enablePreloading,
    'maxConcurrentRequests': maxConcurrentRequests,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PerformanceSettings &&
          runtimeType == other.runtimeType &&
          cacheSize == other.cacheSize &&
          memoryLimit == other.memoryLimit &&
          enableCaching == other.enableCaching &&
          enablePreloading == other.enablePreloading &&
          maxConcurrentRequests == other.maxConcurrentRequests;

  @override
  int get hashCode =>
      cacheSize.hashCode ^
      memoryLimit.hashCode ^
      enableCaching.hashCode ^
      enablePreloading.hashCode ^
      maxConcurrentRequests.hashCode;

  @override
  String toString() =>
      'PerformanceSettings('
      'cacheSize: ${cacheSize}MB, '
      'memoryLimit: ${memoryLimit}MB, '
      'enableCaching: $enableCaching, '
      'enablePreloading: $enablePreloading, '
      'maxConcurrentRequests: $maxConcurrentRequests'
      ')';
}
