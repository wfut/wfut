class WFBasicKeyBindingMenuCW extends UTCustomizeClientWindow;

var UWindowCheckBox ClassExecBox;
var bool bInitialised;
var int YOffset;

function Created()
{
	local int ButtonWidth, ButtonLeft, I, J, pos;
	local int LabelWidth, LabelLeft;
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;
	local UMenuLabelControl Heading;
	local bool bTop;

	super(UMenuPageWindow).Created();

	bIgnoreLDoubleClick = True;
	bIgnoreMDoubleClick = True;
	bIgnoreRDoubleClick = True;

	SetAcceptsFocus();

	ButtonWidth = WinWidth - 140;
	ButtonLeft = WinWidth - ButtonWidth - 40;

	LabelWidth = WinWidth - 100;
	LabelLeft = 20;

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	YOffset = 8;
	ClassExecBox = UWindowCheckBox(CreateControl(class'UWindowCheckBox', CenterPos, YOffset, CenterWidth, 16));
	ClassExecBox.SetText("Enable auto-exec scripts:");
	ClassExecBox.SetHelpText("Enables class change auto-exec scripts (for keybindings, etc).");
	ClassExecBox.SetFont(F_Normal);
	ClassExecBox.bChecked = class'WFPlayer'.default.bAutoLoadClassBindings;
	ClassExecBox.Align = TA_Left;
	ClassExecBox.Register(self);
	ClassExecBox.bAcceptsFocus = False;
	YOffset += 16;

	//Heading = UMenuLabelControl(CreateControl(class'UMenuLabelControl', LabelLeft-10, YOffset+3, WinWidth, 1));
	//Heading.SetText("Main Bindings:");
	//Heading.SetFont(F_Bold);
	//YOffset += 19;

	bTop = True;
	for (I=0; I<ArrayCount(AliasNames); I++)
	{
		if(AliasNames[I] == "")
			break;

		j = InStr(LabelList[I], ",");
		if(j != -1)
		{
			if(!bTop)
				YOffset += 10;
			Heading = UMenuLabelControl(CreateControl(class'UMenuLabelControl', LabelLeft-10, YOffset+3, WinWidth, 1));
			Heading.SetText(Left(LabelList[I], j));
			Heading.SetFont(F_Bold);
			LabelList[I] = Mid(LabelList[I], j+1);
			YOffset += 19;
		}
		bTop = False;

		KeyNames[I] = UMenuLabelControl(CreateControl(class'UMenuLabelControl', LabelLeft, YOffset+3, LabelWidth, 1));
		KeyNames[I].SetText(LabelList[I]);
		KeyNames[I].SetHelpText(CustomizeHelp);
		KeyNames[I].SetFont(F_Normal);
		KeyButtons[I] = UMenuRaisedButton(CreateControl(class'UMenuRaisedButton', ButtonLeft, YOffset, ButtonWidth, 1));
		KeyButtons[I].SetHelpText(CustomizeHelp);
		KeyButtons[I].bAcceptsFocus = False;
		KeyButtons[I].bIgnoreLDoubleClick = True;
		KeyButtons[I].bIgnoreMDoubleClick = True;
		KeyButtons[I].bIgnoreRDoubleClick = True;
		YOffset += 19;
	}
	AliasCount = I;

	LoadExistingKeys();
	YOffset += 10;
	DesiredHeight = YOffset;
	bInitialised = True;
}

