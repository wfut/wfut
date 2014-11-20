class WFHealingDepotEffect extends Effects;

var texture TeamSkins[4];
var byte TeamLightHue[4];

function SetTeam(int NewTeam)
{
	Texture = TeamSkins[NewTeam];
	LightHue = TeamLightHue[NewTeam];
}

defaultproperties
{
	TeamSkins(0)=texture'RedSkin2'
	TeamSkins(1)=texture'BlueSkin2'
	TeamSkins(2)=Texture'UnrealShare.Belt_fx.ShieldBelt.NewGreen'
	TeamSkins(3)=texture'GoldSkin2'
	TeamLightHue(0)=0
	TeamLightHue(1)=170
	TeamLightHue(2)=80
	TeamLightHue(3)=32
	AmbientGlow=255
	bUnlit=True
	bMeshEnviroMap=True
	bFixedRotationDir=True
	RotationRate=(Yaw=5000)
	RemoteRole=ROLE_SimulatedProxy
	bNetTemporary=False
	DrawType=DT_Mesh
	Mesh=Mesh'crossymb'
	DrawScale=1.0
	AmbientGlow=255
	bUnlit=True
	Style=STY_Translucent
	Texture=Texture'Botpack.Skins.JDomN0'
	bCollideActors=False
	bBlockActors=False
	bBlockPlayers=False
	Physics=PHYS_Rotating
}