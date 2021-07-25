library scoped_model;

import 'package:flutter/material.dart';

class ScopedModel<L extends Listenable, T extends DefaultTag>
    extends InheritedNotifier<L> {
  ScopedModel({Key? key, required this.model, this.tag, required Widget child})
      : super(key: key, notifier: model, child: child);

  final L model;
  final T? tag;

  static L of<L extends Listenable>(BuildContext context,
      {bool rebuildOnChange = true}) {
    return ofTagged<L, DefaultTag>(context, rebuildOnChange: rebuildOnChange);
  }

  static L ofTagged<L extends Listenable, T extends DefaultTag>(
      BuildContext context,
      {bool rebuildOnChange = true}) {
    var widget = rebuildOnChange
        ? context.dependOnInheritedWidgetOfExactType<ScopedModel<L, T>>()
        : context
            .getElementForInheritedWidgetOfExactType<ScopedModel<L, T>>()
            ?.widget;

    if (widget == null) {
      throw ScopedModelError();
    } else {
      return (widget as ScopedModel<L, T>).model;
    }
  }
}

class ScopedModelContainer extends StatelessWidget {
  const ScopedModelContainer({required this.container, required this.child});
  final List<Widget Function(Widget)> container;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    var wrapped = child;

    container.forEach((func) {
      wrapped = func(wrapped);
    });

    return wrapped;
  }
}

typedef ScopedModelDescendant<L extends Listenable>
    = ScopedModelTagged<L, DefaultTag>;

class ScopedModelTagged<L extends Listenable, T extends DefaultTag>
    extends StatelessWidget {
  ScopedModelTagged(
      {required this.builder, this.child, this.rebuildOnChange = true});

  final ScopedModelDescendantBuilder<L> builder;
  final Widget? child;
  final bool rebuildOnChange;

  @override
  Widget build(BuildContext context) {
    return builder(
      context,
      child,
      ScopedModel.ofTagged<L, T>(context, rebuildOnChange: rebuildOnChange),
    );
  }
}

typedef Widget ScopedModelDescendantBuilder<L extends Listenable>(
  BuildContext context,
  Widget? child,
  L model,
);

extension OfContext on BuildContext {
  L dependOn<L extends Listenable>() {
    return ScopedModel.of<L>(this);
  }

  L dependOnTagged<L extends Listenable, T extends DefaultTag>() {
    return ScopedModel.ofTagged<L, T>(this);
  }

  L get<L extends Listenable>() {
    return ScopedModel.of<L>(this, rebuildOnChange: false);
  }

  L getTagged<L extends Listenable, T extends DefaultTag>() {
    return ScopedModel.ofTagged<L, T>(this, rebuildOnChange: false);
  }
}

abstract class DefaultTag {}

class ScopedModelError extends Error {
  ScopedModelError();

  String toString() {
    return '''Error: Could not find the correct ScopedModel.
    
To fix, please:
          
  * Provide types to ScopedModelDescendant<MyModel> 
  * Provide types to ScopedModel.of<MyModel>() 
  * Always use package imports. Ex: `import 'package:my_app/my_model.dart';
  
If none of these solutions work, please file a bug at:
https://github.com/brianegan/scoped_model/issues/new
      ''';
  }
}
