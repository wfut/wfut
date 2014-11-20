//=============================================================================
// WFS_PCSystemHUD.
// Author: Ob1-Kenobi (ob1@planetunreal.com)
//=============================================================================
class WFS_PCSystemHUD extends ChallengeTeamHUD;

var class<WFS_HUDInfo>	ExtendedHUDClass;
var WFS_HUDInfo			ExtendedHUD;

var WFS_HUDMenuInfo		HUDMenu;

// TODO: Add more comments and group the functions together

//=============================================================================
// HUD Menu Functions.

function DisplayHUDMenu(class<WFS_HUDMenuInfo> HUDMenuClass, optional actor RelatedActor)
{
	if (HUDMenu != None)
		HUDMenu.CloseMenu(true);

	HUDMenu = spawn(HUDMenuClass);
	if (HUDMenu != none)
	{
		// set up the hud menu
		HUDMenu.OwnerHUD = self;
		HUDMenu.PlayerOwner = WFS_PCSystemPlayer(PlayerOwner);
		HUDMenu.RelatedActor = RelatedActor;
		HUDMenu.Initialise();
	}
}

function ClearHUDMenus()
{
	if (HUDMenu != none)
		HUDMenu.CloseMenu();
}

function HUDMenuSelection(byte Number)
{
	if (HUDMenu != none)
		HUDMenu.ProcessSelection(Number);
	else
	{
		Log("HUDMenu == None!");
		WFS_PCSystemPlayer(PlayerOwner).bHUDMenu = false;
	}
}

function bool ProcessKeyEvent( int Key, int Action, FLOAT Delta )
{
	Log("ProcessKeyEvent called");
	if ((PlayerOwner != none) && WFS_PCSystemPlayer(PlayerOwner).bHUDMenu)
	{
		Switch (Key)
		{
			case EInputKey.IK_1:
				HUDMenu.ProcessSelection(1);
				return true;
			case EInputKey.IK_2:
				HUDMenu.ProcessSelection(2);
				return true;
			case EInputKey.IK_3:
				HUDMenu.ProcessSelection(3);
				return true;
			case EInputKey.IK_4:
				HUDMenu.ProcessSelection(4);
				return true;
			case EInputKey.IK_5:
				HUDMenu.ProcessSelection(5);
				return true;
			case EInputKey.IK_6:
				HUDMenu.ProcessSelection(6);
				return true;
			case EInputKey.IK_7:
				HUDMenu.ProcessSelection(7);
				return true;
			case EInputKey.IK_8:
				HUDMenu.ProcessSelection(8);
				return true;
			case EInputKey.IK_9:
				HUDMenu.ProcessSelection(9);
				return true;
			case EInputKey.IK_0:
				HUDMenu.ProcessSelection(10);
				return true;
		}
	}

	return false;
}


//=============================================================================
// Dynamic HUD functions.

function ChangeExtendedHUD(class<WFS_HUDInfo> NewType)
{
	if (NewType != None)
	{
		if (ExtendedHUD != none)
			ExtendedHUD.Destroy();
		ExtendedHUD = spawn(NewType);
		if (ExtendedHUD != none)
		{
			ExtendedHUD.OwnerHUD = self;
			ExtendedHUD.Initialise();
		}
	}
}

//=============================================================================
// Message functions
//
// Note: The extended HUD info must call WFS_HUDInfo.UpdateHUDMessages() to update the
//       HUD message list after dealing with the message call or the messages
//       will not display correctly.

