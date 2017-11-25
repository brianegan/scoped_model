import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:scoped_model/scoped_model.dart';

void main() {
  testWidgets('Models can be handed down from parent to child',
      (WidgetTester tester) async {
    final initialValue = 0;
    final model = new TestModel(initialValue);
    final widget = new TestWidget(model);

    await tester.pumpWidget(widget);

    final Text text = tester.firstWidget(find.byKey(testKey));

    expect(text.data, initialValue.toString());
  });

  testWidgets('Widgets update when the model notifies the listeners',
      (WidgetTester tester) async {
    final initialValue = 0;
    final model = new TestModel(initialValue);
    final widget = new TestWidget(model);

    // Starts out at the initial value
    await tester.pumpWidget(widget);

    // Increment the model, which should notify the children to rebuild
    model.increment();

    // Rebuild the widget
    await tester.pumpWidget(widget);

    expect(model.listenerCount, 1);
    expect((tester.firstWidget(find.byKey(testKey)) as Text).data, '1');
  });

  testWidgets(
      'Widgets do not update when the model notifies the listeners if the choose not to',
      (WidgetTester tester) async {
    final initialValue = 0;
    final model = new TestModel(initialValue);
    final widget = new TestWidget.noRebuild(model);

    // Starts out at the initial value
    await tester.pumpWidget(widget);

    // Increment the model, which shouldn't trigger a rebuild
    model.increment();

    // Rebuild the widget
    await tester.pumpWidget(widget);

    expect(model.listenerCount, 1);
    expect((tester.firstWidget(find.byKey(testKey)) as Text).data,
        initialValue.toString());
  });
}

final testKey = new UniqueKey();

class TestModel extends Model {
  int _counter;

  TestModel([int initialValue = 0]) {
    _counter = initialValue;
  }

  int get counter => _counter;

  void increment([int value]) {
    _counter++;
    notifyListeners();
  }
}

class TestWidget extends StatelessWidget {
  final TestModel model;
  final bool rebuildOnChange;

  TestWidget(this.model, [this.rebuildOnChange = true]);

  factory TestWidget.noRebuild(TestModel model) => new TestWidget(model, false);

  @override
  Widget build(BuildContext context) {
    return new ScopedModel<TestModel>(
      model: model,
      // Extra nesting to ensure the model is sent down the tree.
      child: new Container(
        child: new Container(
          child: new ScopedModelDescendant<TestModel>(
            rebuildOnChange: rebuildOnChange,
            builder: (context, child, model) => new Text(
                  model.counter.toString(),
                  key: testKey,
                  textDirection: TextDirection.ltr,
                ),
          ),
        ),
      ),
    );
  }
}
