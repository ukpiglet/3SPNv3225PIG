// *F* Developed 2013 rejecht <rejecht at outlook dot com>

class DamTypeShattered extends DamageType
	abstract
	HideDropdown
	;

defaultproperties
{
     DeathString="%k shattered %o to pieces"
     FemaleSuicide="%o shattered to pieces"
     MaleSuicide="%o shattered to pieces"
     bArmorStops=False
     bLocationalHit=False
     bAlwaysSevers=True
     bDetonatesGoop=True
     bCausesBlood=False
     bCausedByWorld=True
     DeathOverlayMaterial=Texture'3SPNv3225PIG.textures.Ice'
     DeathOverlayTime=20000.0
     GibPerterbation=1.0
	 bAlwaysGibs = False // Avoids server-side ChunkUp, catch it through PlayDying client-side and use a separate function to spawn shattered effect.
}
