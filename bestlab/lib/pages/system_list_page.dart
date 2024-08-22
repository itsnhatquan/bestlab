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
  late List<String> systems;
  late List<String> filteredSystems;
  late TextEditingController searchController;
  late mongo.Db db;  // Use the alias 'mongo' for Db class
  late AuthService authService; // Instantiate AuthService

  @override
  void initState() {
    super.initState();
    systems = widget.systems;
    filteredSystems = List.from(systems); // Initialize filteredSystems from systems
    searchController = TextEditingController();
    authService = AuthService(); // Initialize AuthService

    // Initialize the MongoDB connection
    db = mongo.Db('mongodb://nguyenducdai:0Obkv5QtElG92eNp@ac-vwtniuz-shard-00-00.foxbvln.mongodb.net:27017,ac-vwtniuz-shard-00-01.foxbvln.mongodb.net:27017,ac-vwtniuz-shard-00-02.foxbvln.mongodb.net:27017/Authentication?replicaSet=atlas-4210ho-shard-0&ssl=true&authSource=admin');
    db.open().then((_) {
      print('Connected to MongoDB');
    }).catchError((e) {
      print('Error connecting to MongoDB: $e');
    });

    // Listen to changes in the search query
    searchController.addListener(() {
      _filterSystems(searchController.text);
    });
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
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New System'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(hintText: 'System Name'),
                    onChanged: (value) {
                      newSystemName = value;
                      setState(() {
                        errorMessage = null; // Reset error message on name change
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
                                // Hide error message after 3 seconds
                                Future.delayed(Duration(seconds: 3), () {
                                  setState(() {
                                    errorMessage = null;
                                  });
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
                  if (errorMessage != null) ...[
                    SizedBox(height: 10),
                    Text(
                      errorMessage!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ],
              );
            },
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
                // Validate the system name and selected devices
                if (newSystemName.isEmpty) {
                  setState(() {
                    errorMessage = 'System name cannot be empty.';
                  });
                  // Hide error message after 3 seconds
                  Future.delayed(Duration(seconds: 3), () {
                    setState(() {
                      errorMessage = null;
                    });
                  });
                  return;
                }
                if (selectedDevices.isEmpty) {
                  setState(() {
                    errorMessage = 'You must select at least one device.';
                  });
                  // Hide error message after 3 seconds
                  Future.delayed(Duration(seconds: 3), () {
                    setState(() {
                      errorMessage = null;
                    });
                  });
                  return;
                }

                // Check if the system name is unique
                bool success = await _addSystem(newSystemName, selectedDevices);
                if (!success) {
                  setState(() {
                    errorMessage = 'System name already exists. Please choose another name.';
                  });
                  // Hide error message after 3 seconds
                  Future.delayed(Duration(seconds: 3), () {
                    setState(() {
                      errorMessage = null;
                    });
                  });
                  return;
                }

                // If successful, close the dialog and update the UI
                setState(() {
                  systems.add(newSystemName);
                  filteredSystems.add(newSystemName);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
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
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Add your settings logic here
            },
          ),
        ],
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
      floatingActionButton: FloatingActionButton(
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
      ),
    );
  }
}
