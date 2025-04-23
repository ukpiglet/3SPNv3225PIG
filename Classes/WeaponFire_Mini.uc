class WeaponFire_Mini extends MinigunFire;

event ModeDoFire()
{
local Misc_PRI PRI;

	PRI = Misc_PRI(xPawn(Weapon.Owner).PlayerReplicationInfo);
	
    if (PRI != none && !PRI.bBot)
		PRI.Mini.Primary.Fired += load;
		
    Super.ModeDoFire();
}

defaultproperties
{
}
