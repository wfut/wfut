class WFPBLauncherMesh extends WFMeshImports;

#exec MESH IMPORT MESH=pblauncher ANIVFILE=MODELS\pblauncher_a.3d DATAFILE=MODELS\pblauncher_d.3d X=0 Y=0 Z=0 UNMIRROR=1 UNMIRRORTEX=4
#exec MESH ORIGIN MESH=pblauncher X=0 Y=0 Z=0 yaw=128

#exec MESH SEQUENCE MESH=pblauncher SEQ=All    STARTFRAME=0 NUMFRAMES=42
#exec MESH SEQUENCE MESH=pblauncher SEQ=fire   STARTFRAME=0 NUMFRAMES=5
#exec MESH SEQUENCE MESH=pblauncher SEQ=fire2  STARTFRAME=5 NUMFRAMES=4
#exec MESH SEQUENCE MESH=pblauncher SEQ=down   STARTFRAME=9 NUMFRAMES=11
#exec MESH SEQUENCE MESH=pblauncher SEQ=select STARTFRAME=20 NUMFRAMES=21
#exec MESH SEQUENCE MESH=pblauncher SEQ=still  STARTFRAME=41 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=Jpblauncher1 FILE=MODELS\plauncher1.PCX GROUP=Skins FLAGS=2 // front
#exec TEXTURE IMPORT NAME=Jpblauncher2 FILE=MODELS\plauncher2.PCX GROUP=Skins PALETTE=Jpblauncher1 // top
#exec TEXTURE IMPORT NAME=Jpblauncher3 FILE=MODELS\plauncher3.PCX GROUP=Skins PALETTE=Jpblauncher1 // back
#exec TEXTURE IMPORT NAME=Jpblauncher4 FILE=MODELS\plauncher4.PCX GROUP=Skins PALETTE=Jpblauncher1 // bottom
//#exec TEXTURE IMPORT NAME=Jpblauncher5 FILE=MODELS\plauncher5.PCX GROUP=Skins PALETTE=Jpblauncher1 // LED

#exec MESHMAP NEW   MESHMAP=pblauncher MESH=pblauncher
#exec MESHMAP SCALE MESHMAP=pblauncher X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=pblauncher NUM=1 TEXTURE=Jpblauncher1
#exec MESHMAP SETTEXTURE MESHMAP=pblauncher NUM=2 TEXTURE=Jpblauncher2
#exec MESHMAP SETTEXTURE MESHMAP=pblauncher NUM=3 TEXTURE=Jpblauncher3
#exec MESHMAP SETTEXTURE MESHMAP=pblauncher NUM=4 TEXTURE=Jpblauncher4
//#exec MESHMAP SETTEXTURE MESHMAP=pblauncher NUM=5 TEXTURE=Jpblauncher5
#exec MESHMAP SETTEXTURE MESHMAP=pblauncher NUM=5 TEXTURE=Botpack.Ammocount.MiniAmmoled


//third person view

#exec MESH IMPORT MESH=plthird1 ANIVFILE=MODELS\plthird_a.3d DATAFILE=MODELS\plthird_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=plthird1 X=-168 Y=0 Z=-34

#exec MESH SEQUENCE MESH=plthird1 SEQ=All     STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=plthird1 SEQ=plthird STARTFRAME=0 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=Jplthird10 FILE=MODELS\plthird0.PCX GROUP=Skins FLAGS=2 // SKIN

#exec MESHMAP NEW   MESHMAP=plthird1 MESH=plthird
#exec MESHMAP SCALE MESHMAP=plthird1 X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=plthird1 NUM=0 TEXTURE=Jplthird10

defaultproperties
{
}