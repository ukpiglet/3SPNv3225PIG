class WeaponFire_Link extends LinkFire;

event ModeDoFire()
{
local Misc_PRI PRI;

	PRI = Misc_PRI(xPawn(Weapon.Owner).PlayerReplicationInfo);
	
    if (PRI != none && !PRI.bBot)
		PRI.Link.Primary.Fired++;
		
    Super.ModeDoFire();
}

defaultproperties
{
}
