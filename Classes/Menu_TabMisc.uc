class Menu_TabMisc extends UT2k3TabPanel;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local Misc_Player MP;
    local TAM_GRI GRI;

    Super.InitComponent(MyController, MyOwner);

    MP = Misc_Player(PlayerOwner());
    if(MP == None)
        return;

    GRI = TAM_GRI(PlayerOwner().Level.GRI);
		
    // combos
	moCheckBox(Controls[1]).Checked(class'Misc_Player'.default.bDisableSpeed);
	moCheckBox(Controls[2]).Checked(class'Misc_Player'.default.bDisableBooster);
	moCheckBox(Controls[3]).Checked(class'Misc_Player'.default.bDisableBerserk);
	moCheckBox(Controls[4]).Checked(class'Misc_Player'.default.bDisableInvis);
    // HUD
    moCheckBox(Controls[5]).Checked(class'Misc_Player'.default.bMatchHUDToSkins);
    moCheckBox(Controls[6]).Checked(!class'Misc_Player'.default.bShowTeamInfo);
    moCheckBox(Controls[7]).Checked(!class'Misc_Player'.default.bShowCombos);    
	// hitsounds
	moCheckBox(Controls[8]).Checked(!class'Misc_Player'.default.bUseHitSounds);
    GUISlider(Controls[9]).Value = class'Misc_Player'.default.SoundHitVolume;
	if( class'Misc_Player'.default.bUseHitSounds == false)
		GUISlider(Controls[9]).DisableMe();
		GUILabel(Controls[10]).DisableMe();
    
	// HUD extended
	moCheckBox(Controls[14]).Checked(class'Misc_Player'.default.bExtendedInfo);
    // footsteps - auto screenshot, alone volume
	moCheckBox(Controls[16]).Checked(!class'Misc_Pawn'.default.bPlayOwnFootsteps);
    moCheckBox(Controls[17]).Checked(class'Misc_Player'.default.bAutoScreenShot);
    GUISlider(Controls[18]).Value = class'Misc_Player'.default.SoundAloneVolume;		   
	// Netcode
	moCheckBox(Controls[21]).Checked(class'Misc_Player'.default.bEnableEnhancedNetCode);
	// end ceremony
	moCheckBox(Controls[22]).Checked(class'Misc_Player'.default.bDisableEndCeremonySound);
	// autosave settings
	moCheckBox(Controls[25]).Checked(class'Misc_Player'.default.AutoSyncSettings);

	// radar style
	moComboBox(Controls[27]).AddItem("Use Height Blob Style");
	moComboBox(Controls[27]).AddItem("Use Plus Style");
	moComboBox(Controls[27]).AddItem("Use 'Old Style' Blobs");
	moComboBox(Controls[27]).ReadOnly(True);
	if(class'Misc_Player'.default.bUseOld)
		moComboBox(Controls[27]).SetIndex(2);
	else if(class'Misc_Player'.default.bUsePlus)
		moComboBox(Controls[27]).SetIndex(1);
	else 
		moComboBox(Controls[27]).SetIndex(0);

	// Death messages colour
	moCheckBox(Controls[28]).Checked(class'Misc_Player'.default.bTeamColoredDeathMessages);
	// Movement rep logic
	GUISlider(Controls[29]).Value = class'Misc_Player'.default.ClientReplRateBehavior;
	moComboBox(Controls[30]).AddItem("Default");
	moComboBox(Controls[30]).AddItem("Adjustable");
	moComboBox(Controls[30]).ReadOnly(True);
	if( class'Misc_Player'.default.NewClientReplication )
	{
		moComboBox(Controls[30]).SetIndex(1);
	}
	else
	{
		moComboBox(Controls[30]).SetIndex(0);
		GUISlider(Controls[29]).DisableMe();
	}
	if(GRI != None)
	{
        if(GRI.TimeOuts == 0 && !PlayerOwner().PlayerReplicationInfo.bAdmin)
             GUIButton(Controls[20]).DisableMe();

		if(GRI.EnableNewNet == False)
			moCheckBox(Controls[21]).DisableMe();
					
		if(GRI.UTComp_MoveRep == False)
		{
			GUISlider(Controls[29]).DisableMe();
			moComboBox(Controls[30]).DisableMe();
		}
	}
	else
	{
        GUIButton(Controls[20]).DisableMe();
	}
}

