//=============================================================================
// WF_BackpackMesh.
//=============================================================================
class WF_BackpackMesh extends WFMeshImports;

#exec MESH IMPORT MESH=WF_Backpack ANIVFILE=MODELS\WF_Backpack_a.3d DATAFILE=MODELS\WF_Backpack_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=WF_Backpack X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=WF_Backpack SEQ=All      STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=WF_Backpack SEQ=backpack STARTFRAME=0 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=JWF_Backpack0 FILE=MODELS\WF_Backpack0.PCX GROUP=Skins FLAGS=2 // skin

#exec MESHMAP NEW   MESHMAP=WF_Backpack MESH=WF_Backpack
#exec MESHMAP SCALE MESHMAP=WF_Backpack X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=WF_Backpack NUM=0 TEXTURE=JWF_Backpack0

// supply pack skin
#exec TEXTURE IMPORT NAME=WF_SupplyPackSkin FILE=Textures\Skins\WF_SupplyPack.PCX GROUP=Skins FLAGS=2 // skin

defaultproperties
{
    Drawscale=0.90
    DrawType=DT_Mesh
    Mesh=LodMesh'WF_Backpack'
}
