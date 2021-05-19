library panels;

import 'dart:math';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


typedef AddPanelCallback = void Function({ required Widget widget, String? title });
typedef PanelKeyCallback = void Function(Key key);

class Panels extends InheritedWidget {

  final AddPanelCallback addPanel;
  final PanelKeyCallback removePanel;
  final PanelKeyCallback selectPanel;

  Panels({
    Key? key,
    required Widget child,
    required this.addPanel,
    required this.removePanel,
    required this.selectPanel
  }) : super(key: key, child: child);

  static Panels of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<Panels>()!;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    // TODO: implement updateShouldNotify
    return true;
  }
}


class PanelsManager extends StatefulWidget {
  final List<Widget>? children;

  PanelsManager({
    Key? key,
    this.children
  }) : super(key: key);

  @override
  _PanelsManagerState createState() => _PanelsManagerState();
}

class _PanelsManagerState extends State<PanelsManager> {
  List<Widget> currentPanels = [];
  Map<Key, Widget> panelsMap = Map<Key, Widget>();

  @override
  void initState() {
    populateWithDebugPanels();

    widget.children?.forEach((child) {
      addPanel(
        widget: child,
        title: "Panel"
      );
    });

    super.initState();
  }

  void populateWithDebugPanels() {
    for(int j = 0; j < 5; j++) {
      List<Widget> widgets = [];
      List<String> titles = [];

      for(int i = 0; i < 4; i++) {
        widgets.add(Center(
          child: Text("Panel $j - $i!"),
        ));
        titles.add(
          "Panel $j - $i"
        );
      }

      addPanels(widgets: widgets, titles: titles);
    }
  }

  void addPanels({
    required List<Widget> widgets,
    required List<String?> titles
  }) {
    var key = GlobalKey();

    setState(() {
      var newPanel = PanelWrapper(
        key: key,
        titles: titles,
        children: widgets
      );

      panelsMap[key] = newPanel;
      currentPanels = panelsMap.values.toList();
    });
  }

  void addPanel({
    required Widget widget,
    String? title
  }) {
    addPanels(
      widgets: [widget],
      titles: [title]
    );
  }

  void selectPanel(Key key) {
    if(panelsMap.containsKey(key)) {
      setState(() {
        var window = panelsMap.remove(key);
        currentPanels = panelsMap.values.toList();
        panelsMap[key] = window!;
        currentPanels.add(window);
      });
    }
  }

