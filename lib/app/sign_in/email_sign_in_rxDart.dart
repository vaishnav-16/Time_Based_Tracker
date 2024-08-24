import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:time_tracker_flutter_course/app/sign_in/email_sign_in_model.dart';
import 'package:time_tracker_flutter_course/services/auth.dart';


// made using rxdart for practise
class EmailSignInRxdart {
  EmailSignInRxdart({@required this.auth});
  final AuthBase auth;
  final _modelSubject = BehaviorSubject<EmailSignInModel>.seeded(EmailSignInModel());
  Stream<EmailSignInModel> get modelStream => _modelSubject.stream;
  EmailSignInModel get _model => _modelSubject.value;

  void dispose() {
    _modelSubject.close();
  }

  void toggleForm() {
    final formType = _model.formType == EmailSignInFormType.signIn
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
      if (_model.formType == EmailSignInFormType.signIn) {
        await auth.signInWithEmailAndPassword(_model.email, _model.password);
      } else {
        if (_model.confirmPassword != _model.password) {
          throw (FirebaseAuthException(
            code: 'ERROR_PASSWORD_MISMATCH',
            message: 'Both Password fields should be the same',
          ));
          // await showAlertDialog(context,
          //     title: 'ERROR!',
          //     content: 'The password fields don\'t match',
          //     actionText: 'OK');
        } else {
          await auth.createUserWithEmailAndPassword(
              _model.email, _model.password);
        }
        // throw (AssertionError('Both Passwords should be the same'));
      }
    } catch (e) {
      updateWith(isLoading: false);
      rethrow;
    }
  }

  void updateWith({
    String email,
    String password,
    String confirmPassword,
    EmailSignInFormType formType,
    bool isLoading,
    bool submitted,
  }) {
    _modelSubject.value = _model.copyWith(
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      formType: formType,
      isLoading: isLoading,
      submitted: submitted,
    );
  }
}