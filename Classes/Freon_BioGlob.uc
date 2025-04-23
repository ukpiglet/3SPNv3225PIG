class Freon_BioGlob extends BioGlob
	HideDropDown
	CacheExempt;

var bool bHitEnemyFrozen;

simulated function Destroyed()
{
    if ( !bNoFX && EffectIsRelevant(Location,false) )
    {
		if (bHitEnemyFrozen && Freon_GRI(Level.GRI).bEnemyBioThaws){
			Spawn(class'BioEffect');
			Spawn(class'BioSparks');
		}
		else{
			Spawn(class'xEffects.GoopSmoke');
			Spawn(class'xEffects.GoopSparks');
		}
    }
	if ( Fear != None )
		Fear.Destroy();
    if (Trail != None)
        Trail.Destroy();
    //Projectile(Super).Destroyed(); not sure how to do this. Maybe I don't need to as here's nothing in projectile or actor.... 
}

auto state Flying
{
    simulated function ProcessTouch(Actor Other, Vector HitLocation)
    {
		if (Other.IsA('Freon_Pawn') && Freon_Pawn(Other).bFrozen && Freon_Pawn(Other).GetTeamNum() != Instigator.GetTeamNum())
			bHitEnemyFrozen = true;
			
		Super.ProcessTouch( Other,  HitLocation);
    }
}

state OnGround
{
    simulated function ProcessTouch(Actor Other, Vector HitLocation)
    {
        if (Other.IsA('Freon_Pawn') && Freon_Pawn(Other).bFrozen && Freon_Pawn(Other).GetTeamNum() != Instigator.GetTeamNum())
			bHitEnemyFrozen = true;

		Super.ProcessTouch(Other, HitLocation);
    }
}

simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
	local Freon_Pawn Victim;
	
	foreach VisibleCollidingActors( class 'Freon_Pawn', Victim, DamageRadius, HitLocation )
	{
		if (Victim.bFrozen && Victim.GetTeamNum() != Instigator.GetTeamNum()){
			bHitEnemyFrozen = true;
			Spawn(class'BioEffect', Victim, , Victim.Location, Victim.Rotation);
			Spawn(class'BioSparks', Victim, , Victim.Location, Victim.Rotation);
		}
	}
		
	Super.HurtRadius(DamageAmount,  DamageRadius,  DamageType,  Momentum,  HitLocation );
}


defaultproperties
{
}
