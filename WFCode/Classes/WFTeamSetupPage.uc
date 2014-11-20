class WFTeamSetupPage extends WFGameMenuPage;

// TODO: "View" button for viewing team members at low-res

var float LastUpdate;
var float UpdateTime;

var string TeamNames[5];
var color TeamColors[5];
//var WFTextListBox TeamList, PlayerList;
var WFFramedTextListBox TeamList, PlayerList;

var UWindowControlFrame TeamListFrame, PlayerListFrame;
//var UWindowSmallButton JoinTeamButton, AutoTeamButton;
var WFNotifyButton JoinTeamButton, AutoTeamButton;

var WFLabelControl TeamLabel, PlayerLabel;

var int MaxTeams;

// list box texture regions (list boxes are positioned relative to this)
// 217x210 + 24x81 = 241x291 <- this Top-Left page location at 1024x768
var region TeamListRegion, TeamListRegionLowRes, PlayerListRegion;

var font ComponentFont; // font used by listboxes and small buttons

var float LabelX, LabelWidth;
var float SButtonWidth, SButtonHeight;
var float JoinTeamButtonY, AutoTeamButtonY;

var string CurrentTeamPrefix, CurrentTeamAppend;

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

	// create team listbox
	TeamList = WFFramedTextListBox(CreateControl(class'WFFramedTextListBox', 16, 24, 120, 80, self));
	TeamList.Register(self);
	TeamList.SetText("Team List:");
	TeamList.SetTextColor(class'ChallengeHUD'.default.WhiteColor);

	// create player listbox
	PlayerList = WFFramedTextListBox(CreateControl(class'WFFramedTextListBox', 180, 24, 120, 150, self));
	PlayerList.Register(self);
	PlayerList.SetText("Player List:");
	PlayerList.SetTextColor(class'ChallengeHUD'.default.WhiteColor);
	if (IsLowRes())
		PlayerList.HideWindow();

	// Team Button
	XPos = 50/1024.0 * XMod;
	YPos = JoinTeamButtonY/768.0 * YMod;
	XWidth = SButtonWidth/1024.0 * XMod;
	YHeight = SButtonHeight/768.0 * YMod;
	TextureRegion.W = SButtonWidth;
	TextureRegion.H = SButtonHeight;

	JoinTeamButton = WFNotifyButton(CreateWindow(class'WFNotifyButton', XPos, YPos, XWidth, YHeight));
	JoinTeamButton.DisabledTexture = Texture'WFSmallBtnIdle';
	JoinTeamButton.UpTexture = Texture'WFSmallBtnIdle';
	JoinTeamButton.DownTexture = Texture'WFSmallBtnSelect';
	JoinTeamButton.OverTexture = Texture'WFSmallBtnOver';
	JoinTeamButton.bUseRegion = True;
	JoinTeamButton.UpRegion = TextureRegion;
	JoinTeamButton.DownRegion = TextureRegion;
	JoinTeamButton.DisabledRegion = TextureRegion;
	JoinTeamButton.OverRegion = TextureRegion;
	JoinTeamButton.DialogNotifyWindow = Self;
	if (Root.WinWidth < 512) JoinTeamButton.Text = "Join";
	else JoinTeamButton.Text = "Join Team";
	JoinTeamButton.SetTextColor(class'ChallengeHUD'.default.WhiteColor);
	JoinTeamButton.MyFont = class'UTLadderStub'.Static.GetStubClass().Static.GetSmallFont(Root);
	JoinTeamButton.bStretched = True;
	JoinTeamButton.OverSound = sound'LadderSounds.lcursorMove';
	JoinTeamButton.DownSound = sound'LadderSounds.lcursorMove';


	// Auto Team Button
	YPos = AutoTeamButtonY/768.0 * YMod;
	AutoTeamButton = WFNotifyButton(CreateWindow(class'WFNotifyButton', XPos, YPos, XWidth, YHeight));
	AutoTeamButton.DisabledTexture = Texture'WFSmallBtnIdle';
	AutoTeamButton.UpTexture = Texture'WFSmallBtnIdle';
	AutoTeamButton.DownTexture = Texture'WFSmallBtnSelect';
	AutoTeamButton.OverTexture = Texture'WFSmallBtnOver';
	AutoTeamButton.bUseRegion = True;
	AutoTeamButton.UpRegion = TextureRegion;
	AutoTeamButton.DownRegion = TextureRegion;
	AutoTeamButton.DisabledRegion = TextureRegion;
	AutoTeamButton.OverRegion = TextureRegion;
	AutoTeamButton.DialogNotifyWindow = Self;
	if (Root.WinWidth < 512) AutoTeamButton.Text = "Auto";
	else AutoTeamButton.Text = "Auto Team";
	AutoTeamButton.SetTextColor(class'ChallengeHUD'.default.WhiteColor);
	AutoTeamButton.MyFont = class'UTLadderStub'.Static.GetStubClass().Static.GetSmallFont(Root);
	AutoTeamButton.bStretched = True;
	AutoTeamButton.OverSound = sound'LadderSounds.lcursorMove';
	AutoTeamButton.DownSound = sound'LadderSounds.lcursorMove';

	UpdateMenuInfo();
}

