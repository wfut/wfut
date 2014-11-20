class WFStatusVaccinatedFX extends Effects;

simulated function PostBeginPlay()
{
	LoopAnim('All', 1.0, 0.0);
}

defaultproperties
{
	Physics=PHYS_Trailer
	bTrailerSameRotation=True
	LODBias=0.000000
	//Texture=Texture'Botpack.Skins.MuzzyFlak'
	Texture=Texture'Botpack.FlareFX.utflare6'
	DrawScale=0.2
	bParticles=True
	bNetTemporary=False
	Style=STY_Translucent
	RemoteRole=ROLE_SimulatedProxy
	//RemoteRole=ROLE_None
	//bNetOptional=True
	DrawType=DT_Mesh
	Mesh=LodMesh'Botpack.Tele2'
	//Mesh=LodMesh'vaccine'
	//Mesh=LodMesh'vaccine3'
	bOwnerNoSee=True
	bUnlit=True
}