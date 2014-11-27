//=============================================================================
// WFGame.
// Author: Ob1-Kenobi (ob1@planetunreal.com)
//
// The Weapons Factory game type.
//
// Add the WF team class lists to the default props when they're implemented.
// See the WFS_PCSystemGame super-class for more info on how the PCSystem game type
// works.
//
// [-- TODO --]
// AI RELATED: (low priority)
//   o Add basic bot support for four CTF flags.
//   o Add bot support for FRS_DelayReturn.
//   o Implement PCI Bot AI hooks (if any) for the WF player classes.
//   o Add support for alternate capture points.
//   o Possibly create some kind of AI module class for the Game AI.
//=============================================================================
class WFGame extends WFS_PCSystemCTFGame;

var() config string 	ClassDefinitions[4]; // custom class definition strings: "PackageName.ClassListName"

/* would have liked to have used an enum here, but I can't figure out how to static set them
var() config enum EFlagReturnStyle
{
	FRS_DelayReturn,
	FRS_TouchReturn,
	FRS_CarryReturn
} FlagReturnStyle;*/

var() config byte FlagReturnStyle;

var const string WFGameVersion;

var const int FRS_DelayReturn; // players must wait for the flag to return (FlagReturnTime seconds)
var const int FRS_TouchReturn; // players can touch their flag to return it
var const int FRS_CarryReturn; // players must carry their own flag back to base to return it

var() config float FlagReturnTime; // time before flag auto-returns
var() config float DefendRadius; //radius in which person defends flag
var() config float FlagRunnerDefendRadius; //radius in which person defends ithe flag runner

// TODO: add these to the GRI
var() config bool bAutoTeamTimer; // players must choose a team within AutoTeamTime seconds
var() config float AutoTeamTime; // time before player gets auto-teamed if bAutoTeamTimer set

var() config string FlagTextures[4]; // custom skins for the CTF flags
var() config bool bOverrideMapFlagTextures; // don't use skins specified by map default info

var() config bool bOverrideMapData; // use current rules for all maps

var() config string TeamPasswords[4];

var() class<WFS_WindowDisplayInfo> TeamPasswordDialogClass[4];

// referee vars
var config bool bRefStartGame; // referee must start the game when in tournament mode
var WFRefereeInfo RefInfo;

var() config int MaxLoginAttempts;
var() config float SpawnProtectionTime;

// score related
var int KilledFlagCarrierBonus;

// MiscScoreArray index usage
var() byte INDEX_FlagCaps;
var() byte INDEX_FlagDefends;
var() byte INDEX_FlagCarrierKills;
var() byte INDEX_FlagCarrierDefends;
var() byte INDEX_FlagReturns;
var() byte INDEX_Frags;

function PostBeginPlay()
{
	local int i;

	super.PostBeginPlay();

	for (i=0;i<4;i++)
	{
		// remove the old UT team info
		Teams[i].Size = 0;
		Teams[i].Score = 0;
		Teams[i].TeamName = "";
		Teams[i].TeamIndex = -1;
		Teams[i].Destroy();
		Teams[i] = None;

		// create the WFTeamInfo classes
		Teams[i] = Spawn(class'WFTeamInfo');
		Teams[i].Size = 0;
		Teams[i].Score = 0;
		Teams[i].TeamName = TeamNames[i];
		Teams[i].TeamIndex = i;
		TournamentGameReplicationInfo(GameReplicationInfo).Teams[i] = Teams[i];
	}
}

function AdminLogin( PlayerPawn P, string Password )
{
	local WFPlayer WFP;
	local float logintime;

	WFP = WFPlayer(P);
	if ((WFP == None) || WFP.bAdminLoginDisabled || WFP.bAdmin)
		return;

	if (WFP.NumAdminLogins == 0)
	{
		WFP.NumAdminLogins++;
		WFP.FirstAdminLoginTime = Level.TimeSeconds;
	}
	else
		WFP.NumAdminLogins++;

	super.AdminLogin(P, Password);

	if (P.bAdmin)
	{
		WFP.NumAdminLogins = 0;
		WFP.FirstAdminLoginTime = 0.0;
	}
	else
	{
		// check to see if player is flooding to try to gain the password
		logintime = Level.TimeSeconds - WFP.FirstAdminLoginTime;
		if (WFP.NumAdminLogins > MaxLoginAttempts)
		{
			WFP.bAdminLoginDisabled = true;
			WFP.NumAdminLogins = 0;
			WFP.FirstAdminLoginTime = 0.0;
			Log("INFO: ADMINLOGIN: "$WFP.PlayerReplicationInfo.PlayerName$" (IP: "$WFP.GetPlayerNetworkAddress()$") failed to log in within "$MaxLoginAttempts$" attempts, ADMIN login disabled for this player");
		}
	}
}

function PreBeginPlay()
{
	super.PreBeginPlay();
	Log("=== Weapons Factory Version: "$WFGameVersion$" ===");
	if (RefInfo == None)
		RefInfo = spawn(class'WFRefereeInfo');
}

event InitGame( string Options, out string Error )
{
	Super.InitGame(Options, Error);
	MaxCommanders = 0;
}

function InitGameReplicationInfo()
{
	super.InitGameReplicationInfo();
	WFGameGRI(GameReplicationInfo).FlagReturnStyle = FlagReturnStyle;
}

function bool CheckForMapData()
{
	return true; // use default map setup class: WFGameMapSetupInfo
}

// set up the player class lists, and try to load any custom definitions
function InitClassLists()
{
	local class<WFS_PCIList> ClassList;
	local int i;

	for (i=0; i<4; i++)
	{
		if (ClassDefinitions[i] != "")
			ClassList = class<WFS_PCIList>(DynamicLoadObject(ClassDefinitions[i], class'Class'));
		else ClassList = None;

		if (ClassList != None)
			TeamClassList[i] = spawn(ClassList);
		else
			TeamClassList[i] = spawn(DefaultTeamClassList[i]);
	}
}

