class WFGrenShockProj extends WFS_PCSGrenadeProj;

var WFTeslaChainParent ChainBeam;

var() int NumBeams;
var() float ExplodeTime;

function GrenadeLanded()
{
	if (ChainBeam == None)
	{
		ChainBeam = spawn(class'WFGrenShockBoltParent', self,, Location);
		ChainBeam.SetMaxBeams(NumBeams);
		ChainBeam.AmbientSound = Sound'PulseBolt';
		SetTimer(ExplodeTime, false);
	}
}

function Landed(vector HitNormall)
{
	if (ChainBeam == None)
	{
		ChainBeam = spawn(class'WFGrenShockBoltParent', self,, Location);
		ChainBeam.SetMaxBeams(NumBeams);
		ChainBeam.AmbientSound = Sound'PulseBolt';
		SetTimer(ExplodeTime, false);
	}
}

function Timer()
{
	if (ChainBeam != None)
		ChainBeam.Destroy();
	ServerExplosion(Location + vect(0,0,1)*16);
}

function ServerExplosion(vector HitLocation)
{
	BlowUp(HitLocation);
	if ( Level.NetMode != NM_DedicatedServer )
		spawn(class'Botpack.BlastMark',,,,rot(16384,0,0));
	spawn(class'ut_spriteballexplosion',,,hitlocation);

	Destroy();
}

defaultproperties
{
	bRandomSpin=True
	bNetTemporary=False
	bCanHitPlayers=False
	DetonationTime=0.000000
	ExplodeTime=3.0
	NumBeams=3
	Damage=40
	Mesh=LodMesh'Botpack.BioGelm'
	Skin=Texture'JDomN0'
	Texture=Texture'JDomN0'
	bMeshEnviroMap=True
	CollisionRadius=8.000000
	CollisionHeight=8.000000
	BounceDampening=0.5
	MyDamageType=ShockGrenade
}