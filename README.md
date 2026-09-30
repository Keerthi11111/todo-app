# Todo App (Flutter) — Beginner's Guide

A simple Todo app built with Flutter. You can **add**, **edit**, **delete**, and **complete** todos.
The todos are kept in memory only, so they disappear when you close the app.

This README explains every file in `lib/` and the Dart/Flutter syntax used, written for someone starting from zero.

---

## 1. How to run the app

```bash
flutter pub get      # download the packages listed in pubspec.yaml
flutter run          # build and start the app (pick a device/emulator/Chrome)
flutter analyze      # check the code for errors and warnings
flutter test         # run the tests in the test/ folder
```

---

## 2. Project structure

```
todo_app/
├── lib/                        <- ALL your Dart code lives here
│   ├── main.dart               <- starting point of the app
│   ├── models/
│   │   └── todo.dart           <- what a "Todo" is (the data)
│   ├── services/
│   │   └── todo_service.dart   <- add / read / update / delete logic
│   ├── screens/
│   │   └── todo_screen.dart    <- the main page (joins everything together)
│   └── widgets/
│       ├── todo_input.dart     <- text box + "Add" button
│       └── todo_item.dart      <- one row in the list
├── test/
│   └── widget_test.dart        <- automatic test for the app
├── pubspec.yaml                <- project name, version, packages
├── analysis_options.yaml       <- lint (code-style) rules
└── android/ ios/ web/ windows/ macos/ linux/   <- platform files (generated, rarely touched)
```

**Why split into folders?** Each file has one job:

| Folder     | Job                                          | Analogy               |
|------------|----------------------------------------------|-----------------------|
| `models`   | Describes the shape of the data              | A blank form          |
| `services` | Changes the data (the logic)                 | The clerk who files forms |
| `widgets`  | Small reusable pieces of UI                  | Lego bricks           |
| `screens`  | A full page built from widgets               | The finished Lego model |

**How data flows:**

```
User taps a button  ->  Widget calls a callback (onAdd / onEdit / ...)
                    ->  Screen calls TodoService
                    ->  Service changes the list
                    ->  Screen calls setState()  ->  Flutter redraws the UI
```

---

## 3. Core ideas to understand first

### Everything is a Widget
In Flutter, *everything* on screen is a **widget**: text, buttons, padding, rows, even the whole app.
Widgets are placed **inside** other widgets, which makes a tree:

```
MaterialApp
 └── Scaffold
      ├── AppBar
      └── Padding
           └── Column
                ├── TodoInput (Row -> TextField, SizedBox, ElevatedButton)
                └── Expanded -> ListView -> TodoItem (Card -> ListTile)
```

### StatelessWidget vs StatefulWidget
| StatelessWidget | StatefulWidget |
|---|---|
| Has no data that changes over time | Has data that changes (the `State`) |
| Redrawn only when its parent gives it new values | Redraws itself when you call `setState()` |
| Example: `TodoInput`, `TodoItem` | Example: `TodoScreen` (the todo list changes) |

### `build()` method
Every widget has a `build` method. It **returns** the widgets to show. Flutter calls it every time the screen needs to redraw.

### `child` vs `children`
- `child:` holds **one** widget, for example `Padding`, `Center`, `Expanded`, or `Card`.
- `children: [ ... ]` holds a **list** of widgets, for example `Row` or `Column`.

---

## 4. File-by-file explanation

### 4.1 `lib/main.dart` — the starting point

```dart
import 'package:flutter/material.dart';
```
- `import` brings in code from another file or package.
- `package:flutter/material.dart` provides all the Material Design widgets (buttons, text fields, etc.).

```dart
import 'screens/todo_screen.dart';
```
- A **relative import**: a path to one of your own files, relative to this file.

```dart
void main() {
  runApp(const TodoApp());
}
```
- `main()` is where **every** Dart program starts.
- `void` means the function returns nothing.
- `runApp(...)` tells Flutter which widget is the root of the app.
- `const` means the object is fixed at compile time. Flutter can reuse it instead of rebuilding it, which is faster.

```dart
class TodoApp extends StatelessWidget {
  const TodoApp({super.key});
```
- `class TodoApp` defines a new type named `TodoApp`.
- `extends StatelessWidget` means TodoApp **is a** StatelessWidget and inherits its behaviour.
- `const TodoApp({super.key});` is the **constructor**, the function that creates the object.
  - `{ }` means the parameters are **named** (you write `TodoApp(key: ...)`).
  - `super.key` passes `key` up to the parent class. A key helps Flutter identify widgets. You can ignore it for now, but always include it.

