//=============================================================================
// WFRefereeInfo.
//=============================================================================
class WFRefereeInfo extends Info;

var private config string RefPassword;

var int NumReferees;
var config int MaxReferees;
var bool bRefereeReady;

// referee ability flags
var config bool bRefChangeLevel;
var config bool bRefKickPlayers;
var config bool bRefKickBanPlayers;

replication
{
    reliable if (Role == ROLE_Authority)
        NumReferees;
}

// called by gameinfo to set referee login password
function SetRefPassword(string NewPassword)
{
    RefPassword = NewPassword;
    SaveConfig();
}

function RefCommand(WFPlayer Other, string Command, string ParamString)
{
    local int Num;

	//Log("RefCommand(): command = '"$Command$"' ParamString = '"$ParamString$"'");

    if ((Other == none) || (Command == ""))
        return;

	// process the command
    switch (caps(Command))
    {
		case "SAY":
			RefSay(Other, ParamString);
			break;

		case "RESTARTMAP":
			RestartMap(Other);
			break;

		case "CHANGELEVEL":
			if (bRefChangeLevel)
				ChangeLevel(Other, ParamString);
			break;

		case "KICK":
			if (bRefKickPlayers)
				Kick(Other, ParamString);
			break;

		case "KICKBAN":
			if (bRefKickBanPlayers)
				KickBan(Other, ParamString);
			break;

		case "STARTGAME":
			StartGame(Other);
			break;

		case "FORCEREADY":
			ForceReady(Other);
			break;

		case "SETMUTE":
			SetMute(Other, ParamString);
			break;

		case "VIEWTEAM":
			Num = GetTeamNumberForString(ParamString);
			Other.RefViewingTeam = Num;
			ViewTeam(Other, Num);
			break;

		case "RETURNFLAG":
			if (ParamString ~= "all")
				Num = 255;
			else Num = GetTeamNumberForString(ParamString);
			ReturnFlag(Num);
			break;

		default:
			break; // unknown command
    }
}

function ReturnFlag(byte TeamNum)
{
	// TODO: add referee flag returning code
}

function int GetTeamNumberForString(string TeamString)
{
	local int Num;
	switch (caps(TeamString))
	{
		case "0":
		case "RED": Num = 0; break;

		case "1":
		case "BLUE": Num = 1; break;

		case "2":
		case "GREEN": Num = 2; break;

		case "3":
		case "YELLOW":
		case "GOLD": Num = 3; break;
		default: Num = 255;
	}
	return Num;
}

// login/logout control
function RefLogin(WFPlayer Other, coerce string LoginPwd)
{
    local int Team;
    local TeamGamePlus TGP;
    local WFPlayer WFP;
 	local float logintime;
 	local int MaxAttempts;

    if ((Other == None) || Other.bReferee || (RefPassword ~= ""))
		return;

 	WFP = Other; // urgh, should change this :o/
 	if ((WFP == None) || WFP.bRefLoginDisabled)
 		return;

 	if ((MaxReferees > 0) && (NumReferees == MaxReferees))
    {
        Other.ClientMessage("Maximum number of referees already logged in");
        return;
    }

	MaxAttempts = WFGame(Level.Game).MaxLoginAttempts;

 	if (WFP.NumRefLogins == 0)
 	{
 		WFP.NumRefLogins++;
 		WFP.FirstRefLoginTime = Level.TimeSeconds;
 	}
 	else
 		WFP.NumRefLogins++;

    // check password
    if (LoginPwd ~= RefPassword)
    {
        // password checked out
        // if player has joined a team already, update the team count
		ClearPCI(Other);
        Team = Other.PlayerReplicationInfo.Team;
        TGP = TeamGamePlus(Level.Game);
		if (Team < TGP.MaxTeams)
			TGP.Teams[Team].Size--;
		Other.PlayerReplicationInfo.Team = 255;

		ClearViewTarget(Other);

		if (Team < TGP.MaxTeams)
			Other.Died(None, 'RefLogin', Other.Location);
		Other.GotoState('RefereeMode');
		Level.Game.DiscardInventory(Other);
		Other.PlayerRestartState = 'RefereeMode';
		Other.PlayerRestartClass = None;
		Other.ClientSetExtendedHUD(class'WFRefereeHUDInfo');
		//Level.Game.RestartPlayer(Other);
        Other.bReferee = true;
        Other.bMute = false;
        BroadcastMessage(Other.PlayerReplicationInfo.PlayerName$" became a referee");

        NumReferees++;

 		WFP.NumRefLogins = 0;
 		WFP.FirstRefLoginTime = 0.0;
    }
	else if (WFP.NumRefLogins > MaxAttempts)
	{
 		// check to see if player is flooding to try to gain the password
		WFP.bRefLoginDisabled = true;
		WFP.NumRefLogins = 0;
		WFP.FirstRefLoginTime = 0.0;
		Log("INFO: REFLOGIN: "$WFP.PlayerReplicationInfo.PlayerName$" (IP: "$WFP.GetPlayerNetworkAddress()$") failed to log in within "$MaxAttempts$" attempts, REFEREE login disabled for this player");
	}
}

