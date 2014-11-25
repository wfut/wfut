class WFEffectModels extends WFMeshImports;

// geonormal.
#exec MESH IMPORT MESH=geonormal ANIVFILE=MODELS\geonormal_a.3d DATAFILE=MODELS\geonormal_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=geonormal X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=geonormal SEQ=All       STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=geonormal SEQ=GEONORMAL STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=geonormal MESH=geonormal
#exec MESHMAP SCALE MESHMAP=geonormal X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=geonormal NUM=0 TEXTURE=DefaultTexture

// geoflipped.
#exec MESH IMPORT MESH=geoflipped ANIVFILE=MODELS\geoflipped_a.3d DATAFILE=MODELS\geoflipped_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=geoflipped X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=geoflipped SEQ=All     STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=geoflipped SEQ=GEOFLIP STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=geoflipped MESH=geoflipped
#exec MESHMAP SCALE MESHMAP=geoflipped X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=geoflipped NUM=0 TEXTURE=DefaultTexture

// geotwos.
#exec MESH IMPORT MESH=geotwos ANIVFILE=MODELS\geotwos_a.3d DATAFILE=MODELS\geotwos_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=geotwos X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=geotwos SEQ=All     STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=geotwos SEQ=GEOTWOS STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=geotwos MESH=geotwos
#exec MESHMAP SCALE MESHMAP=geotwos X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=geotwos NUM=0 TEXTURE=DefaultTexture

// rdubounce.
#exec MESH IMPORT MESH=rdubounce ANIVFILE=MODELS\rdubounce_a.3d DATAFILE=MODELS\rdubounce_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=rdubounce X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=rdubounce SEQ=All       STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=rdubounce SEQ=RDUBOUNCE STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=rdubounce MESH=rdubounce
#exec MESHMAP SCALE MESHMAP=rdubounce X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=rdubounce NUM=0 TEXTURE=DefaultTexture

// torusanim.
#exec MESH IMPORT MESH=torusanim ANIVFILE=MODELS\torusanim_a.3d DATAFILE=MODELS\torusanim_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=torusanim X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=torusanim SEQ=All       STARTFRAME=0 NUMFRAMES=3
#exec MESH SEQUENCE MESH=torusanim SEQ=TORUSANIM STARTFRAME=0 NUMFRAMES=3

#exec MESHMAP NEW   MESHMAP=torusanim MESH=torusanim
#exec MESHMAP SCALE MESHMAP=torusanim X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=torusanim NUM=0 TEXTURE=DefaultTexture

// toruseff.
#exec MESH IMPORT MESH=toruseff ANIVFILE=MODELS\toruseff_a.3d DATAFILE=MODELS\toruseff_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=toruseff X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=toruseff SEQ=All      STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=toruseff SEQ=TORUSEFF STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=toruseff MESH=toruseff
#exec MESHMAP SCALE MESHMAP=toruseff X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=toruseff NUM=0 TEXTURE=DefaultTexture

// toruseff1.
#exec MESH IMPORT MESH=toruseff1 ANIVFILE=MODELS\toruseff1_a.3d DATAFILE=MODELS\toruseff1_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=toruseff1 X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=toruseff1 SEQ=All       STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=toruseff1 SEQ=TORUSEFF1 STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=toruseff1 MESH=toruseff1
#exec MESHMAP SCALE MESHMAP=toruseff1 X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=toruseff1 NUM=0 TEXTURE=DefaultTexture

// toruseff2.
#exec MESH IMPORT MESH=toruseff2 ANIVFILE=MODELS\toruseff2_a.3d DATAFILE=MODELS\toruseff2_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=toruseff2 X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=toruseff2 SEQ=All       STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=toruseff2 SEQ=TORUSEFF2 STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=toruseff2 MESH=toruseff2
#exec MESHMAP SCALE MESHMAP=toruseff2 X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=toruseff2 NUM=0 TEXTURE=DefaultTexture