```dart
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo App',
      home: const TodoScreen(),
    );
  }
```
- `@override` means "I am replacing a method that the parent class already has".
- `Widget build(BuildContext context)` is a method that returns a `Widget`.
  - `BuildContext context` tells the widget where it sits in the widget tree.
- `MaterialApp` is the wrapper that gives the app theme, navigation, and so on.
  - `debugShowCheckedModeBanner: false` hides the red "DEBUG" ribbon.
  - `home:` sets the first screen to show.
- `name: value,` is **named-argument** syntax. The comma after the last argument (the *trailing comma*) makes the formatter lay the code out nicely.

---

### 4.2 `lib/models/todo.dart` — the data

```dart
class Todo {
  int id;
  String title;
  bool isCompleted;

  Todo({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });
}
```
- **Fields** (variables stored in each Todo):
  - `int` is a whole number (1, 2, 3...).
  - `String` is text ('Buy milk').
  - `bool` is `true` or `false`.
- **Constructor** `Todo({...})`:
  - `this.id` is a shortcut meaning "store this argument in the `id` field".
  - `required` means you **must** pass this value, or you get an error.
  - `this.isCompleted = false` is a **default value**. If you don't pass it, it becomes `false`.

Usage: `Todo(id: 1, title: 'Learn Flutter')` creates a todo that is not completed.

---

### 4.3 `lib/services/todo_service.dart` — the logic (CRUD)

CRUD = **C**reate, **R**ead, **U**pdate, **D**elete.

```dart
final List<Todo> _todos = [];
int _nextId = 1;
```
- `List<Todo>` is a list that can only hold `Todo` objects. The `<Todo>` part is called a **generic type**.
- `[]` is an empty list.
- `final` means this variable can't be pointed to a different list, but you can still add to or remove from the list itself.
- `_` (underscore) at the start of a name makes it **private**: only code inside this file can use it. That protects the list from being changed from outside.

**Create**
```dart
Todo addTodo(String title) {
  final todo = Todo(id: _nextId, title: title);
  _todos.add(todo);
  _nextId++;
  return todo;
}
```
- `Todo addTodo(String title)` takes a String and returns a Todo.
- `final todo = ...`: Dart **infers** (works out) the type from the value, so you don't have to write `Todo`.
- `_nextId++` adds 1 to `_nextId`, so each todo gets a unique id.

**Read**
```dart
List<Todo> getTodos() {
  return List.unmodifiable(_todos);
}
```
- Returns a **read-only copy**, so the screen can't change the list by accident.

**Update**
```dart
void updateTodo(int id, String newTitle) {
  for (Todo todo in _todos) {
    if (todo.id == id) {
      todo.title = newTitle;
      break;
    }
  }
}
```
- `for (Todo todo in _todos)` loops over every todo in the list.
- `==` compares two values (a single `=` *assigns* a value).
- `break` stops the loop early once the todo is found.

**Delete**
```dart
void deleteTodo(int id) {
  _todos.removeWhere((todo) => todo.id == id);
}
```
- `(todo) => todo.id == id` is an **arrow function** (a short anonymous function).
  - `=> expression` is short for `{ return expression; }`.
- `removeWhere` removes every item for which the function returns `true`.

**Toggle**
```dart
todo.isCompleted = !todo.isCompleted;
```
- `!` means **NOT**: it turns `true` into `false` and `false` into `true`.

---

### 4.4 `lib/screens/todo_screen.dart` — the main page

```dart
class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() {
    return _TodoScreenState();
  }
}

class _TodoScreenState extends State<TodoScreen> {
  ...
}
```
A StatefulWidget always comes as **two classes**:
1. `TodoScreen`, the widget itself. It doesn't change.
2. `_TodoScreenState`, which holds the **changing data** and the `build` method.
`createState()` connects the two.

**Fields**
```dart
final TextEditingController todoController = TextEditingController();
final TodoService todoService = TodoService();
List<Todo> todos = [];
```
- `TextEditingController` lets you **read** (`.text`), **set**, and **clear** (`.clear()`) what's typed in a TextField.
- `todoService` holds the service object that does the CRUD work.
- `todos` is the list shown on screen.

