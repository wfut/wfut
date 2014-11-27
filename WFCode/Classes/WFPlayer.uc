//=============================================================================
// WFPlayer.
// Authors: Ob1-Kenobi (ob1@planetunreal.com)
//          ca (ca@planetunreal.com) -- chat macros
//          Mongo (mongo@planetunreal.com) -- crouching code
//
// The Weapons Factory player class.
//
// Add stuff here rather than change the PCSystem player class. If need be
// features can be added to the WFS_PCSystemPlayer class at a later date.
//=============================================================================
class WFPlayer extends WFS_PCSystemPlayer;

var bool bNoFrozenAnim; // don't play animations for this player while in 'Frozen' state

var float lastlog;

var byte Armor; // the players armor (maintained by WFArmor)
var string TeamPassword;
var bool bLoginComplete; // set server-side in PostLogin()

var config bool bAutoLoadClassBindings;

var int MaxActiveAmmoDrops;

var bool bJoinedGame;

var string GameMenuWDI, ClassGameMenuWDI, GameMenuClass;

var bool bFlagTouchDisabled; // this player cant touch the flag

// crouching vars
var float DuckHeight;
var float LastLocCheck;
var bool bStandingUp;
var bool bJustChangedCollision;
var ZoneInfo LastZone;

struct SAutoEvent
{
	var() string EventName; // the event name
	var() string CmdType;   // the command type
	var() string CmdString; // the command string
};

var SAutoEvent AutoEvents[64];

var SAutoEvent PendingEvent;
var float PendingEventTimeout; // time before event is cancelled
var name PendingEventType;
var bool bUserSendEvent;

// referee vars
var bool bReferee; // player is a referee
var WFRefereeInfo RefInfo; // set by the gameinfo
var bool bMute; // player cannot send messages
var int RefViewingTeam;

// flood protection
var bool bAdminLoginDisabled;
var float FirstAdminLoginTime;
var int NumAdminLogins;
var float FirstRefLoginTime;
var int NumRefLogins;
var bool bRefLoginDisabled;

// status rendering chain
var WFPlayerStatus RenderExclusive, RenderChain;

var bool bSuicided;

replication
{
	reliable if (Role == ROLE_Authority)
		Armor;

	reliable if (Role < ROLE_Authority)
		PasswordChangeTeam, SetTeamPassword;

	// console execs
	reliable if (Role < ROLE_Authority)
		DropAmmo, ServerProcessEvent;

	reliable if (bNetOwner && (Role == ROLE_Authority))
		ClientLoadClassBindings, ClientReceiveEvent;

    reliable if (Role < ROLE_Authority)
        RefLogin, RefLogout, Ref, DebugInfo;
}

//=============================================================================
// DEGBUG.
//=============================================================================

exec function DebugInfo()
{
	ClientMessage("State: "$GetStateName());
	ClientMessage("Physics: "$GetPropertyText("Physics"));
	ClientMessage("Collision: "$bCollideWorld$" "$bBlockPlayers$" "$bBlockActors);
	ClientMessage("PRI Flags: bIsSpectator "$PlayerReplicationInfo.bIsSpectator$", bWaitingPlayer "$PlayerReplicationInfo.bWaitingPlayer);
	ClientMessage("bFlagTouchDisabled: "$bFlagTouchDisabled);
	ClientMessage("bHidden: "$bHidden$", Mesh: "$Mesh);
}

exec function GetState()
{
	ClientMessage("Current state: "$GetStateName());
	ClientMessage("Restart state: "$PlayerRestartState);
}

function DLog(coerce string S, optional float delay)
{
	if ((Level.TimeSeconds - LastLog) > delay)
	{
		if (Delay > 0.0)
			LastLog = Level.TimeSeconds;
		Log(S);
	}
}

exec function Admin( string CommandLine )
{
	if (bAdmin && (InStr(Caps(CommandLine), "GET") != -1) && (InStr(CommandLine, "ADMINPASSWORD") != -1))
		return; // surely a logged in admin would already know the admin password? :o)

	super.Admin(CommandLine);
}

//=============================================================================
// STATUS RENDERING CODE.
//=============================================================================

simulated function PostRender( canvas Canvas )
{
	RenderPlayerStatus(Canvas);
	super.PostRender(Canvas);
}

simulated function RenderPlayerStatus(canvas Canvas)
{
	if ((RenderExclusive != None) && RenderExclusive.bExclusiveRender)
	{
		if (RenderExclusive.bDeleteMe)
			RenderExclusive = None;
		else
		{
			RenderExclusive.RenderStatus(Canvas);
			return;
		}
	}

	if (RenderChain != None)
		RenderChain.RenderStatusChain(Canvas);
}

