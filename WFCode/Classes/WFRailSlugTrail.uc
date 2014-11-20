class WFRailSlugTrail extends Effects;

defaultproperties
{
	RemoteRole=ROLE_None
	//Mesh=LodMesh'Botpack.MiniTrace'
	Mesh=LodMesh'Bolt1'
	//Mesh=LodMesh'muzzEF3'
	bUnlit=True
	//bParticles=True
	//Texture=Texture'EMuz1'
	MultiSkins(1)=Texture'JUT_Tracer_01'
	DrawScale=4.0
	DrawType=DT_Mesh
	Style=STY_Translucent
	Physics=PHYS_Trailer
	bTrailerSameRotation=True
	//bTrailerPrePivot=True
	//PrePivot=(X=0.0)
}