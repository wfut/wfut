//=============================================================================
// WFS_PCSWindowLauncher.
// Author: Ob1-Kenobi (ob1@planetunreal.com)
//
// Used to launch a UWindow using a WFS_WindowDisplayInfo class.
//
// Launching windows this way avoids the problems caused by launching windows
// using exec console commands, and ensures that the console will be in the
// correct state to diplay the UWindow properly.
//=============================================================================
class WFS_PCSWindowLauncher extends WFS_PCSystemInfo;

var class<WFS_WindowDisplayInfo> PendingWindow;

var WFS_PCSystemPlayer PlayerOwner;
//var UMenuRootWindow RootWin;
//var WindowConsole WinConsole;
var bool bSetup;

function Initialise(WFS_PCSystemPlayer NewPlayerOwner, UMenuRootWindow NewRootWin, WindowConsole NewWinConsole)
{
	PlayerOwner = NewPlayerOwner;
	//RootWin = NewRootWin;
	//WinConsole = NewWinConsole;
	bSetup = true;
}

function LaunchUWindow(class<WFS_WindowDisplayInfo> WindowInfo)
{
	if (!bSetup)
	{
		Log("WARNING: Tried to launch window before class is set up!");
		return;
	}

	PendingWindow = WindowInfo;
	SetTimer(0.01, false);
}

function Timer()
{
	local UMenuRootWindow RootWin;
	local WindowConsole WinConsole;

	if (PlayerOwner == None)
	{
		Log(self.name$": PlayerOwner == None");
		return;
	}

	WinConsole = PlayerOwner.GetWindowConsole();
	if (WinConsole == None)
	{
		Log(self.name$": failed to find WindowConsole from PlayerOwner: "$PlayerOwner);
		return;
	}

	RootWin = UMenuRootWindow(WinConsole.Root);
	if (RootWin == None)
	{
		Log(self.name$": Root == None");
		return;
	}

	SetTimer(0.0, false);
	PendingWindow.static.DisplayWindow(PlayerOwner, RootWin, WinConsole);
	PendingWindow = None;
}

defaultproperties
{
	RemoteRole=ROLE_None
}