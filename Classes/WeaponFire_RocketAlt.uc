class WeaponFire_RocketAlt extends RocketMultiFire;

event ModeHoldFire()
{
    if (Weapon.Role == ROLE_Authority)
        Instigator.DeactivateSpawnProtection();
	Super.ModeHoldFire();
}

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
