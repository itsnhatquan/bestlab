import 'package:flutter/material.dart';
import 'package:bestlab/components/row.dart'; // Updated to use myRow
import 'package:bestlab/components/my_search_bar.dart';
import 'package:provider/provider.dart';
import 'package:bestlab/components/themeProvider.dart';
import 'login_page.dart'; // Ensure this imports the AuthService
import 'user_create_page.dart'; // Import the UserCreate page
import 'user_setting.dart';

class UserList extends StatefulWidget {
  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  late List<Map<String, dynamic>> users;
  late List<Map<String, dynamic>> filteredUsers;
  late TextEditingController searchController;
  final AuthService authService = AuthService();
  bool isLoading = true;
  String? errorMessage;
  Map<String, dynamic>? currentUser;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    fetchCurrentUser();
    fetchUsers();

    // Listen to changes in the search query
    searchController.addListener(() {
      _filterUsers(searchController.text);
    });
  }

  Future<void> fetchCurrentUser() async {
    try {
      final user = await authService.fetchCurrentLoggedInUser(context);
      if (user != null) {
        setState(() {
          currentUser = user;
        });
        fetchUsers(); // Fetch users after setting the currentUser
      } else {
        setState(() {
          errorMessage = 'Failed to load current user';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load current user';
        isLoading = false;
      });
    }
  }

  Future<void> fetchUsers() async {
    try {
      List<Map<String, dynamic>> allUsers = await authService.getAllUsers();
      users = allUsers.where((user) => user['systemRole'] == 'user' || user['systemRole'] == 'User').toList();

      setState(() {
        filteredUsers = users;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load users';
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _removeItem(int index) async {
    final username = filteredUsers[index]['username'];
    final userId = filteredUsers[index]['userID']; // Use 'userID' if that's your UUID field

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete $username?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      try {
        await authService.deleteUser(userId);

        setState(() {
          filteredUsers.removeAt(index);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$username deleted")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete $username")),
        );
      }
    }
  }

  Future<void> _upgradeRole(int index) async {
    final username = filteredUsers[index]['username'];
    final userId = filteredUsers[index]['userID']; // Use 'userID' if that's your UUID field
    final currentRole = filteredUsers[index]['systemRole'];

    final newRole = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Upgrade Role'),
          content: Container(
            width: double.maxFinite, // Ensures the container takes full width
            height: 200.0, // Adjust height as needed
            child: Scrollbar(
              child: ListView(
                shrinkWrap: true, // Prevents the ListView from expanding infinitely
                children: ['admin', 'owner', 'user']
                    .where((role) => role != currentRole)
                    .map((role) {
                  return ListTile(
                    title: Text(role),
                    onTap: () {
                      Navigator.of(context).pop(role);
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );

    if (newRole != null) {
      try {
        await authService.updateUserRole(userId, newRole);

        setState(() {
          filteredUsers[index]['systemRole'] = newRole;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$username upgraded to $newRole")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to upgrade $username")),
        );
      }
    }
  }

  void _filterUsers(String query) {
    setState(() {
      filteredUsers = users
          .where((user) => user['username'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _navigateToUserSetting(Map<String, dynamic> userData) async {
    final updatedUser = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserSetting(
          userId: userData['userID'], // Provide the selected user's ID
          username: userData['username'], // Provide the selected user's username
          role: userData['systemRole'], // Provide the selected user's role
          systems: userData['systemAccess'] is String
              ? [userData['systemAccess']] // Wrap the string in a list
              : List<String>.from(userData['systemAccess'] ?? []), // Ensure it's a List<String>
        ),
      ),
    );

    if (updatedUser != null) {
      setState(() {
        int index = users.indexWhere((user) => user['userID'] == updatedUser['userID']);
        if (index != -1) {
          users[index] = updatedUser;
        } else {
          users.add(updatedUser);
        }
        _filterUsers(searchController.text);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white, // Background color changes with theme
      appBar: AppBar(
        title: Text(
          'Users',
          style: TextStyle(
            fontSize: 24.0,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: themeProvider.isDarkMode ? Colors.grey[900]! : Color.fromRGBO(75, 117, 198, 1),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : Column(
                  children: [
                    const SizedBox(height: 15),
                    MySearchBar(
                      controller: searchController,
                      hintText: 'Search users...',
                      onChanged: _filterUsers,
                      backgroundColor: themeProvider.isDarkMode ? Colors.grey[800]! : Colors.white,
                      textColor: themeProvider.isDarkMode ? Colors.white : Colors.black,
                      hintColor: themeProvider.isDarkMode ? Colors.white54 : Colors.black54,
                    ),
                    const SizedBox(height: 15),
                    Expanded(
                      child: filteredUsers.isEmpty
                          ? Center(child: Text('No users found'))
                          : ListView.builder(
                              itemCount: filteredUsers.length,
                              itemBuilder: (context, index) {
                                return myRow(
                                  icon: Icons.person,
                                  text: filteredUsers[index]['username'],
                                  userRole: currentUser!['systemRole'],
                                  subText: 'User ID: ${filteredUsers[index]['userID']}',
                                  onTap: () => _navigateToUserSetting(filteredUsers[index]),
                                  onDismissed: () => _removeItem(index),
                                  actions: [
                                  ],
                                );
                              },
                            ),
                    ),
                  ],
                ),
      
      floatingActionButton: FloatingActionButton(
        foregroundColor: Color.fromRGBO(75, 117, 198, 1),
        backgroundColor: themeProvider.isDarkMode ? Colors.grey[700]! : Colors.white,
        shape: CircleBorder(
          eccentricity: 0,
          side: BorderSide(color: Color.fromRGBO(75, 117, 198, 1), width: 2.0),
        ),
        onPressed: () async {
          // Navigate to the UserCreate page and await the result
          final newUser = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserCreate(),
            ),
          );

          if (newUser != null) {
            setState(() {
              // Add the newly created user to the users list
              users.add(newUser);
              // Re-apply the search filter to include the new user
              _filterUsers(searchController.text);
            });
          }
        },
        child: Icon(Icons.add, color: themeProvider.isDarkMode ? Colors.white : Colors.black),
      ),
    );
  }
}
