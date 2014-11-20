class WFTeamDamageZone extends WFMapActors;

var() float DamageTime;
var() int DamageAmount;
var() name DamageType;

var() int TeamFlags;

function PostBeginPlay()
{
	super.PostBeginPlay();
	SetTimer(DamageTime, true);
}

function Timer()
{
	local pawn aPawn;

	foreach Region.Zone.ZoneActors(class'pawn', aPawn)
		if ((aPawn != None) && aPawn.bIsPlayer && (aPawn.PlayerReplicationInfo.Team < 4)
			&& (aPawn.Region.Zone == Region.Zone)
			&& (aPawn.Region.ZoneNumber == Region.ZoneNumber)
			&& DamageTeam(aPawn.PlayerReplicationInfo.Team))
			aPawn.TakeDamage(DamageAmount, None, vect(0,0,0), aPawn.Location, DamageType);
}

function bool DamageTeam(byte TeamNum)
{
	return !bool((2**TeamNum) & TeamFlags);
}

defaultproperties
{
	DamageTime=1.0
	DamageAmount=50
	DamageType=TeamDamageZone
	CollisionHeight=0.0
	CollisionRadius=0.0
	bCollideActors=False
}