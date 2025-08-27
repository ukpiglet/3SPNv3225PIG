class Freon extends TeamArenaMaster DependsOn(TAM_Mutator);

#exec AUDIO IMPORT FILE="Sounds\Teleport.wav"

var config float AutoThawTime;
var config float ThawSpeed;
var config float MinHealthOnThaw;
var config float ThawPointAward;

var bool  bTeamHeal;

var array<Freon_Pawn> FrozenPawns;

//var config int NextRoundDelayFreon;
var config bool TeleportOnThaw;
var config bool bSpawnProtectionOnThaw;
var config bool bCanStandOnIcicle;
var config bool bEnemyBioThaws;
var config float EnemyBioThawPercent;
var config bool bChooseResThawingLast;
var config bool bChooseResDeadFirst;

var config bool KillGitters;
var config int iAdrenGitters;
var config int AdrenGitLose;
var config bool bAllowSelfKillThaw;
var config bool bNoTriggerProtection;
var config bool bFullThaws;
var config bool bShowThawMoments;
var config bool bChargeLowGun;
var config int MaxGitsAllowed;
var config color KillGitterMsgColour;
var config string KillGitterMsg;
var config float SelfKillThawScale;
var config float SelfKillLavaThawtime;
var config bool NoTriggerProtectionMsg;
var config bool bThawPuff;

var Sound TeleportSound;

var config bool bAwardAmmoOnThaw;

//Otherwise Log message: Freon DM-UCMP-Contrast-SE_Beta2.Freon (Function Engine.GameInfo.EndLogging:0027) 
function EndLogging(string Reason)
{
	if (GameStats == None)
		return;
	GameStats.EndGame(Reason);
	if (GameStats != None) GameStats.Destroy();
	GameStats = None;
}

function Killed(Controller Killer, Controller Killed, Pawn KilledPawn, class<DamageType> DamageType)
{
	//if "shattered", then it's not a real kill. Don't count it as a kill or death on scoreboard or for Vendetta etc.
	if (!ClassIsChildOf(DamageType, class'DamTypeShattered'))
		Super.Killed(Killer, Killed, KilledPawn, DamageType);
	
	if(Killed != None && Killed.PlayerReplicationInfo != None)
	{
		if(bRespawning && Freon(Level.Game)==None)
		{
			Killed.PlayerReplicationInfo.bOutOfLives = false;
			Killed.PlayerReplicationInfo.NumLives = 1;

			if(PlayerController(Killed)!=None)
				PlayerController(Killed).ClientReset();
			Killed.Reset();
			if(PlayerController(Killed)!=None)
				PlayerController(Killed).GotoState('Spectating');

			RestartPlayer(Killed);
			return;
		}
		else
		{
			Killed.PlayerReplicationInfo.bOutOfLives = true;
			Killed.PlayerReplicationInfo.NumLives = 0;
		}

		if(Killed.GetTeamNum() != 255 && !(Team_GameBase(Level.Game).bEndOfRound || Team_GameBase(Level.Game).EndOfRoundTime>0))   //Shatter (or any end of round death) should not increase team deaths, nor trigger alone sound
		{
			Deaths[Killed.GetTeamNum()]++;
			CheckForAlone(Killed, Killed.GetTeamNum());
		}
	}
}


function InitGameReplicationInfo()
{
    Super.InitGameReplicationInfo();

    if(Freon_GRI(GameReplicationInfo) == None)
        return;

    Freon_GRI(GameReplicationInfo).AutoThawTime = AutoThawTime;
    Freon_GRI(GameReplicationInfo).ThawSpeed = ThawSpeed;
    Freon_GRI(GameReplicationInfo).bTeamHeal = bTeamHeal;
    Freon_GRI(GameReplicationInfo).ThawPointAward = ThawPointAward;
	Freon_GRI(GameReplicationInfo).bFullThaws = bFullThaws;
	Freon_GRI(GameReplicationInfo).bShowThawMoments = bShowThawMoments;
	Freon_GRI(GameReplicationInfo).bEnemyBioThaws = bEnemyBioThaws;
}

function StartNewRound()
{
    FrozenPawns.Remove(0, FrozenPawns.Length);

    Super.StartNewRound();
}


function ShowPathTo(PlayerController P, int TeamNum)
{
	local Freon_Pawn			Best;
	local class<WillowWhisp>	WWclass;
	local float BestDist, Dist;
	local int myteam, i;
	
	myteam = P.GetTeamNum();

	BestDist = 99999;
    for(i = 0; i < FrozenPawns.Length; i++)
    {
		if (FrozenPawns[i] != none && FrozenPawns[i].GetTeamNum() == myteam){
			Dist = VSize(FrozenPawns[i].Location - P.Pawn.Location);
			if (Dist < BestDist){
				BestDist = Dist;
				Best = FrozenPawns[i];
			}
		}
    }

	if ( (Best != None) && (P.FindPathToward(Best, false) != None) )
	{
		WWclass = class<WillowWhisp>(DynamicLoadObject(PathWhisps[TeamNum], class'Class'));
		Spawn(WWclass, P,, P.Pawn.Location);
	}
}



