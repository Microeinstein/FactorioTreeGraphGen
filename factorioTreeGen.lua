--Factorio tree graph generator
--by Microeinstein

--[[
Personal factorio notes:
	- For recipes:
		If there are "normal" and "expensive",
			choose the right one,
		else
			choose base table;
	- For technologies:
		Multiply by price multiplier;
		Difficulty doesn't have any effect in vanilla;
]]--

local framework, loadError = loadfile("personalFramework.lua")
if loadError then
	error(loadError)
end
framework()

local pref = {
	nl = "\n",
	font = "Calibri",--"Titillium Web",
	font2 = "Calibri",
	fsizen = 16,
	fsizee = 12,--9,
	fsizeg = 15,
	rotangle = 0,--270,
}
local graphML = {
	
	-- (nodes+edges; resources)
	boilerplate = table.concat({
		[[<?xml version="1.0" encoding="UTF-8" standalone="no"?>]],
		[[<graphml xmlns="http://graphml.graphdrawing.org/xmlns" xmlns:java="http://www.yworks.com/xml/yfiles-common/1.0/java" xmlns:sys="http://www.yworks.com/xml/yfiles-common/markup/primitives/2.0" xmlns:x="http://www.yworks.com/xml/yfiles-common/markup/2.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:y="http://www.yworks.com/xml/graphml" xmlns:yed="http://www.yworks.com/xml/yed/3" xsi:schemaLocation="http://graphml.graphdrawing.org/xmlns http://www.yworks.com/xml/schema/graphml/1.1/ygraphml.xsd">]],
		--[[<!--Created by yEd 3.18.1.1-->]]
		[[<!--Created by Factorio Tree Graph Generator (by Microeinstein)-->]],
		[[<key attr.name="Description" attr.type="string" for="graph" id="d0"/>]],
		[[<key for="port" id="d1" yfiles.type="portgraphics"/>]],
		[[<key for="port" id="d2" yfiles.type="portgeometry"/>]],
		[[<key for="port" id="d3" yfiles.type="portuserdata"/>]],
		[[<key attr.name="url" attr.type="string" for="node" id="d4"/>]],
		[[<key attr.name="description" attr.type="string" for="node" id="d5"/>]],
		[[<key for="node" id="d6" yfiles.type="nodegraphics"/>]],
		[[<key for="graphml" id="d7" yfiles.type="resources"/>]],
		[[<key attr.name="url" attr.type="string" for="edge" id="d8"/>]],
		[[<key attr.name="description" attr.type="string" for="edge" id="d9"/>]],
		[[<key for="edge" id="d10" yfiles.type="edgegraphics"/>]],
		[[<graph edgedefault="directed" id="G">]],
		[[<data key="d0"/>]],
		[[%s</graph>]],
		[[<data key="d7">]],
		[[%s</data>]],
		[[</graphml>]],
	}, pref.nl)..pref.nl,
	
	-- (id; fillColor; labels)
	node = table.concat({
		[[<node id="%s">]],
		[[<data key="d6">]],
		[[<y:ShapeNode>]],
		[[<y:Geometry height="32.0" width="94.033203125"/>]],
		[[<y:Fill color="#%s" transparent="false"/>]],
		[[<y:BorderStyle hasColor="false" raised="false" type="line" width="1.0"/>]],
		[[%s<y:Shape type="roundrectangle"/>]],
		[[</y:ShapeNode>]],
		[[</data>]],
		[[</node>]],
	}, pref.nl)..pref.nl,
	
	-- (id; fillColor; labels; resource)
	imageNode = table.concat({
		[[<node id="%s">]],
		[[<data key="d5"/>]],
		[[<data key="d6">]],
		[[<y:ImageNode>]],
		[[<y:Geometry width="%s" height="%s"/>]],
		[[<y:Fill color="#%s" transparent="false"/>]],
		[[<y:BorderStyle color="#000000" type="line" width="1.0"/>]],
		[[%s<y:Image alphaImage="true" refid="%d"/>]],
		[[</y:ImageNode>]],
		[[</data>]],
		[[</node>]],
	}, pref.nl)..pref.nl,
	
	-- (number; source; target; lineColor; lineType; sourceArrow; targetArrow; labels)
	edge = table.concat({
		[[<edge id="e%d" source="%s" target="%s">]],
		[[<data key="d10">]],
		[[<y:QuadCurveEdge straightness="1.0">]],
		[[<y:Path sx="0.0" sy="0.0" tx="0.0" ty="0.0"/>]],
		[[<y:LineStyle color="#%s" type="%s" width="1.0"/>]],
		[[<y:Arrows source="%s" target="%s"/>]],
		[[%s</y:QuadCurveEdge>]],
		[[</data>]],
		[[</edge>]],
	}, pref.nl)..pref.nl,
	
	-- (backgroundColor; lineColor; color; text)
	labels = {
		N22 = table.concat({
			[[<y:NodeLabel alignment="center" autoSizePolicy="content" fontFamily="]]..pref.font..[[" fontSize="]]..pref.fsizen..[[" fontStyle="plain" %s %s height="19.9609375" horizontalTextPosition="center" iconTextGap="4" modelName="custom" textColor="#%s" verticalTextPosition="bottom" visible="true" width="10.46875">%s<y:LabelModel>]],
			[[<y:SmartNodeLabelModel distance="4.0"/>]],
			[[</y:LabelModel>]],
			[[<y:ModelParameter>]],
			[[<y:SmartNodeLabelModelParameter labelRatioX="0.0" labelRatioY="0.0" nodeRatioX="0.0" nodeRatioY="0.0" offsetX="0.0" offsetY="0.0" upX="0.0" upY="-1.0"/>]],
			[[</y:ModelParameter>]],
			[[</y:NodeLabel>]],
		}, pref.nl)..pref.nl,
		N23 = [[<y:NodeLabel alignment="center" autoSizePolicy="content" fontFamily="]]..pref.font..[[" fontSize="]]..pref.fsizen..[[" fontStyle="plain" %s %s height="18.701171875" horizontalTextPosition="center" iconTextGap="4" modelName="sandwich" modelPosition="s" textColor="#%s" verticalTextPosition="bottom" visible="true" width="22.673828125">%s</y:NodeLabel>]]..pref.nl,
		
		E21 = table.concat({
			[[<y:EdgeLabel alignment="center" rotationAngle="]]..pref.rotangle..[[" distance="2.0" fontFamily="]]..pref.font2..[[" fontSize="]]..pref.fsizee..[[" fontStyle="plain" %s %s height="18.701171875" horizontalTextPosition="center" iconTextGap="4" modelName="three_center" modelPosition="scentr" preferredPlacement="source_on_edge" ratio="0.5" textColor="#%s" verticalTextPosition="bottom" visible="true" width="10.673828125">%s]],
			[[<y:PreferredPlacementDescriptor angle="0.0" angleOffsetOnRightSide="0" angleReference="absolute" angleRotationOnRightSide="co" distance="-1.0" placement="source" side="on_edge" sideReference="relative_to_edge_flow"/>]],
			[[</y:EdgeLabel>]],
		}, pref.nl)..pref.nl,
		E23 = table.concat({
			[[<y:EdgeLabel alignment="center" rotationAngle="]]..pref.rotangle..[[" distance="2.0" fontFamily="]]..pref.font2..[[" fontSize="]]..pref.fsizee..[[" fontStyle="plain" %s %s height="18.701171875" horizontalTextPosition="center" iconTextGap="4" modelName="three_center" modelPosition="tcentr" preferredPlacement="target_on_edge" ratio="0.5" textColor="#%s" verticalTextPosition="bottom" visible="true" width="10.673828125">%s]],
			[[<y:PreferredPlacementDescriptor angle="0.0" angleOffsetOnRightSide="0" angleReference="absolute" angleRotationOnRightSide="co" distance="-1.0" placement="target" side="on_edge" sideReference="relative_to_edge_flow"/>]],
			[[</y:EdgeLabel>]],
		}, pref.nl)..pref.nl,
		E33 = table.concat({
			[[<y:EdgeLabel alignment="center" rotationAngle="]]..pref.rotangle..[[" distance="2.0" fontFamily="]]..pref.font2..[[" fontSize="]]..pref.fsizee..[[" fontStyle="plain" %s %s height="18.701171875" horizontalTextPosition="center" iconTextGap="4" modelName="six_pos" modelPosition="ttail" preferredPlacement="target_right" ratio="0.5" textColor="#%s" verticalTextPosition="bottom" visible="true" width="10.673828125">%s]],
			[[<y:PreferredPlacementDescriptor angle="0.0" angleOffsetOnRightSide="0" angleReference="absolute" angleRotationOnRightSide="co" distance="-1.0" placement="target" side="right" sideReference="relative_to_edge_flow"/>]],
			[[</y:EdgeLabel>]],
		}, pref.nl)..pref.nl,
	},
	
	lineTypes = {
		line = [[line]],
		dashed = [[dashed]],
		dashed_dotted = [[dashed_dotted]],
	},
	
	arrowTypes = {
		none = [[none]],
		black = [[standard]],
		white = [[white_delta]],
		crows_foot_optional = [[crows_foot_optional]],
	},
	
	-- (id; title; text?; id..":"; nodes)
	group = table.concat({
		[[<node id="%s" yfiles.foldertype="group">]],
		[[<data key="d4"/>]],
		[[<data key="d5"/>]],
		[[<data key="d6">]],
		[[<y:ProxyAutoBoundsNode>]],
		[[<y:Realizers active="0">]],
		[[<y:GroupNode>]],
		[[<y:Geometry height="153.37646484375" width="327.0166015625"/>]],
		[[<y:Fill color="#F5F5F5" transparent="false"/>]],
		[[<y:BorderStyle color="#000000" type="dashed" width="1.0"/>]],
		[[<y:NodeLabel alignment="right" autoSizePolicy="node_width" backgroundColor="#EBEBEB" borderDistance="0.0" fontFamily="]]..pref.font..[[" fontSize="]]..pref.fsizeg..[[" fontStyle="plain" hasLineColor="false" height="22.37646484375" horizontalTextPosition="center" iconTextGap="4" modelName="internal" modelPosition="t" textColor="#000000" verticalTextPosition="bottom" visible="true" width="327.0166015625">%s</y:NodeLabel>]],
		[[<y:Shape type="roundrectangle"/>]],
		[[<y:State closed="false" closedHeight="50.0" closedWidth="50.0" innerGraphDisplayEnabled="false"/>]],
		[[<y:Insets bottom="15" bottomF="15.0" left="15" leftF="15.0" right="15" rightF="15.0" top="15" topF="15.0"/>]],
		[[<y:BorderInsets bottom="0" bottomF="0.0" left="0" leftF="0.0" right="0" rightF="0.0" top="0" topF="0.0"/>]],
		[[</y:GroupNode>]],
		[[<y:GroupNode>]],
		[[<y:Geometry height="50.0" width="50.0"/>]],
		[[<y:Fill color="#F5F5F5" transparent="false"/>]],
		[[<y:BorderStyle color="#000000" type="dashed" width="1.0"/>]],
		[[<y:NodeLabel alignment="right" autoSizePolicy="node_width" backgroundColor="#EBEBEB" borderDistance="0.0" fontFamily="]]..pref.font..[[" fontSize="]]..pref.fsizeg..[[" fontStyle="plain" hasLineColor="false" height="22.37646484375" horizontalTextPosition="center" iconTextGap="4" modelName="internal" modelPosition="t" textColor="#000000" verticalTextPosition="bottom" visible="true" width="59.02685546875">%s</y:NodeLabel>]],
		[[<y:Shape type="roundrectangle"/>]],
		[[<y:State closed="true" closedHeight="50.0" closedWidth="50.0" innerGraphDisplayEnabled="false"/>]],
		[[<y:Insets bottom="5" bottomF="5.0" left="5" leftF="5.0" right="5" rightF="5.0" top="5" topF="5.0"/>]],
		[[<y:BorderInsets bottom="0" bottomF="0.0" left="0" leftF="0.0" right="0" rightF="0.0" top="0" topF="0.0"/>]],
		[[</y:GroupNode>]],
		[[</y:Realizers>]],
		[[</y:ProxyAutoBoundsNode>]],
		[[</data>]],
		[[<graph edgedefault="directed" id="%s">]],
		[[%s</graph>]],
		[[</node>]],
	}, pref.nl)..pref.nl,
	
	resources = {
		empty = [[<y:Resources/>]]..pref.nl,
		notEmpty = table.concat({
			[[<y:Resources>]],
			[[%s</y:Resources>]],
		}, pref.nl)..pref.nl,
		-- (number; base64/"&#13;")
		entry = [[<y:Resource id="%d" type="java.awt.image.BufferedImage">%s</y:Resource>]]..pref.nl,
	},
}

function showHelp(exitCode)
	local ac = {1,2,3,5,6}
	local nt
	local n1 = math.random(1, #ac)
	nt = n1
	n1 = ac[n1]
	ac[nt] = nil
	ac = table.compact(ac)
	local n2 = math.random(1, #ac)
	nt = n2
	n2 = ac[n2]
	ac[nt] = nil
	ac = table.compact(ac)
	
	local c1 = "\27[0;1;3"..n1.."m"
	local c2 = "\27[0;1;3"..n2.."m"
	local cr = "\27[0m"
	
	local helpText = table.concat({
		"",
		c1.."Factorio tree graph generator tool, by Microeinstein"..cr,
		"  "..c2.."Syntax"..cr..": [-h] [-e] [-t <num>] [-nl|-li -lt]",
		"          <factorio_dir> <output_file>",
		"",
		"  "..c2.."Arguments"..cr..":",
		"    <factorio_dir>  The directory of your factorio installation",
		"    <output_file>   The output path for the graph",
		"",
		"  "..c2.."Options"..cr..":",
		"    -h --help   Show this text",
		"    -e          Use expensive recipes",
		"    -t <num>    Multiply technologies prices",
		"    -nl         Do not group items in levels",
		"    -li         Make links between levels instead of inputs",
		"    -lt         Make links between levels instead of technologies",
		"",
		}, "\n");
	print(helpText)
	os.exit(exitCode or 0)
end
function loadArgs()
	local argsLen = #arg
	--if argsLen == 0 then
	--	showHelp(1)
	--end
	
	if table.contains(arg, "-h")
	or table.contains(arg, "--help")
	or table.contains(arg, "/?") then
		showHelp(0)
	end
	
	local optExp = false
	local optTechMul = 1
	local factorioDir = nil
	outputFile = nil
	local noMoreOptions = false
	noLevels = false
	lightInputs = false
	lightTech = false
	
	local function shiftArgs()
		arg[1] = nil
		arg = table.compact(arg)
		argsLen = argsLen - 1
	end
	local function parseNextArg()
		local a = arg[1]
		local ok = false
		if a == nil or argsLen == 0 then
			return false
		end
		::retry_arg::
		if noMoreOptions then
			if factorioDir == nil then
				factorioDir = a
				ok = true
			elseif outputFile == nil then
				outputFile = a
				ok = true
			end
		else
			if a == "-t" then
				shiftArgs()
				local b = tonumber(arg[1])
				if not b or b < 1 then
					print("Invalid number (-t).")
					os.exit(3)
				end
				optTechMul = b
				ok = true
			elseif a == "-e" then
				optExp = true
				ok = true
			elseif a == "-nl" then
				noLevels = true
				ok = true
			elseif a == "-li" then
				lightInputs = true
				ok = true
			elseif a == "-lt" then
				lightTech = true
				ok = true
			else
				noMoreOptions = true
				goto retry_arg
			end
		end
		if ok then
			shiftArgs()
			return true
		end
	end
	
	repeat until not parseNextArg()
	
	lightInputs = not noLevels and lightInputs
	lightTech = not noLevels and lightTech
	
	-- [Please correct at final release]
	if not factorioDir then
		print("Please specify Factorio directory")
	end
	if not outputFile then
		print("Please specify output file path")
	end
	
	game.dirs.root = factorioDir
	game.recipes.expensive = optExp
	game.technologies.multiplier = optTechMul
	
end
function debugFunctions()
	local badstring = "\u{0061}a\u{00c5}\197\197\u{253C}\195\u{251C}"
	print(badstring, "\n")
	print(utf8.len(badstring), "\n")
	for p, v, u in utf8.codes("abc") do print(p, v, u, v & 0xc0, v & 0x40, v & 0x80) end
	print()
	for p, v, u in utf8.codes(badstring) do print(p, v, u, v & 0xc0, v & 0x40, v & 0x80) end
	print()
	
	local slice = ";abc;de/;f;;ghi;"
	print(slice, "\n")
	for _, s in ipairs(string.split(slice, ";", "/")) do print(#s == 0 and "[empty]" or s) end
	print()
	
	local dirs = {"aa", "bb" .. path.dirSep, path.dirSep .. "cc" .. path.dirSep}
	print(table.unpack(dirs))
	print(path.combine(table.unpack(dirs)))
	print()
	
	local tableSample = {
		2, 2, 2,
		a = "b",
		c = "d",
	}
	tableSample[tableSample] = 5
	rPrint(table.makePrototype(tableSample), 10, "Prototype")
	
	local treeSample = {
		{{name="a"}, {name="b"}, {name="c"}},
		{{name="d"}, {name="e"}, {name="f"}, {name="g"}}
	}
	rPrint(table.blend(treeSample), 10, "Blended TreeSample")
	
	os.exit()
end
function loadConsts()
	game.dirs.data         = path.combine(game.dirs.root, "data")
	game.dirs.base         = path.combine(game.dirs.data, "base")
	game.dirs.core         = path.combine(game.dirs.data, "core")
	game.dirs.prototypes   = path.combine(game.dirs.base, "prototypes")
	game.dirs.graphics     = path.combine(game.dirs.base, "graphics")
	
	game.dirs.recipes      = path.combine(game.dirs.prototypes, "recipe")
	game.dirs.technologies = path.combine(game.dirs.prototypes, "technology")
	game.dirs.icons = {
		recipes      = path.combine(game.dirs.graphics, "icons"),
		technologies = path.combine(game.dirs.graphics, "technology"),
	}
	
	game.files.dataloader   = path.combine(game.dirs.core, "lualib", "dataloader.lua")
	game.files.recipes      = path.getFiles(game.dirs.recipes)
	game.files.technologies = path.getFiles(game.dirs.technologies)
	game.files.icons = {
		recipes      = path.getFiles(game.dirs.icons.recipes, true),
		technologies = path.getFiles(game.dirs.icons.technologies, true),
	}
end
function printFinalArgs()
	--rPrint(game, 10, "Game")
	
	local align = { true, false }
	local rows1 = {
		{"OS", process.isWindows and "Windows" or "Surely not windows" },
		{"ANSI support", tostring(process.ansiSupported) },
		{"Directory", game.dirs.root },
		{"Expensive recipes", tostring(game.recipes.expensive) },
		{"Tech price multiplier", tostring(game.technologies.multiplier) },
		{"Use levels", tostring(not noLevels) },
		{"Light input links", tostring(lightInputs) },
		{"Light tech. links", tostring(lightTech) },
	}
	local rows2 = {
		{"Data loader", game.files.dataloader },
		{"Recipes folder", game.dirs.recipes },
		{"Tech. folder", game.dirs.technologies },
		{"Graphics folder", game.dirs.graphics },
		{"Recipes images amount", tostring(#(game.files.icons.recipes)) },
		{"Tech. images amount", tostring(#(game.files.icons.technologies)) },
	}
	
	printBoxes(false,
		buildText(makeRows({{"Factorio recipes combiner v1.0", "by Microeinstein"}}, align), term.box1v),
		buildText(makeRows(rows1, align), term.box1v),
		buildText(makeRows(rows2, align), term.box1v)
	)
	printBoxes(false,
		"Recipes",
		buildText(makeRows(game.files.recipes, align), term.box1v)
	)
	printBoxes(false,
		"Technologies",
		buildText(makeRows(game.files.technologies, align), term.box1v)
	)
	
	print()
end
function loadFiles()
	if table.len(game.files.recipes) < 1 then
		error("No recipes found!")
	end
	
	loadfile(game.files.dataloader)()
	for i, v in pairs(game.files.recipes) do
		loadfile(path.combine(game.dirs.recipes, v))()
	end
	for i, v in pairs(game.files.technologies) do
		loadfile(path.combine(game.dirs.technologies, v))()
	end
	
	game.recipes.data        = data.raw.recipe
	game.technologies.data   = data.raw.technology
	game.recipes.amount      = table.len(game.recipes.data)
	game.technologies.amount = table.len(game.technologies.data)
end

local lastStatus, counter, problems, notproblems
local numObj, numRec, numTec, filterRT, filterOT, filterOR, filterORT

local function startTask(str)
	io.write("  " .. string.padLeft(str .. "...", 45))
	lastStatus = ""
	counter = 0
	problems = 0
	notproblems = false
end
local function printStatus(value, target)
	local s
	if target ~= nil then
		local num = math.round(value / target * 100)
		num = math.round(num / 5) * 5
		s = tostring(num) .. "%"
	else
		s = tostring(value)
	end
	if s ~= lastStatus then
		term.moveCursor(0, -(#lastStatus))
		--io.write(string.rep(" ", #lastStatus))
		--term.moveCursor(0, -(#lastStatus))
		io.write(s)
		lastStatus = s
	end
end
local function endTask()
	term.moveCursor(0, -(#lastStatus))
	io.write(string.rep(" ", #lastStatus))
	term.moveCursor(0, -(#lastStatus))
	io.write("OK")
	if problems > 0 or counter > 0 then
		local perc = math.round(problems / counter * 100)
		io.write(string.format("   %s: %d/%d (%d%%)", notproblems and "Skips" or "Errors", problems, counter, perc))
	end
	print()
end

function assembleTables()
	local function collectObject(t, n, e, input, output)
		local i, v = table.first(game.objects.data, function(i, v)
			return v.type == t and v.name == n
		end)
		if i == nil then
			i = #(game.objects.data) + 1
			v = {
				type = t,
				name = n,
				input = {},   --recipes or technologies containing this object as ingredient
				output = {},  --recipes containing this object as result
			}
			game.objects.data[i] = v
		end
		if input then
			v.input[#(v.input) + 1] = e
		end
		if output then
			v.output[#(v.output) + 1] = e
		end
		return v
	end
		
	local function taskSR()
		for _, r in pairs(game.recipes.data) do
			if (r.normal and not r.expensive) or (not r.normal and r.expensive) then
				error(r.name .. " has some problems... (difficuity)")
			elseif r.expensive then --and of course "r.normal"
				table.extract( --difficuity specific tables should not contain "resultS"
					game.recipes.expensive and r.expensive or r.normal,
					{"enabled", "energy_required", "ingredients", "result", "results", "result_count"},
					r, false
				)
				r.normal = nil
				r.expensive = nil
			end
			
			--standard results
			if (not r.result and not r.results)
			or (r.result and r.results)
			or (r.results and r.result_count) then
				error(r.name .. " has some problems... (results)")
			end
			
			--too simple to normal
			for k, v in pairs(r.ingredients) do
				local t, n, a = (v.type or "item"), (v.name), (v.amount)
				if not n then
					if #v == 2 then
						n = v[1]
						a = v[2]
					else
						error(r.name .. " has some problems... (ingredients)")
					end
				end
				--grouping objects
				local obj = collectObject(t, n, r, true, false)
				v = {
					amount = a,
					object = obj
				}
				r.ingredients[k] = v
			end
			
			--too simple to normal
			if r.result then
				r.results = {{
					name = r.result,
					amount = r.result_count,
				}}
			end
			for k, v in pairs(r.results) do
				local t = v.type or "item"
				local n = v.name
				--grouping objects
				local obj = collectObject(t, n, r, false, true)
				v = {
					amount = v.amount or 1,
					probability = v.probability or 1,
					object = obj
				}
				r.results[k] = v
			end
			r.category = r.category or "crafting"
			r.energy_required = r.energy_required or 0.5 --time in seconds
			
			--cleaning
			--r.main_product = nil
			r.result = nil
			r.result_count = nil
			r.enabled = r.enabled == nil and true or r.enabled
			--r.order = nil
		end
	end
	local function taskUT()
		local function isUnlocker(t)
			return table.exists(t.effects, function(k, v) return v.type == "unlock-recipe" end)
		end
		
		notproblems = true
		for k, v in pairs(table.where(game.technologies.data, function(k, v) return v.unit.count_formula end)) do
			if isUnlocker(v) then
				error("Hey doc, we have a problem")
			end
			counter = counter + 1
			game.technologies.data[k] = nil
		end
		for k, v in pairs(table.where(game.technologies.data, function(k, v) return v.upgrade or v.max_level or v.level end)) do
			counter = counter + 1
			if not isUnlocker(v) then
				game.technologies.data[k] = nil
			else
				problems = problems + 1
			end
		end
	end
	local function taskMT()
		for _, t in pairs(game.technologies.data) do
			if not t.unit.count then
				error(t.name .. " has some problems... (unit.count)")
			end
			t.unit.count = t.unit.count * game.technologies.multiplier
		end
	end
	local function taskST()
		for _, t in pairs(game.technologies.data) do
			for k, v in pairs(t.unit.ingredients) do
				if type(v[1]) == "string" and type(v[2]) == "number" then
					local obj = collectObject("item", v[1], t, true, false)
					v = {
						amount = v[2],
						object = obj
					}
					t.unit.count = t.unit.count * game.technologies.multiplier
					t.unit.ingredients[k] = v
				else
					error(t.name .. " has some problems... (ingredients)")
				end
			end
			--t.unit.count = nil
			t.effects = t.effects or {}
			--[[Technologies can have no effects (aka just unlock other technologies)
			if #(t.effects) < 1 then
				error(t.name .. " has some problems... (effects)")
			end]]
			for k, v in pairs(t.effects) do
				if v.type == "unlock-recipe" then
					v.recipe = game.recipes.data[v.recipe]
				end
			end
			t.prerequisites = t.prerequisites or {}
			for k, v in pairs(t.prerequisites) do
				if type(v) ~= "string" then
					error(t.name .. " has some problems... (prerequisites)")
				end
				t.prerequisites[k] = game.technologies.data[v]
			end
		end
	end
	local function taskIR()
		for _, r in pairs(game.recipes.data) do
			r.icon = table.first(game.files.icons.recipes, function(k,v) return string.contains(v, r.name) end)
			if not r.icon then
				problems = problems + 1
			end
			printStatus(counter, game.recipes.amount)
			counter = counter + 1
		end
	end
	local function taskIT()
		for _, t in pairs(game.technologies.data) do
			t.icon = table.first(game.files.icons.technologies, function(k,v) return string.contains(v, t.name) end)
			if not t.icon then
				problems = problems + 1
			end
			printStatus(counter, game.technologies.amount)
			counter = counter + 1
		end
	end
	local function taskTN()
		numObj = table.allNumerical(game.objects.data)
		numRec = table.allNumerical(game.recipes.data)
		numTec = table.allNumerical(game.technologies.data)
		printStatus(1, 2)
		filterRT = table.combine{numRec, numTec}
		filterOT = table.combine{numObj, numTec}
		filterOR = table.combine{numObj, numRec}
		filterORT = table.combine{numObj, numRec, numTec}
		printStatus(2, 2)
	end
	local function taskBA()
		local function filterTint(a)
			return
			a.primary ~= nil and
			a.secondary ~= nil and
			a.tertiary ~= nil and
			type(a.primary) == "table" and
			type(a.secondary) == "table" and
			type(a.tertiary) == "table" and
			#a == 0 and
			table.len(a) == 3
		end
		printStatus(0, 3)
		game.objects.blended = table.blend(numObj, filterRT)
		printStatus(1, 3)
		game.recipes.blended = table.blend(numRec, filterOT, filterTint)
		printStatus(2, 3)
		game.technologies.blended = table.blend(numTec, filterOR)
		printStatus(3, 3)
	end
	local function taskDE()
		notproblems = true
		local treeLevel = 0
		local index = 1
		
		local function addTo(lvl, k, tab, element)
			if not table.contains(tab, element) then
				local i = lvl.amounts[k] + 1
				tab[i] = element
				lvl.amounts[k] = i
			end
		end
		local function removeAndCompact(from, elements)
			for _, v1 in pairs(elements) do
				for k2, _ in pairs(table.where(from, function(k, v) return v == v1 end)) do
					from[k2] = nil
				end
			end
			return table.compact(from)
		end
		local function makeNextLevel()
			local level = {
				technologies = {},
				recipes      = {},
				inputs       = {},
				outputs      = {},
				amounts      = {
					t = 0,
					r = 0,
					i = 0,
					o = 0
				}
			}
			
			local debugName = "speed-module"
			local debugTech = false
			local debugRecipe = false
			
			local function lvl1()
				level.outputs = table.takeWhere(game.objects.data, function(i, o)
					return #(o.output) == 0
				end)
				level.amounts.o = #(level.outputs)
			end
			local function lvlNext()
				local blended = table.blend(game.tree, filterORT)
				for k, v in pairs(blended.amounts) do
					if type(v) == "table" then
						v = table.aggregate(v, function(i, a, b) return a + b end)
						blended.amounts[k] = v
					end
				end
				
				local function checkTech1(t)
					for _, p in pairs(t.prerequisites) do
						if not table.exists(blended.technologies, function(i, t) return t.name == p.name end) then
							if debugTech and t.name == debugName then
								print(i.object.name.." tech does not exists")
							end
							return false
						end
					end
					return true
				end
				local function checkTech2(t)
					for _, i in pairs(t.unit.ingredients) do
						if not table.contains(blended.outputs, i.object) then
							if debugTech and t.name == debugName then
								print(i.object.name.." ingredient does not exists")
							end
							return false
						end
					end
					return true
				end
				for n, t in pairs(game.technologies.data) do
					local c1 = not table.contains(blended.technologies, t)
					local c2 = c1 and checkTech1(t)
					local c3 = c2 and checkTech2(t)
					if debugTech and t.name == debugName then
						print(treeLevel, c1, c2, c3)
					end
					if c3 then
						addTo(level, "t", level.technologies, t)
					end
				end
				
				local function checkRecipe0(r)
					if r.enabled then -- (if true or object, not false or nil)
						return r.enabled
					end
					local unlocksThis =
						table.takeWhere(blended.technologies, function(i, t) return
						table.exists(t.effects, function(i, e) return
						e.type == "unlock-recipe" and e.recipe == r
						end)
						end)
					if debugRecipe and r.name == debugName then
						print(#unlocksThis.." unlocking technologies")
					end
					if #unlocksThis < 1 then
						return false
					end
					--r.enabled = unlocksThis --CHANGED FROM ORIGINAL
					return true
				end
				local function checkRecipe1(r)
					for _, i in pairs(r.ingredients) do
						if not table.contains(blended.outputs, i.object) then
							if debugRecipe and r.name == debugName then
								print(i.object.name.." ingredient does not exists")
							end
							return false
						end
					end
					return true
				end
				for n, r in pairs(game.recipes.data) do
					local c1 = not table.contains(blended.recipes, r)
					local c2 = c1 and checkRecipe0(r)
					local c3 = c2 and checkRecipe1(r)
					if debugRecipe and r.name == debugName then
						print(treeLevel, c1, c2, c3)
					end
					if c3 then
						addTo(level, "r", level.recipes, r)
					end
				end
				
				for i1, t in pairs(level.technologies) do
					for i2, i in pairs(t.unit.ingredients) do
						addTo(level, "i", level.inputs, i.object)
					end
				end
				for i1, r in pairs(level.recipes) do
					for i2, i in pairs(r.ingredients) do
						addTo(level, "i", level.inputs, i.object)
					end
					for i2, rs in pairs(r.results) do
						addTo(level, "o", level.outputs, rs.object)
					end
				end
			end
			
			treeLevel = treeLevel + 1
			if treeLevel < 2 then
				lvl1()
			else
				lvlNext()
			end
			
			return level
		end
		
		local lvl, notEmpty = nil, true
		while notEmpty do
			lvl = makeNextLevel()
			notEmpty =
				lvl.amounts.t > 0 or
				lvl.amounts.r > 0 or
				lvl.amounts.i > 0 or
				lvl.amounts.o > 0
			if notEmpty then
				game.tree[treeLevel] = lvl
				printStatus(treeLevel, 18) --change maximum in case of new Factorio version
				counter = counter + 1
			else
				--print("Level "..treeLevel.." is empty!")
			end
		end
	end
	
	local allTasks = {
		{ f = taskSR, n = "Standardizing recipes structures" },
		{ f = taskUT, n = "Removing futile technologies" },
		{ f = taskMT, n = "Multiplying technologies prices" },
		{ f = taskST, n = "Standardizing technologies structures" },
		--{ f = taskIR, n = "Putting recipes icons" },
		--{ f = taskIT, n = "Putting technologies icons" },
		{ f = taskTN, n = "Enumerating tables for filters" },
		{ f = taskBA, n = "Blending tables" },
		{ f = taskDE, n = "Sorting dependencies tree" },
	}
	
	print("[ASSEMBLING]")
	for i, t in ipairs(allTasks) do
		startTask(i .. ". " .. t.n)
		t.f()
		endTask()
	end
	
	print()
end
function exploreTables()
	print("[EXPLORING]")
	local namePrefix = ""
	local prefix = " "
	local pauseAtTables = true
	local pauseAtValues = false
	
	local function explore(depth, tab, title)
		rPrint(tab, depth, namePrefix .. title, pauseAtTables, pauseAtValues, prefix)
	end
	
	--explore(2, data, "Data")
	
	--explore(2, game.objects.blended, "Blended Objects")
	--explore(3, game.recipes.data["iron-plate"].results[1].object, "iron-plate")
	
	--explore(2, game.recipes.data, "Recipes")
	--explore(5, game.recipes.blended, "Blended Recipes")
	--explore(2, game.recipes.blended.ingredients, "Blended Recipes (ingredients)")
	--explore(2, game.recipes.blended.icon, "Blended Recipes (icon)")
	
	--explore(2, game.technologies.data, "Technologies")
	--explore(5, game.technologies.blended, "Blended Technologies")
	--explore(2, game.technologies.blended.prerequisites, "Blended Technologies (prerequisites)")
	--explore(2, game.technologies.blended.effects, "Blended Technologies (effects)")
	
	--[[Debug test
	local blendedTree = table.blend(game.tree, filterORT)
	local testName = "speed-module"
	if table.exists(blendedTree.recipes, function(k, v) return v.name == testName end) then
		print("That's pretty good")
	else
		print("Recipe not in tree!")
		if table.contains(game.recipes.blended.name, testName) then
			print("At least it exist...")
		else
			print("It does not even exist!") --this is really bad
		end
		error()
	end]]
	--explore(4, game.tree, "GeneratedTree")
	--explore(3, blendedTree, "Blended Tree")
	
	print("Everything seems ok.")
	print()
end
function buildGraph()
	local black = {hue = 0, saturation = 0, value = 0}
	local white = {hue = 0, saturation = 0, value = 1}
	local lightPurple = {hue = 270, saturation = 0.18, value = 1}
	local lightBlue   = {hue = 235, saturation = 0.18, value = 1}
	
	--[[Prototypes
	group = {
		parent = {node},
		nodes  = {node..},
		name   = "group",
		*ID
	}
	node = {
		parent = {node},
		color  = {color},
		labels = {label..},
		data   = {*}, -->node~nodes
		*ID
	}
	edge = {
		source = {node},
		target = {node},
		line   = "lineType",
		arrows = {
			source = "arrow",
			target = "arrow",
		},
		color  = {color},
		labels = {label..},
	}
	color = {
		hue        = 0.0,
		saturation = 0.0,
		value      = 0.0,
		*hex       = "123abc",
	}
	label = {
		type  = "labelType",
		color = {color},
		text  = "str",
	}
	]]
	local graph = {
		nodes = {}
	}
	local selected = graph
	local edges = {}
	local resources = graphML.resources.empty--""
	local final
	--local resourceNum = 1
	
	local line1 = graphML.lineTypes.line
	local line2 = graphML.lineTypes.dashed
	local line3 = graphML.lineTypes.dashed_dotted
	local arrow0 = graphML.arrowTypes.none
	local arrow1 = graphML.arrowTypes.black
	local arrow2 = graphML.arrowTypes.white
	local arrow3 = graphML.arrowTypes.crows_foot_optional
	local label1 = graphML.labels.E23
	local label2 = graphML.labels.E21
	local edgePresets = {
		_ttg = {color=black, darker=false, arrow1=arrow3, line=line3, arrow2=arrow2},
		_trg = {color=black, darker=false, arrow1=arrow3, line=line2, arrow2=arrow2},
		_tt  = {color=2,     darker=false, arrow1=arrow0, line=line3, arrow2=arrow2},
		_tr  = {color=1,     darker=true,  arrow1=arrow0, line=line2, arrow2=arrow2},
		_it  = {color=1,     darker=true,  arrow1=arrow0, line=line1, arrow2=arrow1},
		
		_oig = {color=black, darker=false, arrow1=arrow3, line=line1, arrow2=arrow1},
		_oi  = {color=1,     darker=true,  arrow1=arrow0, line=line1, arrow2=arrow1},
		
		_ir  = {color=1,     darker=true,  arrow1=arrow0, line=line1, arrow2=arrow1},
		_ro  = {color=1,     darker=false, arrow1=arrow0, line=line1, arrow2=arrow1},
	}
	
	local sat = {
		t = 0.4,
		i = 0.6,
		r = 0.6,
		o = 1,
	}
	local val = {
		t = 0.65,
		i = 0.85,
		r = 0.45,
		o = 0.9,
	}
	local colorPresets = {}
	local function loadPresets()
		colorPresets["science-pack-1"]          = {h = 0,   s = sat.i, v = 0.85}
		colorPresets["science-pack-2"]          = {h = 110, s = sat.i, v = 0.85}
		colorPresets["science-pack-3"]          = {h = 190, s = sat.i, v = 0.85}
		colorPresets["military-science-pack"]   = {h = 275, s = sat.i, v = 0.20}
		colorPresets["production-science-pack"] = {h = 295, s = sat.i, v = 0.85}
		colorPresets["high-tech-science-pack"]  = {h = 55,  s = sat.i, v = 0.85}
		colorPresets["space-science-pack"]      = {h = 0,   s = 0,     v = 0.85}
		
		colorPresets["water"] = {h = 210, s = sat.i, v = 0.85}
		colorPresets["coal"]  = {h = 0,   s = 0,     v = 0.35}
		colorPresets["electronic-circuit"] = {h = 110, s = sat.i, v = 0.85}
		colorPresets["advanced-circuit"]   = {h = 0,   s = sat.i, v = 0.85}
		colorPresets["processing-unit"]    = {h = 190, s = sat.i, v = 0.85}
		for _, n in pairs(game.objects.blended.name) do
			if string.startsWith(n, "iron") then
				colorPresets[n] = {h = 180, s = 0.12, v = 0.75}
			end
			if string.startsWith(n, "copper") then
				colorPresets[n] = {h = 35, s = 0.75, v = 0.90}
			end
			if string.startsWith(n, "steel") then
				colorPresets[n] = {h = 0, s = 0, v = 0.80}
			end
		end
	end
	loadPresets()
	
	local function makeLabel(type, color, text, lineColor, backgroundColor)
		return {
			type = type,
			backgroundColor = backgroundColor or false,
			lineColor = lineColor or false,
			color = color,
			text = text,
		}
	end
	local function makeColor(data, s, v)
		local c = colorPresets[data.name]
		if c then
			--print(c.h, c.s, c.v)
			c = {
				hue = c.h,
				saturation = c.s,
				value = c.v,
			}
		else
			local h = math.random() * 360
			--print(h, s, v)
			c = {
				hue = h,
				saturation = s,
				value = v,
			}
		end
		return c
	end
	local function bw(color)
		return (color.value < 0.7 or (color.hue > 190 and color.hue <= 360)) and white or black
	end
	local function darker(color)
		local c = {
			hue = color.hue,
			saturation = color.saturation * 2 / 3,
			value = color.value * 0.9,
		}
		return c
	end
	
	local function formatName(text)
		return string.replace(string.firstUpper(text), "-", " ")
	end
	local function formatTime(seconds)
		local function mod(a, b, c)
			local m = a % b
			c = c + ((a - m) / b)
			return m, c
		end
		local s = seconds
		local m = 0
		local h = 0
		s, m = mod(s, 60, m)
		m, h = mod(m, 60, h)
		if math.isInteger(s) then s = math.floor(s) end
		if math.isInteger(m) then m = math.floor(m) end
		if math.isInteger(h) then h = math.floor(h) end
		local str = table.compact{
			h > 0 and h.."h" or nil,
			m > 0 and m.."m" or nil,
			s > 0 and s.."s" or nil,
		}
		return #str > 0 and table.concat(str, " ") or "instant"
	end
	local function pushGroup(name)
		local new = {
			nodes = {},
			parent = selected,
			name = name,
		}
		local n = selected.nodes
		n[#n + 1] = new
		selected = new
	end
	local function popGroup()
		selected = selected.parent
		if selected == nil then
			error("woah calm down")
		end
	end
	local function pushNode(data, color, ...)
		local new = {
			parent = selected,
			color = color,
			labels = {...},
			data = data,
		}
		if data.node then
			data.nodes = { data.node }
			data.node = nil
		end
		if data.nodes then
			local n = data.nodes
			n[#n + 1] = new
		else
			data.node = new
		end
		local n = selected.nodes
		n[#n + 1] = new
		return new
	end
	local function pushEdge(source, target, preset, ...)
		local new = {
			source = source,
			target = target,
			line = preset.line,
			arrows = {
				source = preset.arrow1,
				target = preset.arrow2,
			},
			labels = {...},
		}
		
		local c = preset.color
		if c == 1 then
			c = source.color
		elseif c == 2 then
			c = target.color
		elseif type(c) ~= "table" then
			c = black
		end
		if preset.darker then
			c = darker(c)
		end
		new.color = c
		
		for _, l in pairs(new.labels) do
			if l.lineColor == true then
				l.lineColor = c
			end
		end
		
		local e = edges
		e[#e + 1] = new
		return new
	end

	
	local function taskST()
		local function pushTech(t)
			local c = makeColor(t, sat.t, val.t)
			return pushNode(t, c,
				makeLabel(graphML.labels.N22, bw(c),
					formatName(t.name) .. pref.nl ..
					"(x"..t.unit.count..", "..formatTime(t.unit.time * t.unit.count)..")"
				)
			)
		end
		local function pushObject(o, asInput)
			local c = asInput
				and makeColor(o, sat.i, val.i)
				or makeColor(o, sat.o, val.o)
			return pushNode(o, c,
				makeLabel(graphML.labels.N22, bw(c),
					formatName(o.name)
				)
			)
		end
		local function pushRecipe(r)
			local c = r.selfResult
				and makeColor(r, sat.o, val.o)
				or makeColor(r, sat.r, val.r)
			return pushNode(r, c,
				makeLabel(graphML.labels.N22, bw(c),
					formatName(r.name) .. pref.nl ..
					"("..formatTime(r.energy_required)..")" .. (r.category == "crafting" and "" or (pref.nl ..
						"("..formatName(r.category)..")"
					))
				)
			)
		end
		local function existEdge(source, target, set)
			set = set or edges
			return table.exists(set, function(k, v)
				return v.source == source and v.target == target
			end)
		end
		local function makeResultText(result)
			local txt = ""..result.amount
			if result.probability ~= 1 then
				local prob = result.probability * 100
				if result.amount == 1 then
					txt = prob.."%"
				else
					txt = txt .. " ("..prob.."%)"
				end
			end
			return txt
		end
		
		local levels = #(game.tree)
		local levels2 = #(game.tree) * 2
		
		--[[Unione nodi
		Nel caso in cui una recipe abbia un unico risultato, il quale ha il suo stesso nome,
		verrà generato un nodo [recipe], ad eccezione del nodo [object]; il nodo [recipe]
		verrà assegnato al suo corrispettivo oggetto per quel livello.
		
		Esempio:
			Da:		[recipe]-->[object]		recipe.node={RN}, object.treeNodes[lvl].output={ON}
			A:		[recipe]				recipe.node={RN}, object.treeNodes[lvl].output={RN}
		]]
		
		local function withGroups()
			--objects add-on
			for _, o in pairs(game.objects.data) do
				o.treeNodes = {}
				for lvl, _ in pairs(game.tree) do
					o.treeNodes[lvl] = {
						--input = nil,
						--output = nil,
					}
				end
			end
			
			local function makeNodes()
				for lvl, data in pairs(game.tree) do
					pushGroup("Level "..lvl)
					local innerSelfs = {}
					
					--tech
					if data.amounts.t > 0 then
						pushGroup("Tech")
						for _, t in pairs(data.technologies) do
							pushTech(t)
						end
						popGroup()
					end
					
					--inputs
					if data.amounts.i > 0 then
						pushGroup("Input")
						for k, i in pairs(data.inputs) do
							local node = pushObject(i, true)
							local nodes = i.treeNodes[lvl]
							if nodes.input ~= nil then
								error("This item already have an ID for this level (as input)")
							end
							nodes.input = node
						end
						popGroup()
					end
					
					--recipes
					if data.amounts.r > 0 then
						pushGroup("Recipes")
						for _, r in pairs(data.recipes) do
							--if the recipe has only 1 output, and their names are equal
							--then use a color for objects
							if #(r.results) == 1 and r.results[1].object.name == r.name then
								innerSelfs[#innerSelfs + 1] = r
								r.selfResult = true
							end
							pushRecipe(r)
						end
						popGroup()
					end
					
					--outputs
					if data.amounts.o > 0 then
						local groupPushed = false
						for k, o in pairs(data.outputs) do
							local node
							local _, rec =
								table.first(innerSelfs, function(k, v) return
								table.exists(v.results, function(k, v) return
								v.object == o
								end) end)
							
							if rec == nil then
								if not groupPushed then
									groupPushed = true
									pushGroup("Output")
								end
								node = pushObject(o, false)
							else
								node = rec.node
							end
							local nodes = o.treeNodes[lvl]
							if nodes.output ~= nil then
								error("This item already have an ID for this level (as output)")
							end
							nodes.output = node
						end
						if groupPushed then
							popGroup()
						end
					end
					
					popGroup()
					printStatus(lvl, levels2)
				end
			end
			local function makeEdges()
				for lvl, data in pairs(game.tree) do
					local techGroupLinks = {}
					local recGroupLinks = {}
					
					--tech
					if data.amounts.t > 0 then
						for _, t1 in pairs(data.technologies) do
							if lightTech then
								--tech0 to tech1
								local grpT = t1.node.parent.parent
								for _, t0 in pairs(t1.prerequisites) do
									local grpP = t0.node.parent.parent
									if not existEdge(grpP, grpT, techGroupLinks) then
										local e = pushEdge(grpP, grpT, edgePresets._ttg,
											makeLabel(label2, black, grpT.name, black, lightBlue),
											makeLabel(label1, black, grpP.name, black, lightPurple)
										)
										techGroupLinks[#techGroupLinks + 1] = e
									end
								end
								
								--tech1 to recipe1
								for _, eff in pairs(t1.effects) do
									if eff.type == "unlock-recipe" then
										if eff.recipe.node == nil then
											print()
											print(" [!] "..t1.name)
											print(" [!] "..eff.recipe.name)
											error("excuse me what the fuck (tech-out)")
										end
										local grpR = eff.recipe.node.parent.parent
										if not existEdge(grpT, grpR, techGroupLinks) then
											local e = pushEdge(grpT, grpR, edgePresets._trg,
												makeLabel(label2, black, grpR.name, black, lightBlue),
												makeLabel(label1, black, grpT.name, black, lightPurple)
											)
											techGroupLinks[#techGroupLinks + 1] = e
										end
									end
								end
							else
								--tech0 to tech1
								for _, t0 in pairs(t1.prerequisites) do
									pushEdge(t0.node, t1.node, edgePresets._tt)
								end
								
								--tech1 to recipe1
								for _, eff in pairs(t1.effects) do
									if eff.type == "unlock-recipe" then
										if eff.recipe.node == nil then
											print()
											print(" [!] "..t1.name)
											print(" [!] "..eff.recipe.name)
											error("excuse me what the fuck (tech-out)")
										end
										pushEdge(t1.node, eff.recipe.node, edgePresets._tr)
									end
								end
							end
							
							--objectI to tech1
							for _, ing in pairs(t1.unit.ingredients) do
								local node = ing.object.treeNodes[lvl].input
								if node == nil then
									print()
									print(" [!] "..t1.name)
									print(" [!] "..ing.object.name)
									error("excuse me what the fuck (tech-in)")
								end
								pushEdge(node, t1.node, edgePresets._it,
									ing.amount > 1 and makeLabel(label1, black, ing.amount, true, white) or nil
								)
							end
						end
					end
					
					--inputs
					if data.amounts.i > 0 then
						if lightInputs then
							--objectO to objectI
							for _, i in pairs(data.inputs) do
								local grp1 = i.treeNodes[lvl].input.parent.parent
								if grp1 == nil then
									print()
									print(" [!] "..i.name)
									error("excuse me what the fuck (obj-in)")
								end
								for lvl2, nodes in pairs(i.treeNodes) do
									local out = nodes.output
									if out ~= nil then --consider raw resources
										local grp0 = out.parent.parent
										if not existEdge(grp0, grp1, recGroupLinks) then
											local e = pushEdge(grp0, grp1, edgePresets._oig,
												makeLabel(label2, black, grp1.name, black, lightBlue),
												makeLabel(label1, black, grp0.name, black, lightPurple)
											)
											recGroupLinks[#recGroupLinks + 1] = e
										end
									end
								end
							end
						else
							--objectO to objectI
							for _, i in pairs(data.inputs) do
								local node1 = i.treeNodes[lvl].input
								if node1 == nil then
									print()
									print(" [!] "..i.name)
									error("excuse me what the fuck (obj-in)")
								end
								for lvl2, nodes in pairs(i.treeNodes) do
									local node0 = nodes.output
									if node0 ~= nil then --consider raw resources
										pushEdge(node0, node1, edgePresets._oi)
									end
								end
							end
						end
					end
					
					--recipes
					if data.amounts.r > 0 then
						for _, r in pairs(data.recipes) do
							--objectI to recipe1
							for _, ing in pairs(r.ingredients) do
								local node = ing.object.treeNodes[lvl].input
								if node == nil then
									print()
									print(" [!] "..r.name)
									print(" [!] "..ing.object.name)
									error("excuse me what the fuck (rec-in)")
								end
								pushEdge(node, r.node, edgePresets._ir,
									makeLabel(label1, black, ing.amount, true, white)
								)
							end
							if not r.selfResult then
								--recipe1 to objectO
								for _, res in pairs(r.results) do
									local node = res.object.treeNodes[lvl].output
									if node == nil then
										print()
										print(" [!] "..r.name)
										print(" [!] "..res.object.name)
										error("excuse me what the fuck (rec-out)")
									end
									pushEdge(r.node, node, edgePresets._ro,
										makeLabel(label1, black, makeResultText(res), true, white)
									)
								end
							end
						end
					end
					
					printStatus(levels + lvl, levels2)
				end
			end
			
			makeNodes()
			makeEdges()
		end
		local function allTogether()
			local function makeNodes()
				local innerSelfs = {}
			
				--tech
				--pushGroup("Technologies")
				for _, t in pairs(game.technologies.data) do
					pushTech(t)
				end
				--popGroup()
				
				--recipes
				--pushGroup("Recipes")
				for _, r in pairs(game.recipes.data) do
					--if the recipe has only 1 output, and their names are equal
					--then use a color for objects
					if #(r.results) == 1 and r.results[1].object.name == r.name then
						innerSelfs[#innerSelfs + 1] = r
						r.selfResult = true
					end
					pushRecipe(r)
				end
				
				--objects
				for k, o in pairs(game.objects.data) do
					local node
					local _, rec =
						table.first(innerSelfs, function(k, v) return
						table.exists(v.results, function(k, v) return
						v.object == o
						end) end)
					
					if rec == nil then
						node = pushObject(o, false)
					else
						node = rec.node
					end
					o.node = node
				end
				--popGroup()
			end
			local function makeEdges()
				--tech
				for _, t1 in pairs(game.technologies.data) do
					local n1 = t1.node
					for _, t0 in pairs(t1.prerequisites) do
						local n0 = t0.node
						pushEdge(n0, n1, edgePresets._tt)
					end
					for _, o0 in pairs(t1.unit.ingredients) do
						local n0 = o0.object.node
						pushEdge(n0, n1, edgePresets._it,
							o0.amount > 1 and makeLabel(label1, black, o0.amount) or nil
						)
					end
					for _, eff in pairs(t1.effects) do
						if eff.type == "unlock-recipe" then
							pushEdge(n1, eff.recipe.node, edgePresets._tr)
						end
					end
				end
				
				--recipes
				for _, r1 in pairs(game.recipes.data) do
					local n1 = r1.node
					for _, o0 in pairs(r1.ingredients) do
						local n0 = o0.object.node
						pushEdge(n0, n1, edgePresets._ir,
							makeLabel(label1, black, o0.amount)
						)
					end
					if not r1.selfResult then
						for _, o2 in pairs(r1.results) do
							local n2 = o2.object.node
							pushEdge(n1, n2, edgePresets._ro,
								makeLabel(label1, black, makeResultText(o2))
							)
						end
					end
				end
			end
			
			makeNodes()
			makeEdges()
		end		
		
		if noLevels then
			allTogether()
		else
			withGroups()
		end
	end
	local function taskGR()
		local all = nil
		local status = 0
		local strNodes, strEdges;
		
		local function ps()
			if all then
				printStatus(status, all)
			end
			--printStatus(status.." entities", nil)
		end
		
		local function makeIDs(dry, list, prefix)
			prefix = prefix or ""
			for i, n in pairs(list) do
				if not dry then	n.ID = prefix.."n"..i end
				if n.nodes then
					makeIDs(dry, n.nodes, dry or n.ID.."::")
				end
				status = status + 1
				ps()
			end
		end
		local function makeColorsHex(dry, list)
			for i, n in pairs(list) do
				if not dry then
					for _, c in ipairs({n.color, n.lineColor, n.backgroundColor}) do
						if c and not c.hex then
							c.hex = utils.hsv2hex(c.hue, c.saturation, c.value)
						end
					end
				end
				if n.labels then
					makeColorsHex(dry, n.labels)
				end
				if n.nodes then
					makeColorsHex(dry, n.nodes)
				end
				status = status + 1
				ps()
			end
		end
		local function buildLabelsString(dry, list)
			local str = ""
			for i, l in pairs(list) do
				if not dry then
					str = str .. string.format(l.type,
						l.backgroundColor and ('backgroundColor="#'..l.backgroundColor.hex..'"')
							or ('hasBackgroundColor="false"'),
						l.lineColor and ('lineColor="#'..l.lineColor.hex..'"')
							or ('hasLineColor="false"'),
						l.color.hex, l.text
					)
				end
				status = status + 1
				ps()
			end
			return str
		end
		local function buildNodesString(dry, list)
			local str = ""
			for i, n in pairs(list) do
				local s
				if n.nodes then
					local inner = buildNodesString(dry, n.nodes)
					if not dry then
						s = string.format(graphML.group, n.ID, n.name, n.name, n.ID..":", inner)
					end
				else
					local labels = buildLabelsString(dry, n.labels)
					if not dry then
						s = string.format(graphML.node, n.ID, n.color.hex, labels)
					end
				end
				if not dry then
					str = str .. s
				end
				status = status + 1
				ps()
			end
			return str
		end
		local function buildEdgesString(dry, list)
			local str = ""
			for i, e in pairs(list) do
				local labels = buildLabelsString(dry, e.labels)
				if not dry then
					str = str .. string.format(graphML.edge,
						i, e.source.ID, e.target.ID,
						e.color.hex, e.line,
						e.arrows.source, e.arrows.target,
						labels
					)
				end
				status = status + 1
				ps()
			end
			return str
		end
		local function perform(dry)
			makeIDs(dry, graph.nodes)
			makeColorsHex(dry, graph.nodes)
			makeColorsHex(dry, edges)
			strNodes = buildNodesString(dry, graph.nodes)
			strEdges = buildEdgesString(dry, edges)
		end
		
		--all = countTree(graph.nodes) + countTree(edges)
		
		ps()
		perform(true)
		all = status
		status = 0
		perform(false)
		counter = status
		
		final = string.format(graphML.boilerplate, strNodes..strEdges, resources)
	end
	local function taskSV()
		local out = io.open(outputFile, "w+")
		out:write(final)
		out:close()
	end
	
	local allTasks = {
		{ f = taskST, n = "Creating graph structure" },
		{ f = taskGR, n = "Generating GraphML output" },
		{ f = taskSV, n = "Saving data" },
	}
	
	print("[BUILDING GRAPH]")
	for i, t in ipairs(allTasks) do
		startTask(i .. ". " .. t.n)
		t.f()
		endTask()
	end
	
	print()
end
function main()
	--debugFunctions()
	loadConsts()
	printFinalArgs()
	loadFiles()
	assembleTables()
	exploreTables()
	buildGraph()
	print("Done!")
end

game = {
	dirs = {},
	files = {},
	objects = {
		data = {},
	},
	recipes = {},
	technologies = {},
	tree = {},
}
loadArgs()
term.clear()
main()




