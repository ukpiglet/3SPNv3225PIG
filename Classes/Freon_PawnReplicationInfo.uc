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
    NetUpdateFrequency = default.NetUpdateFrequency * 0.5;
    NetPriority = default.NetPriority * 0.5;
    NetUpdateTime = Level.TimeSeconds - 5;
    SetTimer(0.4, true);
}

event Timer()
{
    Super.Timer();

    if(Freon_Pawn(MyPawn) != None){
        bFrozen = Freon_Pawn(MyPawn).bFrozen;
		if (Freon(Level.Game).SelfKillThawScale != 1){
			bKilledSelf = Freon_Pawn(MyPawn).LastKiller == MyPawn.Controller;
		}
		else{
			bKilledSelf = False;
		}
		
		if (!Freon(Level.Game).bAllowSelfKillThaw && bKilledSelf){
			bLavaSafe = (Level.TimeSeconds - Freon_Pawn(MyPawn).TimeKilled > Freon(Level.Game).SelfKillLavaThawtime);
		}
	}
}

defaultproperties
{
}