static function FillPlayInfo(PlayInfo PI)
{
	local byte Weight; // weight must be a byte (max value 127?)
	
	Weight=0;
	
    Super.FillPlayInfo(PI);

    //weight is held in a byte (max value 127?)
    PI.AddSetting("3SPN Freon", "bSpawnProtectionOnThaw", "Enable Spawn Protection After Thawing", 0, Weight++, "Check");
    PI.AddSetting("3SPN Freon", "TeleportOnThaw", "Teleport After Thawing", 0, Weight++, "Check");
    PI.AddSetting("3SPN Freon", "AutoThawTime", "Automatic Thawing Time", 0, Weight++, "Text", "3;0:999");

    PI.AddSetting("3SPN Freon", "ThawSpeed", "Touch Thawing Time", 0, Weight++, "Text", "3;0:999");
    PI.AddSetting("3SPN Freon", "MinHealthOnThaw", "Minimum Health After Thawing", 0, Weight++, "Text", "3;0:999");
    PI.AddSetting("3SPN Freon", "ThawPointAward", "Thaw Points Award", 0, Weight++, "Text", "8;0:999");
    PI.AddSetting("3SPN Freon", "KillGitters", "Kill Gitters", 0, Weight++, "Check");
    PI.AddSetting("3SPN Freon", "MaxGitsAllowed", "Max Gits Allowed", 0, Weight++, "Text", "3;0:999");
	PI.AddSetting("3SPN Freon", "iAdrenGitters", "Deduct Adren from Gitters after this many", 0, Weight++, "Text", "3;0:999");
	PI.AddSetting("3SPN Freon", "AdrenGitLose", "How much adrenaline to deduct", 0, Weight++, "Text", "3;0:999");
	PI.AddSetting("3SPN Freon", "bAwardAmmoOnThaw", "Ammo Reward Thaw", 0, Weight++, "Check",,, False);
	PI.AddSetting("3SPN Freon", "bChargeLowGun", "Reward ammo to lowest charge gun if held one is not < starting ammo", 0, Weight++, "Check");
	PI.AddSetting("3SPN Freon", "bAllowSelfKillThaw", "Allow self kill/thaw from lava", 0, Weight++, "Check");
	PI.AddSetting("3SPN Freon", "bNoTriggerProtection", "No protection when thaw in thawing range", 0, Weight++, "Check");
	PI.AddSetting("3SPN Freon", "bCanStandOnIcicle", "Can stand on frozen players", 0, Weight++, "Check");
	PI.AddSetting("3SPN Freon", "bEnemyBioThaws", "Enemy Bio Heals Frozen", 0, Weight++, "Check");
	PI.AddSetting("3SPN Freon", "EnemyBioThawPercent", "Enemy Bio Heals damage percentage", 0, Weight++, "Text", "5;0:100");
	PI.AddSetting("3SPN Freon", "bChooseResThawingLast", "Only resurrect thawing player if no others", 0, Weight++, "Check");
	PI.AddSetting("3SPN Freon", "bChooseResDeadFirst", "Resurrect dead player first", 0, Weight++, "Check");
	PI.AddSetting("3SPN Freon", "SelfKillThawScale", "Self kill thaw scale", 0, Weight++, "Text", "5;0:1");
	PI.AddSetting("3SPN Freon", "SelfKillLavaThawtime", "How long after self kill is lava safe", 0, Weight++, "Text", "7;0:99");
	PI.AddSetting("3SPN Freon", "bFullThaws", "Count and reward every 100 health added in thawing", 0, Weight++, "Check");
	PI.AddSetting("3SPN Freon", "bShowThawMoments", "Show how often present at a thaw", 0, Weight++, "Check");
	PI.AddSetting("3SPN Freon", "bThawPuff", "Spawn lava effect & sound when thawing", 0, Weight++, "Check");
}


static event string GetDescriptionText(string PropName)
{
    switch(PropName)
    {
        case "bSpawnProtectionOnThaw":  return "Enable Spawn Protection After Thawing";
        case "TeleportOnThaw":          return "Teleport After Thawing";
        case "AutoThawTime":            return "Automatic Thawing Time";
        case "ThawSpeed":               return "Touch Thawing Time";
        case "MinHealthOnThaw":         return "Minimum Health After Thawing";
        case "KillGitters":             return "Kill Gitters";
        case "MaxGitsAllowed":          return "Max Gits Allowed";
		case "MaxGitsAllowed":          return "Max Gits Allowed";
        case "iAdrenGitters":           return "Deduct Adren from Gitters after this many gits";
        case "AdrenGitLose":            return "How much adrenline for gitters to lose each time";
		case "bAwardAmmoOnThaw":		return "Award one unit of berzerk ammo as a thaw reward";
		case "ThawPointAward":		    return "Award points as a thaw reward";
		case "bAllowSelfKillThaw":      return "Allow players to freeze themselves into lava for a full thaw";
		case "bNoTriggerProtection":    return "No protection when players thaw in range of another teammate needing thawing";
		case "bCanStandOnIcicle":       return "Turn on to be able to stand on frozen players";
		case "bEnemyBioThaws":          return "Turn on to be make enemy bio heal frozen players";
		case "EnemyBioThawPercent":     return "Percentage of bio damage taken as thaw";
		case "bChooseResThawingLast":   return "Only thaw a player being thawed if there's nobody else to choose";
		case "bChooseResDeadFirst":     return "Thaw dead people regardless of how long others have been waiting";
		case "SelfKillThawScale":       return "What percentage of speed to thaw if player killed self";
		case "SelfKillLavaThawtime":    return "If self kill and land in lava before this time passes, you don't get thaw protection";
		case "bFullThaws":              return "Get rewarded for the thaw contribution, not just being there at the end!";
		case "bShowThawMoments":        return "Show 'Being there at the end!' in place of rank on scoreboard";
		case "bThawPuff":               return "Turn it off for just the thaw sound";
		case "bChargeLowGun":           return "If not selected then will charge held gun towards gun maximum";
    }

    return Super.GetDescriptionText(PropName);
}

function ParseOptions(string Options)
{
    local string InOpt;

    Super.ParseOptions(Options);

    InOpt = ParseOption(Options, "AutoThawTime");
    if(InOpt != "")
        AutoThawTime = float(InOpt);

    InOpt = ParseOption(Options, "ThawSpeed");
    if(InOpt != "")
        ThawSpeed = float(InOpt);

    InOpt = ParseOption(Options, "TeamHeal");
    if(InOpt != "")
        bTeamHeal = bool(InOpt);

    InOpt = ParseOption(Options, "ThawPointAward");
    if(InOpt != "")
        ThawPointAward = float(InOpt);

    InOpt = ParseOption(Options, "bDeathFire");
    if(InOpt != "")
        bDeathFire = bool(InOpt);

    InOpt = ParseOption(Options, "bAwardAmmoOnThaw");
    if(InOpt != "")
        bAwardAmmoOnThaw = bool(InOpt);
		
}

event InitGame(string options, out string error)
{
	
    Super.InitGame(Options, Error);

    class'xPawn'.Default.ControllerClass = class'Freon_Bot';

    //NextRoundDelay = NextRoundDelayFreon;
}

function string SwapDefaultCombo(string ComboName)
{
    if(ComboName ~= "xGame.ComboSpeed")
        return "3SPNv3225PIG.Freon_ComboSpeed";
    else if(ComboName ~= "xGame.ComboBerserk")
        return "3SPNv3225PIG.Misc_ComboBerserk";

    return ComboName;
}

