import 'package:flutter/material.dart';

class SystemList extends StatefulWidget {
  SystemList({super.key});

  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<SystemList> {
  final List<String> users = [
    'System 1',
    'System 2',
    'System 3',
    'System 4',
    'System 5',
    'System 6',
    'System 7',
    'System 8',
    'System 9',
    'System 10',
    'System 11',
    'System 12',
  ];

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  void _removeItem(int index) {
    final removedItem = users[index];
    setState(() {
      users.removeAt(index);
    });
    _listKey.currentState!.removeItem(
      index,
      (context, animation) => _buildItem(removedItem, animation),
      duration: const Duration(milliseconds: 300),
    );
  }

  Widget _buildItem(String item, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: SystemRow(
          icon: Icons.person,
          text: item,
          onTap: () {},
          onDismissed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'System',
              style: TextStyle(
                fontSize: 35.0,
                fontWeight: FontWeight.bold,
              )
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Color.fromRGBO(0, 0, 0, 1),
            iconSize: 40.0,
            padding: EdgeInsets.fromLTRB(70, 0, 0, 0),
            onPressed: () {
              // Add your onPressed code here!
            },
          ),
          centerTitle: true,
        ),
        body: AnimatedList(
          key: _listKey,
          initialItemCount: users.length,
          itemBuilder: (context, index, animation) {
            return SizeTransition(
              sizeFactor: animation,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: SystemRow(
                  icon: Icons.build_circle_outlined,
                  text: users[index],
                  onTap: () {},
                  onDismissed: () => _removeItem(index),
                ),
              ),
            );
          },
        ));
  }
}

class SystemRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Function onTap;
  final Function onDismissed;

  SystemRow(
      {required this.icon,
      required this.text,
      required this.onTap,
      required this.onDismissed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
                alignment: Alignment.center), // Background for swipe left
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
                      size: 40,
                      color: Colors.black,
                    ),
                  ),
                  Expanded(
                    flex: 3, // Adjust flex to center the text
                    child: Text(
                      text,
                      textAlign: TextAlign.start, // Center align the text
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
                  )
                ],
              ),
            ),
          )),
    );
  }
}
