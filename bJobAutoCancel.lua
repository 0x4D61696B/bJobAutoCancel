-- =============================================================================
--  bJobAutoCancel
--    by: BurstBiscuit
-- =============================================================================

require "math"
require "table"
require "unicode"

require "lib/lib_ChatLib"
require "lib/lib_Debug"
require "lib/lib_InterfaceOptions"

Debug.EnableLogging(false)


-- =============================================================================
--  Constants
-- =============================================================================

local c_Arcs = {
    -- Coral Forest, Sunken Harbor
    [1153] = "Omnidyne",    -- Indexing the Shipments
    [1154] = "Omnidyne",    -- Omnidyne Field Testing: Shadow
    [1168] = "Omnidyne",    -- Securing the Contract

    -- Sertao, Dredge
    [1205] = "Omnidyne",    -- The Fifth Son

    -- Sertao, Watchtower: Sea of Dunes
    [1211] = "Astrek",      -- Blue Gold I

    -- Sertao, Andreev Station
    [1185] = "Astrek",      -- Buzzards on our Backs
    [1188] = "Astrek",      -- Combing the Desert
    [1189] = "Astrek",      -- The Big Boys are Crushing Us
    [1190] = "Astrek",      -- War Relics

    -- Sertao, Lab 16
    [1214] = "Omnidyne",    -- Project IMP
    [1217] = "Omnidyne",    -- Forbidden Knowledge
    [1219] = "Omnidyne",    -- Enemies at the Gates

    -- Sertao, Forward Operating Base Sagan
    [1224] = "Kisuton",     -- With a Little Help from my Friends
    [1230] = "Kisuton",     -- Hasty Retreat
    [1232] = "Kisuton",     -- Chosen Tech
    [1233] = "Kisuton",     -- Earthbound Interference
}

local c_IconsToFactions = {
    [271169] = "Astrek",
    [271174] = "Kisuton",
    [271173] = "Omnidyne",
}


-- =============================================================================
--  Functions
-- =============================================================================

function Notification(message)
    ChatLib.Notification({text = "[bJobAutoCancel] " .. tostring(message)})
end


-- =============================================================================
--  Interface Options
-- =============================================================================

local io_Settings   = {
    Debug           = false,
    Enabled         = false,
    Notification    = false,
    Factions        = {
        Astrek      = false,
        Kisuton     = false,
        Omnidyne    = false
    }
}

function OnOptionChanged(id, value)
    if (id == "DEBUG_ENABLE") then
        Debug.EnableLogging(value)

    elseif (id == "GENERAL_ENABLE") then
        io_Settings.Enabled = value

    elseif (id == "GENERAL_NOTIFICATION") then
        io_Settings.Notification = value

    elseif (id == "FACTION_ASTREK") then
        io_Settings.Factions.Astrek = value

    elseif (id == "FACTION_KISUTON") then
        io_Settings.Factions.Kisuton = value

    elseif (id == "FACTION_OMNIDYNE") then
        io_Settings.Factions.Omnidyne = value
    end
end

do
    InterfaceOptions.SaveVersion(1)

    InterfaceOptions.AddCheckBox({
        id      = "GENERAL_ENABLE",
        label   = "Addon enabled",
        default = io_Settings.Enabled
    })
    InterfaceOptions.AddCheckBox({
        id      = "GENERAL_NOTIFICATION",
        label   = "Show notification in chat",
        default = io_Settings.Notification
    })
    InterfaceOptions.AddCheckBox({
        id      = "DEBUG_ENABLE",
        label   = "Debug mode",
        default = io_Settings.Debug
    })

    InterfaceOptions.StartGroup({label = "Factions"})
        InterfaceOptions.AddCheckBox({
            id      = "FACTION_ASTREK",
            label   = "Astrek Association",
            default = io_Settings.Factions.Astrek
        })
        InterfaceOptions.AddCheckBox({
            id      = "FACTION_KISUTON",
            label   = "Kisuton",
            default = io_Settings.Factions.Kisuton
        })
        InterfaceOptions.AddCheckBox({
            id      = "FACTION_OMNIDYNE",
            label   = "Omnidyne-M",
            default = io_Settings.Factions.Omnidyne
        })
    InterfaceOptions.StopGroup()
end


-- =============================================================================
--  Events
-- =============================================================================

function OnComponentLoad()
    InterfaceOptions.SetCallbackFunc(OnOptionChanged)
end

function OnArcStatusChanged(args)
    Debug.Event(args)

    if (io_Settings.Enabled and args.arc) then
        local factionName   = ""
        local jobStatus     = Player.GetJobStatus()
        local shouldCancel  = false

        if (c_Arcs[tonumber(args.arc)] and io_Settings.Factions[c_Arcs[tonumber(args.arc)]]) then
            Debug.Log("Canceling job (blacklist):", args.arc)

            factionName     = c_Arcs[tonumber(args.arc)]
            shouldCancel    = true

        elseif (jobStatus and jobStatus.job and jobStatus.job.icon_id and io_Settings.Factions[c_IconsToFactions[tonumber(jobStatus.job.icon_id)]]) then
            Debug.Log("Canceling job (icon_id):", args.arc)

            factionName     = c_IconsToFactions[tonumber(jobStatus.job.icon_id)] .. "*"
            shouldCancel    = true
        end

        if (shouldCancel) then
            if (io_Settings.Notification) then
                if (jobStatus and jobStatus.job and jobStatus.job.name) then
                    Notification("Canceling job " .. tostring(args.arc) .. ": " .. tostring(jobStatus.job.name) .. " (" .. tostring(factionName) .. ")")

                else
                    Debug.Warn("Missing jobStatus")
                    Notification("Canceling job " .. tostring(args.arc) .. ": <unknown> (" .. tostring(factionName) .. ")")
                end
            end

            Game.RequestCancelArc(args.arc)
        end
    end
end
