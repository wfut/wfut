class WFMiniChunk extends UTChunk
	abstract;

simulated function PostBeginPlay()
{
	local rotator RandRot;

	if ( Level.NetMode != NM_DedicatedServer )
	{
		if ( !Region.Zone.bWaterZone )
			Trail = Spawn(class'WFMiniChunkTrail',self);
		SetTimer(0.1, true);
	}

	if ( Role == ROLE_Authority )
	{
		RandRot = Rotation;
		RandRot.Pitch += FRand() * 2000 - 1000;
		RandRot.Yaw += FRand() * 2000 - 1000;
		RandRot.Roll += FRand() * 2000 - 1000;
		Velocity = Vector(RandRot) * (Speed + (FRand() * 200 - 100));
		if (Region.zone.bWaterZone)
			Velocity *= 0.65;
	}
	Super.PostBeginPlay();
}

defaultproperties
{
	//DrawScale=0.400000
	DrawScale=0.100000
	Damage=12
}
