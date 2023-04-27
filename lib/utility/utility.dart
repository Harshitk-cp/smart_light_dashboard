import 'dart:convert';

import 'package:flutter/material.dart';

class Utility {
  static void showAlert(BuildContext context, String text) {
    var alert = AlertDialog(
      content: Row(
        children: <Widget>[Text(text)],
      ),
      actions: <Widget>[
        ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "OK",
              style: TextStyle(color: Colors.white),
            ))
      ],
    );

    showDialog(
        context: context,
        builder: (_) {
          return alert;
        });
  }

  static void showSnack(String msg, GlobalKey<ScaffoldState> scaffoldKey) {
    final snackBarContent = SnackBar(content: Text(msg));
    ScaffoldMessenger.of(scaffoldKey.currentState!.context)
        .showSnackBar(snackBarContent);
  }
}
