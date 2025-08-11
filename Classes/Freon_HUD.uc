class Freon_HUD extends TAM_HUD;

#exec TEXTURE IMPORT NAME=Flake FILE=Textures\flake5.tga GROUP=Textures MIPS=On ALPHA=1 DXT=5
#exec TEXTURE IMPORT NAME=Death FILE=Textures\Death.tga GROUP=Textures MIPS=On ALPHA=1 DXT=5
#exec TEXTURE IMPORT NAME=Suicide FILE=Textures\Suicide.tga GROUP=Textures MIPS=On ALPHA=1 DXT=5

var Texture FrozenBeacon;
var Texture DeathBeacon;
var Texture SuicideBeacon;

var float ThawBarWidth;
var float ThawBarHeight;
var Texture ThawBackMat;
var Texture ThawBarMat;

/*
//stub of something to try to visualise time till next full thaw or reward. Not positioned or checking whether this is in use.
simulated function UpdateRankAndSpread(Canvas C)
{

    local Freon_PRI PRI;
	local float heal;
	
	Super.UpdateRankAndSpread(C);

	if(MyOwner == None)
        return;

    PRI = Freon_PRI(MyOwner.PlayerReplicationInfo);

	heal = PRI.HealthGiven % 50;
    if(PRI != None){
		if(heal < 25){
			C.SetDrawColor(255, 0, 0); // Red
		}
		else if (heal < 40){
			C.SetDrawColor(255, 255, 0); // Yellow
		} 
		else{
			C.SetDrawColor(0, 255, 0); // Green
		}
		C.SetPos(10, 300);
		C.DrawText(string(PRI.HealthGiven), False);
		C.DrawRect(Texture'Engine.WhiteSquareTexture', int(6*PRI.HealthGiven), 10);
	}
}
*/


//override so we can do the frozen colour
static function Color GetHealthRampColor(Misc_PRI PRI)
{
    local int CurrentHealth;
    local Color HealthColor;

    HealthColor = default.FullHealthColor;

    if(PRI == None)
      return HealthColor;


    // downcast to Freon PRI to check frozen
    if(Freon_PawnReplicationInfo(PRI.PawnReplicationInfo) != None &&
       Freon_PawnReplicationInfo(PRI.PawnReplicationInfo).bFrozen)
    {
        CurrentHealth = PRI.PawnReplicationInfo.Health;
        HealthColor = class'Freon_PRI'.default.FrozenColor * (0.5 + (CurrentHealth * 0.005));
    }
    else
    {
        //use health colours from super
        HealthColor = Super.GetHealthRampColor(PRI);
    }

    return HealthColor;
}


static function bool IsTargetInFrontOfPlayer( Canvas C, Actor Target, out Vector ScreenPos,
                                             Vector CamLoc, Rotator CamRot )
{
    // Is Target located behind camera ?
    if((Target.Location - CamLoc) Dot vector(CamRot) < 0)
        return false;

    // Is Target on visible canvas area ?
    ScreenPos = C.WorldToScreen(Target.Location + vect(0,0,1) * Target.CollisionHeight);
    if(ScreenPos.X <= 0 || ScreenPos.X >= C.ClipX)
        return false;
    if(ScreenPos.Y <= 0 || ScreenPos.Y >= C.ClipY)
        return false;

    return true;
}

function DrawCustomBeacon(Canvas C, Pawn P, float ScreenLocX, float ScreenLocY)
{
    local vector ScreenLoc;
    local vector CamLoc;
    local rotator CamRot;
    local float distance;
    local float scaledist;
    local float scale;
    local float XL, YL;
    local byte pawnTeam, ownerTeam;
    local string info;
    local string name;
	local texture mytexture;

    if((FrozenBeacon == None) || (P.PlayerReplicationInfo == None) || P.PlayerReplicationInfo.Team == None)
        return;

    pawnTeam = P.PlayerReplicationInfo.Team.TeamIndex;
    ownerTeam = PlayerOwner.GetTeamNum();

    if(!PlayerOwner.PlayerReplicationInfo.bOnlySpectator && pawnTeam != ownerTeam)
        return;

    C.GetCameraLocation(CamLoc, CamRot);

    distance = VSize(CamLoc - P.Location);
    if(distance > PlayerOwner.TeamBeaconMaxDist)
        return;

    if(!IsTargetInFrontOfPlayer(C, P, ScreenLoc, CamLoc, CamRot) || !PlayerOwner.LineOfSightTo(P))
        return;

    scaledist = PlayerOwner.TeamBeaconMaxDist * FClamp(0.04 * P.CollisionRadius, 1.0, 2.0);
    scale = FClamp(0.28 * (scaledist - distance) / scaledist, 0.1, 0.25);

    if(distance <= class'Freon_Trigger'.default.CollisionRadius)
        C.DrawColor = class'Freon_PRI'.default.FrozenColor;
    else
        C.DrawColor = class'Freon_PRI'.default.FrozenColor * 0.75;

    C.Style = ERenderStyle.STY_Normal;
	
	if (Freon_Pawn(P) != None && Freon_PawnReplicationInfo(Misc_PRI(P.PlayerReplicationInfo).PawnReplicationInfo).bKilledSelf){
		if (Freon_PawnReplicationInfo(Misc_PRI(P.PlayerReplicationInfo).PawnReplicationInfo).bLavaSafe){
			mytexture = SuicideBeacon;
		}
		else{
			mytexture = DeathBeacon;
		}
	}
	else{
		mytexture = FrozenBeacon;
	}
	
    if(distance < PlayerOwner.TeamBeaconPlayerInfoMaxDist)
    {
        C.Font = C.SmallFont;

        if(class'TAM_ScoreBoard'.default.bEnableColoredNamesOnHUD)
            name = Misc_PRI(P.PlayerReplicationInfo).GetColoredName();
        else
            name = P.PlayerReplicationInfo.PlayerName;
        info = name $ " (" $ P.Health $ "%)";
		/*if (Freon_Pawn(P) != None && Freon_PawnReplicationInfo(Misc_PRI(P.PlayerReplicationInfo).PawnReplicationInfo).bKilledSelf){
			if (Freon_PawnReplicationInfo(Misc_PRI(P.PlayerReplicationInfo).PawnReplicationInfo).bLavaSafe){
				info = info@" (Kamakaze)";
			}
			else{
				info = info@" (Kamakaze no lava)";
			}
		}*/
        C.TextSize(info, XL, YL);
        C.SetPos(ScreenLoc.X - 0.125 * mytexture.USize, ScreenLoc.Y - 0.125 * mytexture.VSize - YL);
        C.DrawTextClipped(info, false);

        // thaw bar
        C.SetPos(ScreenLoc.X + 1.25 * mytexture.USize * scale, ScreenLoc.Y + 0.1 * mytexture.VSize * scale);
        C.DrawTileStretched(ThawBackMat, ThawBarWidth, mytexture.VSize * scale * 0.5);

        C.SetPos(ScreenLoc.X + 1.25 * mytexture.USize * scale, ScreenLoc.Y + 0.1 * mytexture.VSize * scale);
        C.DrawTileStretched(ThawBarMat, ThawBarWidth * (P.Health / 100.0), mytexture.VSize * scale * 0.5);
    }

    C.SetPos(ScreenLoc.X - 0.125 * mytexture.USize * scale, ScreenLoc.Y - 0.125 * mytexture.VSize * scale);
	
    C.DrawTile(mytexture,
        mytexture.USize * scale,
        mytexture.VSize * scale,
        0.0,
        0.0,
        mytexture.USize,
        mytexture.VSize);
}

