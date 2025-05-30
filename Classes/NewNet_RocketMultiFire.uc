/*
UTComp - UT2004 Mutator
Copyright (C) 2004-2005 Aaron Everitt & Jo�l Moffatt

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/
//-----------------------------------------------------------
//
//-----------------------------------------------------------
class NewNet_RocketMultiFire extends WeaponFire_RocketAlt;

var vector OldInstigatorLocation;
var Vector OldInstigatorEyePosition;
var vector OldXAxis,OldYAxis, OldZAxis;
var rotator OldAim;
var float OldLoad;
const MAX_PROJECTILE_FUDGE = 0.075;
const EXP_MAX_PROJECTILE_FUDGE = 0.020;

var class<Projectile> FakeProjectileClass;
var NewNet_FakeProjectileManager FPM;

var float NextAltTimerTime;
var bool bAltTimerActive;

var bool bUseEnhancedNetCode;

function PlayFiring()
{
    super.PlayFiring();
	if(!class'Misc_Player'.static.UseNewNet())
		return;
    CheckFireEffect();
}

simulated function CheckFireEffect()
{
   if(Level.NetMode == NM_Client && Instigator.IsLocallyControlled())
   {
		if (Misc_BaseGRI(Level.GRI).NewNetExp)
		{
			if(Class'NewNet_PRI'.default.PredictedPing > EXP_MAX_PROJECTILE_FUDGE)
				DoClientFireEffect();
			else
			{
				OldInstigatorLocation = Instigator.Location;
				OldInstigatorEyePosition = Instigator.EyePosition();
				Weapon.GetViewAxes(OldXAxis,OldYAxis,OldZAxis);
				OldAim=AdjustAim(OldInstigatorLocation+OldInstigatorEyePosition, AimError);
				OldLoad=Load;
				SetAltTimer(Class'NewNet_PRI'.default.PredictedPing - EXP_MAX_PROJECTILE_FUDGE, false);
			}
		}
		else
		{
			if(Class'NewNet_PRI'.default.PredictedPing <= MAX_PROJECTILE_FUDGE)
				DoClientFireEffect();
			else
			{
				OldInstigatorLocation = Instigator.Location;
				OldInstigatorEyePosition = Instigator.EyePosition();
				Weapon.GetViewAxes(OldXAxis,OldYAxis,OldZAxis);
				OldAim=AdjustAim(OldInstigatorLocation+OldInstigatorEyePosition, AimError);
				OldLoad=Load;
				SetAltTimer(Class'NewNet_PRI'.default.PredictedPing - MAX_PROJECTILE_FUDGE, false);
			}
		}
	}
}

simulated function FindFPM()
{
    foreach Weapon.DynamicActors(Class'NewNet_FakeProjectileManager', FPM)
        break;
}

simulated function ModeTick(float DT)
{
    super.ModeTick(dt);
    if(LEvel.NetMode!=NM_Client)
        return;
    if(bAltTimerActive && Level.TimeSeconds > NextAltTimerTime)
    {
        AltTimer();
        bAltTimerActive=False;
    }
}

simulated function SetAltTimer(float f, bool b)
{
    NextAltTimerTime = Level.TimeSeconds + f;
    bAltTimerActive=true;
}

simulated function AltTimer()
{
    DoTimedClientFireEffect();
}

simulated function DoClientFireEffect()
{
    local Vector StartProj, StartTrace, X,Y,Z;
    local Rotator Aim;
    local Vector HitLocation, HitNormal,FireLocation;
    local Actor Other;
    local int p,q, SpawnCount, i;
	local RocketProj FiredRockets[4];
	local bool bCurl;

    if ( (SpreadStyle == SS_Line) || (Load < 2) )
	{
		SuperDoFireEffect();
		return;
	}

    Instigator.MakeNoise(1.0);
    Weapon.GetViewAxes(X,Y,Z);

    StartTrace = Instigator.Location + Instigator.EyePosition();
    StartProj = StartTrace + X*ProjSpawnOffset.X + Z*ProjSpawnOffset.Z;
    if ( !Weapon.WeaponCentered() )
	    StartProj = StartProj + Weapon.Hand * Y*ProjSpawnOffset.Y;

    // check if projectile would spawn through a wall and adjust start location accordingly
    Other = Weapon.Trace(HitLocation, HitNormal, StartProj, StartTrace, false);
    if (Other != None)
    {
        StartProj = HitLocation;
    }

    Aim = AdjustAim(StartProj, AimError);

    SpawnCount = Max(1, int(Load));
    for ( p=0; p<SpawnCount; p++ )
    {
 		Firelocation = StartProj - 2*((Sin(p*2*PI/MaxLoad)*8 - 7)*Y - (Cos(p*2*PI/MaxLoad)*8 - 7)*Z) - X * 8 * FRand();
        FiredRockets[p] = RocketProj(SpawnFakeProjectile(FireLocation, Aim, p));
    }

    if ( SpawnCount < 2 )
		return;

	FlockIndex++;
	if ( FlockIndex == 0 )
		FlockIndex = 1;

    // To get crazy flying, we tell each projectile in the flock about the others.
    for ( p = 0; p < SpawnCount; p++ )
    {
		if ( FiredRockets[p] != None )
		{
			FiredRockets[p].bCurl = bCurl;
			FiredRockets[p].FlockIndex = FlockIndex;
			i = 0;
			for ( q=0; q<SpawnCount; q++ )
				if ( (p != q) && (FiredRockets[q] != None) )
				{
					FiredRockets[p].Flock[i] = FiredRockets[q];
					i++;
				}
			bCurl = !bCurl;
			if ( Level.NetMode != NM_DedicatedServer )
				FiredRockets[p].SetTimer(0.1, true);
		}
	}
}

simulated function DoTimedClientFireEffect()
{
    local Vector StartProj, StartTrace, X,Y,Z;
    local Rotator Aim;
    local Vector HitLocation, HitNormal,FireLocation;
    local Actor Other;
    local int p,q, SpawnCount, i;
	local RocketProj FiredRockets[4];
	local bool bCurl;

    if ( (SpreadStyle == SS_Line) || (OldLoad < 2) )
	{
		SuperDoTimedFireEffect();
		return;
	}

    Instigator.MakeNoise(1.0);
 //   Weapon.GetViewAxes(X,Y,Z);
      X=OldXAxis;
      Y=OldYAxis;
      Z=OldZAxis;
  //  StartTrace = Instigator.Location + Instigator.EyePosition();
    StartTrace = OldInstigatorLocation + OldInstigatorEyePosition;
    StartProj = StartTrace + X*ProjSpawnOffset.X + Z*ProjSpawnOffset.Z;

    if ( !Weapon.WeaponCentered() )
	    StartProj = StartProj + Weapon.Hand * Y*ProjSpawnOffset.Y;

    // check if projectile would spawn through a wall and adjust start location accordingly
    Other = Weapon.Trace(HitLocation, HitNormal, StartProj, StartTrace, false);
    if (Other != None)
    {
        StartProj = HitLocation;
    }

    //Aim = AdjustAim(StartProj, AimError);
    Aim=OldAim;
    SpawnCount = Max(1, int(OldLoad));
    for ( p=0; p<SpawnCount; p++ )
    {
 		Firelocation = StartProj - 2*((Sin(p*2*PI/MaxLoad)*8 - 7)*Y - (Cos(p*2*PI/MaxLoad)*8 - 7)*Z) - X * 8 * FRand();
        FiredRockets[p] = RocketProj(SpawnFakeProjectile(FireLocation, Aim, p));
    }

    if ( SpawnCount < 2 )
		return;

	FlockIndex++;
	if ( FlockIndex == 0 )
		FlockIndex = 1;

    // To get crazy flying, we tell each projectile in the flock about the others.
    for ( p = 0; p < SpawnCount; p++ )
    {
		if ( FiredRockets[p] != None )
		{
			FiredRockets[p].bCurl = bCurl;
			FiredRockets[p].FlockIndex = FlockIndex;
			i = 0;
			for ( q=0; q<SpawnCount; q++ )
				if ( (p != q) && (FiredRockets[q] != None) )
				{
					FiredRockets[p].Flock[i] = FiredRockets[q];
					i++;
				}
			bCurl = !bCurl;
			if ( Level.NetMode != NM_DedicatedServer )
				FiredRockets[p].SetTimer(0.1, true);
		}
	}
}

simulated function SuperDoTimedFireEffect()
{
    local Vector StartProj, StartTrace, X,Y,Z;
    local Rotator R, Aim;
    local Vector HitLocation, HitNormal;
    local Actor Other;
    local int p;
    local int SpawnCount;
    local float theta;

    Instigator.MakeNoise(1.0);
 ///   Weapon.GetViewAxes(X,Y,Z);
    X=OldXAxis;
    Y=OldYAxis;
    Z=OldZAxis;
  //  StartTrace = Instigator.Location + Instigator.EyePosition();// + X*Instigator.CollisionRadius;
    StartTrace=OldInstigatorLocation + OldInstigatorEyePosition;
    StartProj = StartTrace + X*ProjSpawnOffset.X;
    if ( !Weapon.WeaponCentered() )
	    StartProj = StartProj + Weapon.Hand * Y*ProjSpawnOffset.Y + Z*ProjSpawnOffset.Z;

    // check if projectile would spawn through a wall and adjust start location accordingly
    Other = Weapon.Trace(HitLocation, HitNormal, StartProj, StartTrace, false);
    if (Other != None)
    {
        StartProj = HitLocation;
    }

   // Aim = AdjustAim(StartProj, AimError);
    Aim = OldAim;
    SpawnCount = Max(1, ProjPerFire * int(OldLoad));

    switch (SpreadStyle)
    {
    case SS_Random:
        X = Vector(Aim);
        for (p = 0; p < SpawnCount; p++)
        {
            R.Yaw = Spread * (FRand()-0.5);
            R.Pitch = Spread * (FRand()-0.5);
            R.Roll = Spread * (FRand()-0.5);
            SpawnFakeProjectile(StartProj, Rotator(X >> R), p);
        }
        break;
    case SS_Line:
        for (p = 0; p < SpawnCount; p++)
        {
            theta = Spread*PI/32768*(p - float(SpawnCount-1)/2.0);
            X.X = Cos(theta);
            X.Y = Sin(theta);
            X.Z = 0.0;
            SpawnFakeProjectile(StartProj, Rotator(X >> Aim), p);
        }
        break;
    default:
        SpawnFakeProjectile(StartProj, Aim, 0);
    }
}

simulated function projectile SpawnFakeProjectile(Vector Start, Rotator Dir, int index)
{
    local Projectile p;

    if(FPM==None)
	{
        FindFPM();
		if(FPM==None)
			return None;
	}
		
    if(FPM.AllowFakeProjectile(FakeProjectileClass, index))
        p = Weapon.Spawn(FakeProjectileClass,Weapon.Owner,, Start, Dir);

    if( p == none )
        return None;
    FPM.RegisterFakeProjectile(p, index);
    return p;
}



function Projectile AltSpawnProjectile(Vector Start, Rotator Dir, int index)
{
    local Projectile p;

    p = RocketLauncher(Weapon).SpawnProjectile(Start, Dir);
    if ( p != None ){
		p.Damage *= DamageAtten;
		
		if(p.IsA('NewNet_RocketProj'))
			NewNet_RocketProj(p).Index = index;
			
		if(p.IsA('NewNet_SeekingRocketProj'))
			NewNet_SeekingRocketProj(p).Index = index;
	}
    return p;
}

function DoFireEffect()
{
    local Vector StartProj, StartTrace, X,Y,Z;
    local Rotator Aim;
    local Vector HitLocation, HitNormal,FireLocation;
    local Actor Other;
    local int p,q, SpawnCount, i;
	local RocketProj FiredRockets[4];
	local bool bCurl;

	if(!bUseEnhancedNetCode)
	{
       super.DoFireEffect();
       return;
    }

    if ( (SpreadStyle == SS_Line) || (Load < 2) )
	{
		SuperServerDoFireEffect();
		return;
	}

    Instigator.MakeNoise(1.0);
    Weapon.GetViewAxes(X,Y,Z);

    StartTrace = Instigator.Location + Instigator.EyePosition();
    StartProj = StartTrace + X*ProjSpawnOffset.X + Z*ProjSpawnOffset.Z;
    if ( !Weapon.WeaponCentered() )
	    StartProj = StartProj + Weapon.Hand * Y*ProjSpawnOffset.Y;

    // check if projectile would spawn through a wall and adjust start location accordingly
    Other = Weapon.Trace(HitLocation, HitNormal, StartProj, StartTrace, false);
    if (Other != None)
    {
        StartProj = HitLocation;
    }

    Aim = AdjustAim(StartProj, AimError);

    SpawnCount = Max(1, int(Load));

    for ( p=0; p<SpawnCount; p++ )
    {
 		Firelocation = StartProj - 2*((Sin(p*2*PI/MaxLoad)*8 - 7)*Y - (Cos(p*2*PI/MaxLoad)*8 - 7)*Z) - X * 8 * FRand();
        FiredRockets[p] = RocketProj(AltSpawnProjectile(FireLocation, Aim, p));
    }

    if ( SpawnCount < 2 )
		return;

	FlockIndex++;
	if ( FlockIndex == 0 )
		FlockIndex = 1;

    // To get crazy flying, we tell each projectile in the flock about the others.
    for ( p = 0; p < SpawnCount; p++ )
    {
		if ( FiredRockets[p] != None )
		{
			FiredRockets[p].bCurl = bCurl;
			FiredRockets[p].FlockIndex = FlockIndex;
			i = 0;
			for ( q=0; q<SpawnCount; q++ )
				if ( (p != q) && (FiredRockets[q] != None) )
				{
					FiredRockets[p].Flock[i] = FiredRockets[q];
					i++;
				}
			bCurl = !bCurl;
			if ( Level.NetMode != NM_DedicatedServer )
				FiredRockets[p].SetTimer(0.1, true);
		}
	}
}

simulated function SuperDoFireEffect()
{
    local Vector StartProj, StartTrace, X,Y,Z;
    local Rotator R, Aim;
    local Vector HitLocation, HitNormal;
    local Actor Other;
    local int p;
    local int SpawnCount;
    local float theta;

    Instigator.MakeNoise(1.0);
    Weapon.GetViewAxes(X,Y,Z);

    StartTrace = Instigator.Location + Instigator.EyePosition();// + X*Instigator.CollisionRadius;
    StartProj = StartTrace + X*ProjSpawnOffset.X;
    if ( !Weapon.WeaponCentered() )
	    StartProj = StartProj + Weapon.Hand * Y*ProjSpawnOffset.Y + Z*ProjSpawnOffset.Z;

    // check if projectile would spawn through a wall and adjust start location accordingly
    Other = Weapon.Trace(HitLocation, HitNormal, StartProj, StartTrace, false);
    if (Other != None)
    {
        StartProj = HitLocation;
    }

    Aim = AdjustAim(StartProj, AimError);

    SpawnCount = Max(1, ProjPerFire * int(Load));

    switch (SpreadStyle)
    {
    case SS_Random:
        X = Vector(Aim);
        for (p = 0; p < SpawnCount; p++)
        {
            R.Yaw = Spread * (FRand()-0.5);
            R.Pitch = Spread * (FRand()-0.5);
            R.Roll = Spread * (FRand()-0.5);
            SpawnFakeProjectile(StartProj, Rotator(X >> R), p);
        }
        break;
    case SS_Line:
        for (p = 0; p < SpawnCount; p++)
        {
            theta = Spread*PI/32768*(p - float(SpawnCount-1)/2.0);
            X.X = Cos(theta);
            X.Y = Sin(theta);
            X.Z = 0.0;
            SpawnFakeProjectile(StartProj, Rotator(X >> Aim), p);
        }
        break;
    default:
        SpawnFakeProjectile(StartProj, Aim, 0);
    }
}

function SuperServerDoFireEffect()
{
    local Vector StartProj, StartTrace, X,Y,Z;
    local Rotator R, Aim;
    local Vector HitLocation, HitNormal;
    local Actor Other;
    local int p;
    local int SpawnCount;
    local float theta;

    Instigator.MakeNoise(1.0);
    Weapon.GetViewAxes(X,Y,Z);

    StartTrace = Instigator.Location + Instigator.EyePosition();// + X*Instigator.CollisionRadius;
    StartProj = StartTrace + X*ProjSpawnOffset.X;
    if ( !Weapon.WeaponCentered() )
	    StartProj = StartProj + Weapon.Hand * Y*ProjSpawnOffset.Y + Z*ProjSpawnOffset.Z;

    // check if projectile would spawn through a wall and adjust start location accordingly
    Other = Weapon.Trace(HitLocation, HitNormal, StartProj, StartTrace, false);
    if (Other != None)
    {
        StartProj = HitLocation;
    }

    Aim = AdjustAim(StartProj, AimError);

    SpawnCount = Max(1, ProjPerFire * int(Load));

    switch (SpreadStyle)
    {
    case SS_Random:
        X = Vector(Aim);
        for (p = 0; p < SpawnCount; p++)
        {
            R.Yaw = Spread * (FRand()-0.5);
            R.Pitch = Spread * (FRand()-0.5);
            R.Roll = Spread * (FRand()-0.5);
            AltSpawnProjectile(StartProj, Rotator(X >> R), p);
        }
        break;
    case SS_Line:
        for (p = 0; p < SpawnCount; p++)
        {
            theta = Spread*PI/32768*(p - float(SpawnCount-1)/2.0);
            X.X = Cos(theta);
            X.Y = Sin(theta);
            X.Z = 0.0;
            AltSpawnProjectile(StartProj, Rotator(X >> Aim), p);
        }
        break;
    default:
        AltSpawnProjectile(StartProj, Aim, 0);
    }
}

defaultproperties
{
     FakeProjectileClass=Class'3SPNv3225PIG.NewNet_Fake_RocketProj'
}
