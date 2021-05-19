library panels;

import 'dart:math';

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
    for(int i = 0; i < 10; i++) {
      addPanel(
        widget: Center(
          child: Text("Panel $i!"),
        ),
        title: "Panel $i"
      );
    }
  }

  void addPanel({
    required Widget widget,
    String? title
  }) {
    print("Adding new panel: '$title'");
    var key = GlobalKey();

    setState(() {
      var newPanel = PanelWrapper(
        key: key,
        title: title,
        children: [widget, widget, widget]
      );

      panelsMap[key] = newPanel;
      currentPanels = panelsMap.values.toList();
    });
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
  final String? title;
  final Size size;

  PanelWrapper({
    required this.key,
    required this.children,
    this.size = const Size(500, 500),
    this.title
  }) : super(key: key);

  @override
  _PanelWrapperState createState() => _PanelWrapperState();
}

class _PanelWrapperState extends State<PanelWrapper> {

  late Size size;
  late Offset position = Offset(0, 0);
  bool dragged = false;
  int currentChildIndex = 0;

  Size setSizeGetDelta(double width, double height) {
    var newSize = Size(min(max(100, width), 1000), min(max(100, height), 1000));
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
    super.initState();
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
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: (event) => setState(() {
                    dragged = true;
                    Panels.of(context).selectPanel(widget.key);
                  }),
                  onPointerUp: (event) => setState(() {
                    dragged = false;
                  }),
                  onPointerMove: (event) => setState(() {
                    position += event.delta;
                  }),
                  child: Container(
                    height: 30,
                    color: Colors.green,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 20,
                          child: ListView(
                            physics: NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            children: widget.children.map((element) {
                              return Container(
                                margin: EdgeInsets.symmetric(horizontal: 1),
                                child: Material(
                                  color: Theme.of(context).canvasColor.withOpacity(0.3),
                                  child: InkWell(
                                    onTap: () {},
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 4),
                                      child: Row(
                                        children: [
                                          Text(widget.title ?? "Panel"),
                                          Icon(Icons.more_vert, size: 16)
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList()
                          ),
                        ),
                        Spacer(flex: 1),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              margin: EdgeInsets.all(3),
                              child: ClipOval(
                                child: Material(
                                  color: Theme.of(context).errorColor,
                                  shape: CircleBorder(),
                                  child: InkWell(
                                    onTap: () => Panels.of(context).removePanel(widget.key),
                                    child: Container(
                                      padding: EdgeInsets.all(2),
                                      child: Center(
                                        child: Icon(Icons.close, size: 9.0,),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // * Content
            Expanded(
              child: widget.children[currentChildIndex]
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

