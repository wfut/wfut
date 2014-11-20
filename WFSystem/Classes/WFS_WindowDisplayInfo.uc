//=============================================================================
// WFS_WindowDisplayInfo.
//
// This is a static class that is used to diplay UWindow windows. Implement
// all the display code for the window here, then call either ClientDisplayUWindow()
// or DisplayUWindow() in the WFS_PCSystemPlayer class to display the menu.
//
// Use the 'RootWin' and the 'WinConsole' variables to set up the window correctly.
// Don't forget to call WinConsole.LaunchUWindow() when setting up the window.
//
// If you hide the MenuBar or the StatusBar when displaying the window, make sure
// you show them again when the window is closed.
//=============================================================================
class WFS_WindowDisplayInfo extends WFS_PCSystemInfo;

// called to setup and display the window (implement in a sub-class)
static function DisplayWindow(WFS_PCSystemPlayer Other, UMenuRootWindow RootWin, WindowConsole WinConsole)
{
	/* Example:
	// This code would display the DPMS player setup window.

	RootWin.CreateWindow(class'WFD_DPMSPlayerWindow', 100, 100, 200, 200, Self, True);
	WinConsole.LaunchUWindow();

	*/
}

defaultproperties
{
}