//=============================================================================
// WF_FraggrenadeMesh.
//=============================================================================
class WF_FraggrenadeMesh extends ut_Decoration;

#exec MESH IMPORT MESH=WF_Fraggrenade ANIVFILE=MODELS\WF_Fraggrenade_a.3d DATAFILE=MODELS\WF_Fraggrenade_d.3d X=0 Y=0 Z=0 MLOD=0
#exec MESH ORIGIN MESH=WF_Fraggrenade X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=WF_Fraggrenade SEQ=All         STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=WF_Fraggrenade SEQ=fraggrenade STARTFRAME=0 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=JWF_Fraggrenade0 FILE=MODELS\frag.PCX GROUP=Skins FLAGS=2 // skin

#exec MESHMAP NEW   MESHMAP=WF_Fraggrenade MESH=WF_Fraggrenade
#exec MESHMAP SCALE MESHMAP=WF_Fraggrenade X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=WF_Fraggrenade NUM=0 TEXTURE=JWF_Fraggrenade0

defaultproperties
{
    DrawType=DT_Mesh
    Mesh=Mesh'WF_Fraggrenade'
}
