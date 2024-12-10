-- Laser Mod for Minetest
-- Register the laser emitter node
minetest.register_node("laser_mod:laser_emitter", {
    description = "Laser Emitter",
    tiles = {"laser_emitter.png"},
    groups = {cracky = 3, oddly_breakable_by_hand = 1},
    paramtype2 = "facedir",
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string("laser_color", "red")  -- Default color
        local timer = minetest.get_node_timer(pos)
        timer:start(0.1)
    end,
    on_timer = function(pos, elapsed)
        -- Find direction the laser is facing
        local node = minetest.get_node(pos)
        local dir = minetest.facedir_to_dir(node.param2)
        local next_pos = vector.add(pos, dir)

        -- Get the color from the metadata
        local meta = minetest.get_meta(pos)
        local laser_color = meta:get_string("laser_color") or "red"

        -- Emit the laser particle
        minetest.add_particlespawner({
            amount = 1,
            time = 0.1,
            minpos = vector.add(pos, vector.new(0, 0.5, 0)),
            maxpos = vector.add(pos, vector.new(0, 0.5, 0)),
            minvel = vector.new(0, 0, 0),
            maxvel = vector.new(0, 0, 0),
            minsize = 1,
            maxsize = 1,
            texture = "laser_particle.png",
            glow = 14, -- Brightness
            color = laser_color,
        })

        -- Check for collision with nodes and mine the block
        local target_node = minetest.get_node(next_pos)

        if target_node.name ~= "air" and target_node.name ~= "laser_mod:laser_receiver" then
            -- If the node is not air or a laser receiver, mine it (drop the node as an item)
            local drops = minetest.get_node_drops(target_node.name, "")
            for _, drop in ipairs(drops) do
                minetest.add_item(next_pos, drop)  -- Drop the mined item at the position
            end
            -- Remove the node from the world
            minetest.set_node(next_pos, {name = "air"})
        end

        return true
    end,
    on_punch = function(pos, node, puncher, pointed_thing)
        -- When punched with a dye, change the laser color
        local meta = minetest.get_meta(pos)
        local color = puncher:get_wielded_item():get_name()
        if string.sub(color, 1, 4) == "dye:" then
            meta:set_string("laser_color", string.sub(color, 5))
        end
    end,
})

-- Register the laser receiver node
minetest.register_node("laser_mod:laser_receiver", {
    description = "Laser Receiver",
    tiles = {"laser_receiver.png"},
    groups = {cracky = 3, oddly_breakable_by_hand = 1},
    on_construct = function(pos)
        -- Laser receiver does nothing special on construction
    end,
})

-- Register a simple item to represent the laser item drops
minetest.register_craftitem("laser_mod:laser_item", {
    description = "Laser Item",
    inventory_image = "laser_item.png",
})

