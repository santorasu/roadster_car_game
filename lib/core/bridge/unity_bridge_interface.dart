import 'bridge_message.dart';

enum BridgeConnectionStatus {
  disconnected,
  connecting,
  connected,
  error,
}

abstract class IUnityBridge {
  BridgeConnectionStatus get currentStatus;
  Stream<BridgeConnectionStatus> get statusStream;
  Stream<BridgeMessage> get messageStream;
  String? get lastErrorMessage;

  Future<void> connect();
  Future<void> disconnect();
  Future<void> retryConnection();
  Future<void> sendMessage(BridgeMessage message);
  Future<BridgeMessage> sendRequest(String action, [Map<String, dynamic>? payload]);
  void setSimulateError(bool simulate);
}
