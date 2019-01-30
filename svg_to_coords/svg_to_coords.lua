local M = {}

local insert = table.insert

local function split(s, delimiter)
	local result = {}
	for match in (s..delimiter):gmatch("(.-)"..delimiter) do
		insert(result, match)
	end
	return result
end

local function stripchars(str, chrs)
	local s = str:gsub("["..chrs:gsub("%W","%%%1").."]", '')
	return s
end

local xml2lua = require "svg_to_coords.xml2lua"
local tree = require("svg_to_coords.xmlhandler.tree")
local handler = {}

function M:read( xml_filename, position )

	if position == nil then
		position = vmath.vector3(0,0,0)
	end

	-- Read xml
	local handler = tree:new()
	local parser = xml2lua.parser(handler)
	local xml_file = sys.load_resource(xml_filename)
	parser:parse(xml_file)

	-- Read svg data
	local svg_data_raw = parser.handler.root.svg.g.g.polyline._attr.points
	local svg_data = split(svg_data_raw," " )

	local width = parser.handler.root.svg._attr.width:gsub('px', '')
	local height = parser.handler.root.svg._attr.height:gsub('px', '')
	local origin = parser.handler.root.svg.g.g._attr.transform

	-- Extract shape offset
	local origin = stripchars(origin, "translate()")
	local xy = split(origin,"," )
	local offset_x = tonumber(xy[1])
	local offset_y = tonumber(xy[2])

	-- Create coordinate table (with polyline)
	local coordinates = {}

	for i=1, #svg_data do
		local coord = tonumber(svg_data[i])
		if i%2~=0 then
			coord = position.x + offset_x + coord - width/2
		else
			coord = position.y - offset_y - coord + height/2
		end
		insert( coordinates, coord )
	end

	return coordinates

end

return M
