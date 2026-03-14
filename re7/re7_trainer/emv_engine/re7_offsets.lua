--[[
    re7_offsets.lua — Centralized Offset Registry for RE7
    EMV Engine Module

    RE7 uses the older RE Engine (before RE2R), so offsets differ from RE8/RE9.
    These need to be verified against the RE7 binary.

    Based on EMV Engine by alphaZomega (https://github.com/alphazolam/EMV-Engine)
]]

local RE7_OFFSETS = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- Offset Table (TODO: verify against RE7 binary)
-- ═══════════════════════════════════════════════════════════════════════════

RE7_OFFSETS.offsets = {
    -- GameObject / Component chain
    gameobject_base      = 0x10,   -- Component → owning GameObject
    component_next       = 0x10,   -- Component → next component (RE7 uses 0x10, RE9 is 0x18)
    retype_super         = 0x10,   -- RE type → super (parent type) pointer

    -- Resource holder
    resource_ptr         = 0x10,   -- ResourceHolder → resource pointer

    -- Transform
    transform_joint_base = 0x80,   -- Transform → joints array base (TODO: verify)
    transform_joint_stride = 0x50, -- Per-joint stride (TODO: verify)

    -- Character / Player
    player_hitpoint      = 0x58,   -- BaseActor → HitPoint component (TODO: verify)

    -- Camera
    camera_fov           = 0x44,   -- Camera → FOV field (TODO: verify)
}

-- ═══════════════════════════════════════════════════════════════════════════
-- Safe Accessor
-- ═══════════════════════════════════════════════════════════════════════════

function RE7_OFFSETS.get(name)
    local val = RE7_OFFSETS.offsets[name]
    if val == nil then
        if log then
            log.warn("[EMV] RE7_OFFSETS: unknown offset '" .. tostring(name) .. "', returning 0x0")
        end
        return 0x0
    end
    return val
end

function RE7_OFFSETS.dump()
    if not log then return end
    log.info("[EMV] RE7 Offset Registry:")
    for name, val in pairs(RE7_OFFSETS.offsets) do
        log.info(("  %-28s = 0x%X"):format(name, val))
    end
end

return RE7_OFFSETS
