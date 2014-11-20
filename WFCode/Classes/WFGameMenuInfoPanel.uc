class WFGameMenuInfoPanel extends NotifyWindow;

// TODO: figure out whether or not adding dynamic support for buttons would be worth it

// menu can only display 3 buttons, so if any more are added scrolling buttons will need
// to be added to the panel

var NotifyButton PageButtons[8];
var string PageClasses[8]; // string class names for pages
var class<WFGameMenuPage> Pages[8]; // could add extra buttons later
var int NumPages;

var NotifyButton SelectedButton; // currently selected button
var int SelectedPage;
var int LeftButtonNum; // page number value of left button

var const float MenuWidth, MenuHeight;
var texture BG1[3];
var texture BG2[3];

// button positions
var const float Button1X, Button1Y;
var const float Button2X, Button2Y;
var const float Button3X, Button3Y; // currently unused

var const float ButtonWidth, ButtonHeight;

var NotifyButton Button1, Button2, Button3;

// current page location and dimensions relative to 1024x768
//   X,Y = 241,291 - 217x210 = 24x81 (position relative to this window area)
//   W,H = 540,301
var const float PageWidth, PageHeight;
var const float PageX, PageY;
var WFGameMenuPage CurrentPage;

var color SelectedColor, IdleColor;

var WFInfoPanelScrollArea ScrollArea;

// info panel map regions
var region OuterCornerTL, OuterCornerTR, OuterCornerBL, OuterCornerBR;
var region InnerCornerTL, InnerCornerTR, InnerCornerBL, InnerCornerBR;
var region PanelEdge, OuterPanelArea, InnerPanelArea;

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

	ScrollArea = WFInfoPanelScrollArea(CreateWindow(class'WFInfoPanelScrollArea', PageX, PageY, PageWidth, PageHeight, OwnerWindow));

	// Team Button
	XPos = Button1X/1024.0 * XMod;
	YPos = Button1Y/768.0 * YMod;
	XWidth = ButtonWidth/1024.0 * XMod;
	YHeight = ButtonHeight/768.0 * YMod;
	TextureRegion.W = ButtonWidth;
	TextureRegion.H = ButtonHeight;
	Button1 = NotifyButton(CreateWindow(class'WFNotifyButton', XPos, YPos, XWidth, YHeight));
	Button1.DisabledTexture = Texture'WFFlatBtnSelect';
	Button1.UpTexture = Texture'WFFlatBtnIdle';
	Button1.DownTexture = Texture'WFFlatBtnSelect';
	Button1.OverTexture = Texture'WFFlatBtnOver';
	Button1.bUseRegion = True;
	Button1.UpRegion = TextureRegion;
	Button1.DownRegion = TextureRegion;
	Button1.DisabledRegion = TextureRegion;
	Button1.OverRegion = TextureRegion;
	Button1.NotifyWindow = Self;
	Button1.Text = "Team";
	Button1.SetTextColor(IdleColor);
	Button1.MyFont = class'UTLadderStub'.Static.GetStubClass().Static.GetBigFont(Root);
	Button1.bStretched = True;
	Button1.OverSound = sound'LadderSounds.lcursorMove';
	Button1.DownSound = sound'LadderSounds.ladvance';
	SelectButton(Button1);
	SelectedPage = 0;

	// Class Button
	XPos = Button2X/1024.0 * XMod;
	YPos = Button2Y/768.0 * YMod;
	XWidth = ButtonWidth/1024.0 * XMod;
	YHeight = ButtonHeight/768.0 * YMod;
	TextureRegion.W = ButtonWidth;
	TextureRegion.H = ButtonHeight;
	Button2 = NotifyButton(CreateWindow(class'WFNotifyButton', XPos, YPos, XWidth, YHeight));
	Button2.DisabledTexture = Texture'WFFlatBtnSelect';
	Button2.UpTexture = Texture'WFFlatBtnIdle';
	Button2.DownTexture = Texture'WFFlatBtnSelect';
	Button2.OverTexture = Texture'WFFlatBtnOver';
	Button2.bUseRegion = True;
	Button2.UpRegion = TextureRegion;
	Button2.DownRegion = TextureRegion;
	Button2.DisabledRegion = TextureRegion;
	Button2.OverRegion = TextureRegion;
	Button2.NotifyWindow = Self;
	Button2.Text = "Class";
	Button2.SetTextColor(IdleColor);
	Button2.MyFont = class'UTLadderStub'.Static.GetStubClass().Static.GetBigFont(Root);
	Button2.bStretched = True;
	Button2.OverSound = sound'LadderSounds.lcursorMove';
	Button2.DownSound = sound'LadderSounds.ladvance';

	// create the page for the currently selected button
	DisplayPage(SelectedPage);
}

