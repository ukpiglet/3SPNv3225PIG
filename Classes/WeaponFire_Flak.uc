class WeaponFire_Flak extends FlakFire;

event ModeDoFire()
{
local Misc_PRI PRI;

	if ( (Pawn(Owner) != None) && (Pawn(Owner).PlayerReplicationInfo != None) )
	{
		PRI = Misc_PRI (Pawn(Owner).PlayerReplicationInfo);
	}	
    if (PRI != none && !PRI.bBot)
		PRI.Flak.Primary.Fired += 9;
		
    Super.ModeDoFire();
}

defaultproperties
{
}
