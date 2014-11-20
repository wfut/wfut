class WFGameMenu extends NotifyWindow;

var texture BG1[3];
var texture BG2[3];
var texture BG3[3];

var string LookAndFeelClass;

// base menu dimensions
var const float MenuWidth, MenuHeight;

// info panel location and dimensions relative to 1024x768
//   X,Y = 217,210
//   W,H = 585,415
var region InfoPanelRegion;
var WFGameMenuInfoPanel InfoPanel;
//var WFGameMenuLogoArea LogoArea;

// team icon area location and dimensions relative to 1024x768
//   X,Y = 245,100
//   W,H =
var region TeamIconAreaRegion;
var UWindowWindow TeamIconArea;

// text area location and dimensions relative to 1024x768
//   X,Y = 447,100
//   W,H = 321,75
// (low res):
//   X,Y = 245,100
//   W,H = 523,75
var region LogoAreaRegion;
var region LogoAreaRegionLowRes;
var UWindowWindow LogoArea;

// close button location and dimensions relative to 1024x768
//   X,Y = 447,100
//   W,H = 321,75
var region CloseButtonRegion;
var NotifyButton CloseButton;

var bool bCloseUWindow, bRestoreMenuBar;

function Created()
{
	local int XOffset, YOffset;
	local int W, H;
	local float XWidth, YHeight, XMod, YMod, XPos, YPos;
	local bool bOldSmooth;
	local int OldStyle;
	local float XL, YL;
	local color TextColor;
	local region TextureRegion;
	local UWindowLookAndFeel NewLF;

	if (LookAndFeelClass != "")
	{
		NewLF = Root.GetLookAndFeel(LookAndFeelClass);
		if (NewLF != None)
			LookAndFeel = NewLF;
		else Log("ERROR: couldn't load look and feel class: '"$LookAndFeelClass$"'");
	}

	LookAndFeel.PlayMenuSound(Self, MS_WindowOpen);

	class'UTLadderStub'.Static.GetStubClass().Static.SetupWinParams(Self, Root, W, H);

	XMod = 4*W;
	YMod = 3*H;

	bLeaveOnScreen = True;
	//bAlwaysOnTop = True;

	// Info Panel
	InfoPanel = WFGameMenuInfoPanel(CreateWindow(class'WFGameMenuInfoPanel', 217, 210, 585, 415, OwnerWindow));

	// Close Button
	XPos = CloseButtonRegion.X/1024.0 * XMod;
	YPos = CloseButtonRegion.Y/768.0 * YMod;
	XWidth = CloseButtonRegion.W/1024.0 * XMod;
	YHeight = CloseButtonRegion.H/768.0 * YMod;
	TextureRegion.W = CloseButtonRegion.W;
	TextureRegion.H = CloseButtonRegion.H;
	CloseButton = NotifyButton(CreateWindow(class'WFNotifyButton', XPos, YPos, XWidth, YHeight));
	CloseButton.DisabledTexture = Texture'WFRaisedBtnIdle';
	CloseButton.UpTexture = Texture'WFRaisedBtnIdle';
	CloseButton.DownTexture = Texture'WFRaisedBtnSelect';
	CloseButton.OverTexture = Texture'WFRaisedBtnOver';
	CloseButton.bUseRegion = True;
	CloseButton.UpRegion = TextureRegion;
	CloseButton.DownRegion = TextureRegion;
	CloseButton.DisabledRegion = TextureRegion;
	CloseButton.OverRegion = TextureRegion;
	CloseButton.NotifyWindow = Self;
	CloseButton.Text = "Close";
	TextColor.R = 255;
	TextColor.G = 255;
	TextColor.B = 0;
	CloseButton.SetTextColor(TextColor);
	CloseButton.MyFont = class'UTLadderStub'.Static.GetStubClass().Static.GetBigFont(Root);
	CloseButton.bStretched = True;
	CloseButton.OverSound = sound'LadderSounds.lcursorMove';
	CloseButton.DownSound = sound'LadderSounds.ladvance';

	if (IsLowRes())
	{
		LogoAreaRegion.X = LogoAreaRegionLowRes.X;
		LogoAreaRegion.Y = LogoAreaRegionLowRes.Y;
		LogoAreaRegion.W = LogoAreaRegionLowRes.W;
		LogoAreaRegion.H = LogoAreaRegionLowRes.H;
	}
	LogoArea = CreateWindow(class'WFGameMenuLogoArea', LogoAreaRegion.X*XMod, LogoAreaRegion.Y*YMod, LogoAreaRegion.W*XMod, LogoAreaRegion.H*YMod);

	TeamIconArea = CreateWindow(class'WFGameMenuTeamIconArea', TeamIconAreaRegion.X*XMod, TeamIconAreaRegion.Y*YMod, TeamIconAreaRegion.W*XMod, TeamIconAreaRegion.H*YMod);
	if (IsLowRes())
		TeamIconArea.HideWindow();
}

