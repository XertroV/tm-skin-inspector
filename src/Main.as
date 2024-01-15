const string PLUGIN_NAME = Meta::ExecutingPlugin().Name;
const string PLUGIN_ICON = Icons::Car + Icons::ListAlt;
const string MenuTitle = "\\$8f3" + PLUGIN_ICON + "\\$z " + PLUGIN_NAME;

#if DEPENDENCY_GHOSTS_PP || DEV
bool HAS_GPP = true;
#else
bool HAS_GPP = false;
#endif

#if DEPENDENCY_GHOSTS_DEV || DEV
const string GPP_NAME = "ghosts++-dev";
#else
const string GPP_NAME = "ghosts-pp";
#endif

bool GPP_DependencyCheck() {
    // just calling code, so not relyant on the plugin being enabled i think.
    return HAS_GPP; // && Meta::GetPluginFromID(GPP_NAME).Enabled;
}

[Setting hidden]
bool g_AfterCSVOpenFolder = false;

void Main() {
    startnew(WatchSkins);
    trace("G++ detected: " + HAS_GPP);
}

void Unload() {
}
void OnDestroyed() { Unload(); }
void OnDisabled() { Unload(); }

UI::Font@ g_MonoFont;
UI::Font@ g_BoldFont;
UI::Font@ g_BigFont;
UI::Font@ g_MidFont;
void LoadFonts() {
    @g_BoldFont = UI::LoadFont("DroidSans-Bold.ttf");
    @g_MonoFont = UI::LoadFont("DroidSansMono.ttf");
    @g_BigFont = UI::LoadFont("DroidSans.ttf", 26);
    @g_MidFont = UI::LoadFont("DroidSans.ttf", 20);
}

void Notify(const string &in msg) {
    UI::ShowNotification(Meta::ExecutingPlugin().Name, msg);
    trace("Notified: " + msg);
}

void NotifyError(const string &in msg) {
    warn(msg);
    UI::ShowNotification(Meta::ExecutingPlugin().Name + ": Error", msg, vec4(.9, .3, .1, .3), 15000);
}

void NotifyWarning(const string &in msg) {
    warn(msg);
    UI::ShowNotification(Meta::ExecutingPlugin().Name + ": Warning", msg, vec4(.9, .6, .2, .3), 15000);
}


string HumanizeTime(int64 secondsDelta) {
    auto abs = Math::Abs(secondsDelta);
    auto units = abs < 60 ? " s" : abs < 3600 ? " m" : " h";
    auto val = abs / (abs < 60 ? 1 : abs < 3600 ? 60 : 3600);
    auto dir = secondsDelta <= 0 ? " ago" : " away";
    return tostring(val) + units + dir;
}


// show the window immediately upon installation
[Setting hidden]
bool ShowWindow = true;


/** Render function called every frame intended only for menu items in `UI`. */
void RenderMenu() {
    if (UI::MenuItem(MenuTitle, "", ShowWindow)) {
        ShowWindow = !ShowWindow;
    }
}



/** Render function called every frame intended for `UI`.
*/
void RenderInterface() {
    if (!ShowWindow) return;
    UI::SetNextWindowSize(800, 560, UI::Cond::FirstUseEver);
    UI::PushStyleColor(UI::Col::FrameBg, vec4(.2, .2, .2, .5));
    if (UI::Begin(MenuTitle, ShowWindow)) {
        UI::PushFont(g_MonoFont);

        DrawInterfaceInner();

        UI::PopFont();
    }
    UI::End();
    UI::PopStyleColor();
}

void AddSimpleTooltip(const string &in msg) {
    if (UI::IsItemHovered()) {
        UI::SetNextWindowSize(400, 0, UI::Cond::Appearing);
        UI::BeginTooltip();
        UI::TextWrapped(msg);
        UI::EndTooltip();
    }
}
