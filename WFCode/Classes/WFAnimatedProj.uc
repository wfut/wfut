class WFAnimatedProj expands Projectile;

var texture TextureList[50];	// Store the animation's textures in order.
var int TextureNum;				// Number of textures in the texture array (animation).
var int TexturePos;				// Current position in the texture array.
var texture PrevTexture;
var texture PrevTextureAnimNext;
var float DelayTime;				// How much time to wait between each frame.
var float DelayTimeCtr;			// Keep track of delay time.

var texture FirstTexture;

var enum EAnimStyle {
	ANIM_Normal,
	ANIM_Array
} AnimStyle;

var enum EAnimMode {
	AMODE_Normal,
	AMODE_PingPong,
	AMODE_RandomFrame
} AnimMode;

var bool bDieAfterAnim;
var int AnimsToDieAfter;

function PostBeginPlay()
{
	local texture CurrentTexture, OldTexture;
	
	// Otherwise, this has already been built.
	if ( AnimStyle == ANIM_Normal )
	{
		// Compile texture list.
	
		CurrentTexture = FirstTexture;
		TextureList[TextureNum++] = FirstTexture;
	
		while (1 == 1)
		{
			OldTexture = CurrentTexture;
			CurrentTexture = CurrentTexture.AnimNext;
		//	OldTexture.AnimNext = None;
			// End of animation
			if ( CurrentTexture == None )
				break;
			TextureList[TextureNum++] = CurrentTexture;
			Log (CurrentTexture);
		}
	}
	
	Texture = TextureList[TexturePos];
	
}

function Tick( float DeltaTime )
{
	DelayTimeCtr += DeltaTime;
	if ( DelayTimeCtr >= DelayTime ) 
	{
		// Set texture to the current one in our list, then increment by one for next time.
		if ( TexturePos >= TextureNum )
			TexturePos = 0;
		if ( AnimMode == AMODE_Normal )
			Texture = TextureList[TexturePos++];
		if ( AnimMode == AMODE_RandomFrame )
			Texture = TextureList[ rand(TextureNum) ];
		
		// Reset time counter.
		DelayTimeCtr = 0;
	}
}

defaultproperties
{
	AnimStyle=ANIM_Normal
	AnimMode=AMODE_Normal
	DrawType=DT_Sprite
	Style=STY_Translucent
	bClientAnim=true
}