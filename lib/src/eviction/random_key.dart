import 'dart:math';

import 'package:dartcache/src/eviction/eviction_policy.dart';

final class RandomKeyEviction implements EvictionPolicy {
  final _random = Random();
  final _keys = <String>[];

  @override
  void registerKey(String key) {
    _keys.add(key);
  }

  @override
  String evictKey() {
    final index = _random.nextInt(_keys.length);
    return _keys[index];
  }

  @override
  void untrack([String? index]) {
    if (index == null) {
      _keys.clear();
    } else {
      _keys.remove(index);
    }
  }

  @override
  void touchKey(String key) {}
}