function UpdateExtendedHUDMessages()
{
	local int i;

	// update short message queue
	for (i=0; i<4; i++)
	{
		ExtendedHUD.SetShortMessage
		(
			i, ShortMessageQueue[i].Message,
			ShortMessageQueue[i].Switch,
			ShortMessageQueue[i].RelatedPRI,
			ShortMessageQueue[i].OptionalObject,
			ShortMessageQueue[i].EndOfLife,
			ShortMessageQueue[i].LifeTime,
			ShortMessageQueue[i].bDrawing,
			ShortMessageQueue[i].numLines,
			ShortMessageQueue[i].StringMessage,
			ShortMessageQueue[i].DrawColor,
			ShortMessageQueue[i].StringFont,
			ShortMessageQueue[i].XL,
			ShortMessageQueue[i].YL,
			ShortMessageQueue[i].YPos
		);
	}

	// update local messages
	for (i=0; i<10; i++)
	{
		ExtendedHUD.SetLocalMessage
		(
			i, LocalMessages[i].Message,
			LocalMessages[i].Switch,
			LocalMessages[i].RelatedPRI,
			LocalMessages[i].OptionalObject,
			LocalMessages[i].EndOfLife,
			LocalMessages[i].LifeTime,
			LocalMessages[i].bDrawing,
			LocalMessages[i].numLines,
			LocalMessages[i].StringMessage,
			LocalMessages[i].DrawColor,
			LocalMessages[i].StringFont,
			LocalMessages[i].XL,
			LocalMessages[i].YL,
			LocalMessages[i].YPos
		);
	}
}

function SetShortMessage
(
	int num,
	Class<LocalMessage> Message,
	int MsgSwitch,
	PlayerReplicationInfo RelatedPRI,
	Object OptionalObject,
	float EndOfLife,
	float LifeTime,
	bool bDrawing,
	int numLines,
	string StringMessage,
	color DrawColor,
	font StringFont,
	float XL,
	float YL,
	float YPos
)
{
	ShortMessageQueue[num].Message = Message;
	ShortMessageQueue[num].Switch = MsgSwitch;
	ShortMessageQueue[num].RelatedPRI = RelatedPRI;
	ShortMessageQueue[num].OptionalObject = OptionalObject;
	ShortMessageQueue[num].EndOfLife = EndOfLife;
	ShortMessageQueue[num].LifeTime = LifeTime;
	ShortMessageQueue[num].bDrawing = bDrawing;
	ShortMessageQueue[num].numLines = numLines;
	ShortMessageQueue[num].StringMessage = StringMessage;
	ShortMessageQueue[num].DrawColor = DrawColor;
	ShortMessageQueue[num].StringFont = StringFont;
	ShortMessageQueue[num].XL = XL;
	ShortMessageQueue[num].YL = YL;
	ShortMessageQueue[num].YPos = YPos;
}

function SetLocalMessage
(
	int num,
	Class<LocalMessage> Message,
	int MsgSwitch,
	PlayerReplicationInfo RelatedPRI,
	Object OptionalObject,
	float EndOfLife,
	float LifeTime,
	bool bDrawing,
	int numLines,
	string StringMessage,
	color DrawColor,
	font StringFont,
	float XL,
	float YL,
	float YPos
)
{
	LocalMessages[num].Message = Message;
	LocalMessages[num].Switch = MsgSwitch;
	LocalMessages[num].RelatedPRI = RelatedPRI;
	LocalMessages[num].OptionalObject = OptionalObject;
	LocalMessages[num].EndOfLife = EndOfLife;
	LocalMessages[num].LifeTime = LifeTime;
	LocalMessages[num].bDrawing = bDrawing;
	LocalMessages[num].numLines = numLines;
	LocalMessages[num].StringMessage = StringMessage;
	LocalMessages[num].DrawColor = DrawColor;
	LocalMessages[num].StringFont = StringFont;
	LocalMessages[num].XL = XL;
	LocalMessages[num].YL = YL;
	LocalMessages[num].YPos = YPos;
}

//=============================================================================
// Overridden HUD functions

simulated function PostRender(canvas Canvas)
{
	local byte bDisableFunction;

	if (ExtendedHUD != none)
		ExtendedHUD.PostRender(bDisableFunction, Canvas);

	if (!bool(bDisableFunction))
		super.PostRender(Canvas);

	// render the HUD menu
	if (HUDMenu != none)
		HUDMenu.DisplayMenu(Canvas);
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	if (ExtendedHUDClass != None)
	{
		ExtendedHUD = spawn(ExtendedHUDClass);

		if (ExtendedHUD != none)
		{
			ExtendedHUD.OwnerHUD = self;
			ExtendedHUD.Initialise();
		}
	}
}

