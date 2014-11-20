//=============================================================================
// WFS_HUDInfo.
// Author: Ob1-Kenobi (ob1@planetunreal.com)
//
// Extended HUD class created by the main HUD. Can be used to effect the
// way that the main HUD displayes information.
//
// The bDisableFunction parameter can be used to disable the rest
// of the OwnerHUD's function.
//
//=============================================================================
class WFS_HUDInfo extends WFS_PCSystemInfo
	abstract;

var WFS_PCSystemHUD			OwnerHUD;		// hud owner
var() class<ServerInfo> ServerInfoClass;

// TODO: Add functions that are called after super.SomeFunction() in OwnerHUD
//		 - pass result of OwnerHUD.SomeFunction to post called function


//=============================================================================
// HUD message functions
//
// Note: The extended HUD info must call WFS_HUDInfo.UpdateHUDMessages() to update the
//       HUD message list after dealing with the message call or the messages
//       will not display correctly.

struct HUDLocalizedMessage
{
	var Class<LocalMessage> Message;
	var int Switch;
	var PlayerReplicationInfo RelatedPRI;
	var Object OptionalObject;
	var float EndOfLife;
	var float LifeTime;
	var bool bDrawing;
	var int numLines;
	var string StringMessage;
	var color DrawColor;
	var font StringFont;
	var float XL, YL;
	var float YPos;
};

var HUDLocalizedMessage ShortMessageQueue[4];
var HUDLocalizedMessage LocalMessages[10];

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

function UpdateHUDMessages()
{
	local int i;

	// update short message queue
	for (i=0; i<4; i++)
	{
		OwnerHUD.SetShortMessage
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
		OwnerHUD.SetLocalMessage
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

function ClearMessage(out HUDLocalizedMessage M)
{
	M.Message = None;
	M.Switch = 0;
	M.RelatedPRI = None;
	M.OptionalObject = None;
	M.EndOfLife = 0;
	M.StringMessage = "";
	M.DrawColor = OwnerHUD.WhiteColor;
	M.XL = 0;
	M.bDrawing = false;
}

function CopyMessage(out HUDLocalizedMessage M1, HUDLocalizedMessage M2)
{
	M1.Message = M2.Message;
	M1.Switch = M2.Switch;
	M1.RelatedPRI = M2.RelatedPRI;
	M1.OptionalObject = M2.OptionalObject;
	M1.EndOfLife = M2.EndOfLife;
	M1.StringMessage = M2.StringMessage;
	M1.DrawColor = M2.DrawColor;
	M1.XL = M2.XL;
	M1.YL = M2.YL;
	M1.YPos = M2.YPos;
	M1.bDrawing = M2.bDrawing;
	M1.LifeTime = M2.LifeTime;
	M1.numLines = M2.numLines;
}

//=============================================================================
// functions externally called on HUD

// The first place it's safe to access OwnerHUD
function Initialise()
{
	if (ServerInfoClass != None)
		OwnerHUD.ServerInfoClass = ServerInfoClass;
}

simulated function PreRender( out byte bDisableFunction, canvas Canvas );

simulated function PostRender( out byte bDisableFunction, canvas Canvas )
{
	if (OwnerHUD == none)
		return;
}

simulated function LocalizedMessage(out byte bDisableFunction, class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject, optional String CriticalString);
simulated function Message( out byte bDisableFunction, PlayerReplicationInfo PRI, coerce string Msg, name N );
simulated function InputNumber(out byte bDisableFunction, byte F);
simulated function ChangeHud(out byte bDisableFunction, int d);
simulated function ChangeCrosshair(out byte bDisableFunction, int d);

// internal HUD functions
simulated function OwnerHUDTimer(out byte bDisableFunction);
simulated function OwnerHUDTick(out byte bDisableFunction, float DeltaTime);
simulated function SetDamage(out byte bDisableFunction, vector HitLoc, float damage);
simulated function SetHUDR(out byte bDisableFunction, int n);
simulated function SetHUDG(out byte bDisableFunction, int n);
simulated function SetHUDB(out byte bDisableFunction, int n);
simulated function ShowServerInfo(out byte bDisableFunction);
simulated function GrowHUD(out byte bDisableFunction);
simulated function ShrinkHUD(out byte bDisableFunction);
simulated function HUDSetup(out byte bDisableFunction, canvas canvas);
simulated function DrawDigit(out byte bDisableFunction, Canvas Canvas, int d, int Step, float UpScale, out byte bMinus);
simulated function DrawBigNum(out byte bDisableFunction, Canvas Canvas, int Value, int X, int Y, optional float ScaleFactor);
simulated function DrawStatus(out byte bDisableFunction, Canvas Canvas);
simulated function DrawAmmo(out byte bDisableFunction, Canvas Canvas);
simulated function DrawFragCount(out byte bDisableFunction, Canvas Canvas);
simulated function DrawGameSynopsis(out byte bDisableFunction, Canvas Canvas);
simulated function DrawWeapons(out byte bDisableFunction, Canvas Canvas);
simulated function DisplayProgressMessage( out byte bDisableFunction, canvas Canvas );
simulated function DrawTalkFace(out byte bDisableFunction, Canvas Canvas, int i, float YPos);
simulated function UpdateRankAndSpread(out byte bDisableFunction);
simulated function TellTime(out byte bDisableFunction, int num);
simulated function DrawMOTD(out byte bDisableFunction, Canvas Canvas);
simulated function DrawCrossHair(out byte bDisableFunction, canvas Canvas, int X, int Y);
simulated function DrawTypingPrompt( out byte bDisableFunction, canvas Canvas, console Console );
simulated function SetIDColor( out byte bDisableFunction, Canvas Canvas, int type);
simulated function DrawTwoColorID( out byte bDisableFunction, canvas Canvas, string TitleString, string ValueString, int YStart );
simulated function DrawTeam(out byte bDisableFunction, Canvas Canvas, TeamInfo TI);

// To make the OwnerHUD use the value returned by these functions, set bDisableFuncion to 1
// otherwise the returned value will not be used
simulated function bool DrawSpeechArea( out byte bDisableFunction, Canvas Canvas, float XL, float YL );
simulated function bool DisplayMessages( out byte bDisableFunction, canvas Canvas );
simulated function bool TraceIdentify(out byte bDisableFunction, canvas Canvas);
simulated function bool SpecialIdentify(out byte bDisableFunction, Canvas Canvas, Actor Other);
simulated function bool DrawIdentifyInfo(out byte bDisableFunction, canvas Canvas);
simulated function float DrawNextMessagePart(out byte bDisableFunction, Canvas Canvas, string MString, float XOffset, int YPos);
simulated function Texture LoadCrosshair(out byte bDisableFunction, int c);


defaultproperties
{
}