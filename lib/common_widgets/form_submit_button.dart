import 'package:flutter/material.dart';
import 'package:time_tracker_flutter_course/common_widgets/custom_raised_button.dart';

class FormSubmitButton extends CustomRaisedButton {
  FormSubmitButton({
    @required String text,
    VoidCallback onPressed,
  }) : super(
          child: Text(
            text,
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          height: 44,
          color: Colors.amberAccent,
          borderRadius: 8,
          onPressed: onPressed,
        );
}