/*
function DrawCustomBeacon2(Canvas C, Pawn P, float ScreenLocX, float ScreenLocY)
{
    local vector ScreenLoc;
    local vector CamLoc;
    local rotator CamRot;
	local byte pawnTeam, ownerTeam;
	local float	SizeScale, SizeX, SizeY;

    if((TrackedPlayer == None) || (P.PlayerReplicationInfo == None) || P.PlayerReplicationInfo.Team == None)
        return;

    pawnTeam = P.PlayerReplicationInfo.Team.TeamIndex;
    ownerTeam = PlayerOwner.GetTeamNum();

    //if(pawnTeam == ownerTeam || FastTrace(P.Location, CamLoc))
	if(pawnTeam == ownerTeam)
        return;

    C.GetCameraLocation(CamLoc, CamRot);

    if(!IsTargetInFrontOfPlayer(C, P, ScreenLoc, CamLoc, CamRot))
        return;

    C.Style = ERenderStyle.STY_Normal;
    C.SetPos(ScreenLoc.X, ScreenLoc.Y);
	
	SizeScale	= 0.2;
	SizeX		= 32 * SizeScale * ResScaleX;
	SizeY		= 32 * SizeScale * ResScaleY;

	C.SetPos(ScreenLoc.X - SizeX * 0.5, ScreenLoc.Y - SizeY * 0.5);
	C.DrawTile(TrackedPlayer, SizeX, SizeY, 0, 0, 64, 64);
	
}


simulated function bool ShouldDrawPlayer(Misc_PRI PRI)
{
    if(PRI == None || PRI.Team == None)
        return false;
    if(Freon_PawnReplicationInfo(PRI.PawnReplicationInfo) == None ||
            (PRI.bOutOfLives && !Freon_PawnReplicationInfo(PRI.PawnReplicationInfo).bFrozen) ||
            PRI == PlayerOwner.PlayerReplicationInfo)
        return false;
    return true;
}
*/

simulated function bool ShouldDrawPlayer(Misc_PRI PRI)
{
    local Misc_PRI PRI_PO; //PRI PlayerOwner
    //local Misc_PRI PRI_VT; //PRI ViewTarget

    if(PRI == None || PRI.Team == None)
        return false;

    if(Freon_PawnReplicationInfo(PRI.PawnReplicationInfo) == None)
        return false;

    if(PRI.bOutOfLives && !Freon_PawnReplicationInfo(PRI.PawnReplicationInfo).bFrozen)
        return false;

    // Show PlayerOwner only if frozen
    // Player can see their HUD entry from other players HUD when frozen spec-ing
    PRI_PO = Misc_PRI(PlayerOwner.PlayerReplicationInfo);
    if(PRI == PRI_PO)
    {
        if(!Freon_PawnReplicationInfo(PRI_PO.PawnReplicationInfo).bFrozen)
           return false;
    }

/*  // don't do this check (technically it's fine but players expect to see viewtargets own entry!)
    // when frozen spec-ing players actually do want to see the viewed player details in the hud

    // If player has a ViewTarget (frozen or spec-ing) don't show the ViewTarget entry
    if(PlayerOwner.ViewTarget != None)
    {
        PRI_VT = Misc_PRI(Pawn(PlayerOwner.ViewTarget).PlayerReplicationInfo);
        if(PRI == PRI_VT)
            return false;
    }
*/

    return true;
}


