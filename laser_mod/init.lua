-- Table to store laser colors
local laser_colors = {
    red = "#FF0000",
    green = "#00FF00",
    blue = "#0000FF",
    yellow = "#FFFF00",
    purple = "#800080",
    orange = "#FFA500",
    white = "#FFFFFF",
    black = "#000000",
}

-- Register the laser emitter node
minetest.register_node("laser_mod:laser_emitter", {
    description = "Laser Emitter",
    tiles = {"laser_emitter.png"},
    groups = {cracky = 3, oddly_breakable_by_hand = 1},
    paramtype2 = "facedir",  -- Allows the node to have a facing direction
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string("laser_color", "red") -- Default laser color
        local timer = minetest.get_node_timer(pos)
        timer:start(0.1) -- Trigger laser periodically
    end,
    on_timer = function(pos)
        local node = minetest.get_node(pos)
        -- Get the direction the node is facing (param2 defines the direction)
        local dir = minetest.facedir_to_dir(node.param2)
        local start_pos = vector.add(pos, dir)  -- Start position is the emitter's position

        -- Get laser color from metadata
        local meta = minetest.get_meta(pos)
        local color = meta:get_string("laser_color")
        local laser_color_code = laser_colors[color] or "#FF0000"  -- Default red if not set

        local laser_pos = vector.new(start_pos)
        while true do
            local node_at = minetest.get_node_or_nil(laser_pos)
            if not node_at or node_at.name == "laser_mod:laser_receiver" then
                break  -- Stop the laser at the receiver or air
            end

            if node_at.name ~= "air" then
                -- Destroy the node the laser hits
                minetest.remove_node(laser_pos)
            end

            -- Check for players in the beam
            local players = minetest.get_objects_inside_radius(laser_pos, 0.5)
            for _, player in ipairs(players) do
                if player:is_player() then
                    player:set_hp(player:get_hp() - 10)  -- Damage player
                end
            end

            -- Add the particle effect to visualize the laser
            minetest.add_particle({
                pos = laser_pos,
                velocity = {x = 0, y = 0, z = 0},
                acceleration = {x = 0, y = 0, z = 0},
                expirationtime = 0.1,
                size = 4,
                collisiondetection = false,
                vertical = false,
                texture = "laser_particle.png",  -- Laser particle texture
            })

            -- Move the laser beam forward one step
            laser_pos = vector.add(laser_pos, dir)
        end

        return true  -- Continue the timer
    end,
    on_punch = function(pos, _, puncher, pointed_thing)
        local item = puncher:get_wielded_item()
        local dye_name = item:get_name():match("^dye:(.+)$") -- Check if it's a dye
        if dye_name and laser_colors[dye_name] then
            local meta = minetest.get_meta(pos)
            meta:set_string("laser_color", dye_name)
            minetest.chat_send_player(puncher:get_player_name(), "Laser color changed to " .. dye_name)
        end
    end,
})

-- Register the laser receiver node
minetest.register_node("laser_mod:laser_receiver", {
    description = "Laser Receiver",
    tiles = {"laser_receiver.png"},
    groups = {cracky = 3, oddly_breakable_by_hand = 1},
    on_construct = function(pos)
        -- Placeholder for any receiver-specific logic
    end,
})

-- Add crafting recipes (optional)
minetest.register_craft({
    output = "laser_mod:laser_emitter",
    recipe = {
        {"default:steel_ingot", "default:mese_crystal", "default:steel_ingot"},
        {"", "default:glass", ""},
        {"", "default:steel_ingot", ""},
    },
})

minetest.register_craft({
    output = "laser_mod:laser_receiver",
    recipe = {
        {"default:steel_ingot", "default:mese_crystal", "default:steel_ingot"},
        {"", "default:glass", ""},
        {"", "default:steel_ingot", ""},
    },
})
