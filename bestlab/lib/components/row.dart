import 'package:flutter/material.dart';

class row extends StatelessWidget { // Renamed to follow Dart naming conventions
  final IconData icon;
  final String text;
  final Function onTap;
  final Function onDismissed;

  row({
    required this.icon,
    required this.text,
    required this.onTap,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0), // Add bottom padding
      child: GestureDetector(
        onTap: () => onTap(),
        child: Container(
          constraints: BoxConstraints.expand(
            height:
                Theme.of(context).textTheme.headlineMedium!.fontSize! * 1.1 +
                    50.0,
          ),
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color.fromRGBO(217, 217, 217, 1)),
              )),
          child: Dismissible(
            key: Key(text),
            background: Container(), // No background for swipe right
            secondaryBackground: Container(
              color: Colors.red,
              alignment: Alignment.center,
            ), // Background for swipe left
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
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: Icon(
                      icon,
                      size: 30,
                      color: Colors.black,
                    ),
                  ),
                  Expanded(
                    flex: 3, // Adjust flex to center the text
                    child: Text(
                      text,
                      textAlign: TextAlign.start, // Align the text to the start
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Icon(
                      Icons.delete_outline_outlined,
                      size: 25,
                      color: Color.fromRGBO(75, 117, 198, 1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
