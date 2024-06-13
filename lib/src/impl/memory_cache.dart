import 'dart:async';

import 'package:dartcache/dartcache.dart';
import 'package:dartcache/src/cache_entry.dart';
import 'package:dartcache/src/eviction.dart';
import 'package:dartcache/src/eviction/eviction_policy.dart';

final class MemoryCache implements SyncCache {
  final Map<String, CacheEntry> _cache = {};
  final Duration? _defaultTtl;
  final Duration? _checkDuration;
  final OnEvict? _onEvictCallback;
  final int? _maxSize;
  final EvictionPolicy? _evictionPolicy;

  int _totalSize = 0;

  MemoryCache({
    Duration? defaultTtl,
    Duration? checkDuration = const Duration(minutes: 1),
    EvictionPolicy? evictionPolicy,
    OnEvict? onEvict,
    int? maxSize,
  })  : _defaultTtl = defaultTtl,
        _checkDuration = checkDuration,
        _evictionPolicy = evictionPolicy,
        _onEvictCallback = onEvict,
        _maxSize = maxSize,
        assert(maxSize == null || evictionPolicy != null, "evictionPolicy should be non-null with maxSize is specified.") {
    if (_checkDuration != null) {
      Timer.periodic(_checkDuration, _onEvictTimerTick);
    }
  }

  @override
  void clear() {
    _cache.clear();
    _evictionPolicy?.untrack();
    _totalSize = 0;
  }

  @override
  void evict(String key) {
    final value = _cache.remove(key);
    if (value != null) {
      _onEvict(key, value);
    }
  }

  @override
  T? get<T>(String key) {
    final value = _cache[key];
    if (value == null) return null;

    if (value.isExpired) {
      _cache.remove(key);
      _onEvictCallback?.call(key, value.value);
      _evictionPolicy?.untrack(key);
      return null;
    }

    return value.value as T;
  }

  @override
  void put<T>(String key, T value, {EntrySettings settings = const EntrySettings()}) {
    if (settings.size == null && _maxSize != null) {
      throw ArgumentError("Entry $key should specify a size because the MemoryCache instance specifies a max size.");
    }

    // check for size
    if (settings.size != null) {
      _ensureSize(settings.size!);
    }

    // get expiration policy
    Expires expire;
    if (settings.expire == null) {
      if (_defaultTtl == null) {
        expire = const Expires.noExpires();
      } else {
        expire = Expires.expiresAfter(_defaultTtl);
      }
    } else {
      expire = settings.expire!;
    }

    _cache[key] = CacheEntry(
      value: value,
      settings: EntrySettings(
        expire: expire,
        size: settings.size,
      ),
    );
    _evictionPolicy?.registerKey(key);

    if (settings.size != null) {
      _totalSize += settings.size!;
    }
  }

  @override
  bool update<T>(String key, T Function(T value) callback, {bool refreshTTL = false}) {
    final value = get<T>(key);
    if (value == null) return false;

    final updated = callback(value);
    if (refreshTTL && _defaultTtl != null) {
      // _cache[key] = CacheEntry(value: updated, expiration: DateTime.now().add(_defaultTtl));
    } else {
      _cache[key]!.value = updated;
    }
    _evictionPolicy?.registerKey(key);
    return true;
  }

  void _ensureSize(int size) {
    // evict keys until size is available
    int tryCount = 1;
    while (size > (_maxSize! - _totalSize) && tryCount < 5) {
      final String key = _evictionPolicy!.evictKey();
      final entry = _cache.remove(key);
      if (entry != null) {
        _totalSize -= entry.settings.size!;
      }
      tryCount++;
    }
  }

  void _onEvictTimerTick(_) {
    if (_cache.isEmpty) return;

    for (final MapEntry(:key, :value) in _cache.entries) {
      if (value.isExpired) {
        _cache.remove(key);
        _onEvict(key, value);
      }
    }
  }

  void _onEvict(String key, CacheEntry entry) {
    _onEvictCallback?.call(key, entry);
    _evictionPolicy?.untrack(key);
    if (entry.settings.size != null) {
      _totalSize -= entry.settings.size!;
    }
  }
}
