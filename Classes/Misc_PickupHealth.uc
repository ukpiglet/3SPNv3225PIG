class Misc_PickupHealth extends TournamentHealth
    notplaceable;

auto state Pickup
{
	function Touch( actor Other )
	{
		local Pawn P;
		local Team_GameBase T;

		T = Team_GameBase(Level.Game);
		
		if ( ValidTouch(Other) )
		{
			P = Pawn(Other);
            if (T.bEndOfRound || T.EndOfRoundTime > 0 || T.NextRoundTime > 0){
				P.ReceiveLocalizedMessage(class'Message_NoPickup', 3, None, None);
			}
			else{
				if( P.GiveHealth(HealingAmount, GetHealMax(P))){
					AnnouncePickup(P);
					SetRespawn();
				}
				else{
					P.ReceiveLocalizedMessage(class'Message_NoPickup', 0, None, None);
				}
			}
		}
	}
}
	

defaultproperties
{
     HealingAmount=10
     bSuperHeal=True
     MaxDesireability=1.000000
     RespawnTime=33.000000
     PickupSound=Sound'PickupSounds.HealthPack'
     PickupForce="HealthPack"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'3SPNv3225PIG.Question'
     CullDistance=6500.000000
     Physics=PHYS_Rotating
     ScaleGlow=0.600000
     Style=STY_AlphaZ
     TransientSoundVolume=0.350000
     RotationRate=(Yaw=35000)
}
