class WFBasicKeyBindingMenuWDI extends WFS_WindowDisplayInfo;

// called to setup and display the window (implement in a sub-class)
static function DisplayWindow(WFS_PCSystemPlayer Other, UMenuRootWindow RootWin, WindowConsole WinConsole)
{
	local WFBasicKeyBindingMenu Win;
	local int Team;

	Team = Other.PlayerReplicationInfo.Team;

	Win = WFBasicKeyBindingMenu(RootWin.CreateWindow(class'WFBasicKeyBindingMenu', 0, 0, 100, 100,, True));
	if ((WinConsole.ConsoleWindow != None) && WinConsole.ConsoleWindow.bWindowVisible)
	{
		WinConsole.HideConsole();
		if (WinConsole.bQuickKeyEnable)
			WinConsole.CloseUWindow();
	}

	RootWin.MenuBar.bShowMenu = False;
	WinConsole.LaunchUWindow();
	Win.FocusWindow();
	Win.bAlwaysOnTop = False;
}