function DisplayPage(int PageNum)
{
	local int W, H;
	local float XWidth, YHeight, XMod, YMod, XPos, YPos;
	local class<WFGameMenuPage> PageClass;

	if ((PageNum < 0) || (PageNum > ArrayCount(Pages)))
	{
		Log("WARNING: tried to display invalid page index: "$PageNum);
		return;
	}

	if ((Pages[PageNum] == None) && (PageClasses[PageNum] == ""))
	{
		Log("WARNING: page class is None for page index: "$PageNum);
		return;
	}

	if (Pages[PageNum] == None)
	{
		PageClass = class<WFGameMenuPage>(DynamicLoadObject(PageClasses[PageNum], class'Class', true));
		if (PageClass == None)
		{
			Log("WARNING: failed to load page class '"$PageClasses[PageNum]$"' for page index: "$PageNum);
			return;
		}
	}

	/*if (CurrentPage != None)
	{
		CurrentPage.Close(true);
		CurrentPage = None;
	}*/

	class'WFGameMenu'.static.GetTiledSegmentScale(Root, W, H);

	XMod = 4*W;
	YMod = 3*H;

	SelectedPage = PageNum;
	//CurrentPage = WFGameMenuPage(CreateWindow(Pages[PageNum], PageX/1024.0 * XMod, PageY/768.0 * YMod, PageWidth/1024.0 * XMod, PageHeight/768.0 * YMod, OwnerWindow));
	CurrentPage = WFGameMenuPage(ScrollArea.SetClientArea(Pages[PageNum]));
}

function BeforePaint(Canvas C, float X, float Y)
{
	local float Xs, Ys;
	local int i;
	local int W, H;
	local float XWidth, YHeight, XMod, YMod, XPos, YPos;

	Super.BeforePaint(C, X, Y);

	class'WFGameMenu'.static.GetTiledSegmentScale(Root, W, H);

	XMod = 4*W;
	YMod = 3*H;

	// button 1
	XPos = Button1X/1024.0 * XMod;
	YPos = Button1Y/768.0 * YMod;
	XWidth = ButtonWidth/1024.0 * XMod;
	YHeight = ButtonHeight/768.0 * YMod;
	Button1.SetSize(XWidth, YHeight);
	Button1.WinLeft = XPos;
	Button1.WinTop = YPos;

	// button 2
	XPos = Button2X/1024.0 * XMod;
	YPos = Button2Y/768.0 * YMod;
	Button2.SetSize(XWidth, YHeight);
	Button2.WinLeft = XPos;
	Button2.WinTop = YPos;

	// current page
	if (CurrentPage != None)
	{
		XPos = PageX/1024.0 * XMod;
		YPos = PageY/768.0 * YMod;
		XWidth = PageWidth/1024.0 * XMod;
		YHeight = PageHeight/768.0 * YMod;
		ScrollArea.WinTop = YPos;
		ScrollArea.WinLeft = XPos;
		if ((ScrollArea.WinWidth != XWidth) || (ScrollArea.WinHeight != YHeight))
			ScrollArea.SetSize(XWidth, YHeight);
	}
}

function Resized()
{
	local int W, H;
	local float XWidth, YHeight, XMod, YMod, XPos, YPos;

	class'WFGameMenu'.static.GetTiledSegmentScale(Root, W, H);

	XMod = 4*W;
	YMod = 3*H;

	// button 1
	XPos = Button1X/1024.0 * XMod;
	YPos = Button1Y/768.0 * YMod;
	XWidth = ButtonWidth/1024.0 * XMod;
	YHeight = ButtonHeight/768.0 * YMod;
	Button1.SetSize(XWidth, YHeight);
	Button1.WinLeft = XPos;
	Button1.WinTop = YPos;
	Button1.MyFont = class'UTLadderStub'.Static.GetStubClass().Static.GetBigFont(Root);

	// button 2
	XPos = Button2X/1024.0 * XMod;
	YPos = Button2Y/768.0 * YMod;
	Button2.SetSize(XWidth, YHeight);
	Button2.WinLeft = XPos;
	Button2.WinTop = YPos;
	Button2.MyFont = class'UTLadderStub'.Static.GetStubClass().Static.GetBigFont(Root);

	// current page
	if (CurrentPage != None)
	{
		XPos = PageX/1024.0 * XMod;
		YPos = PageY/768.0 * YMod;
		XWidth = PageWidth/1024.0 * XMod;
		YHeight = PageHeight/768.0 * YMod;
		ScrollArea.WinTop = YPos;
		ScrollArea.WinLeft = XPos;
		if ((ScrollArea.WinWidth != XWidth) || (ScrollArea.WinHeight != YHeight))
			ScrollArea.SetSize(XWidth, YHeight);
	}
}

