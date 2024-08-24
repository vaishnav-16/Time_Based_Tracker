import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker_flutter_course/app/sign_in/validators.dart';
import 'package:time_tracker_flutter_course/common_widgets/form_submit_button.dart';
import 'package:time_tracker_flutter_course/common_widgets/show_alert_dialog.dart';
import 'package:time_tracker_flutter_course/common_widgets/show_exception_error.dart';
import 'package:time_tracker_flutter_course/services/auth.dart';

import 'email_sign_in_model.dart';

class EmailSignInFormStateful extends StatefulWidget
    with EmailAndPasswordValidators {
  @override
  _EmailSignInFormStatefulState createState() =>
      _EmailSignInFormStatefulState();
}

class _EmailSignInFormStatefulState extends State<EmailSignInFormStateful> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordController2 = TextEditingController();

  // can switch to password textField without using focusNode for some reason
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  EmailSignInFormType _formType = EmailSignInFormType.signIn;
  String get _email => _emailController.text;
  String get _password => _passwordController.text;
  String get _confirmPassword => _passwordController2.text;

  bool _submitted = false;
  bool _isLoading = false;

  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordController2.dispose();

    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _toggleForm() {
    setState(() {
      _formType = _formType == EmailSignInFormType.signIn
          ? EmailSignInFormType.register
          : EmailSignInFormType.signIn;
      _submitted = false;
    });

    FocusScope.of(context).requestFocus(_emailFocusNode);
    _emailController.clear();
    _passwordController.clear();
    _passwordController2.clear();
  }

  void _submit() async {
    setState(() {
      _submitted = true;
      _isLoading = true;
    });

    try {
      // await Future.delayed(Duration(seconds: 3));
      final auth = Provider.of<AuthBase>(context, listen: false);
      if (_formType == EmailSignInFormType.signIn) {
        await auth.signInWithEmailAndPassword(_email, _password);
      } else {
        if (_confirmPassword != _password) {
          await showAlertDialog(context,
              title: 'ERROR!',
              content: 'The password fields don\'t match',
              actionText: 'OK');
        } else {
          await auth.createUserWithEmailAndPassword(_email, _password);
        }
        // throw (AssertionError('Both Passwords should be the same'));
      }
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      showExceptionError(
        context,
        title: 'Sign In Failed!',
        exception: e,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _emailEditingComplete() {
    final newFocus = widget.emailValidator.isValid(_email)
        ? _passwordFocusNode
        : _emailFocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  void _passwordEditingComplete() {
    if (_formType == EmailSignInFormType.signIn) {
      _submit();
    } else {
      final newFocus = widget.passwordValidator.isValid(_password)
          ? _confirmPasswordFocusNode
          : _passwordFocusNode;
      FocusScope.of(context).requestFocus(newFocus);
    }
  }

  List<Widget> _buildChildren() {
    final primaryText =
        _formType == EmailSignInFormType.signIn ? 'Sign In' : 'Create Account';

    final secondaryText = _formType == EmailSignInFormType.signIn
        ? 'Haven\'t signed up yet? Click here to register!'
        : 'Have an account? Sign In here!';

    bool submitEnabled = _formType == EmailSignInFormType.signIn
        ? widget.emailValidator.isValid(_email) &&
            widget.passwordValidator.isValid(_password) &&
            !_isLoading
        : widget.emailValidator.isValid(_email) &&
            widget.passwordValidator.isValid(_password) &&
            widget.passwordValidator.isValid(_confirmPassword) &&
            !_isLoading;

    if (_formType == EmailSignInFormType.signIn) {
      return [
        _buildEmailTextField(),
        SizedBox(height: 8),
        _buildPasswordTextField(),
        SizedBox(height: 10),
        FormSubmitButton(
          text: primaryText,
          onPressed: submitEnabled ? _submit : null,
        ),
        SizedBox(height: 8),
        FlatButton(
          onPressed: _isLoading ? null : _toggleForm,
          child: Text(secondaryText),
        ),
      ];
    } else {
      return [
        _buildEmailTextField(),
        SizedBox(height: 8),
        _buildPasswordTextField(),
        SizedBox(height: 8),
        _buildConfirmPasswordTextField(),
        SizedBox(height: 10),
        FormSubmitButton(
          text: primaryText,
          onPressed: submitEnabled ? _submit : null,
        ),
        SizedBox(height: 8),
        FlatButton(
          onPressed: _isLoading ? null : _toggleForm,
          child: Text(secondaryText),
        ),
      ];
    }
  }

  TextField _buildConfirmPasswordTextField() {
    bool showError =
        _submitted && !widget.passwordValidator.isValid(_confirmPassword);
    return TextField(
      focusNode: _confirmPasswordFocusNode,
      controller: _passwordController2,
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        errorText: showError ? widget.invalidPassword : null,
        enabled: _isLoading == false,
      ),
      textInputAction: TextInputAction.done,
      obscureText: true,
      onChanged: (confirmPassword) => _updateState(),
      onEditingComplete: _submit,
      style: TextStyle(fontSize: 20),
    );
  }

  TextField _buildPasswordTextField() {
    bool showError = _submitted && !widget.passwordValidator.isValid(_password);
    return TextField(
      focusNode: _passwordFocusNode,
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: 'Password',
        errorText: showError ? widget.invalidPassword : null,
        enabled: _isLoading == false,
      ),
      obscureText: true,
      textInputAction: _formType == EmailSignInFormType.signIn
          ? TextInputAction.done
          : TextInputAction.next,
      onChanged: (password) => _updateState(),
      onEditingComplete: _passwordEditingComplete,
      style: TextStyle(fontSize: 20),
    );
  }

  TextField _buildEmailTextField() {
    bool showError = _submitted && !widget.emailValidator.isValid(_email);
    return TextField(
      focusNode: _emailFocusNode,
      controller: _emailController,
      decoration: InputDecoration(
        labelText: 'Email ID',
        hintText: 'xyz@test.com',
        errorText: showError ? widget.invalidEmail : null,
        enabled: _isLoading == false,
      ),
      autocorrect: false,
      keyboardType: TextInputType.emailAddress,
      onChanged: (email) => _updateState(),
      onEditingComplete: _emailEditingComplete,
      textInputAction: TextInputAction.next,
      style: TextStyle(fontSize: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: _buildChildren(),
      ),
    );
  }

  _updateState() {
    setState(() {});
  }
}
