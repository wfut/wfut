//=============================================================================
// WF_AlarmMesh.
//=============================================================================
class WF_AlarmMesh expands WFMeshImports;

#exec MESH IMPORT MESH=WF_Alarm ANIVFILE=MODELS\WF_Alarm_a.3d DATAFILE=MODELS\WF_Alarm_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=WF_Alarm X=0 Y=0 Z=0 YAW=64

#exec MESH SEQUENCE MESH=WF_Alarm SEQ=All    STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=WF_Alarm SEQ=alarm1 STARTFRAME=0 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=JWF_Alarm0 FILE=MODELS\WF_Alarm0.PCX GROUP=Skins FLAGS=2 // Skin

#exec MESHMAP NEW   MESHMAP=WF_Alarm MESH=WF_Alarm
#exec MESHMAP SCALE MESHMAP=WF_Alarm X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=WF_Alarm NUM=0 TEXTURE=JWF_Alarm0

defaultproperties
{
    DrawType=DT_Mesh
    Mesh=LodMesh'WF_Alarm'
}
