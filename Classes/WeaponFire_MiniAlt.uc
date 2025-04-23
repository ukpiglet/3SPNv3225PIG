class WeaponFire_MiniAlt extends MinigunAltFire;

event ModeDoFire()
{
local Misc_PRI PRI;

	PRI = Misc_PRI(xPawn(Weapon.Owner).PlayerReplicationInfo);
	
    if (PRI != none && !PRI.bBot)
		PRI.Mini.Secondary.Fired += load;
		
    Super.ModeDoFire();
}

defaultproperties
{
}
