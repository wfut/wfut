class WFMapDataListCW extends UMenuDialogClientWindow;

var UMenuBotmatchClientWindow BotmatchParent;
var UWindowHSplitter Splitter;

var WFMapDataListExclude Exclude;
var WFMapDataListInclude Include;

var WFMapDataListFrameCW FrameExclude;
var WFMapDataListFrameCW FrameInclude;

var UWindowComboControl DefaultCombo;
var UMenuLabelControl DefaultLabel;
var localized string ComboText;
var localized string ComboHelp;
var localized string CustomText;

var localized string ExcludeCaption;
var localized string ExcludeHelp;
var localized string IncludeCaption;
var localized string IncludeHelp;

var bool bChangingDefault;

var class<WFMapSetupInfo> MapSetupClass;

var int InfoDialogWidth, InfoDialogHeight;

function Created()
{
	Super.Created();

	BotmatchParent = UMenuBotmatchClientWindow(OwnerWindow);

	Splitter = UWindowHSplitter(CreateWindow(class'UWindowHSplitter', 0, 0, WinWidth, WinHeight));

	FrameExclude = WFMapDataListFrameCW(Splitter.CreateWindow(class'WFMapDataListFrameCW', 0, 0, 100, 100));
	FrameInclude = WFMapDataListFrameCW(Splitter.CreateWindow(class'WFMapDataListFrameCW', 0, 0, 100, 100));

	Splitter.LeftClientWindow  = FrameExclude;
	Splitter.RightClientWindow = FrameInclude;

	Exclude = WFMapDataListExclude(CreateWindow(class'WFMapDataListExclude', 0, 0, 100, 100, Self));
	FrameExclude.Frame.SetFrame(Exclude);
	Include = WFMapDataListInclude(CreateWindow(class'WFMapDataListInclude', 0, 0, 100, 100, Self));
	FrameInclude.Frame.SetFrame(Include);

	Exclude.Register(Self);
	Include.Register(Self);

	Exclude.SetHelpText(ExcludeHelp);
	Include.SetHelpText(IncludeHelp);

	Include.DoubleClickList = Exclude;
	Exclude.DoubleClickList = Include;

	Splitter.bSizable = False;
	Splitter.bRightGrow = True;
	Splitter.SplitPos = WinWidth/2;

	if (BotMatchParent == None)
	{
		DefaultCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', 10, 2, 250, 1));
		DefaultCombo.SetFont(F_Normal);
		DefaultCombo.SetEditable(False);
		DefaultCombo.SetText(ComboText);
		LoadMapSetupClasses();
		DefaultCombo.SetSelectedIndex(0);
		DefaultCombo.EditBoxWidth = 120;
		DefaultCombo.Register(self);
	}
	else // create text label based on current game type
	{
		DefaultLabel = UMenuLabelControl(CreateControl(class'UMenuLabelControl', 10, 2, 200, 1));
		DefaultLabel.SetText("Map Data List For: "$BotMatchParent.GameClass.Default.GameName);
	}
	GetMapSetupClass();

	LoadMapDataList();
}

function LoadMapSetupClasses()
{
	DefaultCombo.AddItem("Weapons Factory", "WFCode.WFGameMapSetupInfo", 0);
}

function GetMapSetupClass()
{
	if (BotMatchParent != None)
	{
		switch (BotMatchParent.GameClass.name)
		{
			case 'WFGame':
				MapSetupClass = class<WFMapSetupInfo>(DynamicLoadObject("WFCode.WFGameMapSetupInfo", class'Class'));
				break;
		}
	}
	else
		MapSetupClass = class<WFMapSetupInfo>(DynamicLoadObject(DefaultCombo.GetValue2(), class'Class'));
}

function Paint(Canvas C, float X, float Y)
{
	local Texture T;

	Super.Paint(C, X, Y);

	T = GetLookAndFeelTexture();
	DrawUpBevel( C, 0, 20, WinWidth, 15, T);

	C.Font = Root.Fonts[F_Normal];
	C.DrawColor.R = 0;
	C.DrawColor.G = 0;
	C.DrawColor.B = 0;

	ClipText(C, 10, 23, ExcludeCaption, True);
	ClipText(C, WinWidth/2 + 10, 23, IncludeCaption, True);
}

function Resized()
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;

	Super.Resized();

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	Splitter.WinTop = 35;
	Splitter.SetSize(WinWidth, WinHeight-35);
	Splitter.SplitPos = WinWidth/2;

	if (DefaultCombo != None)
	{
		DefaultCombo.SetSize(CenterWidth, 1);
		DefaultCombo.WinLeft = CenterPos;
		DefaultCombo.EditBoxWidth = 110;
	}
}

