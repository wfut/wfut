class WFGrenPlagueProj extends WFS_PCSGrenadeProj;

var() float PuffRate;
var() int NumPuffs;

var int PuffCount;

function GrenadeLanded()
{
	GotoState('ExpelGas');
}

state ExpelGas
{
	function BeginState()
	{
		SetTimer(PuffRate, true);
	}

	function Timer()
	{
		local rotator r;

		r = RotRand();
		r.Pitch = 0;

		spawn(class'WFGrenPlagueGasPuff',,, Location + vect(0,0,25), r);

		PuffCount++;
		if (PuffCount >= NumPuffs)
			Exploded();
	}
}

function Exploded()
{
	SetTimer(0.0, false);
	spawn(class'ut_GreenGelPuff',,,Location + vect(0,0,8));
	Destroy();
}

defaultproperties
{
     //Texture=Texture'Botpack.Jgreen'
     //Mesh=LodMesh'Botpack.BioGelm'
     Mesh=Mesh'WFPlagueGrenade'
     PuffRate=0.5
     NumPuffs=20
     bCanHitPlayers=False
     DetonationTime=0.0
     BounceDampening=0.5
     bNetTemporary=False
}