import 'package:flutter/material.dart';
import '../../../../core/audio/game_audio_service.dart';
import '../../../../core/bridge/unity_bridge_service.dart';
import '../../../../core/storage/player_data_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/cyber_button.dart';
import 'package:tesla_roadster_game/features/arcade_driving/domain/models/game_mode.dart';
import 'package:tesla_roadster_game/features/arcade_driving/presentation/screens/arcade_game_screen.dart';
import 'package:tesla_roadster_game/features/arcade_driving/presentation/widgets/audio_settings_dialog.dart';
import 'package:tesla_roadster_game/features/game_viewport/presentation/screens/game_viewport_screen.dart';
import 'package:tesla_roadster_game/features/garage/presentation/widgets/garage_vehicle_selector.dart';
import '../widgets/career_records_card.dart';
import '../widgets/game_mode_selector.dart';
import '../widgets/quick_specs_row.dart';
import '../widgets/system_status_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GameMode _selectedMode = GameMode.endlessDrive;

  @override
  void initState() {
    super.initState();
    _loadSelectedMode();
    PlayerDataService.changeNotifier.addListener(_loadSelectedMode);
  }

  @override
  void dispose() {
    PlayerDataService.changeNotifier.removeListener(_loadSelectedMode);
    super.dispose();
  }

  void _loadSelectedMode() {
    PlayerDataService.instance.loadCareerData().then((data) {
      if (mounted) {
        setState(() {
          _selectedMode = data.selectedGameMode == 'time_trial'
              ? GameMode.timeTrial
              : GameMode.endlessDrive;
        });
      }
    }).catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.roadsterRed,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'ROADSTER',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '3D SIMULATOR',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            key: const Key('home_audio_settings_button'),
            icon: const Icon(Icons.tune_rounded, color: Color(0xFF00E5FF)),
            tooltip: 'Audio Settings',
            onPressed: () {
              GameAudioService.instance.playUiTap();
              AudioSettingsDialog.show(context);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const GarageVehicleSelector(),
              const SizedBox(height: 16),

              const QuickSpecsRow(),
              const SizedBox(height: 16),

              const SystemStatusCard(),
              const SizedBox(height: 16),

              const CareerRecordsCard(),
              const SizedBox(height: 16),

              GameModeSelector(
                onModeChanged: (mode) {
                  setState(() {
                    _selectedMode = mode;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Feature 02 & 09: Playable Arcade Driving
              CyberButton(
                key: const Key('play_arcade_game_button'),
                text: 'Play Arcade Drive (Flutter)',
                icon: Icons.sports_motorsports_rounded,
                variant: CyberButtonVariant.primary,
                height: 58,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ArcadeGameScreen(initialMode: _selectedMode),
                    ),
                  );
                  PlayerDataService.notifyDataChanged();
                },
              ),
              const SizedBox(height: 12),

              // Feature 01: 3D Mission Foundation (Preserved)
              CyberButton(
                key: const Key('play_game_button'),
                text: 'Launch 3D Mission',
                icon: Icons.view_in_ar_rounded,
                variant: CyberButtonVariant.outline,
                height: 52,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const GameViewportScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              // Test Error & Retry Flow Button
              CyberButton(
                key: const Key('simulate_error_launch_button'),
                text: 'Simulate Error & Test Retry',
                icon: Icons.bug_report_outlined,
                variant: CyberButtonVariant.outline,
                height: 48,
                onPressed: () {
                  UnityBridgeService().setSimulateError(true);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const GameViewportScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Legal / Attribution Note
              Center(
                child: Text(
                  'Independent Tribute Concept • Feature 01 Android Foundation\nAll trademarks and brand names belong to their respective owners.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 10,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
