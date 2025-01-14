import 'package:flutter/material.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// [Widget] building the [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (e) {
              return Container(
                constraints: const BoxConstraints(minWidth: 48),
                height: 48,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.primaries[e.hashCode % Colors.primaries.length],
                ),
                child: Center(child: Icon(e, color: Colors.white)),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Dock of the reorderable [items].
class Dock<T> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// Initial [T] items to put in this [Dock].
  final List<T> items;

  /// Builder building the provided [T] item.
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// State of the [Dock] used to manipulate the [_items].
class _DockState<T> extends State<Dock<T>> {
  /// [T] items being manipulated.
  late final List<T> _items = widget.items.toList();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: SizedBox(
        height: 65,
        child: ReorderableListView(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          // Disable default drag handles to remove the two-line icon.
          buildDefaultDragHandles: false,
          onReorder: (int oldIndex, int newIndex) {
            setState(() {
              if (newIndex > oldIndex) newIndex -= 1;
              final T item = _items.removeAt(oldIndex);
              _items.insert(newIndex, item);
            });
          },
          proxyDecorator:
              (Widget child, int index, Animation<double> animation) {
            return ScaleTransition(
              scale: animation.drive(Tween<double>(begin: 1.0, end: 1.05)),
              child: Opacity(
                opacity: 0.9,
                child: child,
              ),
            );
          },
          children: _items.asMap().entries.map((entry) {
            int index = entry.key;
            T e = entry.value;
            // Wrap each item with ReorderableDragStartListener for long-press dragging.
            return ReorderableDragStartListener(
              key: ValueKey(e),
              index: index,
              child: widget.builder(e),
            );
          }).toList(),
        ),
      ),
    );
  }
}