/*function DrawListBoxTexture(canvas C, float X, float Y, float W, float H, float XScale, float YScale)
{
	DrawStretchedTextureSegment(C, X, Y, W*XScale, 32.0*YScale, ListBoxTextureTop.X, ListBoxTextureTop.Y, ListBoxTextureTop.W, ListBoxTextureTop.H, Texture'WFListBoxMap');
	DrawStretchedTextureSegment(C, X, Y+(32.0*YScale), W*XScale, (H-48.0)*YScale, ListBoxTextureMid.X, ListBoxTextureMid.Y, ListBoxTextureMid.W, ListBoxTextureMid.H, Texture'WFListBoxMap');
	DrawStretchedTextureSegment(C, X, Y+((H-16.0)*YScale), W*XScale, 16.0*YScale, ListBoxTextureBottom.X, ListBoxTextureBottom.Y, ListBoxTextureBottom.W, ListBoxTextureBottom.H, Texture'WFListBoxMap');
}*/

function BeforePaint(Canvas C, float X, float Y)
{
	local int W, H;
	local float XMod, YMod, XL, YL, XPos, YPos;

	Super.BeforePaint(C, X, Y);

	class'WFGameMenu'.static.GetTiledSegmentScale(Root, W, H);

	XMod = W*4/1024.0;
	YMod = H*3/768.0;

	ComponentFont = class'UTLadderStub'.Static.GetStubClass().Static.GetSmallFont(Root);

	if (IsLowRes())
	{
		TeamList.WinLeft = (WinWidth/2) - (TeamListRegionLowRes.W*XMod/2);
		TeamList.WinTop = TeamListRegion.Y*YMod;
		XL = TeamListRegionLowRes.W * XMod;
		YL = TeamListRegionLowRes.H * YMod;
		if ((TeamList.WinWidth != XL) || (TeamList.WinHeight != YL))
			TeamList.SetSize(XL, YL);
	}
	else
	{
		TeamList.WinLeft = TeamListRegion.X*XMod;
		TeamList.WinTop = TeamListRegion.Y*YMod;
		XL = TeamListRegion.W * XMod;
		YL = TeamListRegion.H * YMod;
		if ((TeamList.WinWidth != XL) || (TeamList.WinHeight != YL))
			TeamList.SetSize(XL, YL);
	}

	if (IsLowRes())
	{
		if (PlayerList.bWindowVisible)
			PlayerList.HideWindow();
	}
	else
	{
		if (!PlayerList.bWindowVisible)
			PlayerList.ShowWindow();
		PlayerList.WinLeft = PlayerListRegion.X*XMod;
		PlayerList.WinTop = PlayerListRegion.Y*YMod;
		XL = PlayerListRegion.W * XMod;
		YL = PlayerListRegion.H * YMod;
		if ((PlayerList.WinWidth != XL) || (PlayerList.WinHeight != YL))
			PlayerList.SetSize(XL, YL);
	}

	if (IsLowRes())
	{
		XPos = TeamList.WinLeft;
		YPos = AutoTeamButtonY * YMod;
	}
	else
	{
		XPos = TeamList.WinLeft + (TeamList.WinWidth/2) - (JoinTeamButton.WinWidth/2);
		YPos = JoinTeamButtonY * YMod;
	}
	XL = SButtonWidth * XMod;
	YL = SButtonHeight * YMod;
	JoinTeamButton.SetSize(XL, YL);
	JoinTeamButton.WinLeft = XPos;
	JoinTeamButton.WinTop = YPos;
	JoinTeamButton.MyFont = ComponentFont;
	if (Root.WinWidth < 512) JoinTeamButton.Text = "Join";
	else JoinTeamButton.Text = "Join Team";

	if (IsLowRes())
		XPos = TeamList.WinLeft + TeamList.WinWidth - XL;
	else YPos = AutoTeamButtonY * YMod;
	AutoTeamButton.SetSize(XL, YL);
	AutoTeamButton.WinLeft = XPos;
	AutoTeamButton.WinTop = YPos;
	AutoTeamButton.MyFont = ComponentFont;
	if (Root.WinWidth < 512) AutoTeamButton.Text = "Auto";
	else AutoTeamButton.Text = "Auto Team";
}

