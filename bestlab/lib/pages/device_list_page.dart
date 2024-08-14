import 'package:flutter/material.dart';
import 'package:bestlab/components/row.dart'; // Updated import for myRow
import 'package:bestlab/components/my_search_bar.dart';
import 'package:bestlab/pages/login_page.dart'; // Assuming your AuthService is in login_page.dart
import 'package:provider/provider.dart';
import 'package:bestlab/components/themeProvider.dart';

class DeviceList extends StatefulWidget {
  final String systemName;
  final List<String> devices;

  DeviceList({super.key, required this.systemName, required this.devices});

  @override
  _DeviceListState createState() => _DeviceListState();
}

class _DeviceListState extends State<DeviceList> {
  late List<String> devices;
  late List<String> filteredDevices;
  late TextEditingController searchController;
  late AuthService authService; // Add AuthService instance

  @override
  void initState() {
    super.initState();
    devices = widget.devices;
    filteredDevices = devices;
    searchController = TextEditingController();
    authService = AuthService(); // Initialize AuthService

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

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Device \"$deviceName\" deleted")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete device \"$deviceName\"")),
        );
      }
    }
  }

  void _filterDevices(String query) {
    setState(() {
      filteredDevices = devices
          .where((device) => device.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _addDevice(String deviceName) async {
    try {
      // Check if the device name already exists
      if (devices.contains(deviceName)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Device \"$deviceName\" already exists")),
        );
        return; // Prevent adding the device
      }

      await authService.addDevice(deviceName);
      setState(() {
        devices.add(deviceName);
        _filterDevices(searchController.text); // Update filteredDevices based on the search query
      });
    } catch (e) {
      print('Error adding device: $e');
    }
  }

  void _showAddDeviceDialog() {
    String newDeviceName = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Device'),
          content: TextField(
            decoration: InputDecoration(hintText: 'Device Name'),
            onChanged: (value) {
              newDeviceName = value;
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
                if (newDeviceName.isNotEmpty) {
                  await _addDevice(newDeviceName);
                }
                Navigator.of(context).pop();
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
      backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white, // Background color changes with theme
      appBar: AppBar(
        title: Text(
          widget.systemName,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.0,
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Device ${filteredDevices[index]} deleted")),
                      );
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
          _showAddDeviceDialog();
        },
        child: Icon(Icons.add, color: themeProvider.isDarkMode ? Colors.white : Colors.black),
      ),
    );
  }
}
