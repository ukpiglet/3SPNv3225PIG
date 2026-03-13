class Menu_TabNewMisc extends UT2k3TabPanel;

var automated moComboBox cb_HudTypeCombo;
var automated moNumericEdit nu_MaxHUDPlayerCount;
var automated moCheckBox ch_ComboCheck, ch_DeathsCheck, ch_ExtendCheck, ch_MatchCheck, ch_TeamCheck, ch_DirectionFromView, ch_ShowOnlyFrozen, ch_ShowWithAdren, ch_ShowLiveTeammates;
var automated GUISectionBackground sb_SectionHUD, sb_SectionNet, sb_SectionSound, sb_SectionCombo;
var automated moCheckBox ch_EnableEnhancedNetCode, ch_DisableOwnFootsteps, ch_AutoScreenShot, ch_DisableSpeed, ch_DisableBooster, ch_DisableBerserk, ch_DisableInvis;
var automated moCheckBox ch_PlayOwnLandings, ch_DisableEndCeremonySound, ch_UseHitSounds, ch_AutoSyncSettings;
var automated moSlider sl_SoundHitVolume, sl_SoundAloneVolume;
var automated moComboBox cb_NewClientReplication, cb_NetUpdateRate;

//Buttons
var automated GUIButton btn_LoadSettingsButton, btn_SaveSettingsButton, btn_TimeoutButton;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local TAM_GRI GRI;

	Super.InitComponent(MyController, MyOwner);

	GRI = TAM_GRI(PlayerOwner().Level.GRI);

// HUD
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

	sb_SectionHUD.ManageComponent(ch_TeamCheck);
	sb_SectionHUD.ManageComponent(ch_ExtendCheck);
	sb_SectionHUD.ManageComponent(cb_HudTypeCombo);
	sb_SectionHUD.ManageComponent(ch_DeathsCheck);
	sb_SectionHUD.ManageComponent(ch_ComboCheck);
	sb_SectionHUD.ManageComponent(ch_MatchCheck);
	sb_SectionHUD.ManageComponent(nu_MaxHUDPlayerCount);
	sb_SectionHUD.ManageComponent(ch_DirectionFromView);
	sb_SectionHUD.ManageComponent(ch_ShowLiveTeammates);
	sb_SectionHUD.ManageComponent(ch_ShowOnlyFrozen);
	sb_SectionHUD.ManageComponent(ch_ShowWithAdren);
	
	if (!class'Freon_Player'.default.bShowOnlyFrozen)
		DisableComponent(ch_ShowWithAdren);

// Net
	ch_EnableEnhancedNetCode.SetComponentValue(class'Misc_Player'.default.bEnableEnhancedNetCode,true);

	cb_NewClientReplication.AddItem("Default");
	cb_NewClientReplication.AddItem("Adjustable");
	cb_NewClientReplication.ReadOnly(True);

	cb_NetUpdateRate.AddItem("Minimum Rate");
	cb_NetUpdateRate.AddItem("Medium Rate");
	cb_NetUpdateRate.AddItem("Maximum Rate");
	cb_NetUpdateRate.ReadOnly(True);

	if( class'Misc_Player'.default.NewClientReplication )
	{
		cb_NewClientReplication.SetIndex(1);
	}
	else
	{
		cb_NewClientReplication.SetIndex(0);
		cb_NetUpdateRate.DisableMe();
	}

	cb_NetUpdateRate.SetIndex(class'Misc_Player'.default.ClientReplRateBehavior);

	sb_SectionNet.ManageComponent(ch_EnableEnhancedNetCode);
	sb_SectionNet.ManageComponent(cb_NewClientReplication);
	sb_SectionNet.ManageComponent(cb_NetUpdateRate);

// Net/Misc
	ch_AutoSyncSettings.SetComponentValue(class'Misc_Player'.default.AutoSyncSettings,true);
	ch_AutoScreenShot.SetComponentValue(class'Misc_Player'.default.bAutoScreenShot,true);

	sb_SectionNet.ManageComponent(ch_AutoScreenShot);
	sb_SectionNet.ManageComponent(ch_AutoSyncSettings);