function ClearPCI(WFPlayer Other)
{
	local WFPCIList classlist;

	if ((Other == None) || (Other.PCInfo == None))
		return;

	foreach allactors(class'WFPCIList', classlist)
		if ((classlist != None) && (classlist.Team == Other.PlayerReplicationInfo.Team))
			break; // found relavent class list for player

	Other.PCInfo.static.PlayerChangedTeam(Other);
	if (classlist != None)
		classlist.PlayerChangedClass(Other.PCInfo, None);
}

function ClearViewTarget(WFPlayer Other)
{
	local playerpawn P;

	if (Other == None)
		return;

	// clear any viewtarget refs to this player
	foreach allactors(class'PlayerPawn', P)
		if ((P != None) && P.IsA('WFPlayer') && (P.ViewTarget == Other))
		{
			P.ViewTarget = None;
			P.bBehindView = false;
		}

	// clear the viewtarget for the player
	Other.ViewTarget = None;
	Other.bBehindView = false;
}

function RefLogout(WFPlayer Other, optional bool bTimedOut)
{
    // go back to default login state
    if (!Other.bReferee)
        return;
    Other.bReferee = false;
    if (!bTimedOut)
    {
        ClearViewTarget(Other);
        Other.GotoState('PCSpectating');
        Other.PlayerReplicationInfo.Team = 4; // TEAM_Spectator
		Other.ClientSetExtendedHUD(class'WFHUDInfo');
        BroadcastMessage(Other.PlayerReplicationInfo.PlayerName$" left referee mode");
    }
    NumReferees--;
}

function RefSay(WFPlayer Other, string Message)
{
    local string TeamName;
    local int TeamNum, pos;
    local pawn aPawn;
    local bool bRefMessage, bCentre;
    local name MsgType;

	// Message string format: "@[team] message text"
	//Log("RefSay(): "$Message);

	// Team number is parsed from the single character number specified to the left
	// of the " " character. Valid names for "[team]" are: red, blue, green, gold, or ref
	// ([team]=ref will only send to other referees)

	// eg. "ref say @blue message text" or "ref say:@blue:message text"
	// would both send "message text" to only the players on blue team
	bCentre = Left(Message, 1) ~= "#";
	if (bCentre) Message = Mid(Message, 1);

    TeamNum = -1;
    MsgType = 'RefSay';
    if (Left(Message, 1) != "@")
        TeamNum = 255; // send message to all players
    else
    {
		MsgType = 'RefTeamSay';
		Message = Mid(Message, 1);
		pos = InStr(Message, " ");
        TeamName = Left(Message, pos);

        if (TeamName ~= "ref") bRefMessage = true;
        else TeamNum = GetTeamNumberForString(TeamName);

        Message = Mid(Message, pos+1);
	}

	// always allow message broadcast for referees
	for (aPawn=Level.Pawnlist; aPawn!=None; aPawn=aPawn.NextPawn)
	{
		if ( (aPawn.bIsPlayer && TeamNum == 255) || aPawn.IsA('MessagingSpectator') || aPawn.IsInState('RefereeMode')
			|| (aPawn.bIsPlayer && !bRefMessage && (aPawn.PlayerReplicationInfo.Team == TeamNum)) )
		{
			if (bCentre && aPawn.IsA('PlayerPawn'))
			{
				PlayerPawn(aPawn).ClearProgressMessages();
				PlayerPawn(aPawn).SetProgressTime(5);
				PlayerPawn(aPawn).SetProgressMessage(Message,0);
			}
			else
				aPawn.TeamMessage(Other.PlayerReplicationInfo, Message, MsgType, true);
		}
	}
}

