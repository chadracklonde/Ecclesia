import 'package:ecclesia/features/members/domain/entities/member.dart';
import 'package:ecclesia/features/members/presentation/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('affiche "Pleine communion" pour le statut fullMember',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: StatusBadge(status: MemberStatus.fullMember)),
      ),
    );
    expect(find.text('Pleine communion'), findsOneWidget);
  });

  testWidgets('affiche "Probation" pour le statut probation', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: StatusBadge(status: MemberStatus.probation)),
      ),
    );
    expect(find.text('Probation'), findsOneWidget);
  });
}
