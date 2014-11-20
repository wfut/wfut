class WFRLMesh extends WFMeshImports;

//righthandedview

#exec MESH IMPORT MESH=rocketlauncher ANIVFILE=MODELS\rocketlauncher_a.3d DATAFILE=MODELS\rocketlauncher_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=rocketlauncher X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=rocketlauncher SEQ=All    STARTFRAME=0 NUMFRAMES=32
#exec MESH SEQUENCE MESH=rocketlauncher SEQ=fire   STARTFRAME=0 NUMFRAMES=9
#exec MESH SEQUENCE MESH=rocketlauncher SEQ=down   STARTFRAME=9 NUMFRAMES=11
#exec MESH SEQUENCE MESH=rocketlauncher SEQ=select STARTFRAME=20 NUMFRAMES=11
#exec MESH SEQUENCE MESH=rocketlauncher SEQ=still  STARTFRAME=31 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=Jrocketlauncher1 FILE=MODELS\rocketlauncher1.PCX GROUP=Skins FLAGS=2 // Material #25
#exec TEXTURE IMPORT NAME=Jrocketlauncher2 FILE=MODELS\rocketlauncher2.PCX GROUP=Skins PALETTE=Jrocketlauncher1 // Material #26
#exec TEXTURE IMPORT NAME=Jrocketlauncher3 FILE=MODELS\rocketlauncher3.PCX GROUP=Skins PALETTE=Jrocketlauncher1 // Material #27
#exec TEXTURE IMPORT NAME=Jrocketlauncher4 FILE=MODELS\rocketlauncher4.PCX GROUP=Skins PALETTE=Jrocketlauncher1 // Material #28

#exec MESHMAP NEW   MESHMAP=rocketlauncher MESH=rocketlauncher
#exec MESHMAP SCALE MESHMAP=rocketlauncher X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=rocketlauncher NUM=1 TEXTURE=Jrocketlauncher1
#exec MESHMAP SETTEXTURE MESHMAP=rocketlauncher NUM=2 TEXTURE=Jrocketlauncher2
#exec MESHMAP SETTEXTURE MESHMAP=rocketlauncher NUM=3 TEXTURE=Jrocketlauncher3
#exec MESHMAP SETTEXTURE MESHMAP=rocketlauncher NUM=4 TEXTURE=Jrocketlauncher4

//thirdperson

#exec MESH IMPORT MESH=rlthird ANIVFILE=MODELS\rlthird_a.3d DATAFILE=MODELS\rlthird_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=rlthird X=-160 Y=0 Z=-20

#exec MESH SEQUENCE MESH=rlthird SEQ=All   STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=rlthird SEQ=rl3rd STARTFRAME=0 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=Jrlthird0 FILE=MODELS\rlthird0.PCX GROUP=Skins FLAGS=2 // SKIN

#exec MESHMAP NEW   MESHMAP=rlthird MESH=rlthird
#exec MESHMAP SCALE MESHMAP=rlthird X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=rlthird NUM=0 TEXTURE=Jrlthird0

