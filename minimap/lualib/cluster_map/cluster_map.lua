require "surface"
require "gui"

global.cluster_map_nodes = global.cluster_map_nodes or {}
global.cluster_map_set_up_done = global.cluster_map_set_up_done or false
global.cluster_map_own_id = nil
global.cluster_map_tick_actions = global.cluster_map_tick_actions or {}

function cluster_map_add_node(node)
	if global.cluster_map_set_up_done == false then
		cluster_map_set_up()
	end
	
	if node.id ~= nil and global.cluster_map_nodes[node.id] ~= nil then
		cluster_map_update_node(node)
		return
	end

	if node.id == nil or 
		node.name == nil or
		node.width == nil or
		node.height == nil or
		node.tlc == nil or
		node.tlc.x == nil or
		node.tlc.y == nil		
	then
		return
	end
	
	if node.progress == nil then
		node.progress = 0
	end
	
	if node.rocket == nil then
		node.rocket = false
	end
	
	if node.active == nil then
		node.active = false
	end
	
	if node.connections == nil then
		node.connections = {}
	else
		node.connections = cluster_map_set_connections(node)
	end
	
	if node.address == nil then
		node.address = nil
	end
	
	if node.region == nil then
		node.region = "Unkown"
	end
	
	global.cluster_map_nodes[node.id] = node
	cluster_map_create_node(node.id)
end

function cluster_map_update_node(node)
	if global.cluster_map_set_up_done == false then
		cluster_map_set_up()
	end
	
	if node.id ~= nil and global.cluster_map_nodes[node.id] == nil then
		cluster_map_add_node(node)
		return
	end
	
	local current = global.cluster_map_nodes[node.id]
	if node.progress ~= nil then
		current.progress = node.progress
	end
	
	if node.rocket ~= nil then
		current.rocket = node.rocket
	end
	
	if node.active ~= nil then
		current.active = node.active
	end
	
	if node.connections ~= nil then
		current.connections = cluster_map_set_connections(node)
	end
	
	if node.address ~= nil then
		current.address = node.address
	end
	
	if node.region ~= nil then
		current.region = node.region
	end
	cluster_map_create_node(node.id)
end

function cluster_map_set_node(id)
	if global.cluster_map_nodes[id] ~= nil then
		local old_id = global.cluster_map_own_id
		global.cluster_map_own_id = id
		cluster_map_create_node(id)
		if old_id ~= nil and old_id > 0 then
			cluster_map_create_node(old_id)
		end
	end
end

function cluster_map_set_connections(node)
	local valid_c = {}
	for i, cid in pairs(node.connections) do
		if global.cluster_map_nodes[cid] ~= nil then
			table.insert(valid_c, cid)
			cluster_map_check_or_create_connection(cid, node.id)
		end
	end
	return valid_c
end

function cluster_map_check_or_create_connection(cid, nid)
	local node = global.cluster_map_nodes[cid]
	for i, c in pairs(node.connections) do
		if c == nid then
			return
		end
	end
	table.insert(node.connections, nid)
end

function cluster_map_set_up()
	if global.cluster_map_set_up_done == false then
		global.cluster_map_surface = game.create_surface("cluster_map", {default_enable_all_autoplace_controls = false, seed = 0, peaceful_mode = true} )
		global.cluster_map_surface.request_to_generate_chunks({0,0}, 20)
		global.cluster_map_surface.force_generate_chunk_requests()
		global.cluster_map_set_up_done = true
	end
end

function cluster_map_do_action_on_tick(tick, action, param)
	if action ~= "update_tag" then
		return
	end
	if tick > game.tick then
		table.insert(global.cluster_map_tick_actions, {tick = tick, action = action, param = param})
	end
end

--
--	EVENTS
--
Event.register(defines.events.on_tick, function(event)
	new_list = {}
	for i, action in pairs(global.cluster_map_tick_actions) do
		if action.tick <= game.tick then
			if action.action == "update_tag" then
				cluster_map_update_tag(action.param)
			end
		else
			table.insert(new_list, action)
		end
	end
	global.cluster_map_tick_actions = new_list
end)
