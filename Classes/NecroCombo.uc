//----------------------------------------------------------------------------------------------
// NecroCombo [ComboWhore Ed] | ComboWhore Tweak based on original code by Shaun Goeppinger 2013
// www.combowhore.com
//----------------------------------------------------------------------------------------------
class NecroCombo extends Combo;

var() config float NecroScoreAward;
var() config float NecroAdrenAward;
var() config float ShieldOnResurrect;
var() config float SacrificePercentage;
var() config bool bResLoseProtection;

var() config int HealthOnResurrect;

var() config bool bSacrificeHealth;
var() config bool bShareHealth;
var() config bool bNecroEffectNecrobod;
var() config bool bNecroEffectResurrectee;
var() config bool bNecroTeleport;
var() config bool bPigletsNecro;
var() config bool bDebug;  //debug and all debug log lines could be removed as soon as happy it's working as intended.

var() localized string PropsDisplayText[13];
var() localized string PropsDescText[13];

var Controller Resurrectee;

function Controller PickWhoToResPiglet()
{
	local array<Controller> DeadBestControllerList, MyControllerList, ThawingBestControllerList, DeadBotControllerList, FrozenBotControllerList, ThawingBotControllerList;
	local Controller C, Necromancer;
	local int i;
	local float BestRezTime, ThawingBestRezTime, DeadBestRezTime;
	local string sDebug;

	i = 0;
	BestRezTime = 100000;
	ThawingBestRezTime = 100000;
	DeadBestRezTime = 100000;
	
	Necromancer = Pawn(Owner).Controller;
	
	if (bDebug) log("Starting check bChooseResDeadFirst="$Freon(Level.Game).bChooseResDeadFirst,'piglet');

	if(Necromancer == None || Necromancer.PlayerReplicationInfo == None)
	{
		return None;
	}

	for(C = Level.ControllerList; C != None; C = C.NextController)
	{
        if(C == Necromancer)
            continue;

        if(C.PlayerReplicationInfo==None)
            continue;

        if(C.PlayerReplicationInfo.bOnlySpectator || !C.PlayerReplicationInfo.bOutOfLives)
            continue;
			
		if(Misc_Player(C)!=None && Level.TimeSeconds<Misc_Player(C).NextRezTime)
			continue;

        if((!C.IsA('PlayerController') && !C.PlayerReplicationInfo.bBot) || C.Pawn!=None)
            continue;

        if(C.PlayerReplicationInfo.Team != Necromancer.PlayerReplicationInfo.Team)
            continue;


		if (bDebug){
			if (C.IsA('Freon_Player')){
				sDebug = "Freon_Player, rejoined="$Misc_Player(C).bRejoined@"FrozenPawn=";
				if (Freon_Player(C).FrozenPawn!=None)
					sDebug = sDebug$"exists";
				else
					sDebug = sDebug$"none";
			}
			
			if (C.IsA('Freon_Bot')){
				sDebug = "Freon_Bot, FrozenPawn=";
				if (Freon_Bot(C).FrozenPawn!=None)
					sDebug = sDebug$"exists";
				else
					sDebug = sDebug$"none";
			}
			
			log(sDebug@"bOutOfLives="$c.PlayerReplicationInfo.bOutOfLives@C.PlayerReplicationInfo.PlayerName@C.Class, 'piglet');
		}

		//Frozen player or frozen bot
        if((C.IsA('Freon_Player') && Freon_Player(C).FrozenPawn!=None) ||
           (C.IsA('Freon_Bot') && Freon_Bot(C).FrozenPawn!=None)) //frozen player or frozen bot in Freon
        {
			//being thawed player
			if	(Freon(Level.Game) != None && Freon(Level.Game).bChooseResThawingLast &&  
				 C.IsA('Freon_Player') && Freon_Player(C).FrozenPawn!=None && Freon_Player(C).FrozenPawn.MyTrigger != None && Freon_Player(C).FrozenPawn.MyTrigger.Toucher.length != 0){
				if (bDebug) log("Found thawing: lastrestime: "$Misc_Player(C).LastRezTime@ThawingBestRezTime@C.PlayerReplicationInfo.PlayerName, 'piglet'); 
				if(Misc_Player(C).LastRezTime<ThawingBestRezTime){ //Thawing player
					if (bDebug) log("Zapping thawing: "$C.PlayerReplicationInfo.PlayerName, 'piglet'); 
					ThawingBestControllerList.Length = 0;
					ThawingBestRezTime = Misc_Player(C).LastRezTime;
				}
				if(Misc_Player(C).LastRezTime==ThawingBestRezTime){
					i = ThawingBestControllerList.Length;
					ThawingBestControllerList.Length = i+1;
					ThawingBestControllerList[i] = C;
					if (bDebug) log("Saving thawing: Pos"@i+1@C.PlayerReplicationInfo.PlayerName, 'piglet'); 
				}
			}
			else{
				//being thawed bot
				if (C.IsA('Freon_Bot') && Freon_Bot(C).FrozenPawn!=None && Freon_Bot(C).FrozenPawn.MyTrigger != None && Freon_Bot(C).FrozenPawn.MyTrigger.Toucher.length != 0){ //bots being thawed
					if (bDebug) log("Found thawing bot"@C.PlayerReplicationInfo.PlayerName, 'piglet');  
					i = ThawingBotControllerList.Length;
					ThawingBotControllerList.Length = i+1;
					ThawingBotControllerList[i] = C;
				}
				else{
					if(Misc_Player(C)!=None){ //frozen players not being thawed
						if (bDebug) log("Found frozen: lastrestime: "$Misc_Player(C).LastRezTime@BestRezTime@C.PlayerReplicationInfo.PlayerName, 'piglet'); 
						if(Misc_Player(C).LastRezTime<BestRezTime){
							if (bDebug) log("Zapping frozen: "$C.PlayerReplicationInfo.PlayerName, 'piglet'); 
							MyControllerList.Length = 0;
							BestRezTime = Misc_Player(C).LastRezTime;
						}
						if(Misc_Player(C).LastRezTime==BestRezTime){
							i = MyControllerList.Length;
							MyControllerList.Length = i+1;
							MyControllerList[i] = C;
							if (bDebug) log("Saving frozen: Pos"@i+1@C.PlayerReplicationInfo.PlayerName, 'piglet'); 
						}
					}
					else{
						//frozen bots. Don't really care if being thawed or not
						if (bDebug) log("Found frozen bot"@C.PlayerReplicationInfo.PlayerName, 'piglet'); 
						i = FrozenBotControllerList.Length;
						FrozenBotControllerList.Length = i+1;
						FrozenBotControllerList[i] = C;
					}
				}
			}
		}
        else //Dead Bot, Dead Player or TAM
        {
			//I see dead freon people
			if (C.PlayerReplicationInfo.bOutOfLives && Freon(Level.Game) != None && Freon(Level.Game).bChooseResDeadFirst && Misc_Player(C) != None && !Misc_Player(C).bRejoined){
				if (bDebug) log("Found dead: lastrestime: "$Misc_Player(C).LastRezTime@DeadBestRezTime@C.PlayerReplicationInfo.PlayerName, 'piglet'); 
				if(Misc_Player(C).LastRezTime<DeadBestRezTime){  //zap the array if earlier res time found
					if (bDebug) log("Zapping dead: "$C.PlayerReplicationInfo.PlayerName, 'piglet'); 
					DeadBestControllerList.Length = 0;
					DeadBestRezTime = Misc_Player(C).LastRezTime;
				}
				if(Misc_Player(C).LastRezTime == DeadBestRezTime){ //add to the array if same res time found, otherwise ignore the player
					i = DeadBestControllerList.Length;
					DeadBestControllerList.Length = i+1;
					DeadBestControllerList[i] = C;
					if (bDebug) log("Saving dead: Pos"@i+1@C.PlayerReplicationInfo.PlayerName, 'piglet'); 
				}
			}
			else{
				if(C.PlayerReplicationInfo.bBot || PlayerController(C)!=None){ //possibly not required....there's not a lot left other than this!
					// TAM Player, or one that has rejoined in freon...gets added to the same list as 
					if(Misc_Player(C)!=None) //TAM player
					{
						if (bDebug) log("Found TAM or dead rejoined player. Gets same treatment as any frozen not-being-thawed player"@C.PlayerReplicationInfo.PlayerName, 'piglet');
						if(Misc_Player(C).LastRezTime<BestRezTime){
							MyControllerList.Length = 0;
							BestRezTime = Misc_Player(C).LastRezTime;
						}
									
						if(Misc_Player(C).LastRezTime==BestRezTime){
							i = MyControllerList.Length;
							MyControllerList.Length = i+1;
							MyControllerList[i] = C;
						}
					}
					else{ //dead bots
						if (bDebug) log("Found dead bot"@C.PlayerReplicationInfo.PlayerName, 'piglet'); 
						i = DeadBotControllerList.Length;
						DeadBotControllerList.Length = i+1;
						DeadBotControllerList[i] = C;
					}
				}
			} 
		}
	}

	if (DeadBestControllerList.Length != 0)                                                     //dead players
		C = DeadBestControllerList[Rand(DeadBestControllerList.Length)];	
	else
		if (MyControllerList.Length != 0)														//frozen players
				C = MyControllerList[Rand(MyControllerList.Length)];	
		else
			if(ThawingBestControllerList.Length != 0)  											//players being thawed
				C = ThawingBestControllerList[Rand(ThawingBestControllerList.Length)];	
			else
				if(DeadBotControllerList.Length != 0)  											//dead bot
					C = DeadBotControllerList[Rand(DeadBotControllerList.Length)];	
				else
					if(FrozenBotControllerList.Length != 0)  									//frozen bot
						C = FrozenBotControllerList[Rand(FrozenBotControllerList.Length)];						
					else
						if(ThawingBotControllerList.Length != 0) 								//bot being thawed
							C = ThawingBotControllerList[Rand(ThawingBotControllerList.Length)];	
						else
							C = None;															//nobody to res
	
	if (bDebug){
		if (C != None)
			log("Resurrecting"@C.PlayerReplicationInfo.PlayerName, 'piglet'); 
		else
			log("Resurrecting nobody", 'piglet'); 
	
		log("---------",'Piglet');
	}

	return C;
}

