import 'dart:ffi';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:panels/panels.dart';

typedef ButtonBuilder = Widget Function(BuildContext context, VoidCallback onTap);
typedef PanelStateBuilder = Widget Function(BuildContext context, PanelState state);
typedef PanelStateChildBuilder = Widget Function(BuildContext context, PanelState state, Widget child);

class PanelsTheme extends InheritedTheme {
  final PanelsThemeData data;

  @override
  bool updateShouldNotify(PanelsTheme oldWidget) {
    return oldWidget.data != data;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return PanelsTheme(data: data, child: child);
  }

  static PanelsTheme? of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<PanelsTheme>();

  PanelsTheme({Key? key, required this.data, required Widget child}) : super(key: key, child: child);
}

class PanelsThemeData with Diagnosticable {
  final double resizeBorderWidth;
  final double resizeCornerWidth;
  final double frameDraggedElevation;
  final double frameStaticElevation;

  final bool showDebugColors;

  List<Color>? get debugColors {
    var size = 10;
    if (!showDebugColors) return List.filled(size, Colors.transparent);

    var random = Random(1335);

    return List.generate(size, (index) => Color.fromRGBO(random.nextInt(255), random.nextInt(255), random.nextInt(255), 1.0 / (index + 1).toDouble()));
  }

  final ButtonBuilder closeButtonBuilder;
  static Widget defaultCloseButtonBuilder(BuildContext context, VoidCallback onTap) {
    return Container(
      margin: EdgeInsets.all(5),
      child: ClipOval(
        child: Material(
          color: Theme.of(context).errorColor,
          shape: CircleBorder(),
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.all(3),
              child: Center(
                child: Icon(
                  Icons.close,
                  size: 9.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  final PanelStateBuilder contextMenuBuilder;
  static Widget defaultContextMenuBuilder(BuildContext context, PanelState state) {
    return PopupMenuButton<String>(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
      tooltip: "Context Menu",
      child: Center(
        child: Icon(Icons.more_vert, size: 19.0),
      ),
      initialValue: state.widget.titles[state.tabController.index],
      onSelected: (String value) {
        state.tabController.animateTo(state.widget.titles.indexOf(value));
      },
      itemBuilder: (context) {
        return state.widget.titles.map((String? title) {
          return PopupMenuItem<String>(
            height: 10.0,
            // enabled: title != widget.titles[tabController.index],
            value: title ?? "Panel",
            child: Text(title ?? "Panel"),
          );
        }).toList();
      },
    );
  }

  final PanelStateChildBuilder frameBuilder;
  static Widget defaultFrameBuilder(BuildContext context, PanelState state, Widget child) {
    var theme = PanelsTheme.of(context)!.data;

    return Material(elevation: state.dragged ? theme.frameDraggedElevation : theme.frameStaticElevation, child: Container(color: theme.debugColors?[9], child: child));
  }

  PanelsThemeData(
      {this.resizeBorderWidth = 6.0,
      this.resizeCornerWidth = 10.0,
      this.frameDraggedElevation = 4.0,
      this.frameStaticElevation = 2.0,
      this.closeButtonBuilder = defaultCloseButtonBuilder,
      this.contextMenuBuilder = defaultContextMenuBuilder,
      this.frameBuilder = defaultFrameBuilder,
      this.showDebugColors = false});

  @override
  int get hashCode {
    return hashValues(resizeBorderWidth, resizeCornerWidth, frameDraggedElevation, frameStaticElevation, showDebugColors, closeButtonBuilder, contextMenuBuilder, frameBuilder);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is PanelsThemeData && other.hashCode == hashCode;
  }
}

class FrostedPanelsThemeData extends PanelsThemeData {
  static Widget frostedFrameBuilder(BuildContext context, PanelState state, Widget child) {
    var theme = PanelsTheme.of(context)!.data;
    var border = BorderRadius.only(bottomLeft: Radius.circular(10.0), bottomRight: Radius.circular(10.0), topRight: Radius.circular(10.0));

    return Container(
      decoration: BoxDecoration(
        borderRadius: border,
        border: Border.all(color: Colors.black.withOpacity(0.2)),
      ),
      child: ClipRRect(
          borderRadius: border,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
            child: Material(
                shape: RoundedRectangleBorder(
                  borderRadius: border,
                ),
                type: MaterialType.transparency,
                child: Container(color: theme.debugColors?[9], child: child)),
          )),
    );
  }

  static Widget frostedContextMenuBuilder(BuildContext context, PanelState state) {
    return PopupMenuButton<String>(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
      tooltip: "Context Menu",
      child: Center(
        child: Icon(Icons.more_vert, size: 19.0),
      ),
      initialValue: state.widget.titles[state.tabController.index],
      onSelected: (String value) {
        state.tabController.animateTo(state.widget.titles.indexOf(value));
      },
      color: Theme.of(context).popupMenuTheme.color?.withOpacity(0.5),
      itemBuilder: (context) {
        return state.widget.titles.map((String? title) {
          return PopupMenuItem<String>(
            height: 10.0,
            // enabled: title != widget.titles[tabController.index],
            value: title ?? "Panel",
            child: Text(title ?? "Panel"),
          );
        }).toList();
      },
    );
  }

  FrostedPanelsThemeData() : super(frameBuilder: frostedFrameBuilder, contextMenuBuilder: frostedContextMenuBuilder);
}
