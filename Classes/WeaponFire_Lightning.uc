class WeaponFire_Lightning extends SniperFire;

event ModeDoFire()
{
local Misc_PRI PRI;

	PRI = Misc_PRI(xPawn(Weapon.Owner).PlayerReplicationInfo);
	
    if (PRI != none && !PRI.bBot)
		PRI.Sniper.Fired += load;
		
    Super.ModeDoFire();
}

defaultproperties
{
     DamageTypeHeadShot=Class'3SPNv3225PIG.DamType_Headshot'
}
