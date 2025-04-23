class WeaponFire_Assault extends AssaultFire;

event ModeDoFire()
{
local Misc_PRI PRI;

	PRI = Misc_PRI(xPawn(Weapon.Owner).PlayerReplicationInfo);
	
    if (PRI != none && !PRI.bBot)
		PRI.Assault.Primary.Fired += load;
		
    Super.ModeDoFire();
}

defaultproperties
{
}