function PawnFroze(Freon_Pawn Frozen)
{
    local int i;

    for(i = 0; i < FrozenPawns.Length; i++)
    {
        if(FrozenPawns[i] == Frozen)
            return;
    }

    FrozenPawns[FrozenPawns.Length] = Frozen;
    Frozen.Spree = 0;

    if(Misc_Player(Frozen.Controller) != None)
        Misc_Player(Frozen.Controller).Spree = 0;
}

//
// Restart a thawing player. Same as RestartPlayer() just sans the spawn effects
//
function RestartFrozenPlayer(Controller aPlayer, vector Loc, rotator Rot, NavigationPoint Anchor)
{
    local int TeamNum;
    local class<Pawn> DefaultPlayerClass;
    local Vehicle V, Best;
    local vector ViewDir;
    local float BestDist, Dist;
    local TeamInfo BotTeam, OtherTeam;

    if ( (!bPlayersVsBots || (Level.NetMode == NM_Standalone)) && bBalanceTeams && (Bot(aPlayer) != None) && (!bCustomBots || (Level.NetMode != NM_Standalone)) )
    {
        BotTeam = aPlayer.PlayerReplicationInfo.Team;
        if ( BotTeam == Teams[0] )
            OtherTeam = Teams[1];
        else
            OtherTeam = Teams[0];

        if ( OtherTeam.Size < BotTeam.Size - 1 )
        {
            aPlayer.Destroy();
            return;
        }
    }

    if ( bMustJoinBeforeStart && (UnrealPlayer(aPlayer) != None)
        && UnrealPlayer(aPlayer).bLatecomer )
        return;

    if ( aPlayer.PlayerReplicationInfo.bOutOfLives )
        return;

    if ( aPlayer.IsA('Bot') && TooManyBots(aPlayer) )
    {
        aPlayer.Destroy();
        return;
    }

    if( bRestartLevel && Level.NetMode != NM_DedicatedServer && Level.NetMode != NM_ListenServer )
        return;

    if ( (aPlayer.PlayerReplicationInfo == None) || (aPlayer.PlayerReplicationInfo.Team == None) )
        TeamNum = 255;
    else
        TeamNum = aPlayer.PlayerReplicationInfo.Team.TeamIndex;

    if (aPlayer.PreviousPawnClass!=None && aPlayer.PawnClass != aPlayer.PreviousPawnClass)
        BaseMutator.PlayerChangedClass(aPlayer);

    if ( aPlayer.PawnClass != None )
        aPlayer.Pawn = Spawn(aPlayer.PawnClass,,, Loc, Rot);

    if( aPlayer.Pawn==None )
    {
        DefaultPlayerClass = GetDefaultPlayerClass(aPlayer);
        aPlayer.Pawn = Spawn(DefaultPlayerClass,,, Loc, Rot);
    }
    if ( aPlayer.Pawn == None )
    {
        log("Couldn't spawn player of type "$aPlayer.PawnClass$" at "$Location);
        aPlayer.GotoState('Dead');
        if ( PlayerController(aPlayer) != None )
            PlayerController(aPlayer).ClientGotoState('Dead','Begin');
        return;
    }
    if ( PlayerController(aPlayer) != None )
        PlayerController(aPlayer).TimeMargin = -0.1;
    if(Anchor != None)
        aPlayer.Pawn.Anchor = Anchor;
    aPlayer.Pawn.LastStartTime = Level.TimeSeconds;
    aPlayer.PreviousPawnClass = aPlayer.Pawn.Class;

    aPlayer.Possess(aPlayer.Pawn);
    aPlayer.PawnClass = aPlayer.Pawn.Class;

    //aPlayer.Pawn.PlayTeleportEffect(true, true);
    aPlayer.ClientSetRotation(aPlayer.Pawn.Rotation);
    AddDefaultInventory(aPlayer.Pawn);

    if ( bAllowVehicles && (Level.NetMode == NM_Standalone) && (PlayerController(aPlayer) != None) )
    {
        // tell bots not to get into nearby vehicles for a little while
        BestDist = 2000;
        ViewDir = vector(aPlayer.Pawn.Rotation);
        for ( V=VehicleList; V!=None; V=V.NextVehicle )
            if ( V.bTeamLocked && (aPlayer.GetTeamNum() == V.Team) )
            {
                Dist = VSize(V.Location - aPlayer.Pawn.Location);
                if ( (ViewDir Dot (V.Location - aPlayer.Pawn.Location)) < 0 )
                    Dist *= 2;
                if ( Dist < BestDist )
                {
                    Best = V;
                    BestDist = Dist;
                }
            }

        if ( Best != None )
            Best.PlayerStartTime = Level.TimeSeconds + 8;
    }
}

