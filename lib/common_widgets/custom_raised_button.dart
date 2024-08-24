import 'package:flutter/material.dart';

class CustomRaisedButton extends StatelessWidget {
  CustomRaisedButton({
    this.child,
    this.color,
    this.borderRadius: 8.0,
    this.height: 50.0,
    this.onPressed,
  })  : assert(height != null),
        assert(borderRadius != null);
  final Widget child;
  final Color color;
  final double borderRadius;
  final double height;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: RaisedButton(
        child: child,
        color: color,
        disabledColor: Colors.black45,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
          Radius.circular(borderRadius),
        )),
        onPressed: onPressed,
      ),
    );
  }
}
