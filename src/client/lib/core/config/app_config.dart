/// Configuration settings and environment variables for the application.
class AppConfig {
  // API Configuration
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  static const Duration apiTimeout = Duration(
    seconds: int.fromEnvironment(
      'API_TIMEOUT_SECONDS',
      defaultValue: 30,
    ),
  );

  // LLM Provider
  static const String llmProvider = String.fromEnvironment(
    'LLM_PROVIDER',
    defaultValue: 'local',
  );

  // Ollama Configuration
  static const String ollamaBaseUrl = String.fromEnvironment(
    'OLLAMA_BASE_URL',
    defaultValue: 'http://localhost:11434',
  );

  static const String ollamaModel = String.fromEnvironment(
    'OLLAMA_MODEL',
    defaultValue: 'qwen2.5-coder:7b',
  );

  // Groq Configuration
  static const String groqApiKey = String.fromEnvironment(
    'GROQ_API_KEY',
    defaultValue: '',
  );

  // UI Configuration
  static const String themeMode = String.fromEnvironment(
    'THEME_MODE',
    defaultValue: 'dark',
  );

  static const String language = String.fromEnvironment(
    'LANGUAGE',
    defaultValue: 'es',
  );

  // Debug
  static const bool enableDebugLogging = bool.fromEnvironment(
    'ENABLE_DEBUG_LOGGING',
    defaultValue: false,
  );

  // Computed properties
  static bool get isLocalMode => llmProvider == 'local';
  static bool get isCloudMode => llmProvider == 'cloud';
  static bool get isDarkMode => themeMode == 'dark';
  static bool get isSpanish => language == 'es';
}
