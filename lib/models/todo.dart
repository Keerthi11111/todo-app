class Todo {

  //Todo title

  int id;

  String title;

  //whether the todo is completed.
  bool isCompleted;

  //constructor
  Todo({
    required this.id,
    required this.title,
    this.isCompleted =false
  });

}