// player control
function Kick(WFPlayer Other, string S)
{
	local Pawn aPawn;

	for( aPawn=Level.PawnList; aPawn!=None; aPawn=aPawn.NextPawn )
		if
		(	aPawn.bIsPlayer
			&&	aPawn.PlayerReplicationInfo.PlayerName~=S
			&&	(PlayerPawn(aPawn)==None || NetConnection(PlayerPawn(aPawn).Player)!=None ) )
		{
			Level.Game.BroadCastMessage(aPawn.PlayerReplicationInfo.PlayerName$" was kicked by "$Other.PlayerReplicationInfo.PlayerName, true);
			aPawn.Destroy();
			return;
		}
}

function KickBan(WFPlayer Other, string S)
{
	local Pawn aPawn;
	local string IP;
	local int j;

	for( aPawn=Level.PawnList; aPawn!=None; aPawn=aPawn.NextPawn )
		if
		(	aPawn.bIsPlayer
			&&	aPawn.PlayerReplicationInfo.PlayerName~=S
			&&	(PlayerPawn(aPawn)==None || NetConnection(PlayerPawn(aPawn).Player)!=None ) )
		{
			IP = PlayerPawn(aPawn).GetPlayerNetworkAddress();
			if(Level.Game.CheckIPPolicy(IP))
			{
				IP = Left(IP, InStr(IP, ":"));
				Log("Adding IP Ban for: "$IP);
				for(j=0;j<50;j++)
					if(Level.Game.IPPolicies[j] == "")
						break;
				if(j < 50)
					Level.Game.IPPolicies[j] = "DENY,"$IP;
				Level.Game.SaveConfig();
			}
			Level.Game.BroadCastMessage(aPawn.PlayerReplicationInfo.PlayerName$" was kick-banned by "$Other.PlayerReplicationInfo.PlayerName, true);
			aPawn.Destroy();
			return;
		}
}

// command format: "ref setmute all 1( param)"
function SetMute(WFPlayer Other, string Options)
{
	local string MuteType, Param;
	local int pos, num;
	local bool bMute;

	//Log("SetMute(): "$Options);

	pos = InStr(Options, " ");
	if (pos == -1)
		return;
	else
	{
		MuteType = Left(Options, pos);
		Options = Mid(Options, pos+1);
	}

	pos = InStr(Options, " ");
	if (pos == -1)
	{
		bMute = Options ~= "1";
		Param = "";
	}
	else
	{
		bMute = Left(Options, pos) ~= "1";
		Param = Mid(Options, pos+1);
	}

	//Log("SetMute(): Type = "$MuteType$", bMute = "$bMute$", Param = "$Param);

	switch(caps(MuteType))
	{
		case "ALL":
			MuteAll(bMute);
			break;

		case "TEAM":
			num = int(Param);
			if (num >= TeamGamePlus(Level.Game).maxteams)
				Other.ClientMessage("Bad team number for SetMute command: "$num);
			else MuteTeam(num, bMute);
			break;

		case "PLAYER":
			if (!MutePlayer(Param, bMute))
				Other.ClientMessage("Player name not found for SetMute command: "$param);
			break;

		case "PLAYERID":
			num = int(Param);
			if (!MutePlayerID(num, bMute))
				Other.ClientMessage("Player ID not found for SetMute command: "$num);
			break;
	}
}

// game messaging control
function MuteTeam(int TeamNum, bool bMute)
{
	local pawn P;
	for (P=Level.PawnList; P!=None; P=P.NextPawn)
		if ( P.IsA('WFPlayer') && !P.IsInState('RefereeMode')
			&& (P.PlayerReplicationInfo.Team == TeamNum))
			WFPlayer(P).bMute = bMute;
}

function MuteAll(bool bMute)
{
	local pawn P;
	for (P=Level.PawnList; P!=None; P=P.NextPawn)
		if ( P.IsA('WFPlayer') && !P.IsInState('RefereeMode'))
			WFPlayer(P).bMute = bMute;
}

