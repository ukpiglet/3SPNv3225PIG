class Freon_Bot extends Misc_Bot;

var Freon_Pawn FrozenPawn;

function WasKilledBy(Controller Other)
{
//Fixed: If bot killed while frozen Pawn = None
	local Controller C;
	local Pawn P;
	
	if (Pawn != None)
		P = Pawn;
	else
		P = FrozenPawn;

	if ( P.bUpdateEyeHeight )
	{
		for ( C=Level.ControllerList; C!=None; C=C.NextController )
			if ( C.IsA('PlayerController') && (PlayerController(C).ViewTarget == P) && (PlayerController(C).RealViewTarget == None) )
				PlayerController(C).ViewNextBot();
	}
	if ( (Other != None) && (Other.Pawn != None) )
		LastKillerPosition = Other.Pawn.Location;
}

//Otherwise:    Freon_Bot DM-UCMP-Contrast-SE_Beta2.Freon_Bot (Function UnrealGame.Bot.NotifyPhysicsVolumeChange:0084) Accessed None 'Pawn'
function bool NotifyPhysicsVolumeChange (PhysicsVolume NewVolume)
{
  if ( Pawn == None )
    return False;
  else
	return Super.NotifyPhysicsVolumeChange(NewVolume);
}

function Reset()
{
    Super.Reset();
    FrozenPawn = None;
}

function SetPawnClass(string inClass, string inCharacter)
{
	local class<Freon_Pawn> pClass;

	if(inClass != "")
	{
		pClass = class<Freon_Pawn>(DynamicLoadObject(inClass, class'Class'));
		if(pClass != None)
			PawnClass = pClass;
	}

	PawnSetupRecord = class'xUtil'.static.FindPlayerRecord(inCharacter);
	PlayerReplicationInfo.SetCharacterName(inCharacter);
}

function Freeze()
{
    if(Pawn == None)
        return;

    SetLocation(Pawn.Location);
    
    FrozenPawn = Freon_Pawn(Pawn);
    Pawn = None;
    PendingMover = None;

    if(!IsInState('GameEnded') && !IsInState('RoundEnded'))
        GotoState('Frozen');
}

state Dead
{
    function PawnDied(Pawn P) {}
}

state Frozen extends Dead
{
    ignores KilledBy;

    function Actor FaceActor(float StrafingModifier) {return None;}
    function ReceiveProjectileWarning(Projectile P) {}
    function PawnDied(Pawn P) {}
    function bool AdjustAround(Pawn P) {return false;}
    function ServerRestartPlayer() {}
    function ChangedWeapon() {}
    function bool NotifyLanded(vector HitNormal) {return false;}
}

state RestFormation
{
	ignores EnemyNotVisible;

	function CancelCampFor(Controller C)
	{
		if (Pawn != None && C.Pawn != None)  //bug fix
			Super.CancelCampFor(C);
	}
}

function DisplayDebug(Canvas Canvas, out float YL, out float YPos){
	Canvas.DrawText("Piglet DisplayDebug", false);

	YPos += 2*YL;
	super.DisplayDebug(Canvas, YL, YPos);
}

function bool WeaponFireAgain(float RefireRate, bool bFinishedFire)
{
	if (pawn != None)
		return Super.WeaponFireAgain(RefireRate, bFinishedFire);
	else
	{
		StopFiring();
		return false;
	}
}

function bool NeedToTurn(vector targ)
{
	if (pawn != None)
		return Pawn.NeedToTurn(targ);
	else
		return false;
}


defaultproperties
{
     PlayerReplicationInfoClass=Class'3SPNv3225PIG.Freon_PRI'
}
