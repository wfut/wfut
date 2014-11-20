class WFGrenEMPProj extends WFS_PCSGrenadeProj;

simulated function Explosion(vector HitLocation)
{
	local shockexplo s;

	BlowUp(HitLocation);
	if ( Level.NetMode != NM_DedicatedServer )
			spawn(class'Botpack.BlastMark',,,,rot(16384,0,0));
	S = spawn(class'shockexplo',,,hitlocation);
	s.RemoteRole = ROLE_None;

	spawn(class'WFGrenEMPWave',,,HitLocation);

	GotoState('Exploded');
}

function BlowUp(vector HitLocation)
{
	MakeNoise(1.0);
}

defaultproperties
{
	Mass=25.000000
	LifeSpan=0.000000
	DetonationTime=5.000000
	BounceDampening=0.500000
	CollisionRadius=4.000000
	CollisionHeight=4.000000
	Mesh=Mesh'WF_FragGrenade'
	Skin=Texture'BlueSkin2'
	Texture=Texture'BlueSkin2'
	bMeshEnviroMap=True
	DrawScale=0.800000
	bRandomSpin=True
	BounceDampening=0.5
	bCanHitPlayers=False
}