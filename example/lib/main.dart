import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

void main() {
  runApp(MyApp(
    counterModel: CounterModel(),
    userModel: UserModel('Brian'),
  ));
}

class MyApp extends StatelessWidget {
  final CounterModel counterModel;
  final UserModel userModel;

  const MyApp({
    Key key,
    @required this.counterModel,
    @required this.userModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // At the top level of our app, we'll, create a ScopedModel Widget. This
    // will provide the CounterModel to all children in the app that request it
    // using a ScopedModelDescendant.
    return ScopedModel<UserModel>(
      model: userModel,
      child: ScopedModel<CounterModel>(
        model: counterModel,
        child: MaterialApp(
          title: 'Scoped Model Demo',
          home: CounterHome('Scoped Model Demo'),
        ),
      ),
    );
  }
}

// Start by creating a class that has a counter and a method to increment it.
//
// Note: It must extend from Model.
class CounterModel extends Model {
  int _counter = 0;

  int get counter => _counter;

  void increment() {
    // First, increment the counter
    _counter++;

    // Then notify all the listeners.
    notifyListeners();
  }
}

class UserModel extends Model {
  String _username;

  UserModel(String username) : _username = username;

  String get username => _username;

  set username(String newName) {
    _username = newName;
    notifyListeners();
  }
}

class CounterHome extends StatelessWidget {
  final String title;

  CounterHome(this.title);

  @override
  Widget build(BuildContext context) {
    final counter =
        ScopedModel.of<CounterModel>(context, rebuildOnChange: true).counter;
    final userModel = ScopedModel.of<UserModel>(context, rebuildOnChange: true);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('${userModel.username} pushed the button this many times:'),
            // Create a ScopedModelDescendant. This widget will get the
            // CounterModel from the nearest parent ScopedModel<CounterModel>.
            // It will hand that CounterModel to our builder method, and
            // rebuild any time the CounterModel changes (i.e. after we
            // `notifyListeners` in the Model).
            Text('$counter', style: Theme.of(context).textTheme.display1),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RaisedButton(
                child: Text('Change Username'),
                onPressed: () {
                  userModel.username = 'Suzanne';
                },
              ),
            )
          ],
        ),
      ),
      // Use the ScopedModelDescendant again in order to use the increment
      // method from the CounterModel
      floatingActionButton: ScopedModelDescendant<CounterModel>(
        builder: (context, child, model) {
          return FloatingActionButton(
            onPressed: model.increment,
            tooltip: 'Increment',
            child: Icon(Icons.add),
          );
        },
      ),
    );
  }
}
