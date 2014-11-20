//=============================================================================
// WFS_PCSystemGame.
// Author: Ob1-Kenobi (ob1@planetunreal.com)
//=============================================================================
class WFS_PCSystemCTFGame extends CTFGame;

var byte TEAM_Spectator;
var WFS_GameModeInfo					GameMode;
var WFS_PCIList							TeamClassList[4];
var WFS_MapSetupInfo					MapInfo;

var() class<WFS_PCSystemPlayer>			PCPlayerClass;
var() class<WFS_PCSystemBot>			PCBotClass;

var() class<WFS_GameModeInfo>			DefaultMode;
var() class<WFS_MapSetupInfo>			DefaultMapInfo;
var() class<WFS_PCIList>				DefaultTeamClassList[4];

var() config bool 					bAllowClassChanging;

var() class<WFS_HUDInfo>				DefaultExtendedHUDClass;

var() bool							bVoiceMetaClassCheck;

var() config string					TeamNames[4];

function PreBeginPlay()
{
	// TODO: add code for 'game modes'

	// setup the class lists for each team
	InitClassLists();

	super.PreBeginPlay();
}

function PostBeginPlay()
{
	local int i;

	// set up the custom team names
	for (i=0; i<4; i++)
		TeamColor[i] = TeamNames[i];

	super.PostBeginPlay();

	// map data setup
	if (CheckForMapData())
		InitMapData();
}

// called to setup class lists for this game
function InitClassLists()
{
	local int i;

	for (i=0; i<4; i++)
	{
		if (TeamClassList[i] == None)
		{
			TeamClassList[i] = spawn(DefaultTeamClassList[i]);
			TeamClassList[i].Team = i;
		}
	}
}

function InitGameReplicationInfo()
{
	local int i;
	super.InitGameReplicationInfo();
	for (i=0; i<4; i++)
		WFS_PCSystemGRI(GameReplicationInfo).TeamClassList[i] = TeamClassList[i];
	WFS_PCSystemGRI(GameReplicationInfo).MaxTeams = MaxTeams;
	WFS_PCSystemGRI(GameReplicationInfo).bAllowClassChanging = bAllowClassChanging;
}

// returns true if map data class found for this map
// (implement in subclass to activate map data)
function bool CheckForMapData();

function InitMapData()
{
	if ((MapInfo == none) && (DefaultMapInfo != None))
	{
		MapInfo = spawn(DefaultMapInfo, self);
		MapInfo.SetupMap();
	}
}

event playerpawn Login
(
	string Portal,
	string Options,
	out string Error,
	class<playerpawn> SpawnClass
)
{
	local playerpawn NewPlayer;
	local class<WFD_DPMSMeshInfo> MeshInfoClass;
	local string InSkin, InFace;
	local int InTeam;

	NewPlayer = Super.Login(Portal, Options, Error, PCPlayerClass);
	if (NewPlayer == None)
		return None;

	MeshInfoClass = GetMeshInfoClass(SpawnClass);
	log("MeshInfo:"@MeshInfoClass);
	log("SoundInfo:"@MeshInfoClass.default.DefaultSoundClass);

	InSkin	   = ParseOption ( Options, "Skin"    );
	InFace     = ParseOption ( Options, "Face"    );
	InTeam     = NewPlayer.PlayerReplicationInfo.Team;

	// set up player using spawnclass
	ChangeMeshByClass(NewPlayer, SpawnClass, bVoiceMetaClassCheck);

	// set player skin
	MeshInfoClass.static.SetMultiSkin(NewPlayer, InSkin, InFace, InTeam);

	if (!bGameEnded)
	{
		NewPlayer.PlayerRestartState = 'PCSpectating';
		SetInitialTeam(NewPlayer);
		//ChangeTeam(NewPlayer, TEAM_Spectator);

		WFS_PCSystemPlayer(NewPlayer).bDisplayClassMessage = true;
	}
	else
		SetInitialTeam(NewPlayer);

	return NewPlayer;
}

// used to set the starting team of a player that has just logged in
function SetInitialTeam(playerpawn NewPlayer)
{
	Log("Setting player to Spectator.");
	ChangeTeam(NewPlayer, TEAM_Spectator);
}

event PostLogin( playerpawn NewPlayer )
{
	Super(DeathMatchPlus).PostLogin(NewPlayer);

	if (bGameEnded)
	{
		NewPlayer.GotoState('GameEnded');
		NewPlayer.ClientGameEnded();
	}
	//if ( Level.NetMode != NM_Standalone )
	//	NewPlayer.ClientChangeTeam(NewPlayer.PlayerReplicationInfo.Team);
	//NewPlayer.ClientChangeTeam(TEAM_Spectator);
}

function Logout(pawn Exiting)
{
	local class<WFS_PlayerClassInfo> PCInfo;
	PCInfo = GetPCIFor(Exiting);
	if (PCInfo != None)
	{
		PCInfo.static.PlayerLeaving(Exiting);
		if (Exiting.PlayerReplicationInfo.Team != TEAM_Spectator)
			TeamClassList[Exiting.PlayerReplicationInfo.Team].PlayerChangedClass(PCInfo, None);
	}

	Super(DeathMatchPlus).Logout(Exiting);
	if ( Exiting.IsA('Spectator') || Exiting.IsA('Commander') || (Exiting.PlayerReplicationInfo.Team == TEAM_Spectator))
		return;
    Teams[Exiting.PlayerReplicationInfo.Team].Size--;
	ClearOrders(Exiting);
	if ( !bGameEnded && bBalanceTeams && !bRatedGame )
		ReBalance();
}

// DesiredClass is the ClassName property of the desired PCI
function SetRestartClass(pawn Other, string DesiredClass)
{
	local class<WFS_PlayerClassInfo> NewClass;
	local string reason;

	//Log("SetRestartClass(): DesiredClass: "$DesiredClass);
	NewClass = GetPlayerClass(Other, DesiredClass);
	//Log("SetRestartClass(): NewClass: "$NewClass);

	if (ValidPlayerClass(Other, NewClass, Reason))
	{
		WFS_PCSystemPlayer(Other).PlayerRestartClass = NewClass;
		if (Other.IsInState('Dying'))
			Other.ClientMessage("Class changed to '"$NewClass.default.ClassName$"'.", 'Critical');
		else Other.ClientMessage("After dying you will restart as the '"$NewClass.default.ClassName$"' class.", 'Critical');
	}
	else if (NewClass != none)
	{
		if (Reason != "")
			Other.ClientMessage("Cannot change to the '"$NewClass.default.ClassName$"' class: "$Reason, 'Critical');
		else
			Other.ClientMessage("Cannot change to the '"$NewClass.default.ClassName$"' class.", 'Critical');
	}
}

function class<WFS_PlayerClassInfo> GetPlayerClass(pawn Other, string ClassName)
{
	return TeamClassList[Other.PlayerReplicationInfo.Team].GetClassByClassName(ClassName);
}

// Used to confirm that this is a valid class, set 'reason' to give an explanation why
// the class change was not vaild.
function bool ValidPlayerClass(pawn Other, class<WFS_PlayerClassInfo> TestClass, out string Reason)
{
	local WFS_PCIList ClassList;
	local int Index;

	if (TestClass == none)
		return false;

	ClassList = TeamClassList[Other.PlayerReplicationInfo.Team];
	if (!ClassList.CanChangeToClass(TestClass))
	{
		Index = ClassList.GetIndexOfClass(TestClass);
		if (Index != -1)
		{
			if (ClassList.MaxPlayers[Index] == -1)
				Reason = "class has been disabled";
			else Reason = "maximum players reached for that class";
		}
		else Reason = "not listed for current team";
		return false;
	}

	return true;
}

