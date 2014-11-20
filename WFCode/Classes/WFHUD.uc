//=============================================================================
// WFHUD.
//
// TODO: add code for a prioritised status render list
//=============================================================================
class WFHUD extends WFS_PCSystemHUD;

// local references to rendered status (ensures reliable rendering)
var WFPlayerStatus RenderList[16], Exclusive, RenderChain;
var string TeamColorStr[4];
var int StatusCount;

var localized string IdentifyArmor;

var string ConsoleHintText[32]; // the console command list
var color ConsoleHintTextColor;
var string ConsoleHintHelp[32]; // the help text
var color ConsoleHintHelpColor;
var float HintLeft, HintTop, HintWidth, HintHeight;
var int NumHints;
var bool bSlideOnHint, bHintSliding, bInitial;
var float HintSlideTime; // time taken for hints to slide on-screen

var config bool bShowConsoleHints;

simulated function PostRender(canvas Canvas)
{
	RenderPlayerStatus(Canvas);
	super.PostRender(Canvas);
}

simulated function RenderPlayerStatus(canvas Canvas)
{
	local int i;

	if (PawnOwner == None)
		return;

	if ((Exclusive != None) && Exclusive.bExclusiveRender)
	{
		if (Exclusive.bDeleteMe)
			Exclusive = None;
		else
		{
			Exclusive.RenderStatus(Canvas);
			return;
		}
	}

	if (RenderChain != None)
		RenderChain.RenderStatusChain(Canvas);
}

simulated function AddRenderedStatus(WFPlayerStatus NewStatus)
{
	local int i;

	if (NewStatus.bExclusiveRender)
	{
		if ((Exclusive == None) || (Exclusive.bDeleteMe)
			|| (Exclusive.RenderPriority < NewStatus.RenderPriority))
		{
			Exclusive = NewStatus;
			return;
		}
	}

	// add to the render list
	if (RenderChain == None)
	{
		NewStatus.bRegistered = true;
		RenderChain = NewStatus;
	}
	else if (RenderChain.RenderPriority > NewStatus.RenderPriority)
	{
		NewStatus.bRegistered = true;
		NewStatus.NextStatus = RenderChain;
		RenderChain = NewStatus;
	}
	else RenderChain.AddStatus(NewStatus);
}

simulated function RemoveRenderedStatus(WFPlayerStatus OldStatus)
{
	local WFPlayerStatus S;

	if (Exclusive == OldStatus)
	{
		Exclusive = None;
		OldStatus.bRegistered = false;
	}

	for (S=RenderChain; S!=None; S=S.NextStatus)
	{
		if (S.NextStatus == OldStatus)
		{
			S.NextStatus = OldStatus.NextStatus;
			OldStatus.bRegistered = false;
		}
	}
}

// Uses WFTeamSayMessagePlus message class to fix a spacing bug with team messages.
// "Player  (Area):Message text" -> "Player  (Area): Message text"
simulated function Message( PlayerReplicationInfo PRI, coerce string Msg, name MsgType )
{
	local int i;
	local Class<LocalMessage> MessageClass;

	switch (MsgType)
	{
		case 'Say':
			MessageClass = class'SayMessagePlus';
			break;
		case 'TeamSay':
			MessageClass = class'WFTeamSayMessagePlus';
			break;
		case 'CriticalEvent':
			MessageClass = class'CriticalStringPlus';
			LocalizedMessage( MessageClass, 0, None, None, None, Msg );
			return;
		default:
			MessageClass= class'StringMessagePlus';
			break;
	}

	// only do this bit if running v432 or greater
	if ( (int(Level.EngineVersion) > 428) && (ClassIsChildOf(MessageClass, class'SayMessagePlus') ||
				     ClassIsChildOf(MessageClass, class'TeamSayMessagePlus')) )
	{
		SetPropertyText("FaceTexture", string(PRI.TalkTexture));
		SetPropertyText("FaceTeam", TeamColorStr[PRI.Team]);
		if ( PRI.TalkTexture != None )
			SetPropertyText("FaceTime", string(Level.TimeSeconds + 3));
		if ( Msg == "" )
			return;
	}

	for (i=0; i<4; i++)
	{
		if ( ShortMessageQueue[i].Message == None )
		{
			// Add the message here.
			ShortMessageQueue[i].Message = MessageClass;
			ShortMessageQueue[i].Switch = 0;
			ShortMessageQueue[i].RelatedPRI = PRI;
			ShortMessageQueue[i].OptionalObject = None;
			ShortMessageQueue[i].EndOfLife = MessageClass.Default.Lifetime + Level.TimeSeconds;
			if ( MessageClass.Default.bComplexString )
				ShortMessageQueue[i].StringMessage = Msg;
			else
				ShortMessageQueue[i].StringMessage = MessageClass.Static.AssembleString(self,0,PRI,Msg);
			ShortMessageQueue[i].bDrawing = ( ClassIsChildOf(MessageClass, class'SayMessagePlus') ||
				     ClassIsChildOf(MessageClass, class'TeamSayMessagePlus') );
			return;
		}
	}

	// No empty slots.  Force a message out.
	for (i=0; i<3; i++)
		CopyMessage(ShortMessageQueue[i],ShortMessageQueue[i+1]);

	ShortMessageQueue[3].Message = MessageClass;
	ShortMessageQueue[3].Switch = 0;
	ShortMessageQueue[3].RelatedPRI = PRI;
	ShortMessageQueue[3].OptionalObject = None;
	ShortMessageQueue[3].EndOfLife = MessageClass.Default.Lifetime + Level.TimeSeconds;
	if ( MessageClass.Default.bComplexString )
		ShortMessageQueue[3].StringMessage = Msg;
	else
		ShortMessageQueue[3].StringMessage = MessageClass.Static.AssembleString(self,0,PRI,Msg);
	ShortMessageQueue[3].bDrawing = ( ClassIsChildOf(MessageClass, class'SayMessagePlus') ||
			 ClassIsChildOf(MessageClass, class'TeamSayMessagePlus') );
}