// Combo
	ch_DisableSpeed.SetComponentValue(class'Misc_Player'.default.bDisableSpeed,true);
	ch_DisableBooster.SetComponentValue(class'Misc_Player'.default.bDisableBooster,true);
	ch_DisableBerserk.SetComponentValue(class'Misc_Player'.default.bDisableBerserk,true);
	ch_DisableInvis.SetComponentValue(class'Misc_Player'.default.bDisableInvis,true);

	sb_SectionCombo.ManageComponent(ch_DisableSpeed);
	sb_SectionCombo.ManageComponent(ch_DisableBooster);
	sb_SectionCombo.ManageComponent(ch_DisableBerserk);
	sb_SectionCombo.ManageComponent(ch_DisableInvis);

// Sound
	ch_DisableOwnFootsteps.SetComponentValue(!class'Misc_Pawn'.default.bPlayOwnFootsteps,true);
	ch_PlayOwnLandings.SetComponentValue(class'Misc_Pawn'.default.bPlayOwnLandings,true);
	ch_DisableEndCeremonySound.SetComponentValue(class'Misc_Player'.default.bDisableEndCeremonySound,true);
	ch_UseHitSounds.SetComponentValue(!class'Misc_Player'.default.bUseHitSounds,true);
	sl_SoundHitVolume.SetComponentValue(class'Misc_Player'.default.SoundHitVolume, true);
	sl_SoundAloneVolume.SetComponentValue(class'Misc_Player'.default.SoundAloneVolume, true);

	if( class'Misc_Player'.default.bUseHitSounds == false)
		sl_SoundHitVolume.DisableMe();

	sb_SectionSound.ManageComponent(ch_DisableOwnFootsteps);
	sb_SectionSound.ManageComponent(ch_PlayOwnLandings);
	sb_SectionSound.ManageComponent(ch_DisableEndCeremonySound);
	sb_SectionSound.ManageComponent(ch_UseHitSounds);
	sb_SectionSound.ManageComponent(sl_SoundHitVolume);
	sb_SectionSound.ManageComponent(sl_SoundAloneVolume);

// Buttons
	if(GRI != None)
	{
		if(GRI.TimeOuts == 0 && !PlayerOwner().PlayerReplicationInfo.bAdmin)
			 btn_TimeoutButton.DisableMe();

		if(!GRI.EnableNewNet)
			ch_EnableEnhancedNetCode.DisableMe();

		if(!GRI.UTComp_MoveRep)
		{
			cb_NetUpdateRate.DisableMe();
			cb_NewClientReplication.DisableMe();
		}
	}
	else
	{
		btn_TimeoutButton.DisableMe();
	}
}

function bool OnClick(GUIComponent C)
{
	if(C == btn_TimeoutButton) // Attempt TimeOut
	{
		Misc_Player(PlayerOwner()).CallTimeout();
		Controller.CloseMenu();
	}
	else if(C == btn_LoadSettingsButton) // Load Settings
	{
		Misc_Player(PlayerOwner()).LoadSettings();
		Controller.CloseMenu();
	}
	else if(C == btn_SaveSettingsButton) // Save Settings
	{
		Misc_Player(PlayerOwner()).SaveSettings();
		Controller.CloseMenu();
	}

	return true;
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

		case ch_EnableEnhancedNetCode:
			class'Misc_Player'.default.bEnableEnhancedNetCode = ch_EnableEnhancedNetCode.IsChecked();
			break;

		case ch_DisableOwnFootsteps:
			class'Misc_Pawn'.default.bPlayOwnFootsteps = !ch_DisableOwnFootsteps.IsChecked();
			break;

		case ch_AutoScreenShot:
			class'Misc_Player'.default.bAutoScreenShot = ch_AutoScreenShot.IsChecked();
			break;

		case ch_DisableSpeed:
			class'Misc_Player'.default.bDisableSpeed = ch_DisableSpeed.IsChecked();
			break;

		case ch_DisableBooster:
			class'Misc_Player'.default.bDisableBooster = ch_DisableBooster.IsChecked();
			break;

		case ch_DisableBerserk:
			class'Misc_Player'.default.bDisableBerserk = ch_DisableBerserk.IsChecked();
			break;

		case ch_DisableInvis:
			class'Misc_Player'.default.bDisableInvis = ch_DisableInvis.IsChecked();
			break;

		case ch_PlayOwnLandings:
			class'Misc_Pawn'.default.bPlayOwnLandings = ch_PlayOwnLandings.IsChecked();
			break;

		case ch_DisableEndCeremonySound:
			class'Misc_Player'.default.bDisableEndCeremonySound = ch_DisableEndCeremonySound.IsChecked();
			break;

		case ch_UseHitSounds:
			class'Misc_Player'.default.bUseHitSounds = !ch_UseHitSounds.IsChecked();
			if( class'Misc_Player'.default.bUseHitSounds)
				sl_SoundHitVolume.EnableMe();
			else
				sl_SoundHitVolume.DisableMe();
			break;

		case sl_SoundHitVolume:
			class'Misc_Player'.default.SoundHitVolume = sl_SoundHitVolume.GetValue();
			break;

		case sl_SoundAloneVolume:
			class'Misc_Player'.default.SoundAloneVolume = sl_SoundAloneVolume.GetValue();
			break;

		case ch_AutoSyncSettings:
			class'Misc_Player'.default.AutoSyncSettings = ch_AutoSyncSettings.IsChecked();
			break;

		case cb_NewClientReplication:
			if( cb_NewClientReplication.GetIndex() == 0)
			{
				class'Misc_Player'.default.NewClientReplication = False;
				cb_NetUpdateRate.DisableMe();
			}
			else
			{
				cb_NetUpdateRate.EnableMe();
				class'Misc_Player'.default.NewClientReplication = True;
			}
			break;

		case cb_NetUpdateRate:
			class'Misc_Player'.default.ClientReplRateBehavior = cb_NetUpdateRate.GetIndex();
			Misc_Player(PlayerOwner()).SetNetUpdateRate(cb_NetUpdateRate.GetIndex());
			break;

	}

	class'Misc_Player'.default.bHUDChanged = True; // not necessarily true - but it doesn't hurt to let it recalculate stuff for one frame!

	Misc_Player(PlayerOwner()).SetupCombos();
	Misc_Player(PlayerOwner()).ReloadDefaults();
	class'Freon_Player'.Static.StaticSaveConfig();
	class'Misc_Pawn'.Static.StaticSaveConfig();
	class'Menu_Menu3SPN'.default.SettingsDirty = true;
}


