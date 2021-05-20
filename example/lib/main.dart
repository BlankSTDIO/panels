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
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.purpleAccent
      ),
      home: Example(),
    );
  }
}


class Example extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PanelsTheme(
        data: FrostedPanelsThemeData(), // PanelsThemeData()
        child: PanelsManager(
          children: [
            MyCustomWidget()
          ]
        ),
      ),
    );
  }
}

class MyCustomWidget extends StatelessWidget {
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
              child: Center(
                child: MaterialButton(
                  color: Theme.of(context).primaryColor,
                  onPressed: () {
                    Panels.of(context).addPanel(
                      widget: MyCustomWidget(),
                      title: "Opened From MyCustomWidget()"
                    );
                  },
                  child: Text("Test"),
                ),
              ),
            )
          ],
        ),
      )
    );
  }
}

