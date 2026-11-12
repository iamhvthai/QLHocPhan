import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_middterm_crud_application/main.dart';

void main() {
  testWidgets('App khởi động', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
