class WFAlarmGlow extends Effects;

var Effects AlarmEffect;

simulated function PostBeginPlay()
{
	SetTimer(0.01, false);
}

simulated function Timer()
{
	if (Level.NetMode != NM_DedicatedServer)
		AlarmEffect = spawn(class'WFAlarmLight', self,, Location);
}

function HideGlow()
{
	bHidden = true;
}

function ShowGlow()
{
	bHidden = false;
}

simulated function Destroyed()
{
	super.Destroyed();
	if (AlarmEffect != None)
		AlarmEffect.Destroy();
}

defaultproperties
{
     bHidden=True
     bNetTemporary=False
     bTrailerPrePivot=True
     Physics=PHYS_Trailer
     RemoteRole=ROLE_SimulatedProxy
}