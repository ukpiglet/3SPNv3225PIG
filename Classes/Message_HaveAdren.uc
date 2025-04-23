class Message_HaveAdren extends LocalMessage;

var() localized string Adren;

var Sound CantSound;

static function string GetString(optional int Switch,optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
       return default.Adren;
}

static simulated function ClientReceive(
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{

	Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);

	Misc_Player(P).PlayCustomRewardAnnouncement(class'Misc_Player'.default.SoundAdrenaline[Switch], 1);
	//P.ClientPlaySound(class'Misc_Player'.default.SoundAdrenaline[Switch]);
	    
}

defaultproperties
{
     Adren="You have enough adrenaline to do a combo"
     bIsUnique=True
     bIsPartiallyUnique=True
     bFadeMessage=True
     Lifetime=2
     DrawColor=(B=0)
     StackMode=SM_Down
     PosY=0.100000
}