// if in health is 0, find the 'ambient' temperature of the map (the average of all player's health)
function PlayerThawed(Freon_Pawn Thawed, optional float Health, optional float Shield, optional bool dying)
{
    local vector Pos;
    local vector Vel;
    local rotator Rot;
    local Controller C;
    local array<TAM_Mutator.WeaponData> WD;
    local Inventory inv;
    local int i;
    local NavigationPoint N;
    local Controller LastHitBy;
    local int Team;
    local bool bGivesGit;
    local int TeamNum;
    local NavigationPoint startSpot;

    if(bEndOfRound)
        return;

    if(!dying && Health == 0.0)
    {
        for(C = Level.ControllerList; C != None; C = C.NextController)
        {
            if(C.Pawn != None)
            {
                Health += C.Pawn.Health;
                i++;
            }
        }

        if(i > 0)
            Health /= i;
    }

    if(!dying && TeleportOnThaw)
    {
        C = Thawed.Controller;

        if(C.PlayerReplicationInfo==None || C.PlayerReplicationInfo.Team==None)
            TeamNum = 255;
        else
            TeamNum = C.PlayerReplicationInfo.Team.TeamIndex;

        startSpot = Level.Game.FindPlayerStart(C, TeamNum);
    }

    if(startSpot != None)
    {
        Pos = startSpot.Location;
        Rot = startSpot.Rotation;
        Vel = vect(0,0,0);

        Thawed.PlaySound(TeleportSound, SLOT_None, 300.0);
        Thawed.PlayTeleportEffect(true, false);
    }
    else
    {
        Pos = Thawed.Location;
        Rot = Thawed.Rotation;
        Vel = Thawed.Velocity;
    }

    C = Thawed.Controller;
    N = Thawed.Anchor;
    LastHitBy = Thawed.LastHitBy;
    bGivesGit = Thawed.bGivesGit;

    if(C.PlayerReplicationInfo == None)
        return;

    // store ammo amounts
    WD = Thawed.MyWD;

    for(i = 0; i < FrozenPawns.Length; i++)
    {
        if(FrozenPawns[i] == Thawed)
            FrozenPawns.Remove(i, 1);
    }

    Thawed.Destroy();

    C.PlayerReplicationInfo.bOutOfLives = false;
    C.PlayerReplicationInfo.NumLives = 1;

    if(PlayerController(C) != None)
        PlayerController(C).ClientReset();

    RestartFrozenPlayer(C, Pos, Rot, N);
	
	if (C == None)	//can be destroyed by RestartFrozenPlayer()
		return;
	
    if(C.Pawn != None)
    {
        C.Pawn.SetLocation(Pos);
        C.Pawn.SetRotation(Rot);
        C.Pawn.AddVelocity(Vel);
        C.Pawn.LastHitBy = LastHitBy;

        if(!dying)
        {
            // redistribute ammo
            for(inv = C.Pawn.Inventory; inv != None; inv = inv.Inventory)
            {
                if(Weapon(inv) == None)
                    return;

                for(i = 0; i < WD.Length; i++)
                {
                    if(WD[i].WeaponName ~= string(inv.Class))
                    {
                        Weapon(inv).AmmoCharge[0] = WD[i].Ammo[0];
                        Weapon(inv).AmmoCharge[1] = WD[i].Ammo[1];
						
						// Special shield gun alt fire fix...from Sol
                        // This happens because there are client side timers that need to be reactived.
                        // Only stop/start fire sets the timers.
                        if(Weapon(inv).IsA('ShieldGun')) 
                        {
                            Weapon(inv).StopFire(1);
                            Weapon(inv).AddAmmo(100 - Weapon(inv).AmmoAmount(1), 1);
                        }
                        break;
                    }
                }
            }

            if(Health != 0.0)
            {
                C.Pawn.Health = Max(MinHealthOnThaw,Health);
            }
            else
            {
                C.Pawn.Health = MinHealthOnThaw;
            }
            C.Pawn.ShieldStrength = Shield;
        }

        if(Freon_Pawn(C.Pawn)!=None)
            Freon_Pawn(C.Pawn).bGivesGit = bGivesGit;

        if(dying || bSpawnProtectionOnThaw==False && Misc_Pawn(C.Pawn)!=None)
            Misc_Pawn(C.Pawn).DeactivateSpawnProtection();
    }

    if(PlayerController(C) != None)
        PlayerController(C).ClientSetRotation(Rot);

    Team = C.GetTeamNum();
    if(Team == 255)
        return;

    if(TAM_TeamInfo(Teams[Team]) != None && TAM_TeamInfo(Teams[Team]).ComboManager != None)
        TAM_TeamInfo(Teams[Team]).ComboManager.PlayerSpawned(C);
    else if(TAM_TeamInfoRed(Teams[Team]) != None && TAM_TeamInfoRed(Teams[Team]).ComboManager != None)
        TAM_TeamInfoRed(Teams[Team]).ComboManager.PlayerSpawned(C);
    else if(TAM_TeamInfoBlue(Teams[Team]) != None && TAM_TeamInfoBlue(Teams[Team]).ComboManager != None)
        TAM_TeamInfoBlue(Teams[Team]).ComboManager.PlayerSpawned(C);

    if(!dying && C.Pawn != None)
    {
        BroadcastLocalizedMessage(class'Freon_ThawMessage', 255, C.Pawn.PlayerReplicationInfo);
    }
}

function RewardFullThawers(array<Freon_Pawn> Thawers, float HealthGain){
	
	local int i;
	local int PrevTotal, NewTotal;
	local Freon_PRI xPRI;
	
    for(i = 0; i < Thawers.Length; i++){
		xPRI = Freon_PRI(Thawers[i].PlayerReplicationInfo);
		if (xPRI != None){
			PrevTotal = int(xPRI.HealthGiven/50);
			xPRI.HealthGiven += HealthGain;
			NewTotal = int(xPRI.HealthGiven/50);
			if (PrevTotal != NewTotal){
				RewardThaw(Thawers[i], ThawPointAward, 6.0f, 2);
				if (NewTotal%2 == 0){
					WholeThaw(Thawers[i]);
					SpecialEvent(xPRI, "Thaw"); //allow stats for thawing
				}
			}
		}
	}
}

function PlayerThawedByTouch(Freon_Pawn Thawed, array<Freon_Pawn> Thawers, optional float Health, optional float Shield)
{
    local Controller C;
    local int i;
	local Freon_PRI xPRI;

    if(bEndOfRound)
        return;

    C = Thawed.Controller;
    PlayerThawed(Thawed, Health, Shield);

    if( C != None )	//can be destroyed in PlayerThawed() - but still continue and award points as they did the thaw!
    {   
		if(PlayerController(C) != None)
			PlayerController(C).ReceiveLocalizedMessage(class'Freon_ThawMessage', 0, Thawers[0].PlayerReplicationInfo);

		if(C.PlayerReplicationInfo == None)
			return;
	}

    for(i = 0; i < Thawers.Length; i++){
		if (!Freon(Level.Game).bFullThaws){
			RewardThaw(Thawers[i], ThawPointAward, 5.0f, 1);
			WholeThaw(Thawers[i]);
		}
		
		xPRI = Freon_PRI(Thawers[i].PlayerReplicationInfo);
		if (xPRI != None){
			xPRI.Thaws++;
			SpecialEvent(xPRI, "Thaw"); //allow stats for thawing
		}
				
		if(C != None && PlayerController(Thawers[i].Controller) != None)
			PlayerController(Thawers[i].Controller).ReceiveLocalizedMessage(class'Freon_ThawMessage', 1, C.PlayerReplicationInfo);
	}
}

function RewardThaw(Freon_Pawn Thawer, float ScoreToAdd, float AdrenToAdd, int AmmoTimes)
{
    local int i;

	if(ScoreToAdd != 0 && Thawer.PlayerReplicationInfo != None)
		Thawer.PlayerReplicationInfo.Score += ScoreToAdd;

	if(Thawer.Controller != None && AdrenToAdd != 0)
		Thawer.Controller.AwardAdrenaline(AdrenToAdd);

	if (bAwardAmmoOnThaw){
		for (i = 0; i < AmmoTimes; i++){
			GiveReward(Thawer);
		}
	}
}

