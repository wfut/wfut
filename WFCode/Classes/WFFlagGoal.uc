//=============================================================================
// WFFlagGoal.
// Author: Ob1-Kenobi (ob1@planetunreal.com)
//
// Can be used as an aternate location to cap a flag, i.e. instead of the flags
// origional location.
//=============================================================================
class WFFlagGoal extends WFMarker;

var CTFFlag MyFlag;
var int Team;
var bool bAlwaysCap; // allow cap even if flag not home

var bool bActive;

function Touch(actor Other)
{
	local Pawn aPawn;
	local CTFFlag aFlag;
	local CTFReplicationInfo CTFGRI;
	local bool bFlagHome;
	local byte PlayersTeam;

	if ((MyFlag == None) && (Team != 255))
		return;

	// can only cap a flag if own flag at home
	if ((Team == 255) || bAlwaysCap || MyFlag.bHome)
	{
		aPawn = Pawn(Other);
		if ( (aPawn != None) && aPawn.bIsPlayer && (aPawn.Health > 0)
			&& !aPawn.IsInState('FeigningDeath') )
		{
			PlayersTeam = aPawn.PlayerReplicationInfo.Team;
			CTFGRI = CTFReplicationInfo(Level.Game.GameReplicationInfo);
			bFlagHome = bAlwaysCap || CTFGRI.FlagList[PlayersTeam].bHome;
			if ( bFlagHome && ((Team == 255) || (PlayersTeam == Team))
				&& (aPawn.PlayerReplicationInfo.HasFlag != None))
			{
				aFlag = CTFFlag(aPawn.PlayerReplicationInfo.HasFlag);
				if ((aFlag != None) && (PlayersTeam != aFlag.Team) && (aFlag.Team != Team))
				{
					// score the capture
					CTFGame(Level.Game).ScoreFlag(aPawn, aFlag);
					aFlag.SendHome();
				}
			}
		}
	}
}

defaultproperties
{
     bStatic=False
     bNoDelete=False
     CollisionRadius=48.000000
     CollisionHeight=30.000000
     bCollideActors=True
}