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

// variables for DrawPlayersExtendedZAxis : intended to be cached and not calculated every tick
//Global or Friends
var float oldClipy, oldClipX;
var Misc_BaseGRI BGRI;
var int ZAStartListY, widthA, ZAheight, halfRadarSize, ZAradarCenterX, ZAnamey, heightPlusSpaceA, radarSize, posxA, namexA, MaxHUDPlayerCount, HeightStep;
var float heightOffset, CU, startX, healthBlob, halfHealthBlob, dotSize, HalfdotSize, dotLength, MaxNamePosA, HeightDotSize, HalfHeightDotSize;
var color FrozenColorBack;

//Enemies:
var int namexE, widthE, posxE, heightPlusSpaceE;
var float scale, MaxNamePosE, discSize, discSizeSquash, HDxoffset, HDWidth, HDHeight, HDHeightOffset;

// Note: This class is held in variable PlayerController.myHUD

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
	local Freon_PawnReplicationInfo FPRI;

    HealthColor = default.FullHealthColor;

    if(PRI == None)
      return HealthColor;

    // downcast to Freon PRI to check frozen
	FPRI = Freon_PawnReplicationInfo(PRI.PawnReplicationInfo);
    if(FPRI != None && FPRI.bFrozen)
    {
        CurrentHealth = FPRI.Health;
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
    local string info;
    local string name;
	local texture mytexture;
	local Misc_PRI MPRI;
	local Freon_PawnReplicationInfo FPRI;
	local int TUSize, TVSize;

    if((FrozenBeacon == None) || (P.PlayerReplicationInfo == None) || P.PlayerReplicationInfo.Team == None)
        return;

    if(!PlayerOwner.PlayerReplicationInfo.bOnlySpectator && P.PlayerReplicationInfo.Team.TeamIndex != PlayerOwner.GetTeamNum())
        return;

    C.GetCameraLocation(CamLoc, CamRot);

    distance = VSize(CamLoc - P.Location);
    if(distance > PlayerOwner.TeamBeaconMaxDist)
        return;

    if(!IsTargetInFrontOfPlayer(C, P, ScreenLoc, CamLoc, CamRot) || !FastTrace(P.Location, CamLoc))
        return;

    scaledist = PlayerOwner.TeamBeaconMaxDist * FClamp(0.04 * P.CollisionRadius, 1.0, 2.0);
    scale = FClamp(0.28 * (scaledist - distance) / scaledist, 0.1, 0.25);

    if(distance <= class'Freon_Trigger'.default.CollisionRadius)
        C.DrawColor = class'Freon_PRI'.default.FrozenColor;
    else
        C.DrawColor = class'Freon_PRI'.default.FrozenColor * 0.75;

    C.Style = ERenderStyle.STY_Normal;
	
	MPRI = Misc_PRI(P.PlayerReplicationInfo);
	FPRI = Freon_PawnReplicationInfo(MPRI.PawnReplicationInfo);
	if (Freon_Pawn(P) != None && FPRI.bKilledSelf){
		if (FPRI.bLavaSafe){
			mytexture = SuicideBeacon;
		}
		else{
			mytexture = DeathBeacon;
		}
	}
	else{
		mytexture = FrozenBeacon;
	}
	
	TUSize = mytexture.USize;
	TVSize = mytexture.VSize;

    if(distance < PlayerOwner.TeamBeaconPlayerInfoMaxDist)
    {
        C.Font = C.SmallFont;

        if(class'TAM_ScoreBoard'.default.bEnableColoredNamesOnHUD)
            name = MPRI.GetColoredName();
        else
            name = MPRI.PlayerName;
        info = name $ " (" $ P.Health $ "%)";

        C.TextSize(info, XL, YL);
        C.SetPos(ScreenLoc.X - 0.125 * TUSize, ScreenLoc.Y - 0.125 * TVSize - YL);
        C.DrawTextClipped(info, false);

        // thaw bar
        C.SetPos(ScreenLoc.X + 1.25 * TUSize * scale, ScreenLoc.Y + 0.1 * TVSize * scale);
        C.DrawTileStretched(ThawBackMat, ThawBarWidth, TVSize * scale * 0.5);

        C.SetPos(ScreenLoc.X + 1.25 * TUSize * scale, ScreenLoc.Y + 0.1 * TVSize * scale);
        C.DrawTileStretched(ThawBarMat, ThawBarWidth * (P.Health / 100.0), TVSize * scale * 0.5);
    }

    C.SetPos(ScreenLoc.X - 0.125 * TUSize * scale, ScreenLoc.Y - 0.125 * TVSize * scale);
	
    C.DrawTile(mytexture,
        TUSize * scale,
        TVSize * scale,
        0.0,
        0.0,
        TUSize,
        TVSize);
}