simulated function DrawPlayers(Canvas C)
{
    local int i;
    local int Team;
    local float xl;
    local float yl;
    local float MaxNamePos;
    local int posx;
    local int posy;
    local float scale;
    local string name;
    local int listy;
    local int space;
    local int namey;
    local int namex;
    local int height;
    local int width;

    local int allies;
    local int enemies;

    local Misc_PRI PRI;
	
	local Actor Start;
    local vector Diff;
    local int zdiff, Scaling;

    if(myOwner == None)
        return;

    if(PlayerOwner.PlayerReplicationInfo.Team != None)
        Team = PlayerOwner.GetTeamNum();
    else
    {
        if(Pawn(PlayerOwner.ViewTarget) == None || Pawn(PlayerOwner.ViewTarget).GetTeamNum() == 255)
            return;
        Team = Pawn(PlayerOwner.ViewTarget).GetTeamNum();
    }

    listy = 0.08 * HUDScale * C.ClipY;
    space = 0.005 * HUDScale * C.ClipY;
    scale = FMax(HUDScale, 0.75);
    height = C.ClipY * 0.0255 * Scale;
    width = C.ClipX * 0.13 * Scale;
    namex = C.ClipX * 0.025 * Scale;
    MaxNamePos = 0.99 * (width - namex);
    C.Font = GetFontSizeIndex(C, -3 + int(Scale * 1.25));
    C.StrLen("Test", xl, yl);
    namey = (height * 0.6) - (yl * 0.5);

    for(i = 0; i < MyOwner.GameReplicationInfo.PRIArray.Length; i++)
    {
        PRI = Misc_PRI(myOwner.GameReplicationInfo.PRIArray[i]);

        if(!ShouldDrawPlayer(PRI))
            continue;

        if(!class'Misc_Player'.default.bShowTeamInfo)
            continue;

        if(PRI.Team.TeamIndex == Team)
        {
            if(allies > 9)
                continue;

            posy = listy + ((height + space) * allies);
            posx = C.ClipX * 0.01;

            // draw background
            C.SetPos(posx, posy);

            if(Freon_PawnReplicationInfo(PRI.PawnReplicationInfo) != None && Freon_PawnReplicationInfo(PRI.PawnReplicationInfo).bFrozen)
                C.DrawColor = class'Freon_PRI'.default.FrozenColor * 0.6;
            else
                C.DrawColor = default.BlackColor;
            C.DrawColor.A = 100;
            C.DrawTile(TeamTex, width, height, 168, 211, 166, 44);

            // draw disc
            C.SetPos(posx, posy);
            C.DrawColor = default.WhiteColor;
            C.DrawTile(TeamTex, C.ClipX * 0.0195 * Scale, C.ClipY * 0.026 * Scale, 119, 258, 54, 55);

            // draw name
            if(class'TAM_ScoreBoard'.default.bEnableColoredNamesOnHUD)
                name = PRI.GetColoredName();
            else
                name = PRI.PlayerName;

            C.DrawColor = NameColor;
            C.SetPos(posx + namex, posy + namey);
            class'Misc_Util'.static.DrawTextClipped(C, name, MaxNamePos);

            // draw health dot
            C.DrawColor = GetHealthRampColor(PRI);
            C.SetPos(posx + (0.0022 * Scale * C.ClipX), posy + (0.0035 * Scale * C.ClipY));
            C.DrawTile(TeamTex, C.ClipX * 0.0165 * Scale, C.ClipY * 0.0185 * Scale, 340, 432, 78, 78);

            // draw location dot
            C.DrawColor = WhiteColor;
            Draw2DLocationDot(C, PRI.PawnReplicationInfo.Position, (posx / C.ClipX) + (0.006 * Scale), (posy / C.ClipY) + (0.008 * Scale), 0.008 * Scale, 0.01 * Scale);

			//draw height dot
			if (Misc_BaseGRI(MyOwner.GameReplicationInfo).bHeightRadar){
				if(PlayerOwner.Pawn == None){
					if(PlayerOwner.ViewTarget != None)
						Start = PlayerOwner.ViewTarget;
					else
						Start = PlayerOwner;
				}
				else
					Start = PlayerOwner.Pawn;

				Diff = PRI.PawnReplicationInfo.Position - Start.Location;
				zdiff = int(Diff.Z / 150);
				if (zdiff>5) zdiff = 5;
				if (zdiff<-5) zdiff = -5;
				C.SetPos(((posx / C.ClipX) + (0.006 * Scale))*C.ClipX,
					((posy / C.ClipY) + (0.008 * Scale))* C.ClipY - height * zdiff/10);
				Scaling = 24 * C.ClipX * (0.45 * HUDScale) / 2000;
				C.DrawColor.R = 0;
				C.DrawTile(LocationDot, Scaling, Scaling, 340, 432, 78, 78);
            }
			
		
            // friends shown
            allies++;
        }
        else
        {
            if(enemies > 9)
                continue;

            posy = listy + ((height + space) * enemies);
            posx = C.ClipX * 0.99;

            // draw background
            C.SetPos(posx - width, posy);
            if(Freon_PawnReplicationInfo(PRI.PawnReplicationInfo) != None && Freon_PawnReplicationInfo(PRI.PawnReplicationInfo).bFrozen)
                C.DrawColor = class'Freon_PRI'.default.FrozenColor * 0.6;
            else
                C.DrawColor = default.BlackColor;
            C.DrawColor.A = 100;
            C.DrawTile(TeamTex, width, height, 168, 211, 166, 44);

            // draw disc
            C.SetPos(posx - (C.ClipX * 0.0195 * Scale), posy);
            C.DrawColor = default.WhiteColor;
            C.DrawTile(TeamTex, C.ClipX * 0.0195 * Scale, C.ClipY * 0.026 * Scale, 119, 258, 54, 55);

            // draw name
            if(class'TAM_ScoreBoard'.default.bEnableColoredNamesOnHUD)
                name = PRI.GetColoredName();
            else
                name = PRI.PlayerName;
            C.TextSize(name, xl, yl);
            xl = Min(xl, MaxNamePos);
            C.DrawColor = NameColor;
            C.SetPos(posx - xl - namex, posy + namey);
            class'Misc_Util'.static.DrawTextClipped(C, name, MaxNamePos);

            // draw health dot
            if(Freon_PawnReplicationInfo(PRI.PawnReplicationInfo)!= None && Freon_PawnReplicationInfo(PRI.PawnReplicationInfo).bFrozen)
                C.DrawColor = class'Freon_PRI'.default.FrozenColor;
            else
                C.DrawColor = HudColorTeam[PRI.Team.TeamIndex];

            C.SetPos(posx - (0.0165 * Scale * C.ClipX), posy + (0.0035 * Scale * C.ClipY));
            C.DrawTile(TeamTex, C.ClipX * 0.0165 * Scale, C.ClipY * 0.0185 * Scale, 340, 432, 78, 78);

            // enemies shown
            enemies++;
        }
    }
}


