/*
UTComp - UT2004 Mutator
Copyright (C) 2004-2005 Aaron Everitt & Joël Moffatt

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
class NewNet_ShockProjFire extends WeaponFire_ShockAlt;

var class<Projectile> FakeProjectileClass;

var NewNet_FakeProjectileManager FPM;

function PlayFiring()
{
    super.PlayFiring();
    if(Level.NetMode != NM_Client || !class'Misc_Player'.static.UseNewNet())
       return;
    CheckFireEffect();
}

simulated function CheckFireEffect()
{
   if(Level.NetMode == NM_Client && Instigator.IsLocallyControlled())
        DoClientFireEffect();
}

simulated function DoClientFireEffect()
{
    local Vector StartProj, StartTrace, X,Y,Z;
    local Rotator Aim;
    local Vector HitLocation, HitNormal;
    local Actor Other;
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
    if(FPM.AllowFakeProjectile(FakeProjectileClass))
        p = Weapon.Spawn(FakeProjectileClass,,, Start, Dir);

    if( p == none )
        return None;

    FPM.RegisterFakeProjectile(p);
    return p;
}

simulated function FindFPM()
{
    foreach Weapon.DynamicActors(Class'NewNet_FakeProjectileManager', FPM)
        break;
}

defaultproperties
{
     FakeProjectileClass=Class'3SPNv3225PIG.NewNet_Fake_ShockProjectile'
     ProjectileClass=Class'3SPNv3225PIG.NewNet_ShockProjectile'
}
