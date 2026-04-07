import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ─── Kinetic Gradient Button ───────────────────────────────────────────────────
class KineticButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double verticalPadding;

  const KineticButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.verticalPadding = 20,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          gradient: AppColors.kineticGradient,
          borderRadius: BorderRadius.circular(100),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A003530),
              blurRadius: 40,
              offset: Offset(0, 20),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          vertical: verticalPadding,
          horizontal: 32,
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: AppColors.onPrimary,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.onPrimary,
                  ),
                ),
        ),
      ),
    );
  }
}

// ─── Glassmorphism App Bar ─────────────────────────────────────────────────────
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;

  const GlassAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64 + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 8,
        right: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.4),
      ),
      child: Row(
        children: [
          leading ?? const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: AppColors.onSurface,
              ),
            ),
          ),
          ...?actions,
        ],
      ),
    );
  }
}

// ─── Progress Ring ─────────────────────────────────────────────────────────────
class ProgressRing extends StatelessWidget {
  final double progress;     // 0.0 – 1.0
  final double size;
  final double strokeWidth;
  final Widget? child;
  final Color trackColor;
  final Color progressColor;

  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 120,
    this.strokeWidth = 10,
    this.child,
    this.trackColor = AppColors.primaryFixedDim,
    this.progressColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              progress: progress.clamp(0.0, 1.0),
              strokeWidth: strokeWidth,
              trackColor: trackColor,
              progressColor: progressColor,
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color trackColor;
  final Color progressColor;

  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Track
    paint.color = trackColor;
    canvas.drawCircle(center, radius, paint);

    // Progress
    paint.color = progressColor;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

// ─── Stat Card ─────────────────────────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final String iconCode;
  final Color? accentColor;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.iconCode,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A003530),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              IconData(
                int.parse(iconCode, radix: 16),
                fontFamily: 'MaterialIcons',
              ),
              color: accent,
              size: 22,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            unit,
            style: const TextStyle(
              fontFamily: 'Lexend',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Workout History Tile ──────────────────────────────────────────────────────
class WorkoutTile extends StatelessWidget {
  final String exerciseName;
  final String exerciseType;
  final int durationMinutes;
  final double caloriesBurned;
  final WorkoutIntensityBadge intensity;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const WorkoutTile({
    super.key,
    required this.exerciseName,
    required this.exerciseType,
    required this.durationMinutes,
    required this.caloriesBurned,
    required this.intensity,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: AppColors.kineticGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.fitness_center, color: AppColors.onPrimary, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exerciseName,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '$durationMinutes min',
                        style: const TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 8),
                      intensity,
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${caloriesBurned.toInt()}',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    color: AppColors.primary,
                  ),
                ),
                const Text(
                  'KCAL',
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
            if (onDelete != null) ...[
              const SizedBox(width: 12),
              GestureDetector(
                onTap: onDelete,
                child: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.errorContainer, size: 22),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class WorkoutIntensityBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bgColor;

  const WorkoutIntensityBadge({
    super.key,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  factory WorkoutIntensityBadge.fromLevel(String level) {
    switch (level) {
      case 'high':
        return const WorkoutIntensityBadge(
          label: 'HIGH',
          color: AppColors.tertiary,
          bgColor: AppColors.tertiaryContainer,
        );
      case 'extreme':
        return const WorkoutIntensityBadge(
          label: 'MAX',
          color: AppColors.error,
          bgColor: AppColors.errorContainer,
        );
      case 'low':
        return const WorkoutIntensityBadge(
          label: 'LOW',
          color: AppColors.secondary,
          bgColor: AppColors.secondaryFixed,
        );
      default:
        return const WorkoutIntensityBadge(
          label: 'MOD',
          color: AppColors.primary,
          bgColor: AppColors.primaryContainer,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Lexend',
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ─── Kinetic Weekly Bar Chart ──────────────────────────────────────────────────
class WeeklyBarChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final int selectedIndex;
  final double maxValue;

  const WeeklyBarChart({
    super.key,
    required this.values,
    required this.labels,
    this.selectedIndex = 6,
    required this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(values.length, (i) {
        final isSelected = i == selectedIndex;
        final ratio = maxValue > 0 ? (values[i] / maxValue).clamp(0.0, 1.0) : 0.0;
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (isSelected)
              Text(
                values[i].toInt().toString(),
                style: const TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              width: 28,
              height: 80 * ratio + 8,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? AppColors.kineticGradient
                    : null,
                color: isSelected
                    ? null
                    : AppColors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              labels[i],
              style: TextStyle(
                fontFamily: 'Lexend',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? AppColors.onSurface
                    : AppColors.outlineVariant,
                letterSpacing: 0.5,
              ),
            ),
          ],
        );
      }),
    );
  }
}