/* debug
function Destroyed()
{
	if (ExtendedHUD != none)
		ExtendedHUD.Destroy();

	super.Destroyed();
}*/

function SetDamage(vector HitLoc, float damage)
{
	local byte bDisableFunction;

	if (ExtendedHUD != none)
	{
		ExtendedHUD.SetDamage(bDisableFunction, HitLoc, damage);
		if (bool(bDisableFunction))
			return;
	}

	super.SetDamage(HitLoc, Damage);
}

simulated function ChangeCrosshair(int d)
{
	local byte bDisableFunction;

	if (ExtendedHUD != none)
	{
		ExtendedHUD.ChangeCrosshair(bDisableFunction, d);
		if (bool(bDisableFunction))
			return;
	}

	super.ChangeCrosshair(d);
}

// to use texture returned by ExtendedHUD, set bDisableFunction to True
simulated function Texture LoadCrosshair(int c)
{
	local byte bDisableFunction;
	local Texture Result;

	if (ExtendedHUD != none)
	{
		Result = ExtendedHUD.LoadCrosshair(bDisableFunction, c);
		if (bool(bDisableFunction))
			return Result;
	}

	return super.LoadCrosshair(c);
}

simulated function HUDSetup(canvas canvas)
{
	local byte bDisableFunction;

	if (ExtendedHUD != none)
	{
		ExtendedHUD.HUDSetup(bDisableFunction, canvas);
		if (bool(bDisableFunction))
			return;
	}

	super.HUDSetup(canvas);
}

simulated function DrawDigit(Canvas Canvas, int d, int Step, float UpScale, out byte bMinus )
{
	local byte bDisableFunction;

	if (ExtendedHUD != none)
	{
		ExtendedHUD.DrawDigit(bDisableFunction, Canvas, d, Step, UpScale, bMinus);
		if (bool(bDisableFunction))
			return;
	}

	super.DrawDigit(Canvas, d, Step, UpScale, bMinus );
}

simulated function DrawBigNum(Canvas Canvas, int Value, int X, int Y, optional float ScaleFactor)
{
	local byte bDisableFunction;

	if (ExtendedHUD != none)
	{
		ExtendedHUD.DrawBigNum(bDisableFunction, Canvas, Value, X, Y, ScaleFactor);
		if (bool(bDisableFunction))
			return;
	}

	super.DrawBigNum(Canvas, Value, X, Y, ScaleFactor);
}

