class WFTeslaChainBoltChild extends WFTeslaStarterBolt;

var actor BeamTarget;
var WFTeslaChainParent ChainParent;

var float LastTargetCheck;

replication
{
	reliable if (Role == ROLE_Authority)
		BeamTarget;
}

simulated function Tick(float DeltaTime)
{
	local vector X,Y,Z, AimSpot, DrawOffset, AimStart;
	local int YawErr;
	local float dAdjust;
	local Bot MyBot;

	AnimTime += DeltaTime;
	if ( AnimTime > 0.05 )
	{
		AnimTime -= 0.05;
		SpriteFrame++;
		if ( SpriteFrame == ArrayCount(SpriteAnim) )
			SpriteFrame = 0;
		Skin = SpriteAnim[SpriteFrame];
	}

	if (LastTargetCheck == 0.0)
		LastTargetCheck = Level.TimeSeconds;

	if ((Role == ROLE_Authority) && ((Level.TimeSeconds - LastTargetCheck) > 0.5))
	{
		LastTargetCheck = Level.TimeSeconds;

		if ((ChainParent != None) && ((BeamTarget == None)
			|| (VSize(ChainParent.Location - BeamTarget.Location) > ChainParent.Range)
			|| !ChainParent.ValidTarget(BeamTarget)) )
		{
			ChainParent.OutOfRange(BeamTarget);
			return;
		}
	}

	// orient with respect to instigator
	SetLocation(Owner.Location);

	if ( BeamTarget != None )
	{
		SetRotation(rotator(BeamTarget.Location - Location));
		GetAxes(Rotation,X,Y,Z);
	}
	else
	{
		//Log(self$".Target: None");
		GetAxes(Rotation,X,Y,Z);
	}

	CheckBeam(X, DeltaTime);
}

defaultproperties
{
	FireOffset=(X=0.0,Y=0.0,Z=0.0)
	TeslaBeamClass=class'WFTeslaCBChildSegment'
	MaxPos=4
}
