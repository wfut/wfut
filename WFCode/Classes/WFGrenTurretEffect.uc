//=============================================================================
// WFGrenTurretEffect.
//=============================================================================
class WFGrenTurretEffect extends Effects;

defaultproperties
{
     bAnimByOwner=True
     bOwnerNoSee=True
     bNetTemporary=False
     bTrailerSameRotation=True
     Physics=PHYS_Trailer
     RemoteRole=ROLE_SimulatedProxy
     DrawType=DT_Mesh
     Style=STY_Translucent
     Texture=FireTexture'UnrealShare.Belt_fx.ShieldBelt.N_Shield'
     ScaleGlow=0.500000
     AmbientGlow=64
     Fatness=157
     bUnlit=True
     bMeshEnviroMap=True
}
