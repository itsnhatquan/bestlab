import 'package:flutter/material.dart';

class MyTextfieldStateful extends StatefulWidget {
  final String hintText;
  final String labelText;
  final TextEditingController controller;
  final bool obscureText;
  final bool showEyeIcon;

  const MyTextfieldStateful({
    super.key,
    required this.hintText,
    required this.labelText,
    required this.controller,
    this.obscureText = true,
    this.showEyeIcon = false,
  });

  @override
  State<MyTextfieldStateful> createState() => _MyTextfieldStatefulState();
}

class _MyTextfieldStatefulState extends State<MyTextfieldStateful> {
  bool passwordVisible = true;

  @override
  void initState() {
    super.initState();
    passwordVisible = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: widget.controller,
        obscureText: passwordVisible,
        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.grey[500]),
          labelText: widget.labelText,
          filled: true,
          fillColor: Colors.grey.shade200,
          suffixIcon: widget.showEyeIcon
              ? IconButton(
                  icon: Icon(passwordVisible
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      passwordVisible = !passwordVisible;
                    });
                  },
                )
              : null,
          alignLabelWithHint: false,
        ),
        keyboardType: widget.showEyeIcon
            ? TextInputType.visiblePassword
            : TextInputType.text,
        textInputAction: TextInputAction.done,
      ),
    );
  }
}
