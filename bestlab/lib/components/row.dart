import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bestlab/components/themeProvider.dart';

class myRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? subText; // Optional subtitle text
  final Function onTap;
  final Function onDismissed;
  final List<Widget>? actions; // Optional list of actions
  final String userRole; // Add userRole to the constructor

  myRow({
    required this.icon,
    required this.text,
    this.subText,
    required this.onTap,
    required this.onDismissed,
    this.actions,
    required this.userRole, // Add this line
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDarkMode = themeProvider.isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0), // Match padding with search bar
      child: GestureDetector(
        onTap: () => onTap(),
        child: Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[800] : Colors.white,
            borderRadius: BorderRadius.circular(12), // Match border radius with search bar
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 6,
                offset: Offset(0, 3), // matches shadow with search bar
              ),
            ],
          ),
          child: userRole.toLowerCase() == 'admin'
              ? Dismissible(
                  key: Key(text),
                  background: Container(), // No background for swipe right
                  secondaryBackground: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12), // Ensure border radius matches
                    ),
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      // Prevent dismissing on swipe right
                      return false;
                    }
                    // Allow dismissing on swipe left
                    return true;
                  },
                  onDismissed: (direction) {
                    if (direction == DismissDirection.endToStart) {
                      onDismissed();
                    }
                  },
                  child: _buildListTile(isDarkMode),
                )
              : _buildListTile(isDarkMode), // Render ListTile without Dismissible for non-admin users
        ),
      ),
    );
  }

  ListTile _buildListTile(bool isDarkMode) {
    return ListTile(
      leading: Icon(icon, color: isDarkMode ? Colors.white : Colors.black),
      title: Text(
        text,
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      subtitle: subText != null
          ? Text(
              subText!,
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: actions ?? [],
      ),
    );
  }
}
