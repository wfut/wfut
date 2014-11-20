class WFClassHelpWDI extends WFS_WindowDisplayInfo;

// called to setup and display the window (implement in a sub-class)
static function DisplayWindow(WFS_PCSystemPlayer Other, UMenuRootWindow RootWin, WindowConsole WinConsole)
{
	local WFS_HTMLDialogWindow Win;
	local class<WFS_DynamicHTMLPage> HTML;
	local class<WFS_PlayerClassInfo> PCI;
	local int Team;
	local float X, Y;

	PCI = Other.PCInfo;

	if (PCI != None)
	{
		X = RootWin.WinWidth/2 - 150;
		Y = RootWin.WinHeight/2 - 150;
		Team = Other.PlayerReplicationInfo.Team;

		Win = WFClassHelpWindow(RootWin.CreateWindow(class'WFClassHelpWindow', X, Y, 300, 300,, True));

		if (PCI.default.ClassDescription != "")
			HTML = class<WFS_DynamicHTMLPage>(DynamicLoadObject(PCI.default.ClassDescription, class'Class', true));
		if (HTML != None)
		{
			Win.SetHTML(HTML.static.GetHTML("?Team="$Team), "Class Help: "$Other.PCInfo.default.ClassName);

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
	}
}

defaultproperties
{
}