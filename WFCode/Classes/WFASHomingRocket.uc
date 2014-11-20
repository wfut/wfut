class WFASHomingRocket extends WFASRocket;

var Actor Seeking;
var vector InitialDir;

var sound FoundTargetSound;

replication
{
	// Relationships.
	reliable if( Role==ROLE_Authority )
		Seeking, InitialDir;
}

simulated function Timer()
{
	local vector SeekingDir;
	local float MagnitudeVel;

	if ( InitialDir == vect(0,0,0) )
		InitialDir = Normal(Velocity);

	if ( (Role == ROLE_Authority)
		&& ((Seeking == None) || !CanSee(Seeking)) )
		FindTarget();

	if ( (Seeking != None) && (Seeking != Instigator) )
	{
		SeekingDir = Normal(Seeking.Location - Location);
		if ( (SeekingDir Dot normal(Velocity)) > 0 )
		{
			MagnitudeVel = VSize(Velocity);
			SeekingDir = Normal(SeekingDir * 0.75 * MagnitudeVel + Velocity);
			Velocity =  MagnitudeVel * SeekingDir;
			Acceleration = 25 * SeekingDir;
			SetRotation(rotator(Velocity));
		}
	}

	super.Timer();
}

function bool CanSee(actor Other)
{
	local vector OtherDir, Dir;

	OtherDir = normal(Other.Location - Location);
	if ((Other != None) && FastTrace(Other.Location, Location)
		&& (OtherDir dot normal(Velocity) > 0));
		return true;

	if (Seeking == Other)
		Seeking = None;

	return false;
}

function FindTarget()
{
	local teamcannon c;
	foreach allactors(class'TeamCannon', c)
		if ((c != None) && CanSee(c) && ValidCannon(c))
		{
			PlaySound(FoundTargetSound, SLOT_None, 2.0);
			Seeking = c;
		}
}

defaultproperties
{
	Speed=600
	MaxSpeed=600
	Damage=125
	PlayerDamageScale=0.35
	FoundTargetSound=Sound'UnrealShare.Eightball.SeekLock'
}