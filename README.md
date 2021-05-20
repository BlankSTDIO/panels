#### Warning: Beta
## Panels
![Pub Version (including pre-releases)](https://img.shields.io/pub/v/panels?include_prereleases&style=flat-square)

Panels is a flutter package that aims to provide a set of useful desktop UI panels that can move around, dock and tab like we expect in more robust desktop applications.

## Features
- [x] Draggable Panels
- [x] Resizable Panels
- [x] Correct Mosue Cursor
- [x] Tabs in Panels
- [ ] Make all Panels dockable into each other
- [ ] Custom panel themes
  - [x] Customizable close button
  - [x] Customizable context menu
  - [ ] Customizable tabs
  - [x] Customizable frame
  - [ ] Customizable top bar

## Demo

![ezgif com-gif-maker](https://user-images.githubusercontent.com/19771356/118943560-08258480-b954-11eb-86bf-8e3c8c6277dd.gif)

## Default Theme
| ThemeData.light() | ThemeData.dark() |
|:-----------------:|:----------------:|
|![image](https://user-images.githubusercontent.com/19771356/118945284-9bab8500-b955-11eb-82dd-4759929317d3.png)|![image](https://user-images.githubusercontent.com/19771356/118945533-d3b2c800-b955-11eb-803e-34acb6b93baf.png)|

## FrostedPanelsTheme
| ThemeData.light() | ThemeData.dark() |
|:-----------------:|:----------------:|
|![image](https://user-images.githubusercontent.com/19771356/118982039-50a46880-b97b-11eb-8f8e-f753fe7c1224.png)|![image](https://user-images.githubusercontent.com/19771356/118981945-366a8a80-b97b-11eb-9fee-043f2b534d91.png)|
## Under the hood
There are 10 Mouse Regions and listeners (All sides and corners + The big one in the middle + the draggable) that change the look of the mouse according to their function. Windows can be clicked on in any of these regions to become selected (put on top).

![ezgif com-gif-maker (1)](https://user-images.githubusercontent.com/19771356/118943590-0eb3fc00-b954-11eb-9a5f-50dc9f5fbc3d.gif)

There is an InheritedWidget called `Panels` which is created by a StatefulWidget called `PanelsManager`.
The children of the panels manager are put into a stack. To add Panels/Windows one can simply do `Panels.of(context).addPanel(widget: Widget, title: "Title of Panel");` to create one from any Widget from anywhere in a context that is a decendant of the `PanelsManager` (`Panels`).

Please see the `examples` directory for an example.

