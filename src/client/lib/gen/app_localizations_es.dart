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
}
