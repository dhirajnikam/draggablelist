import 'dart:ui';

import 'package:flutter/material.dart';

/// Main widget: A macOS-inspired dock of icons.
class MacDockWidget extends StatefulWidget {
  const MacDockWidget({super.key});

  @override
  State<MacDockWidget> createState() => _MacDockWidgetState();
}

class _MacDockWidgetState extends State<MacDockWidget> {
  int? hoveredIndex;
  int? draggingIndex;
  final double baseItemHeight = 40.0;
  final double baseTranslationY = 0.0;
  final double verticalItemPadding = 10.0;

  final List<IconData> dockItems = [
    Icons.person,
    Icons.message,
    Icons.call,
    Icons.camera,
    Icons.photo,
  ];

  @override
  void initState() {
    super.initState();
    hoveredIndex = null;
    draggingIndex = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background bar
            Positioned(
              height: baseItemHeight + 10,
              left: 0,
              right: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.black12,
                ),
              ),
            ),
            // Hover-animated icons
            Padding(
              padding: EdgeInsets.all(verticalItemPadding),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  dockItems.length,
                  (index) => DragTarget<IconData>(
                    onWillAcceptWithDetails: (data) {
                      if (draggingIndex != null) {
                        setState(() {
                          hoveredIndex = index;
                        });
                      }
                      return true;
                    },
                    onLeave: (data) {
                      setState(() {
                        hoveredIndex = null;
                      });
                    },
                    onAcceptWithDetails: (data) {
                      setState(() {
                        final draggedIndex = draggingIndex!;
                        final draggedItem = dockItems.removeAt(draggedIndex);
                        dockItems.insert(index, draggedItem);
                        draggingIndex = null;
                        hoveredIndex = null;
                      });
                    },
                    builder: (context, candidateData, rejectedData) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (hoveredIndex == index && draggingIndex != null)
                            const SizedBox(
                              width: 40.0,
                              height: 40.0,
                            ),
                          Draggable<IconData>(
                            data: dockItems[index],
                            feedback: _buildDockItem(index),
                            childWhenDragging: const SizedBox(),
                            onDragStarted: () {
                              setState(() {
                                draggingIndex = index;
                              });
                            },
                            onDragEnd: (_) {
                              setState(() {
                                draggingIndex = null;
                              });
                            },
                            child: _buildDockItem(index),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds an individual icon in the dock with hover effects.
  Widget _buildDockItem(int index) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hoveredIndex = index),
      onExit: (_) => setState(() => hoveredIndex = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        transform: Matrix4.identity()
          ..translate(
            0.0,
            _getTranslationY(index),
          ),
        height: _getScaledSize(index),
        width: _getScaledSize(index),
        alignment: Alignment.bottomCenter,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          height: _getScaledSize(index),
          width: _getScaledSize(index),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.primaries[index % Colors.primaries.length],
          ),
          child: Icon(
            dockItems[index],
            size: _getScaledSize(index) / 2,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// Calculates the size of each icon based on hover proximity.
  double _getScaledSize(int index) {
    return _getInterpolatedValue(
      index: index,
      baseValue: baseItemHeight,
      maxValue: 70.0,
      nonHoveredMaxValue: 50.0,
    );
  }

  /// Calculates how far each icon should shift vertically based on hover proximity.
  double _getTranslationY(int index) {
    return _getInterpolatedValue(
      index: index,
      baseValue: baseTranslationY,
      maxValue: -22.0,
      nonHoveredMaxValue: -14.0,
    );
  }

  /// Helper to interpolate icon properties (size or translation).
  double _getInterpolatedValue({
    required int index,
    required double baseValue,
    required double maxValue,
    required double nonHoveredMaxValue,
  }) {
    if (hoveredIndex == null) return baseValue;

    final difference = (hoveredIndex! - index).abs();
    final itemsAffected = dockItems.length;

    if (difference == 0) {
      return maxValue;
    } else if (difference <= itemsAffected) {
      final ratio = (itemsAffected - difference) / itemsAffected;
      return lerpDouble(baseValue, nonHoveredMaxValue, ratio) ?? baseValue;
    } else {
      return baseValue;
    }
  }
}
