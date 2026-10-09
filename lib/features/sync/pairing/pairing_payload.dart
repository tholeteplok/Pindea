import 'dart:convert';

/// Pairing QR Payload Model conforming to PRD v1.1 Specification (Section 13.2)
class PairingPayload {
  final int version;
  final String hubId;
  final String name;
  final List<String> addresses;
  final int port;
  final String fingerprint;
  final String userId;
  final String token;
  final int expiresAt; // Epoch timestamp in seconds

  const PairingPayload({
    this.version = 1,
    required this.hubId,
    required this.name,
    required this.addresses,
    this.port = 47820,
    required this.fingerprint,
    required this.userId,
    required this.token,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().millisecondsSinceEpoch ~/ 1000 > expiresAt;

  Map<String, dynamic> toJson() => {
        'v': version,
        'hub_id': hubId,
        'name': name,
        'addrs': addresses,
        'port': port,
        'fp': fingerprint,
        'uid': userId,
        'tok': token,
        'exp': expiresAt,
      };

  String toJsonString() => jsonEncode(toJson());

  factory PairingPayload.fromJson(Map<String, dynamic> json) {
    return PairingPayload(
      version: json['v'] as int? ?? 1,
      hubId: json['hub_id'] as String,
      name: json['name'] as String,
      addresses: (json['addrs'] as List<dynamic>).map((e) => e.toString()).toList(),
      port: json['port'] as int? ?? 47820,
      fingerprint: json['fp'] as String,
      userId: json['uid'] as String,
      token: json['tok'] as String,
      expiresAt: json['exp'] as int,
    );
  }

  factory PairingPayload.fromJsonString(String raw) {
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return PairingPayload.fromJson(map);
  }
}
