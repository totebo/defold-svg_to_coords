# Defold Svg to Coordinates
Reads and returns coordinates of one SVG shape.

# Installation
You can use Defold States in your own project by adding this project as a [Defold library dependency](http://www.defold.com/manuals/libraries/). Open your game.project file and in the dependencies field under project add:

    https://github.com/totebo/defold-svg_to_coords/archive/master.zip

Or point to the ZIP file of a [specific release](https://github.com/totebo/defold-svg_to_coords/releases).


## Example

      local svg_to_coords = require "svg_to_coords.svg_to_coords"
      local coordinates = svg_to_coords:read( "main/shape.svg" )
