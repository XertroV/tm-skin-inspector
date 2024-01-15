void LogPlayerSkin(CTrackManiaNetworkServerInfo@ si, CTrackManiaPlayerInfo@ player) {
    SeenSkin(player);
    // don't log server
    if (si.ServerLogin == player.Login) return;
    Skin_Logs.InsertLast(Skin_Log(si, player));
}

dictionary seenSkins;
Skin_Log@[] Skin_Logs;

class Skin_Log {
    int64 loadTime;
    string Name;
    string Login;
    string WebServicesUserId;
    string Prestige_SkinOptions;
    string Model_CarSport_SkinName;
    string Short_SkinName;
    string Model_CarSport_SkinUrl;
    string Short_SkinURL;
    string Character_SkinOptions;
    string Model_CharacterPilot_SkinName;
    string Model_CharacterPilot_SkinUrl;
    string ServerName;
    string ServerLogin;
    string ServerDetails;

    Skin_Log(CTrackManiaNetworkServerInfo@ si, CTrackManiaPlayerInfo@ player) {
        loadTime = Time::Stamp;
        this.Name = player.Name;
        this.Login = player.Login;
        this.ServerName = si.ServerName;
        this.ServerLogin = si.ServerLogin;
        this.WebServicesUserId = player.WebServicesUserId;
        this.Prestige_SkinOptions = player.Prestige_SkinOptions;
        this.Model_CarSport_SkinName = player.Model_CarSport_SkinName;
        Short_SkinName = Model_CarSport_SkinName.Replace("Skins\\Models\\CarSport\\", "");
        this.Model_CarSport_SkinUrl = player.Model_CarSport_SkinUrl;
        Short_SkinURL = Model_CarSport_SkinUrl.Replace("https://core.trackmania.nadeo.live/storageObjects/", "");
        this.Character_SkinOptions = player.Character_SkinOptions;
        this.Model_CharacterPilot_SkinName = player.Model_CharacterPilot_SkinName;
        this.Model_CharacterPilot_SkinUrl = player.Model_CharacterPilot_SkinUrl;

        ServerDetails = "Seen on Server:\nName: " + ServerName + "\nLogin: " + ServerLogin;
    }

    string ToString() {
        return "Skin_Log( " + Name + ", " + Login + ", " + Model_CarSport_SkinName + ", " + Model_CarSport_SkinUrl + " )";
    }

    string get_HumanTimeDelta() {
        return HumanizeTime(loadTime - Time::Stamp);
    }

    // cols = 8
    void DrawRow() {
        UI::TableNextRow();


        UI::PushID(Login + loadTime);

        bool inGameSkin = Model_CarSport_SkinUrl.Length == 0;
        // string inGameColorMod = inGameSkin ? "\\$999" : "";
        if (inGameSkin) {
            UI::PushStyleColor(UI::Col::Text, vec4(.6, .6, .6, 1));
        }

        UI::TableNextColumn();
        UI::AlignTextToFramePadding();
        UI::Text(HumanTimeDelta);

        UI::TableNextColumn();
        CopiableValue(Name);

        UI::TableNextColumn();
        CopiableValue(Login);
        AddSimpleTooltip(WebServicesUserId);
        UI::SameLine();
        if (UI::Button(Icons::FilesO + " WSID")) {
            SetClipboard(WebServicesUserId);
        }

        UI::TableNextColumn();
        UI::Text(Short_SkinName);
        HandOnHover();
        if (UI::IsItemClicked()) { SetClipboard(Model_CarSport_SkinName); }
        AddSimpleTooltip(Model_CarSport_SkinName);

        UI::TableNextColumn();
        CopiableValue(Prestige_SkinOptions);
        AddSimpleTooltip(Prestige_SkinOptions);

        UI::TableNextColumn();
        // CopiableValue(Model_CarSport_SkinUrl);
        UI::Text(Short_SkinURL);
        HandOnHover();
        if (UI::IsItemClicked()) { SetClipboard(Model_CarSport_SkinUrl); }
        AddSimpleTooltip(Model_CarSport_SkinUrl);

        UI::TableNextColumn();
        // UI::BeginDisabled(fid is null);
        if (UI::Button("TM.IO")) {
            OpenBrowserURL("https://trackmania.io/#/player/" + WebServicesUserId);
        }
        UI::SameLine();
        if (UI::Button(Icons::FilesO + " All")) {
            SetClipboard(AsCSVRow());
        }

        UI::TableNextColumn();
        UI::Text(ServerName);
        HandOnHover();
        if (UI::IsItemClicked()) { SetClipboard(ServerDetails); }
        AddSimpleTooltip(ServerDetails);

        if (inGameSkin) {
            UI::PopStyleColor();
        }

        UI::PopID();
    }

    string AsCSVRow() {
        return StripFormatCodes(string::Join({tostring(loadTime), Name, Login, WebServicesUserId, Model_CarSport_SkinName, Prestige_SkinOptions, Model_CarSport_SkinUrl, Model_CharacterPilot_SkinName, Character_SkinOptions, Model_CharacterPilot_SkinUrl, ServerName, ServerLogin}, ', '));
    }
}


void ExportSkinLogCSV() {
    auto filename = "SkinLog_" + Time::Stamp + ".csv";
    IO::File f(IO::FromStorageFolder(filename), IO::FileMode::Write);
    f.WriteLine("Timestamp, Name, Login, WebServicesUserId, Model_CarSport_SkinName, Prestige_SkinOptions, Model_CarSport_SkinUrl, Model_CharacterPilot_SkinName, Character_SkinOptions, Model_CharacterPilot_SkinUrl, ServerName, ServerLogin");
    for (uint i = 0; i < Skin_Logs.Length; i++) {
        f.WriteLine(Skin_Logs[i].AsCSVRow());
    }
    f.Close();
    Notify("Saved Skin Log CSV: " + IO::FromStorageFolder(filename));
    if (g_AfterCSVOpenFolder) {
        OpenExplorerPath(IO::FromStorageFolder(""));
    }
}
