class WFCodeMediaInfo extends WFMediaInfo;

// --- WF HUD texure imports ---

// "flag returning" icon
// (used by: WFHUDInfo)
#exec TEXTURE IMPORT NAME=I_Returning FILE=TEXTURES\HUD\I_Returning.PCX GROUP="Icons" FLAGS=2 MIPS=OFF


// --- WF player condition imports ---

// "OnFire" flame texture
// (used by: WFFireEffect)
#exec OBJ LOAD FILE=Textures\WFFireFX.utx Package=WFMedia.WFFireFX


// "OnFire" sounds
// (used by: WFFlameGenerator)
#exec AUDIO IMPORT FILE="Sounds\PlayerStatus\firesound.WAV" NAME="firesound"
// (used by: WFStatusOnFire)
#exec AUDIO IMPORT FILE="Sounds\PlayerStatus\Vapour.WAV" NAME="Vapour2"


// "Blinded" texure
// (used by: WFStatusBlinded)
#exec TEXTURE IMPORT Name="FadeTex" FILE=Textures\PlayerStatus\fadetex.PCX MIPS=OFF