// change a players class
function ChangePlayerClass(pawn Other, class<WFS_PlayerClassInfo> NewClass, optional bool bRestartPlayer)
{
	local class<WFS_PlayerClassInfo> OldPCI;
	local class<WFD_DPMSMeshInfo> OldMeshInfo;
	local WFS_PCSystemPlayer PCSPlayer;
	local class<VoicePack> NewVoiceType;

	if (newClass == none)
		return;

	//Log("NEW PLAYERCLASS: "$newClass);
	PCSPlayer = WFS_PCSystemPlayer(Other);
	if (PCSPlayer == None)
	{
		warn("ChangePlayerClass(): PCSPlayer == None!");
		return;
	}

	// clear the player restart class
	PCSPlayer.PlayerRestartClass = None;

	// notify old PCI of class change
	if (PCSPlayer.PCInfo != none)
	{
		PCSPlayer.PCInfo.static.PlayerChangingClass(Other, newClass);
		PCSPlayer.PCInfo.static.ResetPlayer(Other);
		OldPCI = PCSPlayer.PCInfo;
	}

	// set up new PCI class
	PCSPlayer.PCInfo = newClass;

	// notify the class list
	TeamClassList[Other.PlayerReplicationInfo.Team].PlayerChangedClass(OldPCI, NewClass);

	// update the mesh
	OldMeshInfo = PCSPlayer.MeshInfo;
	if (newClass.default.MeshInfo != none)
	{
		PCSPlayer.MeshInfo = newClass.default.MeshInfo;
		Other.PlayerReplicationInfo.bIsFemale = PCSPlayer.MeshInfo.default.bIsFemale;
	}

	// update the player sounds
	// (use the default sounds for the current MeshInfo if no sound class specified)
	if (newClass.default.SoundInfo != none)
		PCSPlayer.SoundInfo = newClass.default.SoundInfo;
	else if (newClass.default.MeshInfo != none)
		PCSPlayer.SoundInfo = newClass.default.MeshInfo.default.DefaultSoundClass;

	// change to the new skin for this class
	// (uses default skin for the current mesh if no class skin name is specified)
	Other.static.SetMultiSkin(
					Other,
					newClass.default.ClassSkinName,
					newClass.default.ClassFaceName,
					Other.PlayerReplicationInfo.Team
				);

	// set the voice type
	if (newClass.default.VoiceType != "")
	{
		NewVoiceType = class<VoicePack>(DynamicLoadObject(newClass.default.VoiceType, class'Class'));
		if (NewVoiceType != None)
			PCSPlayer.PlayerReplicationInfo.VoiceType = NewVoiceType;
	}

	// set the extended HUD for this player
	if (newClass.default.ExtendedHUD != none)
		PCSPlayer.ClientSetExtendedHUD(newClass.default.ExtendedHUD);

	// force voice pack update if necessary
	if (bVoiceMetaClassCheck)
		CheckVoiceType(PCSPlayer, OldMeshInfo, NewClass.default.MeshInfo);

	// put player in the 'Waiting' state if game not yet begun
	if (Other.IsInState('PCSpectating') && !PCSPlayer.bChangedTeam)
	{
		Other.PlayerRestartState = Other.default.PlayerRestartState;
		if (bRequireReady && (CountDown > 0))
			Other.GotoState('PlayerWaiting');
		else bRestartPlayer = True;
	}

	// restart player
	if (bRestartPlayer || PCSPlayer.bChangedTeam)
	{
		Other.PlayerRestartState = Other.Default.PlayerRestartState;
		PCSPlayer.ServerRestartPlayer();
		if (PCSPlayer.bChangedTeam)
		{
			PCSPlayer.bChangedTeam = False;
			DisplayClassMessage(Other);
		}
	}
	Log("CLASS CHANGE: "$Other.PlayerReplicationInfo.PlayerName$" changed class to: "$newClass);
}

// TODO: add command lists to the class message
function DisplayClassMessage(pawn Other)
{
	local int Line, ClassCount;
	local playerpawn PlayerOther;
	local WFS_PCIList ClassList;
	local class<WFS_PlayerClassInfo> PCI;

	PlayerOther = playerpawn(Other);
	if (PlayerOther == None)
		return;

	PCI = GetPCIFor(Other);
	if (PCI == None)
		return;

	PlayerOther.ClearProgressMessages();
	PlayerOther.SetProgressTime(5);
	PlayerOther.SetProgressColor(class'ChallengeTeamHUD'.Default.TeamColor[PlayerOther.PlayerReplicationInfo.Team], Line);
	PlayerOther.SetProgressMessage("[ -"@PCI.default.ClassName@"- ]", Line++);

	ClassList = TeamClassList[PlayerOther.PlayerReplicationInfo.Team];
	ClassCount = ClassList.PlayerCounts[ClassList.GetIndexOfClass(PCI)] - 1;

	if (ClassCount == 1)
		PlayerOther.SetProgressMessage("There is 1 other"@PCI.default.ClassName@"on your team.", Line++);
	else if (ClassCount > 1)
		PlayerOther.SetProgressMessage("There are"@ClassCount@"other"@PCI.default.ClassNamePlural@"on your team.", Line++);
	else
		PlayerOther.SetProgressMessage("There are no other"@PCI.default.ClassNamePlural@"on your team.", Line++);

	PlayerOther.SetProgressMessage("Type 'classhelp' for help on this class.", Line++);
}

function SendStartMessage(PlayerPawn P)
{
	local WFS_PCSystemPlayer PCSPlayer;

	PCSPlayer = WFS_PCSystemPlayer(P);
	if (PCSPlayer != None)
		PCSPlayer.bDisplayClassMessage = false;

	DisplayClassMessage(P);
}

// checks that the voice type is valid for the new MeshInfo's voice type meta class
function CheckVoiceType( pawn Other, class<WFD_DPMSMeshInfo> OldMeshInfo, class<WFD_DPMSMeshInfo> NewMeshInfo)
{
	local class<VoicePack> OldVoiceMetaClass, NewVoiceMetaClass, NewVoiceType;
	local string OldMetaClassName, NewMetaClassName;

	if (OldMeshInfo != None)
		OldMetaClassName = OldMeshInfo.default.VoicePackMetaClass;
	NewMetaClassName = NewMeshInfo.default.VoicePackMetaClass;

	if ((caps(OldMetaClassName) == caps(NewMetaClassName)) || (NewMetaClassName == ""))
		return; // voice type is valid

	// test to see if the current voice type is valid
	NewVoiceMetaClass = class<VoicePack>(DynamicLoadObject(NewMetaClassName, class'Class'));
	if (ClassIsChildOf(Other.PlayerReplicationInfo.VoiceType, NewVoiceMetaClass)
		|| (Other.PlayerReplicationInfo.VoiceType == NewVoiceMetaClass))
		return; // voice type is valid

	// voice type is not valid, change to the default voice for the new mesh info class
	NewVoiceType = class<VoicePack>(DynamicLoadObject(NewMeshInfo.default.VoiceType, class'Class'));
	if (NewVoiceType != None)
		Other.PlayerReplicationInfo.VoiceType = NewVoiceType;
}

