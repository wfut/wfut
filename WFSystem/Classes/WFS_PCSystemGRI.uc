//=============================================================================
// WFS_PCSystemGRI.
//=============================================================================
//class WFS_PCSystemGRI extends TournamentGameReplicationInfo;
class WFS_PCSystemGRI extends CTFReplicationInfo;

var WFS_PCIList 			TeamClassList[4];
var int 				MaxTeams;	// used by StartGameHUDMenu
var bool				bAllowClassChanging;

replication
{
	reliable if (Role == ROLE_Authority)
		TeamClassList, bAllowClassChanging, MaxTeams;

//	reliable if ( (Role == ROLE_Authority) && bNetInitial )
//		MaxTeams;
}

defaultproperties
{
}
