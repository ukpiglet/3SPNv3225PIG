// Developed 2013 rejecht <rejecht at outlook dot com>

class GibCube extends GibBotHead;

#EXEC TEXTURE IMPORT GROUP=Textures NAME=Ice FILE="Textures\Ice.tga" MIPS=Off ALPHA=0 DXT=3 LODSET=LODSET_PlayerSkin
// #

simulated event SpawnTrail ()
{
}

static function StaticPrecache (LevelInfo LI)
{
	LI.AddPrecacheMaterial (Texture'Ice');
}


// #

defaultproperties
{
     GibGroupClass=Class'3SPNv3225PIG.xFrozenGibGroup'
     TrailClass=Class'3SPNv3225PIG.GibIceEffect'
     LifeSpan=7.000000
     Skins(0)=Texture'3SPNv3225PIG.textures.Ice'
     Mass=130.000000
}