event PostLogin( playerpawn NewPlayer )
{
	local string TimeString;

	Super.PostLogin(NewPlayer);

	GetTimeStamp(TimeString);

	Log("=== PLAYER LOGED IN ===");
	Log("Login Name: "$NewPlayer.PlayerReplicationInfo.PlayerName);
	Log("Time: "$TimeString);
	Log("IP Address: "$NewPlayer.GetPlayerNetworkAddress());
	Log("=======================");

	WFPlayer(NewPlayer).bLoginComplete = true;
	WFPlayer(NewPlayer).RefInfo = RefInfo;
}

function ChangeName(Pawn Other, string S, bool bNameChange)
{
	local string oldName, TimeString;

	oldname = other.playerReplicationInfo.PlayerName;
	super.ChangeName(Other, S, bNameChange);

	if (Other.IsA('WFPlayer') && WFPlayer(Other).bLoginComplete
		&& (oldname != other.playerReplicationInfo.PlayerName))
	{
		GetTimeStamp(TimeString);
		Log("=== PLAYER CHANGED NAME ===");
		Log("Old Name: "$oldname);
		Log("New Name: "$other.PlayerReplicationInfo.PlayerName);
		Log("Time: "$TimeString);
		Log("IP Address: "$playerpawn(other).GetPlayerNetworkAddress());
		Log("=======================");
	}
}

function string GetGameTime()
{
	local string TimeStamp;

	TimeStamp = string(Level.Year);

	if (Level.Month < 10)
		TimeStamp = TimeStamp$"/0"$Level.Month;
	else
		TimeStamp = TimeStamp$"/"$Level.Month;

	if (Level.Day < 10)
		TimeStamp = TimeStamp$"/0"$Level.Day;
	else
		TimeStamp = TimeStamp$"/"$Level.Day;

	if (Level.Hour < 10)
		TimeStamp = TimeStamp$" 0"$Level.Hour;
	else
		TimeStamp = TimeStamp$" "$Level.Hour;

	if (Level.Minute < 10)
		TimeStamp = TimeStamp$":0"$Level.Minute;
	else
		TimeStamp = TimeStamp$":"$Level.Minute;

	if (Level.Second < 10)
		TimeStamp = TimeStamp$":0"$Level.Second;
	else
		TimeStamp = TimeStamp$":"$Level.Second;

	return TimeStamp;
}

function int ReduceDamage(int Damage, name DamageType, pawn injured, pawn instigatedBy)
{
	local int injuredTeam, instigatingTeam;

	// from CTFGame (added different team check)
	if ( (instigatedBy != None)
		&& injured.IsA('Bot')
		&& !IsOnTeam(instigatedBy, injured.PlayerReplicationInfo.Team)
		&& ((injured.health < 35) || (injured.PlayerReplicationInfo.HasFlag != None)) )
			Bot(injured).SendTeamMessage(None, 'OTHER', 4, 15);

	return Super.ReduceDamage(Damage, DamageType, injured, instigatedBy);
}

function int GetTeamForPawn(pawn Other)
{
	if (Other.IsA('WFSupplyDepot'))
		return WFSupplyDepot(Other).OwnerTeam;

	return super.GetTeamForPawn(Other);
}

// Called by WFGameMapSetupInfo to allow PCI lists to add ammo types
// (not called for regular dropped WFBackpacks)
function bool ModifySupplyPack(WFSupplyPack Pack)
{
	local int i;
	local bool bModified;

	bModified = false;
	for (i=0; i<4; i++)
		if (WFPCIList(TeamClassList[i]).ModifySupplyPack(Pack))
			bModified = true;

	return bModified;
}

// --- Team Password Code ---
function bool ChangeTeam(Pawn Other, int NewTeam)
{
	if (!CanChangeTeam(Other, NewTeam))
		return false;
	CheckTeamSizes();
	return super.ChangeTeam(Other, NewTeam);
}

function bool CanChangeTeam(pawn Other, int NewTeam)
{
	local WFPlayer WFP;
	local bool bCanAutoTeam;
	local int i;

	WFP = WFPlayer(Other);
	if ((WFP == None) || !WFP.bLoginComplete)
		return true;

	if (WFP.bLoginComplete && (WFP.PlayerReplicationInfo.Team == NewTeam))
	{
		WFP.ClientMessage("You are already on that team.", 'CriticalEvent', true);
		return false;
	}

	if (NewTeam == 255)
	{
		for (i=0; i<MaxTeams; i++)
			if (TeamPasswords[i] ~= "")
				return true;
		WFP.ClientMessage("Cannot use Auto-Team: all teams require a password", 'CriticalEvent', true);
		return false;
	}

	if (NewTeam >= MaxTeams)
		return false;

	if (NewTeam == TEAM_Spectator)
		return true;

	if ((Level.NetMode == NM_Standalone) || (TeamPasswords[NewTeam] ~= "") || (TeamPasswords[NewTeam] ~= WFP.TeamPassword))
		return true;

	WFP.ClientMessage("Password required to join "$TeamNames[NewTeam], 'CriticalEvent', true);
	WFP.ClientDisplayUWindow(TeamPasswordDialogClass[NewTeam]);

	return false;
}
// ---

function string GetRules()
{
	local string ResultSet;
	ResultSet = Super.GetRules();
	Resultset = ResultSet$"\\wfut_version\\"$WFGameVersion;
	return ResultSet;
}

