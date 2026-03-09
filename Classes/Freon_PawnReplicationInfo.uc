class Freon_PawnReplicationInfo extends Misc_PawnReplicationInfo;

var bool bFrozen;
var bool bKilledSelf;
var bool bLavaSafe;

replication
{
    unreliable if(bNetDirty && Role == ROLE_Authority)
        bFrozen, bKilledSelf, bLavaSafe;
}

function SetMyPawn(xPawn P)
{
    if(Freon_Pawn(P) != None)
        bFrozen = Freon_Pawn(P).bFrozen;
    else
        bFrozen = false;

    Super.SetMyPawn(P);
}

function PawnFroze()
{
    bFrozen = true;
    //NetUpdateFrequency = default.NetUpdateFrequency * 0.5;
    //NetPriority = default.NetPriority * 0.5;
    NetUpdateTime = Level.TimeSeconds - 5;
    SetTimer(0.4, true);
}

event Timer()
{
	local Freon_Pawn FP;
	local Freon F;
    Super.Timer();

    FP = Freon_Pawn(MyPawn);
	F = Freon(Level.Game);
	if(FP != None){
        bFrozen = FP.bFrozen;
		if (F.SelfKillThawScale != 1){
			bKilledSelf = FP.LastKiller == MyPawn.Controller;
		}
		else{
			bKilledSelf = False;
		}
		
		if (!F.bAllowSelfKillThaw && bKilledSelf){
			bLavaSafe = (Level.TimeSeconds - FP.TimeKilled > F.SelfKillLavaThawtime);
		}
	}
}

defaultproperties
{
}
