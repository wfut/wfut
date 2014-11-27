class WFPipeBombTriggerArea extends Triggers;

var() float ProximityRadius;
var byte OwnerTeam;
var WFPipeBombTrigger OwnerBombTrigger;

function PostBeginPlay()
{
	super.PostBeginPlay();
	SetTimer(0.25, true);
}

function Touch(actor Other)
{
	if (ValidTouch(Other) && (OwnerBombTrigger != None))
	{
		//Log("Valid trigger for: "$Other);
		OwnerBombTrigger.Detonate();
	}
}

function Timer()
{
	if (CheckProximity() && (OwnerBombTrigger != None))
	{
		//Log("Valid proximity trigger");
		OwnerBombTrigger.Detonate();
	}
}

function bool ValidTouch(actor Other)
{
	if ( (Other != None) && !Other.bHidden && Other.bIsPawn && pawn(Other).bIsPlayer
		&& (pawn(Other).PlayerReplicationInfo.Team != OwnerTeam) )
		return true;

	return false;
}

function bool CheckProximity()
{
	local int i;
	local pawn p;

	if ((Owner != None) && (Location != Owner.Location))
		SetLocation(Owner.Location);

	/*for (i=0; i<4; i++)
	{
		if ((Touching[i] != None) && ValidTouch(Touching[i]))
			return true;
	}*/

	for (p=Level.PawnList; p!=None; p=p.NextPawn)
	{
		if ((p != None) && (VSize(p.Location - Location) <= ProximityRadius) && ValidTouch(Touching[i]))
			return true;
	}

	return false;
}

function InitProximityArea()
{
	SetCollisionSize(ProximityRadius, ProximityRadius);
	SetCollision(true,false,false);
}

defaultproperties
{
     ProximityRadius=250.000000
     RemoteRole=ROLE_None
}
