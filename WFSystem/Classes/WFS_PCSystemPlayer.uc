//=============================================================================
// WFS_PCSystemPlayer.
// Author: Ob1-Kenobi (ob1@planetunreal.com)
//=============================================================================
class WFS_PCSystemPlayer expands WFD_DPMSPlayer;

var class<WFS_PlayerClassInfo>		PCInfo;		// the player class info var
var class<WFS_PlayerClassInfo>		PlayerRestartClass;
var Actor						RelatedActors[8]; // actor references
var WFS_PCSWindowLauncher			WindowLauncher; // used to launch UWindows

var() float 					MenuDisplayDelay; // time before team menu appears

var() class<WFS_HUDMenuInfo>		StartGameMenuClass; // menu displayed at login
var() class<WFS_WindowDisplayInfo>	StartGameWindowInfoClass; // Window info used to display menu at login

var() class<WFS_HUDMenuInfo>		PCSelectionMenuClass;

var() class<WFS_PCSWindowLauncher>	WindowLauncherClass;

// replicated client grenade vars
var bool bGren1, bGren2, bGren3, bGren4;//, bGren5, bGren6, bGren7, bGren8, bGren9;

// bindable input vars. eg: "set input <key> button GrenX"
var input byte Gren1, Gren2, Gren3, Gren4;

var bool bChangedTeam; // internal variable used for when player changes team in game
var bool bDisplayClassMessage; // used to display the class message when a new player joins the game
var bool bLoginCanChangeTeam; // used as a hack to prevent players team being set twice in Login()

var bool bHUDMenu; // player is in HUD menu mode

var float FreezeTime; // how long to freeze the player before leaving the 'Frozen' state
var name FreezeTag;

replication
{
	// HUD menu related variables
	reliable if (Role < ROLE_Authority)
		bHUDMenu;

	// HUD menu related functions
	reliable if (Role == ROLE_Authority)
		ClientProcessInputNumber, ClientDisplayHUDMenu, ClearHUDMenus;

	// needs to be set SERVER SIDE
	reliable if (Role == ROLE_Authority)
		PCInfo, RelatedActors, PlayerRestartClass;

	// functions the client can call
	reliable if (Role < ROLE_Authority) // TODO: change to ServerChangeClass
		ChangePlayerClass, ServerSpecial, SetClass;

	// client variables
	reliable if (Role < ROLE_Authority)
		bGren1, bGren2, bGren3, bGren4;//, bGren5, bGren6, bGren7, bGren8, bGren9;

	// functions called by the server
	reliable if (Role == ROLE_Authority)
		ClientSetExtendedHUD, ClientDisplayUWindow, ClientDisplayUWindowClass;

	// Debug functions
//	reliable if (Role < ROLE_Authority)
//		PCSpectate, Ready, ShowTeamSizes, DefaultState, SetState, GetState;
}

// === PLAYER EXECS ===

/* debug execs
exec function Ready()
{
	bReadyToPlay = true;
}

exec function PCSpectate()
{
	GotoState('PCSpectating');
}

exec function DefaultState()
{
	GotoState(default.PlayerRestartState);
}

exec function ShowTeamSizes()
{
	if (myHUD != none)
	{
		WFS_PCSystemHUD(myHUD).DisplayHUDMenu(class'WFS_PCStartGameHUDMenu');
	}
	else
	{
		Log("[--Debug--]: ShowTeamSizes(): myHUD == 'None'");
	}
}

exec function GetState()
{
	local string s;
	s = string(GetStateName());
	ClientMessage("Current state is '"$s$"'", 'Critical');
}

exec function SetState(name StateName)
{
	ClientMessage("Setting state to '"$StateName$"'", 'Critical');
	GotoState(StateName);
}

exec function GetPlayerPhysics()
{
	ClientMessage("Current Physics is: "$GetPropertyText("Physics"), 'Critical');
}

exec function SetPlayerPhysics(EPhysics NewPhysics)
{
	SetPhysics(NewPhysics);
	ClientMessage("Physics set to: "$GetPropertyText("Physics"), 'Critical');
}*/

// game execs
exec function HUDMenu()
{
	if (PCInfo == none)
		return;

	if (PCInfo.default.HUDMenu != none)
		DisplayHUDMenu(PCInfo.default.HUDMenu);
}

// display help for the current player class
exec function ClassHelp();

exec function SetClass(coerce string newClass)
{
	if (newClass == "")
		ClientDisplayHUDMenu(PCSelectionMenuClass);
	else if (WFS_PCSystemGRI(GameReplicationInfo).bAllowClassChanging)
		WFS_PCSystemGame(Level.Game).SetRestartClass(self, newClass);
}

