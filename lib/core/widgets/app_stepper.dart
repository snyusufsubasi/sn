import 'package:flutter/material.dart';

import '../theme/colors/app_palette.dart';
import '../theme/dimensions/app_spacing.dart';


/// Navlun durumu için adım adım ilerleme çubuğu.
///
/// ```
/// ○━━━━━●━━━━━○━━━━━○
/// Onay  Yükle Yolda Teslim
/// ```
class AppStepper extends StatelessWidget {
  const AppStepper({
    required this.steps,
    required this.activeStep,
    super.key,
  });

  /// Adım listesi — her adımın label'ı
  final List<String> steps;

  /// Aktif adım index'i (0-based)
  final int activeStep;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // İlerleme çizgisi + daireler
        SizedBox(
          height: 32,
          child: CustomPaint(
            painter: _StepperPainter(
              stepCount: steps.length,
              activeStep: activeStep,
              completedColor: const Color(AppPalette.green600),
              activeColor: const Color(AppPalette.navy800),
              inactiveColor: const Color(AppPalette.ink300),
              lineColor: const Color(AppPalette.ink300),
            ),
            size: Size.infinite,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Label satırı
        Row(
          children: List.generate(steps.length, (i) {
            final isActive = i == activeStep;
            final isCompleted = i < activeStep;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: i == 0 ? 0 : AppSpacing.xs,
                  right: i == steps.length - 1 ? 0 : AppSpacing.xs,
                ),
                child: Text(
                  steps[i],
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isActive || isCompleted
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: isCompleted
                        ? const Color(AppPalette.green600)
                        : isActive
                            ? const Color(AppPalette.navy800)
                            : const Color(AppPalette.ink500),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _StepperPainter extends CustomPainter {
  _StepperPainter({
    required this.stepCount,
    required this.activeStep,
    required this.completedColor,
    required this.activeColor,
    required this.inactiveColor,
    required this.lineColor,
  });

  final int stepCount;
  final int activeStep;
  final Color completedColor;
  final Color activeColor;
  final Color inactiveColor;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final spacing = size.width / (stepCount - 1).clamp(1, stepCount);
    final centerY = size.height / 2;
    final dotRadius = 6.0;
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < stepCount; i++) {
      final x = i * spacing;
      if (i == 0 && spacing.isFinite) {
        // Başlangıç
      }

      // Çizgi (daireler arası)
      if (i < stepCount - 1 && spacing.isFinite) {
        final nextX = (i + 1) * spacing;
        final isCompletedLine = i < activeStep;
        if (isCompletedLine) {
          // Tamamlanan çizgi — yeşil
          final completedPaint = Paint()
            ..color = completedColor
            ..strokeWidth = 2.5
            ..strokeCap = StrokeCap.round;
          canvas.drawLine(
            Offset(x, centerY),
            Offset(nextX, centerY),
            completedPaint,
          );
        } else {
          canvas.drawLine(
            Offset(x, centerY),
            Offset(nextX, centerY),
            linePaint,
          );
        }
      }

      // Daire
      final isCompleted = i < activeStep;
      final isActive = i == activeStep;
      final circlePaint = Paint()
        ..color = isCompleted
            ? completedColor
            : isActive
                ? activeColor
                : inactiveColor
        ..style = PaintingStyle.fill;

      if (isCompleted) {
        // Onay işareti
        canvas.drawCircle(Offset(x, centerY), dotRadius, circlePaint);
        _drawCheckmark(canvas, Offset(x, centerY), dotRadius);
      } else if (isActive) {
        canvas.drawCircle(Offset(x, centerY), dotRadius + 1, circlePaint);
        canvas.drawCircle(
          Offset(x, centerY),
          dotRadius + 3,
          Paint()
            ..color = activeColor.withOpacity(0.2)
            ..style = PaintingStyle.fill,
        );
      } else {
        canvas.drawCircle(Offset(x, centerY), dotRadius, circlePaint);
        // İçi boş hissi
        canvas.drawCircle(
          Offset(x, centerY),
          dotRadius - 2,
          Paint()
            ..color = const Color(AppPalette.white)
            ..style = PaintingStyle.fill,
        );
      }
    }
  }

  void _drawCheckmark(Canvas canvas, Offset center, double radius) {
    final path = Path()
      ..moveTo(center.dx - radius * 0.35, center.dy)
      ..lineTo(center.dx - radius * 0.1, center.dy + radius * 0.35)
      ..lineTo(center.dx + radius * 0.45, center.dy - radius * 0.3);
    final paint = Paint()
      ..color = const Color(AppPalette.white)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_StepperPainter old) =>
      old.activeStep != activeStep || old.stepCount != stepCount;
}