function Controller PickWhoToRes()  //version before piglet's changes in priority
{
    //local array<float> MyDistanceList;
    //local Pawn P;
    //local float distance;
	local array<Controller> MyControllerList, ThawingBestControllerList;
	local Controller C, Necromancer;
	local int i;
	local float BestRezTime;
	local float ThawingBestRezTime;

	i = 0;
	BestRezTime = 100000;
	ThawingBestRezTime = 100000;
	Necromancer = Pawn(Owner).Controller;

	if(Necromancer == None || Necromancer.PlayerReplicationInfo == None)
	{
		return None;
	}

	for(C = Level.ControllerList; C != None; C = C.NextController)
	{
        if(C == Necromancer)
            continue;

        if(C.PlayerReplicationInfo==None)
            continue;

        if(C.PlayerReplicationInfo.bOnlySpectator || !C.PlayerReplicationInfo.bOutOfLives)
            continue;
			
		if(Misc_Player(C)!=None && Level.TimeSeconds<Misc_Player(C).NextRezTime)
			continue;

        if((!C.IsA('PlayerController') && !C.PlayerReplicationInfo.bBot) || C.Pawn!=None)
            continue;

        if(C.PlayerReplicationInfo.Team != Necromancer.PlayerReplicationInfo.Team)
            continue;

        if((C.IsA('Freon_Player') && Freon_Player(C).FrozenPawn!=None) ||
           (C.IsA('Freon_Bot') && Freon_Bot(C).FrozenPawn!=None))
        {
			
			//keep track of the earliest "being thawed player" if it might be used
			if	(Freon(Level.Game) != None && Freon(Level.Game).bChooseResThawingLast &&  
					(C.IsA('Freon_Player') && Freon_Player(C).FrozenPawn!=None && Freon_Player(C).FrozenPawn.MyTrigger.Toucher.length != 0) ||
					(C.IsA('Freon_Bot') && Freon_Bot(C).FrozenPawn!=None && Freon_Bot(C).FrozenPawn.MyTrigger.Toucher.length != 0)
				)
			{
					
				if(Misc_Player(C)!=None){			
					if(Misc_Player(C).LastRezTime<ThawingBestRezTime)
						ThawingBestControllerList.Length = 0;

					ThawingBestRezTime = Misc_Player(C).LastRezTime;
				}
				
				i = ThawingBestControllerList.Length;
				ThawingBestControllerList.Length = i+1;
				ThawingBestControllerList[i] = C;
			}
			else{
				// always prefer a player who hasn't been resurrected in the longest time
				if(Misc_Player(C)!=None){			
					if(Misc_Player(C).LastRezTime<BestRezTime)
						MyControllerList.Length = 0;

					BestRezTime = Misc_Player(C).LastRezTime;
				}
				
				i = MyControllerList.Length;
				MyControllerList.Length = i+1;
				MyControllerList[i] = C;
			}
        }
        else
        {	//Dead Bot, Dead Player or TAM
            if(C.PlayerReplicationInfo.bBot || PlayerController(C)!=None)
            {
				// always prefer a player who hasn't been resurrected in the longest time
				if(Misc_Player(C)!=None)
				{
					if(Misc_Player(C).LastRezTime<BestRezTime)
						MyControllerList.Length = 0;
						
					BestRezTime = Misc_Player(C).LastRezTime;
				}
				
                i = MyControllerList.Length;
				MyControllerList.Length = i+1;
                MyControllerList[i] = C;
            }
        }   
	}

	//don't res player being thawed unless there is no other player...
	if(MyControllerList.Length == 0){
		if (ThawingBestControllerList.Length == 0)
			return None;
		else
			return ThawingBestControllerList[Rand(ThawingBestControllerList.Length)];	
	}
	
    return MyControllerList[Rand(MyControllerList.Length)];
}

