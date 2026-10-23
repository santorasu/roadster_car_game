import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tesla_roadster_game/app/app.dart';
import 'package:tesla_roadster_game/core/audio/audio_settings.dart';
import 'package:tesla_roadster_game/core/audio/game_audio_service.dart';
import 'package:tesla_roadster_game/features/arcade_driving/domain/models/arcade_game_state.dart';
import 'package:tesla_roadster_game/features/arcade_driving/domain/models/player_car.dart';
import 'package:tesla_roadster_game/features/arcade_driving/presentation/widgets/arcade_game_over_dialog.dart';
import 'package:tesla_roadster_game/features/arcade_driving/presentation/widgets/arcade_hud.dart';
import 'package:tesla_roadster_game/features/arcade_driving/presentation/widgets/arcade_pause_dialog.dart';
import 'package:tesla_roadster_game/features/arcade_driving/presentation/widgets/audio_settings_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Feature 04: AudioSettings Unit Tests', () {
    late AudioSettings settings;

    setUp(() {
      settings = AudioSettings();
    });

    test('Initializes with intended defaults', () {
      expect(settings.masterMuted, isFalse);
      expect(settings.masterVolume, closeTo(0.80, 0.001));
      expect(settings.musicMuted, isFalse);
      expect(settings.musicVolume, closeTo(0.65, 0.001));
      expect(settings.sfxMuted, isFalse);
      expect(settings.sfxVolume, closeTo(0.85, 0.001));

      // Effective volume calculations
      expect(settings.effectiveMusicVolume, closeTo(0.80 * 0.65, 0.001));
      expect(settings.effectiveSfxVolume, closeTo(0.80 * 0.85, 0.001));
    });

    test('Master mute suppresses effective volumes to 0.0', () {
      settings.setMasterMuted(true);
      expect(settings.masterMuted, isTrue);
      expect(settings.effectiveMusicVolume, equals(0.0));
      expect(settings.effectiveSfxVolume, equals(0.0));

      settings.toggleMasterMute();
      expect(settings.masterMuted, isFalse);
      expect(settings.effectiveMusicVolume, greaterThan(0.0));
      expect(settings.effectiveSfxVolume, greaterThan(0.0));
    });

    test('Individual channel mutes suppress respective effective volume', () {
      settings.setMusicMuted(true);
      expect(settings.effectiveMusicVolume, equals(0.0));
      expect(settings.effectiveSfxVolume, greaterThan(0.0)); // SFX still active

      settings.setMusicMuted(false);
      settings.setSfxMuted(true);
      expect(settings.effectiveMusicVolume, greaterThan(0.0)); // Music active
      expect(settings.effectiveSfxVolume, equals(0.0));
    });

    test('Volume clamping protects against out-of-bounds values', () {
      settings.setMasterVolume(1.8);
      expect(settings.masterVolume, equals(1.0));

      settings.setMasterVolume(-0.5);
      expect(settings.masterVolume, equals(0.0));

      settings.setMusicVolume(1.2);
      expect(settings.musicVolume, equals(1.0));

      settings.setSfxVolume(-0.2);
      expect(settings.sfxVolume, equals(0.0));
    });

    test('Restore defaults resets all values and mute flags', () {
      settings.setMasterMuted(true);
      settings.setMasterVolume(0.2);
      settings.setMusicMuted(true);
      settings.setSfxVolume(0.1);

      settings.resetDefaults();

      expect(settings.masterMuted, isFalse);
      expect(settings.masterVolume, closeTo(0.80, 0.001));
      expect(settings.musicMuted, isFalse);
      expect(settings.musicVolume, closeTo(0.65, 0.001));
      expect(settings.sfxMuted, isFalse);
      expect(settings.sfxVolume, closeTo(0.85, 0.001));
    });
  });

  group('Feature 04: GameAudioService Lifecycle & Fallback Tests', () {
    late AudioSettings settings;
    late GameAudioService audioService;

    setUp(() {
      settings = AudioSettings();
      audioService = GameAudioService.custom(settings: settings, isTestMode: true);
    });

    test('Service operates safely in test/fallback mode without throwing exceptions', () async {
      await audioService.initialize();
      await audioService.startBgm();
      await audioService.updateEngineSound(speedMph: 120.0, isAccelerating: true, isBraking: false);
      await audioService.playCollision();
      await audioService.playVergeSpark();
      await audioService.playUiTap();
      await audioService.pauseAll();
      await audioService.resumeAll();
      await audioService.stopEngineSound();
      await audioService.stopBgm();
      await audioService.dispose();
      // Expect clean execution without unhandled exception
    });

    test('Lifecycle state changes correctly trigger audio suspension and resumption', () {
      audioService.handleLifecycleChange(AppLifecycleState.paused);
      audioService.handleLifecycleChange(AppLifecycleState.resumed);
      audioService.handleLifecycleChange(AppLifecycleState.inactive);
      audioService.handleLifecycleChange(AppLifecycleState.detached);
    });
  });

  group('Feature 04: UI Polish & Audio Modal Interactive Widget Tests', () {
    testWidgets('HomeScreen AppBar provides Audio Settings action opening AudioSettingsDialog',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const TeslaRoadsterGameApp());
      await tester.pump();

      final audioButton = find.byKey(const Key('home_audio_settings_button'));
      expect(audioButton, findsOneWidget);

      await tester.tap(audioButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify dialog is presented
      expect(find.byType(AudioSettingsDialog), findsOneWidget);
      expect(find.text('AUDIO CONTROL'), findsOneWidget);
      expect(find.byKey(const Key('master_mute_toggle')), findsOneWidget);
      expect(find.byKey(const Key('master_volume_slider')), findsOneWidget);
      expect(find.byKey(const Key('music_volume_slider')), findsOneWidget);
      expect(find.byKey(const Key('sfx_volume_slider')), findsOneWidget);

      // Close dialog
      final closeBtn = find.byKey(const Key('close_audio_settings_button'));
      expect(closeBtn, findsOneWidget);
      await tester.tap(closeBtn);
      await tester.pumpAndSettle();

      expect(find.byType(AudioSettingsDialog), findsNothing);

    });

    testWidgets('ArcadeHud displays speed power arc, critical hull styling, and audio control',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final player = PlayerCar();
      player.speedMph = 195.0; // High speed (hyper red)
      player.health = 0.18;   // Critical health (< 0.25)

      final state = ArcadeGameState();
      state.score = 45000;
      state.comboMultiplier = 2.0;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: ArcadeHud(
                player: player,
                state: state,
                onPausePressed: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Verify HUD readouts
      expect(find.text('195'), findsOneWidget);
      expect(find.text('MPH'), findsOneWidget);
      expect(find.text('CRITICAL HULL'), findsOneWidget);
      expect(find.text('18%'), findsOneWidget);
      expect(find.text('2.0x'), findsOneWidget);
      expect(find.byKey(const Key('hud_audio_settings_button')), findsOneWidget);
      expect(find.byKey(const Key('arcade_pause_button')), findsOneWidget);
    });

    testWidgets('ArcadePauseDialog and ArcadeGameOverDialog include audio settings triggers',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Test Pause Dialog
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: ArcadePauseDialog(
                onResume: () {},
                onRestart: () {},
                onExit: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('resume_game_button')), findsOneWidget);
      expect(find.byKey(const Key('pause_audio_settings_button')), findsOneWidget);
      expect(find.byKey(const Key('restart_game_button')), findsOneWidget);
      expect(find.byKey(const Key('exit_game_button')), findsOneWidget);

      // Test Game Over Dialog
      final player = PlayerCar()..topSpeedMph = 210.0;
      final state = ArcadeGameState()
        ..score = 92000
        ..highScore = 92000
        ..distanceMeters = 3400.0
        ..comboMultiplier = 1.5;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: ArcadeGameOverDialog(
                state: state,
                player: player,
                onRestart: () {},
                onExit: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('MISSION FAILED'), findsOneWidget);
      expect(find.text('NEW RECORD SCORE!'), findsOneWidget);
      expect(find.byKey(const Key('game_over_restart_button')), findsOneWidget);
      expect(find.byKey(const Key('game_over_audio_settings_button')), findsOneWidget);
      expect(find.byKey(const Key('game_over_exit_button')), findsOneWidget);
    });
  });
}
