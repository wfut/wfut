class WFClassSetupPage extends WFGameMenuPage;

//#exec TEXTURE IMPORT NAME=blue_recon_preview FILE=Textures\bluerecon.PCX MIPS=OFF

var WFFramedTextListBox ClassList;

var int PlayerTeam, MaxTeams;
var region ClassListRegion, ClassListRegionLowRes;

var float LastUpdate, UpdateTime;

var region InfoButtonRegion, SelectButtonInfo;
var float InfoButtonX, SelectButtonX;
var WFNotifyButton InfoButton, SelectButton;
var float SButtonWidth, SButtonHeight, LowResButtonY;

var region MeshWindowRegion;
var WFPlayerMeshClient MeshWindow;

var string CurrentClassPrefix, CurrentClassAppend;

var bool bUpdating; // to avoid mesh changing events during listbox update

var region PreviewTextureRegion;
var texture ClassPreviewTexture;

function Created()
{
	local int W, H;
	local float XWidth, YHeight, XMod, YMod, XPos, YPos;
	local region TextureRegion;

	class'WFGameMenu'.static.GetTiledSegmentScale(Root, W, H);

	XMod = W*4/1024.0;
	YMod = H*3/768.0;

	ClassList = WFFramedTextListBox(CreateControl(class'WFFramedTextListBox', 16, 24, 120, 80, self));
	ClassList.Register(self);
	ClassList.SetText("Class List:");
	ClassList.SetTextColor(class'ChallengeHUD'.default.WhiteColor);

	// Team Button
	XPos = InfoButtonX/1024.0 * XMod;
	YPos = 281.0/768.0 * YMod;
	XWidth = SButtonWidth/1024.0 * XMod;
	YHeight = SButtonHeight/768.0 * YMod;
	TextureRegion.W = SButtonWidth;
	TextureRegion.H = SButtonHeight;

	// Class Info Button
	InfoButton = WFNotifyButton(CreateWindow(class'WFNotifyButton', XPos, YPos, XWidth, YHeight));
	InfoButton.DisabledTexture = Texture'WFSmallBtnIdle';
	InfoButton.UpTexture = Texture'WFSmallBtnIdle';
	InfoButton.DownTexture = Texture'WFSmallBtnSelect';
	InfoButton.OverTexture = Texture'WFSmallBtnOver';
	InfoButton.bUseRegion = True;
	InfoButton.UpRegion = TextureRegion;
	InfoButton.DownRegion = TextureRegion;
	InfoButton.DisabledRegion = TextureRegion;
	InfoButton.OverRegion = TextureRegion;
	InfoButton.DialogNotifyWindow = Self;
	if (Root.WinWidth < 512) InfoButton.Text = "Info";
	else InfoButton.Text = "Class Info";
	InfoButton.SetTextColor(class'ChallengeHUD'.default.WhiteColor);
	InfoButton.MyFont = class'UTLadderStub'.Static.GetStubClass().Static.GetSmallFont(Root);
	InfoButton.bStretched = True;
	InfoButton.OverSound = sound'LadderSounds.lcursorMove';
	InfoButton.DownSound = sound'LadderSounds.lcursorMove';

	// Select Class Button
	XPos = SelectButtonX/768.0 * YMod;
	SelectButton = WFNotifyButton(CreateWindow(class'WFNotifyButton', XPos, YPos, XWidth, YHeight));
	SelectButton.DisabledTexture = Texture'WFSmallBtnIdle';
	SelectButton.UpTexture = Texture'WFSmallBtnIdle';
	SelectButton.DownTexture = Texture'WFSmallBtnSelect';
	SelectButton.OverTexture = Texture'WFSmallBtnOver';
	SelectButton.bUseRegion = True;
	SelectButton.UpRegion = TextureRegion;
	SelectButton.DownRegion = TextureRegion;
	SelectButton.DisabledRegion = TextureRegion;
	SelectButton.OverRegion = TextureRegion;
	SelectButton.DialogNotifyWindow = Self;
	if (Root.WinWidth < 512) SelectButton.Text = "Select";
	else SelectButton.Text = "Select Class";
	SelectButton.SetTextColor(class'ChallengeHUD'.default.WhiteColor);
	SelectButton.MyFont = class'UTLadderStub'.Static.GetStubClass().Static.GetSmallFont(Root);
	SelectButton.bStretched = True;
	SelectButton.OverSound = sound'LadderSounds.lcursorMove';
	SelectButton.DownSound = sound'LadderSounds.lcursorMove';

	/* mesh window
	MeshWindow = WFPlayerMeshArea(CreateWindow(class'WFPlayerMeshArea', MeshWindowRegion.X*XMod, MeshWindowRegion.Y*YMod, MeshWindowRegion.W*XMod, MeshWindowRegion.H*YMod));
	MeshWindow.SetMeshActorTag('ClassPreviewActor');
	if (IsLowRes())
		MeshWindow.HideWindow();
	*/
	//MeshWindow = WFPlayerMeshClient(CreateWindow(class'WFPlayerMeshClient', MeshWindowRegion.X*XMod, MeshWindowRegion.Y*YMod, MeshWindowRegion.W*XMod, MeshWindowRegion.H*YMod));
	//if (IsLowRes())
	//	MeshWindow.HideWindow();

	//ClassPreviewTexture = texture'blue_recon_preview';

	bUpdating = true;
	UpdateMenuInfo();
	bUpdating = false;
}