function StopEffect(xPawn P)
{
}

function StartEffect(xPawn P)
{
	if(P.Controller == None || P.PlayerReplicationInfo == None)
    {
        Destroy(); 
        return;
    }

	if (bPigletsNecro)
		Resurrectee = PickWhoToResPiglet();
	else
		Resurrectee = PickWhoToRes();
	
    DoResurrection();
}

function Abort(bool bEndOfRoundError)
{
    local Controller Necromancer;
    local Pawn P;

    P = Pawn(Owner);
    if(P != None)
        Necromancer = Pawn(Owner).Controller;

    if(Necromancer != None)
        TeamPlayerReplicationInfo(Necromancer.PlayerReplicationInfo).Combos[4]--;

    if(PlayerController(NecroMancer) != None)
        PlayerController(NecroMancer).ClientPlaySound(Sound'ShortCircuit');

	if (bEndOfRoundError){
		if(P != None)
				Pawn(Owner).ReceiveLocalizedMessage(class'NecroMessages', 4, None, None);
	}
	else
		if(Level.Game.IsA('Freon'))
		{
			if(P != None)
				Pawn(Owner).ReceiveLocalizedMessage(class'NecroMessages', 3, None, None);
		}
		else
		{
			if(P != None)
				Pawn(Owner).ReceiveLocalizedMessage(class'NecroMessages', 1, None, None);
		}

    Destroy();
}

