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
class NewNet_FlakFire extends WeaponFire_Flak;

var float PingDT;
var bool bUseEnhancedNetCode;

var bool bUseReplicatedInfo;
var rotator savedRot;
var vector savedVec;

var vector OldInstigatorLocation;
var Vector OldInstigatorEyePosition;
var vector OldXAxis,OldYAxis, OldZAxis;
var rotator OldAim;

var class<Projectile> FakeProjectileClass;
var NewNet_FakeProjectileManager FPM;
var TAM_Mutator MNN;
var bool bSkipNextEffect;

const PROJ_TIMESTEP = 0.0251;
const MAX_PROJECTILE_FUDGE = 0.075;
const SLACK = 0.01;

const EXP_MAX_PROJECTILE_FUDGE = 0.020;
const EXP_PROJ_TIMESTEP = 0.01;
var float timestep;

function PlayFiring()
{
   super.PlayFiring();

   if(Level.NetMode != NM_Client || !class'Misc_Player'.static.UseNewNet())
       return;
   if(!bSkipNextEffect)
       CheckFireEffect();
   else
   {
      bSkipNextEffect=false;
	  if (Weapon != None)
		Weapon.ClientStopFire(0);
   }
}

function CheckFireEffect()
{
   if(Level.NetMode == NM_Client && Instigator.IsLocallyControlled())
   {
       if (Misc_BaseGRI(Level.GRI).NewNetExp)
	   {
			if(Class'NewNet_PRI'.default.PredictedPing > EXP_MAX_PROJECTILE_FUDGE)
			{
				OldInstigatorLocation = Instigator.Location;
				OldInstigatorEyePosition = Instigator.EyePosition();
				Weapon.GetViewAxes(OldXAxis,OldYAxis,OldZAxis);
				OldAim=AdjustAim(OldInstigatorLocation+OldInstigatorEyePosition, AimError);
				SetTimer(Class'NewNet_PRI'.default.PredictedPing - EXP_MAX_PROJECTILE_FUDGE, false);
			}
			else
				DoClientFireEffect();
	   }
	   else
	   {
			if(Class'NewNet_PRI'.default.PredictedPing - SLACK > MAX_PROJECTILE_FUDGE)
			{
				OldInstigatorLocation = Instigator.Location;
				OldInstigatorEyePosition = Instigator.EyePosition();
				Weapon.GetViewAxes(OldXAxis,OldYAxis,OldZAxis);
				OldAim=AdjustAim(OldInstigatorLocation+OldInstigatorEyePosition, AimError);
				SetTimer(Class'NewNet_PRI'.default.PredictedPing - SLACK - MAX_PROJECTILE_FUDGE, false);
			}
			else
				DoClientFireEffect();
	   }
   }
}

function Timer()
{
   DoTimedClientFireEffect();
}

function DoInstantFireEffect()
{
   CheckFireEffect();
   bSkipNextEffect=true;
}

simulated function DoTimedClientFireEffect()
{
    local Vector StartProj, StartTrace, X,Y,Z;
    local Rotator R, Aim;
    local Vector HitLocation, HitNormal;
    local Actor Other;
    local int p;
    local int SpawnCount;

    Instigator.MakeNoise(1.0);
    //Weapon.GetViewAxes(X,Y,Z);
    X = OldXAxis;
    Y = OldXAxis;
    Z = OldXAxis;

   // StartTrace = Instigator.Location + Instigator.EyePosition();// + X*Instigator.CollisionRadius;
    StartTrace = OldInstigatorLocation + OldInstigatorEyePosition;

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
    SpawnCount = Max(1, ProjPerFire * int(Load));

    switch (SpreadStyle)
    {
    case SS_Random:
        X = Vector(Aim);
        for (p = 0; p < SpawnCount; p++)
        {
            R = NewNet_FlakCannon(Weapon).GetRandRot();
			
			if(FPM==None)
			{
				FindFPM();
				if(FPM==None)
					return;
			}
				
            if(FPM.AllowFakeProjectile(FakeProjectileClass, p))
            {
                FPM.RegisterFakeProjectile(FlakChunk(SpawnFakeProjectile(StartProj, Rotator(X >> R))), p);
            }
        }
        break;
    default:
        SpawnFakeProjectile(StartProj, Aim);
    }
}