function ResolutionChanged(float W, float H)
{
	Resized();
	super.ResolutionChanged(W, H);
}

function Paint(Canvas C, float X, float Y)
{
	local int W, H;
	local float XMod, YMod;

	super.Paint(C, X, Y);

	class'WFGameMenu'.static.GetTiledSegmentScale(Root, W, H);

	bLeaveOnScreen=True;

	XMod = 4*W;
	YMod = 3*H;

	// Background
	DrawBackGround(C, XMod/1024.0, YMod/768.0);
}

function Notify(UWindowWindow Window, byte E)
{
	if (E == DE_Click)
	{
		switch (Window)
		{
			case Button1:
				if (SelectedButton != Button1)
				{
					SelectButton(Button1);
					DisplayPage(LeftButtonNum);
				}
				break;

			case Button2:
				if (SelectedButton != Button2)
				{
					SelectButton(Button2);
					DisplayPage(LeftButtonNum + 1);
				}
				break;

			case Button3:
				if (SelectedButton != Button3)
				{
					SelectButton(Button3);
					DisplayPage(LeftButtonNum + 2);
				}
				break;

		}
	}
}

function SelectButton(NotifyButton Button)
{
	if (SelectedButton != None)
	{
		SelectedButton.bDisabled = false;
		SelectedButton.SetTextColor(IdleColor);
	}

	SelectedButton = Button;
	if (SelectedButton != None)
	{
		SelectedButton.bDisabled = true;
		SelectedButton.SetTextColor(SelectedColor);
	}
}

function AfterPaint(Canvas C, float X, float Y)
{
	local float XMod, YMod;
	local int W, H;

	super.AfterPaint(C, X, Y);

	class'WFGameMenu'.static.GetTiledSegmentScale(Root, W, H);
	XMod = 4*W;
	YMod = 3*H;

	DrawInnerBorder(C, XMod/1024.0, YMod/768.0);
}

function DrawInnerBorder(canvas C, float XMod, float YMod)
{
	local bool bOldSmooth;

	if (ScrollArea == None)
		return;

	bOldSmooth = C.bNoSmooth;
	C.bNoSmooth = True;
	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;

	// topleft inner corner
	DrawStretchedTextureSegment(C, ScrollArea.WinLeft, ScrollArea.WinTop, 11.0*XMod, 11.0*YMod,
		InnerCornerTL.X, InnerCornerTL.Y, InnerCornerTL.W, InnerCornerTL.H, Texture'WFInfoPanelMap');

	// topright inner corner
	DrawStretchedTextureSegment(C, ScrollArea.WinLeft + ScrollArea.WinWidth - 11.0*XMod, ScrollArea.WinTop, 11.0*XMod, 11.0*YMod,
		InnerCornerTR.X, InnerCornerTR.Y, InnerCornerTR.W, InnerCornerTR.H, Texture'WFInfoPanelMap');

	// bottomleft inner corner
	DrawStretchedTextureSegment(C, ScrollArea.WinLeft, ScrollArea.WinTop + ScrollArea.WinHeight - 11.0*YMod, 11.0*XMod, 11.0*YMod,
		InnerCornerBL.X, InnerCornerBL.Y, InnerCornerBL.W, InnerCornerBL.H, Texture'WFInfoPanelMap');

	// bottomright inner corner
	DrawStretchedTextureSegment(C, ScrollArea.WinLeft + ScrollArea.WinWidth - 11.0*XMod, ScrollArea.WinTop + ScrollArea.WinHeight - 11.0*YMod, 11.0*XMod, 11.0*YMod,
		InnerCornerBR.X, InnerCornerBR.Y, InnerCornerBR.W, InnerCornerBR.H, Texture'WFInfoPanelMap');

	C.bNoSmooth = bOldSmooth;
}