function LoadMapDataList()
{
	local string NextData, NextDesc, DataName;
	local int i, IncludeCount, NumDataClasses;
	local WFMapDataList L;
	local class<WFMapData> DataBaseClass;

	// search for map data files
	//DataBaseClass = class<WFMapData>(DynamicLoadObject("WFCode.WFMapData", class'Class'));
	Exclude.Items.Clear();
	NumDataClasses = 0;
	GetPlayerOwner().GetNextIntDesc("WFCode.WFMapData", 0, NextData, NextDesc);
	while (	(NextData != "") && (NumDataClasses < 200) )
	{
		// Add the map.
		L = WFMapDataList(Exclude.Items.Append(class'WFMapDataList'));
		L.DataClass = NextData;
		L.DisplayName = NextDesc;

		NumDataClasses++;
		GetPlayerOwner().GetNextIntDesc("WFCode.WFMapData", NumDataClasses, NextData, NextDesc);
	}

	// Now load the current maplist into Include, and remove them from Exclude.
	Include.Items.Clear();
	IncludeCount = ArrayCount(class'WFMapSetupInfo'.default.MapDataClassList);
	for(i=0;i<IncludeCount;i++)
	{
		DataName = MapSetupClass.Default.MapDataClassList[i];
		if(DataName == "")
			break;

		L = WFMapDataList(Exclude.Items).FindMapData(DataName);

		if (L != None)
		{
			L.Remove();
			Include.Items.AppendItem(L);
		}
		else
			Log("Unknown Map Data in Map Data List: "$DataName);
	}

	Exclude.Sort();
}

function DefaultComboChanged()
{
	local class<WFMapSetupInfo> C;
	local int i, Count;

	if(bChangingDefault)
		return;

	bChangingDefault = True;

	C = class<WFMapSetupInfo>(DynamicLoadObject(DefaultCombo.GetValue2(), class'Class'));
	if (C != None)
	{
		GetMapSetupClass();
		LoadMapDataList();
	}

	bChangingDefault = False;
}

function SaveConfigs()
{
	local int i, IncludeCount;
	local WFMapDataList L;

	Super.SaveConfigs();

	L = WFMapDataList(Include.Items.Next);

	IncludeCount = ArrayCount(MapSetupClass.default.MapDataClassList);
	for(i=0; i<IncludeCount; i++)
	{
		if(L == None)
			MapSetupClass.default.MapDataClassList[i] = "";
		else
		{
			MapSetupClass.default.MapDataClassList[i] = L.DataClass;
			L = WFMapDataList(L.Next);
		}
	}

	MapSetupClass.static.StaticSaveConfig();
}

function DisplayInfo()
{
	local WFMapDataList L;
	local class<WFMapData> MapDataClass;

	if (Exclude.SelectedItem != None)
		L = WFMapDataList(Exclude.SelectedItem);
	else L = WFMapDataList(Include.SelectedItem);

	if (L != None)
	{
		MapDataClass = class<WFMapData>(DynamicLoadObject(L.DataClass, class'Class'));
		if (MapDataClass != None)
			DisplayInfoFor(MapDataClass);
	}
}

function DisplayInfoFor(class<WFMapData> MapDataClass)
{
	local WFS_HTMLDialogWindow W;
	local string HTML;
	local float X, Y;
	//Log("-- DisplayInfoFor() called for: "$MapDataClass);

	X = Root.WinWidth/2 - InfoDialogWidth/2;
	Y = Root.WinHeight/2 - InfoDialogHeight/2;

	W = WFS_HTMLDialogWindow(Root.CreateWindow(class'WFS_HTMLDialogWindow', X, Y, InfoDialogWidth, InfoDialogHeight,, True));
	HTML = class'WFMapDataHTMLPage'.static.GetHTML("", 0, MapDataClass);
	W.SetHTML(HTML, "Map Data Information");
	ShowModal(W);
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	if (C == None) return;

	switch(E)
	{
	case DE_Change:
		switch(C)
		{
		case DefaultCombo:
			DefaultComboChanged();
			break;
		}
		break;
	}
}

defaultproperties
{
     ComboText="Configure Data List For: "
     ComboHelp="Choose a WF game type and configure the map data list below."
     CustomText="Custom"
     ExcludeCaption="Unused Map Data Packs"
     ExcludeHelp="Click and drag a map to the right hand column to include that map data pack in the map data list."
     IncludeCaption="Maps Data Packs Used"
     IncludeHelp="Click and drag a map data pack to the left hand column to remove it from the list, or drag it up or down to re-order it in the list."
     InfoDialogWidth=200
     InfoDialogHeight=200
}