function bool MutePlayer(coerce string PlayerName, bool bMute)
{
	local pawn P;
	for (P=Level.PawnList; P!=None; P=P.NextPawn)
		if ( P.IsA('WFPlayer') && !P.IsInState('RefereeMode')
			&& (P.PlayerReplicationInfo.PlayerName ~= PlayerName)
			&& !P.IsInState('RefereeMode'))
			{
				WFPlayer(P).bMute = bMute;
				return true;
			}

	return false; // player not found
}

function bool MutePlayerID(int PlayerID, bool bMute)
{
	local pawn P;
	for (P=Level.PawnList; P!=None; P=P.NextPawn)
		if ( P.IsA('WFPlayer') && !P.IsInState('RefereeMode')
			&& (P.PlayerReplicationInfo.PlayerID ~= PlayerID))
			{
				WFPlayer(P).bMute = bMute;
				return true;
			}

	return false; // player not found
}

// game control

// hrm, not sure there is much point having this here if ref can pause game anyway
function PauseGame(WFPlayer Other)
{
	local bool bPause;
	bPause = (Level.Pauser == "");
	Level.Game.SetPause(bPause, Other);
}

function StartPreMatch(WFPlayer Other);
function StartGameWait(WFPlayer Other);

function LockGame(WFPlayer Other);
function UnlockGame(WFPlayer Other);

function ForceReady(WFPlayer Other)
{
	local pawn P;
	for (P=Level.PawnList; P!=None; P=P.NextPawn)
		if ( P.IsA('PlayerPawn') && !P.IsA('Spectator') && !P.IsInState('RefereeMode') )
			PlayerPawn(P).bReadyToPlay = true;;
}

function StartGame(WFPlayer Other)
{
	bRefereeReady = true;
}

function ChangeLevel(WFPlayer Other, string NextMapName)
{
	local int pos;

	// make sure the map is valid for this gametype
	if (caps(Left(NextMapName, Len(Level.Game.MapPrefix))) != Level.Game.MapPrefix)
	{
		Other.ClientMessage("Map name must begin with "$Level.Game.MapPrefix);
		return;
	}

	// remove any "?" params from the level URL
	pos = InStr(NextMapName, "?");
	if (pos != -1)
		NextMapName = Left(NextMapName, pos-1);

	Level.ServerTravel( NextMapName, false );
}

function RestartMap(WFPlayer Other)
{
	Level.ServerTravel( "?restart", false );
}

// player viewing commands
function ViewTeam(WFPlayer Other, int num)
{
	local pawn Current, First, aPawn;
	local bool bFound;

	//Log("ViewTeam(): num = "$num);

	if ((num >= TeamGamePlus(Level.Game).MaxTeams) || (num < 0))
		num = 255; // view all players

	Current = pawn(Other.ViewTarget);
	if ((Current != None) && (!Current.bIsPlayer || ((num != 255) && (Current.PlayerReplicationInfo.Team != num))) )
		Current = None;

	First = None;
	foreach allactors(class'Pawn', aPawn)
	{
		if ( (aPawn != None) && aPawn.bIsPlayer && ((num == 255) || (aPawn.PlayerReplicationInfo.Team == num))
			&& !aPawn.IsInState('RefereeMode') && !aPawn.IsInState('PCSpectating') )
		{
			if (Current == None)
			{
				SetViewTarget(Other, aPawn);
				return;
			}

			if (First == None)
				First = aPawn;

			if (bFound)
			{
				SetViewTarget(Other, aPawn);
				return;
			}

			if (aPawn == Current)
				bFound = true;
		}
	}

	if (bFound && (First != None))
	{
		SetViewTarget(Other, First);
		return;
	}

	Other.ClientMessage("Failed to view team: "$Num);
}

function SetViewTarget(WFPlayer Other, actor NewTarget)
{
	if (NewTarget == None)
		return;

	Other.ViewTarget = NewTarget;
	Other.bBehindview = true;
	if (NewTarget.bIsPawn && pawn(NewTarget).bIsPlayer)
		Other.ClientMessage("Now viewing from: "$pawn(NewTarget).PlayerReplicationInfo.PlayerName);
	Other.ViewTarget.BecomeViewTarget();
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
	bRefChangeLevel=True
	bRefKickPlayers=True
	bRefKickBanPlayers=True
}