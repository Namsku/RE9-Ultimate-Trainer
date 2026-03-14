--[[
    game_config.lua — RE7-specific scan functions + manager configuration
    
    This module adapts the generic Objects Tab scan functions to RE7's SDK types.
    RE7 uses different manager names and APIs compared to RE9.
    
    Key differences from RE9:
      - Enemies: app.EnemyOrder / app.EnemyActionController (not app.CharacterManager)
      - Items:   app.ItemSlotManager / app.Item (not app.ItemManager)
      - Spawns:  app.EnemyGenerator (not app.ItemSpawner)
      - HP:      app.EnemyStatus / Health/MaxHealth fields (not app.HitPoint)
]]

local GameConfig = {}

local function mgr(name)
    local ok, m = pcall(sdk.get_managed_singleton, name)
    if ok and m then return m end
    return nil
end

-- ═══════════════════════════════════════════════════════════════════════════
-- RE7 Enemy Types (used for display names)
-- ═══════════════════════════════════════════════════════════════════════════

local ENEMY_NAMES = {
    em2000 = "Jack Baker",
    em2050 = "Jack (Cutscene)",
    em2100 = "Jack Transformed",
    em2150 = "Jack (Cutscene 2)",
    em3000 = "Marguerite Baker",
    em3100 = "Molded (Standard)",
    em3101 = "Molded (Bedroom)",
    em3102 = "Molded (Fast)",
    em3200 = "Marguerite Bugs",
    em3300 = "Molded (Crawl)",
    em3400 = "Bugs",
    em3500 = "Centipede",
    em3600 = "Molded (Fat)",
    em3700 = "Molded (Quick)",
    em4000 = "Molded (Blade)",
    em4100 = "Molded (Flying)",
    em4200 = "Molded (Fat Blade)",
    em5400 = "Eveline",
    em5500 = "Eveline (Child)",
    em5600 = "Mannequin",
    em6000 = "Mia",
    em8000 = "Jack (Chainsaw)",
    em8001 = "Jack (Mutant)",
    em8010 = "Jack (Garage)",
    em8100 = "Marguerite (Mutant)",
    em8900 = "Lucas Trap",
    em8940 = "Final Boss",
    em8950 = "Final Boss (Arm)",
    em9200 = "Mia (Infected)",
}

local function guess_enemy_name(obj_name)
    local lower = obj_name:lower()
    for prefix, display in pairs(ENEMY_NAMES) do
        if lower:find(prefix, 1, true) then
            return display
        end
    end
    return nil
end

-- ═══════════════════════════════════════════════════════════════════════════
-- RE7 Scan: Enemies via scene component search
-- ═══════════════════════════════════════════════════════════════════════════

