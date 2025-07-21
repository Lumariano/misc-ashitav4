# autohide
This addon will automatically hide font objects, primitive objects and any ImGui windows drawn by Ashita when:
* Your chat is expanded
* Any event is active (e.g. a cutscene or a NPC interaction)
* Your interface is hidden (i.e. hidden by yourself using the "Hide Menus" controller bind for example)
* You're zoning

It will also hide these elements when certain menus are active. By default those are:
* Your normal map
* Your conquest map
* Your scanlist

Which elements are hidden during each state/active menu can be configured.

## Usage
* `/autohide config`: Toggles the visibility of the config window
* `/autohide getmenu`: Get the name of the currently active menu

## Credits
* Thorny for the hidden interface and active event checks as well as determining the currently active menu.
* onimitch for the expanded chat check.
