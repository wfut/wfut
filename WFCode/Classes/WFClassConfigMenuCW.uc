//=============================================================================
// WFClassConfigMenuCW.
//=============================================================================
class WFClassConfigMenuCW expands UWindowDialogClientWindow;

var UMenuBotmatchClientWindow BotmatchParent;
var UWindowSmallCloseButton CloseButton;

var UWindowComboControl ClassListCombo[4];
var localized string ClassTeamNames[4];
var localized string DefaultText;
var localized string ClassListHelp;

var UWindowSmallButton ClassLimits[4];

var string DefListBaseClass;

var string DefClass[32];
var string DefName[32];
const MAX_DEFS = 32;

// used to vertically position the components
var int SpacingOffset;
var int ControlOffset;

var UWindowFramedWindow OwnerFrame;

function Created()
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos, ButtonWidth, ButtonLeft;
	local int Offset, i;
	local string spos;

	Super.Created();

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;
	BotmatchParent = UMenuBotmatchClientWindow(OwnerWindow);

	CloseButton = UWindowSmallCloseButton(CreateWindow(class'UWindowSmallCloseButton', WinWidth-48, WinHeight-19, 48, 16));

	ControlOffset = 8;

	LoadClassDefs();

	// create the PCI list boxes
	for (i=0; i<4; i++)
	{
		ClassListCombo[i] = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
		ClassListCombo[i].SetText(ClassTeamNames[i]);
		ClassListCombo[i].SetHelpText(ClassListHelp);
		ClassListCombo[i].SetFont(F_Normal);
		ClassListCombo[i].SetEditable(False);
		ClassListCombo[i].AddItem(DefaultText, "");
		FillClassListCombo(ClassListCombo[i]);
		ClassListCombo[i].SetSelectedIndex(ClassListCombo[i].FindItemIndex2(GetClassDefinition(i), true));

		ControlOffset += 16;
		ClassLimits[i] = UWindowSmallButton(CreateControl(class'UWindowSmallButton', ControlRight, ControlOffset, ControlWidth, 16));
		ClassLimits[i].SetText("Configure Class Limits");

		ControlOffset += SpacingOffset;
	}
}

// load the available PCI lists
function LoadClassDefs()
{
	local int NumDefs;
	local string NextDef, NextDesc;

	GetPlayerOwner().GetNextIntDesc(DefListBaseClass, 0, NextDef, NextDesc);
	while( (NextDef != "") && (NumDefs < MAX_DEFS) )
	{
		DefClass[NumDefs] = NextDef;
		DefName[NumDefs] = NextDesc;

		NumDefs++;
		GetPlayerOwner().GetNextIntDesc(DefListBaseClass, NumDefs, NextDef, NextDesc);
	}
}

// add the available class list to a combo control
function FillClassListCombo(UWindowComboControl Combo)
{
	local int i;

	for (i=0; i<MAX_DEFS; i++)
		if ((DefClass[i] != "") && (DefName[i] != ""))
			Combo.AddItem(DefName[i], DefClass[i]);
}

function Paint(Canvas C, float X, float Y)
{
	local Texture T;
	local int i;

	Super.Paint(C, X, Y);

	T = GetLookAndFeelTexture();
	DrawUpBevel( C, 0, WinHeight-24, WinWidth, 24, T);

	for (i=0; i<4; i++)
	{
		ClassLimits[i].AutoWidth(C);
		ClassLimits[i].WinLeft = ClassListCombo[i].WinLeft + ClassListCombo[i].WinWidth - ClassLimits[i].WinWidth;
	}
}

function Resized()
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;
	local int i;

	Super.Resized();

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = WinWidth - 32;
	CenterPos = (WinWidth - CenterWidth)/2;

	CloseButton.WinTop = WinHeight - 20;
	CloseButton.WinLeft = WinWidth - 52;

	for (i=0; i<4; i++)
	{
		ClassListCombo[i].SetSize(CenterWidth, 1);
		ClassListCombo[i].WinLeft = CenterPos;
		ClassListCombo[i].EditBoxWidth = 110;

		ClassLimits[i].WinTop = ClassListCombo[i].WinTop + 18;
		ClassLimits[i].WinLeft = ClassListCombo[i].WinLeft + ClassListCombo[i].WinWidth - ClassLimits[i].WinWidth;
	}
}

function Notify(UWindowDialogControl C, byte E)
{
	local int i;

	Super.Notify(C, E);

	switch(E)
	{
		case DE_Change:
			for (i=0; i<4; i++)
				if (C == ClassListCombo[i])
					ClassListComboChanged(i);
			break;

		case DE_Click:
			for (i=0; i<4; i++)
				if (C == ClassLimits[i])
					ClassLimitsClick(i);
			break;
	}
}

function SaveConfigs()
{
	Super.SaveConfigs();

	SaveClassDefinitions();
}

function ClassLimitsClick(int Index)
{
	local WFMenuClassPlayerLimits Win;
	local int W, H, X, Y;
	local class<WFS_PCIList> ClassList;

	ClassList = class<WFS_PCIList>(DynamicLoadObject(ClassListCombo[Index].GetValue2(), class'Class', true));
	if (ClassList == None)
	{
		Log("ClassLimitsCheck: ClassList == None.");
		return;
	}

	W = 250;
	H = 200;

	X = Root.WinWidth/2 - W/2;
	Y = Root.WinHeight/2 - H/2;

	Win = WFMenuClassPlayerLimits(Root.CreateWindow(class'WFMenuClassPlayerLimits', X, Y, W, H));
	Win.SetupMenu(ClassList);
	OwnerFrame.ShowModal(Win);
}

//-----------------------------------------------------------------------------
// Game type specific functions.

function SaveClassDefinitions()
{
	class'WFGame'.static.StaticSaveConfig();
}

function ClassListComboChanged(int Index)
{
	Class<WFGame>(BotmatchParent.GameClass).Default.ClassDefinitions[Index] = ClassListCombo[Index].GetValue2();
}

function string GetClassDefinition(int num)
{
	return class'WFGame'.default.ClassDefinitions[num];
}

defaultproperties
{
	SpacingOffset=25
	DefaultText="(default)"
	ClassTeamNames(0)="Class list (Red):"
	ClassTeamNames(1)="Class list (Blue):"
	ClassTeamNames(2)="Class list (Green):"
	ClassTeamNames(3)="Class list (Gold):"
	DefListBaseClass="WFSystem.WFS_PCIList"
	ClassListHelp="Select the player class definition list that will be used for this team."
}