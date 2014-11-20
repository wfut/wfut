//=============================================================================
// WFPlayerStatus.
// Author: Ob1-Kenobi (ob1@planetunreal.com)
//=============================================================================
class WFPlayerStatus extends TournamentPickup
	abstract;

var() float ScaleFactor; // scaling factor of the effect

var() string StatusType; // type name of the status (eg. "Concussed")
var() localized string DeathMessage;
var() localized string SuicideMessage;

// status flags
var() bool bRenderStatus; // this status recieves RenderStatus() calls from the HUD
var() bool bExclusiveRender; // don't allow other status classes to render to the canvas
var() byte RenderPriority; // 1...255 = priorty value (highest gets rendered last)

var() byte StatusID; // the unique bit flag set while this status is active 1..31 (0=none)

var pawn StatusInstigator; // the player that caused this status (valid server-side)
var PlayerReplicationInfo StatusInstigatorPRI; // the PRI of the StatusInstigator

var byte Team; // the team of the StatusInstigator (can be used to prevent team damage, etc)

var WFPlayerStatus NextStatus; // only valid for rendering status client-side
var bool bRegistered; // true when successfully registered for rendering
var bool bPreInitialised;

replication
{
	reliable if (bNetOwner && (Role == ROLE_Authority))
		ScaleFactor, StatusInstigatorPRI;
}

simulated function PostBeginPlay()
{
	StatusID = Min(StatusID, 31);
	super.PostBeginPlay();
}

// Called to render the status list
final simulated function RenderStatusChain(canvas Canvas)
{
	if (!bDeleteMe)
		RenderStatus(Canvas);

	if (NextStatus != None)
		NextStatus.RenderStatusChain(Canvas);
}

// implement in subclass to draw on the canvas
// (set bRenderStatus or bExclusiveRender to recieve render calls)
simulated function RenderStatus(canvas Canvas);

// give the status to a player
function GiveStatusTo(pawn Other, pawn InstigatedBy, optional float NewScaleFactor)
{
	if (Other == None)
	{
		Warn("Tried to give "$self$" to None!");
		Destroy();
		return;
	}

	if (HandleStatusFor(Other))
		return;

	bHeldItem = true;
	StatusInstigator = InstigatedBy;
	if (InstigatedBy != None)
	{
		StatusInstigatorPRI = InstigatedBy.PlayerReplicationInfo;
		Team = StatusInstigatorPRI.Team;
	}
	if (NewScaleFactor > 0.0)
		ScaleFactor = NewScaleFactor;

	GiveTo(Other);
	SetStatusFlag();
	GotoState('Activated');

	SendStatusMessage(Other, InstigatedBy);
}

// Set the status flag.
function SetStatusFlag()
{
	local pawn PawnOwner;
	local WF_PRI PRI;
	local WF_BotPRI BotPRI;
	local int BitFlag;

	if (StatusID == 0)
		return;

	PawnOwner = pawn(Owner);
	if (PawnOwner == None)
		return;

	BitFlag = 2**(StatusID-1);
	if (PawnOwner.PlayerReplicationInfo != None)
	{
		PRI = WF_PRI(PawnOwner.PlayerReplicationInfo);
		if (PRI != None)
			PRI.StatusFlags = PRI.StatusFlags | BitFlag;
		else
		{
			BotPRI = WF_BotPRI(PawnOwner.PlayerReplicationInfo);
			if (BotPRI != None)
				BotPRI.StatusFlags = BotPRI.StatusFlags | BitFlag;
		}
	}
}

// Clear the status flag
function ClearStatusFlag()
{
	local pawn PawnOwner;
	local WF_PRI PRI;
	local WF_BotPRI BotPRI;
	local int BitFlag;

	if (StatusID == 0)
		return;

	PawnOwner = pawn(Owner);
	if (PawnOwner == None)
		return;

	BitFlag = 2**(StatusID-1);
	if (PawnOwner.PlayerReplicationInfo != None)
	{
		PRI = WF_PRI(PawnOwner.PlayerReplicationInfo);
		if (PRI != None)
		{
			if (bool(PRI.StatusFlags & BitFlag))
				PRI.StatusFlags -= BitFlag;
		}
		else
		{
			BotPRI = WF_BotPRI(PawnOwner.PlayerReplicationInfo);
			if ((BotPRI != None) && bool(BotPRI.StatusFlags & BitFlag))
				BotPRI.StatusFlags -= BitFlag;
		}
	}
}

