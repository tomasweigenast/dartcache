abstract interface class EvictionPolicy {
  /// Calculates and returns the key that should be deleted next.
  String evictKey();

  /// Registers a new key.
  void registerKey(String key);

  /// Registers an interaction with a key.
  void touchKey(String key);

  /// Removes the specified key. If [key] is null, untracks every key.
  void untrack([String? key]);
}