//==============
simulated function DrawStatus(Canvas Canvas)
{
	local float StatScale, ChestAmount, ThighAmount, H1, H2, X, Y, DamageTime;
	Local int ArmorAmount,CurAbs,i;
	Local inventory Inv,BestArmor;
	local bool bChestArmor, bShieldbelt, bThighArmor, bJumpBoots, bHasDoll;
	local Bot BotOwner;
	local TournamentPlayer TPOwner;
	local texture Doll, DollBelt;

	// used to render the PlayerMeshInfo status doll textures
	local WFD_DPMSPlayer DPMSOwner;
	local WFD_DPMSBot DPMSBotOwner;

	// --- ExtendedHUD code ---
	local byte bDisableFunction;

	if (ExtendedHUD != none)
	{
		ExtendedHUD.DrawStatus(bDisableFunction, Canvas);
		if (bool(bDisableFunction))
			return;
	}
	// ------------------------

	ArmorAmount = 0;
	CurAbs = 0;
	i = 0;
	BestArmor=None;
	for( Inv=PawnOwner.Inventory; Inv!=None; Inv=Inv.Inventory )
	{
		if (Inv.bIsAnArmor)
		{
			if ( Inv.IsA('UT_Shieldbelt') )
				bShieldbelt = true;
			else if ( Inv.IsA('Thighpads') )
			{
				ThighAmount += Inv.Charge;
				bThighArmor = true;
			}
			else
			{
				bChestArmor = true;
				ChestAmount += Inv.Charge;
			}
			ArmorAmount += Inv.Charge;
		}
		else if ( Inv.IsA('UT_JumpBoots') )
			bJumpBoots = true;
		else
		{
			i++;
			if ( i > 100 )
				break; // can occasionally get temporary loops in netplay
		}
	}

	if ( !bHideStatus )
	{
		TPOwner = TournamentPlayer(PawnOwner);
		DPMSOwner = WFD_DPMSPlayer(PawnOwner);
		if ( Canvas.ClipX < 400 )
			bHasDoll = false;
		// Support for the WFD_DPMSMeshInfo status doll textures
		else if ((DPMSOwner != None) && (DPMSOwner.MeshInfo != None))
		{
			Doll = DPMSOwner.MeshInfo.default.StatusDoll;
			DollBelt = DPMSOwner.MeshInfo.default.StatusBelt;
			bHasDoll = true;
		}
		// --- (end of WFD_DPMSMeshInfo status doll support code) ---
		else if ( TPOwner != None )
		{
			Doll = TPOwner.StatusDoll;
			DollBelt = TPOwner.StatusBelt;
			bHasDoll = true;
		}
		else
		{
			BotOwner = Bot(PawnOwner);
			DPMSBotOwner = WFD_DPMSBot(PawnOwner);
			// Bot support for the WFD_DPMSMeshInfo status doll textures
			if ( (DPMSBotOwner != None) && (DPMSBotOwner != None) )
			{
				Doll = DPMSBotOwner.MeshInfo.default.StatusDoll;
				DollBelt = DPMSBotOwner.MeshInfo.default.StatusBelt;
				bHasDoll = true;
			}
			// --- (end of WFD_DPMSMeshInfo status doll Bot support code) ---
			else if ( BotOwner != None )
			{
				Doll = BotOwner.StatusDoll;
				DollBelt = BotOwner.StatusBelt;
				bHasDoll = true;
			}
		}
		if ( bHasDoll )
		{
			Canvas.Style = ERenderStyle.STY_Translucent;
			StatScale = Scale * StatusScale;
			X = Canvas.ClipX - 128 * StatScale;
			Canvas.SetPos(X, 0);
			if (PawnOwner.DamageScaling > 2.0)
				Canvas.DrawColor = PurpleColor;
			else
				Canvas.DrawColor = HUDColor;
			Canvas.DrawTile(Doll, 128*StatScale, 256*StatScale, 0, 0, 128.0, 256.0);
			Canvas.DrawColor = HUDColor;
			if ( bShieldBelt )
			{
				Canvas.DrawColor = BaseColor;
				Canvas.DrawColor.B = 0;
				Canvas.SetPos(X, 0);
				Canvas.DrawIcon(DollBelt, StatScale);
			}
			if ( bChestArmor )
			{
				ChestAmount = FMin(0.01 * ChestAmount,1);
				Canvas.DrawColor = HUDColor * ChestAmount;
				Canvas.SetPos(X, 0);
				//Canvas.DrawTile(Doll, 128*StatScale, 64*StatScale, 128, 0, 128, 64);
				Canvas.DrawTile(Doll, 128*StatScale, 80*StatScale, 128, 0, 128, 80);
			}
			if ( bThighArmor )
			{
				ThighAmount = FMin(0.02 * ThighAmount,1);
				Canvas.DrawColor = HUDColor * ThighAmount;
				Canvas.SetPos(X, 64*StatScale);
				Canvas.DrawTile(Doll, 128*StatScale, 64*StatScale, 128, 64, 128, 64);
			}
			if ( bJumpBoots )
			{
				Canvas.DrawColor = HUDColor;
				Canvas.SetPos(X, 128*StatScale);
				Canvas.DrawTile(Doll, 128*StatScale, 64*StatScale, 128, 128, 128, 64);
			}
			Canvas.Style = Style;
			if ( (PawnOwner == PlayerOwner) && Level.bHighDetailMode && !Level.bDropDetail )
			{
				for ( i=0; i<4; i++ )
				{
					DamageTime = Level.TimeSeconds - HitTime[i];
					if ( DamageTime < 1 )
					{
						Canvas.SetPos(X + HitPos[i].X * StatScale, HitPos[i].Y * StatScale);
						if ( (HUDColor.G > 100) || (HUDColor.B > 100) )
							Canvas.DrawColor = RedColor;
						else
							Canvas.DrawColor = (WhiteColor - HudColor) * FMin(1, 2 * DamageTime);
						Canvas.DrawColor.R = 255 * FMin(1, 2 * DamageTime);
						Canvas.DrawTile(Texture'BotPack.HudElements1', StatScale * HitDamage[i] * 25, StatScale * HitDamage[i] * 64, 0, 64, 25.0, 64.0);
					}
				}
			}
		}
	}
	Canvas.DrawColor = HUDColor;
	if ( bHideStatus && bHideAllWeapons )
	{
		X = 0.5 * Canvas.ClipX;
		Y = Canvas.ClipY - 64 * Scale;
	}
	else
	{
		X = Canvas.ClipX - 128 * StatScale - 140 * Scale;
		Y = 64 * Scale;
	}
	Canvas.SetPos(X,Y);
	if ( PawnOwner.Health < 50 )
	{
		H1 = 1.5 * TutIconBlink;
		H2 = 1 - H1;
		Canvas.DrawColor = WhiteColor * H2 + (HUDColor - WhiteColor) * H1;
	}
	else
		Canvas.DrawColor = HUDColor;
	Canvas.DrawTile(Texture'BotPack.HudElements1', 128*Scale, 64*Scale, 128, 128, 128.0, 64.0);

	if ( PawnOwner.Health < 50 )
	{
		H1 = 1.5 * TutIconBlink;
		H2 = 1 - H1;
		Canvas.DrawColor = Canvas.DrawColor * H2 + (WhiteColor - Canvas.DrawColor) * H1;
	}
	else
		Canvas.DrawColor = WhiteColor;

	DrawBigNum(Canvas, Max(0, PawnOwner.Health), X + 4 * Scale, Y + 16 * Scale, 1);

	Canvas.DrawColor = HUDColor;
	if ( bHideStatus && bHideAllWeapons )
	{
		X = 0.5 * Canvas.ClipX - 128 * Scale;
		Y = Canvas.ClipY - 64 * Scale;
	}
	else
	{
		X = Canvas.ClipX - 128 * StatScale - 140 * Scale;
		Y = 0;
	}
	Canvas.SetPos(X, Y);
	Canvas.DrawTile(Texture'BotPack.HudElements1', 128*Scale, 64*Scale, 0, 192, 128.0, 64.0);
	if ( bHideStatus && bShieldBelt )
		Canvas.DrawColor = GoldColor;
	else
		Canvas.DrawColor = WhiteColor;
	//DrawBigNum(Canvas, Min(150,ArmorAmount), X + 4 * Scale, Y + 16 * Scale, 1);
	DrawBigNum(Canvas, Max(0,ArmorAmount), X + 4 * Scale, Y + 16 * Scale, 1);
}
//==============