function bool PickupQuery( Pawn Other, Inventory item )
{
	local class<WFS_PlayerClassInfo> PCInfo;

	if (Item == None)
		return false;

	PCInfo = GetPCIFor(Other);
	if (PCInfo != None)
	{
		// handle a health pickup
		if (item.IsA('TournamentHealth') || item.IsA('Health'))
		{
			PCInfo.static.HandleHealthPickup(Other, item);
			return false;
		}

		// return false if not valid item for Other
		if (!PCInfo.static.ValidPickup(Other, item))
			return false;

		// give the PCInfo a chance to handle the pickup query
		if (PCInfo.static.HandlePickupQuery(Other, item))
			return false; // pickup query handled by the PCI
	}

	return super.PickupQuery(Other, item);
}

function AddDefaultInventory(pawn PlayerPawn)
{
	local class<WFS_PlayerClassInfo> PCInfo;

	PCInfo = GetPCIFor(PlayerPawn);
	if (PlayerPawn.IsA('WFS_PCSystemPlayer') && (PCInfo == None))
		return; // player has just logged in or has changed team, so don't add inventory

	super.AddDefaultInventory(PlayerPawn);

	if (PCInfo != none)
	{
		PCInfo.static.AddDefaultInventory(self, PlayerPawn);
		PlayerPawn.SwitchToBestWeapon();
	}
}

// TODO: (needs testing): add support for auto-changing a WFS_PCSystemBot's player class
function bool RestartPlayer( pawn aPlayer )
{
	local bool bResult;
	local class<WFS_PlayerClassInfo> PCInfo;
	local WFS_PCSystemPlayer PCSPlayer;
	local WFS_PCSystemBot PCSBot;

	PCInfo = GetPCIFor(aPlayer);
	PCSPlayer = WFS_PCSystemPlayer(aPlayer);
	if (PCSPlayer == None)
		PCSBot = WFS_PCSystemBot(aPlayer);

	// clear the player restart class if PlayerRestartState is 'PCSpectating'
	if ((PCSPlayer != None) && (PCSPlayer.PlayerRestartState == 'PCSpectating'))
		PCSPlayer.PlayerRestartClass = None;

	if ((PCSPlayer != None) && (PCSPlayer.PCInfo != None)
		&& (PCSPlayer.PlayerRestartClass != None) && (PCSPlayer.PCInfo != PCSPlayer.PlayerRestartClass))
	{
		// change to the new player class
		ChangePlayerClass(PCSPlayer, PCSPlayer.PlayerRestartClass);
		PCInfo = GetPCIFor(PCSPlayer); // update the PCInfo var

		// display the class start up message
		if (!aPlayer.IsInState('PlayerWaiting') && !aPlayer.IsInState('PCSpectating'))
			DisplayClassMessage(aPlayer);
	}

	// change a bot player class if 'BotRestartClass' set
	if ((PCSBot != None) && (PCSBot.PCInfo != none)
		&& (PCSBot.BotRestartClass != None) && (PCSBot.PCInfo != PCSBot.BotRestartClass))
	{
		// change to the new player class
		BotChangePlayerClass(PCSBot, PCSBot.BotRestartClass);
		PCInfo = GetPCIFor(PCSBot); // update the PCInfo var
	}

	bResult = super.RestartPlayer(aPlayer);

	if (PCInfo != none)
		PCInfo.static.InitialisePlayer(aPlayer);

	if ((PCSPlayer != None) && PCSPlayer.bDisplayClassMessage
		&& (PCSPlayer.PlayerRestartState != 'PCSpectating'))
	{
		PCSPlayer.bDisplayClassMessage = false;
		DisplayClassMessage(PCSPlayer);
	}

	return bResult;
}

function PlayTeleportEffect( actor Incoming, bool bOut, bool bSound)
{
	local WFS_PCSystemPlayer PCSPlayer;

	PCSPlayer = WFS_PCSystemPlayer(Incoming);
	if ((PCSPlayer != None) && ((PCSPlayer.PlayerRestartState == 'PCSpectating')
		|| (PCSPlayer.PlayerRestartState == 'PlayerWaiting')) )
		return;

	super.PlayTeleportEffect(Incoming, bOut, bSound);
}

//=============================================================================
// DPMS code.

// find a mesh class for a given class
function class<WFD_DPMSMeshInfo> GetMeshInfoClass( class<pawn> PlayerClass )
{
	switch (PlayerClass.Name)
	{
		// -- Unreal Tournament MeshInfo classes --
		case 'TMale1':
			return class'WFD_TMale1MeshInfo';
		case 'TMale2':
			return class'WFD_TMale2MeshInfo';
		case 'TFemale1':
			return class'WFD_TFemale1MeshInfo';
		case 'TFemale2':
			return class'WFD_TFemale2MeshInfo';

		case 'TBoss':
			return class'WFD_TBossMeshInfo';

		//case 'CustomPlayer': // (not yet implemented)
		//	return class'WFD_CustomPlayerMeshInfo';

		// -- Unreal MeshInfo classes --
		case 'MaleOne':
			return class'WFD_MaleOneMeshInfo';
		case 'MaleTwo':
			return class'WFD_MaleTwoMeshInfo';
		case 'MaleThree':
			return class'WFD_MaleThreeMeshInfo';

		case 'FemaleOne':
			return class'WFD_FemaleOneMeshInfo';
		case 'FemaleTwo':
			return class'WFD_FemaleTwoMeshInfo';

		case 'SkaarjPlayer':
			return class'WFD_SkaarjPlayerMeshInfo';

		case 'NaliPlayer':
			return class'WFD_NaliPlayerMeshInfo';

		// -- Bot MeshInfo classes --
		case 'TMale1Bot':
			return class'WFD_TMale1BotMeshInfo';
		case 'TMale2Bot':
			return class'WFD_TMale2BotMeshInfo';

		case 'TFemale1Bot':
			return class'WFD_TFemale1BotMeshInfo';
		case 'TFemale2Bot':
			return class'WFD_TFemale2BotMeshInfo';

		case 'TBossBot':
			return class'WFD_TBossBotMeshInfo';

		//case 'CustomBot': // (not yet implemented)
		//	return class'WFD_CustomBotMeshInfo';


		default:
			Log("GetMeshInfo(): WARNING, unable to find MeshInfo class for: "$PlayerClass);
			if (ClassIsChildOf(PlayerClass, class'Bot'))
				return class'WFD_TMale2BotMeshInfo';
			return class'WFD_TMale2MeshInfo';
	}
}

// change player mesh info class based on a playerpawn class
function ChangeMeshByClass( playerpawn Other, class<playerpawn> NewClass, optional bool bUpdateVoicePack )
{
	local class<WFD_DPMSMeshInfo> NewMeshInfo, OldMeshInfo;
	local string PackageName, ItemName;
	local class<ChallengeVoicePack> VoiceTypeClass;

	// get mesh info for player class
	NewMeshInfo = GetMeshInfoClass(NewClass);

	if (NewMeshInfo == none)
	{
		Log("ChangePlayerClass(): Can't find MeshInfo class for: "$NewClass);
		return;
	}


	if (WFD_DPMSPlayer(Other).MeshInfo != none)
		OldMeshInfo = WFD_DPMSPlayer(Other).MeshInfo;
	WFD_DPMSPlayer(Other).MeshInfo = class<WFD_PlayerPawnMeshInfo>(NewMeshInfo);
	WFD_DPMSPlayer(Other).SoundInfo = NewMeshInfo.default.DefaultSoundClass;
	Other.SetCollisionSize(NewMeshInfo.default.CollisionRadius, NewMeshInfo.default.CollisionHeight);
	Other.PlayerReplicationInfo.bIsFemale = NewMeshInfo.default.bIsFemale;

	NewMeshInfo.static.SetMultiSkin(Other, NewMeshInfo.default.DefaultSkinName, NewMeshInfo.default.DefaultFaceName, Other.PlayerReplicationInfo.Team);

	// update voice pack
	if (bUpdateVoicePack)
		CheckVoiceType(Other, OldMeshInfo, NewMeshInfo);
}

