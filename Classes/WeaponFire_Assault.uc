class WeaponFire_Assault extends AssaultFire;

event ModeDoFire()
{
local Misc_PRI PRI;

	if ( (Pawn(Owner) != None) && (Pawn(Owner).PlayerReplicationInfo != None) )
	{
		PRI = Misc_PRI (Pawn(Owner).PlayerReplicationInfo);
	}	
    if (PRI != none && !PRI.bBot)
		PRI.Assault.Primary.Fired += load;
		
    Super.ModeDoFire();
}

defaultproperties
{
}
