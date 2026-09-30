import 'package:flutter/material.dart';

import '../models/todo.dart';

// Shows ONE todo as a card: checkbox, title, edit and delete buttons.
class TodoItem extends StatelessWidget {
  final Todo todo;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  const TodoItem({
    super.key,
    required this.todo,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        // Checkbox on the left
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: (value) {
            onToggle();
          },
        ),

        // Todo title in the middle (crossed out when completed)
        title: Text(
          todo.title,
          style: TextStyle(
            fontSize: 18,
            decoration: todo.isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),

        // Edit and delete buttons on the right
        trailing: Row(
          // Only take as much width as the buttons need.
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
