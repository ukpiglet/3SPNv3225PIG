class Message_Thaw_hotter_than_hell extends LocalMessage;

#exec AUDIO IMPORT FILE=Sounds\HotterThanHell.wav GROUP=Sounds

var Sound HotterThanHellSound;
var localized string YouAreHotterThanHell;
var localized string PlayerIsHotterThanHell;

static function string GetString(
	optional int SwitchNum,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject 
	)
{
    if(SwitchNum == 1)
	    return default.YouAreHotterThanHell;
    else
        return RelatedPRI_1.PlayerName@default.PlayerIsHotterThanHell;
	
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
		P.ClientPlaySound(default.HotterThanHellSound);
}

defaultproperties
{
     HotterThanHellSound=Sound'3SPNv3225PIG.Sounds.HotterThanHell'
     YouAreHotterThanHell="YOU ARE HOTTER THAN HELL!"
     PlayerIsHotterThanHell="IS HOTTER THAN HELL!"
     bIsUnique=True
     bFadeMessage=True
     Lifetime=5
     DrawColor=(B=0,G=100)
     StackMode=SM_Down
     PosY=0.100000
}