simulated function bool TraceIdentify(canvas Canvas)
{
	local actor Other;
	local vector HitLocation, HitNormal, StartTrace, EndTrace;
	local class<WFPlayerClassInfo> PCI;

	StartTrace = PawnOwner.Location;
	StartTrace.Z += PawnOwner.BaseEyeHeight;
	EndTrace = StartTrace + vector(PawnOwner.ViewRotation) * 1000.0;
	Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);

	if ( Pawn(Other) != None )
	{
		PCI = class<WFPlayerClassInfo>(class'WFS_PlayerClassInfo'.static.GetPCIFor(pawn(Other)));
		if ( Pawn(Other).bIsPlayer && !Other.bHidden && ((PCI == None) || (PCI.default.bCanIdentify)) )
		{
			IdentifyTarget = Pawn(Other).PlayerReplicationInfo;
			IdentifyFadeTime = 3.0;
		}
	}
	else if ( (Other != None) && SpecialIdentify(Canvas, Other) )
		return false;

	if ( (IdentifyFadeTime == 0.0) || (IdentifyTarget == None) || IdentifyTarget.bFeigningDeath )
		return false;

	return true;
}

simulated function bool DrawIdentifyInfo(canvas Canvas)
{
	local float XL, YL, XOffset, X1;
	local Pawn P;
	local byte bDisableFunction;
	local bool Result;
	local class<WFPlayerClassInfo> PCI;

	if (ExtendedHUD != none)
	{
		Result = ExtendedHUD.DrawIdentifyInfo(bDisableFunction, Canvas);
		if (bool(bDisableFunction))
			return Result;
	}

	if ( !Super(ChallengeHUD).DrawIdentifyInfo(Canvas) )
		return false;

	PCI = class<WFPlayerClassInfo>(class'WFS_PlayerClassInfo'.static.GetPCIFor(PlayerOwner));
	Canvas.StrLen("TEST", XL, YL);
	if( PawnOwner.PlayerReplicationInfo.Team == IdentifyTarget.Team )
	{
		P = Pawn(IdentifyTarget.Owner);
		Canvas.Font = MyFonts.GetSmallFont(Canvas.ClipX);
		if ( P != None )
		{
			if ((PCI != None) && PCI.default.bDisplayArmorID)
				DrawIDStatus(Canvas, p, (Canvas.ClipY - 256 * Scale) + 1.5 * YL);
			else DrawTwoColorID(Canvas,IdentifyHealth,string(P.Health), (Canvas.ClipY - 256 * Scale) + 1.5 * YL);
		}
	}
	return true;
}

