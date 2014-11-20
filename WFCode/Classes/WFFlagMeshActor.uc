class WFFlagMeshActor extends MeshActor;

var WFFlagTexturePreviewClient WFNotifyClient;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	LoopAnim('pflag');
}

function AnimEnd()
{
	WFNotifyClient.AnimEnd(self);
}

defaultproperties
{
     bHidden=False
     bOnlyOwnerSee=True
     bAlwaysTick=True
     Physics=PHYS_Rotating
     RemoteRole=ROLE_None
     DrawType=DT_Mesh
     Mesh=LodMesh'Botpack.pflag'
     Skin=Texture'Botpack.Skins.JpflagR'
     DrawScale=0.050000
     AmbientGlow=255
     bUnlit=True
     CollisionRadius=0.000000
     CollisionHeight=0.000000
}
