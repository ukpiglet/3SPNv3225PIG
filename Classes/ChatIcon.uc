class ChatIcon extends Actor;

#exec TEXTURE IMPORT NAME=Red FILE=Textures\Red.tga GROUP=TA MIPS=On ALPHA=1 DXT=5
#exec TEXTURE IMPORT NAME=Blue FILE=Textures\Blue.tga GROUP=TA MIPS=On ALPHA=1 DXT=5
#exec TEXTURE IMPORT NAME=Green FILE=Textures\Green.tga GROUP=TA MIPS=On ALPHA=1 DXT=5

var const Texture RedIcon, BlueIcon, GreenIcon;

function PostBeginPlay()
{
    if(Pawn(Owner) == None)
        return;

    if(Pawn(Owner).GetTeamNum() == 0)
        Texture = RedIcon;
    else if(Pawn(Owner).GetTeamNum() == 1)
        Texture = BlueIcon;
    else
        Texture = GreenIcon;
}


function Tick(float DeltaTime)
{
    if(Pawn(Owner) == None && !bDeleteMe)
        Destroy();
}

defaultproperties
{
     RedIcon=Texture'3SPNv3225PIG.TA.Red'
     BlueIcon=Texture'3SPNv3225PIG.TA.Blue'
     GreenIcon=Texture'3SPNv3225PIG.TA.Green'
     DrawScale=0.500000
     Style=STY_Masked
}