function DrawBackground(canvas C, float XMod, float YMod)
{
	local bool bOldSmooth;

	bOldSmooth = C.bNoSmooth;
	C.bNoSmooth = True;

	// topleft outer corner
	DrawStretchedTextureSegment(C, 0, 0, (35.0*XMod)+1, 30.0*YMod,
		OuterCornerTL.X, OuterCornerTL.Y, OuterCornerTL.W, OuterCornerTL.H, Texture'WFInfoPanelMap');

	// topright outer corner
	DrawStretchedTextureSegment(C, WinWidth - 35.0*XMod, 0, 35.0*XMod, 30.0*YMod,
		OuterCornerTR.X, OuterCornerTR.Y, OuterCornerTR.W, OuterCornerTR.H, Texture'WFInfoPanelMap');

	// bottomleft outer corner
	DrawStretchedTextureSegment(C, 0, WinHeight - 30.0*YMod, (35.0*XMod)+1, 30.0*YMod,
		OuterCornerBL.X, OuterCornerBL.Y, OuterCornerBL.W, OuterCornerBL.H, Texture'WFInfoPanelMap');

	// bottomright outer corner
	DrawStretchedTextureSegment(C, WinWidth - 35.0*XMod, WinHeight - 30.0*YMod, 35.0*XMod, 30.0*YMod,
		OuterCornerBR.X, OuterCornerBR.Y, OuterCornerBR.W, OuterCornerBR.H, Texture'WFInfoPanelMap');

	// top and bottom border
	DrawStretchedTextureSegment(C, (35.0*XMod), 0, WinWidth - 35.0*XMod*2.0, WinHeight,
		OuterPanelArea.X, OuterPanelArea.Y, OuterPanelArea.W, OuterPanelArea.H, Texture'WFInfoPanelMap');

	// left border
	DrawStretchedTextureSegment(C, 0, 30.0*YMod, 35.0*XMod, WinHeight - 30.0*YMod*2.0,
		OuterPanelArea.X, OuterPanelArea.Y, OuterPanelArea.W, OuterPanelArea.H, Texture'WFInfoPanelMap');

	// right border
	DrawStretchedTextureSegment(C, WinWidth - 35.0*XMod, 30.0*YMod, 35.0*XMod, WinHeight - 30.0*YMod*2.0,
		OuterPanelArea.X, OuterPanelArea.Y, OuterPanelArea.W, OuterPanelArea.H, Texture'WFInfoPanelMap');

	C.bNoSmooth = bOldSmooth;
}

defaultproperties
{
	OuterCornerTL=(X=0,Y=0,W=35,H=30)
	OuterCornerTR=(X=35,Y=0,W=35,H=30)
	OuterCornerBL=(X=0,Y=30,W=35,H=30)
	OuterCornerBR=(X=35,Y=30,W=35,H=30)
	InnerCornerTL=(X=70,Y=0,W=11,H=11)
	InnerCornerTR=(X=81,Y=0,W=11,H=11)
	InnerCornerBL=(X=70,Y=11,W=11,H=11)
	InnerCornerBR=(X=81,Y=11,W=11,H=11)
	OuterPanelArea=(X=82,Y=24,W=1,H=1)
	MenuWidth=585
	MenuHeight=415
	ButtonWidth=159
	ButtonHeight=51
	Button1X=40
	Button1Y=9
	Button2X=226
	Button2Y=9
	PageX=24
	PageY=81
	PageWidth=540
	PageHeight=301
	BG1(0)=Texture'WFInfoPanelBG11'
	BG1(1)=Texture'WFInfoPanelBG12'
	BG1(2)=Texture'WFInfoPanelBG13'
	BG2(0)=Texture'WFInfoPanelBG21'
	BG2(1)=Texture'WFInfoPanelBG22'
	BG2(2)=Texture'WFInfoPanelBG23'
	SelectedColor=(R=255,G=255,B=255)
	IdleColor=(R=255,G=255)
	//Pages(0)=class'testpage1'
	Pages(0)=class'WFTeamSetupPage'
	//Pages(1)=class'testpage2'
	Pages(1)=class'WFClassSetupPage'
}
