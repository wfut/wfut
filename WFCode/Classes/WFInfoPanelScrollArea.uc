class WFInfoPanelScrollArea extends UWindowScrollingDialogClient;

function Created()
{
	Super(UWindowPageWindow).Created();

	HideWindow();

	if(FixedAreaClass != None)
	{
		FixedArea = UWindowDialogClientWindow(CreateWindow(FixedAreaClass, 0, 0, 100, 100, OwnerWindow));
		FixedArea.bAlwaysOnTop = True;
	}
	else
		FixedArea = None;

	if (ClientArea != None)
		ClientArea = UWindowDialogClientWindow(CreateWindow(ClientClass, 0, 0, WinWidth, WinHeight, OwnerWindow));

	VertSB = UWindowVScrollbar(CreateWindow(class'UWindowVScrollbar', WinWidth-12, 0, 12, WinHeight));
	VertSB.bAlwaysOnTop = True;
	VertSB.HideWindow();

	HorizSB = UWindowHScrollbar(CreateWindow(class'UWindowHScrollbar', 0, WinHeight-12, WinWidth, 12));
	HorizSB.bAlwaysOnTop = True;
	HorizSB.HideWindow();

	BRBitmap = UWindowBitmap(CreateWindow(class'UWindowBitmap', WinWidth-12, WinHeight-12, 12, 12));
	BRBitmap.bAlwaysOnTop = True;
	BRBitmap.HideWindow();
	BRBitmap.bStretch = True;

	ShowWindow();
}

function BeforePaint(Canvas C, float X, float Y)
{
	if (ClientArea == None)
		return;

	super.BeforePaint(C, X, Y);
}

function UWindowDialogClientWindow SetClientArea(class<UWindowDialogClientWindow> NewClientClass)
{
	if (ClientArea != None)
	{
		ClientArea.Close(true);
		ClientArea = None;
	}

	if (NewClientClass == None)
		return None;

	ClientArea = UWindowDialogClientWindow(CreateWindow(NewClientClass, 0, 0, WinWidth, WinHeight, /*OwnerWindow, true*/));

	return ClientArea;
}

defaultproperties
{
	bShowHorizSB=True
	bShowVertSB=True
}