function BeforePaint(Canvas C, float X, float Y)
{
	local int W, H;
	local float XMod, YMod, XL, YL, XPos, YPos;
	local font ComponentFont;

	Super.BeforePaint(C, X, Y);

	class'WFGameMenu'.static.GetTiledSegmentScale(Root, W, H);

	XMod = W*4/1024.0;
	YMod = H*3/768.0;

	ComponentFont = class'UTLadderStub'.Static.GetStubClass().Static.GetSmallFont(Root);

	if (IsLowRes())
	{
		ClassList.WinLeft = (WinWidth/2) - (ClassListRegionLowRes.W*XMod/2);
		ClassList.WinTop = ClassListRegion.Y*YMod;
		XL = ClassListRegionLowRes.W * XMod;
		YL = ClassListRegionLowRes.H * YMod;
		if ((ClassList.WinWidth != XL) || (ClassList.WinHeight != YL))
			ClassList.SetSize(XL, YL);
	}
	else
	{
		ClassList.WinLeft = ClassListRegion.X*XMod;
		ClassList.WinTop = ClassListRegion.Y*YMod;
		XL = ClassListRegion.W * XMod;
		YL = ClassListRegion.H * YMod;
		if ((ClassList.WinWidth != XL) || (ClassList.WinHeight != YL))
			ClassList.SetSize(XL, YL);
	}

	if (IsLowRes())
	{
		XPos = ClassList.WinLeft;
		YPos = LowResButtonY*YMod;
	}
	else
	{
		// align the buttons to the lower edge of the class list
		XPos = InfoButtonX * XMod;
		YPos = ClassList.WinTop + ClassList.WinHeight - InfoButton.WinHeight;
	}
	XL = SButtonWidth * XMod;
	YL = SButtonHeight * YMod;
	InfoButton.SetSize(XL, YL);
	InfoButton.WinLeft = XPos;
	InfoButton.WinTop = YPos;
	InfoButton.MyFont = ComponentFont;
	if (Root.WinWidth < 512) InfoButton.Text = "Info";
	else InfoButton.Text = "Class Info";

	if (IsLowRes()) XPos = ClassList.WinLeft + ClassList.WinWidth - XL;
	else XPos = SelectButtonX * XMod;
	SelectButton.SetSize(XL, YL);
	SelectButton.WinLeft = XPos;
	SelectButton.WinTop = YPos;
	SelectButton.MyFont = ComponentFont;
	if (Root.WinWidth < 512) SelectButton.Text = "Select";
	else SelectButton.Text = "Select Class";

	if (MeshWindow != None)
	{
		if (IsLowRes())
		{
			if (MeshWindow.bWindowVisible)
				MeshWindow.HideWindow();
		}
		else
		{
			if (!MeshWindow.bWindowVisible)
				MeshWindow.ShowWindow();
			MeshWindow.WinLeft = MeshWindowRegion.X*XMod;
			MeshWindow.WinTop = MeshWindowRegion.Y*YMod;
			XL = MeshWindowRegion.W*XMod;
			YL = MeshWindowRegion.H*YMod;
			if (MeshWindow.WinWidth != XL || MeshWindow.WinHeight != YL)
				MeshWindow.SetSize(XL, YL);
		}
	}
}