// change mesh and sound info
// "NewMeshInfo.default.DefaultSoundClass" will be used if NewSoundInfo not set
function ChangeDPMSInfo( pawn Other, class<WFD_DPMSMeshInfo> NewMeshInfo, optional class<WFD_DPMSSoundInfo> NewSoundInfo )
{
	if (NewMeshInfo == none)
		return;

	if (Other.IsA('WFD_DPMSPlayer'))
	{
		WFD_DPMSPlayer(Other).MeshInfo = class<WFD_PlayerPawnMeshInfo>(NewMeshInfo);

		if (NewSoundInfo != none)
			WFD_DPMSPlayer(Other).SoundInfo = NewSoundInfo;
		else WFD_DPMSPlayer(Other).SoundInfo = NewMeshInfo.default.DefaultSoundClass;
	}
	else if (Other.IsA('WFD_DPMSBot'))
	{
		WFD_DPMSBot(Other).MeshInfo = class<WFD_BotMeshInfo>(NewMeshInfo);

		if (NewSoundInfo != none)
			WFD_DPMSBot(Other).SoundInfo = NewSoundInfo;
		else WFD_DPMSBot(Other).SoundInfo = NewMeshInfo.default.DefaultSoundClass;

		WFD_DPMSBot(Other).VoiceType = NewMeshInfo.default.VoiceType;
	}

	Other.SetCollisionSize(NewMeshInfo.default.CollisionRadius, NewMeshInfo.default.CollisionHeight);
	Other.PlayerReplicationInfo.bIsFemale = NewMeshInfo.default.bIsFemale;
	NewMeshInfo.static.CheckMesh(Other);
}

//=============================================================================
// Overridden functions

// AllowTranslocation - return true if Other can teleport to Dest
function bool AllowTranslocation(Pawn Other, vector Dest )
{
	local WFS_PCSystemAutoCannon cannon;
	local Translocator T;
	local bool bAllowed;
	local float Range;

	bAllowed = super.AllowTranslocation(Other, Dest);

	Range = Other.CollisionRadius;
	if (Other.CollisionHeight > Range)
		Range = Other.CollisionHeight;

	// don't allow players to telefrag cannons
	foreach RadiusActors(class'WFS_PCSystemAutoCannon', Cannon, Range, Dest )
	{
		if (Cannon != none)
		{
			T = Translocator(Other.Weapon);
			if (T != None)
			{
				// log the failed translocation
				if (Level.Game.LocalLog != None)
					Level.Game.LocalLog.LogSpecialEvent("translocate_fail", Other.PlayerReplicationInfo.PlayerID);
				if (Level.Game.WorldLog != None)
					Level.Game.WorldLog.LogSpecialEvent("translocate_fail", Other.PlayerReplicationInfo.PlayerID);

				// remove destination pod
				Other.PlaySound(class'Translocator'.default.AltFireSound, SLOT_Misc, 4 * Other.SoundDampening);
				if (T.TTarget != None )
				{
					T.bTTargetOut = false;
					T.TTarget.Destroy();
					T.TTarget = None;
				}
				T.bPointing=True;
			}
			bAllowed = false;
		}
	}

	return bAllowed;
}

function bool IsOnTeam(Pawn Other, int TeamNum)
{
	if ( Other.IsA('StationaryPawn') && StationaryPawn(Other).SameTeamAs(TeamNum) )
		return true;
	else if ((Other.PlayerReplicationInfo != None) && (Other.PlayerReplicationInfo.Team == TeamNum) )
		return true;

	return false;
}

function StartMatch()
{
	local Pawn P;
	local TimedTrigger T;

	if (LocalLog != None)
		LocalLog.LogGameStart();
	if (WorldLog != None)
		WorldLog.LogGameStart();

	ForEach AllActors(class'TimedTrigger', T)
		T.SetTimer(T.DelaySeconds, T.bRepeating);
	if ( Level.NetMode != NM_Standalone )
		RemainingBots = 0;
	GameReplicationInfo.RemainingMinute = RemainingTime;
	bStartMatch = true;

	// start players first (in their current startspots)
	for ( P = Level.PawnList; P!=None; P=P.nextPawn )
		if ( P.bIsPlayer && P.IsA('PlayerPawn'))
		{
			if ( bGameEnded ) return; // telefrag ended the game with ridiculous frag limit
			else if ( !P.IsA('Spectator') && !P.IsInState('PCSpectating') ) // added 2nd check
			{
				P.PlayerRestartState = P.Default.PlayerRestartState;
				P.GotoState(P.Default.PlayerRestartState);
				if ( !P.IsA('Commander') )
					RestartPlayer(P);
			}
			if (!P.IsInState('PCSpectating'))
				SendStartMessage(PlayerPawn(P));
		}


	for ( P = Level.PawnList; P!=None; P=P.nextPawn )
		if ( P.bIsPlayer && !P.IsA('PlayerPawn') )
		{
			P.RestartPlayer();
			if ( P.IsA('Bot') )
				Bot(P).StartMatch();
		}
	bStartMatch = false;
}

