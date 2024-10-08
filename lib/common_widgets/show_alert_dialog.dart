import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<bool> showAlertDialog(
  BuildContext context, {
  @required String title,
  @required String content,
  String cancelActionText,
  @required String actionText,
}) {
  if (!Platform.isIOS) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            if (cancelActionText != null)
              FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(cancelActionText),
              ),
            FlatButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(actionText),
            ),
          ],
        );
      },
    );
  } else {
    return showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            if (cancelActionText != null)
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(cancelActionText),
              ),
            CupertinoDialogAction(
              child: Text(actionText),
              onPressed: () => Navigator.of(context).pop(true),
            )
          ],
        );
      },
    );
  }
}
