class WeaponFire_Flak extends FlakFire;

event ModeDoFire()
{
local Misc_PRI PRI;

	PRI = Misc_PRI(xPawn(Weapon.Owner).PlayerReplicationInfo);
	
    if (PRI != none && !PRI.bBot)
		PRI.Flak.Primary.Fired += 9;
		
    Super.ModeDoFire();
}

defaultproperties
{
}
