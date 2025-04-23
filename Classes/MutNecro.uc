//-----------------------------------------------------------------------------------
// MutNecro [ComboWhore Ed] | ComboWhore Tweak based on code by Shaun Goeppinger 2013
// www.combowhore.com
//-----------------------------------------------------------------------------------
#exec AUDIO IMPORT FILE="Sounds\Resurrection.wav"
#exec AUDIO IMPORT FILE="Sounds\Thaw.wav"
#exec AUDIO IMPORT FILE="Sounds\ShortCircuit.wav"

class MutNecro extends Mutator;

var() config bool bShowSpawnMessage;
var() config string SpawnMessage;
var() config bool bBotsCanNecro;
var() config color SpawnMessageColour;
var config int NecroChance;
var config bool bFullStartingAdren;

var() xPlayer NotifyPlayer[32];
var() localized string PropsDisplayText[5];
var() localized string PropsDescText[5];
var() class<NecroCombo> NecroComboClass;

function string RecommendCombo(string ComboName)
{
    if(bBotsCanNecro)
        if(FRand() < (NecroChance/100)) 
            ComboName = "3SPNv3225PIG.NecroCombo";

    if(NextMutator != None)
    {
        return NextMutator.RecommendCombo(ComboName);
    }

    return ComboName;
}

function ModifyPlayer(Pawn Other)
{
  	Super.ModifyPlayer(Other);

  	if (bShowSpawnMessage && PlayerController(Other.Controller)!=None)
  	{
		PlayerController(Other.Controller).ClientMessage(Level.Game.MakeColorCode(SpawnMessageColour)$SpawnMessage);
	}
}

function Timer()
{
	local byte i;

    local Controller C;
	if (bFullStartingAdren)
		for(C=Level.ControllerList; C!=None; C=C.NextController)
		   C.Adrenaline = 100;
  
	for ( i=0; i<32; i++ )
	{
		if ( NotifyPlayer[i] != None )
		{
			NotifyPlayer[i].ClientReceiveCombo("3SPNv3225PIG.NecroCombo");
			NotifyPlayer[i] = None;
		}
	}
}

function bool IsRelevant(Actor Other, out byte bSuperRelevant)
{
	local byte i;

	if ( xPlayer(Other) != None )
	{
		for ( i=0; i<16; i++ )
		{
			if ( xPlayer(Other).ComboNameList[i] ~= "3SPNv3225PIG.NecroCombo" )
			{
				break;
			}
			else if ( xPlayer(Other).ComboNameList[i] == "" )
			{
				xPlayer(Other).ComboNameList[i] = "3SPNv3225PIG.NecroCombo";
				break;
			}
		}

		for ( i=0; i<32; i++ )
		{
			if ( NotifyPlayer[i] == None )
			{
				NotifyPlayer[i] = xPlayer(Other);
				SetTimer(0.5, false);
				break;
			}
		}
	}

	if ( NextMutator != None )
	{
		return NextMutator.IsRelevant(Other, bSuperRelevant);
	}
	else
	{
		return true;
	}
}

function GetServerDetails( out GameInfo.ServerResponseLine ServerState )
{
	local int i;

    i = ServerState.ServerInfo.Length;
    ServerState.ServerInfo.Length = i+3;
	ServerState.ServerInfo[i].Key = "Mutator";
   	ServerState.ServerInfo[i].Value = GetHumanReadableName();
	ServerState.ServerInfo[i+1].Key = "Necro Score Award";
	ServerState.ServerInfo[i+1].Value = string(class'NecroCombo'.default.NecroScoreAward);
	ServerState.ServerInfo[i+2].Key = "Bot Necro Chance";
	ServerState.ServerInfo[i+2].Value = string(NecroChance)$"%";
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	local byte Weight; // weight must be a byte (max value 127?)
	
	Weight=0;
	
	Super.FillPlayInfo(PlayInfo);
	
	PlayInfo.AddSetting("Necro Combo v3", "bBotsCanNecro", default.PropsDisplayText[0], 0, Weight++, "Check");
	PlayInfo.AddSetting("Necro Combo v3", "NecroChance", default.PropsDisplayText[1], 0, Weight++, "Text", "3;0:100");
	PlayInfo.AddSetting("Necro Combo v3", "bShowSpawnMessage", default.PropsDisplayText[2], 0, Weight++, "Check");
	PlayInfo.AddSetting("Necro Combo v3", "SpawnMessage", default.PropsDisplayText[3], 0, Weight++, "Text", "170",, True);
	PlayInfo.AddSetting("Necro Combo v3", "bFullStartingAdren", default.PropsDisplayText[4], 0, Weight++, "Check");

	if (default.NecroComboClass != None)
	{
		default.NecroComboClass.static.FillPlayInfo(PlayInfo);
		PlayInfo.PopClass();
	}
}

static function string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "bBotsCanNecro":	        return default.PropsDescText[0];
		case "NecroChance":	        	return default.PropsDescText[1];
		case "bShowSpawnMessage":		return default.PropsDescText[2];
		case "SpawnMessage":			return default.PropsDescText[3];
		case "bFullStartingAdren":		return default.PropsDescText[4];
	}
}

