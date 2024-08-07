import 'package:flutter/material.dart';
import 'package:bestlab/components/row.dart';

class SystemList extends StatefulWidget {
  final List<String> systems;

  SystemList({required this.systems});

  @override
  _SystemListState createState() => _SystemListState();
}

class _SystemListState extends State<SystemList> {
  late List<String> systems;

  @override
  void initState() {
    super.initState();
    systems = widget.systems;
  }

  void _removeItem(int index) {
    setState(() {
      systems.removeAt(index);
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
      body: ListView.builder(
        itemCount: systems.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10.0), // Add bottom padding
            child: Dismissible(
              key: Key(systems[index]),
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
                  SnackBar(content: Text("${systems[index]} dismissed")),
                );
              },
              child: row(
                icon: Icons.build_circle_outlined,
                text: systems[index],
                onTap: () {},
                onDismissed: () => _removeItem(index),
              ),
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
