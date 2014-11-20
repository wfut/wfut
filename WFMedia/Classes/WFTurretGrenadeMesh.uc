//=============================================================================
// WFTurretGrenadeMesh.
//=============================================================================
class WFTurretGrenadeMesh expands WFMeshImports;

#exec MESH IMPORT MESH=WF_Turretgr ANIVFILE=MODELS\WFTurretgr_a.3d DATAFILE=MODELS\WFTurretgr_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=WF_Turretgr X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=WF_Turretgr SEQ=All        STARTFRAME=0 NUMFRAMES=98
#exec MESH SEQUENCE MESH=WF_Turretgr SEQ=WFTurbob   STARTFRAME=0 NUMFRAMES=97
#exec MESH SEQUENCE MESH=WF_Turretgr SEQ=WFTurStill STARTFRAME=97 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=JWFTurretgr0 FILE=MODELS\WFTurretgr0.PCX GROUP=Skins FLAGS=2 // skin

#exec MESHMAP NEW   MESHMAP=WF_Turretgr MESH=WF_Turretgr
#exec MESHMAP SCALE MESHMAP=WF_Turretgr X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=WF_Turretgr NUM=0 TEXTURE=JWFTurretgr0

defaultproperties
{
    DrawType=DT_Mesh
    Mesh=WF_Turretgr
}
