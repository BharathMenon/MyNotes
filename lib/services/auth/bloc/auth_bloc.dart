import 'package:bloc/bloc.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/bloc/auth_events.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // default state
  AuthBloc(AuthProvider provider) : super(const AuthStateUninitialized()) {
    on<AuthEventInitialize>((event, emit) async {
      await provider.initialize();
      final user = provider.CurrentUser;
      if (user == null) {
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));
      } else if (!user.isEmailverified) {
        emit(const AuthStateNeedsVerification());
      } else {
        emit(AuthstateLoggedIn(user));
      }
    });
    //send email Verification
    on<AuthEventSendEmailVerification>(
      (event, emit) async {
        await provider.sendEmailVerification();
        emit(state);
      },
    );
    //log in
    on<AuthEventLogIn>((event, emit) async {
      // emit(const AuthstateLoading()); We don't really need this..
      emit(const AuthStateLoggedOut(exception: null, isLoading: true));
      final email = event.Email;
      final password = event.password;
      try {
        final user = await provider.logIn(
          email: email,
          password: password,
        );
        if (!user.isEmailverified) {
          emit(const AuthStateLoggedOut(
            exception: null,
            isLoading: false,
          )); //Just to disable the loading screen.
          emit(const AuthStateNeedsVerification());
        } else {
          emit(const AuthStateLoggedOut(
            exception: null,
            isLoading: false,
          ));
          emit(AuthstateLoggedIn(user));
        }
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(
            exception: e,
            isLoading:
                false)); // In dart, exceptions are of Object type, as anything can be returned as an object.
      }
    });
    //Register
    on<AuthEventRegister>(
      (event, emit) async {
        try {
          await provider.createUser(
              email: event.email, password: event.password);
          await provider.sendEmailVerification();
          emit(const AuthStateNeedsVerification());
        } on Exception catch (e) {
          emit(AuthStateRegistering(e));
        }
      },
    );
    on<AuthEventLogOut>((event, emit) async {
      try {
        await provider.logOut();
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    });
  }
}
