class WFFlagTextureMenuCW extends UWindowDialogClientWindow;

var UWindowSmallCloseButton CloseButton;

var UWindowCheckBox OverrideCheck;
var UWindowComboControl FlagsCombo;
var UWindowComboControl TextureCombo;

var WFFlagTexturePreviewClient MeshWindow;

var localized string OverrideText;
var localized string OverrideHelp;

var localized string FlagText;
var localized string FlagHelp;
var localized string FlagTeamNames[4];

var localized string TextureText;
var localized string TextureHelp;

// used to vertically position the components
var int SpacingOffset;
var int ControlOffset;

var int NumTeams;
var bool bInitialised;
var bool bUpdating;
var string FlagSkinPrefix;

function Created()
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos, ButtonWidth, ButtonLeft;
	local int Offset, i;
	local string spos;

	Super.Created();

	MeshWindow = WFFlagTexturePreviewClient(WFFlagTextureMenuClient(ParentWindow.ParentWindow.ParentWindow).Splitter.BottomClientWindow);

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	ControlOffset = 8;

	OverrideCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, ControlOffset, CenterWidth, 1));
	OverrideCheck.SetText(OverrideText);
	OverrideCheck.SetHelpText(OverrideHelp);
	OverrideCheck.SetFont(F_Normal);
	OverrideCheck.Align = TA_Left;
	OverrideCheck.bChecked = class'WFGame'.default.bOverrideMapFlagTextures;
	ControlOffset += SpacingOffset;

	// create the flag list boxe
	FlagsCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	FlagsCombo.SetText(FlagText);
	FlagsCombo.SetHelpText(FlagHelp);
	FlagsCombo.SetFont(F_Normal);
	FlagsCombo.SetEditable(False);
	for (i=0; i<NumTeams; i++)
		FlagsCombo.AddItem(FlagTeamNames[i], GetFlagTextureFor(i));
	FlagsCombo.SetSelectedIndex(0);
	ControlOffset += SpacingOffset;

	// create the texture list combo
	TextureCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	TextureCombo.SetText(TextureText);
	TextureCombo.SetHelpText(TextureHelp);
	TextureCombo.SetFont(F_Normal);
	TextureCombo.SetEditable(False);
	ControlOffset += SpacingOffset;
}

function AfterCreate()
{
	Super.AfterCreate();

	bInitialised = true;
	LoadFlagTextures();
	SetCurrent();
}

function LoadFlagTextures()
{
	local string SkinName, SkinDesc, TestName;

	TextureCombo.AddItem("(default)", "");

	// find all the flag skins
	// must be: WFFlag<name>.SkinName
	SkinName = "None";
	TestName = "";
	while (true)
	{
		GetPlayerOwner().GetNextSkin(FlagSkinPrefix, SkinName, 1, SkinName, SkinDesc);

		if( SkinName == TestName )
			break;

		if( TestName == "" )
			TestName = SkinName;

		TextureCombo.AddItem(SkinDesc, SkinName);
	}
	TextureCombo.Sort();
}

function SetCurrent()
{
	TextureCombo.SetSelectedIndex(TextureCombo.FindItemIndex2(FlagsCombo.GetValue2(), true));
	UpdatePreview();
}

function UpdatePreview()
{
	local string TextureName;
	local texture FlagTexture;

	if (!bInitialised)
		return;

	TextureName = TextureCombo.GetValue2();
	if (TextureName != "")
	{
		FlagTexture = Texture(DynamicLoadObject(TextureName $"_t"$FlagsCombo.GetSelectedIndex(), class'Texture'));
		MeshWindow.SetSkin(FlagTexture);
	}
	else if (FlagsCombo.GetSelectedIndex() != -1)
		MeshWindow.SetSkin(class'WFGameMapSetupInfo'.default.DefaultFlagTextures[FlagsCombo.GetSelectedIndex()]);
}

function string GetFlagTextureFor(int Team)
{
	return class'WFGame'.default.FlagTextures[Team];
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

	OverrideCheck.SetSize(CenterWidth, 1);
	OverrideCheck.WinLeft = CenterPos;

	FlagsCombo.SetSize(CenterWidth, 1);
	FlagsCombo.WinLeft = CenterPos;
	FlagsCombo.EditBoxWidth = 110;

	TextureCombo.SetSize(CenterWidth, 1);
	TextureCombo.WinLeft = CenterPos;
	TextureCombo.EditBoxWidth = 110;
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	if (bUpdating)
		return;

	switch (E)
	{
		case DE_Change:
			switch (C)
			{
				case FlagsCombo:
					FlagChanged();
					break;
				case TextureCombo:
					TextureChanged();
					break;
				case OverrideCheck:
					OverrideChanged();
					break;
			}
			break;
	}
}

function FlagChanged()
{
	bUpdating = True;
	SetCurrent();
	bUpdating = False;
}

function TextureChanged()
{
	local string NewTexture;
	local int index;

	bUpdating = True;
	NewTexture = TextureCombo.GetValue2();
	index = FlagsCombo.GetSelectedIndex();

	class'WFGame'.default.FlagTextures[index] = NewTexture;
	class'WFGame'.static.StaticSaveConfig();

	FlagsCombo.SetValue(FlagsCombo.GetValue(), NewTexture);
	FlagsCombo.List.Selected.Value2 = NewTexture;

	UpdatePreview();
	bUpdating = False;
}

function OverrideChanged()
{
	class'WFGame'.default.bOverrideMapFlagTextures = OverrideCheck.bChecked;
	class'WFGame'.static.StaticSaveConfig();
}

defaultproperties
{
	SpacingOffset=25
	NumTeams=4
	FlagSkinPrefix="WFFlag"
	FlagText="Select Flag:"
	FlagHelp="Select the flag to customise."
	FlagTeamNames(0)="Red Flag"
	FlagTeamNames(1)="Blue Flag"
	FlagTeamNames(2)="Green Flag"
	FlagTeamNames(3)="Gold Flag"
	OverrideText="Always use custom textures:"
	OverrideHelp="Force maps with different flag textures to use the custom texures."
	TextureText="Flag Texture:"
	TextureHelp="Select the new texture for the flag."
}