function DoResurrection()
{
    local int ResurrecteeHealth;
    local float ResurrecteeShield;
	local float SacrificedHealth;
	local float SacrificedShield;
	local Inventory LeechInv;
    local Controller Necromancer;
    local Pawn P;
	local NavigationPoint startSpot;
	local int TeamNum;
	local Freon_Pawn xPawn;
	local Team_GameBase T;

    if(Resurrectee == None)
    {
        Abort(false);
        return;
    }

    P = Pawn(Owner);
    if(P == None)
    {
        Abort(false);
        return;
    }

    Necromancer = P.Controller;
    if(Necromancer == None)
    {
        Abort(false);
        return;
    }

	//Abort late res at end of round, unless it's the winning round
	T=Team_GameBase(Level.Game);

	if(T != None && (T.Teams[Necromancer.GetTeamNum()].Score + 1) != T.GoalScore && (T.bRespawning || T.bEndOfRound || T.EndOfRoundTime > 0 || T.NextRoundTime > 0))
    {
        Abort(true);
        return;
    }
	
	
	if(Freon_Player(Resurrectee)!=None)
		xPawn = Freon_Player(Resurrectee).FrozenPawn;
	else if(Freon_Bot(Resurrectee)!=None)
		xPawn = Freon_Bot(Resurrectee).FrozenPawn;

	if(xPawn != None)
	{
		if(Freon(Level.Game)==None || bNecroTeleport)
		{
			// First teleport frozen pawn to a new spawn and then thaw
			if(Resurrectee.PlayerReplicationInfo==None || Resurrectee.PlayerReplicationInfo.Team==None)
				TeamNum = 255;
			else
				TeamNum = Resurrectee.PlayerReplicationInfo.Team.TeamIndex;
				
			startSpot = Level.Game.FindPlayerStart(Resurrectee, TeamNum);
			if(startSpot != None)
			{
				xPawn.SetLocation(startSpot.Location);
				xPawn.SetRotation(startSpot.Rotation);
				xPawn.Velocity = vect(0,0,0);
			}
		}
		
		xPawn.Thaw();

        PlaySound(Sound'Thaw', SLOT_None, 300.0);
        BroadcastLocalizedMessage(class'NecroMessages', 2, Necromancer.PlayerReplicationInfo, Resurrectee.PlayerReplicationInfo);		
    }
    else
    {
        Resurrectee.PlayerReplicationInfo.bOutOfLives = false;
        Resurrectee.PlayerReplicationInfo.NumLives = 1;

        Level.Game.RestartPlayer(Resurrectee);
        if(Resurrectee.Pawn == None)
        {
            Abort(false);
            return;
        }

		if(PlayerController(Resurrectee) != None)
			PlayerController(Resurrectee).ClientReset();

		if(Team_GameBase(Level.Game)!=None && Team_GameBase(Level.Game).bSpawnProtectionOnRez==False && Misc_Pawn(Resurrectee.Pawn)!=None)
			Misc_Pawn(Resurrectee.Pawn).DeactivateSpawnProtection();
			
        PlaySound(Sound'Resurrection', SLOT_None, 300.0);
        BroadcastLocalizedMessage(class'NecroMessages', 0, Necromancer.PlayerReplicationInfo, Resurrectee.PlayerReplicationInfo);
    }
	
    ResurrecteeHealth = HealthOnResurrect;
    ResurrecteeShield = ShieldOnResurrect;

    if(bSacrificeHealth)
    {
        SacrificePercentage = FClamp(SacrificePercentage,0.00,1.00);

        SacrificedHealth = float(P.Health) / 100.00;
        SacrificedHealth *= SacrificePercentage * 100;
        SacrificedHealth = Clamp(SacrificedHealth,SacrificedHealth,P.Health);
        SacrificedShield = (P.ShieldStrength / 100) * (SacrificePercentage * 100);

        if(bShareHealth)
        {
            ResurrecteeHealth = SacrificedHealth;
            ResurrecteeShield = SacrificedShield;
        }

        if(P.FindInventoryType(class'NecroLeech') == None)
        {
            LeechInv = Spawn(class'NecroLeech', P,,,);
            if(LeechInv != None)
            {
                LeechInv.GiveTo(P);
                NecroLeech(LeechInv).LeechAmount = SacrificedHealth;
                NecroLeech(LeechInv).ShieldLeechAmount = SacrificedShield;
            }
        }
    }

	// for some reason pawn is sometimes none! Abort until root cause is known
	if(Resurrectee.Pawn == None)
	{
		Abort(false);
		return;
	}

    Resurrectee.Pawn.Health = ResurrecteeHealth;
    Resurrectee.Pawn.ShieldStrength = ResurrecteeShield;
	
	if(Misc_Player(Resurrectee)!=None)
		Misc_Player(Resurrectee).LastRezTime = Level.TimeSeconds;

    Necromancer.Adrenaline -= AdrenalineCost;

    	if(Team_GameBase(Level.Game)!=None && Team_GameBase(Level.Game).DarkHorse==Necromancer)
		Team_GameBase(Level.Game).DarkHorse=None;

    if (bNecroEffectNecrobod){
		Spawn(class'NecroEffectA', Necromancer.Pawn,, Necromancer.Pawn.Location, Necromancer.Pawn.Rotation);
		Spawn(class'NecroEffectB', Necromancer.Pawn,, Necromancer.Pawn.Location, Necromancer.Pawn.Rotation);
	}

	if (bNecroEffectResurrectee){
		Spawn(class'NecroEffectA', Resurrectee.Pawn,, Resurrectee.Pawn.Location, Resurrectee.Pawn.Rotation);
		Spawn(class'NecroEffectB', Resurrectee.Pawn,, Resurrectee.Pawn.Location, Resurrectee.Pawn.Rotation);
	}
	
	//********* recognise that the necro is a thaw (res=thaw)
	If (Freon(Level.Game) != None){
		// maybe add in here to use RewardFullThawers / standard thawing reward rather than the next two lines;
		Freon(Level.Game).RewardThaw(Freon_Pawn(Necromancer.Pawn), NecroScoreAward, NecroAdrenAward, 3);
		Freon(Level.Game).SpecialEvent(Necromancer.Pawn.PlayerReplicationInfo, "Thaw"); //allow stats for thawing
	}
	
	//********* lose thaw protection
	If (bResLoseProtection && Misc_Pawn(Necromancer.Pawn).SpawnProtectionTimer != 0){
			Necromancer.Pawn.DeactivateSpawnProtection();
			if (PlayerController(Necromancer.Pawn.Controller) != None){
				PlayerController(Necromancer.Pawn.Controller).ReceiveLocalizedMessage(class'Message_SpawnProtection', 0);
			}
	}
	
	
	
    Destroy();
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	local byte Weight; // weight must be a byte (max value 127?)
	local int i;
	
	Weight=10;

	Super.FillPlayInfo(PlayInfo);

	PlayInfo.AddSetting("Necro Combo v3", "NecroScoreAward", default.PropsDisplayText[i++], 0, Weight++, "Text");

	PlayInfo.AddSetting("Necro Combo v3", "HealthOnResurrect", default.PropsDisplayText[i++], 0, Weight++, "Text");
	PlayInfo.AddSetting("Necro Combo v3", "ShieldOnResurrect", default.PropsDisplayText[i++], 0, Weight++, "Text");
	PlayInfo.AddSetting("Necro Combo v3", "bSacrificeHealth", default.PropsDisplayText[i++], 0, Weight++, "Check");
	PlayInfo.AddSetting("Necro Combo v3", "SacrificePercentage", default.PropsDisplayText[i++], 0, Weight++, "Text");
	PlayInfo.AddSetting("Necro Combo v3", "bShareHealth", default.PropsDisplayText[i++], 0, Weight++, "Check");
	PlayInfo.AddSetting("Necro Combo v3", "bNecroEffectNecrobod", default.PropsDisplayText[i++], 0, Weight++, "Check");
	PlayInfo.AddSetting("Necro Combo v3", "bNecroEffectResurrectee", default.PropsDisplayText[i++], 0, Weight++, "Check");
	PlayInfo.AddSetting("Necro Combo v3", "bNecroTeleport", default.PropsDisplayText[i++], 0, Weight++, "Check");
	PlayInfo.AddSetting("Necro Combo v3", "NecroAdrenAward", default.PropsDisplayText[i++], 0, Weight++, "Text");
	PlayInfo.AddSetting("Necro Combo v3", "bResLoseProtection", default.PropsDisplayText[i++], 0, Weight++, "Check");
	PlayInfo.AddSetting("Necro Combo v3", "bPigletsNecro", default.PropsDisplayText[i++], 0, Weight++, "Check");
	PlayInfo.AddSetting("Necro Combo v3", "bDebug", default.PropsDisplayText[i++], 0, Weight++, "Check");
}

