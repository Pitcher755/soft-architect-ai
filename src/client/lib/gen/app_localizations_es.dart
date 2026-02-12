// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'SoftArchitect AI';

  @override
  String get projectsPageTitle => 'Proyectos';

  @override
  String get newProjectButton => 'Nuevo Proyecto';

  @override
  String get deleteProjectButton => 'Eliminar';

  @override
  String deleteProjectConfirm(String projectName) {
    return '¿Estás seguro de que deseas eliminar \'$projectName\'?';
  }

  @override
  String get settingsPageTitle => 'Configuración';

  @override
  String get settingsLanguageLabel => 'Idioma';

  @override
  String get selectLanguage => 'Seleccionar Idioma';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageSpanish => 'Español';

  @override
  String get chatPageTitle => 'Chat IA';

  @override
  String get sendMessage => 'Enviar';

  @override
  String get clearHistory => 'Borrar Historial';

  @override
  String get newChat => 'Nuevo Chat';

  @override
  String get errorLoadingProject => 'Error al cargar el proyecto';

  @override
  String get errorLoadingProjects => 'Error al cargar los proyectos';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get edit => 'Editar';

  @override
  String get close => 'Cerrar';

  @override
  String get confirmed => 'Confirmado';

  @override
  String get loading => 'Cargando...';

  @override
  String get empty => 'Sin elementos';

  @override
  String get createProject => 'Crear Proyecto';

  @override
  String get browse => 'Examinar...';

  @override
  String get validateAndSave => 'Validar y Guardar';

  @override
  String get refine => 'Refinar';

  @override
  String get reject => 'Rechazar';

  @override
  String fileSaved(String outputFile) {
    return 'Archivo guardado en: $outputFile';
  }

  @override
  String get contentCopied => 'Contenido copiado al portapapeles';

  @override
  String saveError(String error) {
    return 'Error al guardar: $error';
  }

  @override
  String get loadingProjects => 'Cargando proyectos...';

  @override
  String get today => 'Hoy';

  @override
  String get yesterday => 'Ayer';

  @override
  String daysAgo(int days) {
    return 'Hace $days días';
  }

  @override
  String get languageTitle => 'Idioma';

  @override
  String get languageInterfaceTitle => 'Idioma de la interfaz';

  @override
  String get languageInterfaceSubtitle => 'Cambia el idioma de la aplicación';

  @override
  String get storageTitle => 'Almacenamiento';

  @override
  String get storageProjectDirTitle => 'Directorio de proyectos';

  @override
  String get storageProjectDirSubtitle =>
      'Ubicación por defecto para guardar nuevos proyectos';

  @override
  String get changeDirectory => 'Cambiar directorio';

  @override
  String directoryUpdated(String path) {
    return 'Directorio actualizado: $path';
  }

  @override
  String errorSelectingDirectory(String error) {
    return 'Error al seleccionar directorio: $error';
  }

  @override
  String get folderAlreadyExists =>
      'Ya existe una carpeta con ese nombre en la ruta seleccionada';

  @override
  String get workspaceSectionTitle => 'Espacio de Trabajo de SoftArchitect AI';

  @override
  String get workspaceSubtitle =>
      'Espacio de trabajo interactivo para generación de documentos';

  @override
  String get myProjects => 'Mis Proyectos';

  @override
  String get guideTitle => 'Bienvenido a SoftArchitect AI';

  @override
  String get guideDescription =>
      'Esta es tu guía interactiva. Aquí aprenderás a usar la herramienta.';

  @override
  String get guideSteps =>
      'Pasos: 1. Crea un proyecto con el botón +. 2. Selecciona una carpeta vacía. 3. Empieza a crear.';

  @override
  String get guideFeatures =>
      'Características principales: Análisis de Arquitectura, Documentación Viva, Chat IA, Híbrido';

  @override
  String get chatIATitle => 'Chat IA';

  @override
  String get chatIADescription =>
      'El panel central te permite hablar con tus documentos.';

  @override
  String get projectAlpha => 'PROYECTO-ALFA';

  @override
  String get projectContext => 'Contexto';

  @override
  String get projectArchitecture => 'Arquitectura';

  @override
  String get projectImplementation => 'Implementación';

  @override
  String get projectQuality => 'Calidad';

  @override
  String get projectDocumentation => 'Documentación';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'Inglés';

  @override
  String get avatarUpdated => 'Avatar actualizado correctamente';

  @override
  String avatarUpdateError(String error) {
    return 'Error al seleccionar avatar: $error';
  }

  @override
  String get profileTitle => 'Perfil';

  @override
  String get nameTitle => 'Nombre Completo';

  @override
  String get avatarTitle => 'Avatar';

  @override
  String get appearanceTitle => 'Apariencia';

  @override
  String get themeModeTitle => 'Tema';

  @override
  String get darkMode => 'Oscuro';

  @override
  String get lightMode => 'Claro';

  @override
  String get systemMode => 'Sistema';

  @override
  String get fontSizeTitle => 'Tamaño de Fuente';

  @override
  String get accessibilityTitle => 'Accesibilidad';

  @override
  String get zoomTitle => 'Zoom';

  @override
  String get enableZoomShortcuts => 'Habilitar atajos de teclado para zoom';

  @override
  String get performanceTitle => 'Rendimiento';

  @override
  String get enableAnimations => 'Habilitar animaciones';

  @override
  String get enableMemoryOptimization => 'Optimización de memoria';

  @override
  String get themeModeSubtitle => 'Cambia entre tema claro y oscuro';

  @override
  String get fontSizeSubtitle => 'Ajusta el tamaño del texto en la aplicación';

  @override
  String get zoomSubtitle => 'Ajusta el zoom de toda la aplicación';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get settingsSubtitle =>
      'Personaliza tu experiencia en SoftArchitect AI';
}
