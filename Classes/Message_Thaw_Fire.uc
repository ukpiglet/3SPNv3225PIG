class Message_Thaw_Fire extends LocalMessage;

#exec AUDIO IMPORT FILE=Sounds\Fire.wav GROUP=Sounds

var Sound Fire;
var localized string YouAreFire;
var localized string PlayerIsFire;

static function string GetString(
	optional int SwitchNum,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject 
	)
{
    if(SwitchNum == 1)
	    return default.YouAreFire;
    else
        return RelatedPRI_1.PlayerName@default.PlayerIsFire;
	
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
		P.ClientPlaySound(default.Fire);
}

defaultproperties
{
     Fire=Sound'3SPNv3225PIG.Sounds.Fire'
     YouAreFire="YOU ARE FIRE!"
     PlayerIsFire="IS ON FIRE!"
     bIsUnique=True
     bFadeMessage=True
     Lifetime=5
     DrawColor=(B=0,G=100)
     StackMode=SM_Down
     PosY=0.100000
}
