global.cluster_map_node_tags = global.cluster_map_node_tags or {}
global.cluster_map_surface = global.cluster_map_surface or "nauvis"

function cluster_map_create_all_nodes()
	for i, node in pairs(global.cluster_map_nodes) do
		cluster_map_create_node(node.id)
	end
end

function cluster_map_create_node(id)
	local tilelist = {}
	local tile_name = cluster_map_determine_tile_color(id)
	local edge_tile = "water"
	if id == global.cluster_map_own_id then
		edge_tile = "refined-hazard-concrete-left"
	end
	local node = global.cluster_map_nodes[id]
	local offset_x = (node.tlc.x * 50)-1
	local offset_y = (node.tlc.y * 50)-1
	local xsize = node.width * 50
	local ysize = node.height * 50
	for i= 1,xsize,1 do
		for j= 1,ysize,1 do
			if (i <= 4 or i+4 >= xsize or j <= 4 or j+4 >= ysize) and node.progress >= 7 then
				table.insert(tilelist, {name = edge_tile, position = {x = i+offset_x, y = j+offset_y}})
			else
				table.insert(tilelist, {name = tile_name, position = {x = i+offset_x, y = j+offset_y}})
			end
		end
	end
	global.cluster_map_surface.set_tiles(tilelist, true)
	game.forces["player"].chart(global.cluster_map_surface,
            {{x = offset_x, y = offset_y}, {x = offset_x + xsize, y = offset_y + ysize}})
	cluster_map_do_action_on_tick(game.tick + 120, "update_tag", id)
end

function cluster_map_update_tag(id)
	local node = global.cluster_map_nodes[id]
	local offset_x = (node.tlc.x * 50)-1
	local offset_y = (node.tlc.y * 50)-1
	local xsize = node.width * 50
	local ysize = node.height * 50
	local tag = global.cluster_map_node_tags[id]
	if (tag == nil or tag.valid == nil or tag.valid == false) and node.progress >= 7 then
		tag = game.forces["player"].add_chart_tag(global.cluster_map_surface, {position = {offset_x + (xsize/2), offset_y + (ysize/2)}, text = global.cluster_map_nodes[id].name})
		global.cluster_map_node_tags[id] = tag
	end
end

function cluster_map_determine_tile_color(id)
	local node = global.cluster_map_nodes[id]
	if node.progress < 7 then 
		return "out-of-map"
	elseif node.progress == 7 then
		return "red-desert-3"
	elseif node.progress > 7 then
		if node.active == true then
			if node.progress == 8 then
				return "lab-white"
			elseif node.progress < 17 then
				return "sand-1"
			else
				return "grass-1"
			end
		else
			return "red-desert-0"
		end
	else
		return "out-of-map"
	end
end

--
--	EVENTS
--
Event.register(defines.events.on_chunk_generated, function(event)
	if event.surface.name == "cluster_map" then
		local tilelist = {}
		local tile_name = "out-of-map"
		for i= event.area.left_top.x , event.area.right_bottom.x,1 do
			for j= event.area.left_top.y , event.area.right_bottom.y,1 do
				table.insert(tilelist, {name = tile_name, position = {x = i, y = j}})
			end
		end
		global.cluster_map_surface.set_tiles(tilelist, true)
	end
end)