simulated function DrawPlayersExtended(Canvas C)
{
    local int i;
    local int Team;
    local float xl;
    local float yl;
    local float MaxNamePos;
    local int posx;
    local int posy;
    local float scale;
    local string name;
    local int listy;
    local int space;
    local int namey;
    local int namex;
    local int height;
    local int width;
    local Misc_PRI pri;
    local int health;

    local int allies;
    local int enemies;
	
	local Actor Start;
    local vector Diff;
    local int zdiff, Scaling;

    if(myOwner == None)
        return;

    if(PlayerOwner.PlayerReplicationInfo.Team != None)
        Team = PlayerOwner.GetTeamNum();
    else
    {
        if(Pawn(PlayerOwner.ViewTarget) == None || Pawn(PlayerOwner.ViewTarget).GetTeamNum() == 255)
            return;
        Team = Pawn(PlayerOwner.ViewTarget).GetTeamNum();
    }

    listy = 0.08 * HUDScale * C.ClipY;
    scale = 0.75;
    height = C.ClipY * 0.02;
    space = height + (0.0075 * C.ClipY);
    namex = C.ClipX * 0.02;

    C.Font = GetFontSizeIndex(C, -3);
    C.StrLen("Test", xl, yl);
    namey = (height * 0.6) - (yl * 0.5);

    for(i = 0; i < MyOwner.GameReplicationInfo.PRIArray.Length; i++)
    {
        PRI = Misc_PRI(myOwner.GameReplicationInfo.PRIArray[i]);

        if(!ShouldDrawPlayer(PRI))
            continue;

        if(!class'Misc_Player'.default.bShowTeamInfo)
            continue;

        if(PRI.Team.TeamIndex == Team)
        {
            if(allies > 9)
                continue;

            space = height + (0.0075 * C.ClipY);
            width = C.ClipX * 0.14;
            MaxNamePos = 0.78 * (width - namex);

            posy = listy + ((height + space) * allies);
            posx = C.ClipX * 0.01;

            // draw backgrounds
            C.SetPos(posx, posy);
            if(Freon_PawnReplicationInfo(PRI.PawnReplicationInfo) != None && Freon_PawnReplicationInfo(PRI.PawnReplicationInfo).bFrozen)
                C.DrawColor = class'Freon_PRI'.default.FrozenColor * 0.6;
            else
                C.DrawColor = default.BlackColor;
            C.DrawColor.A = 100;
            C.DrawTile(TeamTex, width + posx, height, 168, 211, 166, 44);
            C.SetPos(posx * 2, posy + height * 1.1);
            C.DrawTile(TeamTex, width, height, 168, 211, 166, 44);

            // draw disc
            C.SetPos(posx, posy);
            C.DrawColor = default.WhiteColor;
            C.DrawTile(TeamTex, C.ClipX * 0.0195 * Scale, C.ClipY * 0.026 * Scale, 119, 258, 54, 55);

            // draw name
            if(class'TAM_ScoreBoard'.default.bEnableColoredNamesOnHUD)
                name = PRI.GetColoredName();
            else
                name = PRI.PlayerName;
            C.DrawColor = NameColor;
            C.SetPos(posx + namex, posy + namey);
            class'Misc_Util'.static.DrawTextClipped(C, name, MaxNamePos);

            // draw location
            MaxNamePos = 0.80 * (width - namex);
            name = PRI.GetLocationName();
            C.StrLen(name, xl, yl);
            if(xl > MaxNamePos)
                name = left(name, MaxNamePos / xl * len(name));
            C.SetPos(posx + namex, posy + (height * 1.1) + namey);

            if(Freon_PawnReplicationInfo(PRI.PawnReplicationInfo)!= None && Freon_PawnReplicationInfo(PRI.PawnReplicationInfo).bFrozen)
                C.DrawColor = class'Freon_PRI'.default.FrozenColor;
            else
                C.DrawColor = LocationColor;
            C.DrawText(name);

            // draw health dot
            if(Freon_PawnReplicationInfo(PRI.PawnReplicationInfo) != None && Freon_PawnReplicationInfo(PRI.PawnReplicationInfo).bFrozen)
                health = PRI.PawnReplicationInfo.Health;
            else
                health = PRI.PawnReplicationInfo.Health + PRI.PawnReplicationInfo.Shield;

            C.DrawColor = GetHealthRampColor(PRI);

            C.SetPos(posx + (0.0022 * Scale * C.ClipX), posy + (0.0035 * Scale * C.ClipY));
            C.DrawTile(TeamTex, C.ClipX * 0.0165 * Scale, C.ClipY * 0.0185 * Scale, 340, 432, 78, 78);

            // draw health
            name = string(health);
            C.StrLen(name, xl, yl);
            C.SetPos(posx * 1.5 + width - xl, posy + namey);
            C.DrawText(name);

            // draw adrenaline
            name = string(PRI.PawnReplicationInfo.Adrenaline);
            C.StrLen(name, xl, yl);
            C.SetPos(posx * 1.5 + width - xl, posy + (height * 1.1) + namey);
            if(PRI.PawnReplicationInfo.Adrenaline<100)
                C.DrawColor = AdrenColor;
            else
                C.DrawColor = FullAdrenColor;

            C.DrawText(name);

            // draw location dot
            C.DrawColor = WhiteColor;
            Draw2DLocationDot(C, PRI.PawnReplicationInfo.Position, (posx / C.ClipX) + (0.006 * Scale), (posy / C.ClipY) + (0.008 * Scale), 0.008 * Scale, 0.01 * Scale);

			//draw height dot
			if (Misc_BaseGRI(MyOwner.GameReplicationInfo).bHeightRadar){

				if(PlayerOwner.Pawn == None){
					if(PlayerOwner.ViewTarget != None)
						Start = PlayerOwner.ViewTarget;
					else
						Start = PlayerOwner;
				}
				else
					Start = PlayerOwner.Pawn;

				Diff = PRI.PawnReplicationInfo.Position - Start.Location;
				zdiff = int(Diff.Z / 150);
				if (zdiff>5) zdiff = 5;
				if (zdiff<-5) zdiff = -5;
				C.SetPos(((posx / C.ClipX) + (0.006 * Scale))*C.ClipX,
					((posy / C.ClipY) + (0.008 * Scale))* C.ClipY - height * zdiff/10);
				Scaling = 24 * C.ClipX * (0.45 * HUDScale) / 2000;
				C.DrawColor.R = 0;
				C.DrawTile(LocationDot, Scaling, Scaling, 340, 432, 78, 78);
            }
			
			
            // friends shown
            allies++;
        }
        else
        {
            if(enemies > 9)
                continue;

            space = (0.005 * C.ClipY);
            width = C.ClipX * 0.11;
            MaxNamePos = 0.99 * (width - namex);

            posy = listy + ((height + space) * enemies);
            posx = C.ClipX * 0.99;

            // draw background
            C.SetPos(posx - width, posy);
            if(Freon_PawnReplicationInfo(PRI.PawnReplicationInfo) != None && Freon_PawnReplicationInfo(PRI.PawnReplicationInfo).bFrozen)
                C.DrawColor = class'Freon_PRI'.default.FrozenColor * 0.6;
            else
                C.DrawColor = default.BlackColor;
            C.DrawColor.A = 100;
            C.DrawTile(TeamTex, width, height, 168, 211, 166, 44);

            // draw disc
            C.SetPos(posx - (C.ClipX * 0.0195 * Scale), posy);
            C.DrawColor = default.WhiteColor;
            C.DrawTile(TeamTex, C.ClipX * 0.0195 * Scale, C.ClipY * 0.026 * Scale, 119, 258, 54, 55);

            // draw name
            if(class'TAM_ScoreBoard'.default.bEnableColoredNamesOnHUD)
                name = PRI.GetColoredName();
            else
                name = PRI.PlayerName;

            C.TextSize(name, xl, yl);
            xl = Min(xl, MaxNamePos);
            C.DrawColor = NameColor;
            C.SetPos(posx - xl - namex, posy + namey);
            class'Misc_Util'.static.DrawTextClipped(C, name, MaxNamePos);

            // draw health dot
            if(Freon_PawnReplicationInfo(PRI.PawnReplicationInfo)!= None && Freon_PawnReplicationInfo(PRI.PawnReplicationInfo).bFrozen)
                C.DrawColor = class'Freon_PRI'.default.FrozenColor;
            else
                C.DrawColor = HudColorTeam[PRI.Team.TeamIndex];
            C.SetPos(posx - (0.016 * Scale * C.ClipX), posy + (0.0035 * Scale * C.ClipY));
            C.DrawTile(TeamTex, C.ClipX * 0.0165 * Scale, C.ClipY * 0.0185 * Scale, 340, 432, 78, 78);

            // enemies shown
            enemies++;
        }
    }
}


