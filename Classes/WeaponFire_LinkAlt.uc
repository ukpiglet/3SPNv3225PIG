class WeaponFire_LinkAlt extends LinkAltFire;

event ModeDoFire()
{
local Misc_PRI PRI;

	PRI = Misc_PRI(xPawn(Weapon.Owner).PlayerReplicationInfo);
	
    if (PRI != none && !PRI.bBot)
		PRI.Link.Secondary.Fired++;
		
    Super.ModeDoFire();
}

/*
function Projectile SpawnProjectile(Vector Start, Rotator Dir)
{
local Misc_PRI PRI;

	PRI = Misc_PRI(xPawn(Weapon.Owner).PlayerReplicationInfo);
	
    if (PRI != none && !PRI.bBot))
		PRI.Link.Secondary.Fired++;
		
    return Super.SpawnProjectile(Start, Dir);
}
*/

defaultproperties
{
}
