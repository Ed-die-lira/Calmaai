// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:calma_ai_flutter/main.dart';
import 'package:calma_ai_flutter/services/auth_service.dart';
import 'package:calma_ai_flutter/services/mock_auth_service.dart';

void main() {
  testWidgets('App inicializa corretamente', (WidgetTester tester) async {
    // Build our app with a mock auth service
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>(
            create: (_) => MockAuthService(),
          ),
        ],
        child: const CalmaApp(),
      ),
    );

    // Verificar se o título do app está presente
    expect(find.text('Calma AI'), findsOneWidget);
  });
}
