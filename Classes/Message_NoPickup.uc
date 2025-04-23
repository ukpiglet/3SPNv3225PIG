class Message_NoPickup extends LocalMessage;

#exec OBJ LOAD FILE=2K4MenuSounds.uax

var() localized string NoHealth;
var() localized string NoShield;
var() localized string NoAdren;
var() localized string RoundEnd;

var Sound CantSound;

static function string GetString(optional int Switch,optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
    if(Switch == 0)
    {
       return default.NoHealth;
    }
    else if(Switch == 1)
    {
       return default.NoShield;
    }
    else if(Switch==2)
    {
       return default.NoAdren;
    }   
	else if(Switch==3)
    {
       return default.RoundEnd;
    }
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
    
	P.ClientPlaySound(default.CantSound);
}

defaultproperties
{
     NoHealth="You can't pick up more health"
     NoShield="You can't pick up more shield"
     NoAdren="You can't pick up more adrenaline"
     RoundEnd="It's round end!"
     CantSound=Sound'2K4MenuSounds.Generic.msfxEdit'
     bIsUnique=True
     bIsPartiallyUnique=True
     bFadeMessage=True
     Lifetime=2
     PosY=0.900000
}
