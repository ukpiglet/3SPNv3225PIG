class WeaponFire_BioAlt extends BioChargedFire;

event ModeHoldFire()
{
    if (Weapon.Role == ROLE_Authority)
        Instigator.DeactivateSpawnProtection();
	Super.ModeHoldFire();
}

event ModeDoFire()
{
local Misc_PRI PRI;

	PRI = Misc_PRI(xPawn(Weapon.Owner).PlayerReplicationInfo);
	
    if (PRI != none && !PRI.bBot)
		PRI.Bio.Fired += 1;
		
    Super.ModeDoFire();
}

function projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local Freon_BioGlob Glob;

    GotoState('');

    if (GoopLoad == 0) return None;

    Glob = Weapon.Spawn(class'Freon_BioGlob',,, Start, Dir);
    if ( Glob != None )
    {
		Glob.Damage *= DamageAtten;
		Glob.SetGoopLevel(GoopLoad);
		Glob.AdjustSpeed();
    }
    GoopLoad = 0;
    if ( Weapon.AmmoAmount(ThisModeNum) <= 0 )
        Weapon.OutOfAmmo();
    return Glob;
}


defaultproperties
{
}
