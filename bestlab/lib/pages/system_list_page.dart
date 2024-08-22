import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo; // Alias the mongo_dart package
import 'package:bestlab/pages/device_list_page.dart';
import 'package:bestlab/components/row.dart';
import 'package:bestlab/components/my_search_bar.dart';
import 'package:provider/provider.dart';
import 'package:bestlab/components/themeProvider.dart';
import 'package:bestlab/pages/login_page.dart'; // Assuming you have an AuthService class that contains getSystemDevices

class SystemList extends StatefulWidget {
  final List<String> systems;
  final Map<String, dynamic> userData;

  SystemList({required this.systems, required this.userData});

  @override
  _SystemListState createState() => _SystemListState();
}

class _SystemListState extends State<SystemList> {
  late List<String> systems = []; // Initialize systems with an empty list
  late List<String> filteredSystems = []; // Initialize filteredSystems with an empty list
  late TextEditingController searchController;
  late mongo.Db db;  // Use the alias 'mongo' for Db class
  late AuthService authService; // Instantiate AuthService
  Map<String, dynamic>? currentUser;

  @override
  void initState() {
    super.initState();
    authService = AuthService(); // Initialize AuthService
    searchController = TextEditingController();

    // Initialize the MongoDB connection
    db = mongo.Db('mongodb://nguyenducdai:0Obkv5QtElG92eNp@ac-vwtniuz-shard-00-00.foxbvln.mongodb.net:27017,ac-vwtniuz-shard-00-01.foxbvln.mongodb.net:27017,ac-vwtniuz-shard-00-02.foxbvln.mongodb.net:27017/Authentication?replicaSet=atlas-4210ho-shard-0&ssl=true&authSource=admin');
    db.open().then((_) {
      print('Connected to MongoDB');
    }).catchError((e) {
      print('Error connecting to MongoDB: $e');
    });

    // Fetch the current logged-in user and filter systems
    _fetchAndFilterSystems();

    // Listen to changes in the search query
    searchController.addListener(() {
      _filterSystems(searchController.text);
    });
  }

  Future<void> _fetchAndFilterSystems() async {
    currentUser = await authService.fetchCurrentLoggedInUser(context);

    if (currentUser != null) {
      bool isAdmin = currentUser!['systemRole'].toLowerCase() == 'admin';

      // Filter systems based on the user's systemAccess or show all if Admin
      if (isAdmin) {
        systems = widget.systems;
      } else {
        systems = widget.systems.where((system) {
          return currentUser!['systemAccess'].contains(system);
        }).toList();
      }

      setState(() {
        filteredSystems = List.from(systems);
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    db.close();
    super.dispose();
  }

  Future<void> _removeSystem(int index) async {
    final systemName = filteredSystems[index];

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete the system "$systemName"?'),
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
        await authService.deleteSystem(systemName);

        setState(() {
          filteredSystems.removeAt(index);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("System \"$systemName\" deleted")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete system \"$systemName\"")),
        );
      }
    }
  }

