import 'package:araciyok/features/jobs/domain/shipment_flow_step.dart';
import 'package:araciyok/features/jobs/presentation/widgets/shipment_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('aktif ve tamamlanan adımları render eder', (tester) async {
    final steps = [
      const ShipmentFlowStep(
        kind: ShipmentFlowStepKind.offerAccepted,
        title: 'Teklif kabul edildi',
        subtitle: 'A',
        isComplete: true,
        isActive: false,
      ),
      const ShipmentFlowStep(
        kind: ShipmentFlowStepKind.pickupApproval,
        title: 'Yük alma onayı',
        subtitle: 'B',
        isComplete: false,
        isActive: true,
        shipperConfirmed: true,
        carrierConfirmed: false,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ShipmentTimeline(steps: steps),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Teklif kabul edildi'), findsOneWidget);
    expect(find.text('Yük alma onayı'), findsOneWidget);
    expect(find.text('Yükveren'), findsOneWidget);
    expect(find.text('Nakliyeci'), findsOneWidget);

    // flutter_animate timer'larını temizle
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
