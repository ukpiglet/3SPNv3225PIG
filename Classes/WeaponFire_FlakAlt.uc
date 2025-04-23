class WeaponFire_FlakAlt extends FlakAltFire;

event ModeDoFire()
{
local Misc_PRI PRI;

	PRI = Misc_PRI(xPawn(Weapon.Owner).PlayerReplicationInfo);
	
    if (PRI != none && !PRI.bBot)
		PRI.Flak.Secondary.Fired += load;
		
    Super.ModeDoFire();
}

defaultproperties
{
}
