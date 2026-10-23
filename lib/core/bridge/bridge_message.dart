import 'dart:convert';
import 'bridge_protocol.dart';

/// Immutable message payload transmitted across the Flutter-Unity bridge.
class BridgeMessage {
  final String version;
  final String action;
  final Map<String, dynamic> payload;
  final int timestamp;

  BridgeMessage({
    this.version = BridgeProtocol.version,
    required this.action,
    this.payload = const {},
    int? timestamp,
  }) : timestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;

  factory BridgeMessage.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> payloadMap = {};
    if (json['payload'] != null) {
      if (json['payload'] is Map) {
        payloadMap = Map<String, dynamic>.from(json['payload'] as Map);
      } else if (json['payload'] is String) {
        try {
          payloadMap = Map<String, dynamic>.from(
            jsonDecode(json['payload'] as String) as Map,
          );
        } catch (_) {
          payloadMap = {'raw': json['payload']};
        }
      }
    } else if (json['payloadJson'] != null && json['payloadJson'] is String) {
      try {
        payloadMap = Map<String, dynamic>.from(
          jsonDecode(json['payloadJson'] as String) as Map,
        );
      } catch (_) {
        payloadMap = {'raw': json['payloadJson']};
      }
    }

    return BridgeMessage(
      version: json['version'] as String? ?? BridgeProtocol.version,
      action: json['action'] as String? ?? 'UNKNOWN',
      payload: payloadMap,
      timestamp: (json['timestamp'] as num?)?.toInt() ??
          DateTime.now().millisecondsSinceEpoch,
    );
  }

  factory BridgeMessage.parse(String rawJson) {
    final Map<String, dynamic> map =
        jsonDecode(rawJson) as Map<String, dynamic>;
    return BridgeMessage.fromJson(map);
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'action': action,
      'payload': payload,
      'payloadJson': jsonEncode(payload),
      'timestamp': timestamp,
    };
  }

  String serialize() => jsonEncode(toJson());

  @override
  String toString() =>
      'BridgeMessage(v: $version, action: $action, payload: $payload, ts: $timestamp)';
}