// overridden to support commands with spaces
function LoadExistingKeys()
{
	local int I, J, pos;
	local string KeyName;
	local string Alias;

	for (I=0; I<AliasCount; I++)
	{
		BoundKey1[I] = 0;
		BoundKey2[I] = 0;
	}

	for (I=0; I<255; I++)
	{
		KeyName = GetPlayerOwner().ConsoleCommand( "KEYNAME "$i );
		RealKeyName[i] = KeyName;
		if ( KeyName != "" )
		{
			Alias = GetPlayerOwner().ConsoleCommand( "KEYBINDING "$KeyName );
			if ( Alias != "" )
			{
				/*pos = InStr(Alias, " ");
				if ( pos != -1 )
				{
					if( !(Left(Alias, pos) ~= "taunt") &&
						!(Left(Alias, pos) ~= "getweapon") &&
						!(Left(Alias, pos) ~= "viewplayernum") &&
						!(Left(Alias, pos) ~= "button") &&
						!(Left(Alias, pos) ~= "mutate"))
						Alias = Left(Alias, pos);
				}*/
				for (J=0; J<AliasCount; J++)
				{
					if ( AliasNames[J] ~= Alias && AliasNames[J] != "None" )
					{
						if ( BoundKey1[J] == 0 )
							BoundKey1[J] = i;
						else
						if ( BoundKey2[J] == 0)
							BoundKey2[J] = i;
					}
				}
			}
		}
	}

	bLoadedExisting = False;
	/*Alias = GetPlayerOwner().ConsoleCommand( "KEYBINDING JoyX" );
	if(Alias ~= JoyXBinding[0])
		JoyXCombo.SetSelectedIndex(0);
	if(Alias ~= JoyXBinding[1])
		JoyXCombo.SetSelectedIndex(1);

	Alias = GetPlayerOwner().ConsoleCommand( "KEYBINDING JoyY" );
	if(Alias ~= JoyYBinding[0])
		JoyYCombo.SetSelectedIndex(0);
	if(Alias ~= JoyYBinding[1])
		JoyYCombo.SetSelectedIndex(1);*/
	bLoadedExisting = True;
}

function BeforePaint(Canvas C, float X, float Y)
{
	local int ButtonWidth, ButtonLeft, I;
	local int LabelWidth, LabelLeft;
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	ButtonWidth = WinWidth - 135;
	ButtonLeft = WinWidth - ButtonWidth - 20;

	LabelWidth = WinWidth - 100;
	LabelLeft = 20;

	ClassExecBox.WinLeft = CenterPos;
	ClassExecBox.SetSize(CenterWidth, 16);

	for (I=0; I<AliasCount; I++)
	{
		KeyButtons[I].SetSize(ButtonWidth, 1);
		KeyButtons[I].WinLeft = ButtonLeft;

		KeyNames[I].SetSize(LabelWidth, 1);
		KeyNames[I].WinLeft = LabelLeft;
	}

	for (I=0; I<AliasCount; I++ )
	{
		if ( BoundKey1[I] == 0 )
			KeyButtons[I].SetText("");
		else
		if ( BoundKey2[I] == 0 )
			KeyButtons[I].SetText(LocalizedKeyName[BoundKey1[I]]);
		else
			KeyButtons[I].SetText(LocalizedKeyName[BoundKey1[I]]$OrString$LocalizedKeyName[BoundKey2[I]]);
	}

	DesiredHeight = YOffset;
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	if (!bInitialised)
		return;

	if (E == DE_Change)
	{
		if (C == ClassExecBox)
			ClassExecBoxChanged();
	}
}

function ClassExecBoxChanged()
{
	if (GetPlayerOwner().IsA('WFPlayer'))
		WFPlayer(GetPlayerOwner()).AutoClassExecs(ClassExecBox.bChecked);
	else
	{
		class'WFPlayer'.default.bAutoLoadClassBindings = ClassExecBox.bChecked;
		class'WFPlayer'.static.StaticSaveConfig();
	}
}

defaultproperties
{
     LabelList(0)="Main Bindings:,Default Class Ability"
     LabelList(1)="Primary Grenade"
     LabelList(2)="Secondary Grenade"
     LabelList(3)="Optional Bindings:,Display Game Menu"
     LabelList(4)="Display Class Help"
     LabelList(5)="Drop Ammo"
     LabelList(6)=""
     LabelList(7)=""
     LabelList(8)=""
     LabelList(9)=""
     AliasNames(0)="special"
     AliasNames(1)="button gren1"
     AliasNames(2)="button gren2"
     AliasNames(3)="gamemenu"
     AliasNames(4)="classhelp"
     AliasNames(5)="dropammo"
     AliasNames(6)=""
     AliasNames(7)=""
     AliasNames(8)=""
}