simulated function DrawPlayersZAxis(Canvas C)
{
    local int i;
    local int HUDOwnerTeam; //team for the HUDOwner
    local float xl;
    local float yl;
    local float MaxNamePos;
    local int posx;
    local int posy;
    local float scale;
    local string name;
    local int StartListY;
    local int space;
    local int namey;
    local int namex;
    local int height;
    local int width;
    local Misc_PRI PRI;

    //hagis
    local int radarSizeAllies;
    local int radarCenterX;
    local int radarCenterY;
    local float CU; // spacing unit 1 char width

    local int allies;
    local int enemies;
	
    if(myOwner == None)
        return;

    if(PlayerOwner.PlayerReplicationInfo.Team != None)
    {
        HUDOwnerTeam = PlayerOwner.GetTeamNum();
    }
    else
    {
        if(Pawn(PlayerOwner.ViewTarget) == None || Pawn(PlayerOwner.ViewTarget).GetTeamNum() == 255)
            return;

        HUDOwnerTeam = Pawn(PlayerOwner.ViewTarget).GetTeamNum();
    }

    //
    // draw own team / allies
    //

    StartListY = 0.08 * HUDScale * C.ClipY; // Y axis start player entries
    height = C.ClipY * 0.02;

    C.Font = GetFontSizeIndex(C, -3);
    C.StrLen("X", CU, yl);
    namey = (height * 0.6) - (yl * 0.5);

    // loop this twice, once for each team, allies first
    for(i = 0; i < MyOwner.GameReplicationInfo.PRIArray.Length; i++)
    {
        if(allies > 9)
            break;

        PRI = Misc_PRI(myOwner.GameReplicationInfo.PRIArray[i]);

        if(!ShouldDrawPlayer(PRI))
            continue;

        if(PRI.Team.TeamIndex != HUDOwnerTeam)
            continue; // allies first

        //space = height + (0.0075 * C.ClipY);
        space = height + (0.0045 * C.ClipY);

        //calc the size of the radar and use this to space out the name and location bars
        radarSizeAllies = (height + space) * 0.85; // fill 85% of player entry height with radar

        posx = int(CU*0.5); //set posx to left side
        posy = StartListY + ((height + space) * allies);

        //draw the text areas if they are showing team info
        if(class'Misc_Player'.default.bShowTeamInfo)
        {
            //start of text area background
            namex = radarSizeAllies + CU;
            width = C.ClipX * 0.11;
            MaxNamePos = width; //width for text

            //
            // draw text area background
            //
            if(Freon_PawnReplicationInfo(PRI.PawnReplicationInfo) != None &&
               Freon_PawnReplicationInfo(PRI.PawnReplicationInfo).bFrozen)
            {
                C.DrawColor = class'Freon_PRI'.default.FrozenColor * 0.6;
            }
            else
            {
                C.DrawColor = default.BlackColor;
            }

            C.SetPos(namex, posy);
            C.DrawColor.A = 100;
            C.DrawTile(TeamTex, width, height, 168, 211, 166, 44);

            //
            // draw player name
            //
            if(class'TAM_ScoreBoard'.default.bEnableColoredNamesOnHUD)
                name = PRI.GetColoredName();
            else
                name = PRI.PlayerName;

            C.DrawColor = NameColor;
            C.SetPos(namex, posy + namey);
            class'Misc_Util'.static.DrawTextClipped(C, name, MaxNamePos);
        }

        //
        // draw outer radar disc
        //
        C.SetPos(posx, posy);
        C.DrawColor = default.WhiteColor;
        //C.DrawTile(TeamTex, C.ClipX * 0.0195 * Scale, C.ClipY * 0.026 * Scale, 119, 258, 54, 55); //original crops
        C.DrawTile(TeamTex, radarSizeAllies, radarSizeAllies, 121, 260, 51, 51); //hagis crops

        //calc radar circle center
        radarCenterX = posx + ((radarSizeAllies+1) / 2);
        radarCenterY = posy + ((radarSizeAllies+1) / 2);

        //
        // draw health dot
        //
        // use circle center to calc the position (need to find top left corner)
        // health dot size is 80% of radarSizeAllies 
        C.DrawColor = GetHealthRampColor(PRI);
        C.SetPos(radarCenterX - ((radarSizeAllies * 0.80)/2.0), radarCenterY - ((radarSizeAllies * 0.80)/2.0));
        C.DrawTile(Hudzaxis, radarSizeAllies * 0.80, radarSizeAllies * 0.80, 1, 1, 78, 78);


		//draw height dot or plus/minus depending on preference
		if(PlayerOwner.ViewTarget != None){
			if((Misc_BaseGRI(MyOwner.GameReplicationInfo) != None) && Misc_BaseGRI(MyOwner.GameReplicationInfo).UseZAxisRadar && class'Misc_Player'.default.bUsePlus){
			
				//same position as the dot
				C.SetPos(radarCenterX - ((radarSizeAllies * 0.80)/2.0), radarCenterY - ((radarSizeAllies * 0.80)/2.0));

				// player height is 88 use two player heights 176
				if(PRI.PawnReplicationInfo.Position.Z > (PlayerOwner.ViewTarget.Location.Z + 176))
					C.DrawTile(Hudzaxis, radarSizeAllies * 0.80, radarSizeAllies * 0.80, 80, 1, 78, 78); //plus
				else if (PRI.PawnReplicationInfo.Position.Z < (PlayerOwner.ViewTarget.Location.Z - 176))
					C.DrawTile(Hudzaxis, radarSizeAllies * 0.80, radarSizeAllies * 0.80, 160, 1, 78, 78); //minus
			}			
			else 
				if (Misc_BaseGRI(MyOwner.GameReplicationInfo).bHeightRadar){
					C.DrawColor.R = 0;
					NewDraw2DHeightDot(C, PRI.PawnReplicationInfo.Position, radarCenterX, radarCenterY, radarSizeAllies);
				}
		}

        //
        // draw location dot
        //
        // don't draw location dot when viewing spec players own HUD entry
        if(PlayerOwner.ViewTarget == None ||
           PRI != Misc_PRI(Pawn(PlayerOwner.ViewTarget).PlayerReplicationInfo))
        {
            C.DrawColor = WhiteColor;
            NewDraw2DLocationDot(C, PRI.PawnReplicationInfo.Position, radarCenterX, radarCenterY, radarSizeAllies);
		}
        // friends shown
        allies++;
    }


    //
    // enemies
    //
    for(i = 0; i < MyOwner.GameReplicationInfo.PRIArray.Length; i++)
    {
        if(enemies > 9)
            break;

        PRI = Misc_PRI(myOwner.GameReplicationInfo.PRIArray[i]);

        if(!ShouldDrawPlayer(PRI))
            continue;

        if(PRI.Team.TeamIndex == HUDOwnerTeam)
            continue;

        scale = 0.75; // radar size old method
        space = (0.005 * C.ClipY);
        namex = C.ClipX * 0.02;
        width = C.ClipX * 0.11;
        MaxNamePos = 0.99 * (width - namex);

        posx = C.ClipX * 0.99;
        posy = StartListY + ((height + space) * enemies);

        //draw the text areas if they are showing team info
        if(class'Misc_Player'.default.bShowTeamInfo)
        {
            // draw background
            C.SetPos(posx - width, posy);
            if(Freon_PawnReplicationInfo(PRI.PawnReplicationInfo) != None &&
              Freon_PawnReplicationInfo(PRI.PawnReplicationInfo).bFrozen)
            {
                C.DrawColor = class'Freon_PRI'.default.FrozenColor * 0.6;
            }
            else
            {
                C.DrawColor = default.BlackColor;
            }
            C.DrawColor.A = 100;
            C.DrawTile(TeamTex, width, height, 168, 211, 166, 44);

            // draw name
            if(class'TAM_ScoreBoard'.default.bEnableColoredNamesOnHUD)
                name = PRI.GetColoredName();
            else
                name = PRI.PlayerName;

            C.TextSize(name, xl, yl);
            xl = Min(xl, MaxNamePos);
            C.DrawColor = NameColor;
            C.SetPos(posx - xl - namex, posy + namey);
            class'Misc_Util'.static.DrawTextClipped(C, name, MaxNamePos);
        }

        // draw disc
        C.SetPos(posx - (C.ClipX * 0.0195 * Scale), posy);
        C.DrawColor = default.WhiteColor;
        C.DrawTile(TeamTex, C.ClipX * 0.0195 * Scale, C.ClipY * 0.026 * Scale, 119, 258, 54, 55);

        // draw health dot
        if(Freon_PawnReplicationInfo(PRI.PawnReplicationInfo)!= None &&
           Freon_PawnReplicationInfo(PRI.PawnReplicationInfo).bFrozen)
        {
            C.DrawColor = class'Freon_PRI'.default.FrozenColor;
        }
        else
        {
            C.DrawColor = HudColorTeam[PRI.Team.TeamIndex];
        }
        C.SetPos(posx - (0.016 * Scale * C.ClipX), posy + (0.0035 * Scale * C.ClipY));
        C.DrawTile(TeamTex, C.ClipX * 0.0165 * Scale, C.ClipY * 0.0185 * Scale, 340, 432, 78, 78);

        // enemies shown
        enemies++;
    }
}