// Drop a Backpack from the players location
function Killed( pawn Killer, pawn Other, name damageType )
{
	local WFBackPack pack;
	local float speed;
	local WF_PRI WFPRI;
	local WF_BotPRI WFBotPRI;
	local WFCustomHUD MyHUD;
  local int i, flagteam;
	local WFFlag Flag;
	local TournamentGameReplicationInfo OwnerGame;
	local bool bPointGiven;
	local pawn aPawn;
	local PlayerReplicationInfo HolderPRI;
  local vector FlagLocation;
	local bool bFlagLOS;

	// send some events
	if (Other.PlayerReplicationInfo.HasFlag != None)
	{
		flagteam = CTFFlag(Other.PlayerReplicationInfo.HasFlag).Team;
		if (Other.PlayerReplicationInfo.Team != flagteam)
			class'WFPlayerClassInfo'.static.SendEvent(Other, "flag_dropped");
		else class'WFPlayerClassInfo'.static.SendEvent(Other, "flag_dropped_own");
	}

	if (DamageType == 'RefLogin')
	{
		if (Other.PlayerReplicationInfo.HasFlag != None)
			Other.PlayerReplicationInfo.HasFlag.Drop(0.5 * Other.Velocity);
		return;
	}

	bPointGiven = false;

	if ((Other != None) && Other.bIsPlayer)
	{
		pack = Other.spawn(class'WFBackPack',,, Other.Location);
		pack.AddInventoryFrom(Other);

		speed = VSize(Other.Velocity);
		if (speed != 0)
			pack.Velocity = Normal(Other.Velocity/speed + 0.5 * VRand()) * (speed + 280);
		else
			pack.Velocity = vect(0,0,0);

		pack.DropFrom(Other.Location);
	}

	// lazy hack to get around the +4 bonus for shooting down a flag carrier
	if ( Other.bIsPlayer && (Other.PlayerReplicationInfo.HasFlag != None) )
	{
		if ( ( Killer != None ) &&
           Killer.bIsPlayer &&
           Other.bIsPlayer &&
           ( Killer.PlayerReplicationInfo.Team !=
             Other.PlayerReplicationInfo.Team ) )
		{
			killer.PlayerReplicationInfo.Score -= 4;
			killer.PlayerReplicationInfo.Score += KilledFlagCarrierBonus;

      //points for killing the flag runner

      class'WFTools'.static.AdjustMiscScore(killer.PlayerReplicationInfo,
                                            INDEX_FlagCarrierKills, 1);
      WFTeamInfo( TournamentGameReplicationInfo(GameReplicationInfo) .Teams[  killer.PlayerReplicationInfo.Team ] ).MiscScoreArray[ INDEX_FlagCarrierKills ]++;
			Killer.ReceiveLocalizedMessage( class'WFFlagRunnerKillMessage', 0, Other.PlayerReplicationInfo );
		  bPointGiven = true;
		}
	}

  // given points for flag runner defends
	if (Killer != None)
	{
		for ( i=0; i<4; i++ )
		{
			Flag = WFFlag(CTFReplicationInfo(GameReplicationInfo).FlagList[i]);
			if( Flag == None )
			{
			  continue;
			}

			//FlagLocation = Flag.Location;
			FlagLocation = Flag.Position().Location;

			bFlagLOS = ((Killer != None) && Killer.FastTrace(FlagLocation))
						|| ((Other != None) && Other.FastTrace(FlagLocation));

			if (!bFlagLOS)
				continue;

			if( !bPointGiven && ( Flag.Holder != None ) )
			{
					HolderPRI = Flag.Holder.PlayerReplicationInfo;
				if ( ( HolderPRI.Team == Killer.PlayerReplicationInfo.Team ) &&
				   ( Killer.PlayerReplicationInfo.Team != Other.PlayerReplicationInfo.Team ) &&
						 ( Flag.bHeld ) &&
							 ( Flag.Holder != Killer ) &&
				   ( VSize( FlagLocation - Other.Location ) < DefendRadius ) )
				{
          class'WFTools'.static.AdjustMiscScore(killer.PlayerReplicationInfo,
                                                INDEX_FlagCarrierDefends, 1);
          WFTeamInfo( TournamentGameReplicationInfo(GameReplicationInfo) .Teams[ killer.PlayerReplicationInfo.Team ] ).MiscScoreArray[ INDEX_FlagCarrierDefends ]++;

					bPointGiven = true;
					Killer.ReceiveLocalizedMessage( class'WFFlagRunnerDefendMessage', 0, killer.PlayerReplicationInfo );
					Flag.Holder.ReceiveLocalizedMessage( class'WFDefendedMessage', 0, killer.PlayerReplicationInfo, HolderPRI );
					break;
				}
			}

			if( !bPointGiven )
			{
				if ( ( Flag.Team == Killer.PlayerReplicationInfo.Team ) &&
				   ( Other.PlayerReplicationInfo.Team != Killer.PlayerReplicationInfo.Team ) &&
						 ( !Flag.bHeld ) &&
							 ( !Flag.bReturning ) &&
				   ( VSize( FlagLocation - Other.Location ) < DefendRadius ) )
				{
          class'WFTools'.static.AdjustMiscScore(killer.PlayerReplicationInfo, INDEX_FlagDefends, 1);
          WFTeamInfo( TournamentGameReplicationInfo(GameReplicationInfo) .Teams[ killer.PlayerReplicationInfo.Team ] ).MiscScoreArray[ INDEX_FlagDefends ]++;
			    bPointGiven = true;
			 	  Killer.ReceiveLocalizedMessage( class'WFFlagDefendMessage', 0, killer.PlayerReplicationInfo );
					break;
				}
			}
		}
	}

  class'WFTools'.static.AdjustMiscScore(killer.PlayerReplicationInfo,
                                            INDEX_Frags, 1);
  WFTeamInfo( TournamentGameReplicationInfo(GameReplicationInfo) .Teams[ killer.PlayerReplicationInfo.Team ] ).MiscScoreArray[ INDEX_Frags ]++;


	super.Killed(Killer, Other, damageType);
}

