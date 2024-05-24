array<float> g_rgflLastFlashlightToggleTime;

void PluginInit() {
    g_Module.ScriptInfo.SetAuthor("xWhitey");
    g_Module.ScriptInfo.SetContactInfo("@tyabus at Discord");
    
    g_rgflLastFlashlightToggleTime.resize(0);
    g_rgflLastFlashlightToggleTime.resize(33);
    
    g_Hooks.RegisterHook(Hooks::Player::PlayerPreThink, @HOOKED_PlayerPreThink);
}

void MapInit() {
    g_rgflLastFlashlightToggleTime.resize(0);
    g_rgflLastFlashlightToggleTime.resize(33);
}

HookReturnCode HOOKED_PlayerPreThink(CBasePlayer@ _Player, uint& out _Flags) {
    if (_Player.pev.impulse == 100) {
        if (g_Engine.time - g_rgflLastFlashlightToggleTime[_Player.entindex()] < 0.2f)
            _Player.pev.impulse = 0;
        else
            g_rgflLastFlashlightToggleTime[_Player.entindex()] = g_Engine.time;
    }
    
    return HOOK_CONTINUE;
}
