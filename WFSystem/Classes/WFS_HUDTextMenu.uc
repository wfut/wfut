//=============================================================================
// WFS_HUDTextMenu.
// A number driven text menu.
//=============================================================================
class WFS_HUDTextMenu extends WFS_HUDMenuInfo;

var() string		MenuOptions[10];
var() string		MenuTitle;
var() string		SeparatorString;

var() bool			bAlignAppendString;
var() bool 			bUseColors;
var() color			MenuOptionColors[10];
var() int			NumOptions;
var() color			MenuTitleColor;
var() float			TitleOffsetScale;

var() bool			bUseTeamColor;

var() color			BorderColor;
var() bool			bBorder3D;
var() bool			bBorderUseTeamColor;
var() int			BorderSize;
var() int			BorderSpacing;

var color			TeamColor[4];
var color			AltTeamColor[4];
var color			DefaultColor;

var color			GreyColor;
var color			WhiteColor;

function DisplayMenu(canvas Canvas)
{
	local int num, i;
	local float XL, YL, YOffset, XLMax, YPos, MaxTextWidth;
	local string MenuString;
	local color OldColor;

	if (ChildMenu != none)
	{
		ChildMenu.DisplayMenu(Canvas);
		return;
	}

	MenuDisplaySetup(Canvas);

	Canvas.StrLen("TEST", XL, YL);
	YOffset = YL;

	XLMax = GetLongestStringWidth(Canvas);

	// draw the background
	DrawBackground(Canvas);

	// draw title string
	if (bUseColors)
		Canvas.DrawColor = GetTitleStringColor();
	else Canvas.DrawColor = DefaultColor;
	Canvas.StrLen(MenuTitle, XL, YL);
	Canvas.SetPos(Canvas.ClipX/2 - XL/2, (Canvas.ClipY/2 - ((NumOptions/2)*YOffset)) - (YOffset*(1.0+TitleOffsetScale)));
	Canvas.DrawText(MenuTitle);

	// draw options
	for (i=0; i<10; i++)
	{
		if ((MenuOptions[i] != "") || (MenuOptions[i] == " "))
		{
			if (MenuOptions[i] != " ")
			{
				if (bAlignAppendString)
					MenuString = GetBaseStringForOption(i) $ MenuOptions[i];
				else
					MenuString = GetBaseStringForOption(i) $ MenuOptions[i] $ GetAppendStringForOption(i);
			}
			else MenuString = " ";
			if (bUseColors)
				Canvas.DrawColor = GetOptionStringColor(i);
			else Canvas.DrawColor = DefaultColor;
			YPos = (Canvas.ClipY/2 - ((NumOptions/2) * YOffset)) + YOffset*num;
			Canvas.SetPos(Canvas.ClipX/2 - (XLMax/2), YPos);
			Canvas.DrawText(MenuString);

			// right align the append string for this option
			if (bAlignAppendString && (MenuOptions[i] != " "))
			{
				if (bUseColors)
					Canvas.DrawColor = GetAppendStringColor(i);
				else Canvas.DrawColor = DefaultColor;
				MenuString = GetAppendStringForOption(i);
				Canvas.StrLen(MenuString, XL, YL);
				Canvas.SetPos(Canvas.ClipX/2 + (XLMax/2) - XL, YPos);
				Canvas.DrawText(MenuString);
			}

			num++;
		}
	}
}

function DrawBackground(canvas Canvas)
{
	local float XLMax, Width, Height, PosX, PosY, XL, YL;

	Canvas.StrLen("TEST", XL, YL);

	XLMax = GetLongestStringWidth(Canvas, true);
	PosX = Canvas.ClipX/2 - XLMax/2 - BorderSpacing;
	Width = XLMax + BorderSpacing*2;

	if (MenuTitle != "")
	{
		PosY = (Canvas.ClipY/2 - ((NumOptions/2)*YL)) - (YL*(1.0+TitleOffsetScale)) - BorderSpacing;
		Height = NumOptions*YL + YL*1.5 + BorderSpacing*2;
	}
	else
	{
		PosY = (Canvas.ClipY/2 - ((NumOptions/2)*YL)) - BorderSpacing;
		Height = NumOptions*YL + BorderSpacing*2;
	}

	Canvas.SetPos(PosX, PosY);
	Canvas.Style = ERenderStyle.STY_Modulated;
	Canvas.DrawRect(texture'bgtex1', Width, Height);
	Canvas.Style = ERenderStyle.STY_Normal;

	// draw the border
	DrawBorder(Canvas, PosX, PosY, Width, Height);
}

