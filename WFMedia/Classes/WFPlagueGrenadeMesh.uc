//=============================================================================
// WFPlagueGrenadeMesh.
//=============================================================================
class WFPlagueGrenadeMesh extends WFMeshImports;

#exec MESH IMPORT MESH=WFPlagueGrenade ANIVFILE=MODELS\WFPlagueGrenade_a.3d DATAFILE=MODELS\WFPlagueGrenade_d.3d X=0 Y=0 Z=0 UNMIRROR=1 UNMIRRORTEX=4
#exec MESH ORIGIN MESH=WFPlagueGrenade X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=WFPlagueGrenade SEQ=All     STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=WFPlagueGrenade SEQ=gasgren STARTFRAME=0 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=JWFPlagueGrenade0 FILE=MODELS\gasgren2.PCX GROUP=Skins FLAGS=2 // Skin

#exec MESHMAP NEW   MESHMAP=WFPlagueGrenade MESH=WFPlagueGrenade
#exec MESHMAP SCALE MESHMAP=WFPlagueGrenade X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=WFPlagueGrenade NUM=0 TEXTURE=JWFPlagueGrenade0

defaultproperties
{
    DrawType=DT_Mesh
    Mesh=WFPlagueGrenade
}
