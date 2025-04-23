class WeaponFire_Rocket extends RocketFire;

event ModeDoFire()
{
local Misc_PRI PRI;

	PRI = Misc_PRI(xPawn(Weapon.Owner).PlayerReplicationInfo);
	
    if (PRI != none && !PRI.bBot)
		PRI.Rockets.Fired += load;
    
	Super.ModeDoFire();
}

defaultproperties
{
}
