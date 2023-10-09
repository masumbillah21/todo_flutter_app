import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo/todo.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _options = ['Pending', 'Completed'];
  final List<Todo> _todos = [];
  String _optionValue = '';
  final TextEditingController _todoEditField = TextEditingController();

  void _showBottomModal({required context, index = -1}) {
    if (index != -1) {
      _todoEditField.text = _todos[index].title;
    } else {
      _todoEditField.text = "";
    }
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      isScrollControlled: true,
      context: context,
      builder: (context) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    index == -1 ? "Add New Todo" : "Update Todo",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.close,
                      color: Colors.red,
                    ),
                  )
                ],
              ),
              TextFormField(
                controller: _todoEditField,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: "Write your todo here...",
                  enabledBorder: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Add your todo...";
                  }
                  return null;
                },
              ),
              if (index != -1) ...[
                const SizedBox(
                  height: 10,
                ),
                DropdownMenu<String>(
                  width: MediaQuery.sizeOf(context).width,
                  initialSelection: _todos[index].status,
                  onSelected: (String? value) {
                    setState(() {
                      _optionValue = value!;
                    });
                  },
                  dropdownMenuEntries:
                      _options.map<DropdownMenuEntry<String>>((String value) {
                    return DropdownMenuEntry<String>(
                      value: value,
                      label: value,
                      style: ButtonStyle(
                        textStyle: MaterialStateTextStyle.resolveWith(
                          (states) => const TextStyle(fontSize: 15),
                        ),
                      ),
                    );
                  }).toList(),
                )
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (index == -1) {
                      _addTodo();
                      _todoEditField.text = "";
                      Navigator.pop(context);
                    } else {
                      _updateTodo(index);
                      _todoEditField.text = "";
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    index == -1 ? "Add" : "Update",
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showDialogBox(context, index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Actions"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              onTap: () {
                Navigator.pop(context);
                _showBottomModal(context: context, index: index);
              },
              leading: const Icon(Icons.edit),
              title: const Text("Update"),
            ),
            const Divider(
              height: 0,
            ),
            ListTile(
              onTap: () {
                _deleteTodo(index);
                Navigator.pop(context);
              },
              leading: const Icon(Icons.delete),
              title: const Text("Delete"),
            ),
          ],
        ),
      ),
    );
  }

  void _addTodo() {
    _todos.add(Todo(
      title: _todoEditField.text,
      date: DateTime.now(),
    ));
    setState(() {});
  }

  void _updateTodo(int index) {
    _todos[index].title = _todoEditField.text;
    _todos[index].status =
        _optionValue.isEmpty ? _todos[index].status : _optionValue;
    setState(() {});
    _optionValue = "";
  }

  void _deleteTodo(int index) {
    _todos.removeAt(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Todos"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showBottomModal(context: context);
        },
        child: const Icon(Icons.add),
      ),
      body: (_todos.isEmpty)
          ? Center(
              child: Text(
                "Add your todos",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            )
          : ListView.builder(
              itemBuilder: (context, index) => Card(
                child: ListTile(
                  onLongPress: () {
                    _showDialogBox(context, index);
                  },
                  leading: CircleAvatar(
                    child: Text("${index + 1}"),
                  ),
                  title: Text(_todos[index].title),
                  subtitle: Text(
                    DateFormat("dd-MM-yyyy h:m:s a").format(_todos[index].date),
                  ),
                  trailing: Text(
                    _todos[index].status,
                    style: TextStyle(
                      color: _todos[index].status == _options[0]
                          ? Colors.red
                          : Colors.green,
                    ),
                  ),
                ),
              ),
              // separatorBuilder: (context, index) => const Divider(
              //   height: 4,
              // ),
              itemCount: _todos.length,
            ),
    );
  }
}
