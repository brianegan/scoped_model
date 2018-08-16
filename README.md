# scoped_model

[![Build Status](https://travis-ci.org/brianegan/scoped_model.svg?branch=master)](https://travis-ci.org/brianegan/scoped_model)  [![codecov](https://codecov.io/gh/brianegan/scoped_model/branch/master/graph/badge.svg)](https://codecov.io/gh/brianegan/scoped_model)

A set of utilities that allow you to easily pass a data Model from a parent Widget down to it's descendants. In addition, it also re-renders all of the children that use the model when the model is updated.

Besides a couple of tests and a bit of documentation, this is not my work / idea. It's a simple extraction of the [Model classes](https://github.com/fuchsia-mirror/topaz/blob/c2be8939b45ad0494f0130dbea6460e77abbe62b/public/dart/widgets/lib/src/model/model.dart) from Fuchsia's core Widgets, presented as a standalone Flutter Plugin for independent use so we can evaluate this architecture pattern more easily as a community.

## Examples

  * [Counter App](https://github.com/brianegan/scoped_model/tree/master/example) - Introduction to the tools provided by Scoped Model. 
  * [Todo App](https://github.com/brianegan/flutter_architecture_samples/tree/master/example/scoped_model) - Shows how to write a Todo app with persistence and tests. 

## Usage

Let's demo the basic usage with the all-time favorite: A counter example!

```dart
// Start by creating a class that holds some view the app's state. In
// our example, we'll have a simple counter that starts at 0 can be 
// incremented.
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

// Create our App, which will provide the `CounterModel` to 
// all children that require it! 
class CounterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // First, create a `ScopedModel` widget. This will provide 
    // the `model` to the children that request it. 
    return new ScopedModel<CounterModel>(
      model: new CounterModel(),
      child: new Column(children: [
        // Create a ScopedModelDescendant. This widget will get the
        // CounterModel from the nearest ScopedModel<CounterModel>. 
        // It will hand that model to our builder method, and rebuild 
        // any time the CounterModel changes (i.e. after we 
        // `notifyListeners` in the Model). 
        new ScopedModelDescendant<CounterModel>(
          builder: (context, child, model) => new Text('${model.counter}'),
        ),
        new Text("Another widget that doesn't depend on the CounterModel")
      ])
    );
  }
}
```

### Finding the Model

There are two ways to find the `Model` provided by the `ScopedModel` Widget.

  1. Use the `ScopedModelDescendant` Widget. It will find the `Model` and run the
  builder function whenever the `Model` notifies the listeners.
  2. Use the [`ScopedModel.of`](https://pub.dartlang.org/documentation/scoped_model/latest/) static method directly. To make this method more readable for frequent access, you can consider adding your own `of` method to your own `Model` classes like so:
  
```dart
class CounterModel extends Model {
  // ...
 
  /// Wraps [ScopedModel.of] for this [Model].
  static CounterModel of(BuildContext context) =>
      ScopedModel.of<CounterModel>(context);
}
```  

## Contributors

  * Original Authors
  * [Brian Egan](https://github.com/brianegan)
  * [Pascal Welsch](https://github.com/passsy)