exec function Special(string SpecialString)
{
	if (!CanDoSpecial())
		return;

	if (PCInfo != None)
	{
		if (PCInfo.static.IsClientSideCommand(SpecialString))
			PCInfo.static.DoSpecial(self, SpecialString, 'ClientSide');
		else ServerSpecial(SpecialString);
	}
}

function ServerSpecial(string SpecialString)
{
	if (!CanDoSpecial())
		return;

	if (PCInfo != None)
		PCInfo.static.DoSpecial(self, SpecialString);
}

function bool CanDoSpecial()
{
	if (Health > 0)
		return true;

	return false;
}

// === PLAYER CLASS RELATED ===

function ChangePlayerClass(class<WFS_PlayerClassInfo> newClass)
{
	WFS_PCSystemGame(Level.Game).ChangePlayerClass(self, newClass);
}

// === HUD RELATED ===

function ClientSetExtendedHUD(class<WFS_HUDInfo> ExtendedHUDClass)
{
	if (myHUD != none)
		WFS_PCSystemHUD(myHUD).ChangeExtendedHUD(ExtendedHUDClass);
}

exec function SwitchWeapon(byte F)
{
	if (bHUDMenu)
		ClientProcessInputNumber(F);
	else super.SwitchWeapon(F);
}

function ClientProcessInputNumber(byte F)
{
	WFS_PCSystemHUD(myHUD).HUDMenuSelection(F);
}

function ClearHUDMenus()
{
	//Log("[--DEBUG--]: CLEARHUDMENUS(): myHUD == "$myHUD);
	if (myHUD != none)
		WFS_PCSystemHUD(myHUD).ClearHUDMenus();
}

function ClientDisplayHUDMenu(class<WFS_HUDMenuInfo> MenuClass, optional actor RelatedActor)
{
	if (MenuClass == none)
		return;
	DisplayHUDMenu(MenuClass, RelatedActor);
}

function DisplayHUDMenu(class<WFS_HUDMenuInfo> MenuClass, optional actor RelatedActor)
{
	if ((myHUD != none) && !IsInState('Dying'))
	{
		bHUDMenu = true;
		WFS_PCSystemHUD(myHUD).DisplayHUDMenu(MenuClass, RelatedActor);
	}
}

// === UWINDOW RELATED ===

// called by server to display a UWindow menu on the client
function ClientDisplayUWindow(class<WFS_WindowDisplayInfo> WindowDisplayClass)
{
	DisplayUWindow(WindowDisplayClass);
}

function ClientDisplayUWindowClass(string WDIClassName)
{
	local class<WFS_WindowDisplayInfo> WDIClass;

	WDIClass = class<WFS_WindowDisplayInfo>(DynamicLoadObject(WDIClassName, class'Class'));
	DisplayUWindow(WDIClass);
}

// display a UWindow menu
function DisplayUWindow(class<WFS_WindowDisplayInfo> WindowDisplayClass)
{
	local UMenuRootWindow RootWindow;
	local WindowConsole WinConsole;

	if (WindowDisplayClass == none)
		return;

	//Log("[--Debug--]: DisplayUWindow(): Using class: "$WindowDisplayClass);

	RootWindow = UMenuRootWindow(GetRootWindow());
	WinConsole = GetWindowConsole();

	if ((RootWindow == none) || (WinConsole == none))
		return;

	//Log("[--Debug--]: DisplayUWindow(): Calling "$WindowDisplayClass$".static.DisplayWindow()");

	//WindowDisplayClass.static.DisplayWindow(self, RootWindow, WinConsole);
	if (WindowLauncher == None)
	{
		WindowLauncher = spawn(WindowLauncherClass);
		WindowLauncher.Initialise(self, RootWindow, WinConsole);
	}

	WindowLauncher.LaunchUWindow(WindowDisplayClass);
}

// get the window console
function WindowConsole GetWindowConsole()
{
	if ((Player != none) && (Player.Console != none))
		return WindowConsole(Player.Console);

	return None;
}

// get the root window
function UWindowRootWindow GetRootWindow()
{
	local WindowConsole WinConsole;

	WinConsole = GetWindowConsole();
	if (WinConsole != none)
		return WinConsole.Root;

	return None;
}

// === PLAYER CLASS INFO NOTIFICATIONS ===

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						vector momentum, name damageType)
{
	local byte bIgnoreDamage;

	bIgnoreDamage = 0;
	if ((PCInfo != none) && (Role == ROLE_Authority))
		PCInfo.static.PlayerTakeDamage(self, Damage, instigatedBy, hitlocation, momentum, damageType, bIgnoreDamage);

	if (!bool(bIgnoreDamage))
		super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
}

