class Menu_TabHUD extends UT2k3TabPanel;


var GUIImage tb_TabBackground;
var automated moComboBox cb_HudTypeCombo;
var automated moNumericEdit nu_MaxHUDPlayerCount;
var automated moCheckBox ch_ComboCheck, ch_DeathsCheck, ch_ExtendCheck, ch_MatchCheck, ch_TeamCheck, ch_DirectionFromView, ch_ShowOnlyFrozen, ch_ShowWithAdren, ch_ShowLiveTeammates;
var automated GUISectionBackground sb_Section1;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);

    ch_MatchCheck.SetComponentValue(class'Misc_Player'.default.bMatchHUDToSkins,true);
    ch_TeamCheck.SetComponentValue(!class'Misc_Player'.default.bShowTeamInfo,true);
    ch_ComboCheck.SetComponentValue(!class'Misc_Player'.default.bShowCombos,true);  
	ch_ExtendCheck.SetComponentValue(class'Misc_Player'.default.bExtendedInfo,true);
	ch_DirectionFromView.SetComponentValue(class'Freon_Player'.default.bDirectionFromView,true);
	ch_ShowOnlyFrozen.SetComponentValue(class'Freon_Player'.default.bShowOnlyFrozen,true);
	ch_ShowWithAdren.SetComponentValue(class'Freon_Player'.default.bShowWithAdren,true);
	ch_ShowLiveTeammates.SetComponentValue(class'Freon_Player'.default.bShowLiveTeammates,true);
	ch_DeathsCheck.SetComponentValue(class'Misc_Player'.default.bTeamColoredDeathMessages,true);

	nu_MaxHUDPlayerCount.SetComponentValue(class'Misc_Player'.default.MaxHUDPlayerCount);
	
	// radar style
	cb_HudTypeCombo.AddItem("Height Blob");
	cb_HudTypeCombo.AddItem("Plus/Minus");
	cb_HudTypeCombo.AddItem("Slow 'Old Style'");
	cb_HudTypeCombo.ReadOnly(True);
	
	if(class'Misc_Player'.default.bUseOld)
		cb_HudTypeCombo.SetIndex(2);
	else if(class'Misc_Player'.default.bUsePlus)
		cb_HudTypeCombo.SetIndex(1);
	else 
		cb_HudTypeCombo.SetIndex(0);
	
	sb_Section1.ManageComponent(ch_TeamCheck);
	sb_Section1.ManageComponent(ch_ExtendCheck);
	sb_Section1.ManageComponent(cb_HudTypeCombo);
	sb_Section1.ManageComponent(ch_DeathsCheck);
	sb_Section1.ManageComponent(ch_ComboCheck);
	sb_Section1.ManageComponent(ch_MatchCheck);
	sb_Section1.ManageComponent(nu_MaxHUDPlayerCount);
	sb_Section1.ManageComponent(ch_DirectionFromView);
	sb_Section1.ManageComponent(ch_ShowLiveTeammates);
	sb_Section1.ManageComponent(ch_ShowOnlyFrozen);
	sb_Section1.ManageComponent(ch_ShowWithAdren);
		
	if (!class'Freon_Player'.default.bShowOnlyFrozen)
		DisableComponent(ch_ShowWithAdren);
}


function InternalOnChange( GUIComponent C )
{
    Switch(C)
    {	
		case nu_MaxHUDPlayerCount:
			class'Misc_Player'.default.MaxHUDPlayerCount = nu_MaxHUDPlayerCount.GetValue();
			break;
	
		case ch_DirectionFromView:
			class'Freon_Player'.default.bDirectionFromView = ch_DirectionFromView.IsChecked();
			break;
	
		case ch_MatchCheck:
			class'Misc_Player'.default.bMatchHUDToSkins = ch_MatchCheck.IsChecked();
			break;
			
		case ch_TeamCheck:
			class'Misc_Player'.default.bShowTeamInfo = !ch_TeamCheck.IsChecked();
			break;
			
		case ch_ComboCheck:
			class'Misc_Player'.default.bShowCombos = !ch_ComboCheck.IsChecked();
			break;
	
		case ch_ExtendCheck:
			class'Misc_Player'.default.bExtendedInfo = ch_ExtendCheck.IsChecked();
			break;
	
		case ch_DeathsCheck:
			class'Misc_Player'.default.bTeamColoredDeathMessages = ch_DeathsCheck.IsChecked();
			break;
	
		case cb_HudTypeCombo:
			class'Misc_Player'.default.bUsePlus=(cb_HudTypeCombo.GetIndex()==1); 
			class'Misc_Player'.default.bUseOld=(cb_HudTypeCombo.GetIndex()==2); 
			
			break;
			
		case ch_ShowOnlyFrozen:
			class'Freon_Player'.default.bShowOnlyFrozen = ch_ShowOnlyFrozen.IsChecked();
			if (ch_ShowOnlyFrozen.IsChecked())
				EnableComponent(ch_ShowWithAdren);
			else
				DisableComponent(ch_ShowWithAdren);
			break;
		
		case ch_ShowWithAdren:
			class'Freon_Player'.default.bShowWithAdren = ch_ShowWithAdren.IsChecked();
			break;
			
		case ch_ShowLiveTeammates:
			class'Freon_Player'.default.bShowLiveTeammates = ch_ShowLiveTeammates.IsChecked();
			break;
	}
	
	class'Misc_Player'.default.bHUDChanged = True;
	class'Freon_Player'.Static.StaticSaveConfig();	
	class'Menu_Menu3SPN'.default.SettingsDirty = true;
}


