# API
## Add new node to server 
```
cluster_map_add_node(node)
    node is a table with:
        id (int)
        name (string)
        width (int)
        height(int)
        tlc (Position) --top left corner
            position is a table with:
            x (int)
            y (int)
        progress (int) (optional) -- between 1 and 17 I think
        rocket (boolean) (optional) --rocket launched?
        active (boolean) (optional) -- is this node online? I think
        connections (table) (optional)
            table consists of the id's of all nodes it is connected with
            -- automatically adds this node to the connections of the nodes in this table
        address (string) (optional) -- server adress used for connecting
        region (string) (optional)
```
### Example
```
/c cluster_map_add_node({id = 16, name = "Nexus", width = 2, height = 2, tlc = {x = 0, y = 0}, progress = 17, rocket = false, active = true, connections = {18,19,21}, address=nil, region="NL-AMS1"})
```

## Update node on server 
```
cluster_map_update_node(node)
    node is a table with:
        id (int)
        progress (int) (optional) -- between 1 and 17 I think
        rocket (boolean) (optional) --rocket launched?
        active (boolean) (optional) -- is this node online? I think
        connections (table) (optional)
            table consists of the id's of all nodes it is connected with
            -- automatically adds this node to the connections of the nodes in this table
        address (string) (optional) -- server adress used for connecting
        region (string) (optional)
```
### Example
```
/c cluster_map_update_node({id = 16, progress = 12})
```

## Set the server node id
```
cluster_map_set_node(id)
    id (int) -- the id of the node this server is running
```
### Example
```
/c cluster_map_set_node(16)
```
