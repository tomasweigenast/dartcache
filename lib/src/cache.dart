import 'dart:async';

import 'package:dartcache/src/cache_entry.dart';

abstract interface class Cache {
  FutureOr<T?> get<T>(String key);
  FutureOr<void> put<T>(String key, T value, {EntrySettings settings = const EntrySettings()});
  FutureOr<void> evict(String key);
  FutureOr<void> clear();
  FutureOr<bool> update<T>(String key, T Function(T value) callback, {bool refreshTTL = false});
}

abstract interface class SyncCache implements Cache {
  @override
  T? get<T>(String key);

  @override
  void put<T>(String key, T value, {EntrySettings settings = const EntrySettings()});

  @override
  void evict(String key);

  @override
  void clear();

  @override
  bool update<T>(String key, T Function(T value) callback, {bool refreshTTL = false});
}

abstract interface class AsyncCache implements Cache {
  @override
  Future<T?> get<T>(String key);

  @override
  Future<void> put<T>(String key, T value, {EntrySettings settings = const EntrySettings()});

  @override
  Future<void> evict(String key);

  @override
  Future<void> clear();

  @override
  Future<bool> update<T>(String key, T Function(T value) callback, {bool refreshTTL = false});
}