function NewDraw2DLocationDot(Canvas C, vector Loc, int CenterX, int CenterY, int OutsideDiameter)
{
    local rotator Dir;
    local float Angle;
    local Actor Start;

    local int posCenterX;
    local int posCenterY;
    local float length;
    local float dotSize;


    if(PlayerOwner.Pawn == None)
    {
        if(PlayerOwner.ViewTarget != None)
            Start = PlayerOwner.ViewTarget;
        else
			if(Freon_Player(PlayerOwner) != None && Freon_Player(PlayerOwner).FrozenPawn != None)
				Start = Freon_Player(PlayerOwner).FrozenPawn;
			else
				Start = PlayerOwner;
    }
    else
    {
        Start = PlayerOwner.Pawn;
    }

    Dir = rotator(Loc - Start.Location);
    Angle = ((Dir.Yaw - Start.Rotation.Yaw) & 65535) * 6.2832 / 65536;

    dotSize = OutsideDiameter * 0.35; // 35% diameter
    length = (OutsideDiameter - (dotSize/2.0)) / 2.0;

    posCenterX = CenterX + length * sin(Angle);
    posCenterY = CenterY - length * cos(Angle);

    C.SetPos(posCenterX - (dotSize/2.0), posCenterY - (dotSize/2.0)); //adjust for dot size

    C.Style = ERenderStyle.STY_Alpha;
    C.DrawTile(LocationDot, dotSize, dotSize, 340, 432, 78, 78);
}

