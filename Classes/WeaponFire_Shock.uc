class WeaponFire_Shock extends ShockBeamFire;

event ModeDoFire()
{
local Misc_PRI PRI;

	if ( (Pawn(Owner) != None) && (Pawn(Owner).PlayerReplicationInfo != None) )
	{
		PRI = Misc_PRI (Pawn(Owner).PlayerReplicationInfo);
	}
	
    if (PRI != none && !PRI.bBot)
		PRI.Shock.Primary.Fired += load;
		
    Super.ModeDoFire();
}

defaultproperties
{
}