function bool IsLowRes()
{
	return Root.WinWidth < 400;
}

function UpdateMenuInfo()
{
	local WFTextList L;
	local int i, Team, PlayerTeam;
	local WFGameGRI GRI;
	local string s1, s2;
	local playerpawn p;

	p = GetPlayerOwner();
	if (p == None)
		return;

	// TESTME: this might not be accessable when the menu is created so might
	//         have to do periodic checks while the menu is being displayed
	GRI = WFGameGRI(p.GameReplicationInfo);
	if (GRI == None)
		return;
	MaxTeams = GRI.MaxTeams;

	// get team names
	for (i=0; i<MaxTeams; i++)
	{
		if (GRI.Teams[i] != None)
			TeamNames[i] = GRI.Teams[i].TeamName;
		else TeamNames[i] = "";
	}

	PlayerTeam = -1;
	if (p.PlayerReplicationInfo != None)
	{
		PlayerTeam = p.PlayerReplicationInfo.Team;
		if ((MaxTeams > 1) && (PlayerTeam >= MaxTeams))
			PlayerTeam = 4;
	}

	/* -- debug --
	TeamNames[0] = "Red";
	TeamNames[1] = "Blue";
	TeamNames[2] = "Green";
	TeamNames[3] = "Gold";
	TeamNames[4] = "Spectating";
	// ----------- */

	if (TeamList.ListBox.SelectedItem != None)
		Team = WFTextList(TeamList.ListBox.SelectedItem).Value;
	TeamList.ListBox.Items.Clear();
	TeamList.ListBox.SelectedItem = None;
	for (i=0; i<5; i++)
	{
		if (TeamNames[i] != "")
		{
			if (PlayerTeam == i)
			{
				s1 = CurrentTeamPrefix;
				s2 = CurrentTeamAppend;
			}
			else
			{
				s1 = "";
				s2 = "";
			}
			L = WFTextList(TeamList.ListBox.Items.Append(class'WFTextList'));
			if (i != 4)
				L.Text = s1 $ TeamNames[i] $ s2 $ "  ["$GRI.Teams[i].Size$"]";
			else L.Text = s1 $ TeamNames[i] $ s2;
			L.TextColor = TeamColors[i];
			L.Value = i; // team number
			if (i == Team)
				TeamList.ListBox.SetSelectedItem(L);
		}
	}
}

