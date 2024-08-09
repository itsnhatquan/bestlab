import 'package:flutter/material.dart';
import 'package:bestlab/components/row.dart';
import 'package:bestlab/components/my_search_bar.dart'; // Import the search bar component

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

  @override
  void initState() {
    super.initState();
    devices = widget.devices;
    filteredDevices = devices;
    searchController = TextEditingController();

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

  void _removeItem(int index) {
    setState(() {
      filteredDevices.removeAt(index);
    });
  }

  void _filterDevices(String query) {
    setState(() {
      filteredDevices = devices
          .where((device) => device.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.systemName,
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
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
      ),
      body: Column(
        children: [
          const SizedBox(height: 15),
          MySearchBar(
            controller: searchController,
            hintText: 'Search devices...',
            onChanged: _filterDevices,
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
                  confirmDismiss: (direction) {
                    return Future.value(direction == DismissDirection.endToStart);
                  },
                  onDismissed: (direction) {
                    _removeItem(index);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("${filteredDevices[index]} dismissed")),
                    );
                  },
                  child: row(
                    icon: Icons.device_hub,
                    text: filteredDevices[index],
                    onTap: () {},
                    onDismissed: () => _removeItem(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        foregroundColor: Color.fromRGBO(75, 117, 198, 1),
        backgroundColor: Colors.white,
        shape: CircleBorder(
          eccentricity: 0,
          side: BorderSide(color: Color.fromRGBO(75, 117, 198, 1), width: 2.0),
        ),
        onPressed: () {
          // Add your add device logic here
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
