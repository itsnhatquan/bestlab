import 'package:bestlab/components/themeProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyDropdown extends StatefulWidget {
  final String hintText;
  final String labelText;
  final List<String> selectedItems;
  final List<String> items;
  final Function(List<String>) onChanged;

  const MyDropdown({
    super.key,
    required this.hintText,
    required this.labelText,
    required this.selectedItems,
    required this.items,
    required this.onChanged,
  });

  @override
  State<MyDropdown> createState() => _MyDropdownState();
}

class _MyDropdownState extends State<MyDropdown> {
  List<String> selectedItems = [];

  @override
  void initState() {
    super.initState();
    selectedItems = List.from(widget.selectedItems);
  }

  String getSelectedItemsText() {
    if (selectedItems.isEmpty) {
      return widget.hintText;
    } else {
      return selectedItems.join(', ');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDarkMode = themeProvider.isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
          color: isDarkMode ? Colors.grey[800] : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: null, // No pre-selected value for multi-select
            hint: Text(
              getSelectedItemsText(),
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                fontSize: 16,
              ),
            ),
            items: widget.items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: StatefulBuilder(
                  builder: (context, setState) {
                    final bool isSelected = selectedItems.contains(value);

                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedItems.remove(value);
                          } else {
                            selectedItems.add(value);
                          }
                          widget.onChanged(selectedItems);
                        });
                      },
                      child: Row(
                        children: [
                          Checkbox(
                            value: isSelected,
                            onChanged: (bool? checked) {
                              setState(() {
                                if (checked == true) {
                                  selectedItems.add(value);
                                } else {
                                  selectedItems.remove(value);
                                }
                                widget.onChanged(selectedItems);
                              });
                            },
                            activeColor: isDarkMode ? Colors.white : Colors.black,
                            checkColor: isDarkMode ? Colors.black : Colors.white,
                          ),
                          Text(
                            value,
                            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }).toList(),
            onChanged: (_) {},
            icon: Icon(Icons.arrow_drop_down, color: isDarkMode ? Colors.white : Colors.black),
            dropdownColor: isDarkMode ? Colors.grey[800] : Colors.grey.shade200,
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
