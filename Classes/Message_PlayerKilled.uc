class Message_PlayerKilled extends LocalMessage;

var localized string YouAreOut;
var localized string PlayerIsOut;

static function SetDrawColorForTeam(Canvas C, TeamInfo Team)
{
    if(Team != None)
    {
        if(Team.TeamIndex == 0)
        {
            C.DrawColor.R = 255;
            C.DrawColor.G = 75;
            C.DrawColor.B = 75;
            return;
        }
        else if(Team.TeamIndex == 1)
        {
            C.DrawColor.R = 75;
            C.DrawColor.G = 128;
            C.DrawColor.B = 255;
            return;
        }        
    }
    
    C.DrawColor.R = 255;
    C.DrawColor.G = 255;
    C.DrawColor.B = 255;
}

static function DrawColoredText(Canvas C, string Text)
{
    local int i;
    local float CX, CY, XL, YL;
    local string s;

    CX = C.CurX;
    CY = C.CurY;

    while(Text != "")
    {
        i = InStr(Text, "");
        if(i >= 0)
        {
            if(i > 0)
            {
                s = Left(Text, i);
                C.DrawTextClipped(s, false);
                C.TextSize(s, XL, YL);
                CX += XL;
                C.SetPos(CX, CY);
            }
            C.DrawColor.R = Asc(Mid(Text, i + 1));
            C.DrawColor.G = Asc(Mid(Text, i + 2));
            C.DrawColor.B = Asc(Mid(Text, i + 3));
            Text = Mid(Text, i + 4);
        }
        else
        {
            C.DrawTextClipped(Text, false);
            break;
        }
    }
}

static function DrawWeaponKilledMessage(Canvas C, class<Weapon> WeaponClass, PlayerReplicationInfo KillerPRI, PlayerReplicationInfo KilledPRI)
{
    local IntBox B;
    local float IconXL, IconYL;
    local float Spacing;
    local float KillerXL, KillerYL;
    local float KilledXL, KilledYL;
    local float DX;
    
    B = WeaponClass.default.IconCoords;
    
    C.TextSize("A", IconXL, IconYL);
    Spacing = IconXL * 0.8;
    IconXL = IconYL * 2.2;
    IconYL = IconXL * (float(B.Y2 - B.Y1) / float(B.X2 - B.X1));

    C.TextSize(KillerPRI.PlayerName, KillerXL, KillerYL);
    C.TextSize(KilledPRI.PlayerName, KilledXL, KilledYL);
    
    DX = (C.ClipX - KillerXL - Spacing - IconXL - Spacing - KilledXL) / 2;

    C.SetPos(DX, C.ClipY * default.PosY);
    SetDrawColorForTeam(C, KillerPRI.Team);
    if(!class'Misc_Player'.default.bTeamColoredDeathMessages && Misc_PRI(KillerPRI) != None)
        DrawColoredText(C, Misc_PRI(KillerPRI).GetColoredName() );
    else
        C.DrawTextClipped(KillerPRI.PlayerName);
    DX += KillerXL + Spacing;
    
    C.SetPos(DX + IconXL, C.ClipY * default.PosY);    
    SetDrawColorForTeam(C, None);
    C.DrawTile(Texture'HudContent.Generic.HUD', -IconXL, IconYL, B.X1, B.Y1, B.X2 - B.X1, B.Y2 - B.Y1);
    DX += IconXL + Spacing;
    
    C.SetPos(DX, C.ClipY * default.PosY);        
    SetDrawColorForTeam(C, KilledPRI.Team);
    if(!class'Misc_Player'.default.bTeamColoredDeathMessages && Misc_PRI(KilledPRI) != None)
        DrawColoredText(C, Misc_PRI(KilledPRI).GetColoredName() );
    else
        C.DrawTextClipped(KilledPRI.PlayerName);
}

