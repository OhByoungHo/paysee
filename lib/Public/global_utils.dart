import 'package:toast/toast.dart';
import 'package:flutter/material.dart';

/// Convert a color hex-string to a Color object.
///
Color getColorFromHex(String hexColor) {
  hexColor = hexColor.toUpperCase().replaceAll('#', '');

  if (hexColor.length == 6) {
    hexColor = 'FF' + hexColor;
  }
  return Color(int.parse(hexColor, radix: 16));
}

void showAlertDialog(BuildContext context, String msg) async {
  String result = await showDialog(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
//        title: Text('확인'),
        content: Text(msg),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0)),
        actions: <Widget>[
          FlatButton(
            child: Text('OK'),
            onPressed: () {Navigator.pop(context, "OK");},
          ),
        ],
      );
    },
  );
}

void showAlertDialogOk(BuildContext context, String msg) async {
  String result = await showDialog(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('확인'),
        content: Text(msg),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0)),
        actions: <Widget>[
          FlatButton(
            child: Text('OK'),
            onPressed: () {Navigator.pop(context, "OK");},
          ),
        ],
      );
    },
  );
}

Future showAlertDialogOkConfirm(BuildContext context, String msg) async {
  return showDialog(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('확인'),
        content: Text(msg),
        actions: <Widget>[
          FlatButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.pop(context, "OK");
            },
          ),
        ],
      );
    },
  );
}

Future showAlertDialogOkCancel(BuildContext context, String msg) async {
  return showDialog(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('확인'),
        content: Text(msg),
        actions: <Widget>[
          FlatButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.pop(context, "OK");
            },
          ),
          FlatButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.pop(context, "Cancel");
            },
          ),
        ],
      );
    },
  );
}

void showToast(String msg, BuildContext context, {int duration, int gravity}) {
  Toast.show(msg, context, duration: duration, gravity: gravity);
}

