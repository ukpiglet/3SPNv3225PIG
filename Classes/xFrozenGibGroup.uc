// *F* Developed 2013-2014 rejecht <rejecht at outlook dot com>

class xFrozenGibGroup extends xBotGibGroup
	;

// #

static event class<Gib> GetGibClass (EGibType GibType)
{
    return Default.Gibs[0];
}

static event Class<xEmitter> GetBloodEmitClass ()
{
	if (Class'Engine.GameInfo'.Static.UseLowGore ())
	{
		if (Class'Engine.GameInfo'.static.NoBlood ())
		{
			return Default.NoBloodEmitClass;
        }


 		return Default.LowGoreBloodEmitClass;
 	}


    return Default.BloodEmitClass;
}

// #

defaultproperties
{
     Gibs(0)=Class'3SPNv3225PIG.GibCube'
     Gibs(1)=Class'3SPNv3225PIG.GibCube'
     Gibs(2)=Class'3SPNv3225PIG.GibCube'
     Gibs(3)=Class'3SPNv3225PIG.GibCube'
     Gibs(4)=Class'3SPNv3225PIG.GibCube'
     Gibs(5)=Class'3SPNv3225PIG.GibCube'
	 Gibs(6)=Class'3SPNv3225PIG.GibCube'
     BloodHitClass=Class'3SPNv3225PIG.GibIceEffect'
     LowGoreBloodHitClass=Class'3SPNv3225PIG.GibIceEffect'
     BloodGibClass=Class'3SPNv3225PIG.GibIceEffect'
     LowGoreBloodGibClass=Class'3SPNv3225PIG.GibIceEffect'
     LowGoreBloodEmitClass=Class'3SPNv3225PIG.GibIceEffect'
     BloodEmitClass=Class'3SPNv3225PIG.GibIceEffect'
     NoBloodEmitClass=Class'3SPNv3225PIG.GibIceEffect'
     NoBloodHitClass=Class'3SPNv3225PIG.GibIceEffect'
     GibSounds(0)=Sound'WeaponSounds.BaseGunTech.BGrenfloor1'
     GibSounds(1)=Sound'WeaponSounds.BaseGunTech.BGrenfloor1'
     GibSounds(2)=Sound'WeaponSounds.BaseGunTech.BGrenfloor1'
}
