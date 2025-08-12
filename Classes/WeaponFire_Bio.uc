class WeaponFire_Bio extends BioFire;

event ModeDoFire()
{
local Misc_PRI PRI;

	if ( (Pawn(Owner) != None) && (Pawn(Owner).PlayerReplicationInfo != None) )
	{
		PRI = Misc_PRI (Pawn(Owner).PlayerReplicationInfo);
	}	
    if (PRI != none && !PRI.bBot)
		PRI.Bio.Fired += load;
		
    Super.ModeDoFire();
}

defaultproperties
{
}
