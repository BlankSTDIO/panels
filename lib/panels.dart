library panels;

import 'dart:math';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:panels/themes.dart';

typedef AddPanelCallback = void Function({required Widget widget, String? title});
typedef AddPanelWithTabsCallback = void Function({required List<Widget> widgets, required List<String?> titles});
typedef PanelKeyCallback = void Function(Key key);

class Panels extends InheritedWidget {
  final AddPanelCallback addPanel;
  final AddPanelWithTabsCallback addPanelWithTabs;
  final PanelKeyCallback removePanel;
  final PanelKeyCallback selectPanel;
  final Key? currentlySelectedPanelKey;

  Panels({
    Key? key,
    required Widget child,
    required this.addPanel,
    required this.addPanelWithTabs,
    required this.removePanel,
    required this.selectPanel,
    required this.currentlySelectedPanelKey,
  }) : super(key: key, child: child);

  static Panels of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<Panels>()!;

  @override
  bool updateShouldNotify(Panels oldWidget) {
    return currentlySelectedPanelKey != oldWidget.currentlySelectedPanelKey;
  }
}

class PanelsManager extends StatefulWidget {
  final List<Widget>? children;
  final bool debug;
  final PanelsThemeData? themeData;

  PanelsManager({Key? key, this.debug = false, this.children, this.themeData}) : super(key: key);

  @override
  _PanelsManagerState createState() => _PanelsManagerState();
}

class _PanelsManagerState extends State<PanelsManager> {
  List<Widget> currentPanels = [];
  Map<Key, Widget> panelsMap = Map<Key, Widget>();
  late Key? currentlySelectedPanelKey;

  @override
  void initState() {
    populateWithDebugPanels();

    widget.children?.forEach((child) {
      addPanel(widget: child, title: "Panel");
    });

    super.initState();
  }

  void populateWithDebugPanels() {
    for (int j = 0; j < 5; j++) {
      List<Widget> widgets = [];
      List<String> titles = [];

      for (int i = 0; i < 4; i++) {
        widgets.add(Center(
          child: Text("Panel $j - $i!"),
        ));
        titles.add("Panel $j - $i");
      }

      addPanelWithTabs(widgets: widgets, titles: titles);
    }
  }

  void addPanelWithTabs({required List<Widget> widgets, required List<String?> titles}) {
    var key = GlobalKey();

    setState(() {
      var newPanel = Panel(key: key, titles: titles, children: widgets);

      panelsMap[key] = newPanel;
      currentPanels = panelsMap.values.toList();
    });
  }

  void addPanel({required Widget widget, String? title}) {
    addPanelWithTabs(widgets: [widget], titles: [title]);
  }

  void selectPanel(Key key) {
    if (panelsMap.containsKey(key)) {
      setState(() {
        var window = panelsMap.remove(key);
        currentPanels = panelsMap.values.toList();
        panelsMap[key] = window!;
        currentPanels.add(window);
      });
    }
  }

