import 'package:flutter/material.dart';
import '../../../../core/bridge/unity_bridge_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/cyber_button.dart';
import 'package:tesla_roadster_game/features/game_viewport/presentation/screens/game_viewport_screen.dart';
import '../widgets/quick_specs_row.dart';
import '../widgets/roadster_hero_banner.dart';
import '../widgets/system_status_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const RoadsterHeroBanner(),
              const SizedBox(height: 16),

              const QuickSpecsRow(),
              const SizedBox(height: 16),

              const SystemStatusCard(),
              const SizedBox(height: 24),

              // Main Play Button
              CyberButton(
                key: const Key('play_game_button'),
                text: 'Launch 3D Mission',
                icon: Icons.play_arrow_rounded,
                variant: CyberButtonVariant.primary,
                height: 56,
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
