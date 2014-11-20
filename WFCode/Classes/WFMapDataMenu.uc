class WFMapDataMenu extends UWindowFramedWindow;

var UWindowSmallCloseButton CloseButton;

var WFMapDataInfoButton MapDataInfoButton;
var localized string MapDataInfoText;
var localized string MapDataInfoHelp;

function Created()
{
	bStatusBar = False;
	bSizable = True;

	Super.Created();

	WinWidth = Min(400, Root.WinWidth - 50);
	WinHeight = Min(210, Root.WinHeight - 50);

	WinLeft = Root.WinWidth/2 - WinWidth/2;
	WinTop = Root.WinHeight/2 - WinHeight/2;

	CloseButton = UWindowSmallCloseButton(CreateWindow(class'UWindowSmallCloseButton', WinWidth-56, WinHeight-24, 48, 16));

	// Map Data Info Button
	MapDataInfoButton = WFMapDataInfoButton(CreateWindow(class'WFMapDataInfoButton', 8, WinHeight-24, 48, 16));
	MapDataInfoButton.SetText(MapDataInfoText);
	MapDataInfoButton.SetFont(F_Normal);
	MapDataInfoButton.SetHelpText(MapDataInfoHelp);
	MapDataInfoButton.Register(UWindowDialogClientWindow(ClientArea));

	MinWinWidth = 200;
}

function Resized()
{
	Super.Resized();
	ClientArea.SetSize(ClientArea.WinWidth, ClientArea.WinHeight-24);
	CloseButton.WinLeft = ClientArea.WinLeft+ClientArea.WinWidth-52;
	CloseButton.WinTop = ClientArea.WinTop+ClientArea.WinHeight+4;
	MapDataInfoButton.WinLeft = ClientArea.WinLeft+8;
	MapDataInfoButton.WinTop = ClientArea.WinTop+ClientArea.WinHeight+4;
}

function Paint(Canvas C, float X, float Y)
{
	local Texture T;

	T = GetLookAndFeelTexture();
	DrawUpBevel( C, ClientArea.WinLeft, ClientArea.WinTop + ClientArea.WinHeight, ClientArea.WinWidth, 24, T);
	MapDataInfoButton.AutoWidth(C);

	Super.Paint(C, X, Y);
}

defaultproperties
{
     ClientClass=Class'WFMapDataListCW'
     WindowTitle="Map Data List"
     MapDataInfoText="Show Info"
     MapDataInfoHelp="Display information for selected map data pack."
}