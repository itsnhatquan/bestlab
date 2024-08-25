import 'package:bestlab/Quan/webview_screen.dart';
import 'package:flutter/material.dart';
import 'package:bestlab/components/row.dart'; // Updated import for myRow
import 'package:bestlab/components/my_search_bar.dart';
import 'package:bestlab/pages/login_page.dart'; // Assuming your AuthService is in login_page.dart
import 'package:provider/provider.dart';
import 'package:bestlab/components/themeProvider.dart';
import 'dart:async';

class DeviceList extends StatefulWidget {
  String systemName;
  final List<String> devices;
  final Map<String, dynamic> userData;

  DeviceList({
    super.key,
    required this.systemName,
    required this.devices,
    required this.userData,
  });

  @override
  _DeviceListState createState() => _DeviceListState();
}

class _DeviceListState extends State<DeviceList> {
  late List<String> devices;
  late List<String> filteredDevices = [];
  late TextEditingController searchController;
  late AuthService authService;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = true; // Add isLoading variable

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    authService = AuthService();
    searchController = TextEditingController();
    _initializeDeviceList();
  }

  Future<void> _initializeDeviceList() async {
    if (widget.userData['systemRole']?.toLowerCase() == 'admin') {
      setState(() {
        devices = widget.devices;
        filteredDevices = devices;
        isLoading = false; // Set isLoading to false once data is fetched
      });
    } else if (widget.userData['systemRole']?.toLowerCase() == 'user') {
      List<String> userDevices = [];

      for (var systemName in widget.userData['systemAccess']) {
        List<String> systemDevices = await authService.getSystemDevices(systemName);
        userDevices.addAll(systemDevices);
      }

      userDevices = userDevices.toSet().toList();

      setState(() {
        devices = userDevices;
        filteredDevices = devices;
        isLoading = false; // Set isLoading to false once data is fetched
      });
    } else {
      setState(() {
        devices = [];
        filteredDevices = devices;
        isLoading = false; // Set isLoading to false once data is fetched
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _filterDevices(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        filteredDevices = devices
            .where((device) => device.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    });
  }

  Future<void> _addDevice(String deviceName, String deviceUrl, String deviceID) async {
    try {
      if (devices.contains(deviceName)) {
        _showSnackBar("Device \"$deviceName\" already exists");
        return;
      }

      var existingDevice = await authService.getDeviceByID(deviceID);
      if (existingDevice != null) {
        _showSnackBar("Device ID \"$deviceID\" already exists");
        return;
      }

      await authService.addDevice(deviceName, deviceUrl, deviceID);
      setState(() {
        devices.add(deviceName);
        _filterDevices(searchController.text);
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
    var currentDevice = await authService.getDeviceByName(currentDeviceName);
    TextEditingController deviceNameController = TextEditingController(text: currentDeviceName);
    TextEditingController deviceUrlController = TextEditingController(text: currentDevice!['url']);
    TextEditingController deviceIDController = TextEditingController(text: currentDevice['deviceID']);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Device'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: deviceNameController,
                decoration: InputDecoration(hintText: 'Device Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: deviceUrlController,
                decoration: InputDecoration(hintText: 'Device URL'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: deviceIDController,
                decoration: InputDecoration(hintText: 'Device ID'),
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
                String newDeviceUrl = deviceUrlController.text.trim();
                String newDeviceID = deviceIDController.text.trim();

                if (newDeviceID != currentDevice['deviceID']) {
                  var existingDevice = await authService.getDeviceByID(newDeviceID);
                  if (existingDevice != null) {
                    _showSnackBar("Device ID \"$newDeviceID\" already exists");
                    return;
                  }
                }

                Navigator.of(context).pop();

                try {
                  await authService.updateDevice(currentDeviceName, newDeviceName, newDeviceUrl, newDeviceID);

                  setState(() {
                    devices[index] = newDeviceName;
                    _filterDevices(searchController.text);
                  });

                  _showSnackBar("Device updated successfully");
                } catch (e) {
                  _showSnackBar("Failed to update device");
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
    String newDeviceID = '';
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
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
                        errorMessage = null;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(hintText: 'Device URL'),
                    onChanged: (value) {
                      newDeviceUrl = value;
                      setState(() {
                        errorMessage = null;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(hintText: 'Device ID'),
                    onChanged: (value) {
                      newDeviceID = value;
                      setState(() {
                        errorMessage = null;
                      });
                    },
                  ),
                  if (errorMessage != null)
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
                    if (newDeviceName.isEmpty || newDeviceUrl.isEmpty || newDeviceID.isEmpty) {
                      setState(() {
                        errorMessage = 'Please fill in all fields.';
                      });
                      return;
                    }

                    if (devices.contains(newDeviceName)) {
                      setState(() {
                        errorMessage = 'Device name already exists. Please choose a different name.';
                      });
                      return;
                    }

                    Navigator.of(context).pop();
                    await _addDevice(newDeviceName, newDeviceUrl, newDeviceID);
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

  Future<bool> _showEditSystemDialog(String currentSystemName, List<String> currentSelectedDevices) async {
    String newSystemName = currentSystemName;
    List<String> selectedDevices = List.from(currentSelectedDevices);
    List<String> availableDevices = await authService.getAllDevices();
    List<String> filteredDevices = List.from(availableDevices);
    TextEditingController searchController = TextEditingController();
    String? errorMessage;

    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit System'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(hintText: 'System Name'),
                    onChanged: (value) {
                      newSystemName = value;
                      setState(() {
                        errorMessage = null;
                      });
                    },
                    controller: TextEditingController(text: newSystemName),
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
                            .where((device) => device.toLowerCase().contains(value.toLowerCase()))
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
                              // Allow selecting a device if it is already associated with the current system
                              if (currentSelectedDevices.contains(device)) {
                                setState(() {
                                  selectedDevices.add(device);
                                  errorMessage = null;
                                });
                              } else {
                                bool isAvailable = await authService.isDeviceAvailable(device);
                                if (!isAvailable) {
                                  setState(() {
                                    errorMessage = 'Device "$device" is already assigned to another system.';
                                  });
                                } else {
                                  setState(() {
                                    selectedDevices.add(device);
                                    errorMessage = null;
                                  });
                                }
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
                  if (errorMessage != null)
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
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: Text('Save'),
                  onPressed: () async {
                    if (newSystemName.isEmpty) {
                      setState(() {
                        errorMessage = 'System name cannot be empty.';
                      });
                      return;
                    }

                    if (selectedDevices.isEmpty) {
                      setState(() {
                        errorMessage = 'You must select at least one device.';
                      });
                      return;
                    }

                    // Ensure all selected devices (excluding those already in the system) are available
                    for (var device in selectedDevices) {
                      if (!currentSelectedDevices.contains(device)) {
                        bool isAvailable = await authService.isDeviceAvailable(device);
                        if (!isAvailable) {
                          setState(() {
                            errorMessage = 'Device "$device" is already assigned to another system.';
                          });
                          return;
                        }
                      }
                    }

                    try {
                      bool success = await authService.updateSystem(
                        currentSystemName,
                        newSystemName,
                        selectedDevices,
                      );

                      if (success) {
                        List<String> updatedDevices = await authService.getSystemDevices(newSystemName);

                        setState(() {
                          widget.systemName = newSystemName;
                          devices = updatedDevices;
                          filteredDevices = devices;
                        });

                        // Safely close the dialog
                        if (mounted) {
                          Navigator.of(context).pop(true);
                        }
                      } else {
                        setState(() {
                          errorMessage = 'Failed to update the system. Please try again.';
                        });
                      }
                    } catch (e) {
                      setState(() {
                        errorMessage = 'An error occurred while updating the system.';
                      });
                      print('Error: $e');
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                widget.systemName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (widget.userData['systemRole']?.toLowerCase() == 'admin')
              if (widget.systemName != "All Devices")
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.white),
                  onPressed: () async {
                    bool updated = await _showEditSystemDialog(widget.systemName, devices);
                    if (updated) {
                      setState(() {});
                    }
                  },
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
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
          Visibility(
            child: IconButton(
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
      body: isLoading // Display loading spinner while data is being fetched
          ? Center(child: CircularProgressIndicator())
          : Column(
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
                        background: widget.userData['systemRole']?.toLowerCase() == 'admin'
                            ? Container(color: Colors.green)
                            : null,
                        secondaryBackground: widget.userData['systemRole']?.toLowerCase() == 'admin'
                            ? Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.symmetric(horizontal: 20.0),
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                        confirmDismiss: (direction) async {
                          if (widget.userData['systemRole']?.toLowerCase() == 'admin') {
                            if (direction == DismissDirection.endToStart) {
                              await _removeDevice(index);
                              return true;
                            }
                            return false;
                          } else {
                            _showSnackBar("Only admins can delete devices.");
                            return false;
                          }
                        },
                        child: myRow(
                          icon: Icons.device_hub,
                          text: filteredDevices[index],
                          userRole: widget.userData['systemRole'],
                         onTap: () async {
  var deviceName = filteredDevices[index];
  var device = await authService.getDeviceByName(deviceName);
  if (device != null) {
   Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WebViewScreen(url: device['url']),
                      ),
                    );
  } else {
    print('Device not found');
  }
},
                          onDismissed: () => _removeDevice(index),
                          actions: [
                            if (widget.userData['systemRole']?.toLowerCase() == 'admin')
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
      floatingActionButton: (widget.userData['systemRole']?.toLowerCase() == 'admin' && widget.systemName == "All Devices")
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