function UpdatePlayerList()
{
	local WFTextList L;
	local int i, Team, SelectedID;
	local playerpawn PPawn;
	local PlayerReplicationInfo PRI;

	if (TeamList.ListBox.SelectedItem == None)
		return;

	PPawn = Root.GetPlayerOwner();
	if (PPawn == None)
		return;

	Team = WFTextList(TeamList.ListBox.SelectedItem).Value;

	SelectedID = -1;
	if (PlayerList.ListBox.SelectedItem != None)
		SelectedID = WFTextList(PlayerList.ListBox.SelectedItem).Value;

	PlayerList.ListBox.Items.Clear();
	PlayerList.ListBox.SelectedItem = None;
	foreach PPawn.AllActors(class'PlayerReplicationInfo', PRI)
	{
		if ((PRI != None) && !(PRI.PlayerName ~= "Player")
			&& ((PRI.Team == Team) || ((Team == 4) && (PRI.Team == 255))) )
		{
			L = WFTextList(PlayerList.ListBox.Items.Append(class'WFTextList'));
			L.Text = PRI.PlayerName;
			L.TextColor = TeamColors[Team];
			L.Value = PRI.PlayerID;
			if (PRI.PlayerID == SelectedID)
				PlayerList.ListBox.SetSelectedItem(L);
		}
	}
}

function Notify(UWindowDialogControl C, byte E)
{
	local int NewTeam, Team;

	if (E == DE_Click)
	{
		if (TeamList.ListBox.SelectedItem != None)
			NewTeam = WFTextList(TeamList.ListBox.SelectedItem).Value;
		Team = Root.GetPlayerOwner().PlayerReplicationInfo.Team;

		switch (C)
		{
			case TeamList:
				UpdatePlayerList();
				if ((TeamList.ListBox.SelectedItem == None) || (WFTextList(TeamList.ListBox.SelectedItem).Value == 4))
				{
					JoinTeamButton.bDisabled = true;
					JoinTeamButton.TextColor.R = 128;
					JoinTeamButton.TextColor.G = 128;
					JoinTeamButton.TextColor.B = 128;
				}
				else
				{
					JoinTeamButton.bDisabled = false;
					JoinTeamButton.TextColor = class'ChallengeHUD'.default.WhiteColor;
				}
				break;
			case JoinTeamButton:
				if ( (TeamList.ListBox.SelectedItem != None) && (NewTeam != Team) && (NewTeam < 4) )
					Root.GetPlayerOwner().ChangeTeam(NewTeam);
				break;
			case AutoTeamButton:
				if (Team >= MaxTeams)
					Root.GetPlayerOwner().ChangeTeam(255);
				break;
		}
	}

	super.Notify(C, E);
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
		UpdateMenuInfo();
	}
}

/*function WindowEvent(WinMessage Msg, Canvas C, float X, float Y, int Key)
{
	if (Msg == WM_KeyDown)
	{
		if (string(Key) ~= "J")
			Notify(JoinTeamButton, DE_Click);
		else if (string(Key) ~= "A")
			Notify(AutoTeamButton, DE_Click);
	}

	super.WindowEvent(Msg, C, X, Y, Key);
}*/

defaultproperties
{
	TeamColors(0)=(R=255,B=0,G=0)
	TeamColors(1)=(R=0,B=255,G=128)
	TeamColors(2)=(R=0,B=0,G=255)
	TeamColors(3)=(R=255,B=0,G=255)
	TeamColors(4)=(R=255,B=255,G=255)
	TeamNames(4)="Spectating"
	UpdateTime=1
	MaxTeams=-1
	//TeamListRegion=(X=262,Y=309,W=224,H=167)
	TeamListRegion=(X=21,Y=18,W=224,H=167)
	TeamListRegionLowRes=(X=21,Y=18,W=400,H=210)
	//PlayerListRegion=(X=529,Y=309,W=224,H=263)
	PlayerListRegion=(X=288,Y=18,W=224,H=263)
	JoinTeamButtonY=200
	AutoTeamButtonY=246
	SButtonWidth=125
	SButtonHeight=40
	CurrentTeamPrefix=">> "
	CurrentTeamAppend=""
}