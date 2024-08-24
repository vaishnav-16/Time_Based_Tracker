import 'package:time_tracker_flutter_course/app/sign_in/validators.dart';

enum EmailSignInFormType { signIn, register }

class EmailSignInModel with EmailAndPasswordValidators {
  EmailSignInModel({
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.formType = EmailSignInFormType.signIn,
    this.isLoading = false,
    this.submitted = false,
  });

  final String email;
  final String password;
  final String confirmPassword;
  final EmailSignInFormType formType;
  final bool isLoading;
  final bool submitted;

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

  EmailSignInModel copyWith({
    String email,
    String password,
    String confirmPassword,
    EmailSignInFormType formType,
    bool isLoading,
    bool submitted,
  }) {
    return EmailSignInModel(
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      formType: formType ?? this.formType,
      isLoading: isLoading ?? this.isLoading,
      submitted: submitted ?? this.submitted,
    );
  }
}
