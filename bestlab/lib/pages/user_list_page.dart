import 'package:flutter/material.dart';
import 'package:bestlab/components/row.dart';
import 'package:bestlab/components/my_search_bar.dart'; // Import the search bar component

class UserList extends StatefulWidget {
  final List<String> users;

  UserList({required this.users});

  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  late List<String> users;
  late List<String> filteredUsers;
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    users = widget.users;
    filteredUsers = users;
    searchController = TextEditingController();

    // Listen to changes in the search query
    searchController.addListener(() {
      _filterUsers(searchController.text);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _removeItem(int index) {
    setState(() {
      filteredUsers.removeAt(index);
    });
  }

  void _filterUsers(String query) {
    setState(() {
      filteredUsers = users
          .where((user) => user.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Users',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Add your settings logic here
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 15),
          MySearchBar(
            controller: searchController,
            hintText: 'Search users...',
            onChanged: _filterUsers, // Pass the filter function here
          ),
          const SizedBox(height: 15),
          Expanded(
            child: ListView.builder(
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(filteredUsers[index]),
                  background: Container(color: Colors.green),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  confirmDismiss: (direction) {
                    return Future.value(direction == DismissDirection.endToStart);
                  },
                  onDismissed: (direction) {
                    _removeItem(index);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("${filteredUsers[index]} dismissed")),
                    );
                  },
                  child: row(
                    icon: Icons.person,
                    text: filteredUsers[index],
                    onTap: () {},
                    onDismissed: () => _removeItem(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        foregroundColor: Color.fromRGBO(75, 117, 198, 1),
        backgroundColor: Colors.white,
        shape: CircleBorder(
            eccentricity: 0,
            side: BorderSide(color: Color.fromRGBO(75, 117, 198, 1), width: 2.0)),
        onPressed: () {
          // Add your add device logic here
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