function Paint(canvas C, float X, float Y)
{
	local int W, H;
	local float XMod, YMod, XL, YL, XPos, YPos;
	local font ComponentFont;

	super.Paint(C, X, Y);

	class'WFGameMenu'.static.GetTiledSegmentScale(Root, W, H);

	XMod = W*4/1024.0;
	YMod = H*3/768.0;

	if (!IsLowRes() && (ClassPreviewTexture != None))
		DrawStretchedTextureSegment(C, PreviewTextureRegion.X*XMod, PreviewTextureRegion.Y*YMod, PreviewTextureRegion.W*XMod, PreviewTextureRegion.H*YMod,
			0, 0, PreviewTextureRegion.W, PreviewTextureRegion.H, ClassPreviewTexture);
}

function bool IsLowRes()
{
	return Root.WinWidth < 400;
}

function UpdateMenuInfo()
{
	local int Team;
	local playerpawn PlayerOwner;
	local WFS_PCIList List;
	local WFGameGRI GRI;
	local WFTextList L;
	local int SelectedID, i, PlayerClass;
	local string s1, s2;

	PlayerOwner = GetPlayerOwner();
	if ((PlayerOwner == None) || (PlayerOwner.PlayerReplicationInfo == None))
		return;

	GRI = WFGameGRI(Root.GetPlayerOwner().GameReplicationInfo);
	if (GRI == None)
		return;
	MaxTeams = GRI.MaxTeams;

	PlayerTeam = PlayerOwner.PlayerReplicationInfo.Team;
	if ( ((PlayerTeam >= MaxTeams) && (MaxTeams > 0)) || (PlayerTeam > 3) )
		return;

	// get list of classes for current team
	List = GRI.TeamClassList[PlayerTeam];
	if (List == None)
		return;

	SelectedID = -1;
	if (ClassList.ListBox.SelectedItem != None)
		SelectedID = WFTextList(ClassList.ListBox.SelectedItem).Value;

	PlayerClass = -1;
	if (playerowner.IsA('WFPlayer'))
		PlayerClass = List.GetIndexOfClass(WFPlayer(playerowner).PCInfo);

	ClassList.ListBox.SelectedItem = None;
	ClassList.ListBox.Items.Clear();
	for (i=0; i<List.NumClasses; i++)
	{
		if (List.PlayerClassNames[i] != "")
		{
			L = WFTextList(ClassList.ListBox.Items.Append(class'WFTextList'));
			if (PlayerClass == i)
			{
				s1 = CurrentClassPrefix;
				s2 = CurrentClassAppend;
			}
			else
			{
				s1 = "";
				s2 = "";
			}
			if (List.PlayerCounts[i] > 0)
				L.Text = s1 $ List.PlayerClassNames[i] $ s2 $ "  ["$List.PlayerCounts[i]$"]";
			else
				L.Text = s1 $ List.PlayerClassNames[i] $ s2;
			L.TextColor = class'ChallengeTeamHUD'.default.TeamColor[PlayerTeam];
			L.Value = i;

			if (SelectedID == i)
				ClassList.ListBox.SetSelectedItem(L);
		}
	}
}

function Tick(float Delta)
{
	local levelinfo LI;

	super.Tick(Delta);

	if (!bWindowVisible)
		return;

	LI = Root.GetLevel();
	if ((LI != None) && ((LI.TimeSeconds - LastUpdate) > UpdateTime))
	{
		LastUpdate = LI.TimeSeconds;
		bUpdating = true;
		UpdateMenuInfo();
		bUpdating = false;
	}
}

function Notify(UWindowDialogControl C, byte E)
{
	local int NewClass;
	local WFS_PCIList List;
	local WFGameGRI GRI;
	local WFPlayer PlayerOwner;

	if (bUpdating)
	{
		super.Notify(C, E);
		return;
	}

	if (E == DE_Click)
	{
		if (ClassList.ListBox.SelectedItem == None)
			return;
		else
			NewClass = WFTextList(ClassList.ListBox.SelectedItem).Value;

		GRI = WFGameGRI(Root.GetPlayerOwner().GameReplicationInfo);
		if (GRI == None)
			return;

		// get list of classes for current team
		List = GRI.TeamClassList[PlayerTeam];
		if (List == None)
			return;

		switch (C)
		{
			case InfoButton:
				// launch class help window
				DisplayClassInfo(List.PlayerClasses[NewClass]);
				break;
			case SelectButton:
				// change class
				PlayerOwner = WFPlayer(GetPlayerOwner());
				if (PlayerOwner != None)
				{
					if (!PlayerOwner.IsInState('PCSpectating'))
						PlayerOwner.SetClass(List.PlayerClasses[NewClass].default.ClassName);
					else
						PlayerOwner.ChangePlayerClass(List.PlayerClasses[NewClass]);
				}
				break;
			case ClassList:
				// new class selected, update meshwindow
				UpdateMeshWindow(List.PlayerClasses[NewClass]);
				break;
		}
	}

	super.Notify(C, E);
}

