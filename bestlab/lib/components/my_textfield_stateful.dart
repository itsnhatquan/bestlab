import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bestlab/components/themeProvider.dart';

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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDarkMode = themeProvider.isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: widget.controller,
        obscureText: passwordVisible,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.grey.shade700),
          ),
          hintText: widget.hintText,
          hintStyle: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
          labelText: widget.labelText,
          labelStyle: TextStyle(color: isDarkMode ? Colors.grey[300] : Colors.grey[800]),
          filled: true,
          fillColor: isDarkMode ? Colors.grey[800] : Colors.grey.shade200,
          suffixIcon: widget.showEyeIcon
              ? IconButton(
                  icon: Icon(
                    passwordVisible ? Icons.visibility : Icons.visibility_off,
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                  ),
                  onPressed: () {
                    setState(() {
                      passwordVisible = !passwordVisible;
                    });
                  },
                )
              : null,
          alignLabelWithHint: false,
        ),
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      ),
    );
  }
}
