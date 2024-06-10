import 'dart:async';

import 'package:dartcache/dartcache.dart';
import 'package:dartcache/src/cache_entry.dart';
import 'package:dartcache/src/evict_policy.dart';
import 'package:dartcache/src/eviction.dart';

final class MemoryCache implements SyncCache {
  final Map<String, CacheEntry> _cache = {};
  final Duration? _defaultTtl;
  final Duration? _checkDuration;
  final OnEvict? _onEvict;
  final EvictPolicy _evictPolicy;

  MemoryCache({
    Duration? defaultTtl,
    Duration? checkDuration = const Duration(minutes: 1),
    EvictPolicy evictPolicy = EvictPolicy.expire,
    OnEvict? onEvict,
  })  : _defaultTtl = defaultTtl,
        _checkDuration = checkDuration,
        _evictPolicy = evictPolicy,
        _onEvict = onEvict {
    if (_checkDuration != null) {
      Timer.periodic(_checkDuration, _onEvictTimerTick);
    }
  }

  @override
  void clear() {
    _cache.clear();
  }

  @override
  void evict(String key) {
    final value = _cache.remove(key);
    if (value != null) {
      _onEvict?.call(key, value.value);
    }
  }

  @override
  T? get<T>(String key) {
    final value = _cache[key];
    if (value == null) return null;

    if (value.isExpired) {
      _cache.remove(key);
      _onEvict?.call(key, value.value);
      return null;
    }

    return value.value as T;
  }

  @override
  void put<T>(String key, T value, {Expires? expires}) {
    Duration? ttl;
    if (expires == null) {
      ttl = _defaultTtl;
    } else if (expires is NoExpiration) {
      ttl = null;
    } else if (expires is ExpiresAt) {
      ttl = expires.ttl;
    }

    _cache[key] = CacheEntry(value: value, expiration: ttl == null ? null : DateTime.now().add(ttl));
  }

  @override
  bool update<T>(String key, T Function(T value) callback, {bool refreshTTL = false}) {
    final value = get<T>(key);
    if (value == null) return false;

    final updated = callback(value);
    if (refreshTTL && _defaultTtl != null) {
      _cache[key] = CacheEntry(value: updated, expiration: DateTime.now().add(_defaultTtl));
    } else {
      _cache[key]!.value = updated;
    }
    return true;
  }

  void _onEvictTimerTick(_) {
    if (_cache.isEmpty) return;

    for (final MapEntry(:key, :value) in _cache.entries) {
      if (value.isExpired) {
        _cache.remove(key);
        _onEvict?.call(key, value.value);
      }
    }
  }
}
