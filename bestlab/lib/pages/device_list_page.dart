import 'package:flutter/material.dart';
import 'package:bestlab/components/row.dart'; // Updated import for myRow
import 'package:bestlab/components/my_search_bar.dart';
import 'package:bestlab/pages/login_page.dart'; // Assuming your AuthService is in login_page.dart
import 'package:provider/provider.dart';
import 'package:bestlab/components/themeProvider.dart';

class DeviceList extends StatefulWidget {
  String systemName;
  final List<String> devices;
  final Map<String, dynamic> userData; // Add userData to the constructor

  DeviceList({
    super.key,
    required this.systemName,
    required this.devices,
    required this.userData, // Add this line
  });

  @override
  _DeviceListState createState() => _DeviceListState();
}

class _DeviceListState extends State<DeviceList> {
  late List<String> devices;
  late List<String> filteredDevices;
  late TextEditingController searchController;
  late AuthService authService; // Add AuthService instance
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Scaffold Key

  @override
  void initState() {
    super.initState();
    authService = AuthService(); // Initialize AuthService
    searchController = TextEditingController();

    // Filter devices based on the user's systemAccess
    if (widget.userData['systemRole'].toLowerCase() == 'admin') {
      devices = widget.devices;
    } else {
      devices = widget.devices.where((device) {
        return widget.userData['systemAccess'].contains(widget.systemName);
      }).toList();
    }

    filteredDevices = devices;

    // Listen to changes in the search query
    searchController.addListener(() {
      _filterDevices(searchController.text);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterDevices(String query) {
    setState(() {
      filteredDevices = devices
          .where((device) => device.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _addDevice(String deviceName, String deviceUrl) async {
    try {
      // Check if the device name already exists
      if (devices.contains(deviceName)) {
        _showSnackBar("Device \"$deviceName\" already exists");
        return; // Prevent adding the device
      }

      // Assuming you have a way to handle the device URL in your database
      await authService.addDevice(deviceName, deviceUrl);
      setState(() {
        devices.add(deviceName);
        _filterDevices(searchController.text); // Update filteredDevices based on the search query
      });
    } catch (e) {
      print('Error adding device: $e');
    }
  }

  Future<void> _removeDevice(int index) async {
    final deviceName = filteredDevices[index];

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete the device "$deviceName"?'),
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
        await authService.deleteDevice(deviceName);

        setState(() {
          filteredDevices.removeAt(index);
        });

        _showSnackBar("Device \"$deviceName\" deleted");
      } catch (e) {
        _showSnackBar("Failed to delete device \"$deviceName\"");
      }
    }
  }

  Future<void> _editDevice(int index) async {
    String currentDeviceName = filteredDevices[index];
    TextEditingController deviceNameController = TextEditingController(text: currentDeviceName);
    TextEditingController deviceUrlController = TextEditingController(); // Add URL controller

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Device Name'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: deviceNameController,
                decoration: InputDecoration(hintText: 'Device Name'),
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
              child: Text('Save'),
              onPressed: () async {
                String newDeviceName = deviceNameController.text.trim();
                Navigator.of(context).pop(); // Close the dialog first

                if (newDeviceName.isNotEmpty && newDeviceName != currentDeviceName) {
                  try {
                    // Update the device name and URL in the database
                    await authService.updateDeviceName(currentDeviceName, newDeviceName);

                    // Update the device list in the state
                    setState(() {
                      devices[index] = newDeviceName;
                      _filterDevices(searchController.text); // Update filteredDevices based on the search query
                    });

                    _showSnackBar("Device name changed to \"$newDeviceName\"");
                  } catch (e) {
                    _showSnackBar("Failed to update device name");
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddDeviceDialog() {
  String newDeviceName = '';
  String newDeviceUrl = '';
  String? errorMessage; // To store error messages

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder( // Use StatefulBuilder to manage state within the dialog
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Add New Device'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(hintText: 'Device Name'),
                  onChanged: (value) {
                    newDeviceName = value;
                    setState(() {
                      errorMessage = null; // Reset error message when the user starts typing
                    });
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(hintText: 'Device URL'),
                  onChanged: (value) {
                    newDeviceUrl = value;
                    setState(() {
                      errorMessage = null; // Reset error message when the user starts typing
                    });
                  },
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
                  // Check if both fields are filled
                  if (newDeviceName.isEmpty || newDeviceUrl.isEmpty) {
                    setState(() {
                      errorMessage = 'Please fill in all fields.';
                    });
                    return;
                  }

                  // Check if the device name already exists
                  if (devices.contains(newDeviceName)) {
                    setState(() {
                      errorMessage = 'Device name already exists. Please choose a different name.';
                    });
                    return;
                  }

                  // Close the dialog and add the device
                  Navigator.of(context).pop();
                  await _addDevice(newDeviceName, newDeviceUrl);
                },
              ),
            ],
          );
        },
      );
    },
  );
}


  void _showSnackBar(String message) {
    final scaffoldMessenger = ScaffoldMessenger.of(_scaffoldKey.currentContext!);
    scaffoldMessenger.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showEditSystemNameDialog() {
    String newSystemName = widget.systemName;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit System Name'),
          content: TextField(
            decoration: InputDecoration(hintText: 'System Name'),
            onChanged: (value) {
              newSystemName = value;
            },
            controller: TextEditingController(text: widget.systemName), // Pre-fill with the current name
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog first
                if (newSystemName.isNotEmpty && newSystemName != widget.systemName) {
                  try {
                    // Update the system name in the database
                    await authService.updateSystemName(widget.systemName, newSystemName);

                    // Update the system name in the state
                    setState(() {
                      widget.systemName = newSystemName; // Update systemName within setState
                    });

                    _showSnackBar("System name changed to \"$newSystemName\"");
                  } catch (e) {
                    _showSnackBar("Failed to update system name");
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      key: _scaffoldKey, // Assign the Scaffold key
      backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white, // Background color changes with theme
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Center the content
          children: [
            Flexible(
              child: Text(
                widget.systemName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis, // Handle overflow if the name is too long
              ),
            ),
            if (widget.systemName != "All Devices") // Conditionally show the edit button
              IconButton(
                icon: Icon(Icons.edit, color: Colors.white),
                onPressed: () {
                  _showEditSystemNameDialog();
                },
                padding: EdgeInsets.zero, // Remove padding around the icon
                constraints: BoxConstraints(), // Remove constraints to make the icon tightly wrap its content
              ),
          ],
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
          Visibility(child:
            IconButton(
              icon: Icon(Icons.settings),
              color: themeProvider.isDarkMode ? Colors.grey[900]! : Color.fromRGBO(75, 117, 198, 1),
              onPressed: () {
                // Add your settings logic here
              },
            ),
          )
        ],
        backgroundColor: themeProvider.isDarkMode ? Colors.grey[900]! : Color.fromRGBO(75, 117, 198, 1),
      ),


      body: Column(
        children: [
          const SizedBox(height: 15),
          MySearchBar(
            controller: searchController,
            hintText: 'Search devices...',
            onChanged: _filterDevices,
            backgroundColor: themeProvider.isDarkMode ? Colors.grey[800]! : Colors.white,
            textColor: themeProvider.isDarkMode ? Colors.white : Colors.black,
            hintColor: themeProvider.isDarkMode ? Colors.white54 : Colors.black54,
          ),
          const SizedBox(height: 15),
          Expanded(
            child: ListView.builder(
              itemCount: filteredDevices.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(filteredDevices[index]),
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
                      await authService.deleteDevice(filteredDevices[index]);
                      setState(() {
                        devices.removeAt(index);
                        filteredDevices.removeAt(index);
                      });
                      _showSnackBar("Device ${filteredDevices[index]} deleted");
                      return true;
                    }
                    return false;
                  },
                  onDismissed: (direction) {},
                  child: myRow(
                    icon: Icons.device_hub,
                    text: filteredDevices[index],
                    onTap: () {},
                    onDismissed: () => _removeDevice(index),
                    actions: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _editDevice(index);
                        },
                      ),
                    ],
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
              _showAddDeviceDialog();
            },
            child: Icon(Icons.add, color: themeProvider.isDarkMode ? Colors.white : Colors.black),
          )
        : null,
    );
  }
}
