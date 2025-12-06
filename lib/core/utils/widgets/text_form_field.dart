import 'package:flutter/material.dart';

class TextFormFieldWidget extends StatelessWidget {
  final String labelText;

  final String hintText;
  final TextEditingController controller;
  final Widget prefixIcon;
  final bool obscureText ;
    final String? Function(String?)? validator;
    const TextFormFieldWidget({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
     required this.validator,
      required this.controller
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator:validator ,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        filled: true,
        fillColor: Colors.grey[200],
        labelStyle: TextStyle(color: Colors.grey),
        hintStyle: TextStyle(fontStyle: FontStyle.italic),
      ),
    );
  }
}
