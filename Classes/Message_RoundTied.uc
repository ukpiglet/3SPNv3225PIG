class Message_RoundTied extends LocalMessage;

//#exec AUDIO IMPORT FILE=Sounds\RoundTied.wav     	    GROUP=Sounds

var Sound RoundTiedSound;

var localized string RoundTiedString;

static function string GetString(
	optional int SwitchNum,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject 
	)
{
    return default.RoundTiedString;
}

static simulated function ClientReceive(
	PlayerController P,
	optional int SwitchNum,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
//    UnrealPlayer(P).ClientDelayedAnnouncement(default.RoundTiedSound, 5);

	Super.ClientReceive(P, SwitchNum, RelatedPRI_1, RelatedPRI_2, OptionalObject);
}

defaultproperties
{
     RoundTiedString="ROUND ENDED IN A TIE!"
     bIsUnique=True
     bFadeMessage=True
     DrawColor=(B=0)
     StackMode=SM_Down
     PosY=0.100000
}
