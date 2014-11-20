//=============================================================================
// WFD_DPMSSoundInfo. (release 4 - UT)
// Author: Ob1-Kenobi (ob1@planetunreal.com)
//
// Don't use group names like "PackageName.(all).SoundName" when setting default
// sound properties. Only use the package name followed by the sound name.
// Otherwise the sound properties will not be set properly.
//
//  e.g. sound'PackageName.SoundName'
//
// External sound packages (*.uax) will need to be loaded before the properties
// are set. Use the OBJ LOAD FILE pre-processor command to do this.
//
// #exec OBJ LOAD FILE=<path to package> PACKAGE=<package name>
//
//=============================================================================
class WFD_DPMSSoundInfo extends WFD_DPMSInfo;

// Common sounds
var(Sounds)	sound	HitSound1;
var(Sounds)	sound	HitSound2;
var(Sounds)	sound	Land;
var(Sounds)	sound	Die;
var(Sounds) sound	WaterStep;

// Sounds common to Bot and Player classes
var(Sounds) sound 	drown;
var(Sounds) sound	breathagain;
var(Sounds) sound	Footstep1;
var(Sounds) sound	Footstep2;
var(Sounds) sound	Footstep3;
var(Sounds) sound	HitSound3;
var(Sounds) sound	HitSound4;
var(Sounds) Sound	Deaths[6];
var(Sounds) sound	GaspSound;
var(Sounds) sound	UWHit1;
var(Sounds) sound	UWHit2;
var(Sounds) sound	LandGrunt;
var(Sounds) sound	JumpSound;

// TournamentPlayer sounds
var(Sounds) sound	Die2;
var(Sounds) sound	Die3;
var(Sounds) sound	Die4;

// ScriptedPawn sounds
var(Sounds)	sound	Acquire;
var(Sounds)	sound	Fear;
var(Sounds)	sound	Roam;
var(Sounds)	sound	Threaten;


//=============================================================================
// Static Sound Playing functions

static function FootZoneChange(pawn Other, ZoneInfo newFootZone);
// formally "Landed(vector HitNormal)"
static function PlayerLanded(pawn Other, vector HitNormal);
static function PlayDyingSound(pawn Other);
static function DoJump(pawn Other, optional float F );
static function PlayFootStep(pawn Other);
static function FootStepping(pawn Other);
static function PlayTakeHitSound(pawn Other, int damage, name damageType, int Mult);
static function Gasp(pawn Other);

// can used to play sounds or call other sound functions
static function PlaySpecial(pawn Other, name Type);


defaultproperties
{
}