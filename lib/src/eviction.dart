typedef OnEvict = void Function(String key, dynamic value);

sealed class Expires {
  const Expires();

  const factory Expires.noExpires() = NoExpiration;
  const factory Expires.expiresAt(DateTime at) = ExpiresAt;
  factory Expires.expiresAfter(Duration ttl, {DateTime? from}) => ExpiresAt((from ?? DateTime.now()).add(ttl));
}

final class NoExpiration extends Expires {
  const NoExpiration();
}

final class ExpiresAt extends Expires {
  final DateTime at;
  const ExpiresAt(DateTime date) : at = date;
}
