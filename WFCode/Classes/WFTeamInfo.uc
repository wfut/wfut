class WFTeamInfo extends TeamInfo;

var int MiscScoreArray[8];

replication
{
	reliable if (Role == ROLE_Authority)
		MiscScoreArray;
}

defaultproperties
{
}