simulated function DoClientFireEffect()
{
    local Vector StartProj, StartTrace, X,Y,Z;
    local Rotator R, Aim;
    local Vector HitLocation, HitNormal;
    local Actor Other;
    local int p;
    local int SpawnCount;

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
            R = NewNet_FlakCannon(Weapon).GetRandRot();
			
			if(FPM==None)
			{
				FindFPM();
				if(FPM==None)
					return;
			}
	
            if(FPM.AllowFakeProjectile(FakeProjectileClass, p))
                FPM.RegisterFakeProjectile(FlakChunk(SpawnFakeProjectile(StartProj, Rotator(X >> R))), p);
        }
        break;
    default:
        SpawnFakeProjectile(StartProj, Aim);
    }
}


simulated function projectile SpawnFakeProjectile(Vector Start, Rotator Dir)
{
    local Projectile p;

    p = FakeSuperSpawnProjectile(Start,Dir);
	return p;
}

simulated function projectile FakeSuperSpawnProjectile(Vector Start, Rotator Dir)
{
    local Projectile p;

    if( ProjectileClass != None )
        p = Weapon.Spawn(FakeProjectileClass,,, Start, Dir);

    if( p == none )
        return None;
    p.Damage *= DamageAtten;
    return p;
}

simulated function FindFPM()
{
    foreach Weapon.DynamicActors(Class'NewNet_FakeProjectileManager', FPM)
        break;
}

function DoFireEffect()
{
    local Vector StartProj, StartTrace, X,Y,Z;
    local Rotator R, Aim;
    local Vector HitLocation, HitNormal;
    local Actor Other;
    local int p;
    local int SpawnCount;
    local projectile proj;

    if(!bUseEnhancedNetCode)
    {
       super.DoFireEffect();
       return;
    }

    Instigator.MakeNoise(1.0);
    Weapon.GetViewAxes(X,Y,Z);

    if(bUseReplicatedInfo)
        StartTrace = SavedVec;
    else
        StartTrace = Instigator.Location + Instigator.EyePosition();// + X*Instigator.CollisionRadius;

    StartProj = StartTrace + X*ProjSpawnOffset.X;
    if ( !Weapon.WeaponCentered() )
	    StartProj = StartProj + Weapon.Hand * Y*ProjSpawnOffset.Y + Z*ProjSpawnOffset.Z;

    // check if projectile would spawn through a wall and adjust start location accordingly
    if(Weapon.Owner!=None)
        Other = Weapon.Owner.Trace(HitLocation, HitNormal, StartProj, StartTrace, false);
    else
        Other=Weapon.Trace(HitLocation, HitNormal, StartProj, StartTrace, false);
    if (Other != None)
    {
        StartProj = HitLocation;
    }

    if(bUseReplicatedInfo)
    {
        Aim = SavedRot;
        bUseReplicatedInfo=false;
    }
    else
        Aim = AdjustAim(StartProj, AimError);

    SpawnCount = Max(1, ProjPerFire * int(Load));

    switch (SpreadStyle)
    {
    case SS_Random:
        X = Vector(Aim);
        for (p = 0; p < SpawnCount; p++)
        {
            R = NewNet_FlakCannon(Weapon).GetRandRot();
            proj = SpawnProjectile(StartProj, Rotator(X >> R));
            if(proj!=None)
                NewNet_FlakChunk(proj).ChunkNum = p;
        }
        break;
    default:
        SpawnProjectile(StartProj, Aim);
    }
    NewNet_FlakCannon(Weapon).SendNewRandSeed();
}

function projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local Projectile p;

    local vector End, HitNormal, HitLocation;
    local actor Other;
    local float f,g;

    if(!bUseEnhancedNetCode)
        return super.SpawnProjectile(Start,Dir);
    /* change this to use gravity */
    if( ProjectileClass != None )
    {
        if(PingDT > 0.0 && Weapon.Owner!=None)
        {
            Start-=1.0*vector(Dir);
			if (Misc_BaseGRI(Level.GRI).NewNetExp)
			{
				timestep = EXP_PROJ_TIMESTEP;
			}
			else
			{
				timestep = PROJ_TIMESTEP;
			}
            for(f=0.00; f<pingDT + timestep; f+=timestep)
            {
                //Make sure the last trace we do is right where we want
                //the proj to spawn if it makes it to the end
                g = Fmin(pingdt, f);
                //Where will it be after deltaF, Dir byRef for next tick
                End = Start + Extrapolate(Dir, timestep);
                //Put pawns there
                TimeTravel(pingdt - g);
                //RadiusTimeTravel(pingDT-g);
                //Trace between the start and extrapolated end
                Other = DoTimeTravelTrace(HitLocation, HitNormal, End, Start);
                if(Other!=None)
                {
                    break;
                }
                //repeat
                Start=End;
           }
           UnTimeTravel();

           if(Other!=None && Other.IsA('NewNet_PawnCollisionCopy'))
           {
                 HitLocation = HitLocation + NewNet_PawnCollisionCopy(Other).CopiedPawn.Location - Other.Location;
                 Other=NewNet_PawnCollisionCopy(Other).CopiedPawn;
           }

           if(Other == none)
               p = Weapon.Spawn(ProjectileClass,,, End, Dir);
           else
               p = Weapon.Spawn(ProjectileClass,,, HitLocation - Vector(dir)*20.0, Dir);
        }
        else
            p = Weapon.Spawn(ProjectileClass,,, Start, Dir);
    }

    if( p == None )
        return None;

    p.Damage *= DamageAtten;
    return p;
}

function vector Extrapolate(out rotator Dir, float dF)
{
    return vector(Dir)*ProjectileClass.default.speed*dF;
}

// We need to do 2 traces. First, one that ignores the things which have already been copied
// and a second one that looks only for things that are copied
function Actor DoTimeTravelTrace(Out vector Hitlocation, out vector HitNormal, vector End, vector Start)
{
    local Actor Other;
    local bool bFoundPCC;
    local vector NewEnd, WorldHitNormal,WorldHitLocation;
    local vector PCCHitNormal,PCCHitLocation;
    local NewNet_PawnCollisionCopy PCC, returnPCC;

    //First, lets set the extent of our trace.  End once we hit an actor which won't
    //be checked by an unlagged copy.
    foreach Weapon.TraceActors(class'Actor', Other,WorldHitLocation,WorldHitNormal,End,Start)
    {
       if((Other.bBlockActors || Other.bProjTarget || Other.bWorldGeometry) && !class'TAM_Mutator'.static.IsPredicted(Other))
       {
           break;
       }
       Other=None;
    }
    if(Other!=None)
        NewEnd=WorldHitlocation;
    else
        NewEnd=End;

    //Now, lets see if we run into any copies, we stop at the location
    //determined by the previous trace.
    foreach Weapon.TraceActors(Class'NewNet_PawnCollisionCopy', PCC, PCCHitLocation, PCCHitNormal, NewEnd,Start)
    {
        if(PCC!=None && PCC.CopiedPawn!=None && PCC.CopiedPawn!=Instigator)
        {
            bFoundPCC=True;
            returnPCC=PCC;
            break;
        }
    }

    // Give back the corresponding info depending on whether or not
    // we found a copy

    if(bFoundPCC)
    {
        HitLocation = PCCHitLocation;
        HitNormal = PCCHitNormal;
        return returnPCC;
    }
    else
    {
        HitLocation = WorldHitLocation;
        HitNormal = WorldHitNormal;
        return Other;
    }
}

function TimeTravel(float delta)
{
    local NewNet_PawnCollisionCopy PCC;

    if(NewNet_FlakCannon(Weapon).M == none)
        foreach Weapon.DynamicActors(class'TAM_Mutator',NewNet_FlakCannon(Weapon).M)
            break;

    for(PCC = NewNet_FlakCannon(Weapon).M.PCC; PCC!=None; PCC=PCC.Next)
        PCC.TimeTravelPawn(Delta);
}

function UnTimeTravel()
{
    local NewNet_PawnCollisionCopy PCC;
    //Now, lets turn off the old hits
    for(PCC = NewNet_FlakCannon(Weapon).M.PCC; PCC!=None; PCC=PCC.Next)
        PCC.TurnOffCollision();
}

defaultproperties
{
     FakeProjectileClass=Class'3SPNv3225PIG.NewNet_Fake_FlakChunk'
     ProjectileClass=Class'3SPNv3225PIG.NewNet_FlakChunk'
}
