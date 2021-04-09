AddCSLuaFile()

local Count = table.Count
local rawset = rawset
local rawget = rawget

require( "cfclogger" )
local Alerter = CFCLogger( "HookWatch" )
CFCHookWatch = {
    initialHookCounts = {}
}

function CFCHookWatch.wrapHookAdd()
    local originalHookAdd = hook.Add

    hook.Add = function( eventName, identifier, func )
        if not isstring( identifier ) then
            Alerter:debug( "A hook with a non-string identifier was added! This can cause performance issues if the hook is called frequently.", eventName, identifier )
            debug.traceback()
        end

        originalHookAdd( eventName, identifier, func )
    end
end

function CFCHookWatch.countHooks()
    local hookCounts = {}

    for eventName, hooks in pairs(hook.GetTable()) do
        rawset( hookCounts, eventName, Count( hooks ) )
    end

    return hookCounts
end

function CFCHookWatch.timerCountThink()
    local initialCounts = CFCHookWatch.initialCounts
    for hookName, count in pairs( CFCHookWatch.countHooks() ) do
        local initialCount = initialCounts[hookName]
        local diff = count - initialCount

        if diff > 20 then
            Alerter:warn(
                "Detected potential hook bloat",
                hookName .. " has grown by " .. diff .. " listeners since session start"
            )
        end
    end
end

function CFCHookWatch.init()
    CFCHookWatch.wrapHookAdd()
    CFCHookWatch.initialHookCounts = CFCHookWatch.countHooks()
end

hook.Add( "OnGamemodeLoaded", "CFC_HookWatch", CFCHookWatch.init )
