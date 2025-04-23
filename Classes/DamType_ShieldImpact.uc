class DamType_ShieldImpact extends DamTypeShieldImpact;

var int AwardLevel;

static function IncrementKills(Controller Killer)
{
    local Misc_PRI xPRI;

    xPRI = Misc_PRI(Killer.PlayerReplicationInfo);
    if(xPRI != None)
    {
      xPRI.SGCount++;
      if((xPRI.SGCount == default.AwardLevel) && (Misc_Player(Killer) != None))
        Misc_Player(Killer).BroadcastAnnouncement(class'Message_Pulveriser');
    }
}

defaultproperties
{
     AwardLevel=3
}