simulated function DrawAmmo(Canvas Canvas)
{
	local byte bDisableFunction;

	if (ExtendedHUD != none)
	{
		ExtendedHUD.DrawAmmo(bDisableFunction, Canvas);
		if (bool(bDisableFunction))
			return;
	}

	super.DrawAmmo(Canvas);
}

simulated function DrawFragCount(Canvas Canvas)
{
	local byte bDisableFunction;

	if (ExtendedHUD != none)
	{
		ExtendedHUD.DrawFragCount(bDisableFunction, Canvas);
		if (bool(bDisableFunction))
			return;
	}

	super.DrawFragCount(Canvas);
}

simulated function DrawGameSynopsis(Canvas Canvas)
{
	local byte bDisableFunction;

	if (ExtendedHUD != none)
	{
		ExtendedHUD.DrawGameSynopsis(bDisableFunction, Canvas);
		if (bool(bDisableFunction))
			return;
	}

	super.DrawGameSynopsis(Canvas);
}

simulated function DrawTeam(Canvas Canvas, TeamInfo TI)
{
	local byte bDisableFunction;

	if (ExtendedHUD != none)
	{
		ExtendedHUD.DrawTeam(bDisableFunction, Canvas, TI);
		if (bool(bDisableFunction))
			return;
	}

	super.DrawTeam(Canvas, TI);
}

