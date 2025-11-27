class Message_TeamsCalled extends LocalMessage;

var string TeamsCalledString1;
var string TeamsCalledString2;
var string TeamsCalledString3;

static function string GetString(
	optional int SwitchNum,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject 
	)
{
	local int called, needed;

	called = SwitchNum / 1000;
	needed = SwitchNum - (called * 1000);

    return default.TeamsCalledString1@called@default.TeamsCalledString2@needed@default.TeamsCalledString3;
}

defaultproperties
{
     TeamsCalledString1="Forced auto balance call by"
     TeamsCalledString2="of"
     TeamsCalledString3="players."
     bIsSpecial=False
}
