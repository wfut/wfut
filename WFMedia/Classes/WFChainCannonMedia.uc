class WFChainCannonMedia extends WFMeshImports;

//RightHandedView
#exec MESH IMPORT MESH=chainfirst ANIVFILE=MODELS\chainfirst_a.3d DATAFILE=MODELS\chainfirst_d.3d X=0 Y=0 Z=0 UNMIRROR=1 UNMIRRORTEX=4
#exec MESH ORIGIN MESH=chainfirst X=0 Y=0 Z=0 YAW=128

#exec MESH SEQUENCE MESH=chainfirst SEQ=All      STARTFRAME=0 NUMFRAMES=117
#exec MESH SEQUENCE MESH=chainfirst SEQ=spinup   STARTFRAME=0 NUMFRAMES=22
#exec MESH SEQUENCE MESH=chainfirst SEQ=spindown STARTFRAME=22 NUMFRAMES=32
#exec MESH SEQUENCE MESH=chainfirst SEQ=fire     STARTFRAME=54 NUMFRAMES=20
#exec MESH SEQUENCE MESH=chainfirst SEQ=down     STARTFRAME=74 NUMFRAMES=11
#exec MESH SEQUENCE MESH=chainfirst SEQ=select   STARTFRAME=85 NUMFRAMES=11
#exec MESH SEQUENCE MESH=chainfirst SEQ=spinidle STARTFRAME=96 NUMFRAMES=20
#exec MESH SEQUENCE MESH=chainfirst SEQ=still    STARTFRAME=116 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=Jchainfirst1 FILE=MODELS\chain_a.PCX GROUP=Skins FLAGS=2 // Material #25
#exec TEXTURE IMPORT NAME=Jchainfirst2 FILE=MODELS\chain_b.PCX GROUP=Skins PALETTE=Jchainfirst1 // Material #26
#exec TEXTURE IMPORT NAME=Jchainfirst3 FILE=MODELS\chain_c.PCX GROUP=Skins PALETTE=Jchainfirst1 // Material #27
#exec TEXTURE IMPORT NAME=Jchainfirst4 FILE=MODELS\chain_d.PCX GROUP=Skins PALETTE=Jchainfirst1 // Material #28

#exec MESHMAP NEW   MESHMAP=chainfirst MESH=chainfirst
#exec MESHMAP SCALE MESHMAP=chainfirst X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=chainfirst NUM=1 TEXTURE=Jchainfirst1
#exec MESHMAP SETTEXTURE MESHMAP=chainfirst NUM=2 TEXTURE=Jchainfirst2
#exec MESHMAP SETTEXTURE MESHMAP=chainfirst NUM=3 TEXTURE=Jchainfirst3
#exec MESHMAP SETTEXTURE MESHMAP=chainfirst NUM=4 TEXTURE=Jchainfirst4

//LeftHandedView
#exec MESH IMPORT MESH=chainfirstL ANIVFILE=MODELS\chainfirst_a.3d DATAFILE=MODELS\chainfirst_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=chainfirstL X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=chainfirstL SEQ=All      STARTFRAME=0 NUMFRAMES=117
#exec MESH SEQUENCE MESH=chainfirstL SEQ=spinup   STARTFRAME=0 NUMFRAMES=22
#exec MESH SEQUENCE MESH=chainfirstL SEQ=spindown STARTFRAME=22 NUMFRAMES=32
#exec MESH SEQUENCE MESH=chainfirstL SEQ=fire     STARTFRAME=54 NUMFRAMES=20
#exec MESH SEQUENCE MESH=chainfirstL SEQ=down     STARTFRAME=74 NUMFRAMES=11
#exec MESH SEQUENCE MESH=chainfirstL SEQ=select   STARTFRAME=85 NUMFRAMES=11
#exec MESH SEQUENCE MESH=chainfirstL SEQ=spinidle STARTFRAME=96 NUMFRAMES=20
#exec MESH SEQUENCE MESH=chainfirstL SEQ=still    STARTFRAME=116 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=JchainfirstL1 FILE=MODELS\chain_a.PCX GROUP=Skins FLAGS=2 // Material #25
#exec TEXTURE IMPORT NAME=JchainfirstL2 FILE=MODELS\chain_b.PCX GROUP=Skins PALETTE=JchainfirstL1 // Material #26
#exec TEXTURE IMPORT NAME=JchainfirstL3 FILE=MODELS\chain_c.PCX GROUP=Skins PALETTE=JchainfirstL1 // Material #27
#exec TEXTURE IMPORT NAME=JchainfirstL4 FILE=MODELS\chain_d.PCX GROUP=Skins PALETTE=JchainfirstL1 // Material #28

#exec MESHMAP NEW   MESHMAP=chainfirstL MESH=chainfirstL
#exec MESHMAP SCALE MESHMAP=chainfirstL X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=chainfirstL NUM=1 TEXTURE=JchainfirstL1
#exec MESHMAP SETTEXTURE MESHMAP=chainfirstL NUM=2 TEXTURE=JchainfirstL2
#exec MESHMAP SETTEXTURE MESHMAP=chainfirstL NUM=3 TEXTURE=JchainfirstL3
#exec MESHMAP SETTEXTURE MESHMAP=chainfirstL NUM=4 TEXTURE=JchainfirstL4

//thirdpersonview
#exec MESH IMPORT MESH=chainthird ANIVFILE=MODELS\chainthird_a.3d DATAFILE=MODELS\chainthird_d.3d X=0 Y=0 Z=0 UNMIRROR=1 UNMIRRORTEX=4
#exec MESH ORIGIN MESH=chainthird X=100 Y=10 Z=-10 Yaw=128

#exec MESH SEQUENCE MESH=chainthird SEQ=All        STARTFRAME=0 NUMFRAMES=21
#exec MESH SEQUENCE MESH=chainthird SEQ=still STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=chainthird SEQ=fire  STARTFRAME=1 NUMFRAMES=20

#exec TEXTURE IMPORT NAME=Jchainthird0 FILE=MODELS\chain_third.PCX GROUP=Skins FLAGS=2 // Skin

#exec MESHMAP NEW   MESHMAP=chainthird MESH=chainthird
#exec MESHMAP SCALE MESHMAP=chainthird X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=chainthird NUM=0 TEXTURE=Jchainthird0

//pickupview
#exec MESH IMPORT MESH=chainpick ANIVFILE=MODELS\chainthird_a.3d DATAFILE=MODELS\chainthird_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=chainpick X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=chainpick SEQ=All        STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=chainpick SEQ=still STARTFRAME=0 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=Jchainpick0 FILE=MODELS\chain_third.PCX GROUP=Skins FLAGS=2 // Skin

#exec MESHMAP NEW   MESHMAP=chainpick MESH=chainpick
#exec MESHMAP SCALE MESHMAP=chainpick X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=chainpick NUM=0 TEXTURE=Jchainpick0

#exec AUDIO IMPORT FILE="Sounds\ChainFire.Wav" NAME=Chainfire
#exec AUDIO IMPORT FILE="Sounds\Chainspin1.Wav" NAME=Chainspin
#exec AUDIO IMPORT FILE="Sounds\ChainSpinUp1.Wav" NAME=Cspinup
#exec AUDIO IMPORT FILE="Sounds\ChainSpinDown1.Wav" NAME=Cspindown