function WholeThaw(Freon_Pawn Thawer){
	
	local Freon_PRI xPRI;
    local class<LocalMessage> Message;
	local int Thaws;
	
	xPRI = Freon_PRI(Thawer.PlayerReplicationInfo);
	if (xPRI != None)
	{
		Message = None;
		
	
		if (Freon(Level.Game).bFullThaws){
			Thaws = int(xPRI.HealthGiven/100);
		}
		else{
			Thaws = xPRI.Thaws;
		}
		
		switch(Thaws)
		{
			case 10: Message = class'Message_Thaw_Flamer';      break;
			case 20: Message = class'Message_Thaw_Scorcher';    break;
			case 30: Message = class'Message_Thaw_Thawsome';    break;
			case 40: Message = class'Message_Thaw_Incinerator'; break;
			case 50: Message = class'Message_Thaw_GodOfThaw';   break;
			case 55: Message = class'Message_Thaw_Feeling_hot';   break;
			case 60: Message = class'Message_Thaw_hotter_than_hell';   break;
		}

		if(Message!=None)
		{
		   if(Misc_Player(Thawer.Controller)!=None)
			   Misc_Player(Thawer.Controller).BroadcastAnnouncement(Message);
		}
	}
}




function GiveReward(Freon_Pawn Thawer){


	if (bChargeLowGun)
		RewardButChargeLowIfNeeded(Thawer);
	else
		RewardHeldGunOnly(Thawer);
	
}

function RewardHeldGunOnly(Freon_Pawn Thawer){
//previous reward ammo strategy - up to max

    local Weapon heldWeapon;
    local float add;
	
    if(Thawer.Role == ROLE_Authority)
    {
        heldWeapon = Thawer.Weapon;
        if(heldWeapon == None)
            return;

        if(heldWeapon.GetAmmoClass(0) != None)
        {
            if(heldWeapon.GetAmmoClass(0).default.InitialAmount > 0)
                add = Max((heldWeapon.GetAmmoClass(0).default.InitialAmount * 0.1), 1);
            else
                add = Max((heldWeapon.MaxAmmo(0) / 2.5 * 0.1), 1); 
        }

        heldWeapon.AmmoCharge[0] = Min(heldWeapon.MaxAmmo(0), heldWeapon.AmmoCharge[0] + add);

        if(heldWeapon.GetAmmoClass(1) == None || heldWeapon.GetAmmoClass(0) == heldWeapon.GetAmmoClass(1))
            return;

        if(heldWeapon.GetAmmoClass(1).default.InitialAmount > 0)
            add = Max((heldWeapon.GetAmmoClass(1).default.InitialAmount * 0.1), 1);
        else
            add = Max((heldWeapon.MaxAmmo(1) / 2.5 * 0.1), 1);

        heldWeapon.AmmoCharge[1] = Min(heldWeapon.MaxAmmo(1), heldWeapon.AmmoCharge[1] + add);
    }
}

function RewardButChargeLowIfNeeded(Freon_Pawn Thawer){
//new reward stategy - reward to initial (or just over), but if up to that level load the lowest ammo gun
//this means that empty gun can be reloaded by selecting full gun (e.g. aassault)

    local Weapon heldWeapon;
    local int initial;
    local float add;

    if(Thawer.Role != ROLE_Authority)
		return;
	    
	heldWeapon = Thawer.Weapon;
	if(heldWeapon == None)
		return;

	initial = heldWeapon.GetAmmoClass(0).default.InitialAmount;
	
	if (heldWeapon.AmmoCharge[0] < initial){
		add = Max((initial * 0.1), 1);
		heldWeapon.AmmoCharge[0] = Min(heldWeapon.MaxAmmo(0), heldWeapon.AmmoCharge[0] + add);
	}
	else{
		ChargeLowWeapon(Thawer);
	}

	if(heldWeapon.GetAmmoClass(1) == None || heldWeapon.GetAmmoClass(0) == heldWeapon.GetAmmoClass(1))
		return;

	if(heldWeapon.GetAmmoClass(1).default.InitialAmount > 0)
		add = Max((heldWeapon.GetAmmoClass(1).default.InitialAmount * 0.1), 1);
	else
		add = Max((heldWeapon.MaxAmmo(1) / 2.5 * 0.1), 1);

	heldWeapon.AmmoCharge[1] = Min(heldWeapon.MaxAmmo(1), heldWeapon.AmmoCharge[1] + add);
    
}

function ChargeLowWeapon(Freon_Pawn Thawer){
    local Inventory inv;
	local Weapon  W, UsedWeapon;
	local float Used, MostUsed;
	local int add;

	for(inv = Thawer.Inventory; inv != None; inv = inv.Inventory){
		W = Weapon(inv);
		if(W == None)
			return;

		if (W.GetAmmoClass(0).default.InitialAmount != 0){
			Used = (W.GetAmmoClass(0).default.InitialAmount - W.AmmoCharge[0])/ W.GetAmmoClass(0).default.InitialAmount * 100;
			if (Used > MostUsed){
				MostUsed = Used;
				UsedWeapon = W;
			}
		}
	}
	
	if (UsedWeapon != None){
		add = Max((UsedWeapon.GetAmmoClass(0).default.InitialAmount * 0.1), 1);
		UsedWeapon.AmmoCharge[0] = Min(UsedWeapon.MaxAmmo(0), UsedWeapon.AmmoCharge[0] + add);
	}
}

