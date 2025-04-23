class Menu_TabInfo extends UT2k3TabPanel;
#exec TEXTURE IMPORT NAME=freon_guide FILE=Textures\freon_guide.tga GROUP=Textures MIPS=Off ALPHA=1 DXT=5

var automated GUISectionBackground SectionBackg;
var automated GUIScrollTextBox TextBox;
var automated GUIButton InfoButton;
var automated GUIGFXButton InfoButton2;

var Texture TipTex;

var array<string> InfoText;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local Misc_Player MP;
    local TAM_GRI GRI;
    local string Content;

    Super.InitComponent(MyController, MyOwner);

    MP = Misc_Player(PlayerOwner());
    if(MP == None)
        return;
        
    GRI = TAM_GRI(PlayerOwner().Level.GRI);
        
    SectionBackg.ManageComponent(TextBox);
    TextBox.MyScrollText.bNeverFocus=True;
    
    Content = JoinArray(InfoText, TextBox.Separator, True);
    Content = Repl(Content, "[3SPNVersion]", class'Misc_BaseGRI'.default.Version);
    Content = Repl(Content, "[Menu3SPNKey]", class'Interactions'.static.GetFriendlyName(class'Misc_Player'.default.Menu3SPNKey));
    TextBox.SetContent(Content, TextBox.Separator);
}

function bool OnClick(GUIComponent C)
{
    if(C == InfoButton) // More info
    {
		PlayerOwner().ClientTravel("https://miasma.wpengine.com/", TRAVEL_Absolute, false);
		Misc_Player(PlayerOwner()).FindPlayerInput();
    }
		
	return true;
}

delegate OnRender(Canvas C)
{	
	local float x, y, w, h;
	
	x = PageOwner.ActualLeft();
	y = PageOwner.ActualTop();
	w = PageOwner.ActualWidth();
	h = PageOwner.ActualHeight();	
	
	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;
	C.DrawColor.A = 255;
	
	//C.SetOrigin(x+64, y+128);
	//C.SetClip(w,h);
	

	C.SetPos(w-256,h-256);
	C.DrawTile(TipTex, 256,256, 0,0,256,256);

}

defaultproperties
{
     Begin Object Class=AltSectionBackground Name=SectionBackgObj
         bFillClient=True
         LeftPadding=0.000000
         RightPadding=0.000000
         WinHeight=1.000000
         bBoundToParent=True
         bScaleToParent=True
         bNeverFocus=True
         OnPreDraw=SectionBackgObj.InternalPreDraw
         OnRendered=Menu_TabInfo.OnRender
     End Object
     SectionBackg=AltSectionBackground'3SPNv3225PIG.Menu_TabInfo.SectionBackgObj'

     Begin Object Class=GUIScrollTextBox Name=TextBoxObj
         bNoTeletype=True
         Separator="þ"
         OnCreateComponent=TextBoxObj.InternalOnCreateComponent
         FontScale=FNS_Small
         WinTop=0.010000
         WinLeft=0.100000
         WinWidth=0.800000
         WinHeight=0.558333
         bBoundToParent=True
         bScaleToParent=True
         bNeverFocus=True
     End Object
     TextBox=GUIScrollTextBox'3SPNv3225PIG.Menu_TabInfo.TextBoxObj'

     Begin Object Class=GUIButton Name=HowToPlayButton
         Caption="Click: Hints and tips on how to play this version of Freon"
         StyleName="SquareMenuButton"
         WinTop=0.955000
         WinLeft=0.050000
         WinWidth=0.600000
         WinHeight=0.080000
         OnClick=Menu_TabInfo.OnClick
         OnKeyEvent=HowToPlayButton.InternalOnKeyEvent
     End Object
     InfoButton=GUIButton'3SPNv3225PIG.Menu_TabInfo.HowToPlayButton'

     TipTex=Texture'3SPNv3225PIG.textures.freon_guide'
     InfoText(0)="Greetings!"
     InfoText(1)="======="
     InfoText(2)="þ"
     InfoText(3)="This seems to be the first time you are running 3SPN [3SPNVersion], please take a moment to update your settings!"
     InfoText(4)="þ"
     InfoText(5)="NOTE: Your settings have been automatically retrieved from the server if they have been previously saved. Your future settings will be saved on this server automatically and restored on 3SPN updates or UT reinstalls. This behavior can be disabled in the Misc panel. The settings are saved for your PLAYERNAME, so if you change it, you must save the settings again for them to be found later."
     InfoText(6)="þ"
     InfoText(7)="You can always access the 3SPN configuration menu later by pressing [Menu3SPNKey] or typing 'menu3spn' in the console."
     InfoText(8)="þ"
     InfoText(61)="Send bug reports and feedback to ukpiglet@btinternet.com"
     InfoText(68)="þ"
     InfoText(69)="Thanks goes to:"
     InfoText(70)=" "
     InfoText(71)="  * Aaron Everitt and Joel Moffatt for UTComp."
     InfoText(72)="  * Michael Massey, Eric Chavez, Mike Hillard, Len Bradley and Steven Phillips for 3SPN."
     InfoText(73)="  * Shaun Goeppinger for Necro."
     InfoText(74)="  * void at www.combowhore.com for many many enhancements to 3SPN."
     InfoText(75)="  * Beltamaxx for his great ideas, inspiration and encouragement."
     InfoText(76)="  * Attila for code from 3.177AT (mail: attila76i(at)freemail.hu   discord: Attila#3682)"
     InfoText(77)="  * SoL»Lizard, hagis, Rejecht, hackysac and others for code changes/improvements and support."
     InfoText(78)="  * Piglet for bug fixes, enhancements, and voice for some of the announcements."
     InfoText(79)=" "
     InfoText(80)="All without whom these gametypes would not be possible."
     InfoText(81)=" "
     InfoText(82)="Click the button below for more information on this version of freon, hints and tips."
}