defaultproperties
{
	Begin Object Class=GUIImage Name=TabBackground
		Image=Texture'InterfaceContent.Menu.ScoreBoxA'
		ImageColor=(B=0,G=0,R=0)
		ImageStyle=ISTY_Stretched
		WinHeight=1.000000
		bNeverFocus=True
	End Object
	tb_TabBackground=TabBackground;

	Begin Object class=GUISectionBackground Name=sbSection1
		WinWidth=0.49
		WinHeight=0.9
		WinLeft=0.000948
		WinTop=0.012761
		Caption="Hud Config:"
		RenderWeight=0.01
	End Object
	sb_Section1=sbSection1
	
	Begin Object Class=moCheckBox Name=TeamCheck
		Caption="Disable Team Info:"
		Hint="Disables showing team members and enemies on the HUD."
		OnChange=InternalOnChange
		TabOrder=1
	End Object
	ch_TeamCheck=TeamCheck
	
	Begin Object Class=moCheckBox Name=ExtendCheck
		Caption="Extended Teammate info:"
		Hint="Displays extra teammate info; health and location name."
		OnChange=InternalOnChange
		TabOrder=2
	End Object
	ch_ExtendCheck=ExtendCheck

	Begin Object Class=moComboBox Name=HudTypeCombo
		Caption="Radar Style:"
		Hint="Select radar style. 'Old' style is slow."
		OnChange=InternalOnChange
		TabOrder=3
	End Object
	cb_HudTypeCombo=HudTypeCombo		

	Begin Object Class=moCheckBox Name=DeathsCheck
		Caption="Team-colored death messages:"
		Hint="Colors player names in death messages based on team."
		OnChange=InternalOnChange
		TabOrder=4
	End Object
	
	ch_DeathsCheck=DeathsCheck	
	Begin Object Class=moCheckBox Name=ComboCheck
		Caption="Disable Combo List:"
		Hint="Disables showing combo info on the lower right portion of the HUD."
		OnChange=InternalOnChange
		TabOrder=5
	End Object
	ch_ComboCheck=ComboCheck

	Begin Object Class=moCheckBox Name=MatchCheck
		Caption="Match HUD color to brightskins:"
		OnChange=InternalOnChange
		TabOrder=6
	End Object
	ch_MatchCheck=MatchCheck

	Begin Object class=moNumericEdit Name=MaxHUDPlayerCount
		Caption="Max HUD Players:"
		Hint="In Freon, the Max number of players shown each side of HUD."
		MinValue=0
		MaxValue=99
		OnChange=InternalOnChange
		LabelJustification=TXTA_Left
		ComponentJustification=TXTA_Right
		CaptionWidth=0.7
		bAutoSizeCaption=True
		ComponentWidth=0.3
		TabOrder=7
	End Object
	nu_MaxHUDPlayerCount=MaxHUDPlayerCount
	
	Begin Object Class=moCheckBox Name=DirectionFromView
		Caption="Use view direction for radar when frozen:"
		Hint="In Freon, when checked, direction is from view. Otherwise, direction is from frozen player rotation."
		OnChange=InternalOnChange
		TabOrder=8
     End Object
     ch_DirectionFromView=DirectionFromView

	Begin Object Class=moCheckBox Name=ShowLiveTeammates
		Caption="Show count of live teammates:"
		Hint="In Freon, when checked, show count of live teammates."
		OnChange=InternalOnChange
		TabOrder=9
     End Object
     ch_ShowLiveTeammates=ShowLiveTeammates

	Begin Object Class=moCheckBox Name=ShowOnlyFrozen
		Caption="Show only frozen teammates:"
		Hint="In Freon, when checked, show only frozen teammates."
		OnChange=InternalOnChange
		TabOrder=10
     End Object
     ch_ShowOnlyFrozen=ShowOnlyFrozen

	 Begin Object Class=moCheckBox Name=ShowWithAdren
		Caption="...and add in teammates with adren"
		Hint="In Freon, when checked, adds in players with adrenaline."
		OnChange=InternalOnChange
		TabOrder=11
     End Object
     ch_ShowWithAdren=ShowWithAdren
}