function ReTrigger(Controller ThawedController){

	local Controller C;
	local float distance;
	local Freon_Pawn P;
	local Freon_Pawn ThawedPawn;
	local int ThawedTeam;
	local bool bProtected;
	local Freon Freon;
	
	bProtected = True;
	Freon = Freon(Level.Game);
	
	if (ThawedController == None || ThawedController.Pawn == None || Freon_Pawn(ThawedController.Pawn) == None){ // can be destroyed on restart (if a bot and too many of them)
		return;
	}

	ThawedPawn = Freon_Pawn(ThawedController.Pawn);	
	ThawedTeam = ThawedController.GetTeamNum();
	
	for(C = Level.ControllerList; C != None; C = C.NextController){
		if(C != ThawedController && C.GetTeamNum() == ThawedTeam){  //ignore self!
		
			//get the pawn of the contoller
			if((C.IsA('Freon_Player') && Freon_Player(C).FrozenPawn!=None) || (C.IsA('Freon_Bot') && Freon_Bot(C).FrozenPawn!=None)){
				if(Freon_Player(C)!=None){
					P = Freon_Player(C).FrozenPawn;
				}
				else{
					P = Freon_Bot(C).FrozenPawn;
				}
			}
			else{		
				P = Freon_Pawn(C.Pawn);
			}
			
			if (P != None){
				distance = VSize(ThawedPawn.Location - P.Location);
				if(distance <= class'Freon_Trigger'.default.CollisionRadius){
					P.MyTrigger.Touch(ThawedPawn);
					ThawedPawn.MyTrigger.Touch(P);
			
					if (bProtected && P.bFrozen && Freon.bNoTriggerProtection){
						ThawedPawn.DeactivateSpawnProtection();
						if (PlayerController(ThawedController) != None)
							PlayerController(ThawedController).ReceiveLocalizedMessage(class'Message_SpawnProtection', 0);
						//if (Freon(Level.Game).NoTriggerProtectionMsg && PlayerController(ThawedPawn.Controller) != None){
						//	PlayerController(ThawedPawn.Controller).ReceiveLocalizedMessage(class'Message_SpawnProtection', 0);
						//}
						bProtected=False;
					}
				}
			}
		}
	}
}

function bool CanSpectate(PlayerController Viewer, bool bOnlySpectator, actor ViewTarget)
{
    if(xPawn(ViewTarget) == None && (Controller(ViewTarget) == None || xPawn(Controller(ViewTarget).Pawn) == None))
        return false;

    if(bOnlySpectator)
    {
        if(Controller(ViewTarget) != None)
            return (Controller(ViewTarget).PlayerReplicationInfo != None && ViewTarget != Viewer);
        else
            return (xPawn(ViewTarget).IsPlayerPawn());
    }

    if(Viewer.Pawn != None)
        return false;

    if(bRespawning || (NextRoundTime <= 1 && bEndOfRound))
        return false;

    if(Controller(ViewTarget) != None)
        return (Controller(ViewTarget).PlayerReplicationInfo != None && ViewTarget != Viewer &&
                (bEndOfRound || (Controller(ViewTarget).GetTeamNum() == Viewer.GetTeamNum()) && Viewer.GetTeamNum() != 255));
    else
    {
        return (xPawn(ViewTarget).IsPlayerPawn() && xPawn(ViewTarget).PlayerReplicationInfo != None &&
                (bEndOfRound || (xPawn(ViewTarget).GetTeamNum() == Viewer.GetTeamNum()) && Viewer.GetTeamNum() != 255));
    }
}

function bool DestroyActor(Actor A)
{
    if(Freon_Pawn(A) != None && Freon_Pawn(A).bFrozen)
        return true;

    return Super.DestroyActor(A);
}

/*function QueueEndRound(PlayerReplicationInfo Scorer)
{
    EndRound(Scorer);
}*/

function EndRound(PlayerReplicationInfo Scorer)
{
    local Freon_Trigger FT;

    foreach DynamicActors(class'Freon_Trigger', FT)
        FT.Destroy();

    Super.EndRound(Scorer);
}

