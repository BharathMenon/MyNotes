import 'package:bloc/bloc.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/bloc/auth_events.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';

// Do a hot restart anytime you change the AuthBloc. This is because the states ultimately get injected to context which happens in main.dart.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // default state
  AuthBloc(AuthProvider provider)
      : super(const AuthStateUninitialized(isLoading: true)) {
    on<AuthEventInitialize>((event, emit) async {
      await provider.initialize();
      final user = provider.CurrentUser;
      if (user == null) {
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));
      } else if (!user.isEmailverified) {
        emit(const AuthStateNeedsVerification(false));
      } else {
        emit(AuthstateLoggedIn(user: user, isLoading: false));
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
      emit(const AuthStateLoggedOut(
        exception: null,
        isLoading: true,
        loadingText: 'Please wait while we log you in',
      ));
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
          emit(const AuthStateNeedsVerification(false));
        } else {
          emit(const AuthStateLoggedOut(
            exception: null,
            isLoading: false,
          ));
          emit(AuthstateLoggedIn(user: user, isLoading: false));
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
          emit(const AuthStateNeedsVerification(false));
        } on Exception catch (e) {
          emit(AuthStateRegistering(exception: e, isLoading: false));
        }
      },
    );
    // Going to Register Screen
    on<AuthEventShouldRegister>(
      (event, emit) {
        emit(const AuthStateRegistering(exception: null, isLoading: false));
      },
    );
    // Reset Pasword
    on<AuthEventForgotPassword>((event, emit) async {
      emit(const AuthStateForgotPassword(
          exception: null, hasSentEmail: false, isLoading: false));

      final email = event.Email;
      if (email == null) {
        return; //user just wants to go to forgot-password screen.
      }
      // user wants to actually send a forgot-password email.
      emit(const AuthStateForgotPassword(
          exception: null, hasSentEmail: false, isLoading: true));
      bool didSendEmail;
      Exception? exception;
      try {
        await provider.sendPasswordReset(Email: email);
        didSendEmail = true;
        exception = null;
      } on Exception catch (e) {
        didSendEmail = false;
        exception = e;
      }
      emit(AuthStateForgotPassword(
          exception: exception, hasSentEmail: didSendEmail, isLoading: false));
    });
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
