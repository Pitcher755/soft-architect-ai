import 'package:mockito/mockito.dart';
import 'package:softarchitect_ai/features/chat/domain/repositories/chat_repository.dart';
import 'package:softarchitect_ai/features/project_shell/core/services/file_system_service.dart';

// Generate mocks using: flutter pub run build_runner build
class MockChatRepository extends Mock implements ChatRepository {
  @override
  Stream<String> generateDocument(
    String docType,
    String prompt,
    Map<String, dynamic> context,
  ) {
    return Stream<String>.fromIterable(_generateMockResponse(docType));
  }

  @override
  Future<void> saveProposal(dynamic proposal) async {
    // Mock implementation - just complete successfully
  }

  /// Generates mock LLM response based on document type
  List<String> _generateMockResponse(String docType) {
    final responses = {
      'PROJECT_MANIFESTO': [
        '# Project Manifesto\n\n',
        'This project aims to ',
        'create a comprehensive software ',
        'architecture AI assistant.\n\n',
        'Values:\n',
        '- Privacy First\n',
        '- Local-First\n',
        '- Security by Design\n',
      ],
      'VISION_PROMISE': [
        '# Vision & Promise\n\n',
        'We envision a world where ',
        'developers have AI-powered guidance ',
        'without compromising data sovereignty.\n',
      ],
      'USER_JOURNEY': [
        '# User Journey\n\n',
        '1. Create new project\n',
        '2. Configure project scope\n',
        '3. Generate documentation\n',
        '4. Validate and save\n',
      ],
    };

    return responses[docType] ??
        [
          'Generated content for $docType...\n',
          'This is a mock LLM response.\n',
        ];
  }
}

class MockFileSystemService extends Mock implements FileSystemService {
  final Map<String, String> _fileStorage = {};

  @override
  Future<void> saveDocument({
    required String projectPath,
    required String relativePath,
    required String content,
  }) async {
    final fullPath = '$projectPath/$relativePath';
    _fileStorage[fullPath] = content;
  }

  @override
  Future<String?> readDocument({
    required String projectPath,
    required String relativePath,
  }) async {
    final fullPath = '$projectPath/$relativePath';
    return _fileStorage[fullPath];
  }

  @override
  Future<bool> documentExists({
    required String projectPath,
    required String relativePath,
  }) async {
    final fullPath = '$projectPath/$relativePath';
    return _fileStorage.containsKey(fullPath);
  }

  @override
  Future<void> deleteDocument({
    required String projectPath,
    required String relativePath,
  }) async {
    final fullPath = '$projectPath/$relativePath';
    _fileStorage.remove(fullPath);
  }

  @override
  Future<void> initializeProjectDirectories({
    required String projectPath,
  }) async {
    // Mock implementation - just track initialization
    _fileStorage['$projectPath/.initialized'] = 'true';
  }

  /// Helper for tests to verify file was saved
  String? getSavedContent(String projectPath, String relativePath) {
    return _fileStorage['$projectPath/$relativePath'];
  }

  /// Helper for tests to check all saved files
  Map<String, String> getAllFiles() => _fileStorage;

  /// Helper for tests to clear storage between tests
  void clear() => _fileStorage.clear();
}
