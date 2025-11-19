import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ShowdialogWidget extends StatelessWidget {
  final String title;
  final String message;
  final String textAction;
  final void Function()? onPressed;

  const ShowdialogWidget({
    super.key,
    required this.message,
    required this.onPressed,
    required this.title,
    required this.textAction,
  });

  //showDialog(
  //       context: context,
  //       builder: (BuildContext context) {}

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel", style: TextStyle(color: Colors.grey.shade600)),
        ),
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            textAction,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
