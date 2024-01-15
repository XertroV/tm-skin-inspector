void DrawInterfaceInner() {
    UI::BeginTabBar("skinlogtabs");

    if (UI::BeginTabItem("Current Server")) {
        DrawCurrentServer();
        UI::EndTabItem();
    }

    if (UI::BeginTabItem("Skin Log")) {
        DrawSkinLogTable();
        UI::EndTabItem();
    }

    if (HAS_GPP) {
        if (UI::BeginTabItem("Ghost Skins")) {
            DrawGhostSkinsInspector();
            UI::EndTabItem();
        }
    }

    UI::EndTabBar();
}


bool newAtTop = true;


void DrawSkinLogTable() {
    S_LogSkins = UI::Checkbox("Logging Active", S_LogSkins);
    UI::SameLine();
    newAtTop = UI::Checkbox("New First", newAtTop);
    UI::SameLine();
    UI::Dummy(vec2(50, 0));
    UI::SameLine();
    if (UI::Button("Export CSV")) {
        // Skin_Logs.RemoveRange(0, Skin_Logs.Length);
        startnew(ExportSkinLogCSV);
    }
    UI::SameLine();
    g_AfterCSVOpenFolder = UI::Checkbox("Open Folder after CSV", g_AfterCSVOpenFolder);
    UI::SameLine();
    UI::Dummy(vec2(50, 0));
    UI::SameLine();
    if (UI::Button("Clear Log")) {
        Skin_Logs.RemoveRange(0, Skin_Logs.Length);
        seenSkins.DeleteAll();
    }


    UI::PushStyleVar(UI::StyleVar::FramePadding, vec2(2, 0));
    if (UI::BeginChild("skinlogchild")) {
        if (UI::BeginTable("skinlog", 8, UI::TableFlags::SizingFixedFit)) {
            UI::TableSetupColumn("Time Ago", UI::TableColumnFlags::WidthFixed, 60);
            UI::TableSetupColumn("Name", UI::TableColumnFlags::WidthFixed, 100);
            UI::TableSetupColumn("Login", UI::TableColumnFlags::WidthFixed, 240);
            UI::TableSetupColumn("Skin Name", UI::TableColumnFlags::WidthStretch, 100);
            UI::TableSetupColumn("Prestige Opts.", UI::TableColumnFlags::WidthStretch, 70);
            UI::TableSetupColumn("Skin URL", UI::TableColumnFlags::WidthStretch, 120);
            UI::TableSetupColumn("", UI::TableColumnFlags::WidthFixed, 100);
            UI::TableSetupColumn("Seen on Server", UI::TableColumnFlags::WidthFixed, 120);

            UI::TableHeadersRow();

            uint nbLogEntries = Skin_Logs.Length;
            UI::ListClipper clip(nbLogEntries);
            while (clip.Step()) {
                for (int i = clip.DisplayStart; i < clip.DisplayEnd; i++) {
                    auto ix = newAtTop ? nbLogEntries - i - 1 : i;
                    UI::PushID(ix);
                    Skin_Logs[ix].DrawRow();
                    UI::PopID();
                }
            }
            UI::EndTable();
        }
    }
    UI::EndChild();
    UI::PopStyleVar();
}


void DrawCurrentServer() {
    auto net = GetApp().Network;
    if (net is null) {
        UI::Text("No App.Network!?");
        return;
    }
    if (net.PlayerInfos.Length == 0) {
        UI::Text("No players.");
        return;
    }

    UI::PushStyleVar(UI::StyleVar::FramePadding, vec2(2, 0));
    if (UI::BeginChild("skincurrchild")) {
        // if (UI::BeginTable("skinsnet", 8, UI::TableFlags::SizingStretchProp)) {
        //     UI::ListClipper clip(Skin_Logs.Length);
        //     while (clip.Step()) {
        //         for (int i = clip.DisplayStart; i < clip.DisplayEnd; i++) {
        //             UI::PushID(i);
        //             Skin_Logs[i].DrawRow();
        //             UI::PopID();
        //         }
        //     }
        //     UI::EndTable();
        // }
        for (uint i = 0; i < net.PlayerInfos.Length; i++) {
            DrawNetPlayerInfo(cast<CTrackManiaPlayerInfo>(net.PlayerInfos[i]));
        }
    }
    UI::EndChild();
    UI::PopStyleVar();
}

void DrawNetPlayerInfo(CTrackManiaPlayerInfo@ pi) {
    if (UI::TreeNode(pi.Name + "##" + pi.Login)) {
        CopiableLabelValue("Name", pi.Name);
        CopiableLabelValue("Login", pi.Login);
        CopiableLabelValue("WebServicesUserId", pi.WebServicesUserId);
        UI::SameLine();
        if (UI::Button("TM.IO")) {
            OpenBrowserURL("https://trackmania.io/#/player/" + pi.WebServicesUserId);
        }
        UI::Text("CarSport:");
        UI::Indent();
        CopiableLabelValue("SkinName", pi.Model_CarSport_SkinName);
        CopiableLabelValue("SkinOptions", pi.Prestige_SkinOptions);
        CopiableLabelValue("SkinUrl", pi.Model_CarSport_SkinUrl);
        UI::Unindent();
        UI::Text("CharacterPilot:");
        UI::Indent();
        CopiableLabelValue("SkinName", pi.Model_CharacterPilot_SkinName);
        CopiableLabelValue("SkinOptions", pi.Character_SkinOptions);
        CopiableLabelValue("SkinUrl", pi.Model_CharacterPilot_SkinUrl);
        UI::Unindent();

        UI::TreePop();
    }
}