function WindowShown()
{
	super.WindowShown();
	LookAndFeel.PlayMenuSound(Self, MS_WindowOpen);
}

function Texture GetLookAndFeelTexture()
{
	return LookAndFeel.Active;
}

function BeforePaint(Canvas C, float X, float Y)
{
	local LadderInventory LadderObj;
	local float Xs, Ys;
	local int i;
	local int W, H;
	local float XWidth, YHeight, XMod, YMod, XPos, YPos;

	Super.BeforePaint(C, X, Y);

	class'UTLadderStub'.Static.GetStubClass().Static.SetupWinParams(Self, Root, W, H);

	XMod = 4*W;
	YMod = 3*H;

	// close button
	XPos = CloseButtonRegion.X/1024.0 * XMod;
	YPos = CloseButtonRegion.Y/768.0 * YMod;
	XWidth = CloseButtonRegion.W/1024.0 * XMod;
	YHeight = CloseButtonRegion.H/768.0 * YMod;
	CloseButton.SetSize(XWidth, YHeight);
	CloseButton.WinLeft = XPos;
	CloseButton.WinTop = YPos;
}

function Paint(Canvas C, float X, float Y)
{
	local int XOffset, YOffset;
	local int W, H;
	local float XWidth, YHeight, XMod, YMod, XPos, YPos;
	local bool bOldSmooth;
	local int OldStyle;
	local float XL, YL;


	class'UTLadderStub'.Static.GetStubClass().Static.SetupWinParams(Self, Root, W, H);

	XMod = 4*W;
	YMod = 3*H;

	// Background

	OldStyle = C.Style;
	bOldSmooth = C.bNoSmooth;
	//C.Style = 2; // STY_Masked
	C.bNoSmooth = true;
	XOffset = ( WinWidth - ((MenuWidth/1024.0)*XMod) )/2;
	YOffset = ( WinHeight - ((MenuHeight/768.0)*YMod) )/2;

	if (IsLowRes()) DrawStretchedTexture(C, XOffset + (0 * W), YOffset + (0 * H), W+1, H+1, texture'WFMenuBG11_alt');
	else DrawStretchedTexture(C, XOffset + (0 * W), YOffset + (0 * H), W+1, H+1, BG1[0]);
	DrawStretchedTexture(C, XOffset + (1 * W), YOffset + (0 * H), W+1, H+1, BG1[1]);
	DrawStretchedTexture(C, XOffset + (2 * W), YOffset + (0 * H), W+1, H+1, BG1[2]);

	DrawStretchedTexture(C, XOffset + (0 * W), YOffset + (1 * H), W+1, H+1, BG2[0]);
	DrawStretchedTexture(C, XOffset + (1 * W), YOffset + (1 * H), W+1, H+1, BG2[1]);
	DrawStretchedTexture(C, XOffset + (2 * W), YOffset + (1 * H), W+1, H+1, BG2[2]);

	DrawStretchedTexture(C, XOffset + (0 * W), YOffset + (2 * H), W+1, H+1, BG3[0]);
	DrawStretchedTexture(C, XOffset + (1 * W), YOffset + (2 * H), W+1, H+1, BG3[1]);
	DrawStretchedTexture(C, XOffset + (2 * W), YOffset + (2 * H), W+1, H+1, BG3[2]);
	//C.Style = OldStyle;
	C.bNoSmooth = bOldSmooth;

	XMod = XMod/1024.0;
	YMod = YMod/768.0;
	if (InfoPanel != None)
	{
		InfoPanel.WinLeft = InfoPanelRegion.X*XMod;
		InfoPanel.WinTop = InfoPanelRegion.Y*YMod;
		XL = InfoPanelRegion.W*XMod;
		YL = InfoPanelRegion.H*YMod;

		if((XL != InfoPanel.WinWidth) || (YL != InfoPanel.WinHeight))
			InfoPanel.SetSize(XL, YL);
	}

	if (IsLowRes())
	{
		LogoAreaRegion.X = LogoAreaRegionLowRes.X;
		LogoAreaRegion.Y = LogoAreaRegionLowRes.Y;
		LogoAreaRegion.W = LogoAreaRegionLowRes.W;
		LogoAreaRegion.H = LogoAreaRegionLowRes.H;
	}
	else if (LogoAreaRegion.X != default.LogoAreaRegion.X)
	{
		LogoAreaRegion.X = default.LogoAreaRegion.X;
		LogoAreaRegion.Y = default.LogoAreaRegion.Y;
		LogoAreaRegion.W = default.LogoAreaRegion.W;
		LogoAreaRegion.H = default.LogoAreaRegion.H;
	}

	LogoArea.WinLeft = LogoAreaRegion.X*XMod;
	LogoArea.WinTop = LogoAreaRegion.Y*YMod;
	XL = LogoAreaRegion.W*XMod;
	YL = LogoAreaRegion.H*YMod;
	if ((LogoArea.WinWidth != XL) || (LogoArea.WinHeight != YL))
		LogoArea.SetSize(XL, YL);

	if (IsLowRes())
	{
		if (TeamIconArea.bWindowVisible)
			TeamIconArea.HideWindow();
	}
	else
	{
		if (!TeamIconArea.bWindowVisible)
			TeamIconArea.ShowWindow();
		TeamIconArea.WinLeft = TeamIconAreaRegion.X*XMod;
		TeamIconArea.WinTop = TeamIconAreaRegion.Y*YMod;
		XL = TeamIconAreaRegion.W*XMod;
		YL = TeamIconAreaRegion.H*YMod;
		if ((TeamIconArea.WinWidth != XL) || (TeamIconArea.WinHeight != YL))
			TeamIconArea.SetSize(XL, YL);
	}
}

