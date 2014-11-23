class WFMedkitMesh extends WFMeshImports;

/*
FireTexture'UnrealShare.SEffect1.Smoke1'
FireTexture'UnrealShare.Effect3.fireeffect3'
FireTexture'UnrealShare.Belt_fx.UDamageFX'
FireTexture'UnrealShare.Belt_fx.ShieldBelt.BlueShield'
FireTexture'UnrealI.Effect10.fireeffect10'
*/

// heal effect textures
#exec TEXTURE IMPORT NAME=ShockTexRed FILE=Textures\MedKit\Shockwave_red.PCX GROUP="Skins"
#exec TEXTURE IMPORT NAME=ShockTexBlue FILE=Textures\MedKit\Shockwave_blue.PCX GROUP="Skins"

// mesh
#exec MESH IMPORT MESH=medkitleft ANIVFILE=MODELS\medkit_a.3d DATAFILE=MODELS\medkit_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=medkitleft X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=medkitleft SEQ=All       STARTFRAME=0 NUMFRAMES=35
#exec MESH SEQUENCE MESH=medkitleft SEQ=heal      STARTFRAME=0 NUMFRAMES=7
#exec MESH SEQUENCE MESH=medkitleft SEQ=vaccinate STARTFRAME=7 NUMFRAMES=5
#exec MESH SEQUENCE MESH=medkitleft SEQ=down      STARTFRAME=12 NUMFRAMES=11
#exec MESH SEQUENCE MESH=medkitleft SEQ=select    STARTFRAME=23 NUMFRAMES=11
#exec MESH SEQUENCE MESH=medkitleft SEQ=still     STARTFRAME=34 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=Jmedkitleft1 FILE=MODELS\medkit1.PCX GROUP=Skins FLAGS=2 // SIDES
#exec TEXTURE IMPORT NAME=Jmedkitleft2 FILE=MODELS\medkit2.PCX GROUP=Skins PALETTE=Jmedkitleft1 // TOP_BOTTOM
#exec TEXTURE IMPORT NAME=Jmedkitleft3 FILE=MODELS\medkit3.PCX GROUP=Skins PALETTE=Jmedkitleft1 // FRONT
#exec OBJ LOAD FILE=..\Textures\UT_ArtFX.utx PACKAGE=UT_ArtFX




#exec MESHMAP NEW   MESHMAP=medkitleft MESH=medkitleft
#exec MESHMAP SCALE MESHMAP=medkitleft X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=medkitleft NUM=1 TEXTURE=Jmedkitleft1
#exec MESHMAP SETTEXTURE MESHMAP=medkitleft NUM=2 TEXTURE=Jmedkitleft2
#exec MESHMAP SETTEXTURE MESHMAP=medkitleft NUM=3 TEXTURE=Jmedkitleft3
#exec MESHMAP SETTEXTURE MESHMAP=medkitleft NUM=4 TEXTURE=UT_ArtFX.BetaBump
//#exec MESHMAP SETTEXTURE MESHMAP=medkitleft NUM=4 TEXTURE=UnrealShare.top3


//righthand view
#exec MESH IMPORT MESH=medkit ANIVFILE=MODELS\medkit_a.3d DATAFILE=MODELS\medkit_d.3d X=0 Y=0 Z=0 UNMIRROR=1 UNMIRRORTEX=4
#exec MESH ORIGIN MESH=medkit X=0 Y=0 Z=0 YAW=128

#exec MESH SEQUENCE MESH=medkit SEQ=All       STARTFRAME=0 NUMFRAMES=35
#exec MESH SEQUENCE MESH=medkit SEQ=heal      STARTFRAME=0 NUMFRAMES=7
#exec MESH SEQUENCE MESH=medkit SEQ=vaccinate STARTFRAME=7 NUMFRAMES=5
#exec MESH SEQUENCE MESH=medkit SEQ=down      STARTFRAME=12 NUMFRAMES=11
#exec MESH SEQUENCE MESH=medkit SEQ=select    STARTFRAME=23 NUMFRAMES=11
#exec MESH SEQUENCE MESH=medkit SEQ=still     STARTFRAME=34 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=Jmedkit1 FILE=MODELS\medkit1.PCX GROUP=Skins FLAGS=2 // SIDES
#exec TEXTURE IMPORT NAME=Jmedkit2 FILE=MODELS\medkit2.PCX GROUP=Skins PALETTE=Jmedkit1 // TOP_BOTTOM
#exec TEXTURE IMPORT NAME=Jmedkit3 FILE=MODELS\medkit3.PCX GROUP=Skins PALETTE=Jmedkit1 // FRONT



#exec MESHMAP NEW   MESHMAP=medkit MESH=medkit
#exec MESHMAP SCALE MESHMAP=medkit X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=medkit NUM=1 TEXTURE=Jmedkit1
#exec MESHMAP SETTEXTURE MESHMAP=medkit NUM=2 TEXTURE=Jmedkit2
#exec MESHMAP SETTEXTURE MESHMAP=medkit NUM=3 TEXTURE=Jmedkit3
#exec MESHMAP SETTEXTURE MESHMAP=medkit NUM=4 TEXTURE=UT_ArtFX.BetaBump
//#exec MESHMAP SETTEXTURE MESHMAP=medkit NUM=4 TEXTURE=UnrealShare.top3

//thirdperson
#exec MESH IMPORT MESH=medthird ANIVFILE=MODELS\medthird_a.3d DATAFILE=MODELS\medthird_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=medthird X=-160 Y=0 Z=-50

#exec MESH SEQUENCE MESH=medthird SEQ=All      STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=medthird SEQ=medthird STARTFRAME=0 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=Jmedthird1 FILE=MODELS\med3rd.PCX GROUP=Skins FLAGS=2 // BODY
#exec OBJ LOAD FILE=..\Textures\UT_ArtFX.utx PACKAGE=UT_ArtFX

#exec MESHMAP NEW   MESHMAP=medthird MESH=medthird
#exec MESHMAP SCALE MESHMAP=medthird X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=medthird NUM=1 TEXTURE=Jmedthird1
#exec MESHMAP SETTEXTURE MESHMAP=medthird NUM=2 TEXTURE=UT_ArtFX.BetaBump
//#exec MESHMAP SETTEXTURE MESHMAP=medthird NUM=2 TEXTURE=UnrealShare.top3

