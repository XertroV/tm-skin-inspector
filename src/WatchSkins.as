void WatchSkins() {
    uint lastNbPlayers = 0;
    auto net = GetApp().Network;

    while (true) {
        sleep(50);
        if (!S_LogSkins) continue;

        if (lastNbPlayers != net.PlayerInfos.Length) {
            lastNbPlayers = net.PlayerInfos.Length;
            CheckForNewSkins(net);
        }
    }
}

void CheckForNewSkins(CGameCtnNetwork@ net) {
    for (uint i = 0; i < net.PlayerInfos.Length; i++) {
        auto pi = cast<CTrackManiaPlayerInfo>(net.PlayerInfos[i]);
        if (!HasSeen(pi))
            LogPlayerSkin(cast<CTrackManiaNetworkServerInfo>(net.ServerInfo), pi);
    }
}


string SkinKey(CTrackManiaPlayerInfo@ pi) {
    return pi.Login + pi.Model_CarSport_SkinUrl;
}

bool HasSeen(CTrackManiaPlayerInfo@ pi) {
    return seenSkins.Exists(SkinKey(pi));
}

void SeenSkin(CTrackManiaPlayerInfo@ pi) {
    seenSkins[SkinKey(pi)] = true;
}