simulated function DrawWeapons(Canvas Canvas)
{
	local byte bDisableFunction;

	if (ExtendedHUD != none)
	{
		ExtendedHUD.DrawWeapons(bDisableFunction, Canvas);
		if (bool(bDisableFunction))
			return;
	}

	super.DrawWeapons(Canvas);
}

simulated function DisplayProgressMessage( canvas Canvas )
{
	local byte bDisableFunction;

	if (ExtendedHUD != none)
	{
		ExtendedHUD.DisplayProgressMessage(bDisableFunction, Canvas);
		if (bool(bDisableFunction))
			return;
	}

	super.DisplayProgressMessage(Canvas);
}

/* taken out to preserve version compatibility (v432 redeclares this function)
function DrawTalkFace(Canvas Canvas, int i, float YPos)
{
	local byte bDisableFunction;

	if (ExtendedHUD != none)
	{
		UpdateExtendedHUDMessages();
		ExtendedHUD.DrawTalkFace(bDisableFunction, Canvas, i, YPos);
		if (bool(bDisableFunction))
			return;
	}

	super.DrawTalkFace(Canvas, i, YPos);
}*/

// could disable on a return value of false
function bool DrawSpeechArea( Canvas Canvas, float XL, float YL )
{
	local byte bDisableFunction;
	local bool Result;

	if (ExtendedHUD != none)
	{
		Result = ExtendedHUD.DrawSpeechArea(bDisableFunction, Canvas, XL, YL);
		if (bool(bDisableFunction))
			return Result;
	}

	return super.DrawSpeechArea(Canvas, XL, YL);
}

function Timer()
{
	local byte bDisableFunction;

	if (ExtendedHUD != none)
	{
		ExtendedHUD.OwnerHUDTimer(bDisableFunction);
		if (bool(bDisableFunction))
			return;
	}

	super.Timer();
}

function UpdateRankAndSpread()
{
	local byte bDisableFunction;

	if (ExtendedHUD != none)
	{
		ExtendedHUD.UpdateRankAndSpread(bDisableFunction);
		if (bool(bDisableFunction))
			return;
	}

	super.UpdateRankAndSpread();
}

simulated function TellTime(int num)
{
	local byte bDisableFunction;

	if (ExtendedHUD != none)
	{
		ExtendedHUD.TellTime(bDisableFunction, num);
		if (bool(bDisableFunction))
			return;
	}

	super.TellTime(num);
}

simulated function Tick(float DeltaTime)
{
	local byte bDisableFunction;

	if (ExtendedHUD != none)
	{
		ExtendedHUD.OwnerHUDTick(bDisableFunction, DeltaTime);
		if (bool(bDisableFunction))
			return;
	}

	super.Tick(DeltaTime);
}

simulated function DrawMOTD(Canvas Canvas)
{
	local byte bDisableFunction;

	if (ExtendedHUD != none)
	{
		ExtendedHUD.DrawMOTD(bDisableFunction, Canvas);
		if (bool(bDisableFunction))
			return;
	}

	super.DrawMOTD(Canvas);
}

simulated function DrawCrossHair( canvas Canvas, int X, int Y)
{
	local byte bDisableFunction;

	if (ExtendedHUD != none)
	{
		ExtendedHUD.DrawCrossHair(bDisableFunction, Canvas, X, Y);
		if (bool(bDisableFunction))
			return;
	}

	super.DrawCrossHair(Canvas, X, Y);
}

