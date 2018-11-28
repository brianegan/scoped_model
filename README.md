# scoped_model

[![Build Status](https://travis-ci.org/brianegan/scoped_model.svg?branch=master)](https://travis-ci.org/brianegan/scoped_model)  [![codecov](https://codecov.io/gh/brianegan/scoped_model/branch/master/graph/badge.svg)](https://codecov.io/gh/brianegan/scoped_model)

A set of utilities that allow you to easily pass a data Model from a parent Widget down to it's descendants. In addition, it also rebuilds all of the children that use the model when the model is updated. This library was originally extracted from the Fuchsia codebase. 

This Library provides three main classes:

  * The `Model` class. You will extend this class to create your own Models, such as `SearchModel` or `UserModel`. You can listen to Models for changes!
  * The `ScopedModel` Widget. If you need to pass a `Model` deep down your Widget hierarchy, you can wrap your `Model` in a `ScopedModel` Widget. This will make the Model available to all descendant Widgets.
  * The `ScopedModelDescendant` Widget. Use this Widget to find the appropriate `ScopedModel` in the Widget tree. It will automatically rebuild whenever the Model notifies that change has taken place.

This library is built upon several features of Flutter:

  * The `Model` class implements the `Listenable` interface
    * `AnimationController` and `TextEditingController` are also `Listenables`
  * The `Model` is passed down the Widget tree using an `InheritedWidget`. When an `InheritedWidget` is rebuilt, it will surgically rebuild all of the Widgets that depend on it's data. No need to manage subscriptions!
  * It uses the `AnimatedBuilder` Widget under the hood to listen to the Model and rebuild the `InheritedWidget` when the model changes. 

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

## Finding the Model

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

## Listening to multiple Models in a build function

In many cases, it makes sense to split your Models apart into logical components
by functionality. For example, rather than having an `AppModel` that contains
all of your application logic, it can often make more sense to split models
apart into a `UserModel`, a `SearchModel` and a `ProductModel`, for example.

However, if you need to display information from two of these models in a single
Widget, you might be wondering how to achieve that! To do so, you have two 
options:

  1. Use multiple `ScopedModelDescendant` Widgets
  2. Use multiple `ScopedModel.of` calls. No need to manage subscriptions,
  Flutter takes care of all of that through the magic of InheritedWidgets.
  
```dart
class CombinedWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final username =
      ScopedModel.of<UserModel>(context, rebuildOnChange: true).username;
    final counter =
      ScopedModel.of<CounterModel>(context, rebuildOnChange: true).counter;

    return Text('$username tapped the button $counter times');
  }
}
```

## Contributors

  * Original Fuchsia Authors
  * [Andrew Wilson](https://github.com/apwilson)
  * [Brian Egan](https://github.com/brianegan)
  * [Pascal Welsch](https://github.com/passsy)