local function scan_enemies_re7(make_entry)
    local out = {}
    
    local scene = nil
    pcall(function()
        scene = sdk.call_native_func(
            sdk.get_native_singleton("via.SceneManager"),
            sdk.find_type_definition("via.SceneManager"),
            "get_CurrentScene()"
        )
    end)
    if not scene then return out, 0, "no scene" end

    -- Find all EnemyOrder components (each enemy has one)
    local td = sdk.find_type_definition("app.EnemyOrder")
    if not td then return out, 0, "EnemyOrder type not found" end

    local comps = nil
    pcall(function() comps = scene:call("findComponents(System.Type)", td:get_runtime_type()) end)
    if not comps then return out, 0, "findComponents nil" end

    local ok, n = pcall(comps.call, comps, "get_Count")
    if not ok or not n or n <= 0 then return out, 0, "0 enemies" end

    for i = 0, math.min(n - 1, 200) do
        pcall(function()
            local eo = comps:call("get_Item", i)
            if not eo then return end
            local go = eo:call("get_GameObject")
            if not go then return end

            local entry = make_entry(go)
            if not entry then return end

            -- Try to get friendly enemy name
            local display = guess_enemy_name(entry.name)
            if display then
                entry.name = display .. " (" .. entry.name .. ")"
            end

            -- Try to read HP from EnemyStatus save data pattern
            pcall(function()
                local status = eo:call("get_EnemyStatus") or eo:get_field("_EnemyStatus")
                if status then
                    local hp = status:get_field("Health") or status:call("get_Health")
                    local maxhp = status:get_field("MaxHealth") or status:call("get_MaxHealth")
                    if hp and maxhp then
                        entry.name = entry.name .. string.format(" [HP:%.0f/%.0f]", hp, maxhp)
                    end
                end
            end)

            out[#out + 1] = entry
        end)
    end

    return out, n, n .. " enemies"
end

-- ═══════════════════════════════════════════════════════════════════════════
-- RE7 Scan: Items via scene component search
-- ═══════════════════════════════════════════════════════════════════════════

local function scan_items_re7(make_entry)
    local out = {}

    local scene = nil
    pcall(function()
        scene = sdk.call_native_func(
            sdk.get_native_singleton("via.SceneManager"),
            sdk.find_type_definition("via.SceneManager"),
            "get_CurrentScene()"
        )
    end)
    if not scene then return out, 0, "no scene" end

    -- Try multiple item component types
    local item_types = {
        "app.ItemCore",
        "app.ItemPickup",
        "app.Item",
        "app.InteractItemController",
    }

    local total = 0
    local seen = {}

    for _, type_name in ipairs(item_types) do
        local td = sdk.find_type_definition(type_name)
        if td then
            pcall(function()
                local comps = scene:call("findComponents(System.Type)", td:get_runtime_type())
                if not comps then return end
                local ok, n = pcall(comps.call, comps, "get_Count")
                if not ok or not n or n <= 0 then return end

                for i = 0, math.min(n - 1, 300) do
                    pcall(function()
                        local comp = comps:call("get_Item", i)
                        if not comp then return end
                        local go = comp:call("get_GameObject")
                        if not go then return end
                        local addr = go:get_address()
                        if seen[addr] then return end
                        seen[addr] = true

                        local entry = make_entry(go)
                        if entry then
                            entry.name = "[" .. type_name:gsub("app%.", "") .. "] " .. entry.name
                            out[#out + 1] = entry
                            total = total + 1
                        end
                    end)
                end
            end)
        end
    end

    return out, total, total .. " items"
end

-- ═══════════════════════════════════════════════════════════════════════════
-- RE7 Scan: Enemy Spawners (EnemyGenerator)
-- ═══════════════════════════════════════════════════════════════════════════

local function scan_spawners_re7(make_entry)
    local out = {}

    local scene = nil
    pcall(function()
        scene = sdk.call_native_func(
            sdk.get_native_singleton("via.SceneManager"),
            sdk.find_type_definition("via.SceneManager"),
            "get_CurrentScene()"
        )
    end)
    if not scene then return out, 0, "no scene" end

    local td = sdk.find_type_definition("app.EnemyGenerator")
    if not td then return out, 0, "EnemyGenerator type not found" end

    local comps = nil
    pcall(function() comps = scene:call("findComponents(System.Type)", td:get_runtime_type()) end)
    if not comps then return out, 0, "findComponents nil" end

    local ok, n = pcall(comps.call, comps, "get_Count")
    if not ok or not n or n <= 0 then return out, 0, "0 spawners" end

    for i = 0, math.min(n - 1, 300) do
        pcall(function()
            local gen = comps:call("get_Item", i)
            if not gen then return end
            local go = gen:call("get_GameObject")
            if not go then return end

            local entry = make_entry(go)
            if entry then
                entry.name = "[Spawner] " .. entry.name

                -- Try to get what enemy type it spawns
                pcall(function()
                    local eid = gen:get_field("_EnemyID") or gen:call("get_EnemyID")
                    if eid then
                        local eid_str = tostring(eid)
                        local display = guess_enemy_name(eid_str:lower())
                        if display then
                            entry.name = entry.name .. " → " .. display
                        else
                            entry.name = entry.name .. " → " .. eid_str
                        end
                    end
                end)

                out[#out + 1] = entry
            end
        end)
    end

    return out, n, n .. " spawners"
end

-- ═══════════════════════════════════════════════════════════════════════════
-- Register with ObjectsTab
-- ═══════════════════════════════════════════════════════════════════════════

function GameConfig.register(ObjectsTab)
    -- Override the scan functions used by ObjectsTab
    -- The ObjectsTab expects scan functions to be called with make_entry as first arg
    if ObjectsTab._set_scan_functions then
        ObjectsTab._set_scan_functions({
            enemies  = scan_enemies_re7,
            items    = scan_items_re7,
            spawners = scan_spawners_re7,
        })
    else
        -- Fallback: store in global for ObjectsTab to pick up
        _G._RE7_SCAN = {
            enemies  = scan_enemies_re7,
            items    = scan_items_re7,
            spawners = scan_spawners_re7,
        }
    end
end

return GameConfig
