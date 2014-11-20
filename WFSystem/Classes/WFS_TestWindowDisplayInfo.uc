//=============================================================================
// WFS_TestWindowDisplayInfo.
//
// WFS_WindowDisplayInfo example.
//=============================================================================
class WFS_TestWindowDisplayInfo extends WFS_WindowDisplayInfo;

static function DisplayWindow(WFS_PCSystemPlayer Other, UMenuRootWindow RootWin, WindowConsole WinConsole)
{
	local UWindowWindow NewWindow;
	local class<UWindowWindow> SetupWinClass;

	// get the player window class type from the options tab on the menu bar
	SetupWinClass = RootWin.MenuBar.Options.PlayerWindowClass;

	// launch the console in to UWindow mode (important)
	WinConsole.LaunchUWindow();

	// create the window and assign the Options menu from the menu bar as the owner
	NewWindow = RootWin.CreateWindow(SetupWinClass, 100, 100, 200, 200, RootWin.MenuBar.Options, True);
}

defaultproperties
{
}