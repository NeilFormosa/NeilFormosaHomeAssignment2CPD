import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/department.dart';
import '../models/event.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({Key? key}) : super(key: key);

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final Box<Event> eventBox = Hive.box<Event>('events');
  final Box<Department> departmentBox = Hive.box<Department>('departments');

  Department? selectedDepartment;
  DateTime? selectedDate;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  void addEvent() {
    final title = titleController.text.trim();

    if (title.isEmpty || selectedDepartment == null || selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Title, department and date are required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    eventBox.add(
      Event(
        name: title,
        description: descController.text.trim().isEmpty
            ? null
            : descController.text.trim(),
        date: selectedDate!,
        departmentName: selectedDepartment!.name,
      ),
    );

    titleController.clear();
    descController.clear();
    selectedDepartment = null;
    selectedDate = null;

    setState(() {});
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Events'), centerTitle: true),
      body: Column(
        children: [
          const SizedBox(height: 12),
          const Text(
            'Events',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          /// EVENT LIST
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: eventBox.listenable(),
              builder: (context, Box<Event> box, _) {
                if (box.isEmpty) {
                  return const Center(child: Text('No events added'));
                }

                return ListView.builder(
                  itemCount: box.length,
                  itemBuilder: (context, index) {
                    final event = box.getAt(index)!;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: ListTile(
                        title: Text(
                          event.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${event.description ?? "(No description)"}\n'
                          'Department: ${event.departmentName}\n'
                          'Date: ${event.date.toLocal().toString().split(' ')[0]}',
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => eventBox.deleteAt(index),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          /// ADD EVENT FORM
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Event title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<Department>(
                  value: selectedDepartment,
                  hint: const Text('Select department'),
                  items: departmentBox.values.map((dept) {
                    return DropdownMenuItem(
                      value: dept,
                      child: Text(dept.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedDepartment = value);
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedDate == null
                            ? 'No date selected'
                            : selectedDate!.toLocal().toString().split(' ')[0],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: pickDate,
                      child: const Text('Pick date'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: addEvent,
                  child: const Text('Add Event'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
