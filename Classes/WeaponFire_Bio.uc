class WeaponFire_Bio extends BioFire;

event ModeDoFire()
{
local Misc_PRI PRI;

	PRI = Misc_PRI(xPawn(Weapon.Owner).PlayerReplicationInfo);
	
    if (PRI != none && !PRI.bBot)
		PRI.Bio.Fired += load;
		
    Super.ModeDoFire();
}

defaultproperties
{
}