static function DrawWeaponSuicideMessage(Canvas C, class<Weapon> WeaponClass, PlayerReplicationInfo KilledPRI)
{
    local IntBox B;
    local float IconXL, IconYL;
    local float Spacing;
    local float KilledXL, KilledYL;
    local float DX;
    
    B = WeaponClass.default.IconCoords;
    
    C.TextSize("A", IconXL, IconYL);
    Spacing = IconXL * 0.8;
    IconXL = IconYL * 2.2;
    IconYL = IconXL * (float(B.Y2 - B.Y1) / float(B.X2 - B.X1));
    
    C.TextSize(KilledPRI.PlayerName, KilledXL, KilledYL);

    DX = (C.ClipX - IconXL - Spacing - KilledXL - Spacing - IconXL) / 2;

    C.SetPos(DX + IconXL, C.ClipY * default.PosY);    
    SetDrawColorForTeam(C, None);
    C.DrawTile(Texture'HudContent.Generic.HUD', -IconXL, IconYL, B.X1, B.Y1, B.X2 - B.X1, B.Y2 - B.Y1);    
    DX += IconXL + Spacing;
    
    C.SetPos(DX, C.ClipY * default.PosY);
    SetDrawColorForTeam(C, KilledPRI.Team);
    if(!class'Misc_Player'.default.bTeamColoredDeathMessages && Misc_PRI(KilledPRI) != None)
        DrawColoredText(C, Misc_PRI(KilledPRI).GetColoredName() );
    else
        C.DrawTextClipped(KilledPRI.PlayerName);
    DX += KilledXL + Spacing;
    
    C.SetPos(DX, C.ClipY * default.PosY);    
    SetDrawColorForTeam(C, None);
    C.DrawTile(Texture'HudContent.Generic.HUD', IconXL, IconYL, B.X1, B.Y1, B.X2 - B.X1, B.Y2 - B.Y1);    
}

static function DrawKilledMessageOldStyle(Canvas C, int Switch, PlayerReplicationInfo KilledPRI)
{
    local float XL, YL;
    
    if(Switch == 0)
    {
        C.TextSize(default.YouAreOut, XL, YL);
        C.SetPos((C.ClipX - XL) / 2, C.ClipY * default.PosY);
        SetDrawColorForTeam(C, KilledPRI.Team);
        C.DrawTextClipped(default.YouAreOut);
        return;
    }
    
    if(KilledPRI == None)
        return;
    
    C.TextSize(KilledPRI.PlayerName @ default.PlayerIsOut, XL, YL);
    C.SetPos((C.ClipX - XL) / 2, C.ClipY * default.PosY);    
    SetDrawColorForTeam(C, KilledPRI.Team);
    DrawColoredText(C, Misc_PRI(KilledPRI).GetColoredName() @ class'GameInfo'.static.MakeColorCode(C.DrawColor) $ default.PlayerIsOut);
}

static function RenderComplexMessage(
    Canvas Canvas, out float XL, out float YL,
    optional String MessageString,
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject)
{
    if(class<WeaponDamageType>(OptionalObject) == None)
        DrawKilledMessageOldStyle(Canvas, Switch, RelatedPRI_2);
    else if(Switch == 0 && RelatedPRI_1 != None && RelatedPRI_2 != None)
        DrawWeaponKilledMessage(Canvas, class<WeaponDamageType>(OptionalObject).default.WeaponClass, RelatedPRI_1, RelatedPRI_2);
    else if(Switch == 1 && RelatedPRI_2 != None)
        DrawWeaponSuicideMessage(Canvas, class<WeaponDamageType>(OptionalObject).default.WeaponClass, RelatedPRI_2);
}

static function string GetString(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
    return class'Team_GameBase'.default.DeathMessageClass.static.GetString(Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
}

static function ClientReceive(
    PlayerController P,
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
    if(Misc_Player(P) == None || class<WeaponDamageType>(OptionalObject) == None || class<WeaponDamageType>(OptionalObject).default.WeaponClass == None)
        Super.ClientReceive(P, int(P.PlayerReplicationInfo != RelatedPRI_2), RelatedPRI_1, RelatedPRI_2);
    else
        Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
    
    class'Team_GameBase'.default.DeathMessageClass.static.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
}

defaultproperties
{
     YouAreOut="YOU ARE OUT!"
     PlayerIsOut="IS OUT!"
     bComplexString=True
     bIsUnique=True
     bFadeMessage=True
     StackMode=SM_Down
     PosY=0.860000
}