function DisplayClassInfo(class<WFS_PlayerClassInfo> PCI)
{
	local WFS_HTMLDialogWindow Win;
	local class<WFS_DynamicHTMLPage> HTML;
	local float X, Y, XL, YL;
	local UWindowWindow GameMenu;

	if (PCI == None)
		return;

	if (Root.WinWidth < 512)
	{
		XL = Root.WinWidth*0.75;
		YL = Root.WinHeight*0.75;
	}
	else
	{
		XL = 300;
		YL = 300;
	}
	X = FMax((Root.WinWidth/2) - (XL/2.0), 0);
	Y = FMax((Root.WinHeight/2) - (YL/2.0), 0);

	GameMenu = Root.FindChildWindow(class'WFGameMenu', True);

	Win = WFClassHelpWindow(Root.CreateWindow(class'WFClassHelpWindow', X, Y, 300, 300,, True));

	if (PCI.default.ClassDescription != "")
		HTML = class<WFS_DynamicHTMLPage>(DynamicLoadObject(PCI.default.ClassDescription, class'Class', true));
	if (HTML != None)
	{
		Win.SetHTML(HTML.static.GetHTML("?Team="$PlayerTeam), "Class Info: "$PCI.default.ClassName);

		//Win.FocusWindow();
		ShowModal(Win);
		Win.bAlwaysOnTop = True;
		Win.SetSize(XL, YL);
	}
}

function UpdateMeshWindow(class<WFS_PlayerClassInfo> PCI)
{
	local string SN, FN, MeshName;
	local mesh NewMesh;
	local bool bUsedSelectionMesh;

	//Log("MeshWindow.MeshActor: "$ MeshWindow.MeshActor);

	// get new mesh and skin name
	if ((PCI == None) || (MeshWindow == None) || (MeshWindow.MeshActor == None))
		return;

	SN = PCI.default.ClassSkinName;
	FN = PCI.default.ClassFaceName;
	if (PCI.default.MeshInfo.default.DefaultClass != None)
	{
		MeshName = PCI.default.MeshInfo.default.DefaultClass.default.SelectionMesh;
		NewMesh = Mesh(DynamicLoadObject(MeshName, class'Mesh'));
		bUsedSelectionMesh = true;
	}
	else NewMesh = PCI.default.MeshInfo.default.PlayerMesh;

	// clear skins
	// set new mesh and skin
	MeshWindow.ClearSkins();
	if (MeshWindow.MeshActor.Mesh != NewMesh)
		MeshWindow.SetMesh(NewMesh);
	PCI.default.MeshInfo.static.SetMultiSkin(MeshWindow.MeshActor, SN, FN, PlayerTeam);

	if (bUsedSelectionMesh)
	{
		if (ClassIsChildOf(PCI.default.MeshInfo, class'WFD_TournamentFemaleMeshInfo'))
		{
			MeshWindow.MeshActor.DrawScale = 0.14;
			MeshWindow.DrawOffset = vect(0,-0.1,-3.5);
		}
		else
		{
			MeshWindow.MeshActor.DrawScale = 0.15;
			MeshWindow.DrawOffset = vect(0,-0.3,-3.5);
		}
	}
}

defaultproperties
{
	ClassListRegion=(X=21,Y=18,W=224,H=263)
	ClassListRegionLowRes=(X=21,Y=18,W=400,H=210)
	PlayerTeam=-1
	MaxTeams=-1
	UpdateTime=0.5
	SButtonWidth=125
	SButtonHeight=40
	InfoButtonX=262
	SelectButtonX=399
	MeshWindowRegion=(X=262,Y=25,W=262,H=203)
	LowResButtonY=246
	CurrentClassPrefix=">> "
	CurrentClassAppend=""
	PreviewTextureRegion=(X=265,Y=25,W=256,H=203)
}