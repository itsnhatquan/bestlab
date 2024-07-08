import 'package:flutter/material.dart';

class UserList extends StatefulWidget {
  UserList({super.key});

  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  final List<String> users = [
    'Tran Khanh Duc',
    'Nguyen Duc Dai',
    'Trinh Viet Quy',
    'Tong Nhat Quan',
    'User Test 1',
    'User Test 2',
    'User Test 3',
    'User Test 4',
    'User Test 5',
    'User Test 6',
    'User Test 7',
    'User Test 8',
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
        child: UserRow(
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
          title: Text('Users',
              style: TextStyle(
                fontSize: 35.0,
                fontWeight: FontWeight.bold,
              )),
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
                child: UserRow(
                  icon: Icons.person,
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

class UserRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Function onTap;
  final Function onDismissed;

  UserRow(
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
                      size: 30,
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
                      Icons.delete,
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
