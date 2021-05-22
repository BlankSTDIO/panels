# Changelog

All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)

## [UNRELEASED]



## [0.0.3] 2021-05-20
### Changed
- Formatting
- Flutter 2.2 upgrade in pubspec file


## [0.0.2] 2021-05-20
### Added
- `PanelsTheme`: An InheritedWidget containing builder functions to decide the look of panel components.
- `Panels.of(context).addPanelWithTabs`: A method to create panels with initial tabs. Usage: `Panels.of(context).addPanel({ required List<Widget> widgets, required List<String?> titles })`
- `FrostedPanelsTheme`: A new PanelsTheme utilizing a blurring ImageFilter on the panels background to demo the capabilities of the theming system.

### Changed
- `PanelsManager` will now take the PanelsTheme into account before building panels.
- The tabs context menu and the close button are now builders inside the default PanelsTheme
- Added a `selected` check to Panels so that only the Panel currently selected can be resized.


## [0.0.1] - 2021-05-20
### Added
- `PanelsManager`: The base Widget to add, remove and select Panels.
- `Panels`: An InheritedWidget with which Panels can be added. Usage: `Panels.of(context).addPanel({ required Widget widget, String? title})`
- `Panel`: A StateFul widget which is created and managed by the PanelsManager. Shouldn't currently really be used in other contexts.
- Example utilizing Panels
- README
- LICENSE
- This CHANGELOG
- AUTHORS
- FUNDING.yml
