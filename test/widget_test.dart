import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tesla_roadster_game/app/app.dart';
import 'package:tesla_roadster_game/core/bridge/bridge_message.dart';
import 'package:tesla_roadster_game/core/bridge/bridge_protocol.dart';
import 'package:tesla_roadster_game/core/bridge/mock_unity_bridge.dart';
import 'package:tesla_roadster_game/core/bridge/unity_bridge_interface.dart';
import 'package:tesla_roadster_game/core/bridge/unity_bridge_service.dart';

void main() {
  group('Feature 01: Flutter-Unity Foundation & Home Screen Tests', () {
    testWidgets('Home screen renders branding, specs, and play button',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const TeslaRoadsterGameApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Check title and branding
      expect(find.text('CYBER ROADSTER'), findsOneWidget);
      expect(find.text('3D SIMULATOR'), findsOneWidget);

      // Check quick specs
      expect(find.text('0-60 MPH'), findsOneWidget);
      expect(find.text('< 1.9s'), findsOneWidget);
      expect(find.text('TOP SPEED'), findsOneWidget);
      expect(find.text('250+ MPH'), findsOneWidget);

      // Check Play button
      expect(find.byKey(const Key('play_game_button')), findsOneWidget);
      expect(find.text('LAUNCH 3D MISSION'), findsOneWidget);
    });

    testWidgets('Tapping Play button opens GameViewportScreen and starts loading',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() async {
        await UnityBridgeService().disconnect();
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const TeslaRoadsterGameApp());
      await tester.pump();

      final playButton = find.byKey(const Key('play_game_button'));
      expect(playButton, findsOneWidget);

      await tester.tap(playButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Expect loading overlay
      expect(find.text('INITIALIZING UNITY SUBSYSTEM'), findsOneWidget);

      // Allow loading steps to complete
      await tester.pump(const Duration(milliseconds: 1500));

      // HUD speedometer should now be displayed
      expect(find.text('MPH'), findsOneWidget);

      // Disconnect cleanly before completing test
      await UnityBridgeService().disconnect();
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('Simulated error triggers Error Overlay with Retry button',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() async {
        await UnityBridgeService().disconnect();
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const TeslaRoadsterGameApp());
      await tester.pump();

      final errorLaunchButton =
          find.byKey(const Key('simulate_error_launch_button'));
      expect(errorLaunchButton, findsOneWidget);

      await tester.tap(errorLaunchButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1000));

      // Verify error overlay is displayed
      expect(find.text('BRIDGE CONNECTION ERROR'), findsOneWidget);
      final retryButton = find.byKey(const Key('retry_connection_button'));
      expect(retryButton, findsOneWidget);

      // Tap retry and verify reconnection starts
      await tester.tap(retryButton);
      await tester.pump();
      expect(find.text('INITIALIZING UNITY SUBSYSTEM'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 1500));
      expect(find.text('MPH'), findsOneWidget);

      // Disconnect cleanly before completing test
      await UnityBridgeService().disconnect();
      await tester.pump(const Duration(milliseconds: 100));
    });
  });

  group('Feature 01: Bridge Protocol & Mock Engine Tests', () {
    test('BridgeMessage serializes and deserializes correctly', () {
      final msg = BridgeMessage(
        action: BridgeProtocol.actionHandshakeSyn,
        payload: {'platform': 'android', 'minSdk': 24},
      );

      final json = msg.toJson();
      expect(json['version'], BridgeProtocol.version);
      expect(json['action'], BridgeProtocol.actionHandshakeSyn);

      final decoded = BridgeMessage.fromJson(json);
      expect(decoded.version, BridgeProtocol.version);
      expect(decoded.action, BridgeProtocol.actionHandshakeSyn);
      expect(decoded.payload['platform'], 'android');
    });

    test('MockUnityBridge executes handshake sequence to connected', () async {
      final bridge = MockUnityBridge();
      expect(bridge.currentStatus, BridgeConnectionStatus.disconnected);

      final connectFuture = bridge.connect();
      expect(bridge.currentStatus, BridgeConnectionStatus.connecting);

      await connectFuture;
      expect(bridge.currentStatus, BridgeConnectionStatus.connected);

      // Send ping and receive pong
      final pong = await bridge.sendRequest(BridgeProtocol.actionPing);
      expect(pong.action, BridgeProtocol.actionPong);
      expect(pong.payload['fps'], isNotNull);

      await bridge.disconnect();
      expect(bridge.currentStatus, BridgeConnectionStatus.disconnected);
      bridge.dispose();
    });
  });
}
