//=============================================================================
// WFAlarmArea.
//=============================================================================
class WFAlarmArea extends Triggers;

var() float AlarmRadius;
var byte OwnerTeam;
var WFAlarm OwnerAlarm;

function PostBeginPlay()
{
	super.PostBeginPlay();
	SetTimer(0.25, false);
}

function Touch(actor Other)
{
	if (ValidTouch(Other))
	{
		OwnerAlarm.PlayAlarm();
		SetTimer(5.0, false);
	}
}

function Timer()
{
	CheckAlarmRadius();
}

function bool ValidTouch(actor Other)
{
	if ( (Other != None) && !Other.bHidden && Other.bIsPawn && pawn(Other).bIsPlayer
		&& (pawn(Other).PlayerReplicationInfo.Team != OwnerTeam) )
	{
		return true;
	}

	return false;
}

function bool CheckAlarmRadius()
{
	local int i;
	local pawn p;

	for (i=0; i<4; i++)
	{
		if (Touching[i] != None)
		{
			if (ValidTouch(Touching[i]))
			{
				OwnerAlarm.PlayAlarm();
				SetTimer(5.0, false);
				return true;
			}
		}
	}

	OwnerAlarm.StopAlarm();
	return false;
}

function InitAlarmArea()
{
	SetCollisionSize(AlarmRadius, AlarmRadius);
	SetCollision(true,false,false);
}

defaultproperties
{
	AlarmRadius=250.000000
	bStatic=False
	bStasis=False
	bCollideActors=True
	RemoteRole=ROLE_None
}