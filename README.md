# scoped_model

[![Build Status](https://travis-ci.org/brianegan/scoped_model.svg?branch=master)](https://travis-ci.org/brianegan/scoped_model)  [![codecov](https://codecov.io/gh/brianegan/scoped_model/branch/master/graph/badge.svg)](https://codecov.io/gh/brianegan/scoped_model)

A set of utilities that allow you to easily pass a data Model from a parent Widget down to it's descendants. In addition, it also re-renders all of the children who use the model when the model is updated.

Besides a couple of tests and a bit of documentation, this is not my work / idea. It's a simple extraction of the [Model classes](https://github.com/fuchsia-mirror/widgets/blob/master/packages/widgets/lib/model.dart) from Fuchsia's core Widgets, presented as a standalone Flutter Plugin for independent use so we can evaluate this architecture pattern more easily as a community. 

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
                builder: (context, child, model) => new Text(
                    model.counter.toString()),
              ),
        new Text("Another widget that doesn't depend on the CounterModel")
      ])
    );
  }
}
```  
