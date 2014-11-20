class WFIceEffect extends Effects;

#exec OBJ LOAD FILE=..\Textures\TCrystal.utx

function InitFor(actor Other)
{
	Mesh = Other.Mesh;
	DrawScale = Other.DrawScale;
	PrePivot = Other.PrePivot;
	Skin = texture'taryd2';
	Texture = texture'taryd2';
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
	bAnimByOwner=true
	bOwnerNoSee=True
	bNetTemporary=False
	bTrailerSameRotation=True
	Physics=PHYS_Trailer
	Style=STY_Translucent
	DrawType=DT_Mesh
	Fatness=157
	bUnlit=True
	bMeshEnviroMap=True
}