function Died(pawn Killer, name damageType, vector HitLocation)
{
	ClearHUDMenus();

	if (PCInfo != none)
		PCInfo.static.PlayerDied(self, Killer, damageType, HitLocation);

	Super.Died(Killer, damageType, HitLocation);
}

// === PLAYER STATES ===

state PCSpectating
{
ignores SeePlayer, HearNoise, Bump, TakeDamage, Died, ZoneChange, FootZoneChange;

	exec function Jump( optional float F )
	{
	}

	exec function Suicide()
	{
	}

	function ChangeTeam( int N )
	{
		Level.Game.ChangeTeam(self, N);
	}

	exec function Fire( optional float F )
	{
		if (!bHUDMenu)
		{
			SetTimer(0.0, false);
			Timer();
		}
	}

	exec function AltFire( optional float F )
	{
		if (!bHUDMenu)
		{
			SetTimer(0.0, false);
			Timer();
		}
	}

	function ServerReStartPlayer()
	{
		if ( Level.NetMode == NM_Client )
			return;
		if( Level.Game.RestartPlayer(self) )
		{
			ServerTimeStamp = 0;
			TimeMargin = 0;
			Enemy = None;
			Level.Game.StartPlayer(self);
			if ( Mesh != None )
				PlayWaiting();
			ClientReStart();
		}
		else
			log("Restartplayer failed");
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)
	{
		Acceleration = NewAccel;
		MoveSmooth(Acceleration * DeltaTime);
	}

	function PlayWaiting() {}

	event PlayerTick( float DeltaTime )
	{
		if ( bUpdatePosition )
			ClientUpdatePosition();

		PlayerMove(DeltaTime);
	}

	function PlayerMove(float DeltaTime)
	{
		local rotator newRotation;
		local vector X,Y,Z;

		GetAxes(ViewRotation,X,Y,Z);

		aForward *= 0.1;
		aStrafe  *= 0.1;
		aLookup  *= 0.24;
		aTurn    *= 0.24;
		aUp		 *= 0.1;

		Acceleration = aForward*X + aStrafe*Y + aUp*vect(0,0,1);

		UpdateRotation(DeltaTime, 1);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
	}

	function EndState()
	{
		SetMesh();
		bHidden = false;
		PlayerReplicationInfo.bIsSpectator = false;
		SetCollision(true,true,true);
	}

	function BeginState()
	{
		Mesh = None;
		bHidden = true;
		if ( PlayerReplicationInfo != None )
		{
			PlayerReplicationInfo.bIsSpectator = true;
			PlayerReplicationInfo.bWaitingPlayer = false;
		}
		SetCollision(false,false,false);
		EyeHeight = BaseEyeHeight;
		SetPhysics(PHYS_None);
		if (MyHUD != None)
		{
			SetTimer(0.0, false);
			Timer();
		}
		else if (ViewPort(Player) != None)
			SetTimer(MenuDisplayDelay, false);
	}

	function Timer()
	{
		if (myHUD != none)
		{
			bBehindview = false;
			ClearProgressMessages();
			if (StartGameWindowInfoClass != none)
				DisplayUWindow(StartGameWindowInfoClass);
			if (StartGameMenuClass != none)
				DisplayHUDMenu(StartGameMenuClass);
		}
		else
		{
			SetTimer(1.0, false);
			//Log("[--DEBUG--]: myHUD == none, cannot display menu...");
		}
	}
}

state PlayerWalking
{
ignores SeePlayer, HearNoise, Bump;

	exec function FeignDeath()
	{
		if ( Physics == PHYS_Walking )
		{
			if (!PCInfo.default.bAllowFeignDeath)
				return;
			ServerFeignDeath();
			Acceleration = vect(0,0,0);
			GotoState('FeigningDeath');
		}
	}

	function FreezePlayer(optional float NewFreezeTime, optional name NewFreezeTag)
	{
		FreezeTime = NewFreezeTime;
		FreezeTag = NewFreezeTag;
		GotoState('Frozen');
	}
}

// === INPUT ===

function PlayerInput(float DeltaTime)
{
	super.PlayerInput(DeltaTime);

	// replicate the grenade input vars
	ReplicateGrenadeVars(DeltaTime);
}

function ReplicateGrenadeVars(float DeltaTime)
{
	local name CurrentState;

	CurrentState = GetStateName();
	if ((CurrentState == 'Frozen') || (CurrentState == 'GameEnded'))
	{
		bGren1 = false;
		bGren2 = false;
		bGren3 = false;
		bGren4 = false;
	}
	else
	{
		bGren1 = bool(Gren1);
		bGren2 = bool(Gren2);
		bGren3 = bool(Gren3);
		bGren4 = bool(Gren4);
	}
}

