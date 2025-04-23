class Message_CamperX extends Message_Camper;

#exec OBJ LOAD FILE=AS_FX_TX.utx

var Color CamperIconColor;

static function RenderComplexMessage(Canvas C, out float XL, out float YL, optional String MessageString, optional int Switch,
                                     optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
    local PlayerController LocalPlayer;

    if (RelatedPRI_1 != None)
        LocalPlayer = RelatedPRI_1.Level.GetLocalPlayerController();

    if(LocalPlayer != None)
    {
        if(Team_HUDBase(LocalPlayer.myHUD) != None)
            Team_HUDBase(LocalPlayer.myHUD).DrawColoredText(C, MessageString);

        if (Switch == 1 && Misc_PRI(RelatedPRI_1) != None && LocalPlayer.PlayerReplicationInfo != None &&
            LocalPlayer.PlayerReplicationInfo.Team != RelatedPRI_1.Team)
        {
            DrawCamperIcon(C, LocalPlayer, Misc_PRI(RelatedPRI_1).PawnReplicationInfo.Position);
        }
    }
}

static function DrawCamperIcon(Canvas C, PlayerController LocalPlayer, Vector CamperLoc)
{
    local vector CamLoc;
    local rotator CamRot;
    local vector ScreenPos;
    local float Alpha;

    if (LocalPlayer == None || LocalPlayer.Pawn == None)
        return;

    // no mark for visible player
    if ( LocalPlayer.FastTrace(CamperLoc + vect(0,0,32), LocalPlayer.Pawn.Location + vect(0,0,32)) )
        return;

    C.GetCameraLocation(CamLoc, CamRot);
    ScreenPos = C.WorldToScreen(CamperLoc);

    if ( (CamperLoc - CamLoc) Dot vector(CamRot) < 0)
        return;
    if ( ScreenPos.X <= 0 || ScreenPos.X >= C.ClipX )
        return;
    if ( ScreenPos.Y <= 0 || ScreenPos.Y >= C.ClipY )
        return;

    Alpha = C.DrawColor.A;

    C.DrawColor = default.CamperIconColor;
    C.DrawColor.A = Alpha;
    DrawCenteredIcon(C, Texture'AS_FX_TX.HUD.Objective_Primary_Icon', ScreenPos.X, ScreenPos.Y, C.ClipY * 0.0417, C.ClipY * 0.0417);

    C.DrawColor = default.DrawColor;
    C.DrawColor.A = Alpha * 0.78;
    C.Font = LocalPlayer.myHUD.LoadFont(7);
    DrawCenteredText(C, int(VSize(LocalPlayer.Pawn.Location - CamperLoc) * 0.01875) $ "m", ScreenPos.X, ScreenPos.Y + C.ClipY * 0.018);
}

static function DrawCenteredIcon(Canvas C, Texture Tex, float X, float Y, float XL, float YL)
{
    C.SetPos(X - XL * 0.5, Y - YL * 0.5);
    C.DrawTile(Tex, XL, YL, 0, 0, 64, 64);
}

static function DrawCenteredText(Canvas C, string Text, float X, float Y)
{
    local float XL, YL;
    local float OldFontScaleX;

    OldFontScaleX = C.FontScaleX;
    if(C.ClipX >= 1088)
        C.FontScaleX = 0.9;
    else
        C.FontScaleX = 0.75;

    C.StrLen(Text, XL, YL);
    C.SetPos(X - XL * 0.5, Y);
    C.DrawTextClipped(Text, false);

    C.FontScaleX = OldFontScaleX;
}

static function string SomeOneIsCamping(PlayerReplicationInfo RelatedPRI)
{
    return default.PlayerIsCampingOpen @ Misc_PRI(RelatedPRI).GetColoredNameEx() @ default.PlayerIsCamping;
}

defaultproperties
{
     CamperIconColor=(G=160,R=255,A=255)
     bComplexString=True
}
