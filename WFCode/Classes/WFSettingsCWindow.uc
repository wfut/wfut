//=============================================================================
// WFSettingsCWindow.
// The client area for the WF settings.
//
// Set up the .int file for a custom class list as follows so that it can be
// detected by this Settings menu:
//
// [Public]
// Object=(Name=PackageName.ClassName,Class=Class,MetaClass=WFSystem.PCIList,Description="Name of list")
//
// 'PackageName.ClassName' is the name of the class list, eg. 'MyPackage.MyClassDefList'
// The description is the name of the class list that appears on the menu.
//=============================================================================
class WFSettingsCWindow extends UTTeamSCWindow;

var string ClassConfigMenuClass;
var string MapDataConfigMenuClass;
var string FlagTextureMenuClass;
var string TeamNameMenuClass;

var UWindowSmallButton MapDataButton;
var localized string MapDataButtonText;
var localized string MapDataButtonHelp;

var UWindowSmallButton ClassConfigButton;
var localized string ClassConfigButtonText;
var localized string ClassConfigButtonHelp;

var UWindowSmallButton FlagTextureButton;
var localized string FlagTextureButtonText;
var localized string FlagTextureButtonHelp;

var UWindowSmallButton TeamNameButton;
var localized string TeamNameButtonText;
var localized string TeamNameButtonHelp;

function Created()
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos, ButtonWidth, ButtonLeft;
	local int i;

	Super.Created();

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	ButtonWidth = WinWidth - 140;
	ButtonLeft = WinWidth - ButtonWidth - 40;

	TranslocCheck.HideWindow();

	MapDataButton = UWindowSmallButton(CreateWindow(class'UWindowSmallButton', CenterPos, ControlOffset - 25, 48, 16));
	MapDataButton.SetText(MapDataButtonText);
	MapDataButton.SetFont(F_Normal);
	MapDataButton.SetHelpText(MapDataButtonHelp);
	MapDataButton.Register(self);

	ClassConfigButton = UWindowSmallButton(CreateWindow(class'UWindowSmallButton', CenterPos, ControlOffset, 48, 16));
	ClassConfigButton.SetText(ClassConfigButtonText);
	ClassConfigButton.SetFont(F_Normal);
	ClassConfigButton.SetHelpText(ClassConfigButtonHelp);
	ClassConfigButton.Register(self);
	ControlOffset += 25;

	FlagTextureButton = UWindowSmallButton(CreateWindow(class'UWindowSmallButton', CenterPos, ControlOffset, 48, 16));
	FlagTextureButton.SetText(FlagTextureButtonText);
	FlagTextureButton.SetFont(F_Normal);
	FlagTextureButton.SetHelpText(FlagTextureButtonHelp);
	FlagTextureButton.Register(self);
	ControlOffset += 25;

	TeamNameButton = UWindowSmallButton(CreateWindow(class'UWindowSmallButton', CenterPos, ControlOffset, 48, 16));
	TeamNameButton.SetText(TeamNameButtonText);
	TeamNameButton.SetFont(F_Normal);
	TeamNameButton.SetHelpText(TeamNameButtonHelp);
	TeamNameButton.Register(self);
	ControlOffset += 25;
}

function BeforePaint(Canvas C, float X, float Y)
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos, ButtonWidth, ButtonLeft;
	local int i;

	Super.BeforePaint(C, X, Y);

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	MapDataButton.AutoWidth(C);
	MapDataButton.WinLeft = CenterPos;

	ClassConfigButton.AutoWidth(C);
	ClassConfigButton.WinLeft = CenterPos;

	FlagTextureButton.AutoWidth(C);
	FlagTextureButton.WinLeft = CenterPos;

	TeamNameButton.AutoWidth(C);
	TeamNameButton.WinLeft = CenterPos;
}

function Notify(UWindowDialogControl C, byte E)
{
	local int i;

	if (!Initialized)
		return;

	Super.Notify(C, E);

	switch(E)
	{
		case DE_Click:
			switch(C)
			{
				case MapDataButton:
					MapDataButtonClick();
					break;
				case ClassConfigButton:
					ClassConfigButtonClick();
					break;
				case FlagTextureButton:
					FlagTextureButtonClick();
					break;
				case TeamNameButton:
					TeamNameButtonClick();
					break;
			}
			break;
	}
}

function ClassConfigButtonClick()
{
	local class<UWindowWindow> WinClass;
	WinClass = class<UWindowWindow>(DynamicLoadObject(ClassConfigMenuClass, class'Class'));
	Root.CreateWindow(WinClass, (Root.WinWidth/2 - (50)), (Root.WinHeight/2 - (50)), 100, 100, BotMatchParent, true );
}

function MapDataButtonClick()
{
	local class<UWindowWindow> WinClass;
	WinClass = class<UWindowWindow>(DynamicLoadObject(MapDataConfigMenuClass, class'Class'));
	Root.CreateWindow(WinClass, (Root.WinWidth/2 - (50)), (Root.WinHeight/2 - (50)), 100, 100, BotMatchParent, true );
}

function FlagTextureButtonClick()
{
	local class<UWindowWindow> WinClass;
	WinClass = class<UWindowWindow>(DynamicLoadObject(FlagTextureMenuClass, class'Class'));
	Root.CreateWindow(WinClass, (Root.WinWidth/2 - (50)), (Root.WinHeight/2 - (50)), 100, 100, BotMatchParent, true );
}

function TeamNameButtonClick()
{
	local class<UWindowWindow> WinClass;
	WinClass = class<UWindowWindow>(DynamicLoadObject(TeamNameMenuClass, class'Class'));
	Root.CreateWindow(WinClass, (Root.WinWidth/2 - (50)), (Root.WinHeight/2 - (50)), 100, 100, BotMatchParent, true );
}

defaultproperties
{
	ClassConfigMenuClass="WFCode.WFClassConfigMenu"
	MapDataConfigMenuClass="WFCode.WFMapDataMenu"
	FlagTextureMenuClass="WFCode.WFFlagTextureMenu"
	TeamNameMenuClass="WFCode.WFTeamNameMenu"
	MapDataButtonText="Configure Map Data"
	MapDataButtonHelp="Configure map data list for this game type."
	ClassConfigButtonText="Configure Classes"
	ClassConfigButtonHelp="Configure the player class lists for each team."
	FlagTextureButtonText="Customise Flags"
	FlagTextureButtonHelp="Customise the flag textures for each team."
	TeamNameButtonText="Team Names"
	TeamNameButtonHelp="Customise the names used for each team."
}
