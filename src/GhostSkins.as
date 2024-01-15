const uint16 O_CTNGHOST_PRESTIGE = GetOffset("CGameCtnGhost", "LightTrailColor") - 0x10;
const uint16 O_CTNGHOST_SKINPACKDESC = GetOffset("CGameCtnGhost", "ModelIdentAuthor") + 0x20;

string CGameCtnGhost_GetPrestigeOpts(CGameCtnGhost@ g) {
    if (g is null) return "<null ghost>";
    if (!LooksLikeString(g, O_CTNGHOST_PRESTIGE)) return "<error>";
    return Dev::GetOffsetString(g, O_CTNGHOST_PRESTIGE);
}

CSystemPackDesc@ CGameCtnGhost_GetSkin(CGameCtnGhost@ g) {
    if (!LooksLikePtr(g, O_CTNGHOST_SKINPACKDESC)) return null;
    auto nod = Dev::GetOffsetNod(g, O_CTNGHOST_SKINPACKDESC);
    if (nod !is null) return cast<CSystemPackDesc>(nod);
    return null;
}



#if DEPENDENCY_GHOSTS_PP || DEV
void DrawGhostSkinsInspector() {
    auto ghosts = Ghosts_PP::GetCurrentGhosts(GetApp());
    for (uint i = 0; i < ghosts.Length; i++) {
        UI::PushID('' + i);
        DrawGhostSkinElement(ghosts[i]);
        UI::PopID();
    }
}
#else
void DrawGhostSkinsInspector() {}
#endif


void DrawGhostSkinElement(CGameCtnGhost@ g) {
    if (g is null) return;
    UI::PushID(g);
    auto label = g.GhostNickname + " - " + Time::Format(g.RaceTime);
    if (UI::TreeNode(label)) {
        CopiableLabelValue("NickName", g.GhostNickname);
        CopiableLabelValue("Login", g.GhostLogin);
        auto skinOpts = CGameCtnGhost_GetPrestigeOpts(g);
        CopiableLabelValue("SkinOpts", skinOpts);
        auto skin = CGameCtnGhost_GetSkin(g);
        // CopiableLabelValue("Skin Offset", tostring(O_CTNGHOST_SKINPACKDESC));
        // CopiableLabelValue("Skin Ptr", Text::FormatPointer(Dev::GetOffsetUint64(g, O_CTNGHOST_SKINPACKDESC)));
        // CopiableLabelValue("Skin Ptr Okay", tostring(LooksLikePtr(g, O_CTNGHOST_SKINPACKDESC)));
        if (skin is null) {
            UI::TextDisabled("Null skin");
        } else {
            CopiableLabelValue("FileName", skin.FileName);
            CopiableLabelValue("Name", skin.Name);
            CopiableLabelValue("Url", skin.Url);
            CopiableLabelValue("LocatorFileName", skin.LocatorFileName);
        }
        UI::TreePop();
    }
    UI::PopID();
}


bool LooksLikePtr(CMwNod@ nod, uint offset) {
    auto ptr = Dev::GetOffsetUint64(nod, offset);
    return ptr > 0xFFFFFFFFFF && ptr < 0x00000300FFEEDDCC
        && ptr & 0xF == 0;
}

bool LooksLikeString(CMwNod@ nod, uint offset) {
    auto strPtr = Dev::GetOffsetUint64(nod, offset);
    auto strLen = Dev::GetOffsetUint32(nod, offset + 0xC);
    return (strPtr == 0 && strLen == 0
        || (strLen < 12)
        || (strLen >= 12 && strLen < 128
            && strPtr > 0xFFFFFFFFFF && strPtr < 0x00000300FFEEDDCC)
        );
}


uint16 GetOffset(const string &in className, const string &in memberName) {
    // throw exception when something goes wrong.
    auto ty = Reflection::GetType(className);
    auto memberTy = ty.GetMember(memberName);
    if (memberTy.Offset == 0xFFFF) throw("Invalid offset: 0xFFFF");
    return memberTy.Offset;
}
uint16 GetOffset(CMwNod@ obj, const string &in memberName) {
    if (obj is null) return 0xFFFF;
    // throw exception when something goes wrong.
    auto ty = Reflection::TypeOf(obj);
    if (ty is null) throw("could not find a type for object");
    auto memberTy = ty.GetMember(memberName);
    if (memberTy is null) throw(ty.Name + " does not have a child called " + memberName);
    if (memberTy.Offset == 0xFFFF) throw("Invalid offset: 0xFFFF");
    return memberTy.Offset;
}
