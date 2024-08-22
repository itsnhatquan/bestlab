import 'package:flutter/material.dart';
import 'package:bestlab/components/my_textfield_stateful.dart';
import 'package:bestlab/components/my_button.dart';
import 'package:bestlab/components/my_dropdown.dart';
import 'package:provider/provider.dart';
import 'package:bestlab/components/themeProvider.dart';
import 'package:bestlab/components/user_provider.dart';
import 'login_page.dart';

class UserSetting extends StatefulWidget {
  final String userId;
  final String username;
  final String role;
  final List<String> systems;

  UserSetting({
    Key? key,
    required this.userId,
    required this.username,
    required this.role,
    required this.systems,
  }) : super(key: key);

  @override
  _UserSettingState createState() => _UserSettingState();
}

class _UserSettingState extends State<UserSetting> {
  late TextEditingController usernameController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  late String? selectedRole;
  late List<String> selectedSystems;
  List<String> systems = [];
  final AuthService authService = AuthService();
  String? loggedInUserRole;

  @override
  void initState() {
    super.initState();

    usernameController = TextEditingController(text: widget.username);
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    selectedRole = widget.role; // Initialize selectedRole with passed role
    selectedSystems = widget.systems; // Initialize selectedSystems with passed systems

    fetchSystems();
    fetchLoggedInUserRole(); // Fetch the role of the logged-in user
  }

  Future<void> fetchSystems() async {
    final fetchedSystems = await authService.getSystems();
    setState(() {
      systems = fetchedSystems;
    });
  }

  Future<void> fetchLoggedInUserRole() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    String? currentLoggedInUsername = userProvider.user?['username']; // Use null-aware operator

    if (currentLoggedInUsername != null) {
      loggedInUserRole = await authService.getUserRole(currentLoggedInUsername);
      setState(() {});
    }
  }

  Future<void> saveChanges() async {
    String newUsername = usernameController.text.trim();
    String newPassword = passwordController.text.trim();
    String confirmNewPassword = confirmPasswordController.text.trim();

    // Check if password confirmation matches
    if (newPassword.isNotEmpty && newPassword != confirmNewPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    // Prepare the data to be updated
    Map<String, dynamic> updatedData = {};

    if (newUsername.isNotEmpty && newUsername != widget.username) {
      updatedData['username'] = newUsername;
    }

    if (newPassword.isNotEmpty) {
      updatedData['password'] = newPassword;
    }

    if (selectedRole != null && selectedRole != widget.role) {
      updatedData['systemRole'] = selectedRole;
    }

    if (selectedSystems.isNotEmpty && selectedSystems != widget.systems) {
      updatedData['systemAccess'] = selectedSystems;
    }

    // Update the user data if there are changes
    if (updatedData.isNotEmpty) {
      bool success = await authService.updateUser(widget.userId, updatedData);

      if (success) {
        // Update the local data to reflect the changes
        Map<String, dynamic> updatedUser = {
          'userID': widget.userId,
          'username': newUsername.isNotEmpty ? newUsername : widget.username,
          'systemRole': selectedRole ?? widget.role,
          'systemAccess': selectedSystems.isNotEmpty ? selectedSystems : widget.systems,
        };

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User settings updated successfully")),
        );

        Navigator.of(context).pop(updatedUser); // Pass the updated data back
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update user settings")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No changes were made")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'User Settings',
          style: TextStyle(
            fontSize: 35.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          iconSize: 40.0,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
        backgroundColor: isDarkMode ? Colors.grey[900] : Color.fromRGBO(75, 117, 198, 1),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: Icon(
                    Icons.person,
                    size: 150,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 15),
                MyTextfieldStateful(
                  controller: usernameController,
                  hintText: 'Username',
                  labelText: 'Username',
                  obscureText: false,
                  showEyeIcon: false,
                ),
                const SizedBox(height: 15),
                MyTextfieldStateful(
                  controller: passwordController,
                  hintText: 'Password',
                  labelText: 'Password',
                  showEyeIcon: true,
                ),
                const SizedBox(height: 15),
                MyTextfieldStateful(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  labelText: 'Confirm Password',
                  showEyeIcon: true,
                ),
                const SizedBox(height: 15),
                if (loggedInUserRole?.toLowerCase() == 'admin') ...[
                  // Role selection using the custom MyDropdown component with single selection behavior
                  MyDropdown(
                    hintText: 'Select a role...',
                    labelText: 'Role',
                    selectedItems: selectedRole != null ? [selectedRole!] : [],
                    items: ['Admin', 'User'],
                    isSingleSelection: true, // Enforce single selection for role
                    onChanged: (List<String> newValue) {
                      setState(() {
                        if (newValue.isNotEmpty) {
                          selectedRole = newValue.first; // Only allow one role to be selected
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 15),
                  if (selectedRole?.toLowerCase() != 'admin') ...[
                    MyDropdown(
                      hintText: 'Select systems...',
                      labelText: 'Systems',
                      selectedItems: selectedSystems,
                      items: systems,
                      isSingleSelection: false, // Allow multiple selections for systems
                      onChanged: (List<String> newValue) {
                        setState(() {
                          selectedSystems = newValue;
                        });
                      },
                    ),
                  ],
                ],
                const SizedBox(height: 30),
                MyButton(
                  text: 'Save changes',
                  onTap: saveChanges,
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
    );
  }
}
