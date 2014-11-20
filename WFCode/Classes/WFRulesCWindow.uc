//=============================================================================
// WFRulesCWindow.
// The client area for the WF rules.
//=============================================================================
class WFRulesCWindow extends UTTeamRCWindow;

var UWindowComboControl FlagReturnCombo;
var UWindowEditControl FlagReturnTimeEdit;

var string TouchReturnText, CarryReturnText, DelayReturnText;
var string StyleHelpText, FlagReturnText;

function SetupNetworkOptions()
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos, ButtonWidth, ButtonLeft;

	Super.SetupNetworkOptions();

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	FlagReturnCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	FlagReturnCombo.SetText(FlagReturnText);
	FlagReturnCombo.SetHelpText(StyleHelpText);
	FlagReturnCombo.SetFont(F_Normal);
	FlagReturnCombo.SetEditable(False);
	FlagReturnCombo.AddItem(GetTextForFlagStyle(0), "", 0);
	FlagReturnCombo.AddItem(GetTextForFlagStyle(1), "", 1);
	FlagReturnCombo.AddItem(GetTextForFlagStyle(2), "", 2);
	FlagReturnCombo.SetSelectedIndex(class'WFGame'.default.FlagReturnStyle);
	ControlOffset += 25;
}

function BeforePaint(Canvas C, float X, float Y)
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos, ButtonWidth, ButtonLeft;

	Super.BeforePaint(C, X, Y);

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	FlagReturnCombo.SetSize(CenterWidth, 1);
	FlagReturnCombo.WinLeft = CenterPos;
	FlagReturnCombo.EditBoxWidth = 110;
}

function Notify(UWindowDialogControl C, byte E)
{
	local int i;

	if (!Initialized)
		return;

	Super.Notify(C, E);

	switch(E)
	{
		case DE_Change:
			if (C == FlagReturnCombo)
				FlagReturnComboChanged();
			break;
	}
}

function string GetTextForFlagStyle(int StyleNum)
{
	switch(StyleNum)
	{
		case class'WFGame'.default.FRS_DelayReturn:
			return DelayReturnText;
			break;
		case class'WFGame'.default.FRS_TouchReturn:
			return TouchReturnText;
			break;
		case class'WFGame'.default.FRS_CarryReturn:
			return CarryReturnText;
			break;
	}
	return "";
}

function FlagReturnComboChanged()
{
	class'WFGame'.default.FlagReturnStyle = FlagReturnCombo.GetSelectedIndex();
	//class'WFGame'.static.StaticSaveConfig();
}

defaultproperties
{
	TouchReturnText="Touch Return"
	DelayReturnText="Return Delay"
	CarryReturnText="Carry Return"
	//StyleHelp(0)="Players can touch the flag to return it."
	//StyleHelp(1)="Players cannot return the flag. It will return after a time delay."
	//StyleHelp(2)="Players must carry the flag back to base to return it."
	StyleHelpText="The flag return style: touch to return, wait for return, or carry to return - delay return is the recommended style."
	FlagReturnText="Flag return style:"
}