function Timer()
{
	local Pawn P;
	local bool bReady;
	local int M;

	Super(TournamentGameInfo).Timer();

	if ( bNetReady )
	{
		if ( NumPlayers > 0 )
			ElapsedTime++;
		else
			ElapsedTime = 0;
		if ( ElapsedTime > NetWait )
		{
			if ( (NumPlayers + NumBots < 4) && NeedPlayers() )
				AddBot();
			else if ( (NumPlayers + NumBots > 1) || ((NumPlayers > 0) && (ElapsedTime > 2 * NetWait)) )
				bNetReady = false;
		}

		if ( bNetReady )
		{
			for (P=Level.PawnList; P!=None; P=P.NextPawn )
				if ( P.IsA('PlayerPawn') )
					PlayerPawn(P).SetProgressTime(2);
			return;
		}
		else
		{
			while ( NeedPlayers() )
				AddBot();
			bRequireReady = false;
			StartMatch();
		}
	}

	if ( bRequireReady && (CountDown > 0) )
	{
		while ( (RemainingBots > 0) && AddBot() )
			RemainingBots--;
		for (P=Level.PawnList; P!=None; P=P.NextPawn )
			if ( P.IsA('PlayerPawn') )
				PlayerPawn(P).SetProgressTime(2);
		if ( ((NumPlayers == MaxPlayers) || (Level.NetMode == NM_Standalone))
				&& (RemainingBots <= 0) )
		{
			bReady = true;
			for (P=Level.PawnList; P!=None; P=P.NextPawn )
				if ( P.IsA('PlayerPawn') && !P.IsA('Spectator') //&& !P.IsInState('PCSpectating')
					&& !PlayerPawn(P).bReadyToPlay /*|| P.IsInState('PCSpectating')*/)
					bReady = false;

			if ( bReady )
			{
				StartCount = 30;
				CountDown--;
				if ( CountDown <= 0 )
					StartMatch();
				else
				{
					for ( P = Level.PawnList; P!=None; P=P.nextPawn )
						if ( P.IsA('PlayerPawn') )
						{
							PlayerPawn(P).ClearProgressMessages();
							if ( (CountDown < 11) && P.IsA('TournamentPlayer') )
								TournamentPlayer(P).TimeMessage(CountDown);
							else
								PlayerPawn(P).SetProgressMessage(CountDown$CountDownMessage, 0);
						}
				}
			}
			else if ( StartCount > 8 )
			{
				for ( P = Level.PawnList; P!=None; P=P.nextPawn )
					if ( P.IsA('PlayerPawn') )
					{
						PlayerPawn(P).ClearProgressMessages();
						//added this check (could use bHideCenterMessages instead)
						if (!P.IsInState('PCSpectating'))
						{
							PlayerPawn(P).SetProgressTime(2);
							PlayerPawn(P).SetProgressMessage(WaitingMessage1, 0);
							PlayerPawn(P).SetProgressMessage(WaitingMessage2, 1);
							if ( PlayerPawn(P).bReadyToPlay )
								PlayerPawn(P).SetProgressMessage(ReadyMessage, 2);
							else
								PlayerPawn(P).SetProgressMessage(NotReadyMessage, 2);
						}
					}
			}
			else
			{
				StartCount++;
				if ( Level.NetMode != NM_Standalone )
					StartCount = 30;
			}
		}
		else
		{
			for ( P = Level.PawnList; P!=None; P=P.nextPawn )
				if ( P.IsA('PlayerPawn') )
					PlayStartupMessage(PlayerPawn(P));
		}
	}
	else
	{
		if ( bAlwaysForceRespawn || (bForceRespawn && (Level.NetMode != NM_Standalone)) )
			For ( P=Level.PawnList; P!=None; P=P.NextPawn )
			{
				if ( P.IsInState('Dying') && P.IsA('PlayerPawn') && P.bHidden )
					PlayerPawn(P).ServerReStartPlayer();
			}
		if ( Level.NetMode != NM_Standalone )
		{
			if ( NeedPlayers() )
				AddBot();
		}
		else
			while ( (RemainingBots > 0) && AddBot() )
				RemainingBots--;
		if ( bGameEnded )
		{
			if ( Level.TimeSeconds > EndTime + RestartWait )
				RestartGame();
		}
		else if ( !bOverTime && (TimeLimit > 0) )
		{
			GameReplicationInfo.bStopCountDown = false;
			RemainingTime--;
			GameReplicationInfo.RemainingTime = RemainingTime;
			if ( RemainingTime % 60 == 0 )
				GameReplicationInfo.RemainingMinute = RemainingTime;
			if ( RemainingTime <= 0 )
				EndGame("timelimit");
		}
		else
		{
			ElapsedTime++;
			GameReplicationInfo.ElapsedTime = ElapsedTime;
		}
	}
}

// TODO: need to test this more
function bool ChangeTeam(Pawn Other, int NewTeam)
{
	local int i, s, DesiredTeam, OldTeam;
	local pawn APlayer, P;
	local teaminfo SmallestTeam;
	local WFS_PCSystemPlayer PCSPlayer;
	local class<WFS_PlayerClassInfo> PCI;

	//if (Other.IsA('PlayerPawn'))
	//	Log("[--Debug--]: ChangeTeam(): "$Other$" changing team to: "$NewTeam$" (Current Team = "$Other.PlayerReplicationInfo.Team$")");

	if ( bRatedGame && (Other.PlayerReplicationInfo.Team != 255) )
		return false;

	DesiredTeam = NewTeam;
	OldTeam = Other.PlayerReplicationInfo.Team;
	PCSPlayer = WFS_PCSystemPlayer(Other);

	if ((PCSPlayer != None) && !PCSPlayer.bLoginCanChangeTeam)
	{
		// hack to prevent team from being set twice at login
		PCSPlayer.bLoginCanChangeTeam = true;
		return true;
	}

	for( i=0; i<MaxTeams; i++ )
		if ( (SmallestTeam == None)
			|| (SmallestTeam.Size > Teams[i].Size) )
		{
			s = i;
			SmallestTeam = Teams[i];
		}

	if ( bPlayersBalanceTeams && (Level.NetMode != NM_Standalone) )
	{
		//Log("[--Debug--]: ChangeTeam(): bPlayersBalanceTeams == 'True'");
		//if ( NumBots == 1 )
		if ( NumBots > 0 )
		{
			//Log("[--Debug--]: ChangeTeam(): NumBots == 1");
			// join bot's team, because he will leave
			for ( P=Level.PawnList; P!=None; P=P.NextPawn )
				if ( P.IsA('Bot') )
					break;

			if ( (P != None) && (P.PlayerReplicationInfo != None)
				&& (Teams[P.PlayerReplicationInfo.Team].Size == SmallestTeam.Size) )
			{
				Other.PlayerReplicationInfo.Team = 255;
				NewTeam = P.PlayerReplicationInfo.Team;
			}
			else if ( (NewTeam >= MaxTeams)
				|| (Teams[NewTeam].Size > SmallestTeam.Size) )
			{
				Other.PlayerReplicationInfo.Team = 255;
				NewTeam = 255;
			}
		}
		else if ( (NewTeam >= MaxTeams)
			|| (Teams[NewTeam].Size > SmallestTeam.Size) )
		{
			//Log("[--Debug--]: ChangeTeam(): Setting "$Other$".PRI.Team and NewTeam to 255");
			Other.PlayerReplicationInfo.Team = 255;
			NewTeam = 255;
		}
	}

	if ( (NewTeam == 255) || (NewTeam >= MaxTeams) )
	{
		//Log("[--Debug--]: ChangeTeam(): Setting NewTeam to smallest team: Team "$s);
		NewTeam = s;
	}

	if ( Other.IsA('Spectator') )
	{
		Other.PlayerReplicationInfo.Team = 255;
		if (LocalLog != None)
			LocalLog.LogTeamChange(Other);
		if (WorldLog != None)
			WorldLog.LogTeamChange(Other);
		return true;
	}
	if ( Other.IsA('Commander') )
	{
		Other.PlayerReplicationInfo.Team = NewTeam;
		if (LocalLog != None)
			LocalLog.LogTeamChange(Other);
		if (WorldLog != None)
			WorldLog.LogTeamChange(Other);
		return true;
	}
	// change players team to TEAM_Spectator
	if (DesiredTeam == TEAM_Spectator)
	{
		//Log("[--Debug--]: ChangeTeam(): DesiredTeam == TEAM_Spectator");
		if ((OldTeam != 255) && (OldTeam < Maxteams))
		{
			//Log("[--Debug--]: ChangeTeam(): Reducing size of old team for "$Other$": Team "$OldTeam);
			Teams[OldTeam].Size--;
		}
		Other.PlayerReplicationInfo.Team = TEAM_Spectator;
		Other.PlayerReplicationInfo.TeamName = "";
		if (!VerifyTeamSize(OldTeam))
			Log("[--Debug--]: Warning: Team "$OldTeam$" is the wrong size!");
		if (LocalLog != None)
			LocalLog.LogTeamChange(Other);
		if (WorldLog != None)
			WorldLog.LogTeamChange(Other);
		return true;
	}
	/* add player to desired team if coming from spectating
	if ( Other.IsInState('PCSpectating') )
	{
		if (NewTeam != DesiredTeam)
			Log("WARNING: NewTeam("$NewTeam$") != DesiredTeam("$DesiredTeam$")");
		Other.PlayerReplicationInfo.Team = NewTeam;
		Other.PlayerReplicationInfo.TeamName = Teams[NewTeam].TeamName;
		BroadcastLocalizedMessage( DMMessageClass, 3, Other.PlayerReplicationInfo, None, NewTeam );
		if (LocalLog != None)
			LocalLog.LogTeamChange(Other);
		if (WorldLog != None)
			WorldLog.LogTeamChange(Other);
		ReBalance(); // rebalance the teams
		return true;
	}*/

	if ( (Other.PlayerReplicationInfo.Team != 255)
		&& (Other.PlayerReplicationInfo.Team == NewTeam) && bNoTeamChanges )
		return false;

	if ( Other.IsA('TournamentPlayer') )
		TournamentPlayer(Other).StartSpot = None;

	// reduce size of old team
	if ( (Other.PlayerReplicationInfo.Team != 255)
			&& (Other.PlayerReplicationInfo.Team != TEAM_Spectator))
	{
		ClearOrders(Other);
		TeamClassList[Other.PlayerReplicationInfo.Team].PlayerChangedClass(GetPCIFor(Other), None);
		//Log("[--Debug--]: ChangeTeam(): Reducing size of old team for "$Other$": Team "$Other.PlayerReplicationInfo.Team);
		Teams[Other.PlayerReplicationInfo.Team].Size--;
	}

	// add player to NewTeam
	if ( Teams[NewTeam].Size < MaxTeamSize )
	{
		//Log("[--Debug--]: ChangeTeam(): Adding "$Other$" to Team "$NewTeam);
		AddToTeam(NewTeam, Other);

		PCI = GetPCIFor(Other);
		if (PCI != None)
			PCI.static.PlayerChangedTeam(Other);

		if (PCSPlayer != None)
		{
			// put player in spectate mode so that Other can select class for this team
			if ((OldTeam != TEAM_Spectator) && (PCI != None))
			{
				PCSPlayer.PlayerRestartState = 'PCSpectating';
				PCSPlayer.bChangedTeam = True;
				PCSPlayer.PCInfo = None;
				PCSPlayer.ClientSetExtendedHUD(DefaultExtendedHUDClass);
			}
		}
		TeamClassList[Other.PlayerReplicationInfo.Team].PlayerChangedClass(None, GetPCIFor(Other));

		return true;
	}

	// add player to smallest team
	if ( (Other.PlayerReplicationInfo.Team == 255)
		|| ((SmallestTeam != None) && (SmallestTeam.Size < MaxTeamSize)) )
	{
		if ( s == 255 )
			s = 0;
		//Log("[--Debug--]: ChangeTeam(): Adding "$Other$" to smallest team: Team "$s);
		AddToTeam(s, Other);

		PCI = GetPCIFor(Other);
		if (PCI != None)
			PCI.static.PlayerChangedTeam(Other);

		if (PCSPlayer != None)
		{
			// put player in spectate mode so that Other can select class for this team
			if ((OldTeam != TEAM_Spectator) && (PCI != None))
			{
				PCSPlayer.PlayerRestartState = 'PCSpectating';
				PCSPlayer.bChangedTeam = True;
				PCSPlayer.PCInfo = None;
				PCSPlayer.ClientSetExtendedHUD(DefaultExtendedHUDClass);
			}
		}
		TeamClassList[Other.PlayerReplicationInfo.Team].PlayerChangedClass(None, GetPCIFor(Other));

		return true;
	}

	return false;
}