function AnnounceBest()
{
    local Controller C;

    local string acc;
    local string dam;
    local string hs;
    local string th;
    local string gt;

    local Freon_PRI PRI;
    local Misc_PRI accuracy;
    local Misc_PRI damage;
    local Misc_PRI headshots;
	local Misc_PRI longesths;
    local Freon_PRI thaws;
    local Freon_PRI git;

    local string Red;
    local string Blue;
    local string Text;
    local Color  color;
	local int thawsies;
	local string thawstring, thawstringprefix, plural;	

    Red = class'DMStatsScreen'.static.MakeColorCode(class'SayMessagePlus'.default.RedTeamColor);
    Blue = class'DMStatsScreen'.static.MakeColorCode(class'SayMessagePlus'.default.BlueTeamColor);

    color = class'Canvas'.static.MakeColor(210, 210, 210);
    Text = class'DMStatsScreen'.static.MakeColorCode(color);

    for(C = Level.ControllerList; C != None; C = C.NextController)
    {
        PRI = Freon_PRI(C.PlayerReplicationInfo);

        if(PRI == None || PRI.Team == None || PRI.bOnlySpectator)
            continue;

        PRI.ProcessHitStats();

        if(accuracy == None || (accuracy.AveragePercent < PRI.AveragePercent))
            accuracy = PRI;

        if(damage == None || (damage.EnemyDamage < PRI.EnemyDamage))
            damage = PRI;

        if(headshots == None || (headshots.Headshots < PRI.Headshots))
            headshots = PRI;
			
		if(longesths == None || (longesths.LongestHeadShotDistance < PRI.LongestHeadShotDistance))
			longesths = PRI;

		if(thaws == None || ((bFullThaws && thaws.HealthGiven < PRI.HealthGiven) || (!bFullThaws && thaws.Thaws < PRI.Thaws) )){
		    thaws = PRI;
		}

        if(git == None || (git.Git < PRI.Git))
            git = PRI;
    }

    if(accuracy != None && accuracy.AveragePercent > 0.0)
    {
        if(accuracy.Team.TeamIndex == 0)
        {
            if(class'Misc_Player'.default.bEnableColoredNamesInTalk)
                acc = Text$"Most Accurate:"@Red$accuracy.GetColoredName()$Text$";"@accuracy.AveragePercent$"%";
            else
                acc = Text$"Most Accurate:"@Red$accuracy.PlayerName$Text$";"@accuracy.AveragePercent$"%";
        }
        else
        {
            if(class'Misc_Player'.default.bEnableColoredNamesInTalk)
                acc = Text$"Most Accurate:"@Blue$accuracy.GetColoredName()$Text$";"@accuracy.AveragePercent$"%";
            else
                acc = Text$"Most Accurate:"@Blue$accuracy.PlayerName$Text$";"@accuracy.AveragePercent$"%";
        }
    }

    if(damage != None && damage.EnemyDamage > 0)
    {
        if(damage.Team.TeamIndex == 0)
        {
            if(class'Misc_Player'.default.bEnableColoredNamesInTalk)
                dam = Text$"Most Damage:"@Red$damage.GetColoredName()$Text$";"@damage.EnemyDamage;
            else
                dam = Text$"Most Damage:"@Red$damage.PlayerName$Text$";"@damage.EnemyDamage;
        }
        else
        {
            if(class'Misc_Player'.default.bEnableColoredNamesInTalk)
                dam = Text$"Most Damage:"@Blue$damage.GetColoredName()$Text$";"@damage.EnemyDamage;
            else
                dam = Text$"Most Damage:"@Blue$damage.PlayerName$Text$";"@damage.EnemyDamage;
        }
    }

    if(headshots != None && headshots.Headshots > 0)
    {
		if(headshots.Team.TeamIndex == 0)
        {
            if(class'Misc_Player'.default.bEnableColoredNamesInTalk)
			{
				hs = Text$"Most Headshots:"@Red$headshots.GetColoredName()$Text$";"@headshots.Headshots;
			}
            else
			{
				hs = Text$"Most Headshots:"@Red$headshots.PlayerName$Text$";"@headshots.Headshots;
			}
        }
        else
        {
            if(class'Misc_Player'.default.bEnableColoredNamesInTalk)
			{
				hs = Text$"Most Headshots:"@Blue$headshots.GetColoredName()$Text$";"@headshots.Headshots;
            }
			else
			{
				hs = Text$"Most Headshots:"@Blue$headshots.PlayerName$Text$";"@headshots.Headshots;
			}
		}
		if(longesths != None && longesths.LongestHeadShotDistance > 20)
		{
			if(longesths.Team.TeamIndex == 0)
			{
				if(class'Misc_Player'.default.bEnableColoredNamesInTalk)
					hs $= Text$"          Longest Headshot:"@longesths.LongestHeadShotDistance$Text$"m by "@Red$longesths.GetColoredName();
				else
					hs $= Text$"          Longest Headshot:"@longesths.LongestHeadShotDistance$Text$"m by "@Red$longesths.PlayerName;
			}
			else
			{
				if(class'Misc_Player'.default.bEnableColoredNamesInTalk)
					hs $= Text$"          Longest Headshot:"@longesths.LongestHeadShotDistance$Text$"m by "@Blue$longesths.GetColoredName();
				else
					hs $= Text$"          Longest Headshot:"@longesths.LongestHeadShotDistance$Text$"m by "@Blue$longesths.PlayerName;
			}
		}
	}


    if(thaws != None)
    {
		
		if (bFullThaws){
			if (thaws.Thaws == 1){
				plural="";
			}
			else{
				plural="s";
			}
			thawsies = int(thaws.HealthGiven);
		}
		else
			thawsies = thaws.Thaws;

		if (thawsies > 0){
			if (Freon(Level.Game).bFullThaws){
				thawstring = string(int(thaws.HealthGiven))@" (Present at"@thaws.Thaws@"thaw moment"$plural$")";
				thawstringprefix = "Most Thawhealth:";
			}
			else{
				thawstring = string(thaws.Thaws);
				thawstringprefix = "Most Thaws:";
			}
	
			if(thaws.Team.TeamIndex == 0)
			{
				if(class'Misc_Player'.default.bEnableColoredNamesInTalk)
					th =  Text$thawstringprefix@Red$thaws.GetColoredName()$Text$";"@thawstring@" ";
				else
					th =  Text$thawstringprefix@Red$thaws.PlayerName$Text$";"@thawstring@" ";
			}
			else
			{
				if(class'Misc_Player'.default.bEnableColoredNamesInTalk)
					th =  Text$thawstringprefix@Blue$thaws.GetColoredName()$Text$";"@thawstring@" ";
				else
					th =  Text$thawstringprefix@Blue$thaws.PlayerName$Text$";"@thawstring@" ";
			}
		}
    }

    if(git != None && git.Git > 0)
    {
        if(git.Team.TeamIndex == 0)
        {
            if(class'Misc_Player'.default.bEnableColoredNamesInTalk)
                gt =  Text$"Biggest Git:"@Red$git.GetColoredName()$Text$";"@git.Git@" ";
            else
                gt =  Text$"Biggest Git:"@Red$git.PlayerName$Text$";"@git.Git@" ";
        }
        else
        {
            if(class'Misc_Player'.default.bEnableColoredNamesInTalk)
                gt =  Text$"Biggest Git:"@Blue$git.GetColoredName()$Text$";"@git.Git@" ";
            else
                gt =  Text$"Biggest Git:"@Blue$git.PlayerName$Text$";"@git.Git@" ";
        }
    }

    for(C = Level.ControllerList; C != None; C = C.NextController)
        if(Freon_Player(c) != None)
            Freon_Player(c).ClientListBestFreon(acc, dam, hs, th, gt);
}

static function string ParseChatPercVar(Mutator BaseMutator, controller Who, string Cmd)
{
	local Pawn p;

	if (Who.Pawn==None && Freon_Player(Who).FrozenPawn==None){
//round not started or dead
		if (Who.PlayerReplicationInfo.bOutOfLives){
			if (cmd~="%H")
				return "Dead";			

			if (cmd~="%A")	// Adrenaline
				return "I had"@int(Who.Adrenaline)@"(Adrenaline";

			if (cmd~="%S")
				return "Decomposing";

			if (cmd~="%W")
				return "the inside of a coffin";
		}
		else{
			if (cmd~="%H")
				return "not spawned";			

			if (cmd~="%A")	// Adrenaline
				return int(Who.Adrenaline)@"Adrenaline";

			if (cmd~="%S")
				return "no Shield yet";

			if (cmd~="%W")
				return "nothing";
		}
	}
	else {
//round started
		if (Who.Pawn==None)
			p = Freon_Player(Who).FrozenPawn;
		else
			p = Who.Pawn;
			
		if (cmd~="%H")
			if (Who.Pawn==None)
				return p.Health$"% Defrosted";
			else
				return p.Health@"Health";			

		if (cmd~="%A")	// Adrenaline
			return int(Who.Adrenaline)@"Adrenaline";

		if (cmd~="%S")
			if (Who.Pawn==None)
				return "";
			else
				return int(p.ShieldStrength)@"Shield";

		if (cmd~="%W")
		{
			if (Who.Pawn==None)
				return "frozen arse";
			else if (p.Weapon!=None)
				return p.Weapon.GetHumanReadableName();
			else if ( Vehicle(p) != None )
				return Vehicle(p).GetVehiclePositionString();
			else
				return Default.BareHanded;
		}
	}

	if (cmd=="%%")
		return "%";

	if (cmd~="%L")
		return "";

	return Super.ParseChatPercVar(BaseMutator, Who,Cmd);
}

