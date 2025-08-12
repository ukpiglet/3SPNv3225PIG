class WeaponFire_LinkAlt extends LinkAltFire;

event ModeDoFire()
{
local Misc_PRI PRI;

	if ( (Pawn(Owner) != None) && (Pawn(Owner).PlayerReplicationInfo != None) )
	{
		PRI = Misc_PRI (Pawn(Owner).PlayerReplicationInfo);
	}	
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