//=============================================================================
// Game specific functions.

// Have to override this function to prevent sentry cannon kills to be
// logged as suicides. GameInfo currently logs all deaths by pawns with
// bIsPlayer set to 'False' as suicides.
function Killed( pawn Killer, pawn Other, name damageType )
{
	local string OtherWeapon, KillerWeapon;
	local pawn SentryOwner;
	local bool bAutoTaunt;
	local int NextTaunt, i, Team;
	local byte bLogAsSuicide, bIncreaseDeaths, bDecreaseScore;

	if ( (Other != None) && ((Killer == None) || (Other == Killer)) )
	{
		Team = GetTeamForPawn(Other);
		bLogAsSuicide = 1;
		bIncreaseDeaths = 1;
		bDecreaseScore = 1;
		if ((Team != 255) && (TeamClassList[Team] != None) && TeamClassList[Team].HandleSuicideMessage(Other, DamageType, bLogAsSuicide, bIncreaseDeaths, bDecreaseScore))
		{
			// Log as Suicide
			if (bLogAsSuicide != 0)
			{
				if (damageType == '')
				{
					if ( LocalLog != None )
						LocalLog.LogSuicide(Other, 'Unknown', Killer);
					if ( WorldLog != None )
						WorldLog.LogSuicide(Other, 'Unknown', Killer);
				} else {
					if ( LocalLog != None )
						LocalLog.LogSuicide(Other, damageType, Killer);
					if ( WorldLog != None )
						WorldLog.LogSuicide(Other, damageType, Killer);
				}
			}
			if (bIncreaseDeaths != 0)
				Other.PlayerReplicationInfo.Deaths += 1;
			if (bDecreaseScore != 0)
				Other.PlayerReplicationInfo.Score -= 1;
			if (Other.PlayerReplicationInfo.HasFlag != None)
				Other.PlayerReplicationInfo.HasFlag.Drop(0.5 * Other.Velocity);
			return;
		}
	}

	// intercept sentry cannon kill
	if (Killer != none)
	{
		if (Killer.IsA('WFS_PCSystemAutoCannon'))
		{
			SentryOwner = WFS_PCSystemAutoCannon(Killer).PlayerOwner;
			if ((SentryOwner != None) && (Other != None))
			{
				if (Other != SentryOwner)
				{
					BroadcastAutoCannonMessage(SentryOwner, Other, damageType, Killer.class, 0);

					// Stat Logging (implement before release)
					KillerWeapon = "Automatic Cannon";
					OtherWeapon = "None";
					if (Other.Weapon != None)
						OtherWeapon = Other.Weapon.ItemName;

					if ( LocalLog != None )
						LocalLog.LogKill(
							SentryOwner.PlayerReplicationInfo.PlayerID,
							Other.PlayerReplicationInfo.PlayerID,
							KillerWeapon,
							OtherWeapon,
							damageType
						);
					if ( WorldLog != None )
						WorldLog.LogKill(
							SentryOwner.PlayerReplicationInfo.PlayerID,
							Other.PlayerReplicationInfo.PlayerID,
							KillerWeapon,
							OtherWeapon,
							damageType
						);
				}
				else if (Other == SentryOwner)
				{
					// other was killed by his own cannon
					BroadcastAutoCannonMessage(SentryOwner, Other, damageType, Killer.class, 0);
				}

				// check for any carried flags and drop them
				if ( Other.bIsPlayer && (Other.PlayerReplicationInfo.HasFlag != None) )
				{
					if ( Other.bIsPlayer && (SentryOwner.PlayerReplicationInfo.Team != Other.PlayerReplicationInfo.Team) )
					{
						SentryOwner.PlayerReplicationInfo.Score += 4;
						bAutoTaunt = ((TournamentPlayer(SentryOwner) != None) && TournamentPlayer(SentryOwner).bAutoTaunt);
						if ( (Bot(SentryOwner) != None) || bAutoTaunt )
						{
							NextTaunt = Rand(class<ChallengeVoicePack>(SentryOwner.PlayerReplicationInfo.VoiceType).Default.NumTaunts);
							for ( i=0; i<4; i++ )
							{
								if ( NextTaunt == LastTaunt[i] )
									NextTaunt = Rand(class<ChallengeVoicePack>(SentryOwner.PlayerReplicationInfo.VoiceType).Default.NumTaunts);
								if ( i > 0 )
									LastTaunt[i-1] = LastTaunt[i];
							}
							LastTaunt[3] = NextTaunt;
							SentryOwner.SendGlobalMessage(None, 'AUTOTAUNT', NextTaunt, 5);
						}
					}
					Other.PlayerReplicationInfo.HasFlag.Drop(0.5 * Other.Velocity);
				}

				// score the kill
				ScoreKill(SentryOwner, Other);
				return;
			}
		}

		// someone destroyed a cannon
		if (Other.IsA('WFS_PCSystemAutoCannon') && (Killer != none))
		{
			SentryOwner = WFS_PCSystemAutoCannon(Other).PlayerOwner;
			BroadcastAutoCannonMessage(Killer, SentryOwner, damageType, Other.class, 1);
			ScoreKill(Killer, Other);
			return;
		}
	}
	super.Killed(Killer, Other, damageType);
}

