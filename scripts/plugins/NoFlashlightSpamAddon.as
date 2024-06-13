array<float> g_rgflLastFlashlightToggleTime;
array<CScheduledFunction@> g_rgpfnWatchdog;
array<int> g_rgiBackupFlashBattery;
array<bool> g_rgbBackupHasSuit;
array<bool> g_rgbHadFlashlightFlagPrevCall;

void PluginInit() {
    g_Module.ScriptInfo.SetAuthor("xWhitey");
    g_Module.ScriptInfo.SetContactInfo("@tyabus at Discord");
    
    g_rgflLastFlashlightToggleTime.resize(0);
    g_rgflLastFlashlightToggleTime.resize(33);
    g_rgiBackupFlashBattery.resize(0);
    g_rgiBackupFlashBattery.resize(33);
    g_rgpfnWatchdog.resize(0);
    g_rgpfnWatchdog.resize(33);
    g_rgbBackupHasSuit.resize(0);
    g_rgbBackupHasSuit.resize(33);
    g_rgbHadFlashlightFlagPrevCall.resize(0);
    g_rgbHadFlashlightFlagPrevCall.resize(33);
    
    for (uint idx = 0; idx < g_rgiBackupFlashBattery.length(); idx++) {
        g_rgiBackupFlashBattery[idx] = -1;
    }
    
    for (int idx = 1; idx <= g_Engine.maxClients; ++idx) {
        @g_rgpfnWatchdog[idx] = g_Scheduler.SetTimeout("Watchdog", 0.1f, idx);
    }
}

void MapInit() {
    g_rgflLastFlashlightToggleTime.resize(0);
    g_rgflLastFlashlightToggleTime.resize(33);
    g_rgiBackupFlashBattery.resize(0);
    g_rgiBackupFlashBattery.resize(33);
    g_rgbBackupHasSuit.resize(0);
    g_rgbBackupHasSuit.resize(33);
    g_rgbHadFlashlightFlagPrevCall.resize(0);
    g_rgbHadFlashlightFlagPrevCall.resize(33);
    
    for (uint idx = 0; idx < g_rgiBackupFlashBattery.length(); idx++) {
        g_rgiBackupFlashBattery[idx] = -1;
    }
    
    for (uint idx = 0; idx < g_rgpfnWatchdog.length(); idx++) {
        CScheduledFunction@ pfnSched = @g_rgpfnWatchdog[idx];
        if (pfnSched !is null && !pfnSched.HasBeenRemoved()) {
            g_Scheduler.RemoveTimer(pfnSched);
        }
    }
    
    g_rgpfnWatchdog.resize(0);
    g_rgpfnWatchdog.resize(33);
    
    for (int idx = 1; idx <= g_Engine.maxClients; ++idx) {
        @g_rgpfnWatchdog[idx] = g_Scheduler.SetTimeout("Watchdog", 0.1f, idx);
    }
}

//We actually won't be able to catch the moment when the player tooggles their flashlight and speedhacks if wootguy's anticheat is installed on the server
//Because it cancels PlayerPreThink and PlayerPostThink events if player's speedhack state is SPEEDHACK_FAST, so we need to use schedulers instead.
//If this is used both with NoFlashlightSpam (not this addon), this penalty will kick in if the player is speedhacking and spamming flashlight.
void Watchdog(int _PlayerIdx) {
    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(_PlayerIdx);
    if (pPlayer is null || !pPlayer.IsConnected()) {
        @g_rgpfnWatchdog[_PlayerIdx] = g_Scheduler.SetTimeout("Watchdog", 0.0f, _PlayerIdx);
        return;
    }
    
    if ((pPlayer.pev.effects & EF_DIMLIGHT) != 0) {
        if (!g_rgbHadFlashlightFlagPrevCall[_PlayerIdx]) {
            if (g_Engine.time - g_rgflLastFlashlightToggleTime[_PlayerIdx] < 0.7f) {
                if (g_rgiBackupFlashBattery[_PlayerIdx] == -1) {
                    g_rgiBackupFlashBattery[_PlayerIdx] = pPlayer.m_iFlashBattery;
                    pPlayer.m_iFlashBattery = 0;
                    g_rgbBackupHasSuit[_PlayerIdx] = pPlayer.HasSuit();
                    pPlayer.SetHasSuit(false);
                }
            }
            g_rgflLastFlashlightToggleTime[_PlayerIdx] = g_Engine.time;
            g_rgbHadFlashlightFlagPrevCall[_PlayerIdx] = true;
        }
    } else {
        g_rgbHadFlashlightFlagPrevCall[_PlayerIdx] = false;
    }
    
    if (g_rgiBackupFlashBattery[_PlayerIdx] != -1 && g_Engine.time - g_rgflLastFlashlightToggleTime[_PlayerIdx] > 0.7f) {
        pPlayer.m_iFlashBattery = g_rgiBackupFlashBattery[_PlayerIdx];
        g_rgiBackupFlashBattery[_PlayerIdx] = -1;
        pPlayer.SetHasSuit(g_rgbBackupHasSuit[_PlayerIdx]);
    }
    
    @g_rgpfnWatchdog[_PlayerIdx] = g_Scheduler.SetTimeout("Watchdog", 0.0f, _PlayerIdx);
}
