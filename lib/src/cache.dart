import 'dart:async';

import 'package:dartcache/src/async_cache_impl.dart';
import 'package:dartcache/src/eviction.dart';
import 'package:dartcache/src/impl/memory_cache.dart';

abstract interface class Cache {
  // factory Cache.async() = AsyncCache;
  // factory Cache.sync() = SyncCache;

  FutureOr<T?> get<T>(String key);
  FutureOr<void> put<T>(String key, T value, {Expires? expires});
  FutureOr<void> evict(String key);
  FutureOr<void> clear();
  FutureOr<bool> update<T>(String key, T Function(T value) callback, {bool refreshTTL = false});
}

abstract interface class SyncCache implements Cache {
  factory SyncCache() => MemoryCache();

  @override
  T? get<T>(String key);

  @override
  void put<T>(String key, T value, {Expires? expires});

  @override
  void evict(String key);

  @override
  void clear();

  @override
  bool update<T>(String key, T Function(T value) callback, {bool refreshTTL = false});
}

abstract interface class AsyncCache implements Cache {
  factory AsyncCache() => AsyncCacheImpl();

  @override
  Future<T?> get<T>(String key);

  @override
  Future<void> put<T>(String key, T value, {Expires? expires});

  @override
  Future<void> evict(String key);

  @override
  Future<void> clear();

  @override
  Future<bool> update<T>(String key, T Function(T value) callback, {bool refreshTTL = false});
}
