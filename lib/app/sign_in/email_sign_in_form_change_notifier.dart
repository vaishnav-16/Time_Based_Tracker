import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker_flutter_course/app/sign_in/email_sign_in_bloc.dart';
import 'package:time_tracker_flutter_course/app/sign_in/email_sign_in_change_model.dart';
import 'package:time_tracker_flutter_course/common_widgets/form_submit_button.dart';
import 'package:time_tracker_flutter_course/common_widgets/show_exception_error.dart';
import 'package:time_tracker_flutter_course/services/auth.dart';

import 'email_sign_in_model.dart';

class EmailSignInFormChangeNotifier extends StatefulWidget {
  EmailSignInFormChangeNotifier({@required this.model});
  final EmailSignInChangeModel model;

  static Widget create(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    return ChangeNotifierProvider<EmailSignInChangeModel>(
      create: (_) => EmailSignInChangeModel(auth: auth),
      child: Consumer<EmailSignInChangeModel>(
        builder: (_, model, __) => EmailSignInFormChangeNotifier(model: model),
      ),
    );
  }

  @override
  _EmailSignInFormChangeNotifierState createState() =>
      _EmailSignInFormChangeNotifierState();
}

class _EmailSignInFormChangeNotifierState
    extends State<EmailSignInFormChangeNotifier> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordController2 = TextEditingController();

  // can switch to password textField without using focusNode for some reason
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  EmailSignInChangeModel get model => widget.model;

  @override
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
    model.toggleForm();
    FocusScope.of(context).requestFocus(_emailFocusNode);
    _emailController.clear();
    _passwordController.clear();
    _passwordController2.clear();
  }

  void _submit() async {
    try {
      await model.submit();
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      showExceptionError(
        context,
        title: 'Sign In Failed!',
        exception: e,
      );
    }
  }

  void _emailEditingComplete() {
    final newFocus = model.emailValidator.isValid(model.email)
        ? _passwordFocusNode
        : _emailFocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  void _passwordEditingComplete() {
    if (model.formType == EmailSignInFormType.signIn) {
      _submit();
    } else {
      final newFocus = model.passwordValidator.isValid(model.password)
          ? _confirmPasswordFocusNode
          : _passwordFocusNode;
      FocusScope.of(context).requestFocus(newFocus);
    }
  }

  List<Widget> _buildChildren() {
    if (model.formType == EmailSignInFormType.signIn) {
      return [
        _buildEmailTextField(),
        SizedBox(height: 8),
        _buildPasswordTextField(),
        SizedBox(height: 10),
        FormSubmitButton(
          text: model.primaryText,
          onPressed: model.enableSubmit ? _submit : null,
        ),
        SizedBox(height: 8),
        FlatButton(
          onPressed: model.isLoading ? null : _toggleForm,
          child: Text(model.secondaryText),
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
          text: model.primaryText,
          onPressed: model.enableSubmit ? _submit : null,
        ),
        SizedBox(height: 8),
        FlatButton(
          onPressed: model.isLoading ? null : _toggleForm,
          child: Text(model.secondaryText),
        ),
      ];
    }
  }

  TextField _buildConfirmPasswordTextField() {
    return TextField(
      focusNode: _confirmPasswordFocusNode,
      controller: _passwordController2,
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        errorText: model.showErrorConfirmPassword,
        enabled: model.isLoading == false,
      ),
      textInputAction: TextInputAction.done,
      obscureText: true,
      onChanged: model.updateConfirmPassword,
      onEditingComplete: _submit,
      style: TextStyle(fontSize: 20),
    );
  }

  TextField _buildPasswordTextField() {
    return TextField(
      focusNode: _passwordFocusNode,
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: 'Password',
        errorText: model.showErrorPassword,
        enabled: model.isLoading == false,
      ),
      obscureText: true,
      textInputAction: model.formType == EmailSignInFormType.signIn
          ? TextInputAction.done
          : TextInputAction.next,
      onChanged: model.updatePassword,
      onEditingComplete: () => _passwordEditingComplete(),
      style: TextStyle(fontSize: 20),
    );
  }

  TextField _buildEmailTextField() {
    return TextField(
      focusNode: _emailFocusNode,
      controller: _emailController,
      decoration: InputDecoration(
        labelText: 'Email ID',
        hintText: 'xyz@test.com',
        errorText: model.showErrorEmail,
        enabled: model.isLoading == false,
      ),
      autocorrect: false,
      keyboardType: TextInputType.emailAddress,
      onChanged: model.updateEmail,
      onEditingComplete: () => _emailEditingComplete(),
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
}
