class NewNet_ShieldGun extends ShieldGun
	HideDropDown
	CacheExempt;

function AdjustPlayerDamage( out int Damage, Pawn InstigatedBy, Vector HitLocation,
						         out Vector Momentum, class<DamageType> DamageType)
{
    local int Drain;
	local vector Reflect;
    local vector HitNormal;
    local float DamageMax;

	DamageMax = 100.0;
	if ( DamageType == class'Fell' )
		DamageMax = 20.0;
    else if( !DamageType.default.bArmorStops || !DamageType.default.bLocationalHit || (DamageType == class'DamType_ShieldImpact' && InstigatedBy == Instigator) )
        return;

    if ( CheckReflect(HitLocation, HitNormal, 0) )
    {
        Drain = Min( AmmoAmount(1)*2, Damage );
		Drain = Min(Drain,DamageMax);
	    Reflect = MirrorVectorByNormal( Normal(Location - HitLocation), Vector(Instigator.Rotation) );
        Damage -= Drain;
        Momentum *= 1.25;
        if ( (Instigator != None) && (Instigator.PlayerReplicationInfo != None) && (Instigator.PlayerReplicationInfo.HasFlag != None) )
        {
			Drain = Min(AmmoAmount(1), Drain);
			ConsumeAmmo(1,Drain);
			DoReflectEffect(Drain);
		}
        else
        {
			ConsumeAmmo(1,Drain/2);
			DoReflectEffect(Drain/2);
		}
    }
}

defaultproperties
{
     FireModeClass(0)=Class'3SPNv3225PIG.WeaponFire_Shield'
}
