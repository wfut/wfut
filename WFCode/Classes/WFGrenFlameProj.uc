class WFGrenFlameProj extends WFS_PCSGrenadeProj;

var() int TotalFlames;
var int NumFlames;

function GrenadeLanded()
{
	GotoState('GrenadeArmed');
}

state GrenadeArmed
{
	function BeginState()
	{
		NumFlames = 0;
		SetTimer(0.5, true);
	}

	function Timer()
	{
		local WFGrenFlameSpark s;
		local vector Dir;

		Dir.X = -1.0 + 2.0*FRand();
		Dir.Y = -1.0 + 2.0*FRand();
		Dir.Z = FRand();
		s = spawn(class'WFGrenFlameSpark',,, Location+vect(0,0,4), rotator(Dir));
		s.Instigator = Instigator;
		NumFlames++;
		if (NumFlames == TotalFlames)
		{
			SetTimer(0.0, false);
			spawn(class'ut_spriteballexplosion',,, Location+vect(0,0,16));
			Destroy();
		}
	}
}

defaultproperties
{
	bCanHitPlayers=False
	DetonationTime=0.0
	TotalFlames=20
	Mesh=LodMesh'Botpack.BioGelm'
	Skin=Texture'RedSkin2'
	Texture=Texture'RedSkin2'
	bMeshEnviroMap=True
	BounceDampening=0.500000
	Mass=25.000000
	bNetTemporary=False
}