function Draw2DLocationDot(Canvas C, vector Loc, float OffsetX, float OffsetY, float ScaleX, float ScaleY)
{
    local rotator Dir;
    local float Angle, Scaling;
    local Actor Start;

    if(PlayerOwner.Pawn == None)
    {
        if(PlayerOwner.ViewTarget != None)
            Start = PlayerOwner.ViewTarget;
        else
			if(Freon_Player(PlayerOwner) != None && Freon_Player(PlayerOwner).FrozenPawn != None)
				Start = Freon_Player(PlayerOwner).FrozenPawn;
			else
				Start = PlayerOwner;
    }
    else
    {
        Start = PlayerOwner.Pawn;
    }
	
    Dir = rotator(Loc - Start.Location);
    Angle = ((Dir.Yaw - Start.Rotation.Yaw) & 65535) * 6.2832 / 65536;
    C.Style = ERenderStyle.STY_Alpha;
    C.SetPos(OffsetX * C.ClipX + ScaleX * C.ClipX * sin(Angle),
            OffsetY * C.ClipY - ScaleY * C.ClipY * cos(Angle));

    Scaling = 24 * C.ClipX * (0.45 * HUDScale) / 1600;

    C.DrawTile(LocationDot, Scaling, Scaling, 340, 432, 78, 78);
}


