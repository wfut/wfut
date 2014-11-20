class WFWallGrenadeProj extends WFS_PCSWallGrenadeProj;

simulated function SetupInitialRotation(vector HitNormal)
{
	SetRotation(rotator(HitNormal));
}

defaultproperties
{
	Damage=150
	DetonationTime=15.000000
	Mesh=LodMesh'DampenerM'
	DrawScale=0.500000
}