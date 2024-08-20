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
    selectedRole = widget.role;
    selectedSystems = widget.systems;

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
                // Display dropdowns only if the logged-in user is an admin
                if (loggedInUserRole?.toLowerCase() == 'admin') ...[
                  MyDropdown(
                    hintText: 'Select a role...',
                    labelText: 'Role',
                    selectedItems: selectedRole != null ? [selectedRole!] : [],
                    items: ['Admin', 'User'],
                    onChanged: (List<String> newValue) {
                      setState(() {
                        selectedRole = newValue.isNotEmpty ? newValue.first : null;
                      });
                    },
                  ),
                  const SizedBox(height: 15),
                  MyDropdown(
                    hintText: 'Select systems...',
                    labelText: 'Systems',
                    selectedItems: selectedSystems,
                    items: systems,
                    onChanged: (List<String> newValue) {
                      setState(() {
                        selectedSystems = newValue;
                      });
                    },
                  ),
                ],
                const SizedBox(height: 30),
                MyButton(
                  text: 'Save changes',
                  onTap: () {
                    // Save changes logic
                  },
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
