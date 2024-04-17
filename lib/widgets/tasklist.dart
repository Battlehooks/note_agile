import 'package:flutter/material.dart';
import 'package:note_agile/models/task.dart';
import 'package:note_agile/pages/taskDetail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? taskTitles = prefs.getStringList('taskTitles');
    List<String>? taskDescriptions = prefs.getStringList('taskDescriptions');

    if (taskTitles != null && taskDescriptions != null) {
      setState(() {
        for (int i = 0; i < taskTitles.length; i++) {
          tasks.add(
              Task(title: taskTitles[i], description: taskDescriptions[i]));
        }
      });
    }
  }

  void _saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> taskTitles = [];
    List<String> taskDescriptions = [];

    tasks.forEach((task) {
      taskTitles.add(task.title);
      taskDescriptions.add(task.description);
    });

    await prefs.setStringList('taskTitles', taskTitles);
    await prefs.setStringList('taskDescriptions', taskDescriptions);
  }

  void _addTask(String newTitle, String newDescription) {
    if (newTitle.isNotEmpty) {
      setState(() {
        tasks.add(Task(title: newTitle, description: newDescription));
        _saveTasks();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Title cannot be empty'),
      ));
    }
  }

  void _removeTask(int index) {
    setState(() {
      tasks.removeAt(index);
      _saveTasks();
    });
  }

  void _editTask(int index, String newTitle, String newDescription) {
    if (newTitle.isNotEmpty) {
      setState(() {
        tasks[index].title = newTitle;
        tasks[index].description = newDescription;
        _saveTasks();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Title cannot be empty'),
      ));
    }
  }

  String _truncateString(String text, int maxLength) {
    return text.length <= maxLength
        ? text
        : '${text.substring(0, maxLength)}...';
  }

  void _showAddDialog() {
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                _addTask(titleController.text, descriptionController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(int index) {
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    titleController.text = tasks[index].title;
    descriptionController.text = tasks[index].description;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                _editTask(
                    index, titleController.text, descriptionController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToTaskDetail(Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailScreen(task: task),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Note List'),
      ),
      body: tasks.isEmpty
          ? const Center(
              child: Text('No tasks available'),
            )
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _navigateToTaskDetail(tasks[index]),
                  child: ListTile(
                    key: Key(tasks[index].title), // Add key to the widget
                    title: Text(_truncateString(tasks[index].title,
                        15)), // Batasan jumlah kata untuk judul
                    subtitle: Text(_truncateString(tasks[index].description,
                        30)), // Batasan jumlah kata untuk deskripsi
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _showEditDialog(index),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _removeTask(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddDialog();
        },
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }
}