static function bool IsStatusFlagSet(PlayerReplicationInfo OtherPRI)
{
	local WF_PRI WFPRI;
	local WF_BotPRI WFBotPRI;
	local int BitFlag;

	if (OtherPRI == None)
		return false;

	BitFlag = 2**(default.StatusID-1);
	WFPRI = WF_PRI(OtherPRI);
	if (WFPRI != None)
		return bool(WFPRI.StatusFlags & BitFlag);
	else
	{
		WFBotPRI = WF_BotPRI(OtherPRI);
		if (WFBotPRI != None)
			return bool(WFBotPRI.StatusFlags & BitFlag);
	}

	return false;
}

// implement in sub-class to handle giving this status to a player
// (return true to handle status)
function bool HandleStatusFor(pawn Other);

// Send an initial status message
function SendStatusMessage(pawn Other, pawn InstigatedBy)
{
	// implement in sub-class to customise
	//Other.ReceiveLocalizedMessage( PickupMessageClass, 0, Other.PlayerReplicationInfo, StatusInstigatorPRI, Self.Class );
	Other.ClientMessage(PickupMessage, 'CriticalEvent');
}

// Status setup code. (Don't override Tick(), use StatusTick() instead).
simulated function Tick(float DeltaTime)
{
	if (!bPreInitialised && bActive && (Owner != None))
		PreInitialise();
	StatusTick(DeltaTime);
}

// Player status initialisation code
simulated function PreInitialise()
{
	local WFPlayer PlayerOwner;
	PlayerOwner = WFPlayer(Owner);
	if ((PlayerOwner != None) && (ViewPort(PlayerOwner.Player) != None))
	{
		if (bRenderStatus)
			RegisterStatus();
		if (bRenderStatus && !bRegistered)
			return;
		ClientInitialise();
	}

	if (Role == ROLE_Authority)
		ServerInitialise();

	bPreInitialised = true;
}

// Called only on the client that has this status. (ie. bNetOwner && Role < ROLE_Authority)
simulated function ClientInitialise();

// Called only on the server. (ie. Role == ROLE_Authority)
function ServerInitialise();

// Register this status to recieve RenderStatus() calls.
// (called by PreInitialise())
simulated function RegisterStatus()
{
	local WFPlayer WFPlayerOwner;

	WFPlayerOwner = WFPlayer(Owner);
	if (WFPlayerOwner == None) return;

	if (bRenderStatus && (WFPlayerOwner.MyHUD != None))
		WFHUD(WFPlayerOwner.MyHUD).AddRenderedStatus(self);
}

// Unregister this status
simulated function UnregisterStatus()
{
	local WFPlayer WFPlayerOwner;

	WFPlayerOwner = WFPlayer(Owner);
	if (WFPlayerOwner == None) return;

	if (bRenderStatus && (WFPlayerOwner.MyHUD != None))
		WFHUD(WFPlayerOwner.MyHUD).RemoveRenderedStatus(self);
}

// Use this function instead of Tick()
simulated function StatusTick(float DeltaTime);

// Called to add a status to the list
simulated function AddStatus(WFPlayerStatus NewStatus)
{
	if (NextStatus == None)
	{
		NewStatus.bRegistered = true;
		NextStatus = NewStatus;
	}
	else if ((NewStatus.RenderPriority >= RenderPriority)
		&& (NewStatus.RenderPriority <= NextStatus.RenderPriority))
	{
		NewStatus.bRegistered = true;
		NewStatus.NextStatus = NextStatus;
		NextStatus = NewStatus;
	}
	else NextStatus.AddStatus(NewStatus);
}

// Unregister status if registered for RenderStatus() and clear the status flag
simulated function Destroyed()
{
	if (bRegistered)
		UnregisterStatus();
	if (Role == ROLE_Authority)
		ClearStatusFlag();
	super.Destroyed();
}

defaultproperties
{
	CollisionRadius=18.000000
	CollisionHeight=8.000000
	PickupViewMesh=LodMesh'UnrealShare.VoiceBoxMesh'
	PickupSound=Sound'UnrealShare.Pickups.GenPickSnd'
	bCanHaveMultipleCopies=False
	bActivatable=True
	bAutoActivate=True
	bDisplayableInv=True
	RespawnTime=0.000000
	ScaleFactor=1.000000
	Team=255
	StatusType="None"
	DeathMessage="%o was killed by %k"
}