function Resized()
{
	local Region R;
	local int W, H;
	local float XMod, YMod;
	local float XL, YL;

	class'UTLadderStub'.Static.GetStubClass().Static.SetupWinParams(Self, Root, W, H);

	XMod = 4*W;
	YMod = 3*H;

	CloseButton.MyFont = class'UTLadderStub'.Static.GetStubClass().Static.GetBigFont(Root);

	if(InfoPanel == None)
	{
		Log("InfoPanel is None for "$Self);
		return;
	}

	InfoPanel.WinLeft = (InfoPanelRegion.X/1024.0)*XMod;
	InfoPanel.WinTop = (InfoPanelRegion.Y/768.0)*YMod;
	XL = (InfoPanelRegion.W/1024.0)*XMod;
	YL = (InfoPanelRegion.H/768.0)*YMod;

	if((XL != InfoPanel.WinWidth) || (YL != InfoPanel.WinHeight))
		InfoPanel.SetSize(XL, YL);
}

function ResolutionChanged(float W, float H)
{
	Resized();
	super.ResolutionChanged(W, H);
}

function bool IsLowRes()
{
	return Root.WinWidth < 400;
}

function Close(optional bool bByParent)
{
	super.Close(bByParent);
	if (bCloseUWindow)
	{
		Root.Console.CloseUWindow();
		GetPlayerOwner().bFire = 0;
		GetPlayerOwner().bAltFire = 0;
	}
	if (bRestoreMenuBar)
		UMenuRootWindow(Root).MenuBar.ShowWindow();
}

static function GetTiledSegmentScale(UWindowRootWindow RootWin, out int W, out int H)
{
	W = RootWin.WinHeight/3;
	H = W;

	if (W > 256 || H > 256)
	{
		W = 256;
		H = 256;
	}
}

function Notify(UWindowWindow Window, byte E)
{
	if ((Window == CloseButton) && (E == DE_Click))
		Close();
}

defaultproperties
{
	MenuWidth=635
	MenuHeight=635
	InfoPanelRegion=(X=217,Y=210,W=585,H=415)
	CloseButtonRegion=(X=611,Y=640,W=168,H=52)
	BG1(0)=Texture'WFMenuBG11'
	BG1(1)=Texture'WFMenuBG12'
	BG1(2)=Texture'WFMenuBG13'
	BG2(0)=Texture'WFMenuBG21'
	BG2(1)=Texture'WFMenuBG22'
	BG2(2)=Texture'WFMenuBG23'
	BG3(0)=Texture'WFMenuBG31'
	BG3(1)=Texture'WFMenuBG32'
	BG3(2)=Texture'WFMenuBG33'
	LogoAreaRegion=(X=447,Y=100,W=321,H=80)
	LogoAreaRegionLowRes=(X=245,Y=100,W=523,H=80)
	LookAndFeelClass="WFCode.WFInfoPageLookAndFeel"
	//LookAndFeelClass="WFGameMenu.WFInfoPageLookAndFeel"
	TeamIconAreaRegion=(X=245,Y=93,W=165,H=90)
}