simulated function AddRenderedStatus(WFPlayerStatus NewStatus)
{
	if ((NewStatus.Role == ROLE_Authority) && (Level.NetMode == NM_Client))
		return;

	if (NewStatus.bExclusiveRender)
	{
		if ((RenderExclusive == None) || (RenderExclusive.bDeleteMe)
			|| (RenderExclusive.RenderPriority < NewStatus.RenderPriority))
		{
			RenderExclusive = NewStatus;
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

	if (RenderExclusive == OldStatus)
	{
		RenderExclusive = None;
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

//=============================================================================
// EVENT CODE.
//=============================================================================

function ClientReceiveEvent(string EventID, name EventType)
{
	local string CmdType, CmdString;
	local int Index;

	//Log("Received event: "$EventID$", "$EventType);

	Index = GetEventIndex(EventID);
	if (Index == -1)
		return; // no command set up for this event

	if (AutoEvents[Index].CmdType == "")
	{
		// bad command setup, clear this autoevent
		AutoEvents[Index].EventName = "";
		AutoEvents[Index].CmdString = "";
		return;
	}
	CmdType = AutoEvents[Index].CmdType;
	CmdString = AutoEvents[Index].CmdString;

	// possibly handle some command types clientside
	ClientProcessEvent(EventID, EventType, CmdType, CmdString);

	// send the command back to the server for processing
	if (!bUserSendEvent)
		ServerProcessEvent(EventID, EventType, CmdType, CmdString);
}

function ClientProcessEvent(string EventName, name EventType, string CmdType, string CmdString)
{
	// save the event
	if (bUserSendEvent)
	{
		//Log("Saving Pending Event: "$EventName$":"$CmdType$":"$CmdString);
		PendingEvent.EventName = EventName;
		PendingEvent.CmdType = CmdType;
		PendingEvent.CmdString = CmdString;
		PendingEventType = EventType;
		PendingEventTimeout = Level.TimeSeconds + 5.0;
	}
}

function ServerProcessEvent(string EventName, name EventType, string CmdType, string CmdString)
{
	// handle the event serverside
	//Log("Received Event: "$EventName$"/"$EventType$"/"$CmdType$"/"$CmdString);
	switch (caps(CmdType))
	{
		case "SAY":
			// TODO: maybe allow for global auto-message filtering later
			if (CmdString != "")
				Say(CmdString);
			break;

		case "TEAMSAY":
			if (CmdString != "")
				TeamSay(CmdString);
			break;
	}
}

/*
Auto Events
-----------
Auto events are notifications received from the server that can
optionally be handled by the client, like for sending a team
message for a special ability action.

You can set an auto event using the SetEvent command, eg.

"SetEvent EventName:CmdType:CmdString"

Will set handle an event received matching EventName, and respond
with CmdType and CmdString.

Currently supported AutoEvent command types:

	Say - send CmdString as a global chat message
	TeamSay - send CmdString as a team chat message

*/

// events are set using the following format: [event]:[cmd_type]:[cmd_string]
// eg. "large_plasma_set:teamsay:Large plasma set at %L"
exec function SetEvent(coerce string EventString)
{
	local string EventName, CmdType, CmdString;
	local int pos;

	if (EventString == "")
		return;

	pos = InStr(EventString, ":");
	if (pos == -1)
		return; // bad command format

	// get the event name
	EventName = Left(EventString, pos);
	EventString = Right(EventString, Len(EventString) - (Len(EventName)+1));

	// get the command type and command string
	pos = InStr(EventString, ":");
	if (pos != -1)
	{
		CmdType = Left(EventString, pos);
		CmdString = Right(EventString, Len(EventString) - (Len(CmdType)+1));
	}
	else
	{
		CmdType = EventString;
		CmdString = "";
	}

	// add the event to the event list
	AddEvent(EventName, CmdType, CmdString);
}

exec function SendAutoMessage()
{
	if (bUserSendEvent && (PendingEventTimeout != -1) && (Level.TimeSeconds < PendingEventTimeout))
	{
		//Log("Sending Pending Event: "$PendingEvent.EventName$":"$PendingEvent.CmdType$":"$PendingEvent.CmdString);
		ServerProcessEvent(PendingEvent.EventName, PendingEventType, PendingEvent.CmdType, PendingEvent.CmdString);
		PendingEvent.EventName = "";
		PendingEvent.CmdType = "";
		PendingEvent.CmdString = "";
		PendingEventType = '';
		PendingEventTimeout = -1;
	}
	//else Log("Not sending pending event: "$PendingEvent.EventName$":"$PendingEvent.CmdType$":"$PendingEvent.CmdString);
}

function AddEvent(string EventName, string CmdType, string CmdString)
{
	local int i;

	//Log("Adding Event: "$EventName$":"$CmdType$":"$CmdString);
	for (i=0; i<ArrayCount(AutoEvents); i++)
	{
		if ((AutoEvents[i].EventName == "") || (AutoEvents[i].EventName ~= EventName))
		{
			AutoEvents[i].EventName = EventName;
			AutoEvents[i].CmdType = CmdType;
			AutoEvents[i].CmdString = CmdString;
			break;
		}
	}
}

function int GetEventIndex(coerce string EventName)
{
	local int i;
	for (i=0; i<ArrayCount(AutoEvents); i++)
	{
		//Log("GetEventIndex: comparing "$AutoEvents[i].EventName$" with "$EventName);
		if (AutoEvents[i].EventName ~= EventName)
		{
			//Log("GetEventIndex: match found!");
			return i;
		}
	}

	return -1; // event not found
}

exec function ClearEvents()
{
	local int i;
	for (i=0; i<ArrayCount(AutoEvents); i++)
	{
		AutoEvents[i].EventName = "";
		AutoEvents[i].CmdType = "";
		AutoEvents[i].CmdString = "";
	}
}

//=============================================================================
// Referee code.
//=============================================================================

// "ref" command syntax: "ref [cmd] [params]"
exec function Ref(coerce string Command)
{
    local string cmd, params;
    local int pos;

    if (!bReferee)
    {
        ClientMessage("You must log in using 'RefLogin (password)' first");
        return;
	}

    pos = InStr(Command, " ");
    if (pos != -1)
    {
        cmd = Left(Command, pos);
        params = Mid(Command, pos+1);
    }
    else
    {
        cmd = Command;
        params = "";
    }

    if (RefInfo != None)
        RefInfo.RefCommand(self, cmd, params);
}

exec function RefLogin(coerce string LoginPwd)
{
    if (RefInfo != None)
        RefInfo.RefLogin(self, LoginPwd);
}

exec function RefLogout()
{
    if (RefInfo != None)
        RefInfo.RefLogout(self);
}

//=============================================================================
// Auto-exec script code.
//=============================================================================

function ClientLoadClassBindings(class<WFS_PlayerClassInfo> ClassPCI)
{
	local string filename, result;
	if (bAutoLoadClassBindings && (Viewport(Player) != None))
	{
		filename = ClassPCI.default.ClassName;
		ReplaceText(filename, " ", "_");
		ClearEvents();
		ClientMessage("Loading config file: "$filename$".exec", 'Critical', false);
		result = ConsoleCommand("exec "$filename$".exec");
		if (Result != "")
			ClientMessage(result, 'Critical', false);
	}
}

exec function KeyConfig()
{
	ClientDisplayUWindow(class'WFBasicKeyBindingMenuWDI');
}

exec function LoadClassBindings()
{
	local string filename, result;
	if (PCInfo == None)
		return;
	filename = PCInfo.default.ClassName;
	ReplaceText(filename, " ", "_");
	ClearEvents();
	ClientMessage("Loading config file: "$filename$".exec", 'Critical', false);
	Result = ConsoleCommand("exec "$filename$".exec");
	if (Result != "")
		ClientMessage(Result, 'Critical', false);
}

// restore default UT key mapings for number keys 1->0
exec function Restore_NumKeys()
{
	/*
	local string result;
	result = ConsoleCommand("exec def_numkeys.bind");
	if (Result != "")
		ClientMessage(Result, 'Critical', false);
	*/

	ConsoleCommand("set input 1 SwitchWeapon 1");
	ConsoleCommand("set input 2 SwitchWeapon 2");
	ConsoleCommand("set input 3 SwitchWeapon 3");
	ConsoleCommand("set input 4 SwitchWeapon 4");
	ConsoleCommand("set input 5 SwitchWeapon 5");
	ConsoleCommand("set input 6 SwitchWeapon 6");
	ConsoleCommand("set input 7 SwitchWeapon 7");
	ConsoleCommand("set input 8 SwitchWeapon 8");
	ConsoleCommand("set input 9 SwitchWeapon 9");
	ConsoleCommand("set input 0 SwitchWeapon 10");
}

//=============================================================================
// WF overridden functions.
//=============================================================================

event TeamMessage( PlayerReplicationInfo PRI, coerce string S, name Type, optional bool bBeep  )
{
	// TODO: add special handling for referee messages
	if (S == "")
		return;

	if (Type == 'RefSay')
		Type = 'Say';
	else if (Type == 'RefTeamSay')
		Type = 'TeamSay';

	if (Player.Console != None)
		Player.Console.Message ( PRI, S, Type );
	if (bBeep && bMessageBeep)
		PlayBeepSound();
	if ( myHUD != None )
		myHUD.Message( PRI, S, Type );
}

// added support for the WF translocator
exec function GetWeapon(class<Weapon> NewWeaponClass )
{
	if (NewWeaponClass == class'Translocator')
	{
		if (FindInventoryType(class'Translocator') == None)
		{
			super.GetWeapon(class'WFTranslocator');
			return;
		}
	}
	super.GetWeapon(NewWeaponClass);
}

// Overridden to add the CanReduceDamageFor() function call that allows
// certain damage types to be unaffected by a players armor (eg. 'Infection')
function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						Vector momentum, name damageType)
{
	local int actualDamage;
	local bool bAlreadyDead;
	local byte bIgnoreDamage;

	if ( Role < ROLE_Authority )
	{
		log(self$" client damage type "$damageType$" by "$instigatedBy);
		return;
	}

	// notify PCI
	bIgnoreDamage = 0;
	if (PCInfo != none)
		PCInfo.static.PlayerTakeDamage(self, Damage, instigatedBy, hitlocation, momentum, damageType, bIgnoreDamage);

	if (bool(bIgnoreDamage))
		return;

	//log(self@"take damage in state"@GetStateName());
	bAlreadyDead = (Health <= 0);

	if (Physics == PHYS_None)
		SetMovementPhysics();
	if (Physics == PHYS_Walking)
		momentum.Z = FMax(momentum.Z, 0.4 * VSize(momentum));
	if ( instigatedBy == self )
		momentum *= 0.6;
	momentum = momentum/Mass;

	actualDamage = Level.Game.ReduceDamage(Damage, DamageType, self, instigatedBy);
	if ( bIsPlayer )
	{
		if (ReducedDamageType == 'All') //God mode
			actualDamage = 0;
		else if ((Inventory != None) && CanReduceDamageFor(DamageType))//then check if carrying armor
			actualDamage = Inventory.ReduceDamage(actualDamage, DamageType, HitLocation);
		/* Ob1: no point doing this, as it'll cancel out Level.Game.ReduceDamage()
		        if "Inventory==None", or if the damage type can't be reduced by armor.
		else
			actualDamage = Damage;
		*/
	}
	else if ( (InstigatedBy != None) &&
				(InstigatedBy.IsA(Class.Name) || self.IsA(InstigatedBy.Class.Name)) )
		ActualDamage = ActualDamage * FMin(1 - ReducedDamagePct, 0.35);
	else if ( (ReducedDamageType == 'All') ||
		((ReducedDamageType != '') && (ReducedDamageType == damageType)) )
		actualDamage = float(actualDamage) * (1 - ReducedDamagePct);

	if ( Level.Game.DamageMutator != None )
		Level.Game.DamageMutator.MutatorTakeDamage( ActualDamage, Self, InstigatedBy, HitLocation, Momentum, DamageType );

	AddVelocity( momentum );
	Health -= actualDamage;
	if (CarriedDecoration != None)
		DropDecoration();
	if ( HitLocation == vect(0,0,0) )
		HitLocation = Location;
	if (Health > 0)
	{
		if ( (instigatedBy != None) && (instigatedBy != Self) )
			damageAttitudeTo(instigatedBy);
		PlayHit(actualDamage, hitLocation, damageType, Momentum);
	}
	else if ( !bAlreadyDead )
	{
		//log(self$" died");
		NextState = '';
		PlayDeathHit(actualDamage, hitLocation, damageType, Momentum);
		if ( actualDamage > mass )
			Health = -1 * actualDamage;
		if ( (instigatedBy != None) && (instigatedBy != Self) )
			damageAttitudeTo(instigatedBy);
		Died(instigatedBy, damageType, HitLocation);
	}
	else
	{
		//Warn(self$" took regular damage "$damagetype$" from "$instigator$" while already dead");
		// SpawnGibbedCarcass();
		if ( bIsPlayer )
		{
			HidePlayer();
			GotoState('Dying');
		}
		else
			Destroy();
	}
	MakeNoise(1.0);
}

function PlayHit(float Damage, vector HitLocation, name damageType, vector Momentum)
{
	local float rnd;
	local Bubble1 bub;
	local bool bServerGuessWeapon;
	local class<DamageType> DamageClass;
	local vector BloodOffset, Mo;
	local int iDam;

	if ( (Damage <= 0) && (ReducedDamageType != 'All') )
		return;

	//DamageClass = class(damageType);
	if ( ReducedDamageType != 'All' ) //spawn some blood
	{
		if (damageType == 'Drowned')
		{
			bub = spawn(class 'Bubble1',,, Location
				+ 0.7 * CollisionRadius * vector(ViewRotation) + 0.3 * EyeHeight * vect(0,0,1));
			if (bub != None)
				bub.DrawScale = FRand()*0.06+0.04;
		}
		else if ( (damageType != 'Burned') && (damageType != 'Corroded')
					&& (damageType != 'Fell') )
		{
			BloodOffset = 0.2 * CollisionRadius * Normal(HitLocation - Location);
			BloodOffset.Z = BloodOffset.Z * 0.5;
			if ( (DamageType == 'shot') || (DamageType == 'decapitated') || (DamageType == 'shredded') )
			{
				Mo = Momentum;
				if ( Mo.Z > 0 )
					Mo.Z *= 0.5;
				spawn(class 'UT_BloodHit',self,,hitLocation + BloodOffset, rotator(Mo));
			}
			else
				spawn(class 'UT_BloodBurst',self,,hitLocation + BloodOffset);
		}
	}

	rnd = FClamp(Damage, 20, 60);
	if ( damageType == 'Burned' )
		ClientFlash( -0.009375 * rnd, rnd * vect(16.41, 11.719, 4.6875));
	else if ( damageType == 'Corroded' )
		ClientFlash( -0.01171875 * rnd, rnd * vect(9.375, 14.0625, 4.6875));
	else if ( damageType == 'Drowned' )
		ClientFlash(-0.390, vect(312.5,468.75,468.75));
	else if (!HandleDamageFlash(Damage, DamageType))
		ClientFlash( -0.019 * rnd, rnd * vect(26.5, 4.5, 4.5));

	ShakeView(0.15 + 0.005 * Damage, Damage * 30, 0.3 * Damage);
	PlayTakeHitSound(Damage, damageType, 1);
	bServerGuessWeapon = ( ((Weapon != None) && Weapon.bPointing) || (GetAnimGroup(AnimSequence) == 'Dodge') );
	iDam = Clamp(Damage,0,200);
	ClientPlayTakeHit(hitLocation - Location, iDam, bServerGuessWeapon );
	if ( !bServerGuessWeapon
		&& ((Level.NetMode == NM_DedicatedServer) || (Level.NetMode == NM_ListenServer)) )
	{
		Enable('AnimEnd');
		BaseEyeHeight = Default.BaseEyeHeight;
		bAnimTransition = true;
		PlayTakeHit(0.1, hitLocation, Damage);
	}
}

function ChangeTeam( int N )
{
	local int OldTeam, OldScore, OldDeaths;

	OldTeam = PlayerReplicationInfo.Team;
	if (N != PlayerReplicationInfo.Team)
		Level.Game.ChangeTeam(self, N);
	if ( Level.Game.bTeamGame && (PlayerReplicationInfo.Team != OldTeam) )
	{
		// save old score
		OldScore = PlayerReplicationInfo.Score;
		OldDeaths = PlayerReplicationInfo.Deaths;
		Died( None, '', Location );
		// restore old score
		PlayerReplicationInfo.Score = OldScore;
		PlayerReplicationInfo.Deaths = OldDeaths;
	}
}

//=============================================================================
// WF console execs
//=============================================================================

exec function ChangeClass(coerce string ClassName)
{
	SetClass(ClassName);
}

exec function SetClass(coerce string newClass)
{
	if (newClass == "")
		ClientDisplayUWindowClass(ClassGameMenuWDI);
	else if (WFS_PCSystemGRI(GameReplicationInfo).bAllowClassChanging)
	{
		WFGame(Level.Game).SetRestartClass(self, newClass);
		if ((PlayerRestartClass != None) && (PlayerRestartState == 'PCSpectating')
			&& IsInState('Dying'))
		{
			PlayerRestartState = 'PlayerWalking';
			WFGame(Level.Game).ChangePlayerClass(self, PlayerRestartClass);
			//PCInfo = class'WFPlayerClassInfo'; // ensure player restarts with new class
			//PCInfo = PlayerRestartClass;
		}
	}
}

exec function ClassHelp()
{
	DisplayUWindow(class'WFClassHelpWDI');
}

exec function GameMenu()
{
	ClientDisplayUWindowClass(GameMenuWDI);
}

exec function Special(string SpecialString)
{
	local string Command;
	local int pos, num;

	if (!CanDoSpecial())
		return;

	pos = InStr(caps(SpecialString), "CLASS_COMMAND");
	Command = "None";
	if ((pos != -1) && ClassIsChildOf(PCInfo, class'WFPlayerClassInfo'))
	{
		//num = int(Right(SpecialString, 1);
		num = int(Right(SpecialString, Len(SpecialString) - 13));
		if ((num > 0) && (num < ArrayCount(class'WFPlayerClassInfo'.default.CommandSlot)))
			Command = class<WFPlayerClassInfo>(PCInfo).default.CommandSlot[num];
	}

	if (Command == "None")
		Command = SpecialString;

	if (PCInfo != None)
	{
		if (PCInfo.static.IsClientSideCommand(Command))
			PCInfo.static.DoSpecial(self, Command, 'ClientSide');
		else ServerSpecial(Command);
	}
}

exec function Team(string Team)
{
	local int TeamNum;
	if (Team ~= "") return;

	TeamNum = 255;
	switch (caps(Team))
	{
		case "RED": TeamNum = 0; break;
		case "BLUE": TeamNum = 1; break;
		case "GREEN": TeamNum = 2; break;
		case "YELLOW":
		case "GOLD": TeamNum = 3; break;
	}

	ChangeTeam(TeamNum);
}

exec function SetTeamPassword(coerce string Pwd)
{
	if (Pwd != "")
		TeamPassword = Pwd;
}

exec function AutoClassExecs(bool bEnable)
{
	bAutoLoadClassBindings = bEnable;
	default.bAutoLoadClassBindings = bEnable;
	SaveConfig();
}

// drop ammo from current weapon
exec function DropAmmo(optional int Amount)
{
	local WFBackpack Pack;
	local rotator Dir;
	local int count;
	local pawn aPawn;

	if ((weapon == None) || (weapon.AmmoType == None) || Weapon.AmmoType.IsA('WFRechargingAmmo'))
		return;

	count = 0;
	aPawn = self;
	foreach Allactors(class'WFBackpack', Pack, aPawn.name)
	{
		if ((Pack != None) && !Pack.bDeleteMe)
			count++;
	}

	if (Count >= MaxActiveAmmoDrops)
	{
		ClientMessage("Cannot drop more than "$MaxActiveAmmoDrops$" ammo packs.", 'Critical');
		return;
	}

	if (Amount == 0)
		Amount = Weapon.AmmoType.default.AmmoAmount;

	if (Amount > Weapon.AmmoType.AmmoAmount)
		Amount = Weapon.AmmoType.AmmoAmount;

	Pack = None;
	Pack = spawn(class'WFBackPack',, aPawn.name, Location);
	if (Pack != None)
	{
		Dir = ViewRotation;
		Dir.Pitch = 0;
		Dir.Roll = 0;
		Weapon.AmmoType.UseAmmo(Amount);
		if (Weapon.AmmoType.AmmoAmount == 0)
			SwitchToBestWeapon();
		Pack.LifeSpan = 30.0;
		Pack.Velocity = vector(Dir)*300 + vect(0,0,1)*150;
		Pack.AmmoTypes[0] = Weapon.AmmoType.Class;
		Pack.AmmoAmounts[0] = Amount;
		Pack.DropFrom(Location);
	}
}

//=============================================================================
// WF Functions
//=============================================================================

function bool IsImmuneTo(class<WFPlayerStatus> StatusClass)
{
	local bool bIsImmune;

	if (class<WFPlayerClassInfo>(PCInfo) != None)
		bIsImmune = class<WFPlayerClassInfo>(PCInfo).static.IsImmuneTo(StatusClass);

	return bIsImmune || (FindInventoryType(class'WFSpawnProtector') != None);
}

// set up a root window class that wont load the Mod menu
function InitMenu(canvas Canvas)
{
	local UTConsole PlayerConsole;
	local UMenuMenuBar MenuBar;
	local string OldRootWindow;

	if ((Player != none) && (Level.NetMode != NM_DedicatedServer)
		&& (PlayerSetupWindowClass != none))
	{
		PlayerConsole = UTConsole(Player.Console);
		if (PlayerConsole == none)
		{
			//Log("[--Debug--]: PlayerConsole == none");
			return;
		}

		// try to replace the current Preferences menu
		if (!PlayerConsole.bCreatedRoot)
		{
			//Log("[--Debug--]: Creating root window...");
			OldRootWindow = PlayerConsole.RootWindow;
			PlayerConsole.RootWindow = "WFCode.WFRootWindow";
			PlayerConsole.CreateRootWindow(Canvas);
			PlayerConsole.CloseUWindow();
			PlayerConsole.RootWindow = OldRootWindow;
		}

		MenuBar = UMenuRootWindow(PlayerConsole.Root).MenuBar;
		if (MenuBar == none)
		{
			//Log("[--Debug--]: MenuBar == none");
			return;
		}

		if (MenuBar.Options.PlayerWindowClass != PlayerSetupWindowClass)
		{
			//Log("[--Debug--]: Replacing the PlayerWindowClass");
			MenuBar.Options.PlayerWindowClass = PlayerSetupWindowClass;
			bMenuClassSetup = true;
		}
	}
}

// retruns true if player is allowed do a special ability command
function bool CanDoSpecial()
{
	if ((Health > 0) && !IsInState('Frozen') && !IsInState('PlayerWaiting')
		&& !IsInState('GameEnded'))
		return true;

	return false;
}

// change player class
function ChangePlayerClass(class<WFS_PlayerClassInfo> newClass)
{
	local string Reason;
	if (NewClass == None)
		return;

	if (IsInState('PCSpectating') || IsInState('Dying'))
	{
		// only change to the desired class if allowed
		if (WFGame(Level.Game).ValidPlayerClass(self, NewClass, Reason))
			WFGame(Level.Game).ChangePlayerClass(self, newClass);
		else
		{
			// display message if class change not allowed
			if (Reason != "")
				ClientMessage("Cannot change to the '"$NewClass.default.ClassName$"' class: "$Reason, 'Critical');
			else
				ClientMessage("Cannot change to the '"$NewClass.default.ClassName$"' class.", 'Critical');
		}
	}
	else
	{
		WFGame(Level.Game).SetRestartClass(self, newClass.default.ClassName);
		if ((PlayerRestartClass != None) && (PlayerRestartState == 'PCSpectating')
			&& IsInState('Dying'))
		{
			PlayerRestartState = 'PlayerWalking';
			WFGame(Level.Game).ChangePlayerClass(self, PlayerRestartClass);
			//PCInfo = class'WFPlayerClassInfo'; // ensure player restarts with new class
			//PCInfo = PlayerRestartClass;
		}
	}
}

// chage to a passworded team
function PasswordChangeTeam(byte DesiredTeam, string Pwd)
{
	TeamPassword = Pwd;
	ChangeTeam(DesiredTeam);
}

// return false if damage caused by this damage type shouldn't
// be reduced by carried armor
function bool CanReduceDamageFor(name DamageType)
{
	local WFPCIList list;
	local WFS_PCSystemGRI GRI;
	local int PlayersTeam;

	GRI = WFS_PCSystemGRI(GameReplicationInfo);
	PlayersTeam = PlayerReplicationInfo.Team;
	if (PlayersTeam < 4)
	{
		list = WFPCIList(GRI.TeamClassList[PlayersTeam]);
		if (list != None)
			return list.CanReduceDamageFor(DamageType);
	}

	return true;
}

// handle a damage flash from play hit, return true if handled
function bool HandleDamageFlash(float Damage, name DamageType)
{
	local WFPCIList list;
	local WFS_PCSystemGRI GRI;
	local int PlayersTeam;

	GRI = WFS_PCSystemGRI(GameReplicationInfo);
	PlayersTeam = PlayerReplicationInfo.Team;
	if (PlayersTeam < 4)
	{
		list = WFPCIList(GRI.TeamClassList[PlayersTeam]);
		if (list != None)
			return list.HandleDamageFlash(self, Damage, DamageType);
	}

	return false;
}

// -- begin ca code --
// exec function Say( string Msg )
// Override to parse Msg for variables and replace with info
//
// escape codes:
// =============
// %N - player name
// %L - player location
// %S - player status (health/armor)
// %C - player class
// %H - player health
// %A - player armor
// %B - buddies, lists friendly players within radius
// %W - player weapon
// %T - test code
// %% - print the '%' character
//
// Steps through Msg one char at a time, looking for the escape char (#)
// in the message (Msg), and if it finds it then it grabs the next char
// and puts some useful information in the new message (nMsg).
//
// The buddy code uses RadiusActors to find pawns, and then checks to make
// sure they are on the same team, if so adds them to the buddy list (bStr),
// then when its done goes back and rewrites bStr to be grammatically correct,
// i.e. it adds an "and" etc etc.  I know, its a waste of time, but I got
// a kick out of the fact that it worked the first time. :)
//
// To add more codes just add more cases in the switch statement, and append
// the information onto nMsg.
//
// TODO:
// - maybe add multiple levels of escape codes, like %b:5 would return 5 buddies?
function string ParseChatString(string Msg)
{
	local int i, amt, numBuddy, lBuddyLen;
	local float BuddyRadius;
	local string nMsg, tStr, bStr, lbStr;
	local Inventory Inv;
	local Pawn Buddy;

	BuddyRadius = 1500.0;

	// step through the string and look for escape char
	for (i = 0;i <= Len(Msg);i++)
	{
		// use mid to get the char at i in Msg since Msg[i] doesn't work
		if (Mid(Msg, i, 1) == "%")
		{
			// found escape char, now get the next char and parse
			i += 1;
			tStr = Mid(Msg,i,1);
			switch (tStr)
			{
				// player weapon
				case "W":
					nMsg = nMsg $ Weapon.ItemName;
					break;
				// player name
				case "N":
					nMsg = nMsg $ PlayerReplicationInfo.PlayerName;
					break;
				// player location
				case "L":
					if (PlayerReplicationInfo.PlayerLocation != NONE)
						nMsg = nMsg $ PlayerReplicationInfo.PlayerLocation.LocationName;
					else if (PlayerReplicationInfo.PlayerZone != NONE)
						nMsg = nMsg $ PlayerReplicationInfo.PlayerZone.ZoneName;
					else nMsg = nMsg $ "somewhere";
					break;
				// player armor
				case "A":
					amt = 0;
					for (Inv = Inventory; Inv != NONE; Inv = Inv.Inventory)
						if (Inv.bIsAnArmor)
							amt += Inv.Charge;
					nMsg = nMsg $ amt;
					break;
				// player health
				case "H":
					nMsg = nMsg $ Health;
					break;
				// player status (health + armor)
				case "S":
					amt = 0;
					for (Inv = Inventory; Inv != NONE; Inv = Inv.Inventory)
						if (Inv.bIsAnArmor)
							amt += Inv.Charge;
					nMsg = nMsg $ "Health: " $ Health $ " Armor: " $ amt;
					break;
				// player class
				case "C":
					if (PCInfo != None)
						nMsg = nMsg $ PCInfo.default.ClassName;
					else nMsg = nMsg $ "None";
					break;
				// player buddies
				case "B":
					numBuddy = 0;
					foreach RadiusActors(class'Pawn', Buddy, BuddyRadius)
					{
						// Ob1: added bIsPlayer check as sentries were causing problems with the buddy string
						if (Buddy != Self && Buddy.bIsPlayer && Buddy.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team)
						{
							lbStr = Buddy.PlayerReplicationInfo.PlayerName;
							lBuddyLen = Len(lbStr);
							if (numBuddy < 1)
								bStr = lbStr;
							else bStr = bStr $ ", " $ lbStr;
							numBuddy++;
						}
					}

					// do the "and" bit
					if (numBuddy >= 3)
						bStr = Left(bStr, Len(bStr) - lBuddyLen) $ " and " $ lbStr;
					else if (numBuddy == 2)
						bStr = Left(bStr, Len(bStr) - lBuddyLen - 2) $ " and " $ lbStr;
					else if (numBuddy == 0)
						bStr = "nobody";

					nMsg = nMsg $ bStr;
					break;
				// test
				case "T":
					nMsg = nMsg $ "<test>";
					break;
				// print the '%' character
				case "%":
					nMsg = nMsg $ "%";
					break;
				default:
					break;
			}
		}
		else nMsg = nMsg $ Mid(Msg, i, 1);
	}
	return nMsg;
}

exec function Say( string Msg )
{
	local pawn P;

	if (Msg == "")
		return;

	// forward message to RefInfo for processing
	if (bReferee)
	{
		RefInfo.RefCommand(self, "say", Msg);
		return;
	}

	// can't chat if muted
	if (bMute) return;

	// Ob1: intercept '#' admin chat operator
	if ( bAdmin && (left(Msg,1) == "#") )
	{
		Msg = right(Msg,len(Msg)-1);
		for( P=Level.PawnList; P!=None; P=P.nextPawn )
			if( P.IsA('PlayerPawn') )
			{
				PlayerPawn(P).ClearProgressMessages();
				PlayerPawn(P).SetProgressTime(6);
				PlayerPawn(P).SetProgressMessage(Msg,0);
			}
		return;
	}

	// parse the chat string
	Msg = ParseChatString(Msg);

	// and send up our new and improved message
	Super.Say(Msg);
}

exec function TeamSay(string Msg)
{
	if (Msg == "")
		return;

	// forward message to RefInfo for processing
	if (bReferee)
	{
		RefInfo.RefCommand(self, "say", "@ref "$Msg);
		return;
	}

	// can't chat if muted
	if (bMute) return;

	// parse the chat string
	Msg = ParseChatString(Msg);

	// and send up our new and improved message
	Super.TeamSay(Msg);
}
// -- end ca code --

// close the login menu if open
function CloseGameMenu()
{
	local UWindowRootWindow WinRoot;
	local UWindowWindow Win;
	local class<UWindowWindow> WinClass;

	WinClass = class<UWindowWindow>(DynamicLoadObject(GameMenuClass, class'Class'));
	if (WinClass != None)
	{
		WinRoot = GetRootWindow();
		if (WinRoot != None)
		{
			Win = WinRoot.FindChildWindow(WinClass, True);
			if (Win != None)
				Win.Close();
		}
	}

}

event PlayerTimeOut()
{
    if (bReferee && (RefInfo != None))
        RefInfo.RefLogout(self, true);
    super.PlayerTimeOut();
}

// get status inventory to adjust view rotation
function ViewShake(float DeltaTime)
{
	local inventory Item;
	super.ViewShake(deltatime);

	if (PlayerReplicationInfo==None || PlayerReplicationInfo.bIsSpectator || PlayerReplicationInfo.bWaitingPlayer)
		return;

	for (Item=Inventory; Item!=None; Item=Item.Inventory)
		if (Item!=None && Item.IsA('WFPlayerStatus'))
			WFPlayerStatus(Item).AdjustViewRotation(deltatime);
}


//=============================================================================
// WF Player States
//=============================================================================

exec function Suicide()
{
	bSuicided = true;
	super.Suicide();
}

state Dying
{
	function BeginState()
	{
		super.BeginState();
		if (bSuicided)
		{
			bSuicided = false;
			SetTimer(5.0, false);
			ClientMessage("5 second respawn penalty for suicide command.");
		}
	}
}


// referee state
state RefereeMode extends PlayerSpectating
{
	exec function Suicide() { }

	function BeginState()
	{
		bJoinedGame = false;
		bFlagTouchDisabled = true;
		PlayerReplicationInfo.bIsSpectator = true;
		PlayerReplicationInfo.bWaitingPlayer = true;
		//bShowScores = true;
		Mesh = None;
		RefViewingTeam = 255;
		bHidden = true;
		SetCollision(false,false,false);
		EyeHeight = Default.BaseEyeHeight;
		SetPhysics(PHYS_None);
	}

	exec function Fire( optional float F )
	{
		// RefViewingTeam is set when a referee uses "ref viewteam [team]"
		// and is reset to 255 when altfire is pressed
		if (Role == ROLE_Authority)
			RefInfo.ViewTeam(self, RefViewingTeam);
	}

	exec function AltFire( optional float F )
	{
		bBehindView = false;
		Viewtarget = None;
		RefViewingTeam = 255;
		ClientMessage(ViewingFrom$OwnCamera, 'Event', true);
	}

	function ChangeTeam( int N )
	{
		ClientMessage("You must log out of referee mode first");
	}

	function EndState()
	{
		bFlagTouchDisabled = false;
		PlayerReplicationInfo.bIsSpectator = false;
		PlayerReplicationInfo.bWaitingPlayer = false;
		SetMesh();
		bHidden = true;
		SetCollision(true,true,true);
	}
}

// login spectator state
state PCSpectating
{
	exec function Suicide() { }

	function BeginState()
	{
		Mesh = None;
		bHidden = true;
		bFlagTouchDisabled = true;
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

	function EndState()
	{
		bJoinedGame = true;
		bFlagTouchDisabled = false;
		CloseGameMenu();
		super.EndState();
	}

	exec function Fire( optional float F )
	{
		SetTimer(0.0, false);
		Timer();
	}

	exec function AltFire( optional float F )
	{
		SetTimer(0.0, false);
		Timer();
	}

	function Timer()
	{
		local UWindowWindow RootWin;
		RootWin = GetRootWindow();
		if (RootWin != none)
		{
			bBehindview = false;
			if (!bJoinedGame)
				GameMenu();
			else ClientDisplayUWindowClass(ClassGameMenuWDI);
		}
		else
		{
			SetTimer(1.0, false);
			//Log("[--DEBUG--]: myHUD == none, cannot display menu...");
		}
	}
}

state GameEnded
{
	function BeginState()
	{
		super.BeginState();
		CloseGameMenu();
	}

	exec function GameMenu()
	{
	}
}

state Frozen
{
	// can prevent animations and effects from playing while player is frozen
	// by setting bNoFrozenAnim to true (used by the WFStatusFrozen player status)
	function PlayHit(float Damage, vector HitLocation, name damageType, vector Momentum)
	{
		if (bNoFrozenAnim)
			return;

		Global.PlayHit(Damage, HitLocation, damageType, Momentum);
	}

	function PlayInAir()
	{
		if (bNoFrozenAnim)
			return;

		Global.PlayInAir();
	}

	function PlayLanded(float impactVel)
	{
		if (bNoFrozenAnim)
			return;

		Global.PlayLanded(impactVel);
	}

	function PlayChatting()
	{
		if (bNoFrozenAnim)
			return;

		Global.PlayChatting();
	}
}

// crouching code (thanks go to Mongo for this)
state PlayerWalking
{
ignores SeePlayer, HearNoise;

	// called to avoid any encroachment problems when trying to stand up
	function bool CanStandup()
	{
		local vector HitLocation, HitNormal, End, Extent;
		local vector OtherLoc, Dir;
		local actor HitActor, Other;
		local float Dist2D, DistHeight;

		// level geometry check (above player)
		End    = Location + vect(0,0,1) * MeshInfo.default.CollisionHeight;
		Extent = (vect(1,1,0) * CollisionRadius);
		HitActor = Trace( HitLocation, HitNormal, End, Location, False, Extent);
		if (LevelInfo(HitActor) != None)
			return false;

		// check below player if player jumping
		if (Base == None)
		{
			End = Location - vect(0,0,1) * MeshInfo.default.CollisionHeight;
			HitActor = Trace( HitLocation, HitNormal, End, Location, False, Extent);
			if (LevelInfo(HitActor) != None)
				return false;
		}

		// actor check
		foreach RadiusActors(class'Actor', Other, 150)
		{
			if ((Other != None) && (Other != self) && (Other.Base != self) && (Base != Other)
				&& (Other.bBlockPlayers || Other.bBlockActors))
			{
				// could do a double cylinder check here, but its not worth it since
				// the only actors that'll cause encroachment problems will have their
				// nearest touching point inside the collision cylinder only when the
				// player stands, and wont have an intersecting collision cylinder
				// already
				Dir = normal(Location - Other.Location);
				OtherLoc = Other.Location;
				OtherLoc += (Dir*Other.CollisionRadius)*vect(1,1,0); // move XY by collision radius
				OtherLoc += (Dir*Other.CollisionHeight)*vect(0,0,1); // move Z by collision height

				Dist2D = VSize((OtherLoc - Location)*vect(1,1,0));
				DistHeight = VSize((OtherLoc - Location)*vect(0,0,1));
				if ((Dist2D <= MeshInfo.default.CollisionRadius) && (DistHeight <= MeshInfo.default.CollisionHeight + (2*DuckHeight))
					&& FastTrace(OtherLoc))
					return false;
			}
		}

		return true;
	}

	function UnDuck (optional bool bEndState)
	{
		local pawn p;
		local float Dist2D, DistHeight;
		local actor Other;
		local vector OtherLoc, Dir;
		local bool bCanStand;

		SetCollisionSize(MeshInfo.Default.CollisionRadius, MeshInfo.Default.CollisionHeight);
		PrePivot = Default.PrePivot;
		foreach BasedActors(class'Pawn',p) {
			p.MoveSmooth(DuckHeight*vect(0,0,1));
		}
		if (!bEndState)
			MoveSmooth(DuckHeight*vect(0,0,1)); // caused "Water bouncing" bug
		//GroundSpeed = Default.GroundSpeed;
		bIsCrouching = false;
		EyeHeight -= DuckHeight;
		BaseEyeHeight -= DuckHeight;
		if (Physics == PHYS_Falling) BaseEyeHeight = Default.BaseEyeHeight * 0.7;
		//Default.BaseEyeHeight -= DuckHeight;
		if (!bEndState)
			TweenToRunning(0.1);

		// notify any new touching actors
		//Log("-- Making actor Touch() check for: "$PlayerReplicationInfo.PlayerName$" (Role: "$Role$")");
		foreach RadiusActors(class'Actor', Other, 100, Location + vect(0,0,1) * CollisionHeight)
		{
			if ((Other != None) && (Other != self) && Other.bCollideActors)
			{
				// find nearest point within collision cylinder
				//Log("---- actor found: "$Other);
				Dir = normal(Location - Other.Location);
				OtherLoc = Other.Location;
				OtherLoc += (Dir*Other.CollisionRadius)*vect(1,1,0); // move XY by collision radius
				OtherLoc += (Dir*Other.CollisionHeight)*vect(0,0,1); // move Z by collision height
				//Log("---- OtherLoc: "$OtherLoc);
				//Log("---- Location: "$Location);
				Dist2D = VSize((OtherLoc - Location)*vect(1,1,0));
				DistHeight = VSize((OtherLoc - Location)*vect(0,0,1));
				if (/*(OtherLoc.Z > (Location.Z + OldHeight)) && */(Dist2D <= CollisionRadius)
					&& (DistHeight <= CollisionHeight))
					{
						//Log("---- Calling Touch() for : "$Other);
						Other.Touch(self);
					}
			}
		}
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)
	{
		local vector OldAccel;

		OldAccel = Acceleration;
		Acceleration = NewAccel;
		bIsTurning = ( Abs(DeltaRot.Yaw/DeltaTime) > 5000 );
		if ( (DodgeMove == DODGE_Active) && (Physics == PHYS_Falling) )
			DodgeDir = DODGE_Active;
		else if ( (DodgeMove != DODGE_None) && (DodgeMove < DODGE_Active) )
			Dodge(DodgeMove);

		if ( bPressedJump )
			DoJump();
		if ( ( (Physics == PHYS_Walking) || (Physics == PHYS_Falling ) ) && (GetAnimGroup(AnimSequence) != 'Dodge') )
		{
			if (!bIsCrouching)
			{
				if (bDuck != 0)
				{
					////////////
					setCollisionSize(MeshInfo.Default.CollisionRadius,MeshInfo.Default.CollisionHeight - DuckHeight);
					setLocation(Location - DuckHeight*vect(0,0,1));
					PrePivot.Z = Default.PrePivot.Z + DuckHeight;
					//GroundSpeed = Default.GroundSpeed * 0.5;
					EyeHeight += DuckHeight;
					BaseEyeHeight += DuckHeight;
					//Default.BaseEyeHeight += DuckHeight;
					////////////
					bIsCrouching = true;
					PlayDuck();
				}
			}
			else if (bDuck == 0 && CanStandup())
			{
				////////////
				OldAccel = vect(0,0,0);
				UnDuck();
				////////////
			}

			if ( !bIsCrouching )
			{
				if ( (!bAnimTransition || (AnimFrame > 0)) && (GetAnimGroup(AnimSequence) != 'Landing') )
				{
					if ( Acceleration != vect(0,0,0) )
					{
						if ( (GetAnimGroup(AnimSequence) == 'Waiting') || (GetAnimGroup(AnimSequence) == 'Gesture') || (GetAnimGroup(AnimSequence) == 'TakeHit') )
						{
							bAnimTransition = true;
							TweenToRunning(0.1);
						}
					}
			 		else if ( (Velocity.X * Velocity.X + Velocity.Y * Velocity.Y < 1000)
						&& (GetAnimGroup(AnimSequence) != 'Gesture') )
			 		{
			 			if ( GetAnimGroup(AnimSequence) == 'Waiting' )
			 			{
							if ( bIsTurning && (AnimFrame >= 0) )
							{
								bAnimTransition = true;
								PlayTurning();
							}
						}
			 			else if ( !bIsTurning )
						{
							bAnimTransition = true;
							TweenToWaiting(0.2);
						}
					}
				}
			}
			else
			{
				if ( (OldAccel == vect(0,0,0)) && (Acceleration != vect(0,0,0)) )
					PlayCrawling();
			 	else if ( !bIsTurning && (Acceleration == vect(0,0,0)) && (AnimFrame > 0.1) )
					PlayDuck();
			}
		}
	}

	function EndState ()
	{
		if (bDeleteMe)
			return;
		if (MeshInfo.Default.CollisionHeight != CollisionHeight)
			UnDuck(true);
		WalkBob = vect(0,0,0);
	}
}

function HandleWalking()
{
	local rotator carried;

	bIsWalking = (bIsCrouching || (bRun != 0) || (bDuck != 0)) && !Region.Zone.IsA('WarpZoneInfo');
	if ( CarriedDecoration != None )
	{
		if ( (Role == ROLE_Authority) && (standingcount == 0) )
			CarriedDecoration = None;
		if ( CarriedDecoration != None ) //verify its still in front
		{
			bIsWalking = true;
			if ( Role == ROLE_Authority )
			{
				carried = Rotator(CarriedDecoration.Location - Location);
				carried.Yaw = ((carried.Yaw & 65535) - (Rotation.Yaw & 65535)) & 65535;
				if ( (carried.Yaw > 3072) && (carried.Yaw < 62463) )
					DropDecoration();
			}
		}
	}
}

simulated function Tick(float DeltaTime)
{
	local vector HitNormal, HitLocation;
	local actor HitActor;

	super.Tick(DeltaTime);

	if (Role > ROLE_SimulatedProxy)
		return;

	if ((Base != None) && ((Level.TimeSeconds - LastLocCheck) > 0.1) && !FastTrace(Location - vect(0,0,1)*CollisionHeight))
	{
		LastLocCheck = Level.TimeSeconds;
		HitActor = Trace(HitLocation, HitNormal, Location - vect(0,0,1)*CollisionHeight);
		if (LevelInfo(HitActor) != None)
			//SetLocation(Location + vect(0,0,1)*FClamp(Location.Z - HitLocation.Z, 0.000, CollisionHeight));
			SetLocation(HitLocation + vect(0,0,1)*CollisionHeight);
	}

	if (MeshInfo != None)
	{
		if ( (CollisionHeight == (MeshInfo.default.CollisionHeight - DuckHeight)) && (PrePivot.Z != (default.PrePivot.Z + DuckHeight)) )
			PrePivot.Z = default.PrePivot.Z + DuckHeight;
		else if ((CollisionHeight == MeshInfo.default.CollisionHeight) && (PrePivot.Z != default.PrePivot.Z))
			PrePivot.Z = default.PrePivot.Z;
	}
}

event UpdateEyeHeight(float DeltaTime)
{
	local float smooth, bound;

	if (bIsCrouching && (Physics == PHYS_Walking))
		BaseEyeHeight = DuckHeight;

	// smooth up/down stairs
	If( (Physics==PHYS_Walking) && !bJustLanded )
	{
		smooth = FMin(1.0, 10.0 * DeltaTime/Level.TimeDilation);

		EyeHeight = (EyeHeight - Location.Z + OldLocation.Z) * (1 - smooth) + ( ShakeVert + BaseEyeHeight) * smooth;
		bound = -0.5 * CollisionHeight;
		if (EyeHeight < bound) {
			EyeHeight = bound;
		}
		else
		{
			bound = CollisionHeight + FClamp((OldLocation.Z - Location.Z), 0.0, MaxStepHeight);
			if ( EyeHeight > bound && !bIsCrouching) {
				EyeHeight = bound;
			}
		}
	}
	else
	{
		smooth = FClamp(10.0 * DeltaTime/Level.TimeDilation, 0.35,1.0);
		bJustLanded = false;
		EyeHeight = EyeHeight * ( 1 - smooth) + (BaseEyeHeight + ShakeVert) * smooth;
	}

	// teleporters affect your FOV, so adjust it back down
	if ( FOVAngle != DesiredFOV )
	{
		if ( FOVAngle > DesiredFOV )
			FOVAngle = FOVAngle - FMax(7, 0.9 * DeltaTime * (FOVAngle - DesiredFOV));
		else
			FOVAngle = FOVAngle - FMin(-7, 0.9 * DeltaTime * (FOVAngle - DesiredFOV));
		if ( Abs(FOVAngle - DesiredFOV) <= 10 )
			FOVAngle = DesiredFOV;
	}

	// adjust FOV for weapon zooming
	if ( bZooming )
	{
		ZoomLevel += DeltaTime * 1.0;
		if (ZoomLevel > 0.9)
			ZoomLevel = 0.9;
		DesiredFOV = FClamp(90.0 - (ZoomLevel * 88.0), 1, 170);
	}
}

/*singular event BaseChange()
{
	local float decorMass;
	//if ( Level.Netmode == NM_Client )
	//	log("Called "$self$".SetBase("$Base$")");
	if ( (base == None) && (Physics == PHYS_None) )
	{
		SetPhysics(PHYS_Falling);
		bCanFly = false;
	}
	else if (Pawn(Base) != None)
	{
		Base.TakeDamage( (1-Velocity.Z/400)* Mass/Base.Mass, Self,Location,0.5 * Velocity , 'stomped');
		bCanFly = true;
		JumpOffPawn();
	}
	else if ( (Decoration(Base) != None) && (Velocity.Z < -400) )
	{
		decorMass = FMax(Decoration(Base).Mass, 1);
		Base.TakeDamage((-2* Mass/decorMass * Velocity.Z/400), Self, Location, 0.5 * Velocity, 'stomped');
	}
}*/

simulated function bool AdjustHitLocation(out vector HitLocation, vector TraceDir)
{
	return true; // since crouching code adds real collision cylinder
}

defaultproperties
{
	MenuDisplayDelay=3.000000
	PlayerReplicationInfoClass=class'WF_PRI'
	StartGameMenuClass=class'WFStartGameHUDMenu'
	MaxActiveAmmoDrops=5
	DuckHeight=15
	//InitialState=PCSpectating
	GameMenuWDI="WFCode.WFGameMenuWDI"
	ClassGameMenuWDI="WFCode.WFGameMenuClassMenuWDI"
	GameMenuClass="WFCode.WFGameMenu"
	//GameMenuWDI="WFGameMenu.WFGameMenuWDI"
	//ClassGameMenuWDI="WFGameMenu.WFGameMenuClassMenuWDI"
	//GameMenuClass="WFGameMenu.WFGameMenu"
	bUserSendEvent=False
}