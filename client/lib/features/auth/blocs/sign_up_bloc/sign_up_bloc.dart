import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_repository/user_repository.dart';

part 'sign_up_event.dart';
part 'sign_up_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final UserRepository _userRepository;
  SignUpBloc({required UserRepository userRepository})
    : _userRepository = userRepository,
      super(SignUpInitial()) {
    on<SignUpRequired>((event, emit) async {
      emit(SignUpLoading());
      try {
        // Mark as new sign-up BEFORE calling signUp().
        // Firebase auth state changes immediately on signUp(),
        // so this flag must be set before that happens.
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_new_signup', true);

        MyUser myUser= await _userRepository.signUp(
          event.user,
          event.password,
        );

        await _userRepository.setUserData(myUser);
        emit(SignUpSuccess());
      } on FirebaseAuthException catch (e) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('is_new_signup');
        emit(SignUpFailure("FirebaseAuthException: ${e.message}"));
      }
      catch (e) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('is_new_signup');
        emit(SignUpFailure("An unknown error occurred."));
      }
    });
  }
}