  void removePanel(Key key) {
    if(panelsMap.containsKey(key)) {
      setState(() {
        panelsMap.remove(key);
        currentPanels = panelsMap.values.toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Panels(
      addPanel: addPanel,
      removePanel: removePanel,
      selectPanel: selectPanel,
      child: Stack(
        children: currentPanels,
      ),
    );
  }
}

class PanelWrapper extends StatefulWidget {
  final Key key;
  final List<Widget> children;
  final List<String?> titles;
  final Size size;

  PanelWrapper({
    required this.key,
    required this.children,
    this.size = const Size(500, 500),
    this.titles = const []
  }) : assert(titles.length == children.length), super(key: key);

  @override
  _PanelWrapperState createState() => _PanelWrapperState();
}

class _PanelWrapperState extends State<PanelWrapper> with SingleTickerProviderStateMixin{

  late Size size;
  late Offset position = Offset(0, 0);
  bool dragged = false;
  int currentChildIndex = 0;
  late TabController tabController;

  Size setSizeGetDelta(double width, double height) {
    var newSize = Size(max(100, width), max(100, height));
    var delta = Size(size.width - newSize.width, size.height - newSize.height);
    size = newSize;
    return delta;
  }

  void resizeUp(Offset requestedDelta) {
    setState(() {
      var d = setSizeGetDelta(size.width, size.height - requestedDelta.dy);
      position += Offset(0.0, d.height);
    });
  }

  void resizeDown(Offset requestedDelta) {
    setState(() {
      setSizeGetDelta(size.width, size.height + requestedDelta.dy);
    });
  }

  void resizeLeft(Offset requestedDelta) {
    setState(() {
      var d = setSizeGetDelta(size.width - requestedDelta.dx, size.height);
      position += Offset(d.width, 0.0);
    });
  }

  void resizeRight(Offset requestedDelta) {
    setState(() {
      setSizeGetDelta(size.width + requestedDelta.dx, size.height);
    });
  }

  @override
  void initState() {
    size = widget.size;
    tabController = TabController(
      length: widget.children.length,
      vsync: this
    );
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var debug = false;
    var random = Random(1337);
    var debugColors = List.generate(10, (index) {
      if(debug) {
        return Color.fromRGBO(random.nextInt(255), random.nextInt(255), random.nextInt(255), 1.0/(index + 1).toDouble());
      }

      return Colors.transparent;
    });

    var resizeBorderWidth = 6.0;
    var resizeCornerWidth = 8.0;
    var i = -1;
    var tabList = widget.children.map((e) {
      i++;
      return AnimatedContainer(
        duration: Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
        constraints: i == tabController.index ?
        BoxConstraints(
          maxWidth: 1000
        ) :
        BoxConstraints(
          maxWidth: 80
        ),
        child: Text(
          widget.titles[i] ?? "Panel",
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyText1,
        ),
      );
    }).toList();

    var index = -1;

    var centralListener = Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) => Panels.of(context).selectPanel(widget.key),
      child: Container(

        // * Window
        child: Column(
          children: [

            // * Draggable Top-bar
            Container(
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
                    if(dragged) position += event.delta;
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
                                maxWidth: max(size.width/1.64, 10),
                              ),
                              child: Container(
                                margin: EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Theme.of(context).textTheme.bodyText1?.color?.withOpacity(0.1) ?? Colors.black)
                                ),
                                child: TabBar(
                                  indicatorColor: Theme.of(context).textTheme.bodyText1?.color,

                                  indicatorSize: TabBarIndicatorSize.label,
                                  dragStartBehavior: DragStartBehavior.down,
                                  isScrollable: true,
                                  controller: tabController,
                                  labelPadding: EdgeInsets.symmetric(horizontal: 10),
                                  tabs: tabList,
                                ),
                              )
                            )
                            : Container()
                        ),

                        PopupMenuButton<String>(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                          tooltip: "Context Menu",
                          child: Center(
                            child: Icon(Icons.more_vert, size: 19.0),
                          ),
                          initialValue: widget.titles[tabController.index],
                          onSelected: (String value) {
                            tabController.animateTo(widget.titles.indexOf(value));
                          },
                          itemBuilder: (context) {
                            return widget.titles.map((String? title) {
                              return PopupMenuItem<String>(
                                height: 10.0,
                                // enabled: title != widget.titles[tabController.index],
                                value: title ?? "Panel",
                                child: Text(title ?? "Panel"),
                              );
                            }).toList();
                          },
                        ),


                        Spacer(flex: 1),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              margin: EdgeInsets.all(5),
                              child: ClipOval(
                                child: Material(
                                  color: Theme.of(context).errorColor,
                                  shape: CircleBorder(),
                                  child: InkWell(
                                    onTap: () => Panels.of(context).removePanel(widget.key),
                                    child: Container(
                                      padding: EdgeInsets.all(3),
                                      child: Center(
                                        child: Icon(Icons.close, size: 9.0, color: Colors.white,),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // * Content
            Expanded(
              child: TabBarView(
                controller: tabController,
                physics: BouncingScrollPhysics(),
                children: widget.children,
              )
            )
          ],
        )
      ),
    );

    var sideListeners = Column(
      children: [
        Row(
          children: [
            // * Resize Top Left
            Container(
              width: resizeCornerWidth,
              height: resizeCornerWidth,
              color: debugColors[2],
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
                height: resizeBorderWidth,
                color: debugColors[6],
                child: MouseRegion(
                  opaque: false,
                  cursor: SystemMouseCursors.resizeUpDown,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onVerticalDragUpdate: (event) => resizeUp(event.delta),
                    onVerticalDragStart: (event) => Panels.of(context).selectPanel(widget.key),
                  ),
                ),
              ),
            ),

            // * Resize Top Right
            Container(
              width: resizeCornerWidth,
              height: resizeCornerWidth,
              color: debugColors[2],
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
                width: resizeBorderWidth,
                color: debugColors[5],
                child: MouseRegion(
                  opaque: false,
                  cursor: SystemMouseCursors.resizeLeftRight,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
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
                width: resizeBorderWidth,
                color: debugColors[5],
                child: MouseRegion(
                  opaque: false,
                  cursor: SystemMouseCursors.resizeLeftRight,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
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
              width: resizeCornerWidth,
              height: resizeCornerWidth,
              color: debugColors[2],
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
                height: resizeBorderWidth,
                color: debugColors[6],
                child: MouseRegion(
                  opaque: false,
                  cursor: SystemMouseCursors.resizeUpDown,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onVerticalDragUpdate: (event) => resizeDown(event.delta),
                    onVerticalDragStart: (event) => Panels.of(context).selectPanel(widget.key),
                  ),
                ),
              ),
            ),

            // * Resize Bottom Right
            Container(
              width: resizeCornerWidth,
              height: resizeCornerWidth,
              color: debugColors[2],
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
                padding: EdgeInsets.all(resizeBorderWidth),
                child: Material(
                  elevation: dragged ? 5.0 : 2.0,
                  child: Container(
                    color: debugColors[9],

                    // * Central Select Listener
                    child: centralListener
                  )
                ),
              )
            ),

            sideListeners
          ],
        ),
      ),
    );
  }
}

