class WFGameMenuClassMenuWDI extends WFS_WindowDisplayInfo;

// called to setup and display the window (implement in a sub-class)
static function DisplayWindow(WFS_PCSystemPlayer Other, UMenuRootWindow RootWin, WindowConsole WinConsole)
{
	local WFGameMenu Win;
	local int Team;

	Team = Other.PlayerReplicationInfo.Team;

	Win = WFGameMenu(RootWin.CreateWindow(class'WFGameMenu', 0, 0, 100, 100,, True));
	if ((WinConsole.ConsoleWindow != None) && WinConsole.ConsoleWindow.bWindowVisible)
	{
		WinConsole.HideConsole();
		if (WinConsole.bQuickKeyEnable)
			WinConsole.CloseUWindow();
	}

	RootWin.MenuBar.bShowMenu = False;
	RootWin.MenuBar.HideWindow();
	WinConsole.LaunchUWindow();
	Win.bCloseUWindow = true;
	Win.bRestoreMenuBar = true;
	WinConsole.bNoDrawWorld = false;
	Win.InfoPanel.DisplayPage(1);
	Win.InfoPanel.SelectButton(Win.InfoPanel.Button2);
	RootWin.MenuBar.HideWindow();
	Win.FocusWindow();
	if (Other.Level.NetMode == NM_Standalone)
		Other.SetPause(false);
}
