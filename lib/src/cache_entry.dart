import 'package:dartcache/src/eviction.dart';

final class CacheEntry {
  dynamic value;
  final EntrySettings settings;

  CacheEntry({required this.value, required this.settings});

  factory CacheEntry.fromJson(Map<String, dynamic> json) => CacheEntry(
        value: json["value"],
        settings: EntrySettings.fromJson(json["settings"] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        "value": value,
        "settings": settings.toJson(),
      };

  bool get isExpired => switch (settings.expire) {
        ExpiresAt(:final at) => DateTime.now().isAfter(at),
        _ => false,
      };
}

final class EntrySettings {
  final Expires? expire;
  final int? size;

  const EntrySettings({
    this.expire,
    this.size,
  });

  factory EntrySettings.fromJson(Map<String, dynamic> json) => EntrySettings(
        expire: json["expire"] == null
            ? const Expires.noExpires()
            : Expires.expiresAt(DateTime.fromMillisecondsSinceEpoch((json["expire"] as int) * 1000)),
        size: json["size"] as int?,
      );

  Map<String, dynamic> toJson() => {
        "expire": switch (expire) {
          ExpiresAt(:final at) => at.millisecondsSinceEpoch ~/ 1000,
          _ => null,
        },
        "size": size,
      };
}