simulated function bool ShouldDrawPlayer(Misc_PRI PRI)
{
	local Freon_PawnReplicationInfo FPRI;

    if(PRI == None || PRI.Team == None)
        return false;

	FPRI = Freon_PawnReplicationInfo(PRI.PawnReplicationInfo);
    if(FPRI == None || (PRI.bOutOfLives && !FPRI.bFrozen))
        return false;

    // Show PlayerOwner only if frozen
    // Player can see their HUD entry from other players HUD when frozen spec-ing
    if(PRI == PlayerOwner.PlayerReplicationInfo)
    {
        if(!FPRI.bFrozen)
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

function FastDraw2DLocationDot(Canvas C, vector Loc, int CenterX, int CenterY, int dotSize, int HalfdotSize, int length, vector MyLocation, vector MyLocationX, vector MyLocationY)
{
    local vector Dir;
    local float Forward, Side, Scale;
    local int posCenterX, posCenterY;

    Dir = Loc - MyLocation;
    Dir.Z = 0;

    Forward = Dir Dot MyLocationX;
    Side    = Dir Dot MyLocationY;

    Scale = length / Sqrt(Forward*Forward + Side*Side);

    posCenterX = CenterX + Side * Scale;
    posCenterY = CenterY - Forward * Scale;

    C.SetPos(posCenterX - HalfdotSize, posCenterY - HalfdotSize);

    C.Style = ERenderStyle.STY_Alpha;
    C.DrawTile(LocationDot, dotSize, dotSize, 340, 432, 78, 78);
}

// Optimised for speed by Piglet, without too much change in function.
simulated function DrawPlayersExtendedZAxis(Canvas C, bool ExtendedInfo)
{
    local int i;
    local int HUDOwnerTeam; //team for the HUDOwner
    local float xl;
    local float yl;
    local int posy;
    local string name;
    local Misc_PRI pri;
    local int health;
	local int radarCenterY;
    local int allies;
    local int enemies;
	local Freon_PawnReplicationInfo FPRI;
	local color HealthRampColor;
	local Freon_Player FP;
	local Actor Start;
	local vector MyLocation, MyLocationX, MyLocationY, MyLocationZ;
	
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

	C.Font = GetFontSizeIndex(C, -3);
	//Determine whether calculations need to be re-done. Calculations typically done only once on first HUD frame of the map, and then these values used for the rest of the game.
	if (class'Misc_Player'.default.bHUDChanged || oldClipy != C.ClipY || oldClipX != C.ClipX)
	{
		MaxHUDPlayerCount = class'Misc_Player'.default.MaxHUDPlayerCount -1;	// counting from zero due to point of check
		if (MaxHUDPlayerCount == -1) return;
		oldClipy = C.ClipY;
		oldClipX = C.ClipX;
		class'Misc_Player'.default.bHUDChanged = False;

		ZAStartListY = 0.08 * HUDScale * C.ClipY; // Y axis start player entries
		ZAheight = C.ClipY * 0.02;
		heightOffset = ZAheight * 1.1;
		C.StrLen("X", CU, yl);
		ZAnamey = (ZAheight * 0.6) - (yl * 0.5);
		if (ExtendedInfo){
			heightPlusSpaceA = ZAheight + ZAheight + int(0.0075 * C.ClipY);
			//calc the size of the radar and use this to space out the name and location bars
			radarSize = (heightPlusSpaceA) * 0.82; // fill 82% of player entry height with radar
		}
		else{
			heightPlusSpaceA = ZAheight + int(0.022 * C.ClipY);
			radarSize = (heightPlusSpaceA) * 0.9; // fill 82% of player entry height with radar
		}

		HeightDotSize = radarSize * 0.25; // 25% diameter
		HalfHeightDotSize = HeightDotSize * 0.5;
		HeightStep = radarSize * 0.1;

		heightPlusSpaceE = ZAheight + int(0.005 * C.ClipY);
		posxA = int(CU*0.5); //set posxA for allies to left side
		//start of text area backgrounds
		namexA = radarSize + CU;
        widthA = C.ClipX * 0.12;
        MaxNamePosA = widthA - CU*2.75; //width for Allies text
		FrozenColorBack = class'Freon_PRI'.default.FrozenColor * 0.6;
		startX = (C.ClipX * 0.015) + widthA + radarSize;
		halfRadarSize = (radarSize+1) * 0.5;
		ZAradarCenterX = posxA + halfRadarSize;
		healthBlob = (radarSize * 0.80);
		halfHealthBlob = healthBlob * 0.5;
		BGRI = Misc_BaseGRI(MyOwner.GameReplicationInfo);
		dotSize = radarSize * 0.35; // 35% diameter
		HalfdotSize = dotSize * 0.5;
		dotLength = (radarSize - (dotSize * 0.5)) * 0.5;

		//Enemies:
		scale = 0.75; // radar size old method
        namexE = C.ClipX * 0.02;
        widthE = C.ClipX * 0.11;
        MaxNamePosE = 0.99 * (widthE - namexE);
        posxE = C.ClipX * 0.99;
		discSize = C.ClipX * 0.0195 * Scale;
		HDxoffset = 0.016 * Scale * C.ClipX;
		HDWidth = C.ClipX * 0.0165 * Scale;
		HDHeight = C.ClipY * 0.0185 * Scale;
		HDHeightOffset = 0.0035 * Scale * C.ClipY;
		discSizeSquash = C.ClipY * 0.026 * Scale;

	}

	if (MaxHUDPlayerCount == -1) return;

	// Things to calculate every frame - but only before looping, so it's only done once rather than for every loop iteration
	// Calculate base point for direction and height indicators
    if (PlayerOwner.Pawn != None)				// Live
        Start = PlayerOwner.Pawn;
    else
	{
		FP = Freon_Player(PlayerOwner);			// Frozen
		if (FP != None && FP.FrozenPawn != None)
			Start = FP.FrozenPawn;				// Piglet: Want to know how to change this to the rotation of the 3rd person view of the frozen player
		else
			if (PlayerOwner.ViewTarget != None)	// Spectating
				Start = PlayerOwner.ViewTarget;
			else
				Start = PlayerOwner;			// Dead
	}

    MyLocation = Start.Location;
	GetAxes(Start.Rotation, MyLocationX, MyLocationY, MyLocationZ); //save away current rotation
    //
    // draw own team / allies
    //
    // loop this twice, once for each team, allies first
    for(i = 0; i < MyOwner.GameReplicationInfo.PRIArray.Length; i++)
    {
        if(allies > MaxHUDPlayerCount)
            break;

        PRI = Misc_PRI(myOwner.GameReplicationInfo.PRIArray[i]);
		FPRI = Freon_PawnReplicationInfo(PRI.PawnReplicationInfo);

        if(!ShouldDrawPlayer(PRI))
            continue;

        if(PRI.Team.TeamIndex != HUDOwnerTeam)
            continue; // allies first

        posy = ZAStartListY + (heightPlusSpaceA * allies);	// Vertical alignment of drawing

		HealthRampColor = GetHealthRampColor(PRI);

        //draw the text areas if they are showing team info
        if(class'Misc_Player'.default.bShowTeamInfo)
        {
            // draw text area backgrounds
            //
            if(FPRI != None && FPRI.bFrozen)
            {
                C.DrawColor = FrozenColorBack;
            }
            else
            {
                C.DrawColor = default.BlackColor;
            }

            C.SetPos(namexA, posy);
            C.DrawColor.A = 100;
            C.DrawTile(TeamTex, widthA, ZAheight, 168, 211, 166, 44);

			if (ExtendedInfo){
				C.SetPos(namexA, posy + heightOffset);
				C.DrawTile(TeamTex, widthA, ZAheight, 168, 211, 166, 44);
			}

            //
            // draw player name
            //
            if(class'TAM_ScoreBoard'.default.bEnableColoredNamesOnHUD)
                name = PRI.GetColoredName();
            else
                name = PRI.PlayerName;

            C.DrawColor = NameColor;
            C.SetPos(namexA, posy + ZAnamey);
            class'Misc_Util'.static.DrawTextClipped(C, name, MaxNamePosA);

			if (ExtendedInfo)
			{
				// draw player map location
				//
				name = PRI.GetLocationName();
				if(FPRI != None && FPRI.bFrozen)
					C.DrawColor = class'Freon_PRI'.default.FrozenColor;
				else
					C.DrawColor = LocationColor;
				C.SetPos(namexA, posy + heightOffset + ZAnamey);
				class'Misc_Util'.static.DrawTextClipped(C, name, MaxNamePosA);

				//
				// health text
				//
				if(FPRI != None &&
				   FPRI.bFrozen)
				{
					health = PRI.PawnReplicationInfo.Health;
					health = PRI.PawnReplicationInfo.Health;
				}
				else
				{
					health = PRI.PawnReplicationInfo.Health + PRI.PawnReplicationInfo.Shield;
				}

				name = string(health);
				C.StrLen(name, xl, yl);
				C.SetPos(startx - xl, posy + ZAnamey);
				C.DrawColor = HealthRampColor;
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
				C.SetPos(startX - xl, posy + heightOffset + ZAnamey);
				C.DrawText(name);
			}
        }

        //
        // draw outer radar disc
        //
        C.SetPos(posxA, posy);
        C.DrawColor = default.WhiteColor;
        C.DrawTile(TeamTex, radarSize, radarSize, 121, 260, 51, 51); //hagis crops

        //calc radar circle center
        radarCenterY = posy + halfRadarSize;

        //
        // draw health dot
        //
        // use circle center to calc the position (need to find top left corner)
        // health dot size is 80% of radarSize 
        C.SetPos(ZAradarCenterX - halfHealthBlob, radarCenterY - halfHealthBlob);
        C.DrawColor = HealthRampColor;
        C.DrawTile(Hudzaxis, healthBlob, healthBlob, 1, 1, 78, 78);

		//draw height dot or plus/minus depending on preference

		if(PlayerOwner.ViewTarget != None && BGRI != None){
			if(BGRI.UseZAxisRadar && class'Misc_Player'.default.bUsePlus){

				//same position as the dot
				C.SetPos(ZAradarCenterX - halfHealthBlob, radarCenterY - halfHealthBlob);

				// player height is 88 use two player heights 176
				if(PRI.PawnReplicationInfo.Position.Z > (PlayerOwner.ViewTarget.Location.Z + 176))
					C.DrawTile(Hudzaxis, healthBlob, healthBlob, 80, 1, 78, 78); //plus
				else if (PRI.PawnReplicationInfo.Position.Z < (PlayerOwner.ViewTarget.Location.Z - 176))
					C.DrawTile(Hudzaxis, healthBlob, healthBlob, 160, 1, 78, 78); //minus
				}			
			else
				if (BGRI.bHeightRadar){
					C.DrawColor = HeightDotColor;
					FastDraw2DHeightDot(C, PRI.PawnReplicationInfo.Position, ZAradarCenterX, radarCenterY, radarSize, MyLocation,  HeightDotSize, HalfHeightDotSize, HeightStep);
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
            FastDraw2DLocationDot(C, PRI.PawnReplicationInfo.Position, ZAradarCenterX, radarCenterY, dotSize, HalfdotSize, dotLength, MyLocation, MyLocationX, MyLocationY);
		}
        // friends shown
        allies++;
    }

    //
    // enemies
    //
    for(i = 0; i < MyOwner.GameReplicationInfo.PRIArray.Length; i++)
    {
        if(enemies > MaxHUDPlayerCount)
            break;

        PRI = Misc_PRI(myOwner.GameReplicationInfo.PRIArray[i]);
		FPRI = Freon_PawnReplicationInfo(PRI.PawnReplicationInfo);

        if(!ShouldDrawPlayer(PRI))
            continue;

        if(PRI.Team.TeamIndex == HUDOwnerTeam)
            continue;


        posy = ZAStartListY + (heightPlusSpaceE * enemies);

        //draw the text areas if they are showing team info
        if(class'Misc_Player'.default.bShowTeamInfo)
        {
            // draw background
            C.SetPos(posxE - widthE, posy);
            if(FPRI != None && FPRI.bFrozen)
            {
                C.DrawColor = FrozenColorBack;
            }
            else
            {
                C.DrawColor = default.BlackColor;
            }
            C.DrawColor.A = 100;
            C.DrawTile(TeamTex, widthE, ZAheight, 168, 211, 166, 44);

            // draw name
            if(class'TAM_ScoreBoard'.default.bEnableColoredNamesOnHUD)
                name = PRI.GetColoredName();
            else
                name = PRI.PlayerName;

            C.TextSize(name, xl, yl);
            xl = Min(xl, MaxNamePosE);
            C.DrawColor = NameColor;
            C.SetPos(posxE - xl - namexE, posy + ZAnamey);
            class'Misc_Util'.static.DrawTextClipped(C, name, MaxNamePosE);
        }

        // draw disc
        C.SetPos(posxE - discSize, posy);
        C.DrawColor = default.WhiteColor;
        C.DrawTile(TeamTex, discSize, discSizeSquash, 119, 258, 54, 55);

        // draw health dot
        if(FPRI!= None && FPRI.bFrozen)
        {
            C.DrawColor = class'Freon_PRI'.default.FrozenColor;
        }
        else
        {
            C.DrawColor = HudColorTeam[PRI.Team.TeamIndex];
        }
        C.SetPos(posxE - HDxoffset, posy + HDHeightOffset);
        C.DrawTile(TeamTex, HDWidth, HDHeight, 340, 432, 78, 78);

        // enemies shown
        enemies++;
    }
}

/// Start of old stuff after this point - left in because some people might like it.
#include Classes\Include\Freon_HUD_old_legacycrap.uci
/// End of old stuff.


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
