//=============================================================================
// WFRocketMesh.
//=============================================================================
class WFRocketMesh extends WFMeshImports;

#exec MESH IMPORT MESH=WF_Rocket ANIVFILE=MODELS\WFRocket_a.3d DATAFILE=MODELS\WFRocket_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=WF_Rocket X=-100 Y=0 Z=0

#exec MESH SEQUENCE MESH=WF_Rocket SEQ=All   STARTFRAME=0 NUMFRAMES=2
#exec MESH SEQUENCE MESH=WF_Rocket SEQ=still STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=WF_Rocket SEQ=wing  STARTFRAME=1 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=JWFRocket0 FILE=MODELS\WFRocket0.PCX GROUP=Skins FLAGS=2 // Skin

#exec MESHMAP NEW   MESHMAP=WF_Rocket MESH=WF_Rocket
#exec MESHMAP SCALE MESHMAP=WF_Rocket X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=WF_Rocket NUM=0 TEXTURE=JWFRocket0

// napalm rocket mesh
#exec TEXTURE IMPORT NAME=JWFRocket1 FILE=MODELS\WFRocket1.PCX GROUP=Skins FLAGS=2 // Skin