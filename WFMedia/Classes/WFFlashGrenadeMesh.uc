//=============================================================================
// WFFlashGrenadeMesh.
//=============================================================================
class WFFlashGrenadeMesh extends WFMeshImports;

#exec MESH IMPORT MESH=Flashgren ANIVFILE=MODELS\Flashgren_a.3d DATAFILE=MODELS\Flashgren_d.3d X=0 Y=0 Z=0 MLOD=0
#exec MESH ORIGIN MESH=Flashgren X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=Flashgren SEQ=All       STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=Flashgren SEQ=FLASHGREN STARTFRAME=0 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=JFlashgren1 FILE=MODELS\Flashgren.PCX GROUP=Skins FLAGS=2 // Skin

#exec MESHMAP NEW   MESHMAP=Flashgren MESH=Flashgren
#exec MESHMAP SCALE MESHMAP=Flashgren X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=Flashgren NUM=1 TEXTURE=JFlashgren1

defaultproperties
{
    DrawType=DT_Mesh
    Drawscale=.1
    Mesh=Flashgren
}
