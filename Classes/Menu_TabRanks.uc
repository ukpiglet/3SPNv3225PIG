class Menu_TabRanks extends UT2k3TabPanel;

var automated AltSectionBackground BackG;
var automated GUIVertScrollBar ScrollBar;

var Texture RankTex[30];
var string RankTitle[30];
var int Offset;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);
	
	ScrollBar.ItemCount=30;
}

delegate PositionChanged(int NewPos)
{
	Offset = NewPos;
}

delegate OnRender(Canvas C)
{	
	local int i;
	local float x, y, w, h;
	local float iconY;
	
	x = PageOwner.ActualLeft();
	y = PageOwner.ActualTop();
	w = PageOwner.ActualWidth();
	h = PageOwner.ActualHeight();	
	
	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;
	C.DrawColor.A = 255;
	
	C.SetOrigin(x+64, y+128);
	C.SetClip(w,h);
	
	iconY = 0;
	
	for(i=0; i<30; ++i)
	{		
		if(Offset>i)
			continue;
			
		C.SetPos(0,iconY);
		C.DrawTile(RankTex[i], 64,64, 0,0,64,64);
		C.SetPos(128,iconY);
		C.DrawText(RankTitle[i]);
		
		iconY += 64;
		
		if(C.OrgY+iconY+32 >= C.ClipY)
			break;
	}
}

defaultproperties
{
     Begin Object Class=AltSectionBackground Name=BackGObj
         bFillClient=True
         Caption="Ranks Legend"
         LeftPadding=0.000000
         RightPadding=0.000000
         WinHeight=1.000000
         OnPreDraw=BackGObj.InternalPreDraw
         OnRendered=Menu_TabRanks.OnRender
     End Object
     BackG=AltSectionBackground'3SPNv3225PIG.Menu_TabRanks.BackGObj'

     Begin Object Class=GUIVertScrollBar Name=ScrollBarObj
         ItemsPerPage=5
         PositionChanged=Menu_TabRanks.PositionChanged
         WinTop=0.050000
         WinLeft=0.955000
         WinWidth=0.035000
         WinHeight=0.900000
         OnPreDraw=ScrollBarObj.GripPreDraw
     End Object
     ScrollBar=GUIVertScrollBar'3SPNv3225PIG.Menu_TabRanks.ScrollBarObj'

     RankTex(0)=Texture'3SPNv3225PIG.textures.Rank1'
     RankTex(1)=Texture'3SPNv3225PIG.textures.Rank2'
     RankTex(2)=Texture'3SPNv3225PIG.textures.Rank3'
     RankTex(3)=Texture'3SPNv3225PIG.textures.Rank4'
     RankTex(4)=Texture'3SPNv3225PIG.textures.Rank5'
     RankTex(5)=Texture'3SPNv3225PIG.textures.Rank6'
     RankTex(6)=Texture'3SPNv3225PIG.textures.Rank7'
     RankTex(7)=Texture'3SPNv3225PIG.textures.Rank8'
     RankTex(8)=Texture'3SPNv3225PIG.textures.Rank9'
     RankTex(9)=Texture'3SPNv3225PIG.textures.Rank10'
     RankTex(10)=Texture'3SPNv3225PIG.textures.Rank11'
     RankTex(11)=Texture'3SPNv3225PIG.textures.Rank12'
     RankTex(12)=Texture'3SPNv3225PIG.textures.Rank13'
     RankTex(13)=Texture'3SPNv3225PIG.textures.Rank14'
     RankTex(14)=Texture'3SPNv3225PIG.textures.Rank15'
     RankTex(15)=Texture'3SPNv3225PIG.textures.Rank16'
     RankTex(16)=Texture'3SPNv3225PIG.textures.Rank17'
     RankTex(17)=Texture'3SPNv3225PIG.textures.Rank18'
     RankTex(18)=Texture'3SPNv3225PIG.textures.Rank19'
     RankTex(19)=Texture'3SPNv3225PIG.textures.Rank20'
     RankTex(20)=Texture'3SPNv3225PIG.textures.Rank21'
     RankTex(21)=Texture'3SPNv3225PIG.textures.Rank22'
     RankTex(22)=Texture'3SPNv3225PIG.textures.Rank23'
     RankTex(23)=Texture'3SPNv3225PIG.textures.Rank24'
     RankTex(24)=Texture'3SPNv3225PIG.textures.Rank25'
     RankTex(25)=Texture'3SPNv3225PIG.textures.Rank26'
     RankTex(26)=Texture'3SPNv3225PIG.textures.Rank27'
     RankTex(27)=Texture'3SPNv3225PIG.textures.Rank28'
     RankTex(28)=Texture'3SPNv3225PIG.textures.Rank29'
     RankTex(29)=Texture'3SPNv3225PIG.textures.Rank30'
     RankTitle(0)="1. Recruit"
     RankTitle(1)="2. Private"
     RankTitle(2)="3. Gefreiter"
     RankTitle(3)="4. Corporal"
     RankTitle(4)="5. Master Corporal"
     RankTitle(5)="6. Sergeant"
     RankTitle(6)="7. Staff Sergeant"
     RankTitle(7)="8. Master Sergeant"
     RankTitle(8)="9. First Sergeant"
     RankTitle(9)="10. Sergeant Major"
     RankTitle(10)="11. Warrant Officer 1"
     RankTitle(11)="12. Warrant Officer 2"
     RankTitle(12)="13. Warrant Officer 3"
     RankTitle(13)="14. Warrant Officer 4"
     RankTitle(14)="15. Warrant Officer 5"
     RankTitle(15)="16. Third Lieutenant"
     RankTitle(16)="17. Second Lieutenant"
     RankTitle(17)="18. First Lieutenant"
     RankTitle(18)="19. Captain"
     RankTitle(19)="20. Major"
     RankTitle(20)="21. Lieutenant Colonel"
     RankTitle(21)="22. Colonel"
     RankTitle(22)="23. Brigadier"
     RankTitle(23)="24. Major General"
     RankTitle(24)="25. Lieutenant General"
     RankTitle(25)="26. General"
     RankTitle(26)="27. Marshall"
     RankTitle(27)="28. Field Marshall"
     RankTitle(28)="29. Commander"
     RankTitle(29)="30. Generalissimo"
}
