-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2016 INPE and TerraLAB/UFOP -- www.terrame.org

-- This code is part of the TerraME framework.
-- This framework is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.

-- You should have received a copy of the GNU Lesser General Public
-- License along with this library.

-- The authors reassure the license terms regarding the warranties.
-- They specifically disclaim any warranties, including, but not limited to,
-- the implied warranties of merchantability and fitness for a particular purpose.
-- The framework provided hereunder is on an "as is" basis, and the authors have no
-- obligation to provide maintenance, support, updates, enhancements, or modifications.
-- In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
-- indirect, special, incidental, or consequential damages arising out of the use
-- of this software and its documentation.
--
-------------------------------------------------------------------------------------------

View_ = {
	type_ = "View"
}

metaTableView_ = {
	__index = View_,
	__tostring = _Gtme.tostring
}

--- View is an object that contains the information of the data to be visualized.
-- One Application is composed by a set of Views.
-- @arg data.select An optional string with the name of the attribute to be visualized.
-- @arg data.value An optional table with the possible values for the selected attributes. This argument is mandatory when using color.
-- @arg data.visible An optional boolean whether the layer is visible. Defaults to false.
-- @arg data.width An optional argument with the stroke width in pixels.
-- @arg data.transparency An optional argument with the opacity of color attribute. The transparency parameter is a number between 0.0 (fully opaque) and 1.0 (fully transparent).
-- The default value is 0.
-- @arg data.border An optional string or table with the stroke color. Colors can be described as strings using
-- a color name, an RGB value (Ex. {0, 0, 0}), or a HEX value (see https://www.w3.org/wiki/CSS/Properties/color/keywords).
-- @arg data.color An optional table with the colors for the attributes. Colors can be described as strings using
-- a color name, an RGB value, a HEX value, or even as a string with a ColorBrewer format (see http://www.colorbrewer2.org).
-- The available color names are:
-- <br><img src="../../lib/color_keyword_names.svg" alt="Color keywords name"> <br>
-- These colors are defined by www.w3.org (see https://www.w3.org/TR/SVG/types.html#ColorKeywords).
-- The colors available in ColorBrewer format and the maximum number of slices for each of them are:
-- @tabular color
-- Name & Max \
-- Accent, Dark, Set2 & 7 \
-- Pastel2, Set1 & 8 \
-- Pastel1 & 9 \
-- PRGn, RdYlGn, Spectral & 10 \
-- BrBG, Paired, PiYG, PuOr, RdBu, RdGy, RdYlBu, Set3 & 11 \
-- BuGn, BuPu, OrRd, PuBu & 19 \
-- Blues, GnBu, Greens, Greys, Oranges, PuBuGn, PuRd, Purples, RdPu, Reds, YlGn, YlGnBu, YlOrBr, YlOrRd & 20 \
-- @arg data.label An optional table of strings that describes the labels to be shown in the Legend.
-- @arg data.icon An optional table or string. A table with the icon properties, such as path, color and transparency. The property path
-- uses SVG notation (see https://www.w3.org/TR/SVG/paths.html). A string with the name of marker icon. The markers available are:
-- "airport", "animal", "bigcity", "bus", "car", "caution", "cycling", "database", "desert", "diving", "fillingstation", "finish", "fire", "firstaid", "fishing",
-- "flag", "forest", "harbor", "helicopter", "home", "horseriding", "hospital", "lake", "motorbike", "mountains", "radio", "restaurant", "river", "road",
--"shipwreck" and "thunderstorm".
-- @arg data.report An optional Report or user-defined function that creates a report for each spatial object of that view.
-- @arg data.download An optional boolean to allow its data to be downloaded from a link available in the created web page. Default value is false.
-- @usage import("publish")
--
-- local view = View{
--     title = "Emas National Park",
--     description = "A small example related to a fire spread model.",
--     border = "blue",
--     width = 2,
--     color = "PuBu",
--     select = "river",
--     value = {0, 1, 2}
-- }
--
-- print(vardump(view))
function View(data)
	verifyNamedTable(data)
	optionalTableArgument(data, "title", "string")
	optionalTableArgument(data, "description", "string")
	optionalTableArgument(data, "value", "table")
	optionalTableArgument(data, "select", {"string", "table"})
	optionalTableArgument(data, "label", "table")
	optionalTableArgument(data, "report", {"Report", "function"})
	optionalTableArgument(data, "icon", {"string", "table"})

	defaultTableValue(data, "width", 1)
	defaultTableValue(data, "transparency", 0)
	defaultTableValue(data, "visible", true)
	defaultTableValue(data, "download", false)

	verifyUnnecessaryArguments(data, {"title", "description", "border", "width", "color", "visible", "select",
		"value", "layer", "report", "transparency", "label", "icon", "download", "group"})

	if data.report and type(data.report) == "function" then
		mandatoryTableArgument(data, "select")

		if data.select and type(data.select) == "table" then -- TODO TerraME/terrame#1644
			if data.color or data.icon then
				if #data.select ~= 2 then
					customError("Argument 'select' must be a table with size equals to 2, got "..#data.select..".")
				end
			end
		end
	end

	if data.transparency < 0 or data.transparency > 1 then
		customError("Argument 'transparency' should be a number between 0.0 (fully opaque) and 1.0 (fully transparent), got "..data.transparency..".")
	end

	if data.color then
		verifyUnnecessaryArguments(data, {"title", "description", "border", "width", "color", "visible", "select",
			"value", "layer", "report", "transparency", "label", "download", "group"})

		local realTransparency = 1 - data.transparency
		if data.value then
			mandatoryTableArgument(data, "select", "string")

			local classes = #data.value
			if classes == 0 then
				customError("Argument 'value' must be a table with size greater than 0, got "..classes..".")
			end

			local mcolor
			if type(data.color) == "string" then
				mcolor = color{color = data.color, classes = classes, alpha = realTransparency}
			else
				mcolor = color{color = data.color, alpha = realTransparency}
			end

			local nColors = #mcolor
			if classes ~= nColors then
				customError("The number of colors ("..nColors..") must be equal to number of data classes ("..classes..").")
			end

			local colors = {}
			for i = 1, classes do
				colors[tostring(data.value[i])] = mcolor[i]
			end

			local label = {}
			if data.label then
				local labels = #data.label
				if labels == 0 then
					customError("Argument 'label' must be a table of strings with size greater than 0, got "..labels..".")
				end

				if classes ~= labels then
					customError("The number of labels ("..labels..") must be equal to number of data classes ("..classes..").")
				end

				forEachElement(data.label, function(k, v, mtype)
					if mtype ~= "string" then
						customError("Argument 'label' must be a table of strings, element "..k.." ("..tostring(v)..") got "..mtype..".")
					end
				end)

				local i = 1
				forEachOrderedElement(colors, function(_, color)
					label[data.label[i]] = tostring(color)
					i = i + 1
				end)
			else
				forEachElement(colors, function(value, color)
					label[data.select.. " "..value] = tostring(color)
				end)
			end

			data.color = colors
			data.label = label
		else
			if data.select then
				local brewerNames = {"Accent", "Blues", "BrBG", "BuGn", "BuPu", "Dark", "GnBu", "Greens", "Greys", "OrRd",
					"Oranges", "PRGn", "Paired", "Pastel1", "Pastel2", "PiYG", "PuBu", "PuBuGn", "PuOr", "PuRd", "Purples",
					"RdBu", "RdGy", "RdPu", "RdYlBu", "RdYlGn", "Reds", "Set1", "Set2", "Set3", "Spectral", "YlGn", "YlGnBu",
					"YlOrBr", "YlOrRd" }

				local isColorBrewer = type(data.color) == "string" and belong(data.color, brewerNames)
				local isTableColors = type(data.color) == "table" and #data.color > 1 and (type(data.color[1]) == "string" or type(data.color[1]) == "table")

				if not (isColorBrewer or isTableColors) then
					data.color = color{color = data.color, alpha = realTransparency}
				end
			else
				data.color = color{color = data.color, alpha = realTransparency}
			end
		end
	end

	if data.border then
		data.border = color{border = data.border}
	end

	if data.layer then
		if type(data.layer) == "string" then
			data.layer = File(data.layer)
		end

		mandatoryTableArgument(data, "layer", "File")
	end

	if data.icon then
		local itype = type(data.icon)
		if itype == "string" then
			if data.icon:find(".*[MLHVCSQTAZmlhvcsqtaz].*") and data.icon:find("[0-9]") then
				data.icon = {path = data.icon}
				itype = "table"
			else
				local ics = {
					airport = true,
					animal = true,
					bigcity = true,
					bus = true,
					car = true,
					caution = true,
					cycling = true,
					database = true,
					desert = true,
					diving = true,
					fillingstation = true,
					finish = true,
					fire = true,
					firstaid = true,
					fishing = true,
					flag = true,
					forest = true,
					harbor = true,
					helicopter = true,
					home = true,
					horseriding = true,
					hospital = true,
					lake = true,
					motorbike = true,
					mountains = true,
					radio = true,
					restaurant = true,
					river = true,
					road = true,
					shipwreck = true,
					thunderstorm = true
				}

				if not ics[data.icon] then
					switchInvalidArgument("icon", data.icon, ics)
				end
			end
		end

		if itype == "table" then
			if #data.icon > 0 then
				mandatoryTableArgument(data, "select")
				verifyUnnecessaryArguments(data, {"title", "description", "width", "visible", "select", "layer", "report",
					"transparency", "label", "icon", "download", "group"})

				if data.label and (#data.icon ~= #data.label)then
					customError("The number of icons ("..#data.icon..") must be equal to number of labels ("..#data.label..").")
				end
			else
				mandatoryTableArgument(data.icon, "path", "string")
				defaultTableValue(data.icon, "time", 5)
				defaultTableValue(data.icon, "color", "black")
				defaultTableValue(data.icon, "transparency", 0)

				verifyUnnecessaryArguments(data.icon, {"path", "color", "transparency", "time"})

				if not (data.icon.path:find(".*[MLHVCSQTAZmlhvcsqtaz].*") and data.icon.path:find("[0-9]")) then
					customError("The icon path '"..data.icon.path.."' contains no valid commands. The following commands are available for path: M, L, H, V, C, S, Q, T, A, Z")
				end

				if data.icon.transparency < 0 or data.icon.transparency > 1 then
					customError("The icon transparency is a number between 0.0 (fully opaque) and 1.0 (fully transparent), got "..data.icon.transparency..".")
				end

				data.icon.color = color{color = data.icon.color}

				if data.icon.time <= 0 then
					customError("Argument 'time' of icon must be a number greater than 0, got "..data.icon.time..".")
				end
			end
		end
	end

	setmetatable(data, metaTableView_)
	return data
end
