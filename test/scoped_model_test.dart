import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scoped_model/scoped_model.dart';

void main() {
  testWidgets('Models can be handed down from parent to child',
      (WidgetTester tester) async {
    final initialValue = 0;
    final model = TestModel(initialValue);
    final widget = TestWidget(model);

    await tester.pumpWidget(widget);

    expect(find.text('$initialValue'), findsOneWidget);
  });

  testWidgets('Widgets update when the model notifies the listeners',
      (WidgetTester tester) async {
    final initialValue = 0;
    final model = TestModel(initialValue);
    final widget = TestWidget(model);

    // Starts out at the initial value
    await tester.pumpWidget(widget);

    // Increment the model, which should notify the children to rebuild
    model.increment();

    // Rebuild the widget
    await tester.pumpWidget(widget);

    expect(model.listenerCount, 1);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets(
      'Widgets do not update when the model notifies the listeners if the choose not to',
      (WidgetTester tester) async {
    final initialValue = 0;
    final model = TestModel(initialValue);
    final widget = TestWidget.noRebuild(model);

    // Starts out at the initial value
    await tester.pumpWidget(widget);

    // Increment the model, which shouldn't trigger a rebuild
    model.increment();

    // Rebuild the widget
    await tester.pumpWidget(widget);

    expect(model.listenerCount, 1);
    expect(find.text('$initialValue'), findsOneWidget);
  });

  testWidgets("model change doesn't build widgets between model and descendant",
      (WidgetTester tester) async {
    var testModel = TestModel();

    // use List to pass the counter by reference
    List<int> buildCounter = [0];

    // build widget tree with items between scope and descendant
    var tree = MaterialApp(
      home: ScopedModel<TestModel>(
        model: testModel,
        child: Container(
          child: BuildCountContainer(
            buildCounter: buildCounter,
            child: ScopedModelDescendant<TestModel>(
              builder: (BuildContext context, Widget? child, TestModel model) {
                return Text("${model.counter}");
              },
            ),
          ),
        ),
      ),
    );

    // initial drawing shows the counter form the model
    await tester.pumpWidget(tree);
    expect(find.text('0'), findsOneWidget);
    // the render method of the widgets between scope and descendant is called once
    expect(buildCounter[0], 1);

    // Increment the model, which should rebuild only the listening descendant subtree
    testModel.increment();
    await tester.pump();
    await tester.pump();

    // the text changes correctly
    expect(find.text("1"), findsOneWidget);

    // the render method of the widgets between scope and descendant doesn't get called!
    expect(buildCounter[0], 1);
  });

  testWidgets('Throws an error if type info not provided',
      (WidgetTester tester) async {
    final initialValue = 0;
    final model = TestModel(initialValue);
    final widget = ErrorWidget(model);

    await tester.pumpWidget(widget);

    expect(tester.takeException(), isInstanceOf<ScopedModelError>());
  });
}

class TestModel extends Model {
  int _counter;

  TestModel([int initialValue = 0]) : _counter = initialValue;

  int get counter => _counter;

  void increment([int? value]) {
    _counter++;
    notifyListeners();
  }
}

class TestWidget extends StatelessWidget {
  final TestModel model;
  final bool rebuildOnChange;

  TestWidget(this.model, [this.rebuildOnChange = true]);

  factory TestWidget.noRebuild(TestModel model) => TestWidget(model, false);

  @override
  Widget build(BuildContext context) {
    return ScopedModel<TestModel>(
      model: model,
      // Extra nesting to ensure the model is sent down the tree.
      child: Container(
        child: Container(
          child: ScopedModelDescendant<TestModel>(
            rebuildOnChange: rebuildOnChange,
            builder: (context, child, model) {
              return Text(
                model.counter.toString(),
                textDirection: TextDirection.ltr,
              );
            },
          ),
        ),
      ),
    );
  }
}

class ErrorWidget extends StatelessWidget {
  final TestModel model;
  final bool rebuildOnChange;

  ErrorWidget(this.model, [this.rebuildOnChange = true]);

  @override
  Widget build(BuildContext context) {
    return ScopedModel<TestModel>(
      model: model,
      // Extra nesting to ensure the model is sent down the tree.
      child: Container(
        child: Container(
          child: ScopedModelDescendant(
            rebuildOnChange: rebuildOnChange,
            builder: (context, child, dynamic model) {
              return Text(
                model.counter.toString(),
                textDirection: TextDirection.ltr,
              );
            },
          ),
        ),
      ),
    );
  }
}

class BuildCountContainer extends Container {
  final List<int> buildCounter;

  @override
  Widget build(BuildContext context) {
    buildCounter[0]++;
    return super.build(context);
  }

  BuildCountContainer({Widget? child, required this.buildCounter})
      : super(child: child);
}
