import '../models/todo.dart';

class TodoService {

  //temporary in-memory list
  final List<Todo> _todos =[];

  int _nextId = 1;

  //Create

  Todo addTodo(String title) {
    final todo = Todo(id: _nextId,
    title:title);

    _todos.add(todo);

    _nextId++;

    return todo;
  }

    //read

    List<Todo>getTodos(){
      return List.unmodifiable(_todos);
    }

    //update

    void updateTodo(int id , String newTitle){
      for(Todo todo in _todos){
        if(todo.id == id){
          todo.title = newTitle;
          break;
        }
      }
    }

    //delete

    void deleteTodo(int id){
      _todos.removeWhere((todo)=>todo.id== id);
    }

    //complete / uncomplete

    void toggleTodo(int id){
      for(Todo todo in _todos){
        if(todo.id == id){
          todo.isCompleted = !todo.isCompleted;
          break;
        }
      }
    }
}