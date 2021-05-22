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
        data: PanelsThemeData(), // FrostedPanelsThemeData()
        child: PanelsManager(children: [MyCustomWidget()]),
      ),
    );
  }
}


class MyCustomWidget extends StatefulWidget {
  @override
  _MyCustomWidgetState createState() => _MyCustomWidgetState();
}

class _MyCustomWidgetState extends State<MyCustomWidget> {
  int windowsOpened = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Center(
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Text("My Custom Widget"),
            ),
          ),

          Expanded(
            child: Text("This widget has opened $windowsOpened windows."),
          ),

          Expanded(
            child: Center(
              child: MaterialButton(
                color: Theme.of(context).primaryColor,
                onPressed: () {
                  Panels.of(context).addPanel(widget: MyCustomWidget(), title: "Opened From MyCustomWidget()");
                  setState(() {
                    windowsOpened++;
                  });
                },
                child: Text("Open New Window"),
              ),
            ),
          )
        ],
      ),
    ));
  }
}
