//=============================================================================
// WFInstagibMineMesh.
//=============================================================================
class WFInstagibMineMesh extends ut_Decoration;

#exec MESH IMPORT MESH=WFInstagibMine ANIVFILE=MODELS\WFInstagibMine_a.3d DATAFILE=MODELS\WFInstagibMine_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=WFInstagibMine X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=WFInstagibMine SEQ=All    STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=WFInstagibMine SEQ=InstaD STARTFRAME=0 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=JWFInstagibMine0 FILE=MODELS\InstaD0.PCX GROUP=Skins FLAGS=2 // Skin

#exec MESHMAP NEW   MESHMAP=WFInstagibMine MESH=WFInstagibMine
#exec MESHMAP SCALE MESHMAP=WFInstagibMine X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=WFInstagibMine NUM=0 TEXTURE=JWFInstagibMine0

defaultproperties
{
    DrawType=DT_Mesh
    Mesh=WFInstagibMine
}
