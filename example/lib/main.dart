import 'package:flutter/material.dart';
import 'package:panels/panels.dart';
import 'package:panels/themes.dart';

void main() {
  runApp(ExampleApplication());
}

class ExampleApplication extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(primaryColor: Colors.purpleAccent),
      home: Example(),
    );
  }
}

class Example extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PanelsTheme(
        data: FrostedPanelsThemeData(), // FrostedPanelsThemeData() // PanelsThemeData()
        child: PanelsManager(
          children: [MyCustomWidget()],
          initialPanels: [],
          childrenOnTop: [
            Row(
              children: [
                Material(
                  color: Theme.of(context).primaryColor,
                  child: Text("I'm on top of all panels!!!"),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}


class MyCustomWidget extends StatefulWidget {
  // GlobalKey is used here in order to preserve state when moved around in the widget tree
  MyCustomWidget() : super(key: GlobalKey());

  @override
  _MyCustomWidgetState createState() => _MyCustomWidgetState();
}

class _MyCustomWidgetState extends State<MyCustomWidget> {
  int panelsOpened = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Center(
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Text("My Custom Widget", textAlign: TextAlign.center,),
            ),
          ),

          Expanded(
            child: Text("This widget has opened $panelsOpened panels.", textAlign: TextAlign.center),
          ),

          Expanded(
            child: Center(
              child: MaterialButton(
                color: Theme.of(context).primaryColor,
                onPressed: () {
                  Panels.of(context).addPanel(
                    Panel(
                      initialTabs: [
                        PanelTab(
                          child: MyCustomWidget(),
                          title: "Opened From MyCustomWidget()"
                        )
                      ],
                    )
                  );
                  setState(() {
                    panelsOpened++;
                  });
                },
                child: Text("Open New Panel", textAlign: TextAlign.center),
              ),
            ),
          )
        ],
      ),
    ));
  }
}
