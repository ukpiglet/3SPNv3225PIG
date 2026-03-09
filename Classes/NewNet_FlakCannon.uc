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
class NewNet_FlakCannon extends FlakCannon
    HideDropDown
	CacheExempt;

		   
			

const MAX_PROJECTILE_FUDGE = 0.075;
const MAX_PROJECTILE_FUDGE_ALT = 0.075;

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

var rotator RandSeed[9];
var int RandIndex;


replication
{
    reliable if(Role < Role_Authority)
        NewNet_ServerStartFire, NewNet_OldServerStartFire;
    unreliable if(Role == Role_Authority && bNetOwner)
        RandSeed;
}

function DisableNet()
{
    NewNet_FlakFire(FireMode[0]).bUseEnhancedNetCode = false;
    NewNet_FlakFire(FireMode[0]).PingDT = 0.00;
    NewNet_FlakAltFire(FireMode[1]).bUseEnhancedNetCode = false;
    NewNet_FlakAltFire(FireMode[1]).PingDT = 0.00;
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
    if(Level.NetMode!=NM_Client || !class'Misc_Player'.static.UseNewNet())
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

    if ( Pawn(Owner).Controller.IsInState('GameEnded') || Pawn(Owner).Controller.IsInState('RoundEnded') )
        return;
    if (Role < ROLE_Authority)
    {
        if (AltReadyToFire(Mode) && StartFire(Mode) )
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
            if(T==None)
                foreach DynamicActors(Class'NewNet_TimeStamp', T)
                     break;
            if(NewNet_FlakAltFire(FireMode[Mode])!=None)
                NewNet_FlakAltFire(FireMode[Mode]).DoInstantFireEffect();
            else if(NewNet_FlakFire(FireMode[Mode])!=None)
                NewNet_FlakFire(FireMode[Mode]).DoInstantFireEffect();
            R.Pitch = Pawn(Owner).Controller.Rotation.Pitch;
            R.Yaw = Pawn(Owner).Controller.Rotation.Yaw;
            STart=Pawn(Owner).Location + Pawn(Owner).EyePosition();

            V.X = Start.X;
            V.Y = Start.Y;
            V.Z = Start.Z;

            NewNet_ServerStartFire(mode, T.ClientTimeStamp, R, V);
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
	local Misc_BaseGRI BRGI;
	local WeaponFire FM;
	local NewNet_FlakFire FF;
	local NewNet_FlakAltFire FAF;
	local Misc_Player MP;

    if(M==None)
        foreach DynamicActors(class'TAM_Mutator', M)
	        break;

	MP = Misc_Player(Instigator.Controller);
    if(Team_GameBase(Level.Game)!=None && MP!=None)
      MP.NotifyServerStartFire(ClientTimeStamp, M.ClientTimeStamp, M.AverDT);
          
    if ( (Instigator != None) && (Instigator.Weapon != self) )
	{
		if ( Instigator.Weapon == None )
			Instigator.ServerChangedWeapon(None,self);
		else
			Instigator.Weapon.SynchronizeWeapon(self);
		return;
	}

	BRGI = Misc_BaseGRI(Level.GRI);
	FM = FireMode[Mode];
	FF = NewNet_FlakFire(FM);
	FAF = NewNet_FlakAltFire(FM);

    if(NewNet_FlakFire(FM)!=None)
    {
		if (BRGI.NewNetExp)
		{
			FF.PingDT = FMin(M.ClientTimeStamp - ClientTimeStamp + (M.AverDT * BRGI.NewNetExp_ProjMult), BRGI.NewNetExp_ThresholdProj);
		}
		else
		{
		FF.PingDT = FMin(M.ClientTimeStamp - ClientTimeStamp + 1.75*M.AverDT, MAX_PROJECTILE_FUDGE_ALT);
		}
		FF.bUseEnhancedNetCode = true;
	}
	else if(FAF!=None)
	{
		if (BRGI.NewNetExp)
		{
			FAF.PingDT = FMin(M.ClientTimeStamp - ClientTimeStamp + (M.AverDT * BRGI.NewNetExp_ProjMult), BRGI.NewNetExp_ThresholdProj);
		}
		else
		{
			FAF.PingDT = FMin(M.ClientTimeStamp - ClientTimeStamp + 1.75*M.AverDT, MAX_PROJECTILE_FUDGE);
		}
        FAF.bUseEnhancedNetCode = true;
    }

    if ( (FM.NextFireTime <= Level.TimeSeconds + FM.PreFireTime)
		&& StartFire(Mode) )
    {
        FM.ServerStartFireTime = Level.TimeSeconds;
        FM.bServerDelayStartFire = false;

        if(FF!=None)
        {
            FF.SavedVec.X = V.X;
            FF.SavedVec.Y = V.Y;
            FF.SavedVec.Z = V.Z;
            FF.SavedRot.Yaw = R.Yaw;
            FF.SavedRot.Pitch = R.Pitch;
            FF.bUseReplicatedInfo=IsReasonable(FF.SavedVec);
        }
        else if(FAF!=None)
        {
            FAF.SavedVec.X = V.X;
            FAF.SavedVec.Y = V.Y;
            FAF.SavedVec.Z = V.Z;
            FAF.SavedRot.Yaw = R.Yaw;
            FAF.SavedRot.Pitch = R.Pitch;
            FAF.bUseReplicatedInfo=IsReasonable(FAF.SavedVec);
        }
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

    if(Owner == none || Pawn(Owner) == none)
        return true;

    LocDiff = V - (Pawn(Owner).Location + Pawn(Owner).EyePosition());
    clErr = (LocDiff dot LocDiff);
    return clErr < 750.0;
}

function SendNewRandSeed()
{
    local rotator R;
    local int i;
    local float Spread;
    Spread = Class'NewNet_FlakFire'.default.Spread;
    for(i=0; i<ArrayCount(RandSeed); i++)
    {
        R.Yaw = Spread * (FRand()-0.5);
        R.Pitch = Spread * (FRand()-0.5);
        R.Roll = Spread * (FRand()-0.5);

        RandSeed[i]=R;
    }
    RandIndex=0;
}

simulated function rotator GetRandRot()
{
    if(RandIndex > 8)
    {
        RandIndex = 0;
    }
    RandIndex++;
    return RandSeed[RandIndex-1];
}

simulated event PostNetBeginPlay()
{
    super.PostNetBeginPlay();
    SendNewRandSeed();
}

function NewNet_OldServerStartFire(byte Mode, float ClientTimeStamp)
{
	local Misc_BaseGRI BGRI;
	local WeaponFire FM;
	local NewNet_FlakFire FF;
	local NewNet_FlakAltFire FAF;

    if(M==None)
        foreach DynamicActors(class'TAM_Mutator', M)
	        break;

	BGRI = Misc_BaseGRI(Level.GRI);
	FM = FireMode[Mode];
	FF = NewNet_FlakFire(FM);

    if(FF!=None)
    {
		if (BGRI.NewNetExp)
		{
			FF.PingDT = FMin(M.ClientTimeStamp - ClientTimeStamp + (M.AverDT * BGRI.NewNetExp_ProjMult), BGRI.NewNetExp_ThresholdProj);
		}
		else
		{
		FF.PingDT = FMin(M.ClientTimeStamp - ClientTimeStamp + 1.75*M.AverDT, MAX_PROJECTILE_FUDGE_ALT);
		}
        FF.bUseEnhancedNetCode = true;
    }
    else
	{
		FAF = NewNet_FlakAltFire(FireMode[Mode]);
		if(FAF!=None)
		{
			if (BGRI.NewNetExp)
			{
				FAF.PingDT = FMin(M.ClientTimeStamp - ClientTimeStamp + (M.AverDT * BGRI.NewNetExp_ProjMult), BGRI.NewNetExp_ThresholdProj);
			}
			else
			{
				FAF.PingDT = FMin(M.ClientTimeStamp - ClientTimeStamp + 1.75*M.AverDT, MAX_PROJECTILE_FUDGE);
			}
			FAF.bUseEnhancedNetCode = true;
		}
	}

    ServerStartFire(mode);
}

defaultproperties
{
     FireModeClass(0)=Class'3SPNv3225PIG.NewNet_FlakFire'
     FireModeClass(1)=Class'3SPNv3225PIG.NewNet_FlakAltFire'
}