**Lifecycle methods**
```dart
@override
void initState() {
  super.initState();
  loadTodos();
}

@override
void dispose() {
  todoController.dispose();
  super.dispose();
}
```
- `initState()` runs **once**, when the screen is first created. It's a good place to load data.
- `dispose()` runs when the screen is removed. Use it to free resources such as controllers.
- `super.initState()` / `super.dispose()` call the parent class's version. These calls are required.

**setState**
```dart
void loadTodos() {
  setState(() {
    todos = todoService.getTodos();
  });
}
```
- `setState(() { ... })` **changes the data and tells Flutter to call `build` again**, so the screen updates.
- `() { ... }` is an **anonymous function** (a function with no name).
- Changing `todos` *without* `setState` would **not** update the screen.

**Add**
```dart
String title = todoController.text.trim();
if (title.isEmpty) {
  return;
}
```
- `.trim()` removes spaces from the start and end.
- `return;` exits the function early, so empty todos are not added.

**Edit (dialog)**
```dart
showDialog(
  context: context,
  builder: (context) {
    return AlertDialog(
      title: ...,
      content: TextField(...),
      actions: [ TextButton(...), ElevatedButton(...) ],
    );
  },
);
```
- `showDialog` opens a popup. `builder` is a function that returns what goes inside it.
- `Navigator.pop(context)` closes the popup (removes the top page or dialog).

**UI (build)**
```dart
return Scaffold(
  appBar: AppBar(title: const Text('Todo App'), centerTitle: true),
  body: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        TodoInput(controller: todoController, onAdd: addTodo),
        const SizedBox(height: 20),
        Expanded(
          child: todos.isEmpty ? const Center(...) : ListView.builder(...),
        ),
      ],
    ),
  ),
);
```
- `Scaffold` is the basic page layout (app bar at the top, body below).
- `Padding` + `EdgeInsets.all(16)` adds 16 pixels of space on every side.
- `Column` stacks its children **vertically**.
- `SizedBox(height: 20)` adds an empty gap.
- `Expanded` makes its child fill the **remaining** space. A `ListView` inside a `Column` needs this.
- `condition ? A : B` is the **ternary operator**: "if the condition is true use A, otherwise use B".
- `ListView.builder` is a scrollable list that builds items **only when they're visible**, which is efficient.
  - `itemCount` sets how many items there are.
  - `itemBuilder: (context, index) { ... }` is called for each position. `index` is 0, 1, 2...
- `onAdd: addTodo` passes the function itself, without calling it. There are **no `()`**.
  - `addTodo()` (with parentheses) would call it **immediately**, which is wrong here.
- `onEdit: () { editTodo(todo); }` wraps the call in an anonymous function, because we need to pass an argument.

---

### 4.5 `lib/widgets/todo_input.dart` — text box + Add button

```dart
class TodoInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onAdd;
```
- Syntax for a field: **`Type name;`** (type, then a space, then the name).
  (The old code had `TextEditingController.controller`, with a dot. That was a syntax error.)
- `VoidCallback` is the type for "a function that takes no arguments and returns nothing". It lets the parent decide what happens on tap.
- The fields are `final` because a StatelessWidget's values must never change.

```dart
Row(
  children: [
    Expanded(child: TextField(...)),
    const SizedBox(width: 10),
    ElevatedButton(onPressed: onAdd, child: const Text('Add')),
  ],
)
```
- `Row` places its children **horizontally**.
- `Expanded` lets the TextField take all the width the button doesn't use.
- `InputDecoration` controls how the text field looks:
  - `labelText` is the label shown above/inside the field.
  - `hintText` is grey example text shown when the field is empty.
  - `border: OutlineInputBorder()` draws a box around the field.
- `onSubmitted: (_) => onAdd()` makes pressing Enter on the keyboard add the todo too.
  `_` is a name for a parameter we don't use.

---

### 4.6 `lib/widgets/todo_item.dart` — one row in the list

```dart
Card(
  margin: const EdgeInsets.only(bottom: 10),
  child: ListTile(
    leading: Checkbox(...),
    title: Text(todo.title, style: TextStyle(...)),
    trailing: Row(mainAxisSize: MainAxisSize.min, children: [...]),
  ),
)
```
- `Card` is a box with rounded corners and a shadow.
- `EdgeInsets.only(bottom: 10)` adds space **only below** the card.
- `ListTile` is a ready-made row layout with three slots:
  - `leading` goes on the left (the checkbox),
  - `title` goes in the middle (the text),
  - `trailing` goes on the right (the buttons).
