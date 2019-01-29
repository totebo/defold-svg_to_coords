local M = {}

local insert = table.insert

local function load_file( filename )

	local str
	local file = io.open(filename, "rb")

	if file then
		str = file:read("*all")
		file:close()
	end

	return str

end

--[[
local function parsePath(input)
	-- Nabbed from: https://stackoverflow.com/questions/16863540/parse-svg-path-definition-d-in-lua
	local out = {};

	for instr, vals in input:gmatch("([a-df-zA-DF-Z])([^a-df-zA-DF-Z]*)") do
		local line = { instr };
		for v in vals:gmatch("([+-]?[%deE.]+)") do
			line[#line+1] = v;
		end
		out[#out+1] = line;
	end
	return out;
end
--]]

local function split(s, delimiter)
	result = {};
	for match in (s..delimiter):gmatch("(.-)"..delimiter) do
		table.insert(result, match);
	end
	return result;
end

local function stripchars(str, chrs)
	local s = str:gsub("["..chrs:gsub("%W","%%%1").."]", '')
	return s
end

local xml2lua = require "svg_to_coords.xml2lua"
local handler = require("svg_to_coords.xmlhandler.tree")

function M:read( xml_filename )

	-- Read xml
	local xml = load_file( xml_filename )
	local parser = xml2lua.parser(handler)
	parser:parse(xml)

	-- Read svg data
	--local svg_data_raw = parser.handler.root.svg.g.g.polygon._attr.points
	--local svg_data_raw = parser.handler.root.svg.g.g.path._attr.d	
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
	local position = go.get_position( "go" )	
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