static function string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "NecroScoreAward":	        	return default.PropsDescText[0];
		case "HealthOnResurrect":			return default.PropsDescText[1];
		case "ShieldOnResurrect":			return default.PropsDescText[2];
		case "bSacrificeHealth":	        return default.PropsDescText[3];
		case "SacrificePercentage":	        return default.PropsDescText[4];
		case "bShareHealth":				return default.PropsDescText[5];
		case "bNecroEffectNecrobod":		return default.PropsDescText[6];
		case "bNecroEffectResurrectee":		return default.PropsDescText[7];
		case "bNecroTeleport":				return default.PropsDescText[8];
		case "NecroAdrenAward":				return default.PropsDescText[9];
		case "bResLoseProtection":			return default.PropsDescText[10];
		case "bPigletsNecro":			    return default.PropsDescText[11];
		case "bDebug":			            return default.PropsDescText[12];
	}

	return Super.GetDescriptionText(PropName);
}

function Tick(float DeltaTime);

defaultproperties
{
     NecroScoreAward=5.000000
     ShieldOnResurrect=100.000000
     bResLoseProtection=True
     HealthOnResurrect=100
     PropsDisplayText(0)="Necro Score Award"
     PropsDisplayText(1)="Health When Resurrected"
     PropsDisplayText(2)="Shield When Resurrected"
     PropsDisplayText(3)="bSacrificeHealth"
     PropsDisplayText(4)="SacrificePercentage"
     PropsDisplayText(5)="bShareHealth"
     PropsDisplayText(6)="bNecroEffectNecrobod"
     PropsDisplayText(7)="bNecroEffectResurrectee"
     PropsDisplayText(8)="bNecroTeleport"
     PropsDisplayText(9)="Necro Adren Award"
     PropsDisplayText(10)="Res Loses spawn protection"
     PropsDisplayText(11)="Use Piglet's necro code"
     PropsDisplayText(12)="Debug logs"
     PropsDescText(0)="How many points should the player receive for performing the necro combo (Freon only)"
     PropsDescText(1)="How much health the resurrectee should spawn with."
     PropsDescText(2)="How much shield the resurrectee should spawn with."
     PropsDescText(3)="Should the Necromancer Sacrifice their Health and Shield? (A percentage of health is taken away from the necromancer and given to the player ressed, as their starting health)."
     PropsDescText(4)="The percentage of health to be sacrificed from the necromancer and given to the player being ressed as starting health."
     PropsDescText(5)="If true, the health lost by the necromancer will be given to the ressed player instead of the health specified in HealthOnResurrect and ShieldOnResurrect (bSacrificeHalth needs to be true for this setting to work)."
     PropsDescText(6)="If true, then necro effect shown on resurrector."
     PropsDescText(7)="If true, then necro effect shown on resurrectee."
     PropsDescText(8)="If true, then will teleport before resurrecting."
     PropsDescText(9)="How much adren should the player receive for performing the necro combo (Freon only)"
     PropsDescText(10)="If you resurrect, you lose spawn protection..."
     PropsDescText(11)="Use piglet's necro code....new April 2023"
     PropsDescText(12)="Debug Logs"
     ExecMessage="Necromancy!"
     Duration=1.000000
     ActivateSound=None
     ActivationEffectClass=None
     keys(0)=1
     keys(1)=1
     keys(2)=2
     keys(3)=2
	 bPigletsNecro=True
	 bDebug=False

}
