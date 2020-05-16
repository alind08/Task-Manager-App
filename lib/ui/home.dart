import 'package:flutter/material.dart';
import 'package:todo/ui/todo_screen.dart';



class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: Text("TO-DO"),
        backgroundColor: Colors.lightBlue,
        centerTitle: true,
      ),
      body: new ToDoScreen(),
    );
  }
}