function OnChange(GUIComponent C)
{
    local bool b;
	
    if(moCheckBox(c) != None)
    {
        b = moCheckBox(c).IsChecked();
        if(c == Controls[1])
            class'Misc_Player'.default.bDisableSpeed = b;
        else if(c == Controls[2])
            class'Misc_Player'.default.bDisableBooster = b;
        else if(c == Controls[3])
            class'Misc_Player'.default.bDisableBerserk = b;
        else if(c == Controls[4])
            class'Misc_Player'.default.bDisableInvis = b;
        else if(c == Controls[5])
            class'Misc_Player'.default.bMatchHUDToSkins = b;
        else if(c == Controls[6])
            class'Misc_Player'.default.bShowTeamInfo = !b;
        else if(c == Controls[7])
            class'Misc_Player'.default.bShowCombos = !b;
        else if(c == Controls[14])	
            class'Misc_Player'.default.bExtendedInfo = b;
		else if(c == Controls[28])
            class'Misc_Player'.default.bTeamColoredDeathMessages = b;
        else if(c == Controls[16])
        {
            class'UnrealPawn'.default.bPlayOwnFootsteps = !b;
            class'xPawn'.default.bPlayOwnFootsteps = !b;
            class'Misc_Pawn'.default.bPlayOwnFootsteps = !b;
            class'Misc_Pawn'.static.StaticSaveConfig();

            if(xPawn(PlayerOwner().Pawn) != None)
            {
                xPawn(PlayerOwner().Pawn).bPlayOwnFootsteps = !b;
                xPawn(PlayerOwner().Pawn).SaveConfig();
            }
			
            return;
        }
        else if(c == Controls[17])
            class'Misc_Player'.default.bAutoScreenShot = b;
        else if(c == Controls[8])
        {
            class'Misc_Player'.default.bUseHitSounds = !b;
            if(b)
                GUISlider(Controls[9]).DisableMe();
            else
                GUISlider(Controls[9]).EnableMe();
        }
		else if(c == Controls[21])
		{
			class'Misc_Player'.default.bEnableEnhancedNetCode = b;
			if(!b)
				Misc_Player(PlayerOwner()).SetNetCodeDisabled();
		}	
		else if(c == Controls[22])
			class'Misc_Player'.default.bDisableEndCeremonySound = b;
		else if(c == Controls[25])
			class'Misc_Player'.default.AutoSyncSettings = b;
    }
    else if(GUISlider(c) != None)
    {
        switch(c)
        {
            case Controls[9]:
                class'Misc_Player'.default.SoundHitVolume = GUISlider(c).Value;
				break;

            case Controls[18]:
                class'Misc_Player'.default.SoundAloneVolume = GUISlider(c).Value;
				break;
			
			case Controls[29]:
				class'Misc_Player'.default.ClientReplRateBehavior = GUISlider(c).Value;
				Misc_Player(PlayerOwner()).SetNetUpdateRate(GUISlider(c).Value);
				break;
        }
    }
	else{
	    if(C == Controls[27]){  
			class'Misc_Player'.default.bUsePlus=(moComboBox(Controls[27]).GetIndex()==1); 
			class'Misc_Player'.default.bUseOld=(moComboBox(Controls[27]).GetIndex()==2); 
		}
		if(C == Controls[30])
		{
            if( moComboBox(Controls[30]).GetIndex() == 0)
			{
				class'Misc_Player'.default.NewClientReplication = False;
				GUISlider(Controls[29]).DisableMe();
			}
            else
			{
				GUISlider(Controls[29]).EnableMe();
				class'Misc_Player'.default.NewClientReplication = True;
			}
		}
	}

    Misc_Player(PlayerOwner()).SetupCombos();
	Misc_Player(PlayerOwner()).ReloadDefaults();
	class'Misc_Player'.static.StaticSaveConfig();
	class'Menu_Menu3SPN'.default.SettingsDirty = true;
}

