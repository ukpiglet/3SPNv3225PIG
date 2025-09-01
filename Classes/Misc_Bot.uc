class Misc_Bot extends xBot;

var bool ActiveThisRound;

function Reset()
{
    local NavigationPoint P;
    local float Adren;

    Adren = Adrenaline;

    P = StartSpot;
    Super.Reset();
    StartSpot = P;

    if(Pawn == None || !Pawn.InCurrentCombo())
        Adrenaline = Adren;
    else
        Adrenaline = 0.1;
}

function SetPawnClass(string inClass, string inCharacter)
{
	local class<Misc_Pawn> pClass;

	if(inClass != "")
	{
		pClass = class<Misc_Pawn>(DynamicLoadObject(inClass, class'Class'));
		if(pClass != None)
			PawnClass = pClass;
	}

	PawnSetupRecord = class'xUtil'.static.FindPlayerRecord(inCharacter);
	PlayerReplicationInfo.SetCharacterName(inCharacter);
}

function SetFall()
{
	//getting accessed nones with bots
	if (Pawn != None) 
		super.Setfall();
}

function PawnDied(Pawn P)
{
    local float Adren;

    Adren = Adrenaline;
    Super.PawnDied(P);
    Adrenaline = Adren;

    if(PlayerReplicationInfo != None && TAM_TeamInfo(PlayerReplicationInfo.Team) != None)
        TAM_TeamInfo(PlayerReplicationInfo.Team).PlayerDied(self);
}

event NotifyJumpApex()
{

	if (Pawn != None)
		super.NotifyJumpApex();
	else
	{
		bDodgingForward = false;
		bNotifyApex = false;
		bPendingDoubleJump = false;
		return;
	}
		
}

function TryCombo(string ComboName)
{
    local class<Combo> ComboClass;

    if(TAM_GRI(Level.GRI) == None || TAM_GRI(Level.GRI).bDisableTeamCombos)
    {
        //note this doesn't take into account disabled combos 
        Super.TryCombo(ComboName);
        return;
    }

    if(!Pawn.InCurrentCombo() && !NeedsAdrenaline())
    {

/* can't use the ComboNames array because it contains all the combos - including disabled ones
        if(ComboName ~= "Random")
            ComboName = ComboNames[Rand(ArrayCount(ComboNames))];
        else if (ComboName ~= "DMRandom")
            ComboName = ComboNames[1 + Rand(ArrayCount(ComboNames) - 1)];
*/

        // set combo to default then call NewRecommendCombo
        // which will give us enabled combos (or none)
        ComboName = "xGame.Combo";
        ComboName = Level.Game.NewRecommendCombo(ComboName, self);

        if(ComboName ~= "xGame.Combo")
            return;

        ComboClass = class<Combo>(DynamicLoadObject(ComboName, class'Class'));
        if(ComboClass != None)
        {

            if(ComboClass.default.Duration<=1)
            {
                Super.TryCombo(ComboName);
                return;
            }


            if(TAM_TeamInfo(PlayerReplicationInfo.Team) != None)
                TAM_TeamInfo(PlayerReplicationInfo.Team).PlayerUsedCombo(self, ComboClass);
        }
    }
}

function AwardAdrenaline(float amount)
{
    if(bAdrenalineEnabled)
    {
        if((TAM_GRI(Level.GRI) == None || TAM_GRI(Level.GRI).bDisableTeamCombos) && (Pawn != None && Pawn.InCurrentCombo()))
            return;
        //Adrenaline = FClamp(Adrenaline + amount, 0.1, AdrenalineMax);
		Adrenaline = FClamp(Adrenaline + amount, 0.1, Team_GameBase(Level.Game).MaxAdrenaline);
    }
}

defaultproperties
{
     PlayerReplicationInfoClass=Class'3SPNv3225PIG.Misc_PRI'
     Adrenaline=0.100000
}
