//=============================================================================
// WF_DepotMesh.
//=============================================================================
class WF_DepotMesh extends WFMeshImports;

#exec MESH IMPORT MESH=WF_Depot ANIVFILE=MODELS\WFDepot_a.3d DATAFILE=MODELS\WFDepot_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=WF_Depot X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=WF_Depot SEQ=All   STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=WF_Depot SEQ=depot STARTFRAME=0 NUMFRAMES=1

// main body of depot
#exec TEXTURE IMPORT NAME=JWFDepot1 FILE=MODELS\WFDepot1.PCX GROUP=Skins FLAGS=2

// fire engine texture
#exec TEXTURE IMPORT NAME=JWFDepot2 FILE=MODELS\WFDepot2.PCX GROUP=Skins PALETTE=JWFDepot1

// poly under fire engine texture that is not being used
#exec TEXTURE IMPORT NAME=JWFDepot3 FILE=MODELS\WFDepot3.PCX GROUP=Skins PALETTE=JWFDepot1

//fire engine texture of course
//#exec OBJ LOAD FILE=Textures\ShaneFx.utx  PACKAGE=Botpack.ShaneFx

#exec MESHMAP NEW   MESHMAP=WF_Depot MESH=WF_Depot
#exec MESHMAP SCALE MESHMAP=WF_Depot X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=WF_Depot NUM=1 TEXTURE=JWFDepot1
#exec MESHMAP SETTEXTURE MESHMAP=WF_Depot NUM=2 TEXTURE=Botpack.ShaneFx.top3
#exec MESHMAP SETTEXTURE MESHMAP=WF_Depot NUM=3 TEXTURE=JWFDepot3

// depot team skins
#exec TEXTURE IMPORT NAME=WF_SupplyDepotRed FILE=MODELS\depot_red.PCX GROUP=Skins FLAGS=2 // Skin
#exec TEXTURE IMPORT NAME=WF_SupplyDepotBlue FILE=MODELS\depot_blue.PCX GROUP=Skins FLAGS=2 // Skin
#exec TEXTURE IMPORT NAME=WF_SupplyDepotGreen FILE=MODELS\depot_green.PCX GROUP=Skins FLAGS=2 // Skin
#exec TEXTURE IMPORT NAME=WF_SupplyDepotYellow FILE=MODELS\depot_yellow.PCX GROUP=Skins FLAGS=2 // Skin

// depot fire texture team skins
#exec OBJ LOAD FILE=Textures\DepotSkins\rdepot.utx PACKAGE=WFMedia.RDepot
#exec OBJ LOAD FILE=Textures\DepotSkins\gdepot.utx PACKAGE=WFMedia.GDepot
#exec OBJ LOAD FILE=Textures\DepotSkins\ydepot.utx PACKAGE=WFMedia.YDepot

// healing depot team skins
#exec TEXTURE IMPORT NAME=WF_HDepotBodyRed FILE=Textures\DepotSkins\mdepbody_0.pcx GROUP=Skins FLAGS=2 // Skin
#exec TEXTURE IMPORT NAME=WF_HDepotBodyBlue FILE=Textures\DepotSkins\mdepbody_1.pcx GROUP=Skins FLAGS=2 // Skin
#exec TEXTURE IMPORT NAME=WF_HDepotBodyGreen FILE=Textures\DepotSkins\mdepbody_2.pcx GROUP=Skins FLAGS=2 // Skin
#exec TEXTURE IMPORT NAME=WF_HDepotBodyGold FILE=Textures\DepotSkins\mdepbody_3.pcx GROUP=Skins FLAGS=2 // Skin
#exec TEXTURE IMPORT NAME=WF_HDepotTopRed FILE=Textures\DepotSkins\mdepsymb_0.pcx GROUP=Skins FLAGS=2 // Skin
#exec TEXTURE IMPORT NAME=WF_HDepotTopBlue FILE=Textures\DepotSkins\mdepsymb_1.pcx GROUP=Skins FLAGS=2 // Skin
#exec TEXTURE IMPORT NAME=WF_HDepotTopGreen FILE=Textures\DepotSkins\mdepsymb_2.pcx GROUP=Skins FLAGS=2 // Skin
#exec TEXTURE IMPORT NAME=WF_HDepotTopGold FILE=Textures\DepotSkins\mdepsymb_3.pcx GROUP=Skins FLAGS=2 // Skin

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=LodMesh'WF_Depot'
     DrawScale=1.200000
     CollisionHeight=5.000000
     bCollideActors=True
     bBlockActors=True
     bBlockPlayers=True
}