function DrawBorder(canvas Canvas, float PosX, float PosY, float Width, float Height)
{
	local color BaseColor, LightColor, DarkColor;

	BaseColor = GetBorderColor();
	Canvas.DrawColor = BaseColor;
	// top
	Canvas.SetPos(PosX, PosY);
	Canvas.DrawRect(texture'bordertex1', Width, BorderSize);
	// left
	Canvas.SetPos(PosX, PosY + BorderSize);
	Canvas.DrawRect(texture'bordertex1', BorderSize, Height - BorderSize*2);
	// right
	Canvas.SetPos(PosX + Width - BorderSize, PosY + BorderSize);
	Canvas.DrawRect(texture'bordertex1', BorderSize, Height - BorderSize*2);
	// bottom
	Canvas.SetPos(PosX, PosY + Height - BorderSize);
	Canvas.DrawRect(texture'bordertex1', Width, BorderSize);

	if (bBorder3D)
	{
		// set up the border colors
		if (bBorderUseTeamColor)
			LightColor = GetColorForTeam(PlayerOwner.PlayerReplicationInfo.Team);
		else
		{
			LightColor.R = Min(1.5 * BaseColor.R, 255);
			LightColor.G = Min(1.5 * BaseColor.G, 255);
			LightColor.B = Min(1.5 * BaseColor.B, 255);
		}
		DarkColor = 0.5 * BaseColor;

		// draw the inner rect
		Canvas.DrawColor = DarkColor;
		Canvas.SetPos(PosX + BorderSize, PosY + BorderSize);
		Canvas.DrawRect(texture'bordertex1', Width - BorderSize*2 - 1, 1);

		Canvas.DrawColor = DarkColor;
		Canvas.SetPos(PosX + BorderSize, PosY + BorderSize + 1);
		Canvas.DrawRect(texture'bordertex1', 1, Height - BorderSize*2 - 2);

		Canvas.DrawColor = LightColor;
		Canvas.SetPos(PosX + Width - BorderSize - 1, PosY + BorderSize);
		Canvas.DrawRect(texture'bordertex1', 1, Height - BorderSize * 2 - 1);

		Canvas.DrawColor = LightColor;
		Canvas.SetPos(PosX + BorderSize, PosY + Height - BorderSize - 1);
		Canvas.DrawRect(texture'bordertex1', Width - BorderSize*2, 1);

		// draw the outer rect
		Canvas.DrawColor = LightColor;
		Canvas.SetPos(PosX - 1, PosY - 1);
		Canvas.DrawRect(texture'bordertex1', Width + 1, 1);

		Canvas.DrawColor = LightColor;
		Canvas.SetPos(PosX - 1, PosY);
		Canvas.DrawRect(texture'bordertex1', 1, Height);

		Canvas.DrawColor = DarkColor;
		Canvas.SetPos(PosX + Width, PosY - 1);
		Canvas.DrawRect(texture'bordertex1', 1, Height + 1);

		Canvas.DrawColor = DarkColor;
		Canvas.SetPos(PosX - 1, PosY + Height);
		Canvas.DrawRect(texture'bordertex1', Width + 2, 1);
	}
}

function string GetBaseStringForOption(int num)
{
	if (num == 9) return "0"$SeparatorString;
	else return num+1$SeparatorString;
}

function MenuDisplaySetup(canvas Canvas)
{
	Canvas.DrawColor = class'ChallengeHUD'.default.WhiteColor;
	Canvas.Font = OwnerHUD.MyFonts.GetBigFont(Canvas.ClipX);
}

function color GetOptionStringColor(int num)
{
	if (bUseTeamColor)
		return GetColorForTeam(PlayerOwner.PlayerReplicationInfo.Team);
	return MenuOptionColors[num];
}

function color GetAppendStringColor(int num)
{
	if (bUseTeamColor)
		return GetColorForTeam(PlayerOwner.PlayerReplicationInfo.Team);
	return MenuOptionColors[num];
}

function color GetTitleStringColor()
{
	if (bUseTeamColor)
		return GetColorForTeam(PlayerOwner.PlayerReplicationInfo.Team);
	return MenuTitleColor;
}

function color GetColorForTeam(byte TeamNum, optional bool bAltColor)
{
	if (TeamNum < 4)
	{
		if (bAltColor)
			return AltTeamColor[TeamNum];
		return TeamColor[TeamNum];
	}

	if (bAltColor)
		return GreyColor;
	return WhiteColor;
}

function color GetBorderColor()
{
	if (bBorderUseTeamColor)
		return GetColorForTeam(PlayerOwner.PlayerReplicationInfo.Team, bBorder3D);
	else
		return BorderColor;
}

function string GetAppendStringForOption(int num)
{
	return "";
}

function float GetLongestStringWidth(canvas Canvas, optional bool bIncludeTitle)
{
	local float best, XL, YL;
	local int i;

	if (bIncludeTitle)
	{
		Canvas.StrLen(MenuTitle, XL, YL);
		best = XL;
	}
	else best = 0.0;

	for (i=0; i<10; i++)
	{
		Canvas.StrLen(GetBaseStringForOption(i)$MenuOptions[i]$GetAppendStringForOption(i), XL, YL);
		if (XL > best) best = XL;
	}

	return best;
}

defaultproperties
{
	MenuTitleColor=(R=255,G=255,B=255)
	MenuOptionColors(0)=(R=255,G=255,B=255)
	MenuOptionColors(1)=(R=255,G=255,B=255)
	MenuOptionColors(2)=(R=255,G=255,B=255)
	MenuOptionColors(3)=(R=255,G=255,B=255)
	MenuOptionColors(4)=(R=255,G=255,B=255)
	MenuOptionColors(5)=(R=255,G=255,B=255)
	MenuOptionColors(6)=(R=255,G=255,B=255)
	MenuOptionColors(7)=(R=255,G=255,B=255)
	MenuOptionColors(8)=(R=255,G=255,B=255)
	MenuOptionColors(9)=(R=255,G=255,B=255)
	TeamColor(0)=(R=255,G=0,B=0)
	TeamColor(1)=(R=0,G=128,B=255)
	TeamColor(2)=(R=0,G=255,B=0)
	TeamColor(3)=(R=255,G=255,B=0)
	AltTeamColor(0)=(R=200)
	AltTeamColor(1)=(G=94,B=187)
	AltTeamColor(2)=(G=128)
	AltTeamColor(3)=(R=255,G=255,B=128)
	BorderColor=(R=128,G=128,B=128)
	DefaultColor=(R=255,G=255,B=255)
	GreyColor=(R=128,G=128,B=128)
	WhiteColor=(R=255,G=255,B=255)
	BorderSize=1
	BorderSpacing=8
	TitleOffsetScale=0.500000
	bBorder3D=True
	SeparatorString=": "
}
