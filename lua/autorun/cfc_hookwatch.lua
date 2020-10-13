AddCSLuaFile()

require( "cfclogger" )
local Alerter = CFCLogger( "HookWatch", "debug" )

local function wrapHookAdd()
    local originalHookAdd = hook.Add

    hook.Add = function( eventName, identifier, func )
        if not isstring( identifier ) then
            Alerter:warn( "A hook with a non-string identifier was added! This can cause performance issues if the hook is called frequently.", eventName, identifier )
            debug.traceback()
        end

        originalHookAdd( eventName, identifier, func )
    end
end

hook.Add( "OnGamemodeLoaded", "CFC_HookWatch", wrapHookAdd )
