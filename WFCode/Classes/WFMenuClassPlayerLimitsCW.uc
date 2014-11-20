class WFMenuClassPlayerLimitsCW extends UWindowDialogClientWindow;

var class<WFS_PCIList> ClassList;

var UWindowSmallCloseButton CloseButton;
var UWindowComboControl ClassBoxes[16];

var float HOffset;
var bool bInitialised;
var UWindowFramedWindow FrameOwner;

function Created()
{
	// call SetupMenu() to setup the menu for a class list
	bInitialised = false;
}

function SetupMenu(class<WFS_PCIList> NewClassList)
{
	local int i;
	local UWindowLabelControl Label;
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;

	if (NewClassList == None)
	{
		warn("NewClassList == None, can't set up menu.");
		return;
	}

	DesiredWidth = 220;
	FrameOwner.SetSize(DesiredWidth, WinHeight);

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	ClassList = NewClassList;

	HOffset = 8;

	for (i=0; i<ClassList.default.NumClasses; i++)
	{
		ClassBoxes[i] = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, HOffset, CenterWidth, 1));
		ClassBoxes[i].SetButtons(True);
		ClassBoxes[i].SetText(ClassList.default.PlayerClasses[i].default.ClassName);
		ClassBoxes[i].SetHelpText("Player limit for the "$ClassList.default.PlayerClasses[i].default.ClassName$" class.");
		ClassBoxes[i].SetFont(F_Normal);
		ClassBoxes[i].SetEditable(False);
		ClassBoxes[i].AddItem("[disabled]");
		ClassBoxes[i].AddItem("[no limit]");
		ClassBoxes[i].AddItem("1");
		ClassBoxes[i].AddItem("2");
		ClassBoxes[i].AddItem("3");
		ClassBoxes[i].AddItem("4");
		ClassBoxes[i].AddItem("5");
		ClassBoxes[i].AddItem("6");
		ClassBoxes[i].AddItem("7");
		ClassBoxes[i].AddItem("8");
		ClassBoxes[i].AddItem("9");
		ClassBoxes[i].AddItem("10");
		ClassBoxes[i].SetSelectedIndex(Clamp(ClassList.default.MaxPlayers[i]+1, 0, 11));
		HOffset += 16;
	}

	DesiredHeight = HOffset + 8 + 40;
	FrameOwner.SetSize(DesiredWidth, DesiredHeight);

	CloseButton = UWindowSmallCloseButton(CreateWindow(class'UWindowSmallCloseButton', WinWidth-48, WinHeight-19, 48, 16));

	bInitialised = true;
}

function Paint(Canvas C, float X, float Y)
{
	local Texture T;
	local int i;

	Super.Paint(C, X, Y);

	T = GetLookAndFeelTexture();
	DrawUpBevel( C, 0, WinHeight-24, WinWidth, 24, T);

	for (i=0; i<16; i++)
		if (ClassBoxes[i] != None)
			ClassBoxes[i].EditBoxWidth = 85;

	CloseButton.WinTop = WinHeight - 20;
	CloseButton.WinLeft = WinWidth - 52;
}

function Resized()
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;
	local int i;

	Super.Resized();

	if (!bInitialised)
		return;

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = WinWidth - 32;
	CenterPos = (WinWidth - CenterWidth)/2;

	for (i=0; i<16; i++)
	{
		if (ClassBoxes[i] != None)
		{
			ClassBoxes[i].SetSize(CenterWidth, 1);
			ClassBoxes[i].WinLeft = CenterPos;
			ClassBoxes[i].EditBoxWidth = 80;
		}
	}
}

function Notify(UWindowDialogControl C, byte E)
{
	local int i;

	Super.Notify(C, E);

	if ((ClassList == None) || !bInitialised)
		return;

	switch(E)
	{
		case DE_Change:
			for (i=0; i<ClassList.default.NumClasses; i++)
				if (C == ClassBoxes[i])
					ClassLimitsChanged(i);
			break;
	}
}

function ClassLimitsChanged(int index)
{
	ClassList.default.MaxPlayers[index] = Clamp(ClassBoxes[index].GetSelectedIndex()-1, -1, 10);
	ClassList.static.StaticSaveConfig();
}

defaultproperties
{
}