- `Checkbox(value: ..., onChanged: (value) { onToggle(); })`
  - `value` sets whether it's ticked. `onChanged` runs when the user taps it.
- `TextStyle(decoration: todo.isCompleted ? TextDecoration.lineThrough : TextDecoration.none)`
  crosses out the text when the todo is completed.
- `mainAxisSize: MainAxisSize.min` is **important**. By default a `Row` tries to be as wide as possible, which breaks inside `trailing` and causes an error. `min` makes it only as wide as its buttons.
- `IconButton(icon: const Icon(Icons.edit), onPressed: onEdit)` is a clickable icon.

**Fixes made in this file**

| Before (wrong) | After (correct) | Why |
|---|---|---|
| `ListTitle` | `ListTile` | Spelling: the widget is called ListTile |
| `style:` on `ListTile` | `style:` on `Text` | Only `Text` has a `style` |
| `contextTextDecoration.none` | `TextDecoration.none` | No such thing as `contextTextDecoration` |
| `trailing:` on `Card` | `trailing:` inside `ListTile` | `Card` has no `trailing` slot |
| `Row` with no size | `mainAxisSize: MainAxisSize.min` | Prevents a layout crash |

**Fixes made in `todo_input.dart`**

| Before (wrong) | After (correct) | Why |
|---|---|---|
| `TextEditingController.controller;` | `TextEditingController controller;` | Type and name are separated by a space |
| `VoidCallback.onAdd;` | `VoidCallback onAdd;` | Same reason |
| `hintText: labelText:'Enter Todo'` | `labelText: 'Enter Todo'` | Two names given to one value |
| `SizeBox` | `SizedBox` | Spelling |

---

### 4.7 `test/widget_test.dart` — automatic test

```dart
testWidgets('Adding a todo shows it in the list', (WidgetTester tester) async {
  await tester.pumpWidget(const TodoApp());
  expect(find.text('No Todos yet'), findsOneWidget);
  await tester.enterText(find.byType(TextField), 'Buy milk');
  await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
  await tester.pump();
  expect(find.text('Buy milk'), findsOneWidget);
});
```
- `testWidgets` defines a UI test. `tester` is a robot that can tap and type.
- `async` / `await` are used for steps that take time: wait for each one to finish before the next.
- `pumpWidget` starts the app. `pump()` redraws the screen after a change.
- `find.text(...)` searches the screen. `expect(..., findsOneWidget)` fails the test if the result isn't what we expected.
- The old test was for Flutter's default "counter" app (`MyApp`), which no longer exists, so it was replaced.

---

## 5. Dart syntax cheat-sheet

| Syntax | Meaning | Example |
|---|---|---|
| `;` | Ends a statement | `int a = 5;` |
| `//` | Comment (ignored by Dart) | `// hello` |
| `var` / `final` / `const` | Variable / set once / fixed at compile time | `final name = 'Ali';` |
| `int`, `double`, `String`, `bool` | Basic types | `bool done = false;` |
| `List<T>` | List of items of type T | `List<String> names = [];` |
| `{a, b}` in parameters | Named parameters | `Todo(id: 1, title: 'x')` |
| `required` | Named parameter must be given | `required this.id` |
| `this.x` | Refers to this object's field | `this.title = title` |
| `_name` | Private to this file | `_todos` |
| `() { ... }` | Anonymous function | `onPressed: () { print('hi'); }` |
| `(x) => expr` | Arrow function (one expression) | `(t) => t.id == 1` |
| `a ? b : c` | If a, then b, else c | `done ? 'Yes' : 'No'` |
| `!` | NOT | `!true` gives `false` |
| `==` / `=` | Compare / assign | `if (a == b)` / `a = b` |
| `++` | Add 1 | `i++` |
| `@override` | Replaces a parent method | `@override Widget build(...)` |
| `extends` | Inherit from a class | `class A extends StatelessWidget` |
| `async` / `await` | Wait for slow work | `await tester.pump();` |

---

## 6. Ideas to try next
1. Save todos permanently with the `shared_preferences` package.
2. Show a count such as "3 of 5 done" in the AppBar.
3. Use a separate `TextEditingController` for the edit dialog, so editing doesn't touch the main input box.
4. Swipe a todo to delete it, using the `Dismissible` widget.
