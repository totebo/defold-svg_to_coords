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
--local cached_xml_files = {}
local all_cached_coordinates = {}


function M:read( xml_filename )


	--[[
	local cached_xml_file = cached_xml_files[xml_filename]
	if cached_xml_file then
		parser = cached_xml_file
	else
		parser = M:loadXml( xml_filename )
	end
	--]]
	local coordinates
	local cached_coordinates = all_cached_coordinates[xml_filename]
	
	if cached_coordinates then
		
		coordinates = cached_coordinates
		
	else

		--local parser = M:loadXml( xml_filename )

		-- Read xml
		local handler = tree:new()
		local parser = xml2lua.parser(handler)
		local xml_file = sys.load_resource(xml_filename)
		parser:parse( xml_file )

				
		--local svg_data_raw = parser.handler.root.svg.g.g.polygon._attr.points
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
		coordinates = {}

		for i=1, #svg_data do
			local coord = tonumber(svg_data[i])
			if i%2~=0 then
				coord = offset_x + coord - width/2
			else
				coord = -offset_y - coord + height/2
			end
			insert( coordinates, coord )
		end

		all_cached_coordinates[xml_filename] = coordinates

	end

	return coordinates

end


return M
