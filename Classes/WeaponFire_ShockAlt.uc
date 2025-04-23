class WeaponFire_ShockAlt extends ShockProjFire;

event ModeDoFire()
{
local Misc_PRI PRI;

	PRI = Misc_PRI(xPawn(Weapon.Owner).PlayerReplicationInfo);
	
    if (PRI != none && !PRI.bBot)
		PRI.Shock.Secondary.Fired += load;
    
	Super.ModeDoFire();
}

defaultproperties
{
     ProjectileClass=Class'3SPNv3225PIG.WeaponFire_ShockCombo'
}
