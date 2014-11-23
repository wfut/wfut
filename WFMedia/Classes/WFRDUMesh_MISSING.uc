class WFRDUMesh_MISSING extends WFMeshImports;

// FIXME: Missing

/*
//firstpersonview

#exec MESH  MODELIMPORT MESH=ckrdufirst1Mesh MODELFILE=models\ckrdufirst1.PSK LODSTYLE=10
#exec MESH  ORIGIN MESH=ckrdufirst1Mesh X=0 Y=0 Z=0 YAW=0 PITCH=0 ROLL=0
#exec ANIM  IMPORT ANIM=ckrdufirst1Anims ANIMFILE=models\ckrdufirst.PSA COMPRESS=1 MAXKEYS=999999
#exec MESHMAP   SCALE MESHMAP=ckrdufirst1Mesh X=1.0 Y=1.0 Z=1.0
#exec MESH  DEFAULTANIM MESH=ckrdufirst1Mesh ANIM=ckrdufirst1Anims

// Animation sequences. These can replace or override the implicit (exporter-defined) sequences.
#EXEC ANIM  SEQUENCE ANIM=ckrdufirst1Anims SEQ=still STARTFRAME=0 NUMFRAMES=1 RATE=30.0000 COMPRESS=1.00 GROUP=None
#EXEC ANIM  SEQUENCE ANIM=ckrdufirst1Anims SEQ=fire STARTFRAME=1 NUMFRAMES=11 RATE=30.0000 COMPRESS=1.00 GROUP=None
#EXEC ANIM  SEQUENCE ANIM=ckrdufirst1Anims SEQ=shake STARTFRAME=12 NUMFRAMES=9 RATE=30.0000 COMPRESS=1.00 GROUP=None
#EXEC ANIM  SEQUENCE ANIM=ckrdufirst1Anims SEQ=down STARTFRAME=21 NUMFRAMES=11 RATE=30.0000 COMPRESS=1.00 GROUP=None
#EXEC ANIM  SEQUENCE ANIM=ckrdufirst1Anims SEQ=pull STARTFRAME=32 NUMFRAMES=1 RATE=30.0000 COMPRESS=1.00 GROUP=None
#EXEC ANIM  SEQUENCE ANIM=ckrdufirst1Anims SEQ=select STARTFRAME=33 NUMFRAMES=20 RATE=30.0000 COMPRESS=1.00 GROUP=None

// Digest and compress the animation data. Must come after the sequence declarations.
// 'VERBOSE' gives more debugging info in UCC.log
#exec ANIM DIGEST  ANIM=ckrdufirst1Anims VERBOSE

#EXEC TEXTURE IMPORT NAME=ckrdufirst1Tex0  FILE=MODELS\RDU1.pcx  GROUP=Skins
#EXEC TEXTURE IMPORT NAME=ckrdufirst1Tex1  FILE=MODELS\RDU2.pcx  GROUP=Skins
#EXEC TEXTURE IMPORT NAME=ckrdufirst1Tex2  FILE=MODELS\RDU3.pcx  GROUP=Skins
#EXEC TEXTURE IMPORT NAME=ckrdufirst1Tex3  FILE=MODELS\RDU4.pcx  GROUP=Skins
#EXEC TEXTURE IMPORT NAME=ckrdufirst1Tex4  FILE=MODELS\RDU5.pcx  GROUP=Skins

#EXEC MESHMAP SETTEXTURE MESHMAP=ckrdufirst1Mesh NUM=0 TEXTURE=ckrdufirst1Tex0
#EXEC MESHMAP SETTEXTURE MESHMAP=ckrdufirst1Mesh NUM=1 TEXTURE=ckrdufirst1Tex1
#EXEC MESHMAP SETTEXTURE MESHMAP=ckrdufirst1Mesh NUM=2 TEXTURE=ckrdufirst1Tex2
#EXEC MESHMAP SETTEXTURE MESHMAP=ckrdufirst1Mesh NUM=3 TEXTURE=ckrdufirst1Tex3
#EXEC MESHMAP SETTEXTURE MESHMAP=ckrdufirst1Mesh NUM=4 TEXTURE=ckrdufirst1Tex4

// Original material [0] is [SKIN00] SkinIndex: 0 Bitmap: RDU1.bmp  Path: C:\Skins\RDU
// Original material [1] is [SKIN01] SkinIndex: 1 Bitmap: RDU2.bmp  Path: C:\Skins\RDU
// Original material [2] is [SKIN02] SkinIndex: 2 Bitmap: RDU3.bmp  Path: C:\Skins\RDU
// Original material [3] is [SKIN03] SkinIndex: 3 Bitmap: RDU4.bmp  Path: C:\Skins\RDU
// Original material [4] is [SKIN04] SkinIndex: 4 Bitmap: RDU5.bmp  Path: C:\Skins\RDU

//thirdpersonview

#exec MESH IMPORT MESH=rduthird ANIVFILE=MODELS\rduthird_a.3d DATAFILE=MODELS\rduthird_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=rduthird X=0 Y=0 Z=0 Yaw=64

#exec MESH SEQUENCE MESH=rduthird SEQ=All      STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=rduthird SEQ=RDUTHIRD STARTFRAME=0 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=Jrduthird1 FILE=MODELS\rduthird1.PCX GROUP=Skins FLAGS=2 // Skin

#exec MESHMAP NEW   MESHMAP=rduthird MESH=rduthird
#exec MESHMAP SCALE MESHMAP=rduthird X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=rduthird NUM=1 TEXTURE=Jrduthird1

*/
