import 'package:flutter/material.dart';
import 'package:bestlab/components/row.dart';


class DeviceList extends StatefulWidget {
  final String systemName;
  final List<String> devices;

  DeviceList({super.key, required this.systemName, required this.devices});

  @override
  _SystemListState createState() => _SystemListState();
}

class _SystemListState extends State<DeviceList> {
  late List<String> devices;

  @override
  void initState() {
    super.initState();
    devices = widget.devices;
  }

  void _removeItem(int index) {
    setState(() {
      devices.removeAt(index);
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
      body: ListView.builder(
        itemCount: devices.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key(devices[index]),
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
                SnackBar(content: Text("${devices[index]} dismissed")),
              );
            },
            child: row(
              icon: Icons.person,
              text: devices[index],
              onTap: () {},
              onDismissed: () => _removeItem(index),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        foregroundColor: Color.fromRGBO(75, 117, 198, 1),
        backgroundColor: Colors.white,
        shape: CircleBorder(
            eccentricity: 0,
            side:
                BorderSide(color: Color.fromRGBO(75, 117, 198, 1), width: 2.0)),
        onPressed: () {
          // Add your add device logic here
        },
        child: Icon(Icons.add),
      ),
    );
  }
}