defaultproperties
{
	Begin Object class=GUISectionBackground Name=sbSectionHud
		WinWidth=0.36
		WinHeight=0.937239
		WinLeft=0.000948
		WinTop=0.012761
		Caption="Hud:"
		RenderWeight=0.01
	End Object
	sb_SectionHUD=sbSectionHud

	Begin Object class=GUISectionBackground Name=sbSectionNet
		WinLeft=0.37
		WinWidth=0.3
		WinHeight=0.53
		WinTop=0.012761
		Caption="Net/Misc:"
		RenderWeight=0.01
	End Object
	sb_SectionNet=sbSectionNet

	Begin Object class=GUISectionBackground Name=sbSectionCombo
		WinLeft=0.68
		WinWidth=0.3
		WinHeight=0.53
		WinTop=0.012761
		Caption="Combo:"
		RenderWeight=0.01
	End Object
	sb_SectionCombo=sbSectionCombo

	Begin Object class=GUISectionBackground Name=sbSectionSound
		WinLeft=0.37
		WinWidth=0.61
		WinHeight=0.394478
		WinTop=0.555522
		Caption="Sound & Misc Config:"
		RenderWeight=0.01
	End Object
	sb_SectionSound=sbSectionSound

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
		Hint="Match HUD color to brightskins."
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
		Caption="... and teammates with adrenaline:"
		Hint="In Freon, when checked, also show players with 100+ adrenaline."
		OnChange=InternalOnChange
		TabOrder=11
	End Object
	ch_ShowWithAdren=ShowWithAdren

// Net Things
	Begin Object Class=moCheckBox Name=EnableEnhancedNetCode
		Caption="Enhanced NetCode:"
		Hint="Enhanced NetCode - sometimes known as Ping Compensation."
		OnChange=InternalOnChange
		TabOrder=12
	End Object
	ch_EnableEnhancedNetCode=EnableEnhancedNetCode

	Begin Object Class=moComboBox Name=NewClientReplication
		Caption="Client Tickrate:"
		Hint="Adjustable allows you to set higher net update rates, and includes the eyeheight fix."
		OnChange=InternalOnChange
		TabOrder=13
	End Object
	cb_NewClientReplication=NewClientReplication

	Begin Object Class=moComboBox Name=NetUpdateRate
		Caption="Net Update Rate:"
		Hint="Configures NetUpdateRate. Minimum is MinNetUpdateRate. Medium is half way between. Maximum is MaxNetUpdateRate."
		OnChange=InternalOnChange
		TabOrder=14
	End Object
	cb_NetUpdateRate=NetUpdateRate

	Begin Object Class=moCheckBox Name=AutoScreenShot
		Caption="Take End-game Screenshot:"
		Hint="Take End-game Screenshot at end of each map."
		OnChange=InternalOnChange
		TabOrder=15
	End Object
	ch_AutoScreenShot=AutoScreenShot

	Begin Object Class=moCheckBox Name=AutoSyncSettings
		Caption="Sync Settings With Server:"
		Hint="Sync Settings With Server."
		OnChange=InternalOnChange
		TabOrder=16
	End Object
	ch_AutoSyncSettings=AutoSyncSettings

// Combo things
	Begin Object Class=moCheckBox Name=DisableSpeed
		Caption="Disable Speed:"
		Hint="Disable Speed combo."
		OnChange=InternalOnChange
		TabOrder=17
	End Object
	ch_DisableSpeed=DisableSpeed

	Begin Object Class=moCheckBox Name=DisableBooster
		Caption="Disable Booster:"
		Hint="Disable Booster combo."
		OnChange=InternalOnChange
		TabOrder=18
	End Object
	ch_DisableBooster=DisableBooster

	Begin Object Class=moCheckBox Name=DisableBerserk
		Caption="Disable Berserk:"
		Hint="Disable Berserk combo."
		OnChange=InternalOnChange
		TabOrder=19
	End Object
	ch_DisableBerserk=DisableBerserk

	Begin Object Class=moCheckBox Name=DisableInvis
		Caption="Disable Invisibility:"
		Hint="Disable Invisibility combo."
		OnChange=InternalOnChange
		TabOrder=20
	End Object
	ch_DisableInvis=DisableInvis

// Sound things
	Begin Object Class=moCheckBox Name=DisableOwnFootsteps
		Caption="Disable Own Footsteps:"
		Hint="Disable Own Footsteps."
		OnChange=InternalOnChange
		TabOrder=21
	End Object
	ch_DisableOwnFootsteps=DisableOwnFootsteps

	Begin Object Class=moCheckBox Name=PlayOwnLandings
		Caption="Play Own Landing Sounds:"
		Hint="Play Own Landing Sounds."
		OnChange=InternalOnChange
		TabOrder=22
	End Object
	ch_PlayOwnLandings=PlayOwnLandings

	Begin Object Class=moCheckBox Name=DisableEndCeremonySound
		Caption="Disable End Ceremony Sounds:"
		Hint="Disable End Ceremony Sounds."
		OnChange=InternalOnChange
		TabOrder=23
	End Object
	ch_DisableEndCeremonySound=DisableEndCeremonySound

	Begin Object Class=moCheckBox Name=UseHitSounds
		Caption="Disable Hitsounds:"
		Hint="Disable Hitsounds."
		OnChange=InternalOnChange
		TabOrder=24
	End Object
	ch_UseHitSounds=UseHitSounds

	Begin Object Class=moSlider Name=SoundHitVolume
		Caption="HitSound Volume:"
		Hint="HitSound Volume."
		MaxValue=2
		OnChange=InternalOnChange
		TabOrder=25
	End Object
	sl_SoundHitVolume=SoundHitVolume

	Begin Object Class=moSlider Name=SoundAloneVolume
		Caption="Alone Volume:"
		Hint="Alone Volume."
		MaxValue=2
		OnChange=InternalOnChange
		TabOrder=26
	End Object
	sl_SoundAloneVolume=SoundAloneVolume

// Buttons
	Begin Object Class=GUIButton Name=LoadSettingsButton
		Caption="Load Settings"
		StyleName="SquareMenuButton"
		WinTop=0.955000
		WinLeft=0.050000
		WinWidth=0.250000
		WinHeight=0.080000
		OnClick=OnClick
		TabOrder=27
	End Object
	btn_LoadSettingsButton=LoadSettingsButton

	Begin Object Class=GUIButton Name=SaveSettingsButton
		Caption="Save Settings"
		StyleName="SquareMenuButton"
		WinTop=0.955000
		WinLeft=0.300000
		WinWidth=0.250000
		WinHeight=0.080000
		OnClick=OnClick
		TabOrder=28
	End Object
	btn_SaveSettingsButton=SaveSettingsButton

	Begin Object Class=GUIButton Name=TimeoutButton
		Caption="Attempt Timeout"
		StyleName="SquareMenuButton"
		WinTop=0.955000
		WinLeft=0.550000
		WinWidth=0.400000
		WinHeight=0.080000
		OnClick=OnClick
		TabOrder=29
	End Object
	btn_TimeoutButton=TimeoutButton
}