function bool OnClick(GUIComponent C)
{
    if(C == Controls[20]) // Attempt TimeOut
    {
        Misc_Player(PlayerOwner()).CallTimeout();
        Controller.CloseMenu();
    }
	else if(C == Controls[23]) // Load Settings
	{
		Misc_Player(PlayerOwner()).LoadSettings();
        Controller.CloseMenu();
	}
	else if(C == Controls[24]) // Save Settings
	{
		Misc_Player(PlayerOwner()).SaveSettings();
        Controller.CloseMenu();
	}
	
	return true;
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
     Controls(0)=GUIImage'3SPNv3225PIG.Menu_TabMisc.TabBackground'

     Begin Object Class=moCheckBox Name=SpeedCheck
         Caption="Disable Speed."
         OnCreateComponent=SpeedCheck.InternalOnCreateComponent
         Hint="Disables the Speed adrenaline combo if checked."
         WinTop=0.190000
         WinLeft=0.100000
         WinWidth=0.350000
         OnChange=Menu_TabMisc.OnChange
     End Object
     Controls(1)=moCheckBox'3SPNv3225PIG.Menu_TabMisc.SpeedCheck'

     Begin Object Class=moCheckBox Name=BoosterCheck
         Caption="Disable Booster."
         OnCreateComponent=BoosterCheck.InternalOnCreateComponent
         Hint="Disables the Booster adrenaline combo if checked."
         WinTop=0.235000
         WinLeft=0.100000
         WinWidth=0.350000
         OnChange=Menu_TabMisc.OnChange
     End Object
     Controls(2)=moCheckBox'3SPNv3225PIG.Menu_TabMisc.BoosterCheck'

     Begin Object Class=moCheckBox Name=BerserkCheck
         Caption="Disable Berserk."
         OnCreateComponent=BerserkCheck.InternalOnCreateComponent
         Hint="Disables the Berserk adrenaline combo if checked."
         WinTop=0.280000
         WinLeft=0.100000
         WinWidth=0.350000
         OnChange=Menu_TabMisc.OnChange
     End Object
     Controls(3)=moCheckBox'3SPNv3225PIG.Menu_TabMisc.BerserkCheck'

     Begin Object Class=moCheckBox Name=InvisCheck
         Caption="Disable Invisibility."
         OnCreateComponent=InvisCheck.InternalOnCreateComponent
         Hint="Disables the Invisibility adrenaline combo if checked."
         WinTop=0.325000
         WinLeft=0.100000
         WinWidth=0.350000
         OnChange=Menu_TabMisc.OnChange
     End Object
     Controls(4)=moCheckBox'3SPNv3225PIG.Menu_TabMisc.InvisCheck'

     Begin Object Class=moCheckBox Name=MatchCheck
         Caption="Match HUD color to brightskins."
         OnCreateComponent=MatchCheck.InternalOnCreateComponent
         WinTop=0.640000
         WinLeft=0.100000
         WinWidth=0.800000
         OnChange=Menu_TabMisc.OnChange
     End Object
     Controls(5)=moCheckBox'3SPNv3225PIG.Menu_TabMisc.MatchCheck'

     Begin Object Class=moCheckBox Name=TeamCheck
         Caption="Disable Team Info."
         OnCreateComponent=TeamCheck.InternalOnCreateComponent
         Hint="Disables showing team members and enemies on the HUD."
         WinTop=0.415000
         WinLeft=0.100000
         WinWidth=0.800000
         OnChange=Menu_TabMisc.OnChange
     End Object
     Controls(6)=moCheckBox'3SPNv3225PIG.Menu_TabMisc.TeamCheck'

     Begin Object Class=moCheckBox Name=ComboCheck
         Caption="Disable Combo List."
         OnCreateComponent=ComboCheck.InternalOnCreateComponent
         Hint="Disables showing combo info on the lower right portion of the HUD."
         WinTop=0.595000
         WinLeft=0.100000
         WinWidth=0.800000
         OnChange=Menu_TabMisc.OnChange
     End Object
     Controls(7)=moCheckBox'3SPNv3225PIG.Menu_TabMisc.ComboCheck'

     Begin Object Class=moCheckBox Name=HitsoundsCheck
         Caption="Disable Hitsounds."
         OnCreateComponent=HitsoundsCheck.InternalOnCreateComponent
         Hint="Disables damage-dependant hitsounds (the lower the pitch, the greater the damage)."
         WinTop=0.780000
         WinLeft=0.100000
         WinWidth=0.800000
         OnChange=Menu_TabMisc.OnChange
     End Object
     Controls(8)=moCheckBox'3SPNv3225PIG.Menu_TabMisc.HitsoundsCheck'

     Begin Object Class=GUISlider Name=HitVolumeSlider
         MaxValue=2.000000
         WinTop=0.825000
         WinLeft=0.500000
         WinWidth=0.400000
         OnClick=HitVolumeSlider.InternalOnClick
         OnMousePressed=HitVolumeSlider.InternalOnMousePressed
         OnMouseRelease=HitVolumeSlider.InternalOnMouseRelease
         OnChange=Menu_TabMisc.OnChange
         OnKeyEvent=HitVolumeSlider.InternalOnKeyEvent
         OnCapturedMouseMove=HitVolumeSlider.InternalCapturedMouseMove
     End Object
     Controls(9)=GUISlider'3SPNv3225PIG.Menu_TabMisc.HitVolumeSlider'

     Begin Object Class=GUILabel Name=HitVolumeLabel
         Caption="Hitsound Volume:"
         TextColor=(B=255,G=255,R=255)
         WinTop=0.820000
         WinLeft=0.100000
     End Object
     Controls(10)=GUILabel'3SPNv3225PIG.Menu_TabMisc.HitVolumeLabel'

     Begin Object Class=GUILabel Name=HitSoundsLabel
         Caption="Sounds:"
         TextColor=(B=255,G=255,R=255)
         WinTop=0.690000
         WinLeft=0.050000
     End Object
     Controls(11)=GUILabel'3SPNv3225PIG.Menu_TabMisc.HitSoundsLabel'

     Begin Object Class=GUILabel Name=ComboLabel
         Caption="Combos:"
         TextColor=(B=255,G=255,R=255)
         WinTop=0.145000
         WinLeft=0.050000
     End Object
     Controls(12)=GUILabel'3SPNv3225PIG.Menu_TabMisc.ComboLabel'

     Begin Object Class=GUILabel Name=HUDLabel
         Caption="HUD:"
         TextColor=(B=255,G=255,R=255)
         WinTop=0.370000
         WinLeft=0.050000
     End Object
     Controls(13)=GUILabel'3SPNv3225PIG.Menu_TabMisc.HUDLabel'

     Begin Object Class=moCheckBox Name=ExtendCheck
         Caption="Extended Teammate info."
         OnCreateComponent=ExtendCheck.InternalOnCreateComponent
         Hint="Displays extra teammate info; health and location name."
         WinTop=0.460000
         WinLeft=0.100000
         WinWidth=0.800000
         OnChange=Menu_TabMisc.OnChange
     End Object
     Controls(14)=moCheckBox'3SPNv3225PIG.Menu_TabMisc.ExtendCheck'

     Begin Object Class=GUILabel Name=DummyObject
         TextColor=(B=255,G=255,R=255,A=0)
         bVisible=False
     End Object
     Controls(15)=GUILabel'3SPNv3225PIG.Menu_TabMisc.DummyObject'

     Begin Object Class=moCheckBox Name=StepsCheck
         Caption="Disable own footsteps."
         OnCreateComponent=StepsCheck.InternalOnCreateComponent
         WinTop=0.055000
         WinLeft=0.100000
         WinWidth=0.350000
         OnChange=Menu_TabMisc.OnChange
     End Object
     Controls(16)=moCheckBox'3SPNv3225PIG.Menu_TabMisc.StepsCheck'

     Begin Object Class=moCheckBox Name=ShotCheck
         Caption="Take end-game screenshot."
         OnCreateComponent=ShotCheck.InternalOnCreateComponent
         WinTop=0.100000
         WinLeft=0.100000
         WinWidth=0.350000
         OnChange=Menu_TabMisc.OnChange
     End Object
     Controls(17)=moCheckBox'3SPNv3225PIG.Menu_TabMisc.ShotCheck'

     Begin Object Class=GUISlider Name=AloneVolumeSlider
         MaxValue=2.000000
         WinTop=0.865000
         WinLeft=0.500000
         WinWidth=0.400000
         OnClick=AloneVolumeSlider.InternalOnClick
         OnMousePressed=AloneVolumeSlider.InternalOnMousePressed
         OnMouseRelease=AloneVolumeSlider.InternalOnMouseRelease
         OnChange=Menu_TabMisc.OnChange
         OnKeyEvent=AloneVolumeSlider.InternalOnKeyEvent
         OnCapturedMouseMove=AloneVolumeSlider.InternalCapturedMouseMove
     End Object
     Controls(18)=GUISlider'3SPNv3225PIG.Menu_TabMisc.AloneVolumeSlider'

     Begin Object Class=GUILabel Name=AloneVolumeLabel
         Caption="Alone Volume:"
         TextColor=(B=255,G=255,R=255)
         WinTop=0.860000
         WinLeft=0.100000
     End Object
     Controls(19)=GUILabel'3SPNv3225PIG.Menu_TabMisc.AloneVolumeLabel'

     Begin Object Class=GUIButton Name=TimeoutButton
         Caption="Attempt Timeout"
         StyleName="SquareMenuButton"
         WinTop=0.955000
         WinLeft=0.550000
         WinWidth=0.400000
         WinHeight=0.080000
         OnClick=Menu_TabMisc.OnClick
         OnKeyEvent=TimeoutButton.InternalOnKeyEvent
     End Object
     Controls(20)=GUIButton'3SPNv3225PIG.Menu_TabMisc.TimeoutButton'

     Begin Object Class=moCheckBox Name=NewNetCheck
         Caption="Enable Enhanced NetCode."
         OnCreateComponent=NewNetCheck.InternalOnCreateComponent
         WinTop=0.010000
         WinLeft=0.100000
         WinWidth=0.350000
         OnChange=Menu_TabMisc.OnChange
     End Object
     Controls(21)=moCheckBox'3SPNv3225PIG.Menu_TabMisc.NewNetCheck'

     Begin Object Class=moCheckBox Name=CeremonySoundsCheck
         Caption="Disable End Ceremony Sounds."
         OnCreateComponent=CeremonySoundsCheck.InternalOnCreateComponent
         Hint="Disables end ceremony sounds."
         WinTop=0.735000
         WinLeft=0.100000
         WinWidth=0.800000
         OnChange=Menu_TabMisc.OnChange
     End Object
     Controls(22)=moCheckBox'3SPNv3225PIG.Menu_TabMisc.CeremonySoundsCheck'

     Begin Object Class=GUIButton Name=LoadSettingsButton
         Caption="Load Settings"
         StyleName="SquareMenuButton"
         WinTop=0.955000
         WinLeft=0.050000
         WinWidth=0.250000
         WinHeight=0.080000
         OnClick=Menu_TabMisc.OnClick
         OnKeyEvent=TimeoutButton.InternalOnKeyEvent
     End Object
     Controls(23)=GUIButton'3SPNv3225PIG.Menu_TabMisc.LoadSettingsButton'

     Begin Object Class=GUIButton Name=SaveSettingsButton
         Caption="Save Settings"
         StyleName="SquareMenuButton"
         WinTop=0.955000
         WinLeft=0.300000
         WinWidth=0.250000
         WinHeight=0.080000
         OnClick=Menu_TabMisc.OnClick
         OnKeyEvent=TimeoutButton.InternalOnKeyEvent
     End Object
     Controls(24)=GUIButton'3SPNv3225PIG.Menu_TabMisc.SaveSettingsButton'

     Begin Object Class=moCheckBox Name=SyncSettingsCheck
         Caption="Sync Settings With The Server Automatically."
         OnCreateComponent=SyncSettingsCheck.InternalOnCreateComponent
         Hint="Sync Settings With The Server Automatically."
         WinTop=0.910000
         WinLeft=0.100000
         WinWidth=0.800000
         OnChange=Menu_TabMisc.OnChange
     End Object
     Controls(25)=moCheckBox'3SPNv3225PIG.Menu_TabMisc.SyncSettingsCheck'

     Begin Object Class=GUILabel Name=RadarLabel
         Caption="Radar Style:"
         TextColor=(B=255,G=255,R=255)
         WinTop=0.495000
         WinLeft=0.100000
     End Object
     Controls(26)=GUILabel'3SPNv3225PIG.Menu_TabMisc.RadarLabel'

     Begin Object Class=moComboBox Name=HudTypeCombo
         OnCreateComponent=HudTypeCombo.InternalOnCreateComponent
         WinTop=0.505000
         WinLeft=0.500000
         WinWidth=0.400000
         OnChange=Menu_TabMisc.OnChange
     End Object
     Controls(27)=moComboBox'3SPNv3225PIG.Menu_TabMisc.HudTypeCombo'

     Begin Object Class=moCheckBox Name=DeathsCheck
         Caption="Team-colored death messages."
         OnCreateComponent=DeathsCheck.InternalOnCreateComponent
         Hint="Colors player names in death messages based on team."
         WinTop=0.550000
         WinLeft=0.100000
         WinWidth=0.800000
         OnChange=Menu_TabMisc.OnChange
     End Object
     Controls(28)=moCheckBox'3SPNv3225PIG.Menu_TabMisc.DeathsCheck'
	 
Begin Object Class=GUISlider Name=NetUpdateRateSlider
		 Hint="Left to Right from lowest to max rate (equal to your FPS), middle is required for 250+ fps"
         WinTop=0.055000
         WinLeft=0.700000
         WinWidth=0.200000
		 MinValue=0
		 MaxValue=2
		 bIntSlider=true
		 bShowValueTooltip=True
         OnChange=Menu_TabMisc.OnChange
		 OnClick=NetUpdateRateSlider.InternalOnClick
         OnMousePressed=NetUpdateRateSlider.InternalOnMousePressed
         OnMouseRelease=NetUpdateRateSlider.InternalOnMouseRelease
         OnKeyEvent=NetUpdateRateSlider.InternalOnKeyEvent
         OnCapturedMouseMove=NetUpdateRateSlider.InternalCapturedMouseMove
     End Object
     Controls(29)=GUISlider'3SPNv3225PIG.Menu_TabMisc.NetUpdateRateSlider'

	 Begin Object Class=moComboBox Name=ReplBehaviourCombo
         Caption="Client tickrate:"
		 Hint="Adjustable allows you to set higher rates and includes the eyeheight fix"
         OnCreateComponent=ReplBehaviourCombo.InternalOnCreateComponent
         WinTop=0.010000
         WinLeft=0.500000
         WinWidth=0.400000
         OnChange=Menu_TabMisc.OnChange
     End Object
     Controls(30)=moComboBox'3SPNv3225PIG.Menu_TabMisc.ReplBehaviourCombo' 

}
