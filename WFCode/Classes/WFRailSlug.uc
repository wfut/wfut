class WFRailSlug extends UTChunk;

simulated function PostBeginPlay()
{
	local rotator RandRot;

	if ( Level.NetMode != NM_DedicatedServer )
	{
		if ( !Region.Zone.bWaterZone )
			Trail = Spawn(class'ChunkTrail',self);
		SetTimer(0.1, true);
	}

	if ( Role == ROLE_Authority )
	{
		RandRot = Rotation;
		RandRot.Pitch += FRand() * 200 - 100;
		RandRot.Yaw += FRand() * 200 - 100;
		RandRot.Roll += FRand() * 200 - 100;
		Velocity = Vector(RandRot) * (Speed + (FRand() * 20 - 10));
		if (Region.zone.bWaterZone)
			Velocity *= 0.65;
	}
	Super(Projectile).PostBeginPlay();
}

defaultproperties
{
     //Speed=1200
     //MaxSpeed=1200
     AnimSequence=WingIn
     Mesh=LodMesh'GrenadeM'
     bMeshEnviroMap=True
     Skin=Texture'JDomN0'
     //Physics=PHYS_Falling
     //RemoteRole=ROLE_None
}