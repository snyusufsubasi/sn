import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/app_card.dart';
import '../../data/models/job_post.dart';

/// Demo / API key olmadan güzergah önizlemesi.
class ShipmentRoutePreview extends StatefulWidget {
  const ShipmentRoutePreview({required this.job, super.key});

  final JobPost job;

  @override
  State<ShipmentRoutePreview> createState() => _ShipmentRoutePreviewState();
}

class _ShipmentRoutePreviewState extends State<ShipmentRoutePreview>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDuration.deliberate,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: SizedBox(
          height: 140,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _RoutePainter(progress: _controller.value),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.job.originCity,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          widget.job.destinationCity,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ).animate().fadeIn(duration: AppDuration.base).slideY(begin: 0.04, end: 0);
  }
}

class _RoutePainter extends CustomPainter {
  _RoutePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = AppColors.ink50;
    canvas.drawRect(Offset.zero & size, bg);

    final line = Paint()
      ..color = AppColors.ink200
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final start = Offset(24, size.height * 0.35);
    final end = Offset(size.width - 24, size.height * 0.65);
    canvas.drawLine(start, end, line);

    final dot = Offset(
      start.dx + (end.dx - start.dx) * progress,
      start.dy + (end.dy - start.dy) * progress,
    );
    canvas.drawCircle(
      dot,
      8,
      Paint()..color = AppColors.ink900,
    );
    canvas.drawCircle(start, 6, Paint()..color = AppColors.ink900);
    canvas.drawCircle(end, 6, Paint()..color = AppColors.ink900);
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