function BroadcastRegularDeathMessage(pawn Killer, pawn Other, name damageType)
{
	local int Team;

	if (Other != None)
	{
		Team = GetTeamForPawn(Killer);
		if ((Team != 255) && (TeamClassList[Team] != None) && TeamClassList[Team].HandleRegularDeathMessage(Killer, Other, DamageType))
			return;
	}

	super.BroadcastRegularDeathMessage(Killer, Other, DamageType);
}

/*
BroadcastAutoCannonMessage()

	Switch:
		0 = Cannon killed other
		1 = Cannon destroyed by killer
		2 = Low ammo
		3 = Low health
*/
function BroadcastAutoCannonMessage(pawn Killer, pawn Other, name damageType, class<pawn> AutoCannonClass, int switch)
{
	if (switch < 2)
		BroadcastLocalizedMessage(class'WFS_AutoCannonDeathMessage', switch, Killer.PlayerReplicationInfo, Other.PlayerReplicationInfo, AutoCannonClass);
}

function int ReduceDamage(int Damage, name DamageType, pawn injured, pawn instigatedBy)
{
	Damage = Super(DeathMatchPlus).ReduceDamage(Damage, DamageType, injured, instigatedBy);

	if ( (instigatedBy == None) || (instigatedBy.IsA('StationaryPawn') && (instigatedBy.Owner == injured)) )
		return Damage;
	else if ( (instigatedBy == injured) && Injured.IsA('WFS_PCSystemAutoCannon') )
		return 0;
	else if ( (instigatedBy != injured) && IsOnTeam(injured, GetTeamForPawn(instigatedBy)) )
	{
		if ( injured.IsA('Bot') )
			Bot(Injured).YellAt(instigatedBy);
		return (Damage * FriendlyFireScale);
	}
	else
		return Damage;
}

function int GetTeamForPawn(pawn Other)
{
	if (Other.bIsPlayer && (Other.PlayerReplicationInfo != None))
		return Other.PlayerReplicationInfo.Team;
	else if (Other.IsA('TeamCannon'))
		return TeamCannon(Other).MyTeam;

	return 255;
}

//=============================================================================
// Misc functions

function class<WFS_PlayerClassInfo> GetPCIFor(pawn Other)
{
	if (Other.IsA('WFS_PCSystemPlayer'))
		return WFS_PCSystemPlayer(Other).PCInfo;
	else if (Other.IsA('WFS_PCSystemBot'))
		return WFS_PCSystemBot(Other).PCInfo;

	return None;
}

function bool VerifyTeamSize(int TeamNum)
{
	local pawn p;
	local int count;

	if (TeamNum > 3)
		return true;

	count = 0;
	for (p=Level.PawnList; p!=none; p=p.NextPawn)
	{
		if (p.PlayerReplicationInfo.Team == TeamNum)
			count++;
	}

	if (count == Teams[TeamNum].Size)
	{
		return true;
	}
	else if (count < Teams[TeamNum].Size)
	{
		Log("[--Debug--]: VerifyTeamSize(): Team "$TeamNum$" is too big, out by "$string(Teams[TeamNum].Size - count));
		return false;
	}
	else if (count > Teams[TeamNum].Size)
	{
		Log("[--Debug--]: VerifyTeamSize(): Team "$TeamNum$" is too small, out by "$string(count - Teams[TeamNum].Size));
		return false;
	}

	return false;
}

//=============================================================================
// === BOT SETUP ===

// implement in sub-class to choose a player class for this bot
function class<WFS_PlayerClassInfo> FindPCIForBot(bot aBot);

// set up a PCI class for the new bot
function bool AddBot()
{
	local bot NewBot;
	local NavigationPoint StartSpot, OldStartSpot;
	local int DesiredTeam, i, MinSize;
	local class<WFS_PlayerClassInfo> PCI;

	NewBot = SpawnBot(StartSpot);
	if ( NewBot == None )
	{
		log("Failed to spawn bot");
		return false;
	}

	if ( bBalanceTeams && !bRatedGame )
	{
		MinSize = Teams[0].Size;
		DesiredTeam = 0;
		for ( i=1; i<MaxTeams; i++ )
			if ( Teams[i].Size < MinSize )
			{
				MinSize = Teams[i].Size;
				DesiredTeam = i;
			}
	}
	else
		DesiredTeam = NewBot.PlayerReplicationInfo.Team;
	NewBot.PlayerReplicationInfo.Team = 255;
	if ( (DesiredTeam == 255) || !ChangeTeam(NewBot, DesiredTeam) )
	{
		ChangeTeam(NewBot, NextBotTeam);
		NextBotTeam++;
		if ( NextBotTeam >= MaxTeams )
			NextBotTeam = 0;
	}

	if ( bSpawnInTeamArea )
	{
		OldStartSpot = StartSpot;
		StartSpot = FindPlayerStart(NewBot,255);
		if ( StartSpot != None )
		{
			NewBot.SetLocation(StartSpot.Location);
			NewBot.SetRotation(StartSpot.Rotation);
			NewBot.ViewRotation = StartSpot.Rotation;
			NewBot.SetRotation(NewBot.Rotation);
			StartSpot.PlayTeleportEffect( NewBot, true );
		}
		else
			StartSpot = OldStartSpot;
	}

	StartSpot.PlayTeleportEffect(NewBot, true);

	// PCSystem: Select a PCI for this bot
	PCI = FindPCIForBot(NewBot);
	if (PCI != None) BotChangePlayerClass(NewBot, PCI);

	SetBotOrders(NewBot);

	// Log it.
	if (LocalLog != None)
	{
		LocalLog.LogPlayerConnect(NewBot);
		LocalLog.FlushLog();
	}
	if (WorldLog != None)
	{
		WorldLog.LogPlayerConnect(NewBot);
		WorldLog.FlushLog();
	}

	return true;
}

