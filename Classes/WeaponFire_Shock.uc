class WeaponFire_Shock extends ShockBeamFire;

event ModeDoFire()
{
local Misc_PRI PRI;

	PRI = Misc_PRI(xPawn(Weapon.Owner).PlayerReplicationInfo);
	
    if (PRI != none && !PRI.bBot)
		PRI.Shock.Primary.Fired += load;
		
    Super.ModeDoFire();
}

defaultproperties
{
}
