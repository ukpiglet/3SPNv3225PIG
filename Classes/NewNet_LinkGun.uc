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
class NewNet_LinkGun extends LinkGun
	HideDropDown
	CacheExempt;

var NewNet_TimeStamp T;
var TAM_Mutator M;

const MAX_PROJECTILE_FUDGE = 0.075;
									  

var int CurIndex;

replication
{
    reliable if( Role<ROLE_Authority )
        NewNet_ServerStartFire;
 /*   unreliable if(Role == Role_Authority)
        DispatchClientEffect;   */
    unreliable if(Role == Role_Authority && bNetOwner)
        CurIndex;
}

function DisableNet()
{
    NewNet_LinkAltFire(FireMode[0]).bUseEnhancedNetCode = false;
    NewNet_LinkAltFire(FireMode[0]).PingDT = 0.00;
    NewNet_LinkFire(FireMode[1]).bUseEnhancedNetCode = false;
    NewNet_LinkFire(FireMode[1]).PingDT = 0.00;
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
	local controller C;

	C = Pawn(Owner).Controller;
    if ( C.IsInState('GameEnded') || C.IsInState('RoundEnded') )
        return;

    if (Role < ROLE_Authority)
    {
        if (StartFire(Mode))
        {
            if(T==None)
                foreach DynamicActors(Class'NewNet_TimeStamp', T)
                     break;

            NewNet_ServerStartFire(mode, T.ClientTimeStamp);
        }
    }
    else
    {
        StartFire(Mode);
    }
}

function NewNet_ServerStartFire(byte Mode, float ClientTimeStamp)
{
    local Misc_BaseGRI BRGI;
	local Misc_Player MP;
	local NewNet_LinkAltFire LA;
	local NewNet_LinkFire LF;
	local WeaponFire FM;

	if(M==None)
        foreach DynamicActors(class'TAM_Mutator', M)
	        break;

	MP = Misc_Player(Instigator.Controller);
    if(Team_GameBase(Level.Game)!=None && MP!=None)
      MP.NotifyServerStartFire(ClientTimeStamp, M.ClientTimeStamp, M.AverDT);

	BRGI = Misc_BaseGRI(Level.GRI);
	FM = FireMode[Mode];
	LA = NewNet_LinkAltFire(FM);

    if(LA!=None)
    {
		if (BRGI.NewNetExp)
		{
			LA.PingDT = FMin(M.ClientTimeStamp - ClientTimeStamp + (M.AverDT * BRGI.NewNetExp_ProjMult), BRGI.NewNetExp_ThresholdProj);
		}
		else
		{
			LA.PingDT = FMin(M.ClientTimeStamp - ClientTimeStamp + 1.75*M.AverDT, MAX_PROJECTILE_FUDGE);
		}
        LA.bUseEnhancedNetCode = true;
    }
    else
	{
		LF = NewNet_LinkFire(FM);
		if(LF!=None)
		{
			if (BRGI.NewNetExp)
			{
				LF.PingDT = FClamp(M.ClientTimeStamp - ClientTimeStamp + (M.AverDT * BRGI.NewNetExp_HSMult), 0, BRGI.NewNetExp_ThresholdHS);
			}
			else
			{
				LF.PingDT = M.ClientTimeStamp - ClientTimeStamp + 1.75*M.AverDT;
			}
			LF.bUseEnhancedNetCode = true;
		}
	}

    ServerStartFire(Mode);
}


simulated function DispatchClientEffect(Vector V, rotator R)
{
    if(Level.NetMode != NM_Client)
        return;
    Spawn(class'LinkProjectile',,,V,R);
}

defaultproperties
{
     FireModeClass(0)=Class'3SPNv3225PIG.NewNet_LinkAltFire'
     FireModeClass(1)=Class'3SPNv3225PIG.NewNet_LinkFire'
}