simulated function DrawPlayersExtendedZAxis(Canvas C)
{
    local int i;
    local int HUDOwnerTeam; //team for the HUDOwner
    local float xl;
    local float yl;
    local float MaxNamePos;
    local int posx;
    local int posy;
    local float scale;
    local string name;
    local int StartListY;
    local int space;
    local int namey;
    local int namex;
    local int height;
    local int width;
    local Misc_PRI pri;
    local int health;

    //hagis
    local int radarSizeAllies;
    local int radarCenterX;
    local int radarCenterY;
    local float CU; // spacing unit 1 char width

    local int allies;
    local int enemies;
	
    if(myOwner == None)
        return;

    if(PlayerOwner.PlayerReplicationInfo.Team != None)
    {
        HUDOwnerTeam = PlayerOwner.GetTeamNum();
    }
    else
    {
        if(Pawn(PlayerOwner.ViewTarget) == None || Pawn(PlayerOwner.ViewTarget).GetTeamNum() == 255)
            return;

        HUDOwnerTeam = Pawn(PlayerOwner.ViewTarget).GetTeamNum();
    }

    //
    // draw own team / allies
    //

    StartListY = 0.08 * HUDScale * C.ClipY; // Y axis start player entries
    height = C.ClipY * 0.02;

    C.Font = GetFontSizeIndex(C, -3);
    C.StrLen("X", CU, yl);
    namey = (height * 0.6) - (yl * 0.5);

    // loop this twice, once for each team, allies first
    for(i = 0; i < MyOwner.GameReplicationInfo.PRIArray.Length; i++)
    {
        if(allies > 9)
            break;

        PRI = Misc_PRI(myOwner.GameReplicationInfo.PRIArray[i]);

        if(!ShouldDrawPlayer(PRI))
            continue;

        if(PRI.Team.TeamIndex != HUDOwnerTeam)
            continue; // allies first

        space = height + (0.0075 * C.ClipY);

        //calc the size of the radar and use this to space out the name and location bars
        radarSizeAllies = (height + space) * 0.82; // fill 82% of player entry height with radar

        posx = int(CU*0.5); //set posx to left side
        posy = StartListY + ((height + space) * allies);

        //draw the text areas if they are showing team info
        if(class'Misc_Player'.default.bShowTeamInfo)
        {
            //start of text area backgrounds
            namex = radarSizeAllies + CU;
            width = C.ClipX * 0.12;
            MaxNamePos = width - CU*2.75; //width for text

            //
            // draw text area backgrounds
            //
            if(Freon_PawnReplicationInfo(PRI.PawnReplicationInfo) != None &&
               Freon_PawnReplicationInfo(PRI.PawnReplicationInfo).bFrozen)
            {
                C.DrawColor = class'Freon_PRI'.default.FrozenColor * 0.6;
            }
            else
            {
                C.DrawColor = default.BlackColor;
            }

            C.SetPos(namex, posy);
            C.DrawColor.A = 100;
            C.DrawTile(TeamTex, width, height, 168, 211, 166, 44);

            C.SetPos(namex, posy + height * 1.1);
            C.DrawTile(TeamTex, width, height, 168, 211, 166, 44);

            //
            // draw player name
            //
            if(class'TAM_ScoreBoard'.default.bEnableColoredNamesOnHUD)
                name = PRI.GetColoredName();
            else
                name = PRI.PlayerName;

            C.DrawColor = NameColor;
            C.SetPos(namex, posy + namey);
            class'Misc_Util'.static.DrawTextClipped(C, name, MaxNamePos);

            //
            // draw player map location
            //
            name = PRI.GetLocationName();
            if(Freon_PawnReplicationInfo(PRI.PawnReplicationInfo)!= None && Freon_PawnReplicationInfo(PRI.PawnReplicationInfo).bFrozen)
                C.DrawColor = class'Freon_PRI'.default.FrozenColor;
            else
                C.DrawColor = LocationColor;
            C.SetPos(namex, posy + (height * 1.1) + namey);
            class'Misc_Util'.static.DrawTextClipped(C, name, MaxNamePos);

            //
            // health text
            //
            if(Freon_PawnReplicationInfo(PRI.PawnReplicationInfo) != None &&
               Freon_PawnReplicationInfo(PRI.PawnReplicationInfo).bFrozen)
            {
                health = PRI.PawnReplicationInfo.Health;
            }
            else
            {
                health = PRI.PawnReplicationInfo.Health + PRI.PawnReplicationInfo.Shield;
            }

            name = string(health);
            C.StrLen(name, xl, yl);
            C.SetPos((C.ClipX * 0.015) + width + radarSizeAllies - xl, posy + namey);
            C.DrawColor = GetHealthRampColor(PRI);
            C.DrawText(name);

            //
            // draw adrenaline amount text
            //
            if(PRI.PawnReplicationInfo.Adrenaline<100)
                C.DrawColor = AdrenColor;
            else
                C.DrawColor = FullAdrenColor;

            name = string(PRI.PawnReplicationInfo.Adrenaline);
            C.StrLen(name, xl, yl);
            C.SetPos((C.ClipX * 0.015) + width + radarSizeAllies - xl, posy + (height * 1.1) + namey);
            C.DrawText(name);
        }

        //
        // draw outer radar disc
        //
        C.SetPos(posx, posy);
        C.DrawColor = default.WhiteColor;
        //C.DrawTile(TeamTex, C.ClipX * 0.0195 * Scale, C.ClipY * 0.026 * Scale, 119, 258, 54, 55); //original crops
        C.DrawTile(TeamTex, radarSizeAllies, radarSizeAllies, 121, 260, 51, 51); //hagis crops

        //calc radar circle center
        radarCenterX = posx + ((radarSizeAllies+1) / 2);
        radarCenterY = posy + ((radarSizeAllies+1) / 2);

        //
        // draw health dot
        //
        // use circle center to calc the position (need to find top left corner)
        // health dot size is 80% of radarSizeAllies 
        C.SetPos(radarCenterX - ((radarSizeAllies * 0.80)/2.0), radarCenterY - ((radarSizeAllies * 0.80)/2.0));
        C.DrawColor = GetHealthRampColor(PRI);
        C.DrawTile(Hudzaxis, radarSizeAllies * 0.80, radarSizeAllies * 0.80, 1, 1, 78, 78);

		//draw height dot or plus/minus depending on preference
		if(PlayerOwner.ViewTarget != None){
			if((Misc_BaseGRI(MyOwner.GameReplicationInfo) != None) && Misc_BaseGRI(MyOwner.GameReplicationInfo).UseZAxisRadar && class'Misc_Player'.default.bUsePlus){

				//same position as the dot
				C.SetPos(radarCenterX - ((radarSizeAllies * 0.80)/2.0), radarCenterY - ((radarSizeAllies * 0.80)/2.0));

				// player height is 88 use two player heights 176
				if(PRI.PawnReplicationInfo.Position.Z > (PlayerOwner.ViewTarget.Location.Z + 176))
					C.DrawTile(Hudzaxis, radarSizeAllies * 0.80, radarSizeAllies * 0.80, 80, 1, 78, 78); //plus
				else if (PRI.PawnReplicationInfo.Position.Z < (PlayerOwner.ViewTarget.Location.Z - 176))
					C.DrawTile(Hudzaxis, radarSizeAllies * 0.80, radarSizeAllies * 0.80, 160, 1, 78, 78); //minus
				}			
			else 
				if (Misc_BaseGRI(MyOwner.GameReplicationInfo).bHeightRadar){
					C.DrawColor.R = 0;
					NewDraw2DHeightDot(C, PRI.PawnReplicationInfo.Position, radarCenterX, radarCenterY, radarSizeAllies);
			}
		}		
        //
        // draw location dot
        //
        // don't draw location dot when viewing spec players own HUD entry
        if(PlayerOwner.ViewTarget == None ||
           PRI != Misc_PRI(Pawn(PlayerOwner.ViewTarget).PlayerReplicationInfo))
        {
            C.DrawColor = WhiteColor;
            NewDraw2DLocationDot(C, PRI.PawnReplicationInfo.Position, radarCenterX, radarCenterY, radarSizeAllies);
		}
        // friends shown
        allies++;
    }


    //
    // enemies
    //
    for(i = 0; i < MyOwner.GameReplicationInfo.PRIArray.Length; i++)
    {
        if(enemies > 9)
            break;

        PRI = Misc_PRI(myOwner.GameReplicationInfo.PRIArray[i]);

        if(!ShouldDrawPlayer(PRI))
            continue;

        if(PRI.Team.TeamIndex == HUDOwnerTeam)
            continue;

        scale = 0.75; // radar size old method
        space = (0.005 * C.ClipY);
        namex = C.ClipX * 0.02;
        width = C.ClipX * 0.11;
        MaxNamePos = 0.99 * (width - namex);

        posx = C.ClipX * 0.99;
        posy = StartListY + ((height + space) * enemies);

        //draw the text areas if they are showing team info
        if(class'Misc_Player'.default.bShowTeamInfo)
        {
            // draw background
            C.SetPos(posx - width, posy);
            if(Freon_PawnReplicationInfo(PRI.PawnReplicationInfo) != None &&
              Freon_PawnReplicationInfo(PRI.PawnReplicationInfo).bFrozen)
            {
                C.DrawColor = class'Freon_PRI'.default.FrozenColor * 0.6;
            }
            else
            {
                C.DrawColor = default.BlackColor;
            }
            C.DrawColor.A = 100;
            C.DrawTile(TeamTex, width, height, 168, 211, 166, 44);

            // draw name
            if(class'TAM_ScoreBoard'.default.bEnableColoredNamesOnHUD)
                name = PRI.GetColoredName();
            else
                name = PRI.PlayerName;

            C.TextSize(name, xl, yl);
            xl = Min(xl, MaxNamePos);
            C.DrawColor = NameColor;
            C.SetPos(posx - xl - namex, posy + namey);
            class'Misc_Util'.static.DrawTextClipped(C, name, MaxNamePos);
        }

        // draw disc
        C.SetPos(posx - (C.ClipX * 0.0195 * Scale), posy);
        C.DrawColor = default.WhiteColor;
        C.DrawTile(TeamTex, C.ClipX * 0.0195 * Scale, C.ClipY * 0.026 * Scale, 119, 258, 54, 55);

        // draw health dot
        if(Freon_PawnReplicationInfo(PRI.PawnReplicationInfo)!= None &&
           Freon_PawnReplicationInfo(PRI.PawnReplicationInfo).bFrozen)
        {
            C.DrawColor = class'Freon_PRI'.default.FrozenColor;
        }
        else
        {
            C.DrawColor = HudColorTeam[PRI.Team.TeamIndex];
        }
        C.SetPos(posx - (0.016 * Scale * C.ClipX), posy + (0.0035 * Scale * C.ClipY));
        C.DrawTile(TeamTex, C.ClipX * 0.0165 * Scale, C.ClipY * 0.0185 * Scale, 340, 432, 78, 78);

        // enemies shown
        enemies++;
    }
}

defaultproperties
{
     FrozenBeacon=Texture'3SPNv3225PIG.textures.Flake'
     DeathBeacon=Texture'3SPNv3225PIG.textures.Death'
     SuicideBeacon=Texture'3SPNv3225PIG.textures.Suicide'
     ThawBarWidth=50.000000
     ThawBarHeight=10.000000
     ThawBackMat=Texture'InterfaceContent.Menu.BorderBoxD'
     ThawBarMat=Texture'ONSInterface-TX.HealthBar'
}
