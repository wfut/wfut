class WFSeekingRocket extends UT_SeekingRocket;

var int Team;
var int Count;

simulated function Timer()
{
	local ut_SpriteSmokePuff b;
	local vector SeekingDir;
	local float MagnitudeVel;

	if ( InitialDir == vect(0,0,0) )
		InitialDir = Normal(Velocity);

	if ((Seeking == None) && (count >= 5))
	{
		Count = 0;
		FindTarget();
	}
	else count++;

	if ( (Seeking != None) && (Seeking != Instigator) )
	{
		SeekingDir = Normal(Seeking.Location - Location);
		if ( (SeekingDir Dot InitialDir) > 0 )
		{
			MagnitudeVel = VSize(Velocity);
			SeekingDir = Normal(SeekingDir * 0.5 * MagnitudeVel + Velocity);
			Velocity =  MagnitudeVel * SeekingDir;
			Acceleration = 25 * SeekingDir;
			SetRotation(rotator(Velocity));
		}
	}
	if ( bHitWater || (Level.NetMode == NM_DedicatedServer) )
		Return;

	if ( (Level.bHighDetailMode && !Level.bDropDetail) || (FRand() < 0.5) )
	{
		b = Spawn(class'ut_SpriteSmokePuff');
		b.RemoteRole = ROLE_None;
	}
}

function FindTarget()
{
	local pawn p;

	foreach VisibleCollidingActors(class'Pawn', p, 1000.0)
	{
		if ((p != None) && p.bIsPlayer && (p.PlayerReplicationInfo.Team != Team)
			&& (p.Health > 0) && ((Normal(p.Location - Location) dot Velocity) > 0))
		{
			// found good target
			Seeking = p;
			PlaySound(class'UT_EightBall'.default.Misc1Sound, SLOT_None, 2.0);
		}
	}
}

defaultproperties
{
	Damage=40
	MomentumTransfer=40000
	speed=750.000000
	MaxSpeed=1250.000000
	Mesh=LodMesh'WF_Rocket'
	DrawScale=1
}