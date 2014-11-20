class WFTeamPasswordDialog extends UTPasswordWindow;

var string GameMenuClass;

function Created()
{
	Super(UWindowFramedWindow).Created();

	OKButton = UWindowSmallButton(CreateWindow(class'UWindowSmallButton', WinWidth-108, WinHeight-24, 48, 16));
	CloseButton = UWindowSmallCloseButton(CreateWindow(class'UWindowSmallCloseButton', WinWidth-56, WinHeight-24, 48, 16));
	OKButton.Register(WFTeamPasswordDialogCW(ClientArea));
	OKButton.SetText(OKText);
	SetSizePos();
	bLeaveOnScreen = True;
	bAlwaysOnTop = True;
}

function SetDesiredTeam(int NewTeam)
{
	WFTeamPasswordDialogCW(ClientArea).DesiredTeam = NewTeam;
}

function Close(optional bool bByParent)
{
	local class<UWindowWindow> GameMenuWindowClass;
	Super.Close(bByParent);
	GameMenuWindowClass = class<UWindowWindow>(DynamicLoadObject(GameMenuClass, class'Class'));
	if ((GameMenuWindowClass == None) || (Root.FindChildWindow(GameMenuWindowClass, true) == None))
	{
		UMenuRootWindow(Root).MenuBar.ShowWindow();
		Root.Console.CloseUWindow();
	}
}

defaultproperties
{
     ClientClass=Class'WFTeamPasswordDialogCW'
     WindowTitle="Enter Team Password"
     //GameMenuClass="WFGameMenu.WFGameMenu"
     GameMenuClass="WFCode.WFGameMenu"
}