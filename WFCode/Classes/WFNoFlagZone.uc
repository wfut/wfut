class WFNoFlagZone extends WFMapActors;

var() float CheckTime;

function PostBeginPlay()
{
	super.PostBeginPlay();
	SetTimer(CheckTime, true);
}

function Timer()
{
	local pawn aPawn;
	local CTFFlag aFlag;

	foreach Region.Zone.ZoneActors(class'pawn', aPawn)
	{
		if ((aPawn != None) && aPawn.bIsPlayer && (aPawn.Region.Zone == Region.Zone)
			&& (aPawn.Region.ZoneNumber == Region.ZoneNumber)
			&& (aPawn.PlayerReplicationInfo.HasFlag != None))
		{
			aFlag = CTFFlag(aPawn.PlayerReplicationInfo.HasFlag);
			BroadcastLocalizedMessage( class'CTFMessage', 5, None, None, CTFGame(Level.Game).Teams[aFlag.Team] );
			aFlag.SendHome();
		}
	}
}

defaultproperties
{
	CheckTime=0.5
	CollisionHeight=0.0
	CollisionRadius=0.0
	bCollideActors=False
}