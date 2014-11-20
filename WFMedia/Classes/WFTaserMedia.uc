class WFTaserMedia extends WFMediaInfo;

//playerview

#exec MESH IMPORT MESH=inftaser ANIVFILE=MODELS\inftaser_a.3d DATAFILE=MODELS\inftaser_d.3d X=0 Y=0 Z=0 UNMIRROR=1 UNMIRRORTEX=4
#exec MESH ORIGIN MESH=inftaser X=0 Y=0 Z=0 roll=10 yaw=128

#exec MESH SEQUENCE MESH=inftaser SEQ=All      STARTFRAME=0 NUMFRAMES=99
#exec MESH SEQUENCE MESH=inftaser SEQ=fire1    STARTFRAME=0 NUMFRAMES=5
#exec MESH SEQUENCE MESH=inftaser SEQ=fire2    STARTFRAME=5 NUMFRAMES=11
#exec MESH SEQUENCE MESH=inftaser SEQ=walking  STARTFRAME=16 NUMFRAMES=27
#exec MESH SEQUENCE MESH=inftaser SEQ=recharge STARTFRAME=43 NUMFRAMES=19
#exec MESH SEQUENCE MESH=inftaser SEQ=select   STARTFRAME=62 NUMFRAMES=25
#exec MESH SEQUENCE MESH=inftaser SEQ=still    STARTFRAME=87 NUMFRAMES=1
#exec MESH SEQUENCE MESH=inftaser SEQ=down     STARTFRAME=88 NUMFRAMES=11

#exec TEXTURE IMPORT NAME=Jinftaser1 FILE=MODELS\inftaser1.PCX GROUP=Skins FLAGS=2 // Material #25
#exec TEXTURE IMPORT NAME=Jinftaser2 FILE=MODELS\inftaser2.PCX GROUP=Skins PALETTE=Jinftaser1 // Material #26
#exec TEXTURE IMPORT NAME=Jinftaser3 FILE=MODELS\inftaser3.PCX GROUP=Skins PALETTE=Jinftaser1 // Material #27
#exec TEXTURE IMPORT NAME=Jinftaser4 FILE=MODELS\inftaser4.PCX GROUP=Skins PALETTE=Jinftaser1 // Material #28

#exec MESHMAP NEW   MESHMAP=inftaser MESH=inftaser
#exec MESHMAP SCALE MESHMAP=inftaser X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=inftaser NUM=1 TEXTURE=Jinftaser1
#exec MESHMAP SETTEXTURE MESHMAP=inftaser NUM=2 TEXTURE=Jinftaser2
#exec MESHMAP SETTEXTURE MESHMAP=inftaser NUM=3 TEXTURE=Jinftaser3
#exec MESHMAP SETTEXTURE MESHMAP=inftaser NUM=4 TEXTURE=Jinftaser4

//pickupview

#exec MESH IMPORT MESH=taserpick ANIVFILE=MODELS\taser3rd_a.3d DATAFILE=MODELS\taser3rd_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=taserpick X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=taserpick SEQ=All      STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=taserpick SEQ=taserpick STARTFRAME=0 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=Jtaserpick0 FILE=MODELS\taser3rd0.PCX GROUP=Skins FLAGS=2 // SKIN

#exec MESHMAP NEW   MESHMAP=taserpick MESH=taserpick
#exec MESHMAP SCALE MESHMAP=taserpick X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=taserpick NUM=0 TEXTURE=Jtaserpick0

//thirdpersonview
#exec MESH IMPORT MESH=taser3rd ANIVFILE=MODELS\taser3rd_a.3d DATAFILE=MODELS\taser3rd_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=taser3rd X=-30 Y=-28 Z=-10

#exec MESH SEQUENCE MESH=taser3rd SEQ=All      STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=taser3rd SEQ=taser3rd STARTFRAME=0 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=Jtaser3rd0 FILE=MODELS\taser3rd0.PCX GROUP=Skins FLAGS=2 // SKIN

#exec MESHMAP NEW   MESHMAP=taser3rd MESH=taser3rd
#exec MESHMAP SCALE MESHMAP=taser3rd X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=taser3rd NUM=0 TEXTURE=Jtaser3rd0

#exec AUDIO IMPORT FILE=Sounds\taser\taseralt.WAV NAME="taseralt" GROUP="Taser"
#exec AUDIO IMPORT FILE=Sounds\taser\taserprime.WAV NAME="taserprime" GROUP="Taser"
#exec AUDIO IMPORT FILE=Sounds\taser\recharge.WAV NAME="recharge" GROUP="Taser"
