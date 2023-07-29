import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_user.dart';
import 'package:test/test.dart';

//Run program again every time you add a new dependency.
void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();
    test('Should not be initialized to begin with', () async {
      expect(provider.isinitialized, false);
    });
    test('Can\'t logout if not initialized', () {
      expect(
        provider.logOut(),
        throwsA(const TypeMatcher<NotinitializedException>()),
      );
    });
    test('Should be able to initialize', () async {
      await provider.initialize();
      expect(provider.isinitialized, true);
    });

    test('User should be null after initialization', () {
      expect(provider.CurrentUser, null);
    });
    test('Should be able to initialize in less than 2 seconds', () async {
      await provider.initialize();
      expect(provider.isinitialized, true);
    }, timeout: const Timeout(Duration(seconds: 2)));

    test('Create user should delegate to logIn function', () async {
      await provider.initialize();
      final bademailuser = provider.createUser(
        email: 'foo@bar.com',
        password: 'anypassword',
      );
      //Should not use await for future functions (in test at least) where error is expected.
      //Error doesn't need to wait.
      expect(bademailuser,
          throwsA(const TypeMatcher<UserNotFoundAuthException>()));
      final badpassworduser =
          provider.createUser(email: 'email', password: 'foobar');
      expect(badpassworduser,
          throwsA(const TypeMatcher<WrongPasswordAuthException>()));
      final user =
          await provider.createUser(email: 'email', password: 'password');
      expect(provider.CurrentUser, user);
      expect(user.isEmailverified, false);
    });
    test('Logged in user should be able to get verified', () async {
      await provider.initialize();
      await provider.createUser(email: 'email', password: 'password');
      await provider.sendEmailVerification();
      final user = provider.CurrentUser;
      expect(user, isNotNull);
      expect(user!.isEmailverified, true);
    });
    test('Should be able to log out and log in again', () async {
      await provider.initialize();
      await provider.createUser(email: 'email', password: 'password');
      await provider.logOut();
      await provider.logIn(
        email: 'email',
        password: 'password',
      );
      expect(provider.CurrentUser, isNotNull);
    });

    test('Should be able to send a reset password Email', () async {
      await provider.initialize();
      await provider.createUser(email: 'email', password: 'password');
      await provider.sendPasswordReset(Email: 'Nonexistent');
      expect(provider.sentresetpassword, false);
      await provider.sendPasswordReset(Email: 'Noneuser');
      expect(provider.sentresetpassword, false);
      await provider.sendPasswordReset(Email: 'jkrr');
      expect(provider.sentresetpassword, true);
    });
  });
}

class NotinitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _sentresetpassword = true;
  var _isinitialized =
      false; //_ before a avariable means that it exists only in this private field.
  bool get isinitialized => _isinitialized;
  bool get sentresetpassword => _sentresetpassword;
  @override
  AuthUser? get CurrentUser => _user;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isinitialized) throw NotinitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return logIn(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isinitialized = true;
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) {
    if (!isinitialized) throw NotinitializedException();
    if (email == 'foo@bar.com') throw UserNotFoundAuthException();
    if (password == 'foobar') throw WrongPasswordAuthException();
    const user = AuthUser(
      id: 'uid!',
      isEmailverified: false,
      email: 'foofoo',
    );
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!isinitialized) throw NotinitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isinitialized) throw NotinitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    const newUser =
        AuthUser(id: 'anyid', isEmailverified: true, email: 'fooobar');
    _user = newUser;
  }

  @override
  Future<void> sendPasswordReset({required String Email}) async {
    _sentresetpassword = true;
    if (!isinitialized) throw NotinitializedException();
    if (Email == 'Nonexistent') {
      _sentresetpassword = false;
      //throw InvalidEmailAuthException();
    }
    if (Email == 'Noneuser') {
      _sentresetpassword = false;
      //throw UserNotFoundAuthException();
    }

    Future.delayed(const Duration(seconds: 2));
  }
}
