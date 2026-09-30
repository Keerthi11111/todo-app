import 'package:flutter/material.dart';

import '../models/todo.dart';
import '../services/todo_service.dart';
import '../widgets/todo_input.dart';
import '../widgets/todo_item.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() {
    return _TodoScreenState();
  }
}

class _TodoScreenState extends State<TodoScreen> {

  // =========================
  // CONTROLLER
  // =========================

  final TextEditingController todoController =
      TextEditingController();

  // =========================
  // SERVICE
  // =========================

  final TodoService todoService = TodoService();

  // =========================
  // TODO LIST
  // =========================

  List<Todo> todos = [];

  // =========================
  // INITIAL LOAD
  // =========================

  @override
  void initState() {
    super.initState();

    loadTodos();
  }

  // Get Todos from service
  void loadTodos() {
    setState(() {
      todos = todoService.getTodos();
    });
  }

  // =========================
  // CREATE
  // =========================

  void addTodo() {

    String title = todoController.text.trim();

    // Don't add empty Todo
    if (title.isEmpty) {
      return;
    }

    todoService.addTodo(title);

    // Refresh list
    loadTodos();

    // Clear input
    todoController.clear();
  }

  // =========================
  // UPDATE
  // =========================

  void editTodo(Todo todo) {

    // Put existing title into input
    todoController.text = todo.title;

    showDialog(
      context: context,

      builder: (context) {

        return AlertDialog(

          title: const Text('Edit Todo'),

          content: TextField(
            controller: todoController,

            decoration: const InputDecoration(
              labelText: 'Todo',
              border: OutlineInputBorder(),
            ),
          ),

          actions: [

            // Cancel
            TextButton(
              onPressed: () {

                todoController.clear();

                Navigator.pop(context);
              },

              child: const Text('Cancel'),
            ),

            // Update
            ElevatedButton(
              onPressed: () {

                String updatedTitle =
                    todoController.text.trim();

                if (updatedTitle.isEmpty) {
                  return;
                }

                todoService.updateTodo(
                  todo.id,
                  updatedTitle,
                );

                loadTodos();

                todoController.clear();

                Navigator.pop(context);
              },

              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  // =========================
  // DELETE
  // =========================

  void deleteTodo(Todo todo) {

    todoService.deleteTodo(todo.id);

    loadTodos();
  }

  // =========================
  // TOGGLE
  // =========================

  void toggleTodo(Todo todo) {

    todoService.toggleTodo(todo.id);

    loadTodos();
  }

  // =========================
  // DISPOSE
  // =========================

  @override
  void dispose() {

    todoController.dispose();

    super.dispose();
  }

  // =========================
  // UI
  // =========================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      // =========================
      // APP BAR
      // =========================

      appBar: AppBar(
        title: const Text('Todo App'),
        centerTitle: true,
      ),

      // =========================
      // BODY
      // =========================

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            // =========================
            // INPUT
            // =========================

            TodoInput(
              controller: todoController,
              onAdd: addTodo,
            ),

            const SizedBox(height: 20),

            // =========================
            // TODO LIST
            // =========================

            Expanded(
              child: todos.isEmpty

                  // No Todos
                  ? const Center(
                      child: Text(
                        'No Todos yet',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    )

                  // Display Todos
                  : ListView.builder(

                      itemCount: todos.length,

                      itemBuilder: (context, index) {

                        final Todo todo = todos[index];

                        return TodoItem(
                          todo: todo,

                          // Edit
                          onEdit: () {
                            editTodo(todo);
                          },

                          // Delete
                          onDelete: () {
                            deleteTodo(todo);
                          },

                          // Complete
                          onToggle: () {
                            toggleTodo(todo);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}