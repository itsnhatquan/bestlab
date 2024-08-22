import 'package:flutter/material.dart';
import 'package:bestlab/components/my_textfield_stateful.dart';
import 'package:bestlab/components/my_button.dart';
import 'package:bestlab/components/my_dropdown.dart';
import 'package:provider/provider.dart';
import 'package:bestlab/components/themeProvider.dart';
import 'login_page.dart';
import 'package:uuid/uuid.dart';

class UserCreate extends StatefulWidget {
  UserCreate({super.key});

  @override
  _UserCreateState createState() => _UserCreateState();
}

class _UserCreateState extends State<UserCreate> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final AuthService authService = AuthService();

  String? selectedRole;
  List<String> selectedSystems = [];
  List<String> systems = [];
  final Uuid uuid = Uuid();

  @override
  void initState() {
    super.initState();
    fetchSystems();
  }

  Future<void> fetchSystems() async {
    systems = await authService.getSystems();
    setState(() {});
  }

  Future<void> createUser(BuildContext context) async {
    if (validatePassword()) {
      final newUser = {
        'userID': uuid.v4(), // Generate a unique userID
        'username': usernameController.text,
        'password': passwordController.text,
        'name': '', // Add logic to capture or input the name if needed
        'age': 0, // Add logic to capture or input the age if needed
        'systemRole': selectedRole ?? 'User', // Default to 'User' if no role is selected
        'systemAccess': selectedSystems,
      };

      bool success = await authService.addUser(newUser);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User created successfully! Role: $selectedRole, Systems: ${selectedSystems.join(", ")}')),
        );
        Navigator.of(context).pop(); // Go back to the previous screen
      } else {
        showError('Failed to create user');
      }
    }
  }

  bool validatePassword() {
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (password.isEmpty) {
      showError('Password cannot be empty');
      return false;
    }

    if (password.length < 8) {
      showError('Password must be at least 8 characters long');
      return false;
    }

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      showError('Password must contain at least one number');
      return false;
    }

    if (password != confirmPassword) {
      showError('Passwords do not match');
      return false;
    }

    return true;
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Create User',
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
                const SizedBox(height: 30),
                MyButton(
                  text: 'Create new user',
                  onTap: () => createUser(context),
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
