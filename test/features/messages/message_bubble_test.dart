import 'package:araciyok/features/messages/data/models/message.dart';
import 'package:araciyok/features/messages/presentation/widgets/message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Message makeMessage({
    String senderId = 'u1',
    String body = 'Merhaba',
  }) {
    return Message(
      id: 'm1',
      threadId: 't1',
      senderId: senderId,
      body: body,
      isRead: true,
      createdAt: DateTime(2026, 5, 16, 14, 30),
    );
  }

  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('mesaj gövdesini render eder', (tester) async {
    final m = makeMessage(body: 'Yola çıktım');
    await tester.pumpWidget(wrap(MessageBubble(message: m, isMine: false)));
    expect(find.text('Yola çıktım'), findsOneWidget);
  });

  testWidgets('isMine ise farklı alignment kullanır', (tester) async {
    final m = makeMessage();
    await tester.pumpWidget(wrap(MessageBubble(message: m, isMine: true)));
    final align = tester.widget<Align>(find.byType(Align));
    expect(align.alignment, Alignment.centerRight);
  });

  testWidgets('!isMine ise sol hizalı', (tester) async {
    final m = makeMessage();
    await tester.pumpWidget(wrap(MessageBubble(message: m, isMine: false)));
    final align = tester.widget<Align>(find.byType(Align));
    expect(align.alignment, Alignment.centerLeft);
  });

  testWidgets('Message.isMine helper', (tester) async {
    final m = makeMessage(senderId: 'me');
    expect(m.isMine('me'), true);
    expect(m.isMine('other'), false);
  });
}
