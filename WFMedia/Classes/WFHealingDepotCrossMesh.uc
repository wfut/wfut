//=============================================================================
// crossymb.
//=============================================================================
class WFHealingDepotCrossMesh expands WFMeshImports;

#exec MESH IMPORT MESH=crossymb ANIVFILE=MODELS\crossymb_a.3d DATAFILE=MODELS\crossymb_d.3d X=0 Y=0 Z=0 MLOD=0
#exec MESH ORIGIN MESH=crossymb X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=crossymb SEQ=All   STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=crossymb SEQ=cross STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=crossymb MESH=crossymb
#exec MESHMAP SCALE MESHMAP=crossymb X=0.1 Y=0.1 Z=0.2


defaultproperties
{
    DrawType=DT_Mesh
    Mesh=crossymb
}
