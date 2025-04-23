class Message_Pulveriser extends LocalMessage;

#exec AUDIO IMPORT FILE=Sounds\Pulveriser.wav GROUP=Sounds

var Sound PulveriserSound;
var localized string YouArePulveriser;
var localized string PlayerIsPulveriser;

static function string GetString(
	optional int SwitchNum,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject 
	)
{
    if(SwitchNum == 1)
	    return default.YouArePulveriser;
    else
        return RelatedPRI_1.PlayerName@default.PlayerIsPulveriser;
}

static simulated function ClientReceive(
	PlayerController P,
	optional int SwitchNum,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	Super.ClientReceive(P, SwitchNum, RelatedPRI_1, RelatedPRI_2, OptionalObject);
    
	if(SwitchNum==1)
		P.ClientPlaySound(default.PulveriserSound);
}

defaultproperties
{
     PulveriserSound=Sound'3SPNv3225PIG.Sounds.Pulveriser'
     YouArePulveriser="YOU ARE A PULVERISER!"
     PlayerIsPulveriser="IS A PULVERISER!"
     bIsUnique=True
     bFadeMessage=True
     Lifetime=5
     DrawColor=(B=0,G=0)
     StackMode=SM_Down
     PosY=0.100000
}
