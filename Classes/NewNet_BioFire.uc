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
class NewNet_BioFire extends WeaponFire_Bio;

var float PingDT;
var bool bUseEnhancedNetCode;

const PROJ_TIMESTEP = 0.0201;
const MAX_PROJECTILE_FUDGE = 0.075;
const SLACK = 0.01;

var class<Projectile> FakeProjectileClass;
var NewNet_FakeProjectileManager FPM;

var vector OldInstigatorLocation;
var Vector OldInstigatorEyePosition;
var vector OldXAxis,OldYAxis, OldZAxis;
var rotator OldAim;

const EXP_MAX_PROJECTILE_FUDGE = 0.020;
const EXP_PROJ_TIMESTEP = 0.01;
var float timestep;

function projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local Projectile p;

    local rotator NewDir;
    local float f,g;
    local vector End, HitLocation, HitNormal, VZ;
    local actor Other;


    if(Level.NetMode == NM_Client && class'Misc_Player'.static.UseNewNet())
        return SpawnFakeProjectile(Start,Dir);

    if(!bUseEnhancedNetCode)
        return super.SpawnProjectile(start,Dir);

    if( ProjectileClass != none )
    {
        if(PingDT > 0.0 && Weapon.Owner!=None)
        {
            NewDir=Dir;
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
                //Where will it be after deltaF, NewDir byRef for next tick
                End = Start + Extrapolate(NewDir, timestep, g==0.00);
                //Put pawns there
                TimeTravel(pingdt - g);
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

           VZ.Z = ProjectileClass.default.TossZ;
           NewDir =  rotator(vector(NewDir)*ProjectileClass.default.speed - VZ);
           if(Other == none)
               p = Weapon.Spawn(ProjectileClass,,, End, NewDir);
           else
               p = Weapon.Spawn(ProjectileClass,,, HitLocation - Vector(Newdir)*16.0, NewDir);
        }
        else
            p = Weapon.Spawn(ProjectileClass,,, Start, Dir);
    }


    if( p == none )
        return None;
    if(NewNet_BioGlob(p)!=None)
    {
        NewNet_BioGlob(p).Index=NewNet_BioRifle(Weapon).CurIndex;
        NewNet_BioRifle(Weapon).CurIndex++;
    }

    p.Damage *= DamageAtten;
    return p;
}

function vector Extrapolate(out rotator Dir, float dF, bool bTossZ)
{
    local rotator OldDir;
    local Vector VZ;

    OldDir=Dir;

    if(bTossZ)
    {
        VZ.Z = ProjectileClass.default.TossZ;
        Dir = rotator(vector(OldDir)*ProjectileClass.default.speed + VZ + Weapon.Owner.PhysicsVolume.Gravity*dF);
    }
    else
        Dir = rotator(vector(OldDir)*ProjectileClass.default.speed + Weapon.Owner.PhysicsVolume.Gravity*dF);

    if(bTossZ)
    {
        return (vector(OldDir)*ProjectileClass.default.speed + VZ)*dF + 0.5*Square(dF)*Weapon.Owner.PhysicsVolume.Gravity;
    }
    else
        return vector(OldDir)*ProjectileClass.default.speed*dF + 0.5*Square(dF)*Weapon.Owner.PhysicsVolume.Gravity;
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

    if(NewNet_BioRifle(Weapon).M == none)
        foreach Weapon.DynamicActors(class'TAM_Mutator',NewNet_BioRifle(Weapon).M)
            break;

    for(PCC = NewNet_BioRifle(Weapon).M.PCC; PCC!=None; PCC=PCC.Next)
        PCC.TimeTravelPawn(Delta);
}

function UnTimeTravel()
{
    local NewNet_PawnCollisionCopy PCC;
    //Now, lets turn off the old hits
    for(PCC = NewNet_BioRifle(Weapon).M.PCC; PCC!=None; PCC=PCC.Next)
        PCC.TurnOffCollision();
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

function PlayFiring()
{
   super.PlayFiring();

   if(Level.NetMode != NM_Client || !class'Misc_Player'.static.UseNewNet())
       return;
   CheckFireEffect();
}

function DoClientFireEffect()
{
   super.DoFireEffect();
}

simulated function DoTimedClientFireEffect()
{
    local Vector StartProj, StartTrace, X,Y,Z;
    local Rotator Aim;
    local Vector HitLocation, HitNormal;
    local Actor Other;
    local int SpawnCount;

    Instigator.MakeNoise(1.0);
   // Weapon.GetViewAxes(X,Y,Z);
    X = OldXaxis;
    Y = OldXaxis;
    Z = OldXaxis;

  //  StartTrace = Instigator.Location + Instigator.EyePosition();// + X*Instigator.CollisionRadius;
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
    SpawnFakeProjectile(StartProj, Aim);
}

simulated function projectile SpawnFakeProjectile(Vector Start, Rotator Dir)
{
    local Projectile p;

    if(FPM==None)
	{
        FindFPM();
		if(FPM==None)
			return None;
	}

    if(FPM.AllowFakeProjectile(FakeProjectileClass, NewNet_BioRifle(Weapon).CurIndex))
    {
        p = Spawn(FakeProjectileClass,Weapon.Owner,, Start, Dir);
    }
    if( p == none )
        return None;
    FPM.RegisterFakeProjectile(p, NewNet_BioRifle(Weapon).CurIndex);
    return p;
}

simulated function FindFPM()
{
    foreach Weapon.DynamicActors(Class'NewNet_FakeProjectileManager', FPM)
        break;
}

defaultproperties
{
     FakeProjectileClass=Class'3SPNv3225PIG.NewNet_Fake_BioGlob'
     ProjectileClass=Class'3SPNv3225PIG.NewNet_BioGlob'
}