simulated function DrawTypingPrompt( canvas Canvas, console Console )
{
	local byte bDisableFunction;

	if (ExtendedHUD != none)
	{
		ExtendedHUD.DrawTypingPrompt(bDisableFunction, Canvas, Console);
		if (bool(bDisableFunction))
			return;
	}

	super.DrawTypingPrompt(Canvas, Console);
}

simulated function Message( PlayerReplicationInfo PRI, coerce string Msg, name MsgType )
{
	local byte bDisableFunction;

	if (ExtendedHUD != none)
	{
		UpdateExtendedHUDMessages();
		ExtendedHUD.Message(bDisableFunction, PRI, Msg, MsgType);
		if (bool(bDisableFunction))
			return;
	}

	super.Message(PRI, Msg, MsgType);
}

// could disable function on return value of false
simulated function bool DisplayMessages( canvas Canvas )
{
	local byte bDisableFunction;
	local bool Result;

	if (ExtendedHUD != none)
	{
		Result = ExtendedHUD.DisplayMessages(bDisableFunction, Canvas);
		if (bool(bDisableFunction))
			return Result;
	}

	return super.DisplayMessages(Canvas);
}

// could disable function on return value
simulated function float DrawNextMessagePart(Canvas Canvas, string MString, float XOffset, int YPos)
{
	local byte bDisableFunction;
	local float Result;

	if (ExtendedHUD != none)
	{
		Result = ExtendedHUD.DrawNextMessagePart(bDisableFunction, Canvas, MString, XOffset, YPos);
		if (bool(bDisableFunction))
			return Result;
	}

	return super.DrawNextMessagePart(Canvas, MString, XOffset, YPos);
}

// could disable function on return value of false
simulated function bool TraceIdentify(canvas Canvas)
{
	local byte bDisableFunction;
	local bool Result;

	if (ExtendedHUD != none)
	{
		Result = ExtendedHUD.TraceIdentify(bDisableFunction, Canvas);
		if (bool(bDisableFunction))
			return Result;
	}

	return super.TraceIdentify(Canvas);
}

simulated function bool SpecialIdentify(Canvas Canvas, Actor Other )
{
	local byte bDisableFunction;
	local bool Result;

	if (ExtendedHUD != none)
	{
		Result = ExtendedHUD.SpecialIdentify(bDisableFunction, Canvas, Other);
		if (bool(bDisableFunction))
			return Result;
	}

	return super.SpecialIdentify(Canvas, Other);
}

simulated function SetIDColor( Canvas Canvas, int type )
{
	local byte bDisableFunction;

	if (ExtendedHUD != none)
	{
		ExtendedHUD.SetIDColor(bDisableFunction, Canvas, Type);
		if (bool(bDisableFunction))
			return;
	}

	super.SetIDColor(Canvas, Type);
}

simulated function DrawTwoColorID( canvas Canvas, string TitleString, string ValueString, int YStart )
{
	local byte bDisableFunction;

	if (ExtendedHUD != none)
	{
		ExtendedHUD.DrawTwoColorID(bDisableFunction, Canvas, TitleString, ValueString, YStart);
		if (bool(bDisableFunction))
			return;
	}

	super.DrawTwoColorID(Canvas, TitleString, ValueString, YStart);
}

// could disable function on return value of false
simulated function bool DrawIdentifyInfo(canvas Canvas)
{
	local byte bDisableFunction;
	local bool Result;

	if (ExtendedHUD != none)
	{
		Result = ExtendedHUD.DrawIdentifyInfo(bDisableFunction, Canvas);
		if (bool(bDisableFunction))
			return Result;
	}

	return super.DrawIdentifyInfo(Canvas);
}

simulated function LocalizedMessage( class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject, optional String CriticalString )
{
	local byte bDisableFunction;

	if (ExtendedHUD != none)
	{
		UpdateExtendedHUDMessages();
		ExtendedHUD.LocalizedMessage( bDisableFunction, Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject, CriticalString );
		if (bool(bDisableFunction))
			return;
	}

	super.LocalizedMessage( Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject, CriticalString);
}

