class WFPLazerMedia extends WFMediaInfo;

#exec MESH IMPORT MESH=WFPlazer ANIVFILE=MODELS\PLazer_a.3d DATAFILE=MODELS\PLazer_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=WFPlazer X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=WFPlazer SEQ=All                      STARTFRAME=0 NUMFRAMES=90
#exec MESH SEQUENCE MESH=WFPlazer SEQ=idle                     STARTFRAME=0 NUMFRAMES=10
#exec MESH SEQUENCE MESH=WFPlazer SEQ=fire                     STARTFRAME=10 NUMFRAMES=20
#exec MESH SEQUENCE MESH=WFPlazer SEQ=turn                     STARTFRAME=30 NUMFRAMES=10
#exec MESH SEQUENCE MESH=WFPlazer SEQ=altfire                  STARTFRAME=40 NUMFRAMES=20
#exec MESH SEQUENCE MESH=WFPlazer SEQ=turnback                 STARTFRAME=60 NUMFRAMES=10
#exec MESH SEQUENCE MESH=WFPlazer SEQ=select                   STARTFRAME=70 NUMFRAMES=10
#exec MESH SEQUENCE MESH=WFPlazer SEQ=down	             STARTFRAME=80 NUMFRAMES=10

#exec MESHMAP NEW   MESHMAP=WFPlazer MESH=WFPlazer
#exec MESHMAP SCALE MESHMAP=WFPlazer X=0.1 Y=0.1 Z=0.2

#exec TEXTURE IMPORT NAME=JPLazer_01 FILE=Textures\Skins\PLazer_01.PCX GROUP=Skins FLAGS=2	//Material #26
#exec TEXTURE IMPORT NAME=JPLazer_02 FILE=Textures\Skins\PLazer_02.PCX GROUP=Skins FLAGS=2	//Material #27
#exec TEXTURE IMPORT NAME=JPLazer_03 FILE=Textures\Skins\PLazer_03.PCX GROUP=Skins FLAGS=2	//Material #28
#exec TEXTURE IMPORT NAME=IconLazer FILE=TEXTURES\HUD\IconLazer.PCX GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=UseLazer FILE=TEXTURES\HUD\UseLazer.PCX GROUP="Icons" MIPS=OFF

#exec MESHMAP SETTEXTURE MESHMAP=WFPlazer NUM=1 TEXTURE=JPLazer_01
#exec MESHMAP SETTEXTURE MESHMAP=WFPlazer NUM=2 TEXTURE=JPLazer_02
#exec MESHMAP SETTEXTURE MESHMAP=WFPlazer NUM=3 TEXTURE=JPLazer_03

#exec MESH NOTIFY MESH=WFPlazer SEQ=fire TIME=0.01 FUNCTION=TopBarrel
#exec MESH NOTIFY MESH=WFPlazer SEQ=fire TIME=0.50 FUNCTION=BottomBarrel

#exec AUDIO IMPORT FILE="Sounds\Plazer\Fire.WAV" NAME="PLazer_Fire01" GROUP="WFPlazer"
#exec AUDIO IMPORT FILE="Sounds\Plazer\AltFire.WAV" NAME="PLazer_AltFire01" GROUP="WFPlazer"

#exec OBJ LOAD FILE=textures\PLazer_Alt.utx PACKAGE=WFMedia.PLazer_Alt
#exec OBJ LOAD FILE=textures\PLazer_Pri.utx PACKAGE=WFMedia.PLazer_Pri
#exec OBJ LOAD FILE=textures\PLSpark_Anim.utx PACKAGE=WFMedia.PLSpark_Anim
