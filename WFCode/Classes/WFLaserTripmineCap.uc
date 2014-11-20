class WFLaserTripmineCap expands Decoration;

defaultproperties
{
	//Mesh=LodMesh'Botpack.BioGelm'
	Mesh=LodMesh'UnrealShare.TarydiumProjectile'
	//Mesh=LodMesh'tripmineend'
	Skin=Texture'JDomN0'
	Texture=Texture'JDomN0'
	bMeshEnviroMap=True
	DrawScale=0.75
	RemoteRole=ROLE_None
	Physics=PHYS_Rotating
	bStatic=false
	DrawType=DT_Mesh
	bFixedRotationDir=true
	Rotation=(Pitch=8,Yaw=8,Roll=8)
	//RotationRate=(Pitch=9800,Yaw=4000,Roll=2000)
	RotationRate=(Roll=5000)
}