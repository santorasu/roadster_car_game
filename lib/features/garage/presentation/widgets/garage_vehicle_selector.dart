import 'package:flutter/material.dart';
import '../../../../core/audio/game_audio_service.dart';
import '../../../../core/storage/player_data_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../domain/models/vehicle_definition.dart';
import '../painters/garage_car_preview_painter.dart';

/// Interactive Garage vehicle selector and customization dashboard.
/// Allows selecting among electric hypercar variants, customizing paint,
/// wheel rims, and neon underglow with real-time preview and milestone unlock checks.
class GarageVehicleSelector extends StatefulWidget {
  const GarageVehicleSelector({super.key});

  @override
  State<GarageVehicleSelector> createState() => _GarageVehicleSelectorState();
}

class _GarageVehicleSelectorState extends State<GarageVehicleSelector>
    with SingleTickerProviderStateMixin {
  late final AnimationController _turntableController;
  PlayerCareerData _careerData = const PlayerCareerData();
  int _inspectedVehicleIndex = 0;
  int _selectedCustomizationTab = 0; // 0: Paint, 1: Wheels, 2: Underglow
  String? _unlockHint;

  @override
  void initState() {
    super.initState();
    _turntableController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    if (!WidgetsBinding.instance.runtimeType.toString().contains('Test')) {
      _turntableController.repeat(reverse: true);
    }

    _loadData();
    PlayerDataService.changeNotifier.addListener(_onCareerDataChanged);
  }

  void _onCareerDataChanged() {
    if (mounted) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    final data = await PlayerDataService.instance.loadCareerData();
    if (!mounted) return;

    final foundIndex = VehicleCatalog.vehicles.indexWhere((v) => v.id == data.selectedVehicleId);
    setState(() {
      _careerData = data;
      if (foundIndex >= 0) {
        _inspectedVehicleIndex = foundIndex;
      }
    });
  }

  @override
  void dispose() {
    PlayerDataService.changeNotifier.removeListener(_onCareerDataChanged);
    _turntableController.dispose();
    super.dispose();
  }

  VehicleDefinition get _currentVehicle =>
      VehicleCatalog.vehicles[_inspectedVehicleIndex.clamp(0, VehicleCatalog.vehicles.length - 1)];

  PaintColorOption get _currentPaint {
    return VehicleCatalog.paints.firstWhere(
      (p) => p.id == _careerData.selectedPaintColorId,
      orElse: () => VehicleCatalog.paints.first,
    );
  }

  WheelStyleOption get _currentWheel {
    return VehicleCatalog.wheels.firstWhere(
      (w) => w.id == _careerData.selectedWheelStyleId,
      orElse: () => VehicleCatalog.wheels.first,
    );
  }

  UnderglowOption get _currentUnderglow {
    return VehicleCatalog.underglows.firstWhere(
      (u) => u.id == _careerData.selectedUnderglowColorId,
      orElse: () => VehicleCatalog.underglows.first,
    );
  }

  void _changeVehicle(int delta) {
    GameAudioService.instance.playUiTap();
    final count = VehicleCatalog.vehicles.length;
    setState(() {
      _inspectedVehicleIndex = (_inspectedVehicleIndex + delta + count) % count;
      _unlockHint = null;
    });
  }

  Future<void> _equipCurrentVehicle() async {
    final vehicle = _currentVehicle;
    if (!vehicle.isUnlocked(_careerData.unlockedMilestones)) {
      setState(() {
        _unlockHint = 'Locked: ${vehicle.unlockRequirementDescription}';
      });
      return;
    }

    GameAudioService.instance.playUiTap();
    await PlayerDataService.instance.saveVehicleCustomization(
      vehicleId: vehicle.id,
      paintColorId: _careerData.selectedPaintColorId,
      wheelStyleId: _careerData.selectedWheelStyleId,
      underglowColorId: _careerData.selectedUnderglowColorId,
    );
    setState(() {
      _unlockHint = null;
    });
  }

  Future<void> _selectPaint(PaintColorOption paint) async {
    if (!paint.isUnlocked(_careerData.unlockedMilestones)) {
      setState(() {
        _unlockHint = 'Locked: ${paint.unlockRequirementDescription}';
      });
      return;
    }

    GameAudioService.instance.playUiTap();
    await PlayerDataService.instance.saveVehicleCustomization(
      vehicleId: _careerData.selectedVehicleId,
      paintColorId: paint.id,
      wheelStyleId: _careerData.selectedWheelStyleId,
      underglowColorId: _careerData.selectedUnderglowColorId,
    );
    setState(() {
      _unlockHint = null;
    });
  }

  Future<void> _selectWheel(WheelStyleOption wheel) async {
    if (!wheel.isUnlocked(_careerData.unlockedMilestones)) {
      setState(() {
        _unlockHint = 'Locked: ${wheel.unlockRequirementDescription}';
      });
      return;
    }

    GameAudioService.instance.playUiTap();
    await PlayerDataService.instance.saveVehicleCustomization(
      vehicleId: _careerData.selectedVehicleId,
      paintColorId: _careerData.selectedPaintColorId,
      wheelStyleId: wheel.id,
      underglowColorId: _careerData.selectedUnderglowColorId,
    );
    setState(() {
      _unlockHint = null;
    });
  }

  Future<void> _selectUnderglow(UnderglowOption underglow) async {
    if (!underglow.isUnlocked(_careerData.unlockedMilestones)) {
      setState(() {
        _unlockHint = 'Locked: ${underglow.unlockRequirementDescription}';
      });
      return;
    }

    GameAudioService.instance.playUiTap();
    await PlayerDataService.instance.saveVehicleCustomization(
      vehicleId: _careerData.selectedVehicleId,
      paintColorId: _careerData.selectedPaintColorId,
      wheelStyleId: _careerData.selectedWheelStyleId,
      underglowColorId: underglow.id,
    );
    setState(() {
      _unlockHint = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = _currentVehicle;
    final isVehicleUnlocked = vehicle.isUnlocked(_careerData.unlockedMilestones);
    final isVehicleEquipped = _careerData.selectedVehicleId == vehicle.id;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: AppColors.surface,
      borderColor: AppColors.roadsterRed.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Header: Archetype Tag + Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isVehicleUnlocked ? const Color(0xFF00E5FF) : Colors.amber,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    vehicle.codeName.toUpperCase(),
                    style: AppTypography.mono.copyWith(
                      fontSize: 10,
                      color: isVehicleUnlocked ? const Color(0xFF00E5FF) : Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (isVehicleEquipped)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF00E5FF)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, color: Color(0xFF00E5FF), size: 12),
                      SizedBox(width: 4),
                      Text(
                        'EQUIPPED',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF00E5FF),
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                )
              else if (isVehicleUnlocked)
                InkWell(
                  key: const Key('equip_vehicle_button'),
                  onTap: _equipCurrentVehicle,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.roadsterRed,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.drive_eta_rounded, color: Colors.white, size: 12),
                        SizedBox(width: 4),
                        Text(
                          'EQUIP CAR',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_rounded, color: Colors.amber, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'LOCKED',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Vehicle Navigation Selector Row
          Row(
            children: [
              IconButton(
                key: const Key('garage_prev_car_button'),
                icon: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 28),
                tooltip: 'Previous Car',
                onPressed: () => _changeVehicle(-1),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      vehicle.name.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: AppTypography.displayLarge.copyWith(
                        fontSize: 22,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      vehicle.description,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                key: const Key('garage_next_car_button'),
                icon: const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 28),
                tooltip: 'Next Car',
                onPressed: () => _changeVehicle(1),
              ),
            ],
          ),

          // Lock Requirement Warning Banner
          if (!isVehicleUnlocked) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_outline_rounded, color: Colors.amber, size: 14),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'REQUIREMENT: ${vehicle.unlockRequirementDescription}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.amber,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),

          // Showroom Turntable Preview Canvas
          GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity != null) {
                if (details.primaryVelocity! < -100) {
                  _changeVehicle(1);
                } else if (details.primaryVelocity! > 100) {
                  _changeVehicle(-1);
                }
              }
            },
            child: SizedBox(
              height: 230,
              width: double.infinity,
              child: AnimatedBuilder(
                animation: _turntableController,
                builder: (context, _) {
                  final angle = (_turntableController.value - 0.5) * 0.35;
                  return CustomPaint(
                    key: Key('garage_preview_${vehicle.id}'),
                    painter: GarageCarPreviewPainter(
                      vehicle: vehicle,
                      paintColor: _currentPaint,
                      wheelStyle: _currentWheel,
                      underglow: _currentUnderglow,
                      turntableAngle: angle,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Dynamic Vehicle Handling & Performance Stats
          _buildStatsSection(vehicle),
          const SizedBox(height: 16),

          // Customization Tabs [PAINT] [WHEELS] [UNDERGLOW]
          Row(
            children: [
              _buildTabButton(0, 'PAINT', Icons.palette_outlined, const Key('garage_tab_paint')),
              const SizedBox(width: 8),
              _buildTabButton(1, 'WHEELS', Icons.adjust_rounded, const Key('garage_tab_wheels')),
              const SizedBox(width: 8),
              _buildTabButton(2, 'UNDERGLOW', Icons.blur_on_rounded, const Key('garage_tab_underglow')),
            ],
          ),
          const SizedBox(height: 12),

          // Customization Swatch Chooser
          if (_selectedCustomizationTab == 0)
            _buildPaintSelector()
          else if (_selectedCustomizationTab == 1)
            _buildWheelSelector()
          else
            _buildUnderglowSelector(),

          // Active Lock Hint Message
          if (_unlockHint != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: Colors.redAccent, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _unlockHint!,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 14),
                    onPressed: () => setState(() => _unlockHint = null),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String label, IconData icon, Key key) {
    final isSelected = _selectedCustomizationTab == index;
    return Expanded(
      child: InkWell(
        key: key,
        onTap: () {
          GameAudioService.instance.playUiTap();
          setState(() {
            _selectedCustomizationTab = index;
            _unlockHint = null;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF00E5FF).withValues(alpha: 0.18) : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? const Color(0xFF00E5FF) : Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 13,
                color: isSelected ? const Color(0xFF00E5FF) : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(VehicleDefinition vehicle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          _buildStatRow(
            label: 'MAX SPEED',
            valueText: '${vehicle.topSpeedMph.toInt()} MPH',
            progress: (vehicle.topSpeedMph / 280.0).clamp(0.0, 1.0),
            color: const Color(0xFFFF2644),
          ),
          const SizedBox(height: 8),
          _buildStatRow(
            label: 'ACCELERATION',
            valueText: vehicle.accelerationMultiplier >= 1.0
                ? '+${((vehicle.accelerationMultiplier - 1.0) * 100).round()}% TORQUE'
                : '-${((1.0 - vehicle.accelerationMultiplier) * 100).round()}% TORQUE',
            progress: (vehicle.accelerationMultiplier / 1.3).clamp(0.0, 1.0),
            color: const Color(0xFF00E5FF),
          ),
          const SizedBox(height: 8),
          _buildStatRow(
            label: 'HANDLING',
            valueText: vehicle.baseSteeringMultiplier >= 1.0
                ? '+${((vehicle.baseSteeringMultiplier - 1.0) * 100).round()}% LATERAL'
                : '-${((1.0 - vehicle.baseSteeringMultiplier) * 100).round()}% LATERAL',
            progress: (vehicle.baseSteeringMultiplier / 1.3).clamp(0.0, 1.0),
            color: const Color(0xFF00E676),
          ),
          const SizedBox(height: 8),
          _buildStatRow(
            label: 'DURABILITY',
            valueText: vehicle.damageMultiplier < 1.0
                ? '+32% ARMORED'
                : (vehicle.damageMultiplier > 1.0 ? '-25% FRAGILE' : 'STANDARD 1.0x'),
            progress: ((1.4 - vehicle.damageMultiplier) / 0.8).clamp(0.0, 1.0),
            color: const Color(0xFFFFAB00),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required String label,
    required String valueText,
    required double progress,
    required Color color,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.6,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 95,
          child: Text(
            valueText,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 9.5,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaintSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: VehicleCatalog.paints.map((paint) {
        final isSelected = _careerData.selectedPaintColorId == paint.id;
        final isUnlocked = paint.isUnlocked(_careerData.unlockedMilestones);

        return InkWell(
          key: Key('paint_option_${paint.id}'),
          onTap: () => _selectPaint(paint),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 100,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? paint.accentColor.withValues(alpha: 0.25)
                  : AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? paint.accentColor
                    : Colors.white.withValues(alpha: 0.1),
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 32,
                      height: 18,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: paint.gradientColors),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.white30, width: 0.8),
                      ),
                    ),
                    if (!isUnlocked)
                      Container(
                        width: 32,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.lock_rounded, color: Colors.amber, size: 12),
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  paint.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWheelSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: VehicleCatalog.wheels.map((wheel) {
        final isSelected = _careerData.selectedWheelStyleId == wheel.id;
        final isUnlocked = wheel.isUnlocked(_careerData.unlockedMilestones);

        return InkWell(
          key: Key('wheel_option_${wheel.id}'),
          onTap: () => _selectWheel(wheel),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 100,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF00E5FF).withValues(alpha: 0.22)
                  : AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF00E5FF)
                    : Colors.white.withValues(alpha: 0.1),
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: wheel.rimBaseColor,
                        border: Border.all(color: wheel.rimHighlightColor, width: 1.5),
                      ),
                      child: Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: wheel.caliperColor,
                          ),
                        ),
                      ),
                    ),
                    if (!isUnlocked)
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.65),
                        ),
                        child: const Icon(Icons.lock_rounded, color: Colors.amber, size: 12),
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  wheel.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUnderglowSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: VehicleCatalog.underglows.map((underglow) {
        final isSelected = _careerData.selectedUnderglowColorId == underglow.id;
        final isUnlocked = underglow.isUnlocked(_careerData.unlockedMilestones);

        return InkWell(
          key: Key('underglow_option_${underglow.id}'),
          onTap: () => _selectUnderglow(underglow),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 100,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? (underglow.color == Colors.transparent ? Colors.white12 : underglow.color.withValues(alpha: 0.22))
                  : AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? (underglow.color == Colors.transparent ? Colors.white70 : underglow.color)
                    : Colors.white.withValues(alpha: 0.1),
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: underglow.color == Colors.transparent
                            ? Colors.black
                            : underglow.color,
                        boxShadow: underglow.color != Colors.transparent
                            ? [
                                BoxShadow(
                                  color: underglow.color.withValues(alpha: 0.6),
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
                        border: Border.all(color: Colors.white30, width: 1.0),
                      ),
                      child: underglow.color == Colors.transparent
                          ? const Icon(Icons.block_rounded, size: 12, color: Colors.white54)
                          : null,
                    ),
                    if (!isUnlocked)
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.65),
                        ),
                        child: const Icon(Icons.lock_rounded, color: Colors.amber, size: 11),
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  underglow.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
