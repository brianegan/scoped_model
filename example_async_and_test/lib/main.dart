import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:async';

void main() {
  runApp(MyApp(model: CounterModel()));
}

class MyApp extends StatelessWidget {
  final AbstractModel model;

  const MyApp({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // At the top level of our app, we'll, create a ScopedModel Widget. This
    // will provide the CounterModel to all children in the app that request it
    // using a ScopedModelDescendant.
    return ScopedModel<AbstractModel>(
      model: model,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: CounterHome('Scoped Model Demo'),
      ),
    );
  }
}

// Start by creating a class that has a counter and a method to increment it.
//
// Note: It must extend from Model.
abstract class AbstractModel extends Model {
  int get counter;
  void increment();
}

class CounterModel extends AbstractModel {
  int _counter = 0;

  int get counter => _counter;

  void increment() async {
    // First, increment the counter
    _counter++;

    // needed for simulate an async action like an http request ...
    await Future.delayed(const Duration(seconds: 1));

    // Then notify all the listeners.
    notifyListeners();
  }
}

class TestModel extends AbstractModel {
  int _counter = 111;

  int get counter => _counter;

  void increment() {
    _counter += 2;
    notifyListeners();
  }
}

class CounterHome extends StatelessWidget {
  final String title;

  CounterHome(this.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            // Create a ScopedModelDescendant. This widget will get the
            // CounterModel from the nearest parent ScopedModel<CounterModel>.
            // It will hand that CounterModel to our builder method, and
            // rebuild any time the CounterModel changes (i.e. after we
            // `notifyListeners` in the Model).
            ScopedModelDescendant<AbstractModel>(
              builder: (context, child, model) => Text(
                model.counter.toString(),
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
          ],
        ),
      ),
      // Use the ScopedModelDescendant again in order to use the increment
      // method from the CounterModel
      floatingActionButton: ScopedModelDescendant<AbstractModel>(
        builder: (context, child, model) => FloatingActionButton(
          onPressed: model.increment,
          tooltip: 'Increment',
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
