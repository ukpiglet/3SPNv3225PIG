class WeaponFire_Mini extends MinigunFire;

event ModeDoFire()
{
local Misc_PRI PRI;

	if ( (Pawn(Owner) != None) && (Pawn(Owner).PlayerReplicationInfo != None) )
	{
		PRI = Misc_PRI (Pawn(Owner).PlayerReplicationInfo);
	}	
    if (PRI != none && !PRI.bBot)
		PRI.Mini.Primary.Fired += load;
		
    Super.ModeDoFire();
}

defaultproperties
{
}
