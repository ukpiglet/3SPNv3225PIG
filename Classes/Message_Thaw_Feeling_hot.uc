class Message_Thaw_Feeling_hot extends LocalMessage;

#exec AUDIO IMPORT FILE=Sounds\HotHotHot.wav GROUP=Sounds

var Sound HotHotHotSound;
var localized string YouAreHotHotHot;
var localized string PlayerIsHotHotHot;

static function string GetString(
	optional int SwitchNum,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject 
	)
{
    if(SwitchNum == 1)
	    return default.YouAreHotHotHot;
    else
        return RelatedPRI_1.PlayerName@default.PlayerIsHotHotHot;
	
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
		P.ClientPlaySound(default.HotHotHotSound);
}

defaultproperties
{
     HotHotHotSound=Sound'3SPNv3225PIG.Sounds.HotHotHot'
     YouAreHotHotHot="YOU ARE HOT HOT HOT!"
     PlayerIsHotHotHot="IS HOT HOT HOT!"
     bIsUnique=True
     bFadeMessage=True
     Lifetime=5
     DrawColor=(B=0,G=100)
     StackMode=SM_Down
     PosY=0.100000
}
