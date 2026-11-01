class MockAuthAccount {
  final String firstName;
  final String lastName;
  final String? email;
  final String contactNumber;
  final String password;

  const MockAuthAccount({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.contactNumber,
    required this.password,
  });
}

class MockAuthService {
  MockAuthService._();

  static final MockAuthService instance =
      MockAuthService._();

  static const MockAuthAccount defaultAccount =
      MockAuthAccount(
    firstName: 'Test',
    lastName: 'User',
    email: 'test@guso.app',
    contactNumber: '09123456789',
    password: 'guso123',
  );

  MockAuthAccount? _registeredAccount;

  MockAuthAccount? get registeredAccount =>
      _registeredAccount;

  void register({
    required String firstName,
    required String lastName,
    String? email,
    required String contactNumber,
    required String password,
  }) {
    final cleanedEmail = email?.trim();

    _registeredAccount = MockAuthAccount(
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      email: cleanedEmail == null ||
              cleanedEmail.isEmpty
          ? null
          : cleanedEmail,
      contactNumber: contactNumber.trim(),
      password: password,
    );
  }

  bool login({
    required String identifier,
    required String password,
  }) {
    final cleanedIdentifier =
        identifier.trim();

    if (_matchesAccount(
      defaultAccount,
      cleanedIdentifier,
      password,
    )) {
      return true;
    }

    final account = _registeredAccount;

    if (account != null &&
        _matchesAccount(
          account,
          cleanedIdentifier,
          password,
        )) {
      return true;
    }

    return false;
  }

  bool _matchesAccount(
    MockAuthAccount account,
    String identifier,
    String password,
  ) {
    final matchesEmail =
        account.email != null &&
        identifier.toLowerCase() ==
            account.email!.toLowerCase();

    final matchesContact =
        identifier == account.contactNumber;

    return (matchesEmail || matchesContact) &&
        password == account.password;
  }

  bool isEmailTaken(String email) {
    final cleanedEmail =
        email.trim().toLowerCase();

    if (cleanedEmail.isEmpty) {
      return false;
    }

    if (defaultAccount.email
            ?.toLowerCase() ==
        cleanedEmail) {
      return true;
    }

    return _registeredAccount?.email
            ?.toLowerCase() ==
        cleanedEmail;
  }

  bool isContactTaken(
    String contactNumber,
  ) {
    final cleanedContact =
        contactNumber.trim();

    if (defaultAccount.contactNumber ==
        cleanedContact) {
      return true;
    }

    return _registeredAccount
            ?.contactNumber ==
        cleanedContact;
  }
}