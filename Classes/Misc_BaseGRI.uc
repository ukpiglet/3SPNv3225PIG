class Misc_BaseGRI extends GameReplicationInfo DependsOn(Team_GameBase);

var string Version;
var string Acronym;

var int RoundTime;
var int RoundMinute;
var int CurrentRound;
var bool bEndOfRound;
var bool bGamePaused;

var int SecsPerRound;
var int OTDamage;
var int OTInterval;

var int StartingHealth;
var int StartingArmor;
//var int MaxAdrenaline;
var float MaxHealth;

var float CampThreshold;
var bool bKickExcessiveCampers;

var bool bForceRUP;
var int ForceRUPMinPlayers;

var bool bDisableSpeed;
var bool bDisableBooster;
var bool bDisableInvis;
var bool bDisableBerserk;

var int  TimeOuts;

var bool EnableNewNet;

var string ShieldTextureName;
var string FlagTextureName;
var bool ShowServerName;
var bool bUseChatIcon;
var bool FlagTextureEnabled;
var bool FlagTextureShowAcronym;

var string SoundAloneName;
var string SoundSpawnProtectionName;

var string ScoreboardCommunityName;
var string ScoreboardRedTeamName;
var string ScoreboardBlueTeamName;

var bool UseZAxisRadar;
var bool bHeightRadar;
var bool bAllowTelefrags;


var bool NewNetExp;
var float NewNetExp_ThresholdProj;
var float NewNetExp_ThresholdHS;
var float NewNetExp_ProjMult;
var float NewNetExp_HSMult;

var bool UTComp_MoveRep;
var float MinNetUpdateRate;
var float MaxNetUpdateRate;

var int StartUsingCurrPPRAfterRounds;
var float AutoBalanceAvgPPRWeight;
var float BotsPPR;

var bool bLockRolloff;
var float RolloffMinValue;
var bool bKeepMomentumOnLanding;
var int MaxSavedMoves;

var Team_GameBase.EServerLinkStatus ServerLinkStatus; //enum type dependson Team_GameBase

replication
{

    reliable if(bNetInitial && Role == ROLE_Authority)
        RoundTime, SecsPerRound, bDisableSpeed, bDisableBooster, bDisableInvis,
        bDisableBerserk, StartingHealth, StartingArmor, MaxHealth, OTDamage,
        OTInterval, CampThreshold, bKickExcessiveCampers, bForceRUP, ForceRUPMinPlayers,
        TimeOuts, Acronym, EnableNewNet, ShieldTextureName, ShowServerName,
        FlagTextureEnabled, FlagTextureName, FlagTextureShowAcronym, SoundAloneName,
        SoundSpawnProtectionName, 
        ScoreboardCommunityName, ScoreboardRedTeamName, ScoreboardBlueTeamName, UseZAxisRadar, bHeightRadar,
        ServerLinkStatus, bUseChatIcon, NewNetExp, NewNetExp_ThresholdProj, NewNetExp_ThresholdHS, NewNetExp_ProjMult, NewNetExp_HSMult, UTComp_MoveRep, MinNetUpdateRate, MaxNetUpdateRate, 
		AutoBalanceAvgPPRWeight, BotsPPR, StartUsingCurrPPRAfterRounds, bLockRolloff, RollOffMinValue, bKeepMomentumOnLanding, MaxSavedMoves
		; //, MaxAdrenaline;
		
		

    reliable if(!bNetInitial && bNetDirty && Role == ROLE_Authority)
        RoundMinute;

    reliable if(bNetDirty && Role == ROLE_Authority)
        CurrentRound, bEndOfRound, bGamePaused;
}

simulated function Timer()
{
    Super.Timer();

    if(Level.NetMode == NM_Client)
    {
        if(RoundMinute > 0)
        {
            RoundTime = RoundMinute;
            RoundMinute = 0;
        }

        if(RoundTime > 0 && !bStopCountDown)
            RoundTime--;
    }
}

defaultproperties
{
    Version="3225PIG"
    EnableNewNet=True
}

