-- @example Implementation of a simple emas application. It uses the data from a tview file (terralib/emas.tview).
-- There is a layout with the web page properties.
-- Each polygon is drawn using the attribute 'select'.

import("publish")

local layout = Layout{
	title = "Emas",
	description = "Creates a database that can be used by the example fire-spread of base package.",
	base = "satellite",
	zoom = 10,
	center = {lat = -18.106389, long = -52.927778}
}

Application{
	project = filePath("emas.tview", "terralib"),
	layout = layout,
	clean = true,
	select = "river",
	color = "BuGn",
	value = {0, 1, 2},
	output = Directory("EmasWebMap")
}
