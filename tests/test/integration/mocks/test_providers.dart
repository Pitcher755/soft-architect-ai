import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:softarchitect_ai/features/chat/domain/repositories/chat_repository.dart';
import 'package:softarchitect_ai/project_shell/domain/services/file_system_service.dart';
import 'mock_services.dart';

/// Provides mocked dependencies for integration tests.
final testChatRepositoryProvider = Provider<ChatRepository>((ref) {
  return MockChatRepository();
});

final testFileSystemServiceProvider =
    Provider<FileSystemService>((ref) {
  return MockFileSystemService();
});

/// Helper to get mock instances for assertion in tests
class TestMockHelper {
  static final _mockChatRepo = MockChatRepository();
  static final _mockFileSystem = MockFileSystemService();

  static MockChatRepository get chatRepository => _mockChatRepo;
  static MockFileSystemService get fileSystem => _mockFileSystem;

  static void reset() {
    _mockFileSystem.clear();
  }
}
