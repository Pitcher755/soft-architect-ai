/// Circular buffer implementation for fixed-size collections.
///
/// Features:
/// - Automatic overflow handling (FIFO eviction)
/// - O(1) add/remove operations
/// - Memory-bounded (prevents leaks)
///
/// Use case: Chat history management (max 100 messages in RAM).
class CircularBuffer<T> {
  /// Creates circular buffer with specified capacity.
  ///
  /// [maxSize] - Maximum number of items to store.
  CircularBuffer({required this.maxSize})
    : _buffer = List<T?>.filled(maxSize, null);

  /// Internal list storing buffered items.
  final List<T?> _buffer;

  /// Maximum capacity of buffer.
  final int maxSize;

  /// Current write position (head).
  int _head = 0;

  /// Current read position (tail).
  int _tail = 0;

  /// Current number of items in buffer.
  int _count = 0;

  /// Current number of items in buffer.
  int get length => _count;

  /// Check if buffer is empty.
  bool get isEmpty => _count == 0;

  /// Check if buffer is full.
  bool get isFull => _count == maxSize;

  /// Add item to buffer.
  ///
  /// If buffer is full, oldest item is automatically evicted (FIFO).
  ///
  /// [item] - Item to add to buffer.
  void add(T item) {
    _buffer[_head] = item;
    _head = (_head + 1) % maxSize;

    if (isFull) {
      _tail = (_tail + 1) % maxSize;
    } else {
      _count++;
    }
  }

  /// Remove and return oldest item from buffer.
  ///
  /// Returns: Oldest item, or `null` if buffer is empty.
  T? remove() {
    if (isEmpty) {
      return null;
    }

    final item = _buffer[_tail];
    _buffer[_tail] = null;
    _tail = (_tail + 1) % maxSize;
    _count--;

    return item;
  }

  /// Convert buffer contents to list (FIFO order).
  ///
  /// Returns: List of all items in buffer, oldest first.
  List<T> toList() {
    final result = <T>[];
    var index = _tail;

    for (var i = 0; i < _count; i++) {
      final item = _buffer[index];
      if (item != null) {
        result.add(item);
      }
      index = (index + 1) % maxSize;
    }

    return result;
  }

  /// Clear all items from buffer.
  void clear() {
    for (var i = 0; i < maxSize; i++) {
      _buffer[i] = null;
    }
    _head = 0;
    _tail = 0;
    _count = 0;
  }

  /// Get item at specific index (0 = oldest).
  ///
  /// [index] - Index of item to retrieve (0-based).
  ///
  /// Returns: Item at index, or `null` if out of bounds.
  T? operator [](int index) {
    if (index < 0 || index >= _count) {
      return null;
    }

    final actualIndex = (_tail + index) % maxSize;
    return _buffer[actualIndex];
  }
}
