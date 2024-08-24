import 'package:bestlab/pages/common/device_list_page.dart';
import 'package:flutter/material.dart';
import 'package:bestlab/components/row.dart';
import 'package:bestlab/components/my_search_bar.dart'; // Import the search bar component

class SystemList extends StatefulWidget {
  final List<String> systems;
  final Map<String, dynamic> userData; // Add this line to store user data

  SystemList({required this.systems, required this.userData}); // Update constructor

  @override
  _SystemListState createState() => _SystemListState();
}

class _SystemListState extends State<SystemList> {
  late List<String> systems;
  late List<String> filteredSystems;
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    systems = widget.systems;
    filteredSystems = systems;
    searchController = TextEditingController();

    // Listen to changes in the search query
    searchController.addListener(() {
      _filterSystems(searchController.text);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _removeItem(int index) {
    setState(() {
      filteredSystems.removeAt(index);
    });
  }

  void _filterSystems(String query) {
    setState(() {
      filteredSystems = systems
          .where((system) => system.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Systems',
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
            hintText: 'Search systems...',
            onChanged: _filterSystems,
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
                    confirmDismiss: (direction) {
                      return Future.value(direction == DismissDirection.endToStart);
                    },
                    onDismissed: (direction) {
                      _removeItem(index);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("${filteredSystems[index]} dismissed")),
                      );
                    },
                    child: row(
                      icon: Icons.build_circle_outlined,
                      text: filteredSystems[index],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DeviceList(
                              systemName: filteredSystems[index],
                              devices: ['Device 1', 'Device 2'], // Example device list
                            ),
                          ),
                        );
                      },
                      onDismissed: () => _removeItem(index),
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
