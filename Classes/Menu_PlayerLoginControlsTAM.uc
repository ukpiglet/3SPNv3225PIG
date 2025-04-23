class Menu_PlayerLoginControlsTAM extends UT2K4Tab_PlayerLoginControls;

var array<name> MenuCommand;

function bool InternalOnPreDraw(Canvas C)
{
	local GameReplicationInfo GRI;

	GRI = GetGRI();
	if (GRI != None)
	{
		if (bInit)
			InitGRI();

		if ( bTeamGame )
		{
			if ( GRI.Teams[0] != None )
				sb_Red.Caption = RedTeam@string(int(GRI.Teams[0].Score));

			if ( GRI.Teams[1] != None )
				sb_Blue.Caption = BlueTeam@string(int(GRI.Teams[1].Score));

			if (PlayerOwner().PlayerReplicationInfo.Team != None)
			{
				if (PlayerOwner().PlayerReplicationInfo.Team.TeamIndex == 0)
				{
					sb_Red.HeaderBase = texture'Display95';
					sb_Blue.HeaderBase = sb_blue.default.headerbase;
				}
				else
				{
					sb_Blue.HeaderBase = texture'Display95';
					sb_Red.HeaderBase = sb_blue.default.headerbase;
				}
			}
		}

		SetButtonPositions(C);
		UpdatePlayerLists();

		if ( ((PlayerOwner().myHUD == None) || !PlayerOwner().myHUD.IsInCinematic()) /*&& GRI.bMatchHasBegun*/ /*&& !PlayerOwner().IsInState('GameEnded')*/ && (GRI.MaxLives <= 0 || !PlayerOwner().PlayerReplicationInfo.bOnlySpectator) )
			EnableComponent(b_Spec);
		else
			DisableComponent(b_Spec);
	}

	return false;
}


function bool ContextMenuOpened( GUIContextMenu Menu )
{
    local GUIList List;
    local PlayerReplicationInfo PRI;
    local GameReplicationInfo GRI;
    local bool bIsAdmin;
    local bool bReturn;
    local int i;

    Menu.ContextItems.Length = 0;
    MenuCommand.Length = 0;
    bReturn = Super.ContextMenuOpened(Menu);

    PRI = PlayerOwner().PlayerReplicationInfo;
    bIsAdmin = PRI.bAdmin;

    GRI = GetGRI();
    if (GRI == None)
        return false;

    List = GUIList(Controller.ActiveControl);
    if (List == None || !List.IsValid() )
        return false;

    PRI = GRI.FindPlayerByID( int(List.GetExtra()) );
    if (PRI == None)
        return false;

    i = Menu.ContextItems.Length;

    if (bIsAdmin)
    {
            Menu.ContextItems[i++] = "-";
            Menu.ContextItems[i] = "Force use resurrect "$"["$List.Get()$"]";
            MenuCommand[i++] = 'ForceRes';
			Menu.ContextItems[i] = "Make spectator "$"["$List.Get()$"]";
            MenuCommand[i++] = 'Spectate';
    }

    return true;
}

function ContextClick(GUIContextMenu Menu, int ClickIndex)
{
    local GUIList List;
    local PlayerReplicationInfo PRI;
    local GameReplicationInfo GRI;
    local PlayerController PC;

    if (MenuCommand[ClickIndex] == '')
    {
        Super.ContextClick(Menu, ClickIndex);
        return;
    }

    GRI = GetGRI();
    if (GRI == None)
        return;

    List = GUIList(Controller.ActiveControl);
    if (List == None)
        return;

    PRI = GRI.FindPlayerById( int(List.GetExtra()) );
    if (PRI == None)
        return;

    PC = PlayerOwner();

    switch (MenuCommand[ClickIndex])
    {
        case 'ForceRes':
            PC.Admin("forceres"@List.GetExtra());
            break;
		case 'Spectate':
            PC.Admin("makespec"@List.GetExtra());
            break;
			
    }
}

defaultproperties
{
}