// exec functions
exec function ShowServerInfo()
{
	local byte bDisableFunction;

	if (ExtendedHUD != none)
	{
		ExtendedHUD.ShowServerInfo(bDisableFunction);
		if (bool(bDisableFunction))
			return;
	}

	super.ShowServerInfo();
}

exec function GrowHUD()
{
	local byte bDisableFunction;

	if (ExtendedHUD != none)
	{
		ExtendedHUD.GrowHUD(bDisableFunction);
		if (bool(bDisableFunction))
			return;
	}

	super.GrowHUD();
}

exec function ShrinkHUD()
{
	local byte bDisableFunction;

	if (ExtendedHUD != none)
	{
		ExtendedHUD.ShrinkHUD(bDisableFunction);
		if (bool(bDisableFunction))
			return;
	}

	super.ShrinkHUD();
}

// --- not sure these need to be called on ExtendedHUD ---
exec function SetHUDR(int n)
{
	local byte bDisableFunction;

	if (ExtendedHUD != none)
	{
		ExtendedHUD.SetHUDR(bDisableFunction, n);
		if (bool(bDisableFunction))
			return;
	}

	super.SetHUDR(n);
}

exec function SetHUDG(int n)
{
	local byte bDisableFunction;

	if (ExtendedHUD != none)
	{
		ExtendedHUD.SetHUDG(bDisableFunction, n);
		if (bool(bDisableFunction))
			return;
	}

	super.SetHUDG(n);
}

exec function SetHUDB(int n)
{
	local byte bDisableFunction;

	if (ExtendedHUD != none)
	{
		ExtendedHUD.SetHUDB(bDisableFunction, n);
		if (bool(bDisableFunction))
			return;
	}

	super.SetHUDB(n);
}

/* === list of functions that are called on ExtendedHUD ===
function SetDamage(vector HitLoc, float damage)
// -- not sure these need to be called on ExtendedHUD --
exec function SetHUDR(int n)
exec function SetHUDG(int n)
exec function SetHUDB(int n)
// -----------------------------------------------------
exec function ShowServerInfo()
exec function GrowHUD()
exec function ShrinkHUD()
simulated function ChangeCrosshair(int d)
simulated function Texture LoadCrosshair(int c)
simulated function HUDSetup(canvas canvas)
simulated function DrawDigit(Canvas Canvas, int d, int Step, float UpScale, out byte bMinus )
simulated function DrawBigNum(Canvas Canvas, int Value, int X, int Y, optional float ScaleFactor)
simulated function DrawStatus(Canvas Canvas)
simulated function DrawAmmo(Canvas Canvas)
simulated function DrawFragCount(Canvas Canvas)
simulated function DrawGameSynopsis(Canvas Canvas)
simulated function DrawWeapons(Canvas Canvas)
simulated function DisplayProgressMessage( canvas Canvas )
function DrawTalkFace(Canvas Canvas, int i, float YPos)
function bool DrawSpeechArea( Canvas Canvas, float XL, float YL )
function Timer()
function UpdateRankAndSpread()
simulated function TellTime(int num)
simulated function Tick(float DeltaTime)
simulated function DrawMOTD(Canvas Canvas)
simulated function DrawCrossHair( canvas Canvas, int X, int Y)
simulated function DrawTypingPrompt( canvas Canvas, console Console )
simulated function Message( PlayerReplicationInfo PRI, coerce string Msg, name MsgType )
simulated function bool DisplayMessages( canvas Canvas )
simulated function float DrawNextMessagePart(Canvas Canvas, string MString, float XOffset, int YPos)
simulated function bool TraceIdentify(canvas Canvas)
simulated function bool SpecialIdentify(Canvas Canvas, Actor Other )
simulated function SetIDColor( Canvas Canvas, int type )
simulated function DrawTwoColorID( canvas Canvas, string TitleString, string ValueString, int YStart )
simulated function bool DrawIdentifyInfo(canvas Canvas)
simulated function LocalizedMessage( class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject, optional String CriticalString )
*/
defaultproperties
{
}