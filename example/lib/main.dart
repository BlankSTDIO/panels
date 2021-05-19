import 'package:flutter/material.dart';
import 'package:panels/panels.dart';

void main() {
  runApp(ExampleApplication());
}


class ExampleApplication extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.red
      ),
      home: Example(),
    );
  }
}


class Example extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PanelsManager(
        children: [
          MyCustomWidget()
        ]
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
                  color: Colors.black54,
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

