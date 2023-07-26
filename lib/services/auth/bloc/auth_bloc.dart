import 'package:bloc/bloc.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/bloc/auth_events.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // default state
  AuthBloc(AuthProvider provider) : super(const AuthstateLoading()) {
    on<AuthEventInitialize>((event, emit) async {
      await provider.initialize();
      final user = provider.CurrentUser;
      if (user == null) {
        emit(const AuthStateLoggedOut());
      } else if (!user.isEmailverified) {
        emit(const AuthStateNeedsVerification());
      } else {
        emit(AuthstateLoggedIn(user));
      }
    });
    //log in
    on<AuthEventLogIn>((event, emit) async {
      emit(const AuthstateLoading());
      final email = event.Email;
      final password = event.password;
      try {
        final user = await provider.logIn(
          email: email,
          password: password,
        );
        emit(AuthstateLoggedIn(user));
      } on Exception catch (e) {
        emit(AuthStateLoginFailure(
            e)); // In dart, exceptions are of Object type, as anything can be returned as an object.
      }
    });
    on<AuthEventLogOut>((event, emit) async {
      try {
        emit(const AuthstateLoading());
        await provider.logOut();
        emit(const AuthStateLoggedOut());
      } on Exception catch (e) {
        emit(AuthStateLogoutFailure(e));
      }
    });
  }
}