function ScoreKill(pawn Killer, pawn Other)
{

	if ((Killer != None) && (Other != None) && Killer.bIsPlayer && Other.IsA('WFAutoCannon'))
	{
		if (!IsOnTeam(Other, Killer.PlayerReplicationInfo.Team))
			Killer.PlayerReplicationInfo.Score += 1; // +1 point for fragging enemy sentry
		else Killer.PlayerReplicationInfo.Score -= 1; // -1 point for fragging own teams sentry
	}

	super.ScoreKill(Killer, Other);
}

// don't allow TL telefragging
function bool AllowTranslocation(Pawn Other, vector Dest )
{
	local pawn p;
	local translocator T;

	if (!super.AllowTranslocation(Other, Dest))
		return false;

	foreach RadiusActors(class'Pawn', p, 50.0, Dest)
	{
		if ((p != None) && p.bIsPlayer && p.bBlockPlayers && (p.Health > 0))
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
			return false;
		}
	}

	return true;
}

function ChangePlayerClass(pawn Other, class<WFS_PlayerClassInfo> NewClass, optional bool bRestartPlayer)
{
	super.ChangePlayerClass(Other, NewClass, bRestartPlayer);
	WFPlayer(Other).ClientLoadClassBindings(NewClass);
}

function CheckTeamSizes()
{
	local int i;
	local int PlayerCounts[4];
	local pawn aPawn;

	for (aPawn = Level.PawnList; aPawn != None; aPawn = aPawn.NextPawn)
	{
		if ((aPawn != None) && aPawn.bIsPlayer && (aPawn.PlayerReplicationInfo != None)
			&& (aPawn.PlayerReplicationInfo.Team < 4))
			PlayerCounts[aPawn.PlayerReplicationInfo.Team]++;
	}

	for (i=0; i<4; i++)
		if (Teams[i].Size != PlayerCounts[i])
		{
			Log("[--Debug--]: CheckTeamSizes(): Teams["$i$"].Size should be "$PlayerCounts[i]$" not "$Teams[i]);
			Teams[i].Size = PlayerCounts[i];
		}
}

function bool RestartPlayer( pawn aPlayer )
{
	local bool bResult;
	local WFSpawnProtector SP;
	EnableFlagTouch(aPlayer);

	// hack to prevent CSHP from interfering with the initial player states
	if ( (aPlayer.Physics == PHYS_Walking) && (aPlayer.IsInState('PCSpectating') || aPlayer.IsInState('RefereeMode')) )
	{
		aPlayer.SetPhysics(PHYS_None);
		return false;
	}

	bResult = super.RestartPlayer(aPlayer);

	if ((SpawnProtectionTime > 0.0) && (aPlayer.PlayerReplicationInfo.Team < MaxTeams)
		&& !aPlayer.IsInState('PCSpectating'))
	{
		SP = spawn(class'WFSpawnProtector', aPlayer,, aPlayer.Location);
		if (SP != None)
			SP.GiveTo(aPlayer);
	}

	return bResult;
}

function EnableFlagTouch(pawn Other)
{
	if (Other == None)
		return;

	if (Other.IsA('WFPlayer'))
		WFPlayer(Other).bFlagTouchDisabled = false;
	else if (Other.IsA('WFBot'))
		WFBot(Other).bFlagTouchDisabled = false;
}

function DisableFlagTouch(pawn Other)
{
	if (Other == None)
		return;

	if (Other.IsA('WFPlayer'))
		WFPlayer(Other).bFlagTouchDisabled = true;
	else if (Other.IsA('WFBot'))
		WFBot(Other).bFlagTouchDisabled = true;
}

//=============================================================================
// Referee code.
//=============================================================================