function CheckForCampers()
{
    local Controller c;
    local Freon_Pawn p;
    local Freon_PRI pri;
    local Box HistoryBox;
    local float MaxDim;
    local int i;
	local int j;
	local Freon_Trigger MyTrigger;
	local bool bThawing;
	local Array<Freon_Pawn> Thawers;

	//note who is thawing
	ForEach AllActors(class'Freon_Trigger', MyTrigger){
		for (j = 0; j < MyTrigger.Toucher.length; ++j) {
			Thawers.Length = Thawers.Length + 1;
			Thawers[Thawers.Length - 1] = MyTrigger.Toucher[j];
		}
	}
	
    for(c = Level.ControllerList; c != None; c = c.NextController)
    {
        if(Freon_PRI(c.PlayerReplicationInfo) == None || c.Pawn == None || Freon_Pawn(c.Pawn) == None ||
            c.PlayerReplicationInfo.bOnlySpectator || c.PlayerReplicationInfo.bOutOfLives)
            continue;

		P = Freon_Pawn(c.Pawn);
        pri = Freon_PRI(c.PlayerReplicationInfo);		
		
		//ignore thawers. They are thawing, not camping!
		bThawing = false;
		for (j = 0; j < Thawers.length; ++j) {
			if (Thawers[j] == p){
				bThawing = true;
				break;
			}
		}
		
		if (bThawing){
			continue;
		}
		
        p.LocationHistory[p.NextLocHistSlot] = p.Location;
        p.NextLocHistSlot++;

        if(p.NextLocHistSlot == 10)
        {
            p.NextLocHistSlot = 0;
            p.bWarmedUp = true;
        }

        if(p.bWarmedUp)
        {
            HistoryBox.Min.X = p.LocationHistory[0].X;
            HistoryBox.Min.Y = p.LocationHistory[0].Y;
            HistoryBox.Min.Z = p.LocationHistory[0].Z;

            HistoryBox.Max.X = p.LocationHistory[0].X;
            HistoryBox.Max.Y = p.LocationHistory[0].Y;
            HistoryBox.Max.Z = p.LocationHistory[0].Z;

            for(i = 1; i < 10; i++)
            {
                HistoryBox.Min.X = FMin(HistoryBox.Min.X, p.LocationHistory[i].X);
				HistoryBox.Min.Y = FMin(HistoryBox.Min.Y, p.LocationHistory[i].Y);
				HistoryBox.Min.Z = FMin(HistoryBox.Min.Z, p.LocationHistory[i].Z);

				HistoryBox.Max.X = FMax(HistoryBox.Max.X, p.LocationHistory[i].X);
				HistoryBox.Max.Y = FMax(HistoryBox.Max.Y, p.LocationHistory[i].Y);
				HistoryBox.Max.Z = FMax(HistoryBox.Max.Z, p.LocationHistory[i].Z);
            }

            MaxDim = FMax(FMax(HistoryBox.Max.X - HistoryBox.Min.X, HistoryBox.Max.Y - HistoryBox.Min.Y), HistoryBox.Max.Z - HistoryBox.Min.Z);
        
            if(MaxDim < CampThreshold && p.ReWarnTime == 0)
            {
                PunishCamper(c, p, pri);
                if (p != None)		// May have been punished to death!
                    p.ReWarnTime = CampInterval;
            }
            else if(MaxDim > CampThreshold)
            {
                pri.bWarned = false;
                pri.ConsecutiveCampCount = 0;
            }
            else if(p.ReWarnTime > 0)
                p.ReWarnTime--;
        }
    }

//     NextRoundDelayFreon=1 // should be below if needed	
}

defaultproperties
{
     AutoThawTime=90.000000
     ThawSpeed=5.500000
     MinHealthOnThaw=80.000000
     ThawPointAward=0.900000
     bTeamHeal=True
     bSpawnProtectionOnThaw=True
     bCanStandOnIcicle=True
     bEnemyBioThaws=True
     EnemyBioThawPercent=50
     bChooseResThawingLast=True
     bChooseResDeadFirst=True
     iAdrenGitters=4
     AdrenGitLose=25
     bNoTriggerProtection=True
     bFullThaws=True
     bShowThawMoments=True
     bChargeLowGun=True
     MaxGitsAllowed=1
     KillGitterMsgColour=(B=232,G=2,R=226)
     KillGitterMsg="You will die on Gits from now on."
     SelfKillThawScale=0.600000
     SelfKillLavaThawtime=10.000000
     NoTriggerProtectionMsg=True
     TeleportSound=Sound'3SPNv3225PIG.Teleport'
     bAwardAmmoOnThaw=True
     bChallengeMode=True
     bRandomPickups=True
     bPureRFF=True
     AdrenalinePerDamage=0.500000
     bDisableInvis=True
     NextRoundDelay=5
     bModifyShieldGun=True
     BioAmmo=40
     ShockAmmo=35
     LinkAmmo=80
     MiniAmmo=80
     FlakAmmo=22
     RocketAmmo=20
     LightningAmmo=30
     sAdvertiseAs="Freon"
     UseZAxisRadar=True
     bUseOldMessages=True
     EndOfRoundDelay=6
     EndCeremonyEnabled=False
     AllowPersistentStatsWithBots=True
     AllowPersistentStatsIfMoreThan=5
     BotsPPR=4.000000
     AutoBalanceRandomization=10.000000
     AutoBalanceAvgPPRWeight=90.000000
     AutoBalanceOnJoins=False
     AutoBalanceOnJoinsOver=6.000000
     AllowForceAutoBalance=False
     ForceAutoBalanceCooldown=60
     FlagTextureName="3SPNv3225PIG.FlagGB"
     FlagTextureShowAcronym=False
     TeamAIType(0)=Class'3SPNv3225PIG.Freon_TeamAI'
     TeamAIType(1)=Class'3SPNv3225PIG.Freon_TeamAI'
     NetWait=30
     SpawnProtectionTime=0.000000
     DefaultPlayerClassName="3SPNv3225PIG.Freon_Pawn"
     ScoreBoardType="3SPNv3225PIG.Freon_Scoreboard"
     HUDType="3SPNv3225PIG.Freon_HUD"
     MapListType="3SPNv3225PIG.MapListFreon"
     PlayerControllerClassName="3SPNv3225PIG.Freon_Player"
     GameReplicationInfoClass=Class'3SPNv3225PIG.Freon_GRI'
     GameName="Freon"
     Description="Freeze the other team, score a point. Chill well and serve."
     Acronym="Freon"
}
