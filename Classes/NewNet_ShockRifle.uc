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
class NewNet_ShockRifle extends ShockRifle
	HideDropDown
	CacheExempt;

var NewNet_TimeStamp T;
var TAM_Mutator M;



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

replication
{
    reliable if( Role<ROLE_Authority )
        NewNet_ServerStartFire,NewNet_OldServerStartFire;
    unreliable if(bDemoRecording)
        SpawnBeamEffect;
}


function DisableNet()
{
    NewNet_ShockBeamFire(FireMode[0]).bUseEnhancedNetCode = false;
    NewNet_ShockBeamFire(FireMode[0]).PingDT = 0.00;
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

//// client only ////
simulated event ClientStartFire(int Mode)
{
    if(Level.NetMode!=NM_Client || !class'Misc_Player'.static.UseNewNet() || NewNet_ShockBeamFire(FireMode[Mode]) == None)
        super.ClientStartFire(mode);
    else
        NewNet_ClientStartFire(mode);
}

simulated event NewNet_ClientStartFire(int Mode)
{
    local ReplicatedRotator R;
    local ReplicatedVector V;
    local vector Start;
    local float stamp;
	local Pawn P;
	local Controller C;

	P = Pawn(Owner);
	C = P.Controller;
    if ( C.IsInState('GameEnded') || C.IsInState('RoundEnded') )
        return;

    if (Role < ROLE_Authority)
    {
        if (AltReadyToFire(Mode) && StartFire(Mode))
        {
            if(!ReadyToFire(Mode))
            {
                if(T==None)
                    foreach DynamicActors(Class'NewNet_TimeStamp', T)
                         break;
                Stamp = T.ClientTimeStamp;
                NewNet_OldServerStartFire(Mode,Stamp);
                return;
            }
            R.Pitch = C.Rotation.Pitch;
            R.Yaw = C.Rotation.Yaw;
            Start = P.Location + P.EyePosition();

            V.X = Start.X;
            V.Y = Start.Y;
            V.Z = Start.Z;

            if(T==None)
                foreach DynamicActors(Class'NewNet_TimeStamp', T)
                     break;
            Stamp = T.ClientTimeStamp;

            NewNet_ShockBeamFire(FireMode[mode]).DoInstantFireEffect();
            NewNet_ServerStartFire(Mode, stamp, R, V);
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
	local NewNet_ShockBeamFire BF;
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
	BF = NewNet_ShockBeamFire(FM);
	if (BGRI.NewNetExp)
	{
		BF.PingDT = FClamp(M.ClientTimeStamp - ClientTimeStamp + (M.AverDT * BGRI.NewNetExp_HSMult), 0, BGRI.NewNetExp_ThresholdHS);
	}
	else
	{
		BF.PingDT = M.ClientTimeStamp - ClientTimeStamp + 1.75*M.AverDT;
	}
    BF.bUseEnhancedNetCode = true;
    if ( (FM.NextFireTime <= Level.TimeSeconds + FM.PreFireTime)
		&& StartFire(Mode) )
    {
        FM.ServerStartFireTime = Level.TimeSeconds;
        FM.bServerDelayStartFire = false;
        BF.SavedVec.X = V.X;
        BF.SavedVec.Y = V.Y;
        BF.SavedVec.Z = V.Z;
        BF.SavedRot.Yaw = R.Yaw;
        BF.SavedRot.Pitch = R.Pitch;
        BF.bUseReplicatedInfo=IsReasonable(BF.SavedVec);
    }
    else if ( FM.AllowFire() )
    {
        FM.bServerDelayStartFire = true;
	}
	else
		ClientForceAmmoUpdate(Mode, AmmoAmount(Mode));
}

function NewNet_OldServerStartFire(byte Mode, float ClientTimeStamp)
{
	local Misc_BaseGRI BGRI;
	local NewNet_ShockBeamFire SBF;

    if(M==None)
        foreach DynamicActors(class'TAM_Mutator', M)
	        break;

	BGRI = Misc_BaseGRI(Level.GRI);
	SBF = NewNet_ShockBeamFire(FireMode[Mode]);
    if (BGRI.NewNetExp)
	{
		SBF.PingDT = FClamp(M.ClientTimeStamp - ClientTimeStamp + (M.AverDT * BGRI.NewNetExp_HSMult), 0, BGRI.NewNetExp_ThresholdHS);
	}
	else
	{
		SBF.PingDT = M.ClientTimeStamp - ClientTimeStamp + 1.75*M.AverDT;
	}
    SBF.bUseEnhancedNetCode = true;
    ServerStartFire(mode);
}

function bool IsReasonable(Vector V)
{
    local vector LocDiff;
    local float clErr;

    if(Owner == none || Pawn(Owner) == none)
        return true;

    LocDiff = V - (Pawn(Owner).Location + Pawn(Owner).EyePosition());
    clErr = (LocDiff dot LocDiff);

    return clErr < 750.0;
}

simulated function SpawnBeamEffect(vector HitLocation, vector HitNormal, vector Start, rotator Dir, int reflectnum)
{
    local ShockBeamEffect Beam;

    if(bClientDemoNetFunc)
    {
        Start.Z = Start.Z - 64.0;
    }
    Beam = Spawn(Class'NewNet_Client_ShockBeamEffect',,, Start, Dir);
    if (ReflectNum != 0) Beam.Instigator = None; // prevents client side repositioning of beam start
       Beam.AimAt(HitLocation, HitNormal);
}

defaultproperties
{
     FireModeClass(0)=Class'3SPNv3225PIG.NewNet_ShockBeamFire'
     FireModeClass(1)=Class'3SPNv3225PIG.NewNet_ShockProjFire'
}