// === MISC STATES AND FUNCTIONS ===

function FreezePlayer(optional float NewFreezeTime, optional name NewFreezeTag);
function UnfreezePlayer(optional name UnfreezeTag);

// player is frozen and can't move
state Frozen
{
ignores SwitchWeapon, NextWeapon, PrevWeapon, GetWeapon, SwitchToBestWeapon;

	exec function Fire( optional float F ) { }
	exec function AltFire( optional float F ) { }
	exec function Special(string SpecialString) { }
	exec function Taunt( name Sequence ) { }

	function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)
	{
		Acceleration = NewAccel;
		MoveSmooth(Acceleration * DeltaTime);
	}

	function PlayerMove(float DeltaTime)
	{
		local rotator newRotation;
		local vector X,Y,Z;

		/*GetAxes(ViewRotation,X,Y,Z);

		aForward *= 0.1;
		aStrafe  *= 0.1;
		aLookup  *= 0.24;
		aTurn    *= 0.24;
		aUp		 *= 0.1;

		Acceleration = aForward*X + aStrafe*Y + aUp*vect(0,0,1);

		UpdateRotation(DeltaTime, 1);*/
		Acceleration = vect(0,0,0);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));

		ViewShake(DeltaTime);
		ViewFlash(DeltaTime);
	}

	function ServerMove
	(
		float TimeStamp,
		vector Accel,
		vector ClientLoc,
		bool NewbRun,
		bool NewbDuck,
		bool NewbJumpStatus,
		bool bFired,
		bool bAltFired,
		bool bForceFire,
		bool bForceAltFire,
		eDodgeDir DodgeMove,
		byte ClientRoll,
		int View,
		optional byte OldTimeDelta,
		optional int OldAccel
	)
	{
		Global.ServerMove(
					TimeStamp,
					Accel,
					ClientLoc,
					false,
					false,
					false,
					false,
					false,
					false,
					false,
					DodgeMove,
					ClientRoll,
					View);
	}

	event PlayerTick( float DeltaTime )
	{
		if ( bUpdatePosition )
			ClientUpdatePosition();

		PlayerMove(DeltaTime);
	}

	function BeginState()
	{
		Velocity = vect(0,0,0);
		Acceleration = vect(0,0,0);
		BaseEyeheight = Default.BaseEyeHeight;
		EyeHeight = BaseEyeHeight;
		//if ( Carcass(ViewTarget) == None )
		//	bBehindView = true;
		//bFrozen = true;
		bPressedJump = false;
		bJustFired = false;
		bJustAltFired = false;

		// clean out saved moves
		while ( SavedMoves != None )
		{
			SavedMoves.Destroy();
			SavedMoves = SavedMoves.NextMove;
		}
		if ( PendingMove != None )
		{
			PendingMove.Destroy();
			PendingMove = None;
		}

		if ((Role == ROLE_Authority) && (FreezeTime > 0.0))
			SetTimer(FreezeTime, false);
	}

	function Timer()
	{
		UnfreezePlayer('TimerEndFrozenState');
	}

	function EndState()
	{
		// clean out saved moves
		while ( SavedMoves != None )
		{
			SavedMoves.Destroy();
			SavedMoves = SavedMoves.NextMove;
		}
		if ( PendingMove != None )
		{
			PendingMove.Destroy();
			PendingMove = None;
		}
		Velocity = vect(0,0,0);
		Acceleration = vect(0,0,0);
		//bBehindView = false;
		bShowScores = false;
		bJustFired = false;
		bJustAltFired = false;
		bPressedJump = false;
		ViewTarget = None;
		SetTimer(0.0, false);
	}

	function FreezePlayer(optional float NewFreezeTime, optional name NewFreezeTag)
	{
		if ((TimerRate - TimerCounter) < NewFreezeTime)
		{
			FreezeTag = NewFreezeTag;
			FreezeTime = NewFreezeTime;
			SetTimer(NewFreezeTime, false);
		}
	}

	function UnfreezePlayer(optional name UnfreezeTag)
	{
		if ( (FreezeTag == '') || (UnfreezeTag == 'TimerEndFrozenState')
			|| (UnfreezeTag == FreezeTag) )
		{
			FreezeTime = 0.0;
			FreezeTag = '';
			GotoState('PlayerWalking');
		}
	}
}

defaultproperties
{
	StartGameMenuClass=class'WFS_PCStartGameHUDMenu'
	PCSelectionMenuClass=class'WFS_PCSelectionMenu'
	MenuDisplayDelay=5.00000
	WindowLauncherClass=class'WFS_PCSWindowLauncher'
}