import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:time_tracker_flutter_course/app/sign_in/email_sign_in_model.dart';
import 'package:time_tracker_flutter_course/app/sign_in/validators.dart';
import 'package:time_tracker_flutter_course/services/auth.dart';

class EmailSignInChangeModel with EmailAndPasswordValidators, ChangeNotifier {
  EmailSignInChangeModel({
    @required this.auth,
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.formType = EmailSignInFormType.signIn,
    this.isLoading = false,
    this.submitted = false,
  });

  AuthBase auth;
  String email;
  String password;
  String confirmPassword;
  EmailSignInFormType formType;
  bool isLoading;
  bool submitted;

  void toggleForm() {
    final formType = this.formType == EmailSignInFormType.signIn
        ? EmailSignInFormType.register
        : EmailSignInFormType.signIn;

    updateWith(
      email: '',
      password: '',
      confirmPassword: '',
      isLoading: false,
      formType: formType,
      submitted: false,
    );
  }

  void updateEmail(String email) => updateWith(email: email);
  void updatePassword(String password) => updateWith(password: password);
  void updateConfirmPassword(String confirmPassword) =>
      updateWith(confirmPassword: confirmPassword);

  Future<void> submit() async {
    updateWith(isLoading: true, submitted: true);
    try {
      if (formType == EmailSignInFormType.signIn) {
        await auth.signInWithEmailAndPassword(email, password);
      } else {
        if (confirmPassword != password) {
          throw (FirebaseAuthException(
            code: 'ERROR_PASSWORD_MISMATCH',
            message: 'Both Password fields should be the same',
          ));
          // await showAlertDialog(context,
          //     title: 'ERROR!',
          //     content: 'The password fields don\'t match',
          //     actionText: 'OK');
        } else {
          await auth.createUserWithEmailAndPassword(email, password);
        }
        // throw (AssertionError('Both Passwords should be the same'));
      }
    } catch (e) {
      updateWith(isLoading: false);
      rethrow;
    }
  }

  String get primaryText {
    return formType == EmailSignInFormType.signIn
        ? 'Sign In'
        : 'Create Account';
  }

  String get secondaryText {
    return formType == EmailSignInFormType.signIn
        ? 'Haven\'t signed up yet? Click here to register!'
        : 'Have an account? Sign In here!';
  }

  bool get enableSubmit {
    return formType == EmailSignInFormType.signIn
        ? emailValidator.isValid(email) &&
            passwordValidator.isValid(password) &&
            !isLoading
        : emailValidator.isValid(email) &&
            passwordValidator.isValid(password) &&
            passwordValidator.isValid(confirmPassword) &&
            !isLoading;
  }

  String get showErrorConfirmPassword {
    bool showError = submitted && !passwordValidator.isValid(confirmPassword);
    return showError ? invalidPassword : null;
  }

  String get showErrorPassword {
    bool showError = submitted && !passwordValidator.isValid(password);
    return showError ? invalidPassword : null;
  }

  String get showErrorEmail {
    bool showError = submitted && !emailValidator.isValid(email);
    return showError ? invalidEmail : null;
  }

  void updateWith({
    String email,
    String password,
    String confirmPassword,
    EmailSignInFormType formType,
    bool isLoading,
    bool submitted,
  }) {
    this.email = email ?? this.email;
    this.password = password ?? this.password;
    this.confirmPassword = confirmPassword ?? this.confirmPassword;
    this.formType = formType ?? this.formType;
    this.isLoading = isLoading ?? this.isLoading;
    this.submitted = submitted ?? this.submitted;
    notifyListeners();
  }
}
