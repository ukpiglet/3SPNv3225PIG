class WeaponFire_ShockAlt extends ShockProjFire;

event ModeDoFire()
{
local Misc_PRI PRI;

	if ( (Pawn(Owner) != None) && (Pawn(Owner).PlayerReplicationInfo != None) )
	{
		PRI = Misc_PRI (Pawn(Owner).PlayerReplicationInfo);
	}
	
    if (PRI != none && !PRI.bBot)
		PRI.Shock.Secondary.Fired += load;
    
	Super.ModeDoFire();
}

defaultproperties
{
     ProjectileClass=Class'3SPNv3225PIG.WeaponFire_ShockCombo'
}
