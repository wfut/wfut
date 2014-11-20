class WFTeamPasswordDialogWDI extends WFS_WindowDisplayInfo;

var() string PasswordDialogClass;
var() int DesiredTeam;
var() string WindowTitle;

static function DisplayWindow(WFS_PCSystemPlayer Other, UMenuRootWindow RootWin, WindowConsole WinConsole)
{
	local WFTeamPasswordDialog Win;

	Win = WFTeamPasswordDialog(RootWin.CreateWindow(class'WFTeamPasswordDialog', 100, 100, 100, 100));
	Win.SetDesiredTeam(default.DesiredTeam);
	Win.WindowTitle = default.WindowTitle;

	if ((WinConsole.ConsoleWindow != None) && WinConsole.ConsoleWindow.bWindowVisible)
	{
		WinConsole.HideConsole();
		if (WinConsole.bQuickKeyEnable)
			WinConsole.CloseUWindow();
	}

	RootWin.MenuBar.bShowMenu = False;
	WinConsole.LaunchUWindow();
	WinConsole.bNoDrawWorld = False;
	RootWin.MenuBar.HideWindow();
	Win.FocusWindow();
}

defaultproperties
{
	PasswordDialogClass="WFCode.WFTeamPasswordDialog"
}