class Misc_PickupAdren extends AdrenalinePickup
    notplaceable;

#exec STATICMESH IMPORT NAME=Question FILE=StaticMesh\Question.lwo

static function StaticPrecache(LevelInfo L)
{
    L.AddPrecacheStaticMesh(StaticMesh'Question');
}

simulated function UpdatePrecacheStaticMeshes()
{
    Level.AddPrecacheStaticMesh(StaticMesh'Question');
    Super.UpdatePrecacheStaticMeshes();
}

auto state Pickup
{	
	function Touch( actor Other ){
		local Pawn P;
		P = Pawn(Other);
		if (P != None && P.Controller != None){
			if (P.Controller.Adrenaline < Team_GameBase(Level.Game).MaxAdrenaline){
				Super.Touch(Other);
			}
			else {
				P.ReceiveLocalizedMessage(class'Message_NoPickup', 2, None, None);
			}
		}
	}
}

defaultproperties
{
     AdrenalineAmount=10.000000
     MaxDesireability=1.000000
     RespawnTime=33.000000
     PickupForce="HealthPack"
     StaticMesh=StaticMesh'3SPNv3225PIG.Question'
     CullDistance=6500.000000
     DrawScale=1.000000
     TransientSoundVolume=0.350000
     RotationRate=(Yaw=35000)
}
