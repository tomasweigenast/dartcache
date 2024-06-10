final class CacheEntry {
  dynamic value;
  final DateTime? expiration;

  CacheEntry({required this.value, this.expiration});

  factory CacheEntry.fromJson(Map<String, dynamic> json) => CacheEntry(
        value: json["value"],
        expiration: json["exp"] == null ? null : DateTime.fromMillisecondsSinceEpoch(json["exp"] as int),
      );

  Map<String, dynamic> toJson() => {
        "value": value,
        "exp": expiration?.millisecondsSinceEpoch,
      };

  bool get isExpired => expiration != null && DateTime.now().isAfter(expiration!);
}