// added some referee info and game control
function Timer()
{
	local Pawn P;
	local playerpawn PlayerOther;
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
				if ( P.IsA('PlayerPawn') && !P.IsA('Spectator') && !P.IsInState('RefereeMode')
					&& !PlayerPawn(P).bReadyToPlay )
					bReady = false;

			if ( (!bRefStartGame && bReady) || (bRefStartGame && RefInfo.bRefereeReady) )
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
						PlayerOther = playerpawn(P);
						PlayerOther.ClearProgressMessages();
						if (!P.IsInState('PCSpectating')) //added this check
						{
							PlayerOther.SetProgressTime(2);
							if (P.IsInState('RefereeMode'))
							{
								// send info to referee
								if (!bReady)
								{
									PlayerOther.SetProgressMessage(WaitingMessage1, 0);
									PlayerOther.SetProgressMessage("Use 'ref ForceReady' to force players in to ready mode", 1);
								}
								else
								{
									PlayerOther.SetProgressMessage("All players are ready to play!", 0);
									PlayerOther.SetProgressMessage("Use 'ref StartGame' to begin the match", 1);
								}
							}
							else
							{
								if (bRefStartGame && !RefInfo.bRefereeReady)
								{
									// let players know ref needs to start game
									PlayerOther.SetProgressMessage("Waiting for referee to start match", 0);
								}
								else
								{
									PlayerOther.SetProgressMessage(WaitingMessage1, 0);
									PlayerOther.SetProgressMessage(WaitingMessage2, 1);
									if ( PlayerOther.bReadyToPlay )
										PlayerOther.SetProgressMessage(ReadyMessage, 2);
									else
										PlayerOther.SetProgressMessage(NotReadyMessage, 2);
								}
							}
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
		if ( P.bIsPlayer && P.IsA('PlayerPawn') )
		{
			if ( bGameEnded ) return; // telefrag ended the game with ridiculous frag limit
			else if ( !P.IsA('Spectator') && !P.IsInState('PCSpectating') && !P.IsInState('RefereeMode') ) // added 2nd check
			{
				P.PlayerRestartState = P.Default.PlayerRestartState;
				P.GotoState(P.Default.PlayerRestartState);
				if ( !P.IsA('Commander') )
					RestartPlayer(P);
			}
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

// allow referees to pause the game
function bool SetPause( BOOL bPause, PlayerPawn P )
{
	if( bPauseable || P.bAdmin || Level.Netmode==NM_Standalone
		|| (P.IsA('WFPlayer') && WFPlayer(P).bReferee) )
	{
		if( bPause )
			Level.Pauser=P.PlayerReplicationInfo.PlayerName;
		else
			Level.Pauser="";
		return True;
	}
	else return False;
}

//=============================================================================
// Bot setup code.
//=============================================================================

// Debug: assign a random PCI to this bot
function class<WFS_PlayerClassInfo> FindPCIForBot(bot aBot)
{
	local int num, team;

	team = aBot.PlayerReplicationInfo.Team;
	num = Rand(TeamClassList[Team].NumClasses);

	return TeamClassList[Team].PlayerClasses[num];
}

//=============================================================================
// === BOT AI ===
//=============================================================================
// Ob1: DM - feel free to re-write any of this AI code.

function float GameThreatAdd(Bot aBot, Pawn Other)
{
	local CTFFlag aFlag;

	if ( Other.bIsPlayer && (Other.PlayerReplicationInfo.HasFlag != None) )
		return 10;
	else
		return 0;
}

function byte AssessBotAttitude(Bot aBot, Pawn Other)
{
	if (Other.bIsPlayer && ((Other.PlayerReplicationInfo.Team == TEAM_Spectator)
		||(Other.PlayerReplicationInfo.Team == 255)) )
		return 2; // bots ignore spectating players
	else if ( Other.bIsPlayer && (aBot.PlayerReplicationInfo.Team == Other.PlayerReplicationInfo.Team))
		return 3; // teammate
	else if ( PlayerIsDisguised(Other) && (GetDisguiseTeam(Other) == aBot.PlayerReplicationInfo.Team))
		return 3; // disguised player
	else if ( (Other.bIsPlayer && (Other.PlayerReplicationInfo.HasFlag != None))
				|| (aBot.PlayerReplicationInfo.HasFlag != None) )
		return 1;
	else
		return super(TeamGamePlus).AssessBotAttitude(aBot, Other);
}

function bool PlayerIsDisguised(pawn Other)
{
	if (Other.PlayerReplicationInfo == None)
		return false;

	return class'WFDisguise'.static.IsDisguised(Other.PlayerReplicationInfo);
}

function byte GetDisguiseTeam(pawn Other)
{
	local WFDisguise Disguise;

	Disguise = WFDisguise(Other.FindInventoryType(class'WFDisguise'));
	if (Disguise != None)
		return Disguise.DisguiseTeam;

	return 255;
}

// Added support for FRS_CarryReturn.
//
// Note: ANY calls to the native navigation functions that would usually use
//       a flagbase navigation point must use the WF flagbases location marker
//       instead eg. WFFlagBase(FriendlyFlag.HomeBase).BaseMarker
//       This includes:
//          - ActorReachable()
//          - FindPathToward()
function bool FindSpecialAttractionFor(Bot aBot)
{
	if ( aBot.LastAttractCheck == Level.TimeSeconds )
		return false;
	aBot.LastAttractCheck = Level.TimeSeconds;

	switch (FlagReturnStyle)
	{
		// use the standard CTFGame attraction AI for FRS_Normal
		case FRS_TouchReturn:
			return Normal_FindSpecialAttractionFor(aBot);
			break;

		case FRS_DelayReturn:
			return DelayReturn_FindSpecialAttractionFor(aBot);
			break;

		case FRS_CarryReturn:
			return CarryReturn_FindSpecialAttractionFor(aBot);
			break;
	}

	return false;
}

// === Standard CTFGame Attraction AI ===
function bool Normal_FindSpecialAttractionFor(bot aBot)
{
	local WFFlag FriendlyFlag, EnemyFlag;
	local bool bSeeFlag, bReachHome, bOrdered;
	local WFMarker FriendlyBase, EnemyBase, CapturePoint;
	local float Dist;

	//log(aBot@"find special attraction in state"@aBot.GetStateName()@"at"@Level.TimeSeconds);
	FriendlyFlag = WFFlag(CTFReplicationInfo(GameReplicationInfo).FlagList[aBot.PlayerReplicationInfo.Team]);
	CapturePoint = FriendlyFlag.CapturePoint;
	FriendlyBase = WFFlagBase(FriendlyFlag.HomeBase).BaseMarker;

	// TODO: add support for more than one enemy team...
	if ( aBot.PlayerReplicationInfo.Team == 0 )
		EnemyFlag = WFFlag(CTFReplicationInfo(GameReplicationInfo).FlagList[1]);
	else
		EnemyFlag = WFFlag(CTFReplicationInfo(GameReplicationInfo).FlagList[0]);
	EnemyBase = WFFlagBase(EnemyFlag.HomeBase).BaseMarker;

	bOrdered = aBot.bSniping || (aBot.Orders == 'Follow') || (aBot.Orders == 'Hold');

	if ( !FriendlyFlag.bHome  )
	{
		bSeeFlag = aBot.LineOfSightTo(FriendlyFlag.Position());
		FriendlyFlag.bKnownLocation = FriendlyFlag.bKnownLocation || bSeeFlag;

		if ( bSeeFlag && (FriendlyFlag.Holder == None) && aBot.ActorReachable(FriendlyFlag) )
		{
			if ( Level.TimeSeconds - LastGotFlag > 6 )
			{
				LastGotFlag = Level.TimeSeconds;
				aBot.SendTeamMessage(None, 'OTHER', 8, 20);
			}
			aBot.MoveTarget = FriendlyFlag;
			SetAttractionStateFor(aBot);
			return true;
		}

		if ( EnemyFlag.Holder != aBot )
		{
			if ( bSeeFlag && (FriendlyFlag.Holder != None)
				&& !IsOnTeam(FriendlyFlag.Holder, aBot.PlayerReplicationInfo.Team) )
			{
				FriendlyFlag.bKnownLocation = true;
				if ( Level.TimeSeconds - LastSeeFlagCarrier > 6 )
				{
					LastSeeFlagCarrier = Level.TimeSeconds;
					aBot.SendTeamMessage(None, 'OTHER', 12, 10);
				}
				aBot.SetEnemy(FriendlyFlag.Holder);
				aBot.Orders = 'Freelance';
				aBot.MoveTarget = FriendlyFlag.Holder;
				if ( aBot.IsInState('Attacking') )
					return false;
				else
				{
					aBot.GotoState('Attacking');
					return true;
				}
			}
			else if ( aBot.Orders == 'Attack' )
			{
				// break off attack only if needed
				if ( bSeeFlag || (EnemyFlag.Holder != None)
					|| (((FriendlyFlag.Position().Region.Zone != FriendlyFlag.Homebase.Region.Zone) || (VSize(FriendlyFlag.Homebase.Location - FriendlyFlag.Position().Location) > 1000))
						&& ((aBot.Region.Zone != EnemyFlag.Region.Zone)
							|| (VSize(aBot.Location - EnemyFlag.Location) > 1600) || (VSize(aBot.Location - FriendlyFlag.Position().Location) < 1200))) )
				{
					FriendlyFlag.bKnownLocation = true;
					aBot.MoveTarget = aBot.FindPathToward(FriendlyFlag.Position());
					aBot.AlternatePath = None;
					if ( aBot.MoveTarget != None )
					{
						SetAttractionStateFor(aBot);
						return true;
					}
				}
			}
			else if ( (!bOrdered || ABot.OrderObject.IsA('Bot'))
				&& (FriendlyFlag.bKnownLocation || (FRand() < 0.1)) )
			{
				FriendlyFlag.bKnownLocation = true;
				aBot.MoveTarget = aBot.FindPathToward(FriendlyFlag.Position());
				if ( aBot.MoveTarget != None )
				{
					SetAttractionStateFor(aBot);
					return true;
				}
			}
		}
	}

	//-------------------------------------------------------------------------
	// Modified to use the FriendlyBase marker instead of FriendlyFlag.HomeBase
	// and FindPathToMarker() instead of FindPathToBase().
	// - Added AI support for alternate capture points
	if ( EnemyFlag.Holder == aBot )
	{
		aBot.bCanTranslocate = false;
		if (CapturePoint == None)
		{
			bReachHome = aBot.ActorReachable(FriendlyBase);
			if ( bReachHome && !FriendlyFlag.bHome )
			{
				aBot.SendTeamMessage(None, 'OTHER', 1, 25);
				aBot.Orders = 'Freelance';
				return false;
			}
			if ( bReachHome && (VSize(aBot.Location - FriendlyFlag.Location) < 30) )
				FriendlyFlag.Touch(aBot);
			if ( aBot.Enemy != None )
			{
				if ( aBot.Health < 60 )
					aBot.SendTeamMessage(None, 'OTHER', 13, 25);
				if ( !aBot.IsInState('FallBack') )
				{
					aBot.bNoClearSpecial = true;
					aBot.TweenToRunning(0.1);
					aBot.GotoState('Fallback', 'SpecialNavig');
				}
				if ( bReachHome )
					aBot.MoveTarget = FriendlyBase;
				else
					return FindPathToMarker(aBot, FriendlyBase);
			}
			else
			{
				if ( !aBot.IsInState('Roaming') )
				{
					aBot.bNoClearSpecial = true;
					aBot.TweenToRunning(0.1);
					aBot.GotoState('Roaming', 'SpecialNavig');
				}
				if ( bReachHome )
					aBot.MoveTarget = FriendlyBase;
				else
					return FindPathToMarker(aBot, FriendlyBase);
			}
			return true;
		}
		else
		{
			bReachHome = aBot.ActorReachable(CapturePoint);
			if ( bReachHome && !FriendlyFlag.bHome )
			{
				aBot.SendTeamMessage(None, 'OTHER', 1, 25);
				aBot.Orders = 'Freelance';
				return false;
			}
			if ( bReachHome && (VSize(aBot.Location - CapturePoint.Location) < 30) )
				CapturePoint.Touch(aBot);
			if ( aBot.Enemy != None )
			{
				if ( aBot.Health < 60 )
					aBot.SendTeamMessage(None, 'OTHER', 13, 25);
				if ( !aBot.IsInState('FallBack') )
				{
					aBot.bNoClearSpecial = true;
					aBot.TweenToRunning(0.1);
					aBot.GotoState('Fallback', 'SpecialNavig');
				}
				if ( bReachHome )
					aBot.MoveTarget = CapturePoint;
				else
					return FindPathToMarker(aBot, CapturePoint);
			}
			else
			{
				if ( !aBot.IsInState('Roaming') )
				{
					aBot.bNoClearSpecial = true;
					aBot.TweenToRunning(0.1);
					aBot.GotoState('Roaming', 'SpecialNavig');
				}
				if ( bReachHome )
					aBot.MoveTarget = CapturePoint;
				else
					return FindPathToMarker(aBot, CapturePoint);
			}
			return true;
		}
	}
	//---------------------------------------------------------------------

	if ( EnemyFlag.Holder == None )
	{
		if ( aBot.ActorReachable(EnemyFlag) )
		{
			aBot.MoveTarget = EnemyFlag;
			SetAttractionStateFor(aBot);
			return true;
		}
		else if ( (aBot.Orders == 'Attack')
				 || ((aBot.Orders == 'Follow') && aBot.OrderObject.IsA('Bot')
					&& ((Pawn(aBot.OrderObject).Health <= 0)
						 || ((EnemyFlag.Region.Zone == aBot.Region.Zone) && (VSize(EnemyFlag.Location - aBot.Location) < 2000)))) )
		{
			if ( !aBot.bKamikaze
				&& ( (aBot.Weapon == None) || (aBot.Weapon.AIRating < 0.4)) )
			{
				aBot.bKamikaze = ( FRand() < 0.1 );
				return false;
			}

			if ( (aBot.Enemy != None)
				&& (aBot.Enemy.IsA('PlayerPawn') || (aBot.Enemy.IsA('Bot') && (Bot(aBot.Enemy).Orders == 'Attack')))
				&& (((aBot.Enemy.Region.Zone == FriendlyFlag.HomeBase.Region.Zone) && (EnemyFlag.HomeBase.Region.Zone != FriendlyFlag.HomeBase.Region.Zone))
					|| (VSize(aBot.Enemy.Location - FriendlyFlag.HomeBase.Location) < 0.6 * VSize(aBot.Location - EnemyFlag.HomeBase.Location))) )
				{
					aBot.SendTeamMessage(None, 'OTHER', 14, 15); //"Incoming!"
					aBot.Orders = 'Freelance';
					return false;
				}

			if ( EnemyFlag.bHome )
				//FindPathToBase(aBot, EnemyFlag.HomeBase);
				FindPathToMarker(aBot, EnemyBase);
			else
				aBot.MoveTarget = aBot.FindPathToward(EnemyFlag);
			if ( aBot.MoveTarget != None )
			{
				SetAttractionStateFor(aBot);
				return true;
			}
			else
			{
				if ( aBot.bVerbose )
					log(aBot$" no path to flag");
				return false;
			}
		}
		return false;
	}

	if ( (bOrdered && !aBot.OrderObject.IsA('Bot')) || (aBot.Weapon == None) || (aBot.Weapon.AIRating < 0.4) )
		return false;

	if ( (aBot.Enemy == None) && (aBot.Orders != 'Defend') )
	{
		Dist = VSize(aBot.Location - EnemyFlag.Holder.Location);
		if ( (Dist > 500) || (VSize(EnemyFlag.Holder.Velocity) > 230)
			|| !aBot.LineOfSightTo(EnemyFlag.Holder) )
		{
			aBot.MoveTarget = aBot.FindPathToward(EnemyFlag.Holder);
			if ( !aBot.IsInState('Roaming') )
			{
				aBot.bNoClearSpecial = true;
				aBot.TweenToRunning(0.1);
				aBot.GotoState('Roaming', 'SpecialNavig');
				return true;
			}
			return (aBot.MoveTarget != None);
		}
		else
		{
			if ( !aBot.bInitLifeMessage )
			{
				aBot.bInitLifeMessage = true;
				aBot.SendTeamMessage(EnemyFlag.Holder.PlayerReplicationInfo, 'OTHER', 3, 10);
			}
			if ( FRand() < 0.35 )
				aBot.GotoState('Wandering');
			else
			{
				aBot.CampTime = 1.0;
				aBot.bCampOnlyOnce = true;
				aBot.GotoState('Roaming', 'Camp');
			}
			return true;
		}
	}
	return false;
}

// === FRS_DelayReturn Attraction AI ===
function bool DelayReturn_FindSpecialAttractionFor(bot aBot)
{
	// TODO: Add FRS_DelayReturn code here...
	return Normal_FindSpecialAttractionFor(aBot);
}

// === FRS_CarryReturn Attraction AI ===
function bool CarryReturn_FindSpecialAttractionFor(bot aBot)
{
	local CTFFlag FriendlyFlag, EnemyFlag;
	local bool bSeeFlag, bReachHome, bOrdered;
	local WFMarker FriendlyBase, EnemyBase;
	local float Dist;

	//log(aBot@"find special attraction in state"@aBot.GetStateName()@"at"@Level.TimeSeconds);
	FriendlyFlag = CTFReplicationInfo(GameReplicationInfo).FlagList[aBot.PlayerReplicationInfo.Team];
	FriendlyBase = WFFlagBase(FriendlyFlag.HomeBase).BaseMarker;

	// TODO: add support for more than one enemy team...
	if ( aBot.PlayerReplicationInfo.Team == 0 )
		EnemyFlag = CTFReplicationInfo(GameReplicationInfo).FlagList[1];
	else
		EnemyFlag = CTFReplicationInfo(GameReplicationInfo).FlagList[0];
	EnemyBase = WFFlagBase(EnemyFlag.HomeBase).BaseMarker;

	bOrdered = aBot.bSniping || (aBot.Orders == 'Follow') || (aBot.Orders == 'Hold');

	if ( !FriendlyFlag.bHome && (FriendlyFlag.Holder != None) )
	{
		bSeeFlag = aBot.LineOfSightTo(FriendlyFlag.Position());
		FriendlyFlag.bKnownLocation = FriendlyFlag.bKnownLocation || bSeeFlag;

		// try to return the flag back to base if carrying own flag
		if (FriendlyFlag.Holder == aBot)
		{
			aBot.bCanTranslocate = false;
			bReachHome = aBot.ActorReachable(FriendlyBase);

			if ( bReachHome && (VSize(aBot.Location - FriendlyFlag.HomeBase.Location) < 30) )
				FriendlyFlag.HomeBase.Touch(aBot);
			if ( aBot.Enemy != None )
			{
				if ( aBot.Health < 60 )
					aBot.SendTeamMessage(None, 'OTHER', 13, 25);
				if ( !aBot.IsInState('FallBack') )
				{
					aBot.bNoClearSpecial = true;
					aBot.TweenToRunning(0.1);
					aBot.GotoState('Fallback', 'SpecialNavig');
				}
				if ( bReachHome )
					aBot.MoveTarget = FriendlyBase;
				else
					return FindPathToMarker(aBot, FriendlyBase);
			}
			else
			{
				if ( !aBot.IsInState('Roaming') )
				{
					aBot.bNoClearSpecial = true;
					aBot.TweenToRunning(0.1);
					aBot.GotoState('Roaming', 'SpecialNavig');
				}
				if ( bReachHome )
					aBot.MoveTarget = FriendlyBase;
				else
					return FindPathToMarker(aBot, FriendlyBase);
			}
			return true;
		}
		else
		{
			// try to escort friendly flag back to base
			if ( (aBot.Enemy == None) && (aBot.Orders != 'Defend') && (FriendlyFlag.Holder != None) &&
				(aBot.PlayerReplicationInfo.Team == FriendlyFlag.Holder.PlayerReplicationInfo.Team) )
			{
				Dist = VSize(aBot.Location - FriendlyFlag.Holder.Location);
				if ( (Dist > 500) || (VSize(FriendlyFlag.Holder.Velocity) > 230)
					|| !bSeeFlag )
				{
					aBot.MoveTarget = aBot.FindPathToward(FriendlyFlag.Holder);
					if ( !aBot.IsInState('Roaming') )
					{
						aBot.bNoClearSpecial = true;
						aBot.TweenToRunning(0.1);
						aBot.GotoState('Roaming', 'SpecialNavig');
						return true;
					}
					return (aBot.MoveTarget != None);
				}
				else
				{
					if ( !aBot.bInitLifeMessage )
					{
						aBot.bInitLifeMessage = true;
						aBot.SendTeamMessage(FriendlyFlag.Holder.PlayerReplicationInfo, 'OTHER', 3, 10);
					}
					if ( FRand() < 0.35 )
						aBot.GotoState('Wandering');
					else
					{
						aBot.CampTime = 1.0;
						aBot.bCampOnlyOnce = true;
						aBot.GotoState('Roaming', 'Camp');
					}
					return true;
				}
			}
		}
	}

	// Call the main CTF attraction code to handle the rest of the AI.
	return Normal_FindSpecialAttractionFor(aBot);
}

// Use this to guide bots to a dynamically created location marker
// as using dynamically created navigation points with aBot.FindPathToward()
// does not work.
function bool FindPathToMarker(Bot aBot, WFMarker aMarker)
{
	if ( (aBot.AlternatePath != None)
		&& ((aBot.AlternatePath.team == aMarker.team) || aBot.AlternatePath.bTwoWay) )
	{
		if ( aBot.ActorReachable(aBot.AlternatePath) )
		{
			aBot.MoveTarget = aBot.AlternatePath;
			aBot.AlternatePath = None;
		}
		else
		{
			aBot.MoveTarget = aBot.FindPathToward(aBot.AlternatePath);
			if ( aBot.MoveTarget == None )
			{
				aBot.AlternatePath = None;
				aBot.MoveTarget = aBot.FindPathToward(aMarker);
			}
		}
	}
	else
		aBot.MoveTarget = aBot.FindPathToward(aMarker);

	return (aBot.bNoClearSpecial || (aBot.MoveTarget != None));
}

function ScoreFlag(Pawn Scorer, CTFFlag theFlag)
{
  local WF_PRI WFPRI;
  local WF_BotPRI WFBotPRI;
  local int index;

  index = INDEX_FlagCaps;
  if( Scorer.PlayerReplicationInfo.Team == theFlag.Team )
  {
    index = INDEX_FlagReturns;
  }
  class'WFTools'.static.AdjustMiscScore(Scorer.PlayerReplicationInfo,
                                        index, 1);
  WFTeamInfo( TournamentGameReplicationInfo(GameReplicationInfo) .Teams[ Scorer.PlayerReplicationInfo.Team ] ).MiscScoreArray[ index ]++;

  super.ScoreFlag( Scorer, theFlag );
}

defaultproperties
{
	BeaconName="WF"
	GameName="Weapons Factory"
	GameReplicationInfoClass=class'WFGameGRI'
	PCPlayerClass=class'WFPlayer'
	ClassDefinitions(0)="WFCode.WFPlayerClassList"
	ClassDefinitions(1)="WFCode.WFPlayerClassList"
	ClassDefinitions(2)="WFCode.WFPlayerClassList"
	ClassDefinitions(3)="WFCode.WFPlayerClassList"
	RulesMenuType="WFCode.WFRSClient"
	SettingsMenuType="WFCode.WFSSClient"
	DefaultExtendedHUDClass=Class'WFCustomHUDInfo'
	bUseTranslocator=True
	HUDType=Class'WFCustomHUD'
	FlagReturnTime=40.000000
	bVoiceMetaClassCheck=True
	DefaultMapInfo=class'WFGameMapSetupInfo'
	PCBotClass=class'WFBot'
	MutatorClass=class'WFMutator'
	DeathMessageClass=class'WFDeathMessagePlus'
	ScoreBoardType=Class'WFCustomScoreboard'
	TeamPasswordDialogClass(0)=class'WFTeamPasswordDialogWDI_Red'
	TeamPasswordDialogClass(1)=class'WFTeamPasswordDialogWDI_Blue'
	TeamPasswordDialogClass(2)=class'WFTeamPasswordDialogWDI_Green'
	TeamPasswordDialogClass(3)=class'WFTeamPasswordDialogWDI_Gold'
	DefaultTeamClassList(0)=class'WFPlayerClassList'
	DefaultTeamClassList(1)=class'WFPlayerClassList'
	DefaultTeamClassList(2)=class'WFPlayerClassList'
	DefaultTeamClassList(3)=class'WFPlayerClassList'
	WFGameVersion="107b"
	FlagReturnStyle=0
	FRS_DelayReturn=0
	FRS_TouchReturn=1
	FRS_CarryReturn=2
	MapListType=class'WFGameMapList'
	DefendRadius=2084.000000
	FlagRunnerDefendRadius=2048.000000
	SpawnProtectionTime=8.000000
	INDEX_FlagDefends=1
	INDEX_FlagCarrierKills=2
	INDEX_FlagCarrierDefends=3
	INDEX_FlagReturns=4
	INDEX_Frags=7
	KilledFlagCarrierBonus=1
}
