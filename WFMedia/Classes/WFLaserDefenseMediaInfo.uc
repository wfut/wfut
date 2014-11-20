class WFLaserDefenseMediaInfo expands WFMediaInfo;

// mesh
#exec MESH IMPORT MESH=laserd ANIVFILE=MODELS\laserd_a.3d DATAFILE=MODELS\laserd_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=laserd X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=laserd SEQ=All    STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=laserd SEQ=laserD STARTFRAME=0 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=Jlaserd0 FILE=MODELS\laserd0.PCX GROUP=Skins FLAGS=2 // Skin

#exec MESHMAP NEW   MESHMAP=laserd MESH=laserd
#exec MESHMAP SCALE MESHMAP=laserd X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=laserd NUM=0 TEXTURE=Jlaserd0

// beam skins
#exec TEXTURE IMPORT NAME=BeamRedTex FILE=TEXTURES\Tripmine\BeamRed.PCX
#exec TEXTURE IMPORT NAME=BeamBlueTex FILE=TEXTURES\Tripmine\BeamBlue.PCX
#exec TEXTURE IMPORT NAME=BeamGreenTex FILE=TEXTURES\Tripmine\BeamGreen.PCX
#exec TEXTURE IMPORT NAME=BeamYellowTex FILE=TEXTURES\Tripmine\BeamYellow.PCX
#exec TEXTURE IMPORT NAME=BeamWhiteTex FILE=TEXTURES\Tripmine\BeamWhite.PCX