class Menu_TabMiscMore extends UT2k3TabPanel;

var automated moCheckBox EnableWidescreenFixes;
var automated moCheckBox PlayOwnLandings;
//var automated moNumericEdit nu_MaxHUDPlayerCount;
//var automated moCheckBox ch_DirectionFromView;

var automated GUISectionBackground sb_Section1;


function bool AllowOpen(string MenuClass)
{
	if(PlayerOwner()==None || PlayerOwner().PlayerReplicationInfo==None)
		return false;
	return true;
}

event Opened(GUIComponent Sender)
{
	local bool OldDirty;
	OldDirty = class'Menu_Menu3SPN'.default.SettingsDirty;
	super.Opened(Sender);
	class'Menu_Menu3SPN'.default.SettingsDirty = OldDirty;	
}

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local bool OldDirty;

	Super.InitComponent(myController,MyOwner);	 
	 
	OldDirty = class'Menu_Menu3SPN'.default.SettingsDirty;
	
    EnableWidescreenFixes.Checked(class'Misc_Player'.default.bEnableWidescreenFix);
    PlayOwnLandings.Checked(class'Misc_Pawn'.default.bPlayOwnLandings);
	//nu_MaxHUDPlayerCount.SetComponentValue(class'Misc_Player'.default.MaxHUDPlayerCount);
	//ch_DirectionFromView.SetComponentValue(class'Freon_Player'.default.bDirectionFromView,true);
	
	class'Menu_Menu3SPN'.default.SettingsDirty = OldDirty;
	
	sb_Section1.ManageComponent(EnableWidescreenFixes);
	sb_Section1.ManageComponent(PlayOwnLandings);
	//sb_Section1.ManageComponent(nu_MaxHUDPlayerCount);
	//sb_Section1.ManageComponent(ch_DirectionFromView);

}

function InternalOnChange( GUIComponent C )
{
    Switch(C)
    {	

		case EnableWidescreenFixes:
			class'Misc_Player'.default.bEnableWidescreenFix = EnableWidescreenFixes.IsChecked();
			break;

		case PlayOwnLandings:
            class'Misc_Pawn'.default.bPlayOwnLandings = PlayOwnLandings.IsChecked();
            class'Misc_Pawn'.static.StaticSaveConfig();

            if(Misc_Pawn(PlayerOwner().Pawn) != None)
            {
                Misc_Pawn(PlayerOwner().Pawn).bPlayOwnLandings = PlayOwnLandings.IsChecked();
                Misc_Pawn(PlayerOwner().Pawn).SaveConfig();
            }            
			break;
/*
		case nu_MaxHUDPlayerCount:
			class'Misc_Player'.default.MaxHUDPlayerCount = nu_MaxHUDPlayerCount.GetValue();
			class'Misc_Player'.default.bHUDChanged = True;
			break;

		case ch_DirectionFromView:
			class'Freon_Player'.default.bDirectionFromView = ch_DirectionFromView.IsChecked();
			class'Misc_Player'.default.bHUDChanged = True;
			break;
*/
	}
	
    Misc_Player(PlayerOwner()).ReloadDefaults();
    class'Misc_Player'.Static.StaticSaveConfig();	
	class'Menu_Menu3SPN'.default.SettingsDirty = true;
}

defaultproperties
{
	Begin Object class=GUISectionBackground Name=sbSection1
		WinWidth=0.491849
		WinHeight=0.440729
		WinLeft=0.000948
		WinTop=0.012761
        Caption="More Misc"
        RenderWeight=0.01
	End Object
	sb_Section1=sbSection1

    Begin Object Class=moCheckBox Name=WidescreenFixCheck
         Caption="Enable Widescreen fixes:"
		 Hint="(Not useful in patches later than v3369)."
         WinTop=0.010000
         WinLeft=0.100000
         WinWidth=0.350000
		 TabOrder=1
         OnChange=Menu_TabMiscMore.InternalOnChange
     End Object
     EnableWidescreenFixes=WidescreenFixCheck
	
     Begin Object Class=moCheckBox Name=PlayOwnLandingsCheckBox
         Caption="Play Own Landing Sounds:"
         WinTop=0.055000
         WinLeft=0.100000
         WinWidth=0.350000
		 TabOrder=2
         OnChange=Menu_TabMiscMore.InternalOnChange
     End Object
     PlayOwnLandings=PlayOwnLandingsCheckBox
 
 /*
	Begin Object class=moNumericEdit Name=MaxHUDPlayerCount
		WinWidth=0.450000
		WinLeft=0.517383
		WinTop=0.3
		Caption="Max HUD Players:"
		Hint="Max number of players shown each side of HUD."
		MinValue=0
		MaxValue=99
		OnChange=InternalOnChange
		LabelJustification=TXTA_Left
		ComponentJustification=TXTA_Right
		CaptionWidth=0.7
		bAutoSizeCaption=True
		ComponentWidth=0.3
		TabOrder=3
	End Object
	nu_MaxHUDPlayerCount=MaxHUDPlayerCount

     Begin Object Class=moCheckBox Name=DirectionFromView
		Caption="Use view direction on radar when frozen"
		Hint="When checked, direction is from view. Otherwise, direction is from frozen player rotation."
		OnChange=InternalOnChange
     End Object
     ch_DirectionFromView=DirectionFromView
*/
}
