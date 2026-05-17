import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../domain/shipment_flow_step.dart';

class ShipmentTimeline extends StatelessWidget {
  const ShipmentTimeline({required this.steps, super.key});

  final List<ShipmentFlowStep> steps;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          _StepRow(step: steps[i], isLast: i == steps.length - 1).animate(
            delay: Duration(milliseconds: 30 * i),
          )
              .fadeIn(duration: AppDuration.base)
              .slideX(begin: -0.02, end: 0),
        ],
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.step, required this.isLast});

  final ShipmentFlowStep step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final active = step.isActive;
    final done = step.isComplete;
    final dotColor = done
        ? AppColors.success
        : active
            ? AppColors.ink900
            : AppColors.ink300;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Icon(
                  done
                      ? Icons.check_circle
                      : active
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                  color: dotColor,
                  size: 22,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: done ? AppColors.success : AppColors.ink200,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: active || done
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: active || done
                              ? AppColors.ink900
                              : AppColors.ink500,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step.subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.ink600,
                        ),
                  ),
                  if (step.shipperConfirmed != null) ...[
                    const SizedBox(height: 8),
                    _ConfirmLine(
                      label: 'Yükveren',
                      confirmed: step.shipperConfirmed!,
                    ),
                    _ConfirmLine(
                      label: 'Nakliyeci',
                      confirmed: step.carrierConfirmed ?? false,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmLine extends StatelessWidget {
  const _ConfirmLine({required this.label, required this.confirmed});

  final String label;
  final bool confirmed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          confirmed ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 16,
          color: confirmed ? AppColors.success : AppColors.ink300,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: confirmed ? AppColors.ink900 : AppColors.ink500,
            fontWeight: confirmed ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
