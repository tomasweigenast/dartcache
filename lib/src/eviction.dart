typedef OnEvict = void Function(String key, dynamic value);

sealed class Expires {
  const Expires();

  const factory Expires.noExpires() = NoExpiration;
  const factory Expires.expiresAt(Duration ttl) = ExpiresAt;
}

final class NoExpiration extends Expires {
  const NoExpiration();
}

final class ExpiresAt extends Expires {
  final Duration ttl;
  const ExpiresAt(this.ttl);
}
