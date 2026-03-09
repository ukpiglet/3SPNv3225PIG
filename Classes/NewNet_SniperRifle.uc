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
//-----------------------------------------------------------
//
//-----------------------------------------------------------
class NewNet_SniperRifle extends SniperRifle
    HideDropDown
	CacheExempt;

struct ReplicatedRotator
{
    var int Yaw;
    var int Pitch;
};

struct ReplicatedVector
{
    var float X;
    var float Y;
    var float Z;
};

var NewNet_TimeStamp T;
var TAM_Mutator M;

replication
{
    reliable if(Role < Role_Authority)
        NewNet_ServerStartFire;
    unreliable if(bDemoRecording)
        SpawnLGEffect;
}

function DisableNet()
{
    NewNet_SniperFire(FireMode[0]).bUseEnhancedNetCode = false;
    NewNet_SniperFire(FireMode[0]).PingDT = 0.00;
}

simulated function float RateSelf()
{
	if(Instigator==None)
		return -2;
	return Super.RateSelf();
}

simulated function BringUp(optional Weapon PrevWeapon)
{
	if(Instigator==None)
		return;
	Super.BringUp(PrevWeapon);
}

simulated function bool PutDown()
{
	if(Instigator==None)
		return false;
	return Super.PutDown();
}

simulated function SpawnLGEffect(class<Actor> tmpHitEmitClass, vector ArcEnd, vector HitNormal, vector HitLocation)
{
    local xEmitter HitEmitter;
    hitEmitter = xEmitter(Spawn(tmpHitEmitClass,,, arcEnd, Rotator(HitNormal)));
    if ( hitEmitter != None )
	  	hitEmitter.mSpawnVecA = HitLocation;
    if(Level.NetMode!=NM_Client)
        Warn("Server should never spawn the client lightningbolt");
}

simulated function ClientStartFire(int mode)
{
    if(Level.NetMode!=NM_Client)
    {
        Super.ClientStartFire(mode);
        return;
    }

    if (mode == 1)
    {
        FireMode[mode].bIsFiring = true;
        if( Instigator.Controller.IsA( 'PlayerController' ) )
            PlayerController(Instigator.Controller).ToggleZoom();
    }
    else
    {
		if(class'Misc_Player'.static.UseNewNet())
			NewNet_ClientStartFire(mode);
		else
			super(Weapon).ClientStartFire(mode);
    }
}

simulated function NewNet_ClientStartFire(int mode)
{
    local ReplicatedRotator R;
    local ReplicatedVector V;
    local vector Start;
    local float stamp;
	local Pawn P;
	local controller C;

	P = Pawn(Owner);
	C = P.Controller;
    if ( C.IsInState('GameEnded') || C.IsInState('RoundEnded') )
        return;

    if (Role < ROLE_Authority)
    {
        if (AltReadyToFire(mode) && StartFire(Mode) )
        {
            R.Pitch = C.Rotation.Pitch;
            R.Yaw = C.Rotation.Yaw;
            STart=P.Location + P.EyePosition();

            V.X = Start.X;
            V.Y = Start.Y;
            V.Z = Start.Z;

            if(T==None)
                foreach DynamicActors(Class'NewNet_TimeStamp', T)
                     break;
            Stamp = T.ClientTimeStamp;

            NewNet_SniperFire(FireMode[mode]).DoInstantFireEffect();
            NewNet_ServerStartFire(Mode, stamp, R, V/*, b, V2, A,HN,HL*/);
        }
    }
    else
    {
        StartFire(Mode);
    }
}

simulated function bool AltReadyToFire(int Mode)
{
    local int alt;
    local float f;
	local WeaponFire FMA, FMM;

    //There is a very slight descynchronization error on the server
    // with weapons due to differing deltatimes which accrues to a pretty big
    // error if people just hold down the button...
    // This will never cause the weapon to actually fire slower
    f = 0.015;

    if(!ReadyToFire(Mode))
        return false;

    if ( Mode == 0 )
        alt = 1;
    else
        alt = 0;

	FMM = FireMode[Mode];
	FMA = FireMode[alt];
    if ( ((FMA != FMM) && FMA.bModeExclusive && FMA.bIsFiring)
		|| !FMM.AllowFire()
		|| (FMM.NextFireTime > Level.TimeSeconds + FMM.PreFireTime - f) )
    {
        return false;
    }

	return true;
}

function NewNet_ServerStartFire(byte Mode, float ClientTimeStamp, ReplicatedRotator R, ReplicatedVector V)
{
	local Misc_BaseGRI BGRI;
	local WeaponFire FM;
	local NewNet_SniperFire SF;
	local Misc_Player MP;

	if ( (Instigator != None) && (Instigator.Weapon != self) )
	{
		if ( Instigator.Weapon == None )
			Instigator.ServerChangedWeapon(None,self);
		else
			Instigator.Weapon.SynchronizeWeapon(self);
		return;
	}

	if(M==None)
        foreach DynamicActors(class'TAM_Mutator', M)
	        break;

	MP = Misc_Player(Instigator.Controller);
    if(Team_GameBase(Level.Game)!=None && MP!=None)
      MP.NotifyServerStartFire(ClientTimeStamp, M.ClientTimeStamp, M.AverDT);
          
	BGRI = Misc_BaseGRI(Level.GRI);
	FM = FireMode[Mode];
	SF = NewNet_SniperFire(FM);
	if (BGRI.NewNetExp)
	{
		SF.PingDT = FClamp(M.ClientTimeStamp - ClientTimeStamp + (M.AverDT * BGRI.NewNetExp_HSMult), 0, BGRI.NewNetExp_ThresholdHS);
	}
	else
	{
		SF.PingDT = M.ClientTimeStamp - ClientTimeStamp + 1.75*M.AverDT;
	}
	SF.bUseEnhancedNetCode = true;
    if ( (FM.NextFireTime <= Level.TimeSeconds + FM.PreFireTime)
		&& StartFire(Mode) )
    {
        FM.ServerStartFireTime = Level.TimeSeconds;
        FM.bServerDelayStartFire = false;
        SF.SavedVec.X = V.X;
        SF.SavedVec.Y = V.Y;
        SF.SavedVec.Z = V.Z;
        SF.SavedRot.Yaw = R.Yaw;
        SF.SavedRot.Pitch = R.Pitch;
        SF.bUseReplicatedInfo=IsReasonable(SF.SavedVec);
    }
    else if ( FM.AllowFire() )
    {
        FM.bServerDelayStartFire = true;
	}
	else
		ClientForceAmmoUpdate(Mode, AmmoAmount(Mode));
}

function bool IsReasonable(Vector V)
{
    local vector LocDiff;
    local float clErr;
	local Pawn P;

	if(Owner == none)
		return true;

	P = Pawn(Owner);
	if (P == none)
        return true;

    LocDiff = V - (P.Location + P.EyePosition());
    clErr = (LocDiff dot LocDiff);

    return clErr < 850.0; // Epic default allows 850 units, why 750 here?
}

defaultproperties
{
     FireModeClass(0)=Class'3SPNv3225PIG.NewNet_SniperFire'
}
