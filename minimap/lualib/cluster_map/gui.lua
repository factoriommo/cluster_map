global.cluster_map_gui_player_node = global.cluster_map_gui_player_node or {}

function cluster_map_gui_changed(player)
	cluster_map_gui_get_map(player)
	local info = cluster_map_gui_get_info(player)
	info.clear()
	if next(global.cluster_map_nodes) == nil then
		return
	end
	
	local local_node_id = -1
	local local_node = global.cluster_map_nodes[global.cluster_map_own_id]
	local view_node = global.cluster_map_nodes[global.cluster_map_gui_player_node[player.index]]
	if local_node ~= nil then
		local_node_id = local_node.id
		info.add{type="label", name="cmg_info_local_node", caption = "You are on " .. local_node.name}
	end
	
	local dropdown_list = {}
	local dropdown_select_id = 1
	local inverse_node_index = {}
	for i, node in pairs(global.cluster_map_nodes) do
		if node.progress >= 7 or node.id == local_node_id then
			table.insert(dropdown_list, node.name)
			inverse_node_index[node.name] = node.id
		end
	end
	for i, node in pairs(dropdown_list) do
		if view_node ~= nil and view_node.id == inverse_node_index[node] then
			dropdown_select_id = i
		elseif view_node == nil and local_node_id == inverse_node_index[node] then
			dropdown_select_id = i
		end
	end
	local dropdown = info.add{type="drop-down", name="cmg_info_dropdown", items=dropdown_list, selected_index=dropdown_select_id}
	
	if view_node ~= nil then
		info.add{type="label", name="cmg_info_view_node", caption = "You are viewing " .. view_node.name}
		
		if view_node.active then
			info.add{type="label", name="cmg_info_view_status", caption = "Server is active"}
		else
			info.add{type="label", name="cmg_info_view_status", caption = "Server is inactive"}
		end
		
		if view_node.progress > 7 then
			local state = "offline"
			if view_node.progress == 8 then
				state = "awaiting activation"
			elseif view_node.progress > 8 and view_node.progress < 17 then
				state = "activating"
			elseif view_node.progress == 17 then
				state = "online"
			end
			info.add{type="label", name="cmg_info_view_progress", caption = "Server is " .. state}
		end
		
		info.add{type="label", name="cmg_info_view_region", caption = "Region: " .. view_node.region}
		
		local connections = ""
		for i, nid in pairs(view_node.connections) do
			if i > 1 then
				connections = connections .. ","
			end
			connections = connections .. " " .. global.cluster_map_nodes[nid].name
		end
		local cmg_info_connections = info.add{type="label", name="cmg_info_view_connections", caption = view_node.name .. " is connected to" .. connections}
		cmg_info_connections.style.single_line = false
		
		if view_node.id ~= local_node_id then
			if view_node.active and view_node.address ~= nil then
				local cmg_info_connect_button = info.add{type="button", name="cmg_info_view_connect", caption = "Connect to " .. view_node.name}
			else
				local cmg_info_connect_text = info.add{type="label", name="cmg_info_view_connect_text", caption = view_node.name .. " is offline"}
			end
		end
	end
	
end

function cluster_map_gui_get_frame(player)
	if global.cluster_map_set_up_done == false then
		cluster_map_set_up()
	end
	local cmg_frame = player.gui.center.cmg_frame
	if cmg_frame == nil or cmg_frame.valid == nil or cmg_frame.valid == false then
		cmg_frame = player.gui.center.add{type="frame", name="cmg_frame", caption="Cluster map", direction="horizontal"}
	end
	return cmg_frame
end

function cluster_map_gui_get_map(player)
	local cmg_frame = cluster_map_gui_get_frame(player)
	local cmg_map = cmg_frame.cmg_map
	if cmg_map == nil or cmg_map.valid == nil or cmg_map.valid == false then
		cmg_map = cmg_frame.add{type="minimap", name="cmg_map", position={x=1,y=75}, surface_index=game.surfaces["cluster_map"].index, zoom=0.65}
		cmg_map.style.natural_width = 600
		cmg_map.style.natural_height = 600
	end
	return cmg_map
end

function cluster_map_gui_get_info(player)
	local cmg_frame = cluster_map_gui_get_frame(player)
	local cmg_info = cmg_frame.cmg_info
	if cmg_info == nil or cmg_info.valid == nil or cmg_info.valid == false then
		cmg_info = cmg_frame.add{type="flow", name="cmg_info", direction="vertical"}
		cmg_info.style.width = 200
	end
	return cmg_info
end

--
--	EVENTS
--

Event.register(defines.events.on_player_joined_game, function(event)
	local p = game.players[event.player_index]
	global.cluster_map_gui_player_node[p.index] = global.cluster_map_own_id
	p.gui.top.add {type="sprite-button", name = "cmg_toggle", sprite="utility/surface_editor_icon", tooltip = "Show/hide cluster map"}
	cluster_map_gui_changed(p)
	local cmgf = cluster_map_gui_get_frame(p)
	cmgf.visible = false
end)

Event.register(defines.events.on_gui_selection_state_changed, function(event)
	if not (event and event.element and event.element.valid) then return end
	local i = event.player_index
	local p = game.players[i]
	local e = event.element	
	if e.name == "cmg_info_dropdown" then
		local node = event.element.get_item(event.element.selected_index)
		for i, n in pairs(global.cluster_map_nodes) do
			if n.name == node then
				global.cluster_map_gui_player_node[p.index] = n.id
				break
			end
		end
		cluster_map_gui_changed(p)
	end
end)

Event.register(defines.events.on_gui_click, function(event)
	if not (event and event.element and event.element.valid) then return end
	local i = event.player_index
	local p = game.players[i]
	local e = event.element	
	if e.name == "cmg_info_view_connect" then
		local view_node = global.cluster_map_nodes[global.cluster_map_gui_player_node[p.index]]
		
		p.print("Connecting to " .. view_node.name)
		p.connect_to_server{name = view_node.name, address=view_node.address}
	elseif e.name == "cmg_toggle" then
		local cmgf = cluster_map_gui_get_frame(p)
		if next(global.cluster_map_nodes) ~= nil then
			cluster_map_gui_changed(p)
			cmgf.visible = not cmgf.visible
		else
			p.print("No cluster to display")
		end
	end
end)