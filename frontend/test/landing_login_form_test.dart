import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/widgets/landing/landing_login_form.dart';

void main() {
  testWidgets('shows an invalid-credentials error after a login attempt', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var loginSubmitted = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 600,
            height: 800,
            child: LandingLoginForm(
              // Verify that the form still sends credentials to its login handler.
              onLoginPressed: (identifier, password) {
                loginSubmitted = true;
                expect(identifier, 'test@example.com');
                expect(password, 'wrong-password');
              },
              onBackPressed: () {},
              onRegisterPressed: () {},
              onForgotPasswordPressed: () {},
            ),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'wrong-password');
    await tester.tap(find.text('LOGIN'));
    await tester.pump();

    expect(loginSubmitted, isTrue);
    expect(
      find.text('Invalid email/contact number or password.'),
      findsOneWidget,
    );
  });
}
