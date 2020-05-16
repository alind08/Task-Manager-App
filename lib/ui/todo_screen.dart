import 'package:flutter/material.dart';
import 'package:todo/model/todoitem.dart';
import 'package:todo/utils/database_client.dart';
import 'package:todo/utils/date_formatter.dart';

class ToDoScreen extends StatefulWidget {
  @override
  _ToDoScreenState createState() => _ToDoScreenState();
}

class _ToDoScreenState extends State<ToDoScreen> {
  final TextEditingController _textEditingController= new TextEditingController();
  var db= new DatabaseHelper();
  final List<TodoItem> _itemList = <TodoItem>[];

  @override
  void initState() {
    super.initState();

    _readToDoList();
  }


  void _handleSubmit(String text) async{
    _textEditingController.clear();
    TodoItem todoItem = new TodoItem(text, dateFormatted());
    int savedItemId = await db.saveItem(todoItem);

    TodoItem addedItem = await db.getItem(savedItemId);

    setState(() {
      _itemList.insert(0, addedItem);
    });

    print("Item saved id: $savedItemId");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: new Column(
        children: <Widget>[
          new Flexible(
              child: new ListView.builder(
                padding: new EdgeInsets.all(10.0),
                  reverse: false,
                  itemCount: _itemList.length,
                  itemBuilder: (_, int index){
                  return Card(
                    color: Colors.white30,
                    child: new ListTile(
                      title: _itemList[index],
                      onLongPress: ()=> _updateItem(_itemList[index],index),
                      trailing: new Listener(
                        key: new Key(_itemList[index].itemName),
                        child: new Icon(Icons.remove_circle,
                        color: Colors.redAccent,),
                        onPointerDown: (pointerEvent)=>
                        _deleteToDo(_itemList[index].id,index),
                      ),
                    ),
                  );
                }),
          ),
          new Divider(
            height: 1.0,
          )
          ],
      ),

      floatingActionButton: new FloatingActionButton(
          tooltip:"Add item",
          backgroundColor: Colors.green ,
          child: new ListTile(
            title: new Icon(Icons.add),
          ),
          onPressed: _showFormDialog),
    );
  }
  void _showFormDialog(){
    var alert= new AlertDialog(
      content: new Row(
        children: <Widget>[
          new Expanded(
              child: new TextField(
                controller: _textEditingController,
                autofocus: true,
                  decoration: new InputDecoration(
                    labelText: "Item",
                    hintText: "Add a Task!",
                    icon: new Icon(Icons.note_add)
                  ),
              ))
        ],
      ),


      actions: <Widget>[
        new FlatButton(
            onPressed: (){
              _handleSubmit(_textEditingController.text);
              _textEditingController.clear();
              Navigator.pop(context);
            },
            child: Text("Save")),
        new FlatButton(onPressed: ()=> Navigator.pop(context),
            child: Text("Cancel"))
      ],
    );
    showDialog(context: context,
    builder: (_){
      return alert;
    });

  }
  _readToDoList() async{
    List items = await db.getAllItems();
    items.forEach((item){
      TodoItem todoItem = TodoItem.map(item);
      print("Db items: ${todoItem.itemName}");
      setState(() {
         _itemList.add(TodoItem.map(item));
      });
    });
  }

  _deleteToDo(int id,int index) async{
    debugPrint("Deleted Item");

    await db.deleteItem(id);
    setState(() {
      _itemList.removeAt(index);
    });
  }

  _updateItem(TodoItem item, int index) {
    var alert= new AlertDialog(
      title: new Text("update item"),
      content: new Row(
        children: <Widget>[
          new Expanded(
              child: new TextField(
                controller: _textEditingController,
                autofocus: true,

                decoration: new InputDecoration(
                  labelText: "item",
                  hintText: "Add changes to your Task",
                  icon: new Icon(Icons.update)
                ),
              ) )
        ],
      ),
      actions: <Widget>[
        new FlatButton(
            onPressed: () async{
              TodoItem newItemUpdated = TodoItem.fromMap(
                  {"itemName": _textEditingController.text,
                    "dateCreated": dateFormatted(),
                    "id": item.id
                  });
              _handleSubmitUpdate(index, item);
              await db.updateItem(newItemUpdated);
              setState(() {
                _readToDoList();
              });
              Navigator.pop(context);
            },
            child: new Text("Update")),
        new FlatButton(onPressed: ()=>Navigator.pop(context),
            child: new Text("Cancel"))
      ],
    );
    showDialog(
        context: context,
        builder:(_){
          return alert;
        });

  }

  void _handleSubmitUpdate(int index, TodoItem item) {
    setState(() {
      _itemList.removeWhere((element){
        _itemList[index].itemName == item.itemName;

      });
      
  });
        }

}