// draw health and armor
simulated function DrawIDStatus(canvas Canvas, pawn Other, int YStart)
{
	local float XL, YL, XOffset, X1, X2, X3;
	local string Value1, Value2;
	local class<WFS_PlayerClassInfo> PCI;
	local int Armor, MaxArmor;

	Value1 = string(Other.Health);
	Armor = GetArmorValue(Other);
	Value2 = string(Armor);

	PCI = class'WFS_PlayerClassInfo'.static.GetPCIFor(Other);
	if (PCI != None)
	{
		if (PCI.default.Armor > 0)
		{
			MaxArmor = PCI.default.Armor;
			if (PCI.default.MaxArmor > 0)
				MaxArmor = PCI.default.MaxArmor;
		}
		else MaxArmor = 0;
	}

	if (MaxArmor > 0)
	{
		if (Armor == MaxArmor)
			Value2 = Value2 $" (max)";
		else Value2 = Value2 $"/"$ string(MaxArmor);
	}

	Canvas.Style = Style;
	Canvas.StrLen(IdentifyHealth$"  ", XL, YL);
	X1 = XL;
	Canvas.StrLen(Value1, XL, YL);
	X2 = XL;
	Canvas.StrLen(",  "$IdentifyArmor$"  ", XL, YL);
	X3 = XL;
	Canvas.StrLen(Value2, XL, YL);

	// draw health
	XOffset = Canvas.ClipX/2 - (X1+X2+X3+XL)/2;
	Canvas.SetPos(XOffset, YStart);
	SetIDColor(Canvas,0);
	Canvas.DrawText(IdentifyHealth$"  ");

	XOffset += X1;
	Canvas.SetPos(XOffset, YStart);
	SetIDColor(Canvas,1);
	Canvas.DrawText(Value1);

	// draw armor
	XOffset += X2;
	Canvas.SetPos(XOffset, YStart);
	SetIDColor(Canvas,0);
	Canvas.DrawText(",  "$IdentifyArmor$"  ");

	XOffset += X3;
	Canvas.SetPos(XOffset, YStart);
	SetIDColor(Canvas,1);
	Canvas.DrawText(Value2);

	Canvas.DrawColor = WhiteColor;
	Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );
}

function int GetArmorValue(pawn Other)
{
	local WFBot aBot;
	local WFPlayer aPlayer;

	aPlayer = WFPlayer(Other);
	if (aPlayer != None)
		return aPlayer.Armor;
	else
	{
		aBot = WFBot(Other);
		if (aBot != None)
			return aBot.Armor;
	}

	return 0;
}

// --------------------------------
// console hint code.

function bool DrawSpeechArea( Canvas Canvas, float XL, float YL )
{
	local float YPos, Yadj;
	local float WackNumber;
	local int paneltype;

	YPos = FMax(YL*4 + 8, 70*Scale);
	Yadj = YPos + 7*Scale;
	YPos *=2;
	MinFaceAreaOffset = -1 * Yadj;
	Canvas.Style = ERenderStyle.STY_Translucent;
	Canvas.DrawColor = HUDColor * MessageFadeTime;

	Canvas.SetPos(FaceAreaOffset, 0);
	Canvas.DrawTile(texture'Static_a00', Yadj, Yadj, 0, 0, texture'Static_a00'.USize, texture'Static_a00'.VSize);

	WackNumber = 512*Scale - 64 + FaceAreaOffset; // 256*Scale - (512*Scale - (768*Scale - 64 + FaceAreaOffset));
	if ( !PlayerOwner.Player.Console.bTyping )
		paneltype = 0;
	else
	{
		Canvas.StrLen("(>"@PlayerOwner.Player.Console.TypedStr$"_", XL, YL);
		if (XL < 768*Scale)
			paneltype = 1;
		else
			paneltype = 2;
	}

	Canvas.SetPos(Yadj + FaceAreaOffset, 0);
	Canvas.DrawTile(FP1[paneltype], 256*Scale - FaceAreaOffset, YPos, 0, 0, FP1[paneltype].USize, FP1[paneltype].VSize);

	Yadj += 256 * Scale;
	Canvas.SetPos(Yadj, 0);
	Canvas.DrawTile(FP2[paneltype], WackNumber, YPos, 0, 0, FP2[paneltype].USize, FP2[paneltype].VSize);

	Canvas.SetPos(Yadj + WackNumber, 0);
	Canvas.DrawTile(FP3[paneltype], 64, YPos, 0, 0, FP3[paneltype].USize, FP3[paneltype].VSize);

	if (PlayerOwner.Player.Console.bTyping)
	{
		bSlideOnHint = true;
		HintTop = YPos*Scale + YL + 12;
	}
	else bSlideOnHint = false;

	if (bHintSliding || PlayerOwner.Player.Console.bTyping)
		RenderConsoleHints(Canvas);
}