// === WFD_DPMSBot Spawning and intitial setup Code ===
function Bot SpawnBot(out NavigationPoint StartSpot)
{
	local bot NewBot;
	local int BotN;
	local Pawn P;
	local class<WFD_BotMeshInfo> MeshInfo;
	local class<WFD_DPMSSoundInfo> SoundInfo;

	if ( bRatedGame )
		return SpawnRatedBot(StartSpot);

	Difficulty = BotConfig.Difficulty;

	if ( Difficulty >= 4 )
	{
		bNoviceMode = false;
		Difficulty = Difficulty - 4;
	}
	else
	{
		if ( Difficulty > 3 )
		{
			Difficulty = 3;
			bThreePlus = true;
		}
		bNoviceMode = true;
	}
	BotN = BotConfig.ChooseBotInfo();

	// Find a start spot.
	StartSpot = FindPlayerStart(None, 255);
	if( StartSpot == None )
	{
		log("Could not find starting spot for Bot");
		return None;
	}

	// DPMS: Try to spawn the PCSystem bot.
	MeshInfo = class<WFD_BotMeshInfo>(GetMeshInfoClass(BotConfig.CHGetBotClass(BotN)));
	Log("Spawning DPMS Bot class: "$PCBotClass$". WFD_BotMeshInfo: "$MeshInfo);
	NewBot = Spawn(PCBotClass,,,StartSpot.Location,StartSpot.Rotation);

	if ( NewBot == None )
		log("Couldn't spawn player at "$StartSpot);

	if ( (bHumansOnly || Level.bHumansOnly) && !NewBot.bIsHuman )
	{
		log("can't add non-human bot to this game");
		NewBot.Destroy();
		NewBot = None;
	}

	if ( NewBot == None )
	{
		// DPMS: try to spawn the bot again, this time using the first available config entry
		MeshInfo = class<WFD_BotMeshInfo>(GetMeshInfoClass(BotConfig.CHGetBotClass(0)));
		NewBot = Spawn(PCBotClass,,,StartSpot.Location,StartSpot.Rotation);
	}

	if ( NewBot != None )
	{
		// Set the player's ID.
		NewBot.PlayerReplicationInfo.PlayerID = CurrentID++;

		// DPMS: Setup the DPMS info
		ChangeDPMSInfo(NewBot, MeshInfo);

		NewBot.PlayerReplicationInfo.Team = BotConfig.GetBotTeam(BotN);
		BotConfig.CHIndividualize(NewBot, BotN, NumBots);
		NewBot.ViewRotation = StartSpot.Rotation;

		// broadcast a welcome message.
		BroadcastMessage( NewBot.PlayerReplicationInfo.PlayerName$EnteredMessage, false );

		ModifyBehaviour(NewBot);
		AddDefaultInventory( NewBot ); // TODO: may need to change/move this function call
		NumBots++;
		if ( bRequireReady && (CountDown > 0) )
			NewBot.GotoState('Dying', 'WaitingForStart');
		NewBot.AirControl = AirControl;

		if ( (Level.NetMode != NM_Standalone) && (bNetReady || bRequireReady) )
		{
			// replicate skins
			for ( P=Level.PawnList; P!=None; P=P.NextPawn )
				if ( P.bIsPlayer && (P.PlayerReplicationInfo != None) && P.PlayerReplicationInfo.bWaitingPlayer && P.IsA('PlayerPawn') )
				{
					if ( NewBot.bIsMultiSkinned )
						PlayerPawn(P).ClientReplicateSkins(NewBot.MultiSkins[0], NewBot.MultiSkins[1], NewBot.MultiSkins[2], NewBot.MultiSkins[3]);
					else
						PlayerPawn(P).ClientReplicateSkins(NewBot.Skin);
				}
		}
	}

	return NewBot;
}

function BotChangePlayerClass(pawn Other, class<WFS_PlayerClassInfo> NewClass, optional bool bRestartPlayer)
{
	local class<WFS_PlayerClassInfo> OldPCI;
	local class<WFD_DPMSMeshInfo> OldMeshInfo;
	local WFS_PCSystemBot PCSBot;
	local class<VoicePack> NewVoiceType;

	if (newClass == none)
		return;

	Log("NEW BOT PLAYERCLASS: "$newClass);
	PCSBot = WFS_PCSystemBot(Other);
	if (PCSBot == None)
	{
		warn("ChangePlayerClass(): PCSBot == None!");
		return;
	}

	// clear the bot restart class
	PCSBot.BotRestartClass = None;

	// notify old PCI of class change
	if (PCSBot.PCInfo != none)
	{
		PCSBot.PCInfo.static.PlayerChangingClass(Other, newClass);
		PCSBot.PCInfo.static.ResetPlayer(Other);
		OldPCI = PCSBot.PCInfo;
	}

	// set up new PCI class
	PCSBot.PCInfo = newClass;

	// notify the class list
	TeamClassList[Other.PlayerReplicationInfo.Team].PlayerChangedClass(OldPCI, NewClass);

	// update the mesh
	OldMeshInfo = PCSBot.MeshInfo;
	if (newClass.default.AltMeshInfo != none)
	{
		PCSBot.MeshInfo = newClass.default.AltMeshInfo;
		Other.PlayerReplicationInfo.bIsFemale = PCSBot.MeshInfo.default.bIsFemale;
	}

	// update the player sounds
	// (use the default sounds for the current MeshInfo if no sound class specified)
	if (newClass.default.SoundInfo != none)
		PCSBot.SoundInfo = newClass.default.SoundInfo;
	else if (newClass.default.MeshInfo != none)
		PCSBot.SoundInfo = newClass.default.MeshInfo.default.DefaultSoundClass;

	// change to the new skin for this class
	// (uses default skin for the current mesh if no class skin name is specified)
	Other.static.SetMultiSkin(
					Other,
					newClass.default.ClassSkinName,
					newClass.default.ClassFaceName,
					Other.PlayerReplicationInfo.Team
				);

	// set the voice type
	if (newClass.default.VoiceType != "")
	{
		NewVoiceType = class<VoicePack>(DynamicLoadObject(newClass.default.VoiceType, class'Class'));
		if (NewVoiceType != None)
			PCSBot.PlayerReplicationInfo.VoiceType = NewVoiceType;
	}

	// force voice pack update if necessary
	if (bVoiceMetaClassCheck)
		CheckVoiceType(PCSBot, OldMeshInfo, NewClass.default.MeshInfo);
}

//=============================================================================
// === BOT AI ===

/*
AssessBotAttitude returns a value that translates to an attitude
		0 = ATTITUDE_Fear;
		1 = return ATTITUDE_Hate;
		2 = return ATTITUDE_Ignore;
		3 = return ATTITUDE_Friendly;
*/
function byte AssessBotAttitude(Bot aBot, Pawn Other)
{
	if (Other.IsInState('PCSpectating'))
		return 2;	// bots ignore spectating players
	else
		return super.AssessBotAttitude(aBot, Other);
}

defaultproperties
{
	TEAM_Spectator=4
	HUDType=class'WFS_PCSystemHUD'
	DefaultTeamClassList(0)=class'WFS_TestClassList'
	DefaultTeamClassList(1)=class'WFS_TestClassList'
	DefaultTeamClassList(2)=class'WFS_TestClassList'
	DefaultTeamClassList(3)=class'WFS_TestClassList'
	GameReplicationInfoClass=class'WFS_PCSystemGRI'
	PCPlayerClass=class'WFS_PCSystemPlayer'
	PCBotClass=class'WFS_PCSystemBot'
	bAllowClassChanging=true
	MaxAllowedTeams=4
	TeamNames(0)="Red Team"
	TeamNames(1)="Blue Team"
	TeamNames(2)="Green Team"
	TeamNames(3)="Gold Team"
}