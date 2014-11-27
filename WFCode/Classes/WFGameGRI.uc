//=============================================================================
// WFGameGRI.
//=============================================================================
class WFGameGRI extends WFS_PCSystemGRI;

var byte FlagReturnStyle;

replication
{
	reliable if (Role == ROLE_Authority)
		FlagReturnStyle;
}

defaultproperties
{
}