function RenderConsoleHints(canvas Canvas)
{
	local int num, i;
	local float XL, YL, YOffset, XLMax, YPos, MaxTextWidth;
	local string MenuString;
	local color OldColor;
	local int X, Y;
	local font OldFont;
	local int OldX, OldY;

	// save canvas info
	OldFont = Canvas.Font;
	OldX = Canvas.CurX;
	OldY = Canvas.CurY;

	Canvas.Font = MyFonts.GetSmallFont(Canvas.SizeX);
	Canvas.StrLen("TEST", XL, YL);
	YOffset = YL;

	HintWidth = GetLongestStringWidth(Canvas) + 16;
	HintHeight = (YOffset * NumHints) + 16;

	if (bInitial)
	{
		HintLeft = -HintWidth;
		bInitial = false;
	}

	// draw the background
	RenderConsoleHintBG(Canvas);

	X = HintLeft + 8;
	Y = HintTop + 8;

	// draw console hints
	for (i=0; i<32; i++)
	{
		if ((ConsoleHintText[i] != "") || (ConsoleHintText[i] == " "))
		{
			Canvas.DrawColor = ConsoleHintTextColor;
			YPos = YOffset*num;
			Canvas.SetPos(X, Y + YPos);
			Canvas.DrawText(ConsoleHintText[i]);

			Canvas.StrLen(ConsoleHintText[i], XL, YL);
			Canvas.SetPos(X + XL, Y + YPos);
			Canvas.DrawColor = ConsoleHintHelpColor;
			Canvas.DrawText(ConsoleHintHelp[i]);

			num++;
		}
	}

	Canvas.Font = OldFont;
	Canvas.SetPos(OldX, OldY);
}

function RenderConsoleHintBG(canvas Canvas)
{
	Canvas.SetPos(HintLeft, HintTop);
	Canvas.Style = ERenderStyle.STY_Modulated;
	Canvas.DrawRect(texture'bgtex1', HintWidth, HintHeight);
	Canvas.Style = ERenderStyle.STY_Normal;
}

function float GetLongestStringWidth(canvas Canvas, optional bool bIncludeTitle)
{
	local float best, XL, YL;
	local int i;

	best = 0.0;
	for (i=0; i<32; i++)
	{
		Canvas.StrLen(ConsoleHintText[i]$ConsoleHintHelp[i], XL, YL);
		if (XL > best) best = XL;
	}

	return best;
}

exec function ShowHints()
{
	bShowConsoleHints = !bShowConsoleHints;
}

function Tick(float DeltaTime)
{
	local float HintSlideSpeed;
	super.Tick(DeltaTime);
	HintSlideSpeed = HintWidth/HintSlideTime;
	if (bShowConsoleHints && bSlideOnHint && (HintLeft < 0.0))
	{
		bHintSliding = true;
		HintLeft = FMin(0.0, HintLeft + HintSlideSpeed*DeltaTime);
	}
	else if ((!bShowConsoleHints || !bSlideOnHint) && (HintLeft > -HintWidth))
	{
		bHintSliding = true;
		HintLeft = FMax(-HintWidth, HintLeft - HintSlideSpeed*DeltaTime);
	}
	else bHintSliding = false;
}

defaultproperties
{
	ExtendedHUDClass=class'WFHUDInfo'
	IdentifyArmor="Armor:"
	TeamColorStr(0)="(R=255,B=0,G=0)"
	TeamColorStr(1)="(R=0,G=128,B=255)"
	TeamColorStr(2)="(R=0,B=0,G=255)"
	TeamColorStr(3)="(R=255,G=255,B=0)"
	ConsoleHintText(0)="GameMenu"
	ConsoleHintText(1)="ChangeClass"
	ConsoleHintText(2)="ClassHelp"
	ConsoleHintText(3)="Team <team>"
	ConsoleHintText(4)="DropAmmo <amount>"
	ConsoleHintText(5)="KeyConfig"
	ConsoleHintText(6)="ShowHints"
	ConsoleHintHelp(0)=" - displays the game menu"
	ConsoleHintHelp(1)=" - change your current class"
	ConsoleHintHelp(2)=" - get help on the current class"
	ConsoleHintHelp(3)=" - change to <team> [red | blue | green | gold]"
	ConsoleHintHelp(4)=" - drop <amount> ammo from current weapon"
	ConsoleHintHelp(5)=" - display basic key bindings menu"
	ConsoleHintHelp(6)=" - toggles this console help area"
	NumHints=7
	ConsoleHintTextColor=(R=255,G=255,B=255)
	HintSlideTime=0.5
	ConsoleHintHelpColor=(R=128,G=128,B=128)
	bInitial=True
	bShowConsoleHints=True
}