  void removePanel(Key key) {
    if (panelsMap.containsKey(key)) {
      setState(() {
        panelsMap.remove(key);
        currentPanels = panelsMap.values.toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentPanels.length > 0) currentlySelectedPanelKey = currentPanels.last.key;

    var panels = Panels(
      addPanel: addPanel,
      addPanelWithTabs: addPanelWithTabs,
      removePanel: removePanel,
      selectPanel: selectPanel,
      currentlySelectedPanelKey: currentlySelectedPanelKey,
      child: Stack(
        children: currentPanels,
      ),
    );

    if (PanelsTheme.of(context) == null) {
      return PanelsTheme(child: panels, data: widget.themeData ?? PanelsThemeData());
    }

    return panels;
  }
}

class Panel extends StatefulWidget {
  final Key key;
  final List<Widget> children;
  final List<String?> titles;
  final Size size;
  final Offset position;

  Panel({
    required this.key,
    required this.children,
    this.size = const Size(500, 500),
    this.titles = const [],
    this.position = const Offset(0, 0),
  }) : assert(titles.length == children.length),
        super(key: key);

  @override
  PanelState createState() => PanelState();
}

class PanelState extends State<Panel> with TickerProviderStateMixin {
  late Size size;
  late Offset position;
  bool dragged = false;

  bool get selected => widget.key == Panels.of(context).currentlySelectedPanelKey;

  int currentChildIndex = 0;
  late TabController tabController;

  Size setSizeGetDelta(double width, double height) {
    var newSize = Size(max(100, width), max(100, height));
    var delta = Size(size.width - newSize.width, size.height - newSize.height);
    size = newSize;
    return delta;
  }

  void resizeUp(Offset requestedDelta) {
    if (!selected) return;
    setState(() {
      var d = setSizeGetDelta(size.width, size.height - requestedDelta.dy);
      position += Offset(0.0, d.height);
    });
  }

  void resizeDown(Offset requestedDelta) {
    if (!selected) return;
    setState(() {
      setSizeGetDelta(size.width, size.height + requestedDelta.dy);
    });
  }

  void resizeLeft(Offset requestedDelta) {
    if (!selected) return;
    setState(() {
      var d = setSizeGetDelta(size.width - requestedDelta.dx, size.height);
      position += Offset(d.width, 0.0);
    });
  }

  void resizeRight(Offset requestedDelta) {
    if (!selected) return;
    setState(() {
      setSizeGetDelta(size.width + requestedDelta.dx, size.height);
    });
  }

  @override
  void initState() {
    size = widget.size;
    position = widget.position;
    tabController = TabController(length: widget.children.length, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    var theme = PanelsTheme.of(context)!.data;
    var debugColors = theme.debugColors;

    var i = -1;
    var tabList = widget.children.map((e) {
      i++;
      var constraints = i == tabController.index ? BoxConstraints(maxWidth: 1000) : BoxConstraints(maxWidth: 80);

      return Draggable<Widget>(
        data: widget.children[i],
        hitTestBehavior: HitTestBehavior.opaque,
        onDragEnd: (details) {
          if(!details.wasAccepted) {
            Panels.of(context).addPanel(
              widget: widget.children[i],
              title: widget.titles[i]
            );

            if(widget.children.length == 1) {
              Panels.of(context).removePanel(widget.key);
            }
          }
        },
        onDragStarted: () {
          setState(() {
            dragged = false;
          });
        },
        feedback: Material(
          child: Text(
            widget.titles[i] ?? "Panel",
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ),
        childWhenDragging: AnimatedContainer(
          duration: Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
          constraints: constraints,
          child: Text(
            "         ",
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
          constraints: constraints,
          child: Text(
            widget.titles[i] ?? "Panel",
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ),
      );
    }).toList();

    // * Draggable Top-bar
    var topBar = Container(
      child: MouseRegion(
        opaque: false,
        cursor: SystemMouseCursors.move,
        child: Listener(
          behavior: HitTestBehavior.deferToChild,
          onPointerDown: (event) => setState(() {
            dragged = true;
            Panels.of(context).selectPanel(widget.key);
          }),
          onPointerUp: (event) => setState(() {
            dragged = false;
          }),
          onPointerMove: (event) => setState(() {
            if (dragged) position += event.delta;
          }),
          child: Container(
            color: HSVColor.fromColor(Theme.of(context).canvasColor).withValue(HSVColor.fromColor(Theme.of(context).canvasColor).value * 0.95).withAlpha(0.9).toColor(),
            child: Row(
              children: [
                AnimatedSwitcher(
                    duration: Duration(milliseconds: 0),
                    child: !(size.width < 200)
                        ? ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: max(size.width / 1.64, 10),
                            ),
                            child: Container(
                              margin: EdgeInsets.all(1),
                              decoration: BoxDecoration(border: Border.all(color: Theme.of(context).textTheme.bodyText1?.color?.withOpacity(0.1) ?? Colors.black)),
                              child: TabBar(
                                indicatorColor: Theme.of(context).textTheme.bodyText1?.color,
                                indicatorSize: TabBarIndicatorSize.label,
                                dragStartBehavior: DragStartBehavior.down,
                                isScrollable: true,
                                controller: tabController,
                                labelPadding: EdgeInsets.symmetric(horizontal: 10),
                                tabs: tabList,
                              ),
                            ))
                        : Container()),
                theme.contextMenuBuilder(context, this),

                Spacer(flex: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.max,
                  children: [theme.closeButtonBuilder(context, () => Panels.of(context).removePanel(widget.key))],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    var content = Expanded(
        child: TabBarView(
      controller: tabController,
      physics: BouncingScrollPhysics(),
      children: widget.children,
    ));

    var centralListener = Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) => Panels.of(context).selectPanel(widget.key),
      child: Container(

          // * Window
          child: Column(
        children: [topBar, content],
      )),
    );

    var sideListeners = Column(
      children: [
        Row(
          children: [
            // * Resize Top Left
            Container(
              width: theme.resizeCornerWidth,
              height: theme.resizeCornerWidth,
              color: debugColors?[2],
              child: MouseRegion(
                opaque: false,
                cursor: SystemMouseCursors.resizeUpLeft,
                child: Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerMove: (event) {
                    resizeUp(event.delta);
                    resizeLeft(event.delta);
                  },
                  onPointerDown: (event) => Panels.of(context).selectPanel(widget.key),
                ),
              ),
            ),

            // * Resize Top Center
            Expanded(
              child: Container(
                height: theme.resizeBorderWidth,
                color: debugColors?[6],
                child: MouseRegion(
                  opaque: false,
                  cursor: SystemMouseCursors.resizeUpDown,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onVerticalDragUpdate: (event) => resizeUp(event.delta),
                    onVerticalDragStart: (event) => Panels.of(context).selectPanel(widget.key),
                  ),
                ),
              ),
            ),

            // * Resize Top Right
            Container(
              width: theme.resizeCornerWidth,
              height: theme.resizeCornerWidth,
              color: debugColors?[2],
              child: MouseRegion(
                opaque: false,
                cursor: SystemMouseCursors.resizeUpRight,
                child: Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerMove: (event) {
                    resizeUp(event.delta);
                    resizeRight(event.delta);
                  },
                  onPointerDown: (event) => Panels.of(context).selectPanel(widget.key),
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: Row(
            children: [
              // * Resize Left Center
              Container(
                width: theme.resizeBorderWidth,
                color: debugColors?[5],
                child: MouseRegion(
                  opaque: false,
                  cursor: SystemMouseCursors.resizeLeftRight,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragUpdate: (event) => resizeLeft(event.delta),
                    onHorizontalDragStart: (event) => Panels.of(context).selectPanel(widget.key),
                  ),
                ),
              ),

              Expanded(
                child: Container(),
              ),

              // * Resize Right Center
              Container(
                width: theme.resizeBorderWidth,
                color: debugColors?[5],
                child: MouseRegion(
                  opaque: false,
                  cursor: SystemMouseCursors.resizeLeftRight,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragUpdate: (event) => resizeRight(event.delta),
                    onHorizontalDragStart: (event) => Panels.of(context).selectPanel(widget.key),
                  ),
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            // * Resize Bottom Left
            Container(
              width: theme.resizeCornerWidth,
              height: theme.resizeCornerWidth,
              color: debugColors?[2],
              child: MouseRegion(
                opaque: false,
                cursor: SystemMouseCursors.resizeDownLeft,
                child: Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerMove: (event) {
                    resizeDown(event.delta);
                    resizeLeft(event.delta);
                  },
                  onPointerDown: (event) => Panels.of(context).selectPanel(widget.key),
                ),
              ),
            ),

            // * Resize Bottom Center
            Expanded(
              child: Container(
                height: theme.resizeBorderWidth,
                color: debugColors?[6],
                child: MouseRegion(
                  opaque: false,
                  cursor: SystemMouseCursors.resizeUpDown,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onVerticalDragUpdate: (event) => resizeDown(event.delta),
                    onVerticalDragStart: (event) => Panels.of(context).selectPanel(widget.key),
                  ),
                ),
              ),
            ),

            // * Resize Bottom Right
            Container(
              width: theme.resizeCornerWidth,
              height: theme.resizeCornerWidth,
              color: debugColors?[2],
              child: MouseRegion(
                opaque: false,
                cursor: SystemMouseCursors.resizeDownRight,
                child: Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerMove: (event) {
                    resizeDown(event.delta);
                    resizeRight(event.delta);
                  },
                  onPointerDown: (event) => Panels.of(context).selectPanel(widget.key),
                ),
              ),
            ),
          ],
        ),
      ],
    );

    return Positioned(
      top: position.dy,
      left: position.dx,
      child: SizedBox.fromSize(
        size: size,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                padding: EdgeInsets.all(theme.resizeBorderWidth),
                child: DragTarget<Widget>(
                  builder: (context, candidateData, rejectedData) {
                    return theme.frameBuilder(context, this, centralListener);
                  },
                  onAccept: (data) {
                    widget.children.add(data);

                    var newTabController = TabController(
                      length: widget.children.length,
                      vsync: this,
                      initialIndex: tabController.index
                    );
                    tabController.dispose();

                    tabController = newTabController;
                  },
                  onMove: (details) => print(details),
                )
              )
            ),

            // * Resize handles
            sideListeners
          ],
        ),
      ),
    );
  }
}
