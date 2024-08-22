import 'package:bestlab/pages/login_page.dart';
import 'package:bestlab/pages/system_list_page.dart';
import 'package:bestlab/pages/user_list_page.dart';
import 'package:bestlab/pages/device_list_page.dart'; // Import your DeviceList page
import 'aboutUs.dart';
import 'package:flutter/material.dart';
import 'package:bestlab/components/themeProvider.dart';
import 'package:provider/provider.dart';
import 'user_setting.dart';

class Dashboard extends StatefulWidget {
  final Map<String, dynamic> userData;

  Dashboard({required this.userData});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Map<String, dynamic>? currentUser;
  late double height, width;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    var user = await authService.fetchCurrentLoggedInUser(context);
    if (user != null) {
      setState(() {
        currentUser = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    // Get the current theme provider from the context
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      drawer: _drawer(context, themeProvider), // Pass the themeProvider to the drawer
      body: Container(
        color: themeProvider.isDarkMode // Use themeProvider to check for dark mode
            ? Colors.black
            : Color.fromRGBO(75, 117, 198, 1),
        width: width,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(),
              height: height * 0.23,
              width: width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 50,
                      left: 20,
                      right: 15,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () => _scaffoldKey.currentState?.openDrawer(),
                          child: Icon(
                            Icons.menu,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 20,
                      left: 30,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dashboard',
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1,
                          ),
                        ),
                        if (currentUser != null) ...[
                          Text(
                            'Hello ${currentUser!['username']}!',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white54,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: themeProvider.isDarkMode
                      ? Colors.grey[900]
                      : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                width: width,
                padding: EdgeInsets.only(top: 2),
                child: SingleChildScrollView(
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.1,
                      mainAxisSpacing: 25,
                    ),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return InkWell(
                          onTap: () async {
                            var systems = await authService.getSystems(); // Fetch systems from MongoDB
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SystemList(
                                  systems: systems, // Pass the fetched systems
                                  userData: currentUser!,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: themeProvider.isDarkMode
                                  ? Colors.grey[800]
                                  : Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  spreadRadius: 1,
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(Icons.build_circle_outlined, size: 50,),
                                Text(
                                  "Systems",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: themeProvider.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else if (index == 1) {  // No role check here, "Users" tab always shows
                        return InkWell(
                          onTap: () async {
                            if (currentUser!['systemRole'].toLowerCase() == 'admin') {
                              // If the role is 'admin', fetch all users and navigate to the UserList page
                              var users = await authService.getAllUsers();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserList(),
                                ),
                              );
                            } else if (currentUser!['systemRole'].toLowerCase() == 'user') {
                              // If the role is 'user', navigate to the UserSetting page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserSetting(
                                    userId: currentUser!['userID'],
                                    username: currentUser!['username'],
                                    role: currentUser!['systemRole'],
                                    systems: currentUser!['systemAccess'] is String
                                        ? [currentUser!['systemAccess']]
                                        : List<String>.from(currentUser!['systemAccess'] ?? []),
                                  ),
                                ),
                              );
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  spreadRadius: 1,
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(Icons.person, size: 50),
                                Text(
                                  "Users",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else if (index == 2) {
                        return InkWell(
                          onTap: () async {
                            var allDevices = await authService.getAllDevices(); // Fetch all devices
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DeviceList(
                                  systemName: "All Devices",
                                  devices: allDevices,
                                  userData: currentUser!,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: themeProvider.isDarkMode
                                  ? Colors.grey[800]
                                  : Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  spreadRadius: 1,
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(Icons.devices, size: 50,),
                                Text(
                                  "Devices",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: themeProvider.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return InkWell(
                          onTap: () {},
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: themeProvider.isDarkMode
                                  ? Colors.grey[800]
                                  : Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  spreadRadius: 1,
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(Icons.hourglass_bottom, size: 50,),
                                Text(
                                  "Title",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: themeProvider.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                    itemCount: 4, // Adjust the item count based on the number of grid items
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawer(BuildContext context, ThemeProvider themeProvider) => Drawer(
    child: Column(
      children: <Widget>[
        DrawerHeader(
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode
                ? Colors.grey[900]
                : Color.fromRGBO(75, 117, 198, 1),
          ),
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
          child: Container(
            width: double.infinity,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.all(16),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode
                  ? Colors.black
                  : Colors.white,
            ),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ..._menuItems.map((item) => ListTile(
                  title: Text(
                    item,
                    style: TextStyle(
                      color: themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.black,
                      fontSize: 18,
                    ),
                  ),
                  onTap: () {
                    _scaffoldKey.currentState?.openEndDrawer();
                    if (item == 'Sign Out') {
                      _handleSignOut(context);
                    }
                    if (item == 'About us') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AboutUsPage(),
                        ),
                      );
                    }
                  },
                )).toList(),
                Divider(),
                SwitchListTile(
                  title: Text(
                    "Dark Mode",
                    style: TextStyle(
                      color: themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.black,
                      fontSize: 18,
                    ),
                  ),
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme(); // Toggle the theme
                  },
                  secondary: Icon(
                    themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: themeProvider.isDarkMode
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  void _handleSignOut(BuildContext context) async {
    bool? confirmLogout = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Logout'),
        content: Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmLogout == true) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
            (route) => false,
      );
    }
  }

  Widget _navBarItems() => Row(
    mainAxisAlignment: MainAxisAlignment.end,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: _menuItems.map(
          (item) => InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: 24.0, horizontal: 16),
          child: Text(
            item,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    ).toList(),
  );
}

final List<String> _menuItems = <String>[
  'About us',
  'Contact',
  'Settings',
  'Sign Out',
];