  void _filterSystems(String query) {
    setState(() {
      filteredSystems = systems
          .where((system) => system.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<bool> _addSystem(String systemName, List<String> devices) async {
    try {
      var collection = db.collection('systems');
      var existingSystem = await collection.findOne({'name': systemName});
      if (existingSystem == null) {
        await collection.insertOne({
          'name': systemName,
          'devicesCount': devices.length,
          'devices': devices,
        });
        
        // Update the UI immediately after adding the system
        setState(() {
          systems.add(systemName);
          filteredSystems.add(systemName);
        });

        print('System $systemName added to the collection.');
        return true; // Indicate that the system was successfully added
      } else {
        print('System $systemName already exists.');
        return false; // Indicate that the system already exists
      }
    } catch (e) {
      print('Error adding system to MongoDB: $e');
      return false; // Indicate that an error occurred
    }
  }

  void _showAddSystemDialog() async {
    String newSystemName = '';
    List<String> selectedDevices = [];
    List<String> availableDevices = await authService.getAllDevices();
    List<String> filteredDevices = List.from(availableDevices);
    TextEditingController searchController = TextEditingController();
    String? errorMessage; // To store error messages

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder( // Use StatefulBuilder to manage state within the dialog
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add New System'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(hintText: 'System Name'),
                    onChanged: (value) {
                      newSystemName = value;
                      setState(() {
                        errorMessage = null; // Reset error message when the user starts typing
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search Devices...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        filteredDevices = availableDevices
                            .where((device) => device
                            .toLowerCase()
                            .contains(value.toLowerCase()))
                            .toList();
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  Text('Select Devices:'),
                  Container(
                    width: double.maxFinite,
                    height: 200,
                    child: ListView(
                      children: filteredDevices.map((device) {
                        return CheckboxListTile(
                          title: Text(device),
                          value: selectedDevices.contains(device),
                          onChanged: (bool? value) async {
                            if (value == true) {
                              bool isDeviceAvailable =
                              await authService.isDeviceAvailable(device);
                              if (isDeviceAvailable) {
                                setState(() {
                                  selectedDevices.add(device);
                                });
                              } else {
                                setState(() {
                                  errorMessage =
                                  'Device $device is already associated with another system.';
                                });
                              }
                            } else {
                              setState(() {
                                selectedDevices.remove(device);
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  if (errorMessage != null) // Display error message if there is one
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        errorMessage!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Add'),
                  onPressed: () async {
                    // Check if the system name is filled
                    if (newSystemName.isEmpty) {
                      setState(() {
                        errorMessage = 'System name cannot be empty.';
                      });
                      return;
                    }

                    // Check if at least one device is selected
                    if (selectedDevices.isEmpty) {
                      setState(() {
                        errorMessage = 'You must select at least one device.';
                      });
                      return;
                    }

                    // Check if the system name already exists
                    bool success = await _addSystem(newSystemName, selectedDevices);
                    if (!success) {
                      setState(() {
                        errorMessage = 'System name already exists. Please choose another name.';
                      });
                      return;
                    }

                    // Close the dialog (UI update is already handled in _addSystem)
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }


  Future<void> _navigateToDeviceList(String systemName) async {
    List<String> devices = await authService.getSystemDevices(systemName);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeviceList(
          systemName: systemName,
          devices: devices,
          userData: currentUser!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white, // Background color changes with theme
      appBar: AppBar(
        title: Text(
          'Systems',
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
      body: Column(
        children: [
          const SizedBox(height: 15),
          MySearchBar(
            controller: searchController,
            hintText: 'Search systems...',
            onChanged: _filterSystems,
            backgroundColor: themeProvider.isDarkMode ? Colors.grey[800]! : Colors.white,
            textColor: themeProvider.isDarkMode ? Colors.white : Colors.black,
            hintColor: themeProvider.isDarkMode ? Colors.white54 : Colors.black54,
          ),
          const SizedBox(height: 15),
          Expanded(
            child: ListView.builder(
              itemCount: filteredSystems.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0), // Add bottom padding
                  child: Dismissible(
                    key: Key(filteredSystems[index]),
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
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.endToStart) {
                        await authService.deleteSystem(filteredSystems[index]);
                        setState(() {
                          systems.removeAt(index);
                          filteredSystems.removeAt(index);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("System ${filteredSystems[index]} deleted")),
                        );
                        return true;
                      }
                      return false;
                    },
                    onDismissed: (direction) {},
                    child: myRow(
                      icon: Icons.build_circle_outlined,
                      text: filteredSystems[index],
                      onTap: () => _navigateToDeviceList(filteredSystems[index]),
                      onDismissed: () => _removeSystem(index),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: widget.userData['systemRole'].toLowerCase() == 'admin'
        ? FloatingActionButton(
            foregroundColor: Color.fromRGBO(75, 117, 198, 1),
            backgroundColor: themeProvider.isDarkMode ? Colors.grey[700]! : Colors.white,
            shape: CircleBorder(
              eccentricity: 0,
              side: BorderSide(color: Color.fromRGBO(75, 117, 198, 1), width: 2.0),
            ),
            onPressed: () {
              _showAddSystemDialog();
            },
            child: Icon(Icons.add, color: themeProvider.isDarkMode ? Colors.white : Colors.black),
          )
        : null,
    );
  }
}