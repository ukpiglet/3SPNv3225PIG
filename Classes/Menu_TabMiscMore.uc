class Menu_TabMiscMore extends UT2k3TabPanel;

var automated moCheckBox EnableWidescreenFixes;
var automated moCheckBox PlayOwnLandings;

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

	class'Menu_Menu3SPN'.default.SettingsDirty = OldDirty;

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
	}
	
    Misc_Player(PlayerOwner()).ReloadDefaults();
    class'Misc_Player'.Static.StaticSaveConfig();	
	class'Menu_Menu3SPN'.default.SettingsDirty = true;
}

defaultproperties
{
	 
    Begin Object Class=moCheckBox Name=WidescreenFixCheck
         Caption="Enable Widescreen fixes:"
         OnCreateComponent=WidescreenFixCheck.InternalOnCreateComponent
         WinTop=0.010000
         WinLeft=0.100000
         WinWidth=0.350000
         OnChange=Menu_TabMiscMore.InternalOnChange
     End Object
     EnableWidescreenFixes=moCheckBox'3SPNv3225PIG.Menu_TabMiscMore.WidescreenFixCheck'
	
     Begin Object Class=moCheckBox Name=PlayOwnLandingsCheckBox
         Caption="Play Own Landing Sounds:"
         OnCreateComponent=PlayOwnLandingsCheckBox.InternalOnCreateComponent
         WinTop=0.055000
         WinLeft=0.100000
         WinWidth=0.350000
         OnChange=Menu_TabMiscMore.InternalOnChange
     End Object
     PlayOwnLandings=moCheckBox'3SPNv3225PIG.Menu_TabMiscMore.PlayOwnLandingsCheckBox'	
 
}
