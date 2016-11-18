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

return {
	Report = function(unitTest)
		local report = Report()
		unitTest:assertType(report, "Report")
		unitTest:assertNil(report.title)
		unitTest:assertEquals(getn(report.text), 0)
		unitTest:assertEquals(getn(report.image), 0)

		local image = packageInfo("publish").path.."images/urbis_2010_real.PNG"
		report = Report{
			title = "My Report",
			text = "Some text",
			image = image
		}

		unitTest:assertType(report, "Report")
		unitTest:assertEquals(report.title, "My Report")
		unitTest:assertEquals(tostring(report.image[1]), image)
		unitTest:assertEquals(report.text[2], "Some text")
		unitTest:assertEquals(report.nextIdx_, 3)

		report.image["fake"] = nil
		unitTest:assertEquals(report.nextIdx_, 3)
	end,
	addImage = function(unitTest)
		local report = Report()

		unitTest:assertType(report, "Report")
		unitTest:assertNil(report.title)
		unitTest:assertEquals(getn(report.text), 0)
		unitTest:assertEquals(getn(report.image), 0)

		report:addImage("urbis_2010_real.PNG", "publish")

		unitTest:assertNil(report.title)
		unitTest:assertEquals(getn(report.text), 0)
		unitTest:assertEquals(getn(report.image), 1)
		unitTest:assertEquals(tostring(report.image[1]), packageInfo("publish").path.."images/urbis_2010_real.PNG")
	end,
	addSeparator = function(unitTest)
		local report = Report()

		unitTest:assertType(report, "Report")
		unitTest:assertNil(report.title)
		unitTest:assertEquals(getn(report.text), 0)
		unitTest:assertEquals(getn(report.image), 0)
		unitTest:assertEquals(getn(report.separator), 0)

		report:addSeparator()

		unitTest:assertEquals(getn(report.separator), 1)
		unitTest:assertEquals(report.separator[1], true)

		report:addText("My text 1")
		report:addText("My text 2")
		report:addSeparator()

		unitTest:assertEquals(getn(report.separator), 2)
		unitTest:assertEquals(getn(report.text), 2)
		unitTest:assertEquals(report.separator[1], true)
		unitTest:assertEquals(report.separator[4], true)
	end,
	addText = function(unitTest)
		local report = Report()
		local text = "This is the main endogenous variable of the model."

		unitTest:assertType(report, "Report")
		unitTest:assertNil(report.title)
		unitTest:assertEquals(getn(report.text), 0)
		unitTest:assertEquals(getn(report.image), 0)

		report:addText(text)

		unitTest:assertEquals(getn(report.text), 1)
		unitTest:assertEquals(getn(report.image), 0)
		unitTest:assertEquals(report.text[1], text)
	end,
	get = function(unitTest)
		local report = Report()

		unitTest:assertType(report, "Report")
		unitTest:assertNil(report.title)
		unitTest:assertEquals(getn(report.text), 0)
		unitTest:assertEquals(getn(report.image), 0)
		unitTest:assertEquals(getn(report.separator), 0)

		local template = report:get()
		unitTest:assertType(template, "table")
		unitTest:assertEquals(getn(template), 0)

		report:setTitle("Social Classes 2010")
		report:addSeparator()
		report:addImage("urbis_2010_real.PNG", "publish")
		report:addText("This is the main endogenous variable of the model.")
		report:addText("It was obtained from a classification that categorizes the social conditions of households in Caraguatatuba on 'condition A' (best), 'B' or 'C''.")

		unitTest:assertEquals(report.title, "Social Classes 2010")
		unitTest:assertEquals(report.separator[1], true)
		unitTest:assertEquals(tostring(report.image[2]), packageInfo("publish").path.."images/urbis_2010_real.PNG")
		unitTest:assertEquals(report.text[3], "This is the main endogenous variable of the model.")
		unitTest:assertEquals(report.text[4], "It was obtained from a classification that categorizes the social conditions of households in Caraguatatuba on 'condition A' (best), 'B' or 'C''.")

		template = report:get()
		unitTest:assertType(template, "table")
		unitTest:assertEquals(getn(template), 4)

		unitTest:assertNil(template[1].text)
		unitTest:assertNotNil(template[1].separator)
		unitTest:assertNil(template[1].image)

		unitTest:assertNil(template[2].text)
		unitTest:assertNil(template[2].separator)
		unitTest:assertNotNil(template[2].image)

		unitTest:assertNotNil(template[3].text)
		unitTest:assertNil(template[3].separator)
		unitTest:assertNil(template[3].image)

		unitTest:assertNotNil(template[4].text)
		unitTest:assertNil(template[4].separator)
		unitTest:assertNil(template[4].image)
	end,
	setTitle = function(unitTest)
		local report = Report()

		unitTest:assertType(report, "Report")
		unitTest:assertNil(report.title)
		unitTest:assertEquals(getn(report.text), 0)

		report:setTitle("My title")

		unitTest:assertEquals(getn(report.text), 0)
		unitTest:assertEquals(report.title, "My title")
	end,
	__tostring = function(unitTest)
		local report = Report{
			title = "My Report",
			text = "Some text",
			image = packageInfo("publish").path.."images/urbis_2010_real.PNG"
		}

		unitTest:assertType(report, "Report")
		unitTest:assertEquals(tostring(report), [[image      vector of size 1
nextIdx_   number [3]
separator  vector of size 0
text       named table of size 1
title      string [My Report]
]])
	end
}
