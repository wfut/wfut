//=============================================================================
// WFD_DPMSMeshInfo. (release 4 - UT)
// Author: Ob1-Kenobi (ob1@planetunreal.com)
//
// IMPORTANT: Make sure that the 'CheckMesh(Other)' function is called at the start
//            of each animation function to ensure that the player has the
//            correct mesh. Otherwise the mesh wont be updated correctly.
//=============================================================================
class WFD_DPMSMeshInfo extends WFD_DPMSInfo;

// TODO: Add base eye height vars?
//       Implement MeshInfo.default.bCanHoldWeapon

// mesh variables
var() mesh PlayerMesh;					// the mesh for this animation class
var() class<carcass> CarcassClass;		// the carcass mesh for this class
var() class<carcass> DecapClass;		// mesh used in head shot sequence
var() class<pawn> DefaultClass;			// the class that this MeshInfo contains info for
										// (eg. BotPack.TMale1)
										// Used by the player setup menu

// default collision cylinder
var() float CollisionRadius; // Radius of collision cylinder.
var() float CollisionHeight; // Half-height cyllinder.

// model variables
var() bool bCanHoldWeapon;	// model can 'carry' weapon mesh
var() string SelectionMesh; // model selection string
var() string MenuName; 		// player menu class text
var() bool bIsFemale;		// mesh is a female mesh
var() bool bGreenBlood;		// model should use green blood effects

// voice pack vars
var() string VoicePackMetaClass;
var() string VoiceType;		// default voice type for this model

// HUD vars
var() texture StatusDoll;
var() texture StatusBelt;

// sound variables
var() class<WFD_DPMSSoundInfo> DefaultSoundClass;

// skin variables
var(MI_Skin) bool		bIsMultiSkinned;
var(MI_Skin) string 	DefaultSkinName;
var(MI_Skin) string 	DefaultFaceName;	// name of face for default skin
var(MI_Skin) string		DefaultPackage;
var(MI_Skin) int		FaceSkin;
var(MI_Skin) int		FixedSkin;
var(MI_Skin) int		TeamSkin1;
var(MI_Skin) int		TeamSkin2;
var(MI_Skin) int		MultiLevel; //??


//=============================================================================
// skin functions

// implement in sub-class
static function GetMultiSkin( Actor SkinActor, out string SkinName, out string FaceName );
static function SetMultiSkin(Actor SkinActor, string SkinName, string FaceName, byte TeamNum);

// imported here from Engine.Pawn
static function bool SetSkinElement(Actor SkinActor, int SkinNo, string SkinName, string DefaultSkinName)
{
	local Texture NewSkin;

	NewSkin = Texture(DynamicLoadObject(SkinName, class'Texture'));
	if ( NewSkin != None )
	{
		SkinActor.Multiskins[SkinNo] = NewSkin;
		return True;
	}
	else
	{
		log("Failed to load "$SkinName);
		if(DefaultSkinName != "")
		{
			NewSkin = Texture(DynamicLoadObject(DefaultSkinName, class'Texture'));
			SkinActor.Multiskins[SkinNo] = NewSkin;
		}
		return False;
	}
}

//=============================================================================
// Static Animation Functions

// Checks that the MeshInfo vars have been set up ok.
// Call at the start of each animation function to update mesh.
static function CheckMesh(pawn Other)
{
	// this part is called on the server
	if ((Other.Mesh == none) || (Other.Mesh != default.PlayerMesh))
	{
		Other.Mesh = default.PlayerMesh;
		Other.bIsFemale = default.bIsFemale;
		//PlayWaiting(Other); // so mesh doesn't appear to freeze when changed
		UpdateEffects(Other); // update shieldbelt mesh etc.
		UpdateIcons(Other); // FIXME: never callled if mesh updated on server first
	}

	// this function should only actually completed client side
	UpdateIcons(Other); // <- FIXME: only really want this called once on the client
}

// update any effects
static function UpdateEffects(pawn Other);

// update HUD icons (FIXME: don't update icons on a dedicated server)
static function UpdateIcons(pawn Other);

//=============================================================================
// Static Player Animation Functions (Implement in sub-classes)

static function PlayCrawling(pawn Other);
static function PlayDuck(pawn Other);
static function PlayDying(pawn Other, name DamageType, vector HitLoc);
static function PlayFeignDeath(pawn Other);
static function PlayFiring(pawn Other);
static function PlayInAir(pawn Other);
static function PlayLanded(pawn Other, float impactVel);
static function PlayRecoil(pawn Other, float Rate);
static function PlayRising(pawn Other);
static function PlayRunning(pawn Other);
static function PlaySwimming(pawn Other);
static function PlayTurning(pawn Other);
static function PlayWalking(pawn Other);
static function PlayWeaponSwitch(pawn Other, Weapon NewWeapon);
static function TweenToRunning(pawn Other, float tweentime);
static function TweenToSwimming(pawn Other, float tweentime);
static function TweenToWaiting(pawn Other, float tweentime);
static function TweenToWalking(pawn Other, float tweentime);

static function PlayDecap(pawn Other);

static function PlayGutHit(pawn Other, float tweentime);
static function PlayHeadHit(pawn Other, float tweentime);
static function PlayLeftHit(pawn Other, float tweentime);
static function PlayRightHit(pawn Other, float tweentime);

// "GetAnimGroup()" functions from "Engine.Pawn"
static function SwimAnimUpdate(pawn Other, bool bNotForward);

// formerly PlayerSwimming.AnimEnd()
static function SwimAnimEnd(pawn Other);

// Some animation control and movement functions from the PlayerWalking state
// PlayerWalking.AnimEnd()
static function WalkingAnimEnd(pawn Other);
static function PlayWaiting(pawn Other);
static function PlayChatting(pawn Other);

static function Dodge(pawn Other, eDodgeDir DodgeMove);
static function PlayDodge(pawn Other, eDodgeDir DodgeMove);

// can used to play animation or call other animation functions
static function PlaySpecial(pawn Other, name Type);

defaultproperties
{
}