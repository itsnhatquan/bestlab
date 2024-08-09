import 'package:flutter/material.dart';

class MyDropdown extends StatefulWidget {
  final String hintText;
  final String labelText;
  final String? selectedItem;
  final List<String> items;
  final Function(String?) onChanged;

  const MyDropdown({
    super.key,
    required this.hintText,
    required this.labelText,
    required this.selectedItem,
    required this.items,
    required this.onChanged,
  });

  @override
  State<MyDropdown> createState() => _MyDropdownState();
}

class _MyDropdownState extends State<MyDropdown> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          color: Colors.grey.shade200,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: widget.selectedItem,
            hint: Text(
              widget.hintText,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 16,
              ),
            ),
            items: widget.items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: widget.onChanged,
            icon: Icon(Icons.arrow_drop_down, ),
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
            dropdownColor: Colors.grey.shade200,
          ),
        ),
      ),
    );
  }
}
