import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'models/department.dart';
import 'models/event.dart';
import 'pages/events_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(DepartmentAdapter());
  Hive.registerAdapter(EventAdapter());

  await Hive.openBox<Department>('departments');
  await Hive.openBox<Event>('events');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MCAST Events Manager',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        brightness: Brightness.light,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.yellow[700],
          foregroundColor: Colors.black,
        ),
      ),
      home: DepartmentsPage(),
    );
  }
}

class DepartmentsPage extends StatefulWidget {
  @override
  _DepartmentsPageState createState() => _DepartmentsPageState();
}

class _DepartmentsPageState extends State<DepartmentsPage> {
  final Box<Department> departmentBox = Hive.box<Department>('departments');
  final Box<Event> eventBox = Hive.box<Event>('events');

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  // GPS permission handling
  Future<Position?> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  void addDepartment() async {
    final name = nameController.text.trim();
    final desc = descController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Department name cannot be empty!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final position = await getCurrentPosition();
    if (position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location permission denied'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final department = Department(
      name: name,
      description: desc,
      latitude: position.latitude,
      longitude: position.longitude,
    );

    departmentBox.add(department);

    nameController.clear();
    descController.clear();
    setState(() {});
  }

  void deleteDepartment(int index) {
    departmentBox.deleteAt(index);
    setState(() {});
  }

  void showEventsCount() {
    final count = eventBox.length;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('There are $count events in the system'),
        backgroundColor: Colors.yellow[800],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MCAST Event Manager System'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Text(
                  'Departments',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow[800],
                  ),
                ),
                const SizedBox(height: 8),

                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => EventsPage()),
                    );
                  },
                  child: Text('Manage Events'),
                ),

                const SizedBox(height: 8),

                ElevatedButton.icon(
                  icon: Icon(Icons.notifications),
                  label: Text('Show Events Count'),
                  onPressed: showEventsCount,
                ),
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: departmentBox.listenable(),
              builder: (context, Box<Department> box, _) {
                if (box.isEmpty) {
                  return Center(child: Text('No departments added.'));
                }

                return ListView.builder(
                  itemCount: box.length,
                  itemBuilder: (context, index) {
                    final dept = box.getAt(index)!;
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      elevation: 3,
                      child: ListTile(
                        title: Text(
                          dept.name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${dept.description.isEmpty ? "(No description)" : dept.description}\n'
                          'Lat: ${dept.latitude}, Lng: ${dept.longitude}',
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteDepartment(index),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Department Name',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: descController,
                decoration: InputDecoration(
                  hintText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.add, color: Colors.yellow[800], size: 32),
              onPressed: addDepartment,
            ),
          ],
        ),
      ),
    );
  }
}
