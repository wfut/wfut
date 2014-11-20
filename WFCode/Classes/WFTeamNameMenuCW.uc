//=============================================================================
// WFTeamNameMenuCW.
//=============================================================================
class WFTeamNameMenuCW expands UWindowDialogClientWindow;

var UMenuBotmatchClientWindow BotmatchParent;
var UWindowSmallCloseButton CloseButton;

var UWindowEditControl TeamNameEdit[4];
var localized string TeamNames[4];
var localized string TeamNameHelp;

// used to vertically position the components
var int SpacingOffset;
var int ControlOffset;

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

	// create the edit boxes
	for (i=0; i<4; i++)
	{
		TeamNameEdit[i] = UWindowEditControl(CreateControl(class'UWindowEditControl', CenterPos, ControlOffset, CenterWidth, 1));
		TeamNameEdit[i].SetText(TeamNames[i]);
		TeamNameEdit[i].SetHelpText(TeamNameHelp);
		TeamNameEdit[i].SetFont(F_Normal);
		TeamNameEdit[i].EditBox.Value = GetTeamName(i);
		TeamNameEdit[i].SetDelayedNotify(True);
		ControlOffset += SpacingOffset;
	}
}

function Paint(Canvas C, float X, float Y)
{
	local Texture T;
	Super.Paint(C, X, Y);
	T = GetLookAndFeelTexture();
	DrawUpBevel( C, 0, WinHeight-24, WinWidth, 24, T);
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
		TeamNameEdit[i].SetSize(CenterWidth, 1);
		TeamNameEdit[i].WinLeft = CenterPos;
		TeamNameEdit[i].EditBoxWidth = 110;
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
				if (C == TeamNameEdit[i])
					TeamNameEditChanged(i);
			break;
	}
}

function SaveConfigs()
{
	Super.SaveConfigs();

	SaveTeamNames();
}

//-----------------------------------------------------------------------------
// Game type specific functions.

function SaveTeamNames()
{
	class'WFGame'.static.StaticSaveConfig();
}

function string GetTeamName(int Team)
{
	return class'WFGame'.default.TeamNames[Team];
}

function TeamNameEditChanged(int Index)
{
	Class<WFGame>(BotmatchParent.GameClass).Default.TeamNames[Index] = TeamNameEdit[Index].GetValue();
}

defaultproperties
{
	SpacingOffset=25
	TeamNames(0)="Red Team Name:"
	TeamNames(1)="Blue Team Name:"
	TeamNames(2)="Green Team Name:"
	TeamNames(3)="Gold Team Name:"
	TeamNameHelp="Select the player class definition list that will be used for this team."
}