function Mutate(string MutateString, PlayerController Sender)
{
	local array<string> Parameters;
	local int i;
	local string Command;

	if (NextMutator != None)
		NextMutator.Mutate(MutateString, Sender);

	if (!Sender.PlayerReplicationInfo.bAdmin)
		return;

	if (Left(MutateString, 6) ~= "NECRO ") {
		MutateString = Mid(MutateString, 6);
		i = Instr(MutateString, " ");
		if (i != -1) {
			Command = Left(MutateString, i);
		
			Parameters = splitup(Mid(MutateString, i + 1));
		
		} else
			Command = MutateString;
		Command = Caps(Command);
	} else if (MutateString ~= "NECRO")
		Command = "HELP";

	if (Command == "")
		return;

	switch (Command) {

		case "HELP":
			Cmd_Help(Sender, Parameters);       break;
		case "PIG":
			Cmd_pig(Sender, Parameters);        break;
		case "DEBUG":
			Cmd_debug(Sender, Parameters);        break;
		default:
			FeedbackMessage(Sender, "Invalid command, you may want to use \"mutate necro help\"");
	}
}

function FeedbackMessage(PlayerController Target, string Msg)
{
	Target.TeamMessage(None, Chr(27) $ Chr(1) $ Chr(255) $ Chr(1) $ Msg, 'Event');
}

function Cmd_Help(PlayerController Issuer, array<string> Parameters)
{
	FeedbackMessage(Issuer, "=============================================================");
	FeedbackMessage(Issuer, " NecroCombo");
	FeedbackMessage(Issuer, " bPigletsNecro "$class'NecroCombo'.default.bPigletsNecro);
	FeedbackMessage(Issuer, " bDebug        "$class'NecroCombo'.default.bDebug);
	FeedbackMessage(Issuer, "=============================================================");
	FeedbackMessage(Issuer, "Usage:");
	FeedbackMessage(Issuer, " mutate necro <command> <parameters>");
	FeedbackMessage(Issuer, "Commands:");
	FeedbackMessage(Issuer, " pig       - flip between Piglet's rec code and previod style");
	FeedbackMessage(Issuer, " debug     - debug logging toggle");
	FeedbackMessage(Issuer, "=============================================================");
}

function Cmd_pig(PlayerController Issuer, array<string> Parameters)
{
	class'NecroCombo'.default.bPigletsNecro = !class'NecroCombo'.default.bPigletsNecro;
	FeedbackMessage(Issuer, "=============================================================");
	FeedbackMessage(Issuer, " NecroCombo");
	FeedbackMessage(Issuer, "bPigletsNecro="$class'NecroCombo'.default.bPigletsNecro);
	FeedbackMessage(Issuer, "=============================================================");
	class'NecroCombo'.static.StaticSaveConfig();
}

function Cmd_debug(PlayerController Issuer, array<string> Parameters)
{
	class'NecroCombo'.default.bDebug = !class'NecroCombo'.default.bDebug;
	FeedbackMessage(Issuer, "============================================================");
	FeedbackMessage(Issuer, " NecroCombo");
	FeedbackMessage(Issuer, "bDebug="$class'NecroCombo'.default.bDebug);
	FeedbackMessage(Issuer, "============================================================");
	class'NecroCombo'.static.StaticSaveConfig();
}

function array <string> splitup(string params){
	local int i;
	local array<string> parmarray;
	local bool bOpened;
	local string parm;
	
	for (i = 0; i < len(params); i++){
		if (mid(params, i, 1) == "\""){
			if (bOpened)
				bOpened = False;
			else
				bOpened = True;
		}
		else
			if (mid(params,i,1) == " " && !bOpened){
				parmarray.Length = parmarray.Length + 1;
				parmarray[parmarray.Length - 1] = parm;
				parm = "";
			}
			else{
				parm $= mid(params,i,1);
			}
	}

	if (parm != ""){
		parmarray.Length = parmarray.Length + 1;
		parmarray[parmarray.Length - 1] = parm;
	}

	return parmarray;
}

defaultproperties
{
     SpawnMessage="To revive a teammate use movement keys back back forward forward, or use key bound to 'UseNecro' with 100 adren."
     bBotsCanNecro=True
     SpawnMessageColour=(B=255,G=48,R=155,A=255)
     NecroChance=40
     PropsDisplayText(0)="Bots Can Perform Necro Combo"
     PropsDisplayText(1)="Percentage chance bots necro"
     PropsDisplayText(2)="Show How To Resurrect Message"
     PropsDisplayText(3)="Message to show players about res"
     PropsDisplayText(4)="Adrenaline starts at 100 at game start"
     PropsDescText(0)="Should bots use the necro combo? (true by default)"
     PropsDescText(1)="Percentage chance of bot thawing"
     PropsDescText(2)="Show the (To resurrect a teammate press B,B,F,F with 100 adren) spawn message? (True by default)."
     PropsDescText(3)="Message to show players about res"
     PropsDescText(4)="Adrenaline starts at 100 at game start (False by default)"
     NecroComboClass=Class'3SPNv3225PIG.NecroCombo'
     bAddToServerPackages=True
     GroupName="Combo Necromancy"
     FriendlyName="Combo Necromancy"
     Description="Resurrect a team mate from the dead! Support for Invasion and Team Games based on number of lives. (To resurrect a teammate press B,B,F,F with 100 adren)"
}
