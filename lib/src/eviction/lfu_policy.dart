import 'package:dartcache/src/eviction/eviction_policy.dart';

final class LfuKeyEviction implements EvictionPolicy {
  final _keys = <String, int>{};

  @override
  void registerKey(String key) {
    _keys[key] = 0;
  }

  @override
  String evictKey() {
    throw UnimplementedError();
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
  void touchKey(String key) {
    final current = _keys[key] ?? 0;
    _keys[key] = current + 1;
  }
}
