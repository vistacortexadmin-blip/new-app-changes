import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vistacortex_new_features/features/auth/views/login_screen.dart';
import 'package:vistacortex_new_features/features/auth/views/welcome_screen.dart';

void main() {
  testWidgets('landing page continues to sign in and sign up screen',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: WelcomeScreen()),
    );

    expect(find.text('VistaCortex'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign In'), findsWidgets);
    expect(find.text('Sign Up'), findsOneWidget);

    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    expect(find.text('Create Account'), findsWidgets);
    expect(find.text('Confirm Password'), findsOneWidget);
  });
}
