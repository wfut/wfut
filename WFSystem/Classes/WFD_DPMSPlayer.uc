//=============================================================================
// WFD_DPMSPlayer. (release 4 - UT)
// Author: Ob1-Kenobi (ob1@planetunreal.com)
//=============================================================================
class WFD_DPMSPlayer extends TournamentPlayer
	abstract;

var() class<WFD_PlayerPawnMeshInfo> MeshInfo;
var() class<WFD_DPMSSoundInfo> SoundInfo;

var() string DefaultClassPackage; // default package used for SetMeshClass

var() class<UWindowWindow> PlayerSetupWindowClass;
//var() bool bAutoCreateRoot; // auto-create the root window to setup PlayerSetupWindowClass
var bool bMenuClassSetup; // internal

replication
{
	// Things the server should send to the client.
	// Change these SERVER side. Call a function on the server to change them.
	//   eg. SomeGame(Level.Game).ChangeMeshClass(self, NewClass);
	reliable if( Role==ROLE_Authority )
		MeshInfo, SoundInfo;

	// Functions client can call.
	reliable if( Role<ROLE_Authority )
		ServerChangeMeshClass, SetMeshClass, SetSkin, SetFace;
}

exec function SetMeshClass(coerce string ClassName)
{
	local class<Pawn> NewClass;

	if (GetItemName(ClassName) == ClassName)
		NewClass = class<Pawn>(DynamicLoadObject(DefaultClassPackage$ClassName,class'Class'));
	else
		NewClass = class<Pawn>(DynamicLoadObject(ClassName,class'Class'));

	if (NewClass != none)
	{
		// change the class
		ServerChangeMeshClass(NewClass);
	}
	else ClientMessage("Unknown player class: "$ClassName);
}

exec function SetSkin(coerce string NewSkinName)
{
	local string OldSkin, MeshName, SkinName, FaceName;
	local string SkinDesc, TestName, Temp;
	local bool bFound;

	// get the mesh name
	MeshName = GetItemName(String(Mesh));

	SkinName = "None";
	FaceName = "None";
	TestName = "";
	bFound = false;

	// find the skin
	if (MeshInfo.default.bIsMultiSkinned)
	{
		while (true)
		{
			GetNextSkin(MeshName, SkinName, 1, SkinName, SkinDesc);

			if (TestName == SkinName)
				break;

			if (TestName == "")
				TestName = SkinName;

			if ((SkinDesc ~= NewSkinName) && (SkinDesc != ""))
			{
				SkinName = Left(SkinName, Len(SkinName) - 1);
				bFound = true;
				break;
			}

			if (NewSkinName ~= SkinName)
			{
				SkinName = Left(SkinName, Len(SkinName) - 1);
				bFound = true;
				break;
			}
		}

		// get a valid face for this skin
		if (bFound)
		{
			TestName = "";
			while ( True )
			{
				GetNextSkin(MeshName, FaceName, 1, FaceName, SkinDesc);

				if( FaceName == TestName )
					break;

				if( TestName == "" )
					TestName = FaceName;

				// Multiskin format
				if( SkinDesc != "")
				{
					Temp = GetItemName(FaceName);
					if(Mid(Temp, 5) != "" && Left(Temp, 4) == GetItemName(SkinName))
					{
						// valid face found so set skin
						FaceName = Left(FaceName, Len(FaceName) - Len(Temp)) $ Mid(Temp, 5);
						ServerChangeSkin(SkinName, FaceName, PlayerReplicationInfo.Team);
						return;
					}
				}
			}
		}
	}
	else
	{
		// try to set skin
		MeshInfo.static.GetMultiSkin(self, SkinName, FaceName);
		ServerChangeSkin(NewSkinName, FaceName, PlayerReplicationInfo.Team);
	}
}

exec function SetFace(coerce string NewFaceName)
{
	local string SkinName, MeshName, FaceName, FullFaceName;
	local string TestName, SkinDesc, Temp;

	if (!MeshInfo.default.bIsMultiSkinned)
		return;

	MeshName = GetItemName(String(Mesh));

	MeshInfo.static.GetMultiSkin(self, SkinName, FaceName);

	FullFaceName = "None";
	TestName = "";
	while ( True )
	{
		GetNextSkin(MeshName, FullFaceName, 1, FullFaceName, SkinDesc);
		if( FullFaceName == TestName )
			break;

		if( TestName == "" )
			TestName = FullFaceName;

		// Multiskin format
		if( SkinDesc != "")
		{
			Temp = GetItemName(FullFaceName);
			if(Mid(Temp, 5) != "" && Left(Temp, 4) == GetItemName(SkinName))
			{
				// valid face found so set skin
				FaceName = Left(FullFaceName, Len(FullFaceName) - Len(Temp)) $ Mid(Temp, 5);
				if (GetItemName(FaceName) ~= NewFaceName)
				{
					ServerChangeSkin(SkinName, FaceName, PlayerReplicationInfo.Team);
					return;
				}
			}
		}
	}
}


//=============================================================================
// Mesh, Skin & Sound functions
//=============================================================================
// General

// get the MeshInfo class for the current mesh
function class<WFD_DPMSMeshInfo> GetMeshInfoClass()
{
	// could make this a little more dynamic...
	return MeshInfo;
}

//=============================================================================
// Mesh

// player changed class
// Implement in sub class. (NewPlayerClass doesn't need to be a playerpawn class)
function ServerChangeMeshClass(class<Pawn> NewPlayerClass)
{
	/* Example mesh class changing code:

	if (NewPlayerClass.default.mesh == MeshInfo.default.PlayerMesh)
	{
		// Could check if mesh is already same here
		return;
	}

	// change class
	SomeGame(Level.Game).ChangeMeshClass(Self, NewPlayerClass);

	MeshInfo.static.CheckMesh(self); // force mesh to update

	UpdateVoicePack(); // check to see if voice pack needs to be changed

	PlayWaiting(); // stops the new mesh from looking frozen when changed
	*/
}

// update the voice pack if necessary
function UpdateVoicePack()
{
	if ((MeshInfo != none) && (VoicePackMetaClass != MeshInfo.default.VoicePackMetaClass))
	{
		VoicePackMetaClass = MeshInfo.default.VoicePackMetaClass;
		SetVoice(class<ChallengeVoicePack>(DynamicLoadObject(MeshInfo.default.VoiceType, class'Class')));
	}
}

//=============================================================================
// Overridden functions

// Replace the player setup window with one that supports DPMS as well as
// standard UT player classes.
event PreRender(canvas Canvas)
{
	super.PreRender(Canvas);
	if (!bMenuClassSetup && (PlayerSetupWindowClass != none))
		InitMenu(Canvas);
}

// custom function called by PreRender()
function InitMenu(canvas Canvas)
{
	local UTConsole PlayerConsole;
	local UMenuMenuBar MenuBar;

	if ((Player != none) && (Level.NetMode != NM_DedicatedServer)
		&& (PlayerSetupWindowClass != none))
	{
		PlayerConsole = UTConsole(Player.Console);
		if (PlayerConsole == none)
		{
			//Log("[--Debug--]: PlayerConsole == none");
			return;
		}

		// try to replace the current Preferences menu
		if (!PlayerConsole.bCreatedRoot)
		{
			//Log("[--Debug--]: Creating root window...");
			PlayerConsole.CreateRootWindow(Canvas);
			PlayerConsole.CloseUWindow();
		}

		MenuBar = UMenuRootWindow(PlayerConsole.Root).MenuBar;
		if (MenuBar == none)
		{
			//Log("[--Debug--]: MenuBar == none");
			return;
		}

		if (MenuBar.Options.PlayerWindowClass != PlayerSetupWindowClass)
		{
			//Log("[--Debug--]: Replacing the PlayerWindowClass");
			MenuBar.Options.PlayerWindowClass = PlayerSetupWindowClass;
			bMenuClassSetup = true;
		}
	}
}

function Carcass SpawnCarcass()
{
	local carcass carc;

	carc = Spawn(MeshInfo.default.CarcassClass);
	if ( carc == None )
		return None;
	carc.Initfor(self);
	if (Player != None)
		carc.bPlayerCarcass = true;
	if ( !Level.Game.bGameEnded && (Carcass(ViewTarget) == None) )
		ViewTarget = carc; //for Player 3rd person views
	return carc;
}

function SpawnGibbedCarcass()
{
	local carcass carc;

	carc = Spawn(MeshInfo.default.CarcassClass);
	if ( carc != None )
	{
		carc.Initfor(self);
		carc.ChunkUp(-1 * Health);
	}
}

// intercept a SetMesh call
simulated function SetMesh()
{
	if ((Mesh == none) || (Mesh != MeshInfo.default.PlayerMesh))
	{
		mesh = MeshInfo.default.PlayerMesh;
		MeshInfo.static.UpdateIcons(self);
	}
}

//=============================================================================
// Skin functions

static function GetMultiSkin( Actor SkinActor, out string SkinName, out string FaceName )
{
	local class<WFD_DPMSMeshInfo> MeshInfoClass;

	MeshInfoClass = WFD_DPMSPlayer(SkinActor).GetMeshInfoClass();

	if (MeshInfoClass == none)
		return;

	MeshInfoClass.static.GetMultiSkin(SkinActor, SkinName, FaceName);
}

static function SetMultiSkin(Actor SkinActor, string SkinName, string FaceName, byte TeamNum)
{
	local class<WFD_DPMSMeshInfo> MeshInfoClass;

	MeshInfoClass = WFD_DPMSPlayer(SkinActor).GetMeshInfoClass();

	if (MeshInfoClass == none)
		return;

	MeshInfoClass.static.SetMultiSkin(SkinActor, SkinName, FaceName, TeamNum);
}

function ServerChangeSkin( coerce string SkinName, coerce string FaceName, byte TeamNum )
{
	local string MeshName;

	MeshName = GetItemName(string(Mesh));
	if ( Level.Game.bCanChangeSkin )
		MeshInfo.static.SetMultiSkin(self, SkinName, FaceName, TeamNum);
}

//=============================================================================
// Sound Playing Functions (all overridden to use SoundInfo class for sounds)

// From Engine.Pawn
event FootZoneChange(ZoneInfo newFootZone)
{
	if (SoundInfo != none)
		SoundInfo.static.FootZoneChange(self, newFootZone);
}

state FeigningDeath
{
	function Landed(vector HitNormal)
	{
		SoundInfo.static.PlayerLanded(self, HitNormal);
	}
}

// From BotPack.TournamentPlayer
function PlayDyingSound()
{
	SoundInfo.static.PlayDyingSound(self);
}

//Player Jumped
function DoJump( optional float F )
{
	SoundInfo.static.DoJump(self, F);
}

simulated function FootStepping()
{
	SoundInfo.static.FootStepping(self);
}

function PlayTakeHitSound(int damage, name damageType, int Mult)
{
	SoundInfo.static.PlayTakeHitSound(self, damage, damageType, Mult);
}

function Gasp()
{
	SoundInfo.static.Gasp(self);
}

// here to support UnrealI.MaleOne
function PlayMetalStep()
{
	SoundInfo.static.PlaySpecial(self, 'MetalStep');
}

// used by SkaarjTrooper mesh
function WalkStep()
{
	SoundInfo.static.PlaySpecial(self, 'WalkStep');
}

function RunStep()
{
	SoundInfo.static.PlaySpecial(self, 'RunStep');
}

//=============================================================================
// Animation Playing Functions

// TODO: o Implement MeshInfo.default.bCanHoldWeapon

function PlayTurning()
{
	MeshInfo.static.PlayTurning(self);
}

function TweenToWalking(float tweentime)
{
	MeshInfo.static.TweenToWalking(self, tweentime);
}

function PlayDodge(eDodgeDir DodgeMove)
{
	MeshInfo.static.PlayDodge(self, DodgeMove);
}

function PlayWalking()
{
	MeshInfo.static.PlayWalking(self);
}

function TweenToRunning(float tweentime)
{
	MeshInfo.static.TweenToRunning(self, tweentime);
}

function PlayRunning()
{
	MeshInfo.static.PlayRunning(self);
}

function PlayRising()
{
	MeshInfo.static.PlayRising(self);
}

function PlayFeignDeath()
{
	MeshInfo.static.PlayFeignDeath(self);
}

function PlayLanded(float impactVel)
{
	MeshInfo.static.PlayLanded(self, impactVel);
}

function PlayInAir()
{
	MeshInfo.static.PlayInAir(self);
}

function PlayDuck()
{
	MeshInfo.static.PlayDuck(self);
}

function PlayCrawling()
{
	MeshInfo.static.PlayCrawling(self);
}

function TweenToWaiting(float tweentime)
{
	MeshInfo.static.TweenToWaiting(self, tweentime);
}

function PlayRecoil(float Rate)
{
	MeshInfo.static.PlayRecoil(self, Rate);
}

function PlayFiring()
{
	MeshInfo.static.PlayFiring(self);
}

function PlayWeaponSwitch(Weapon NewWeapon)
{
	MeshInfo.static.PlayWeaponSwitch(self, NewWeapon);
}

function PlaySwimming()
{
	MeshInfo.static.PlaySwimming(self);
}

function TweenToSwimming(float tweentime)
{
	MeshInfo.static.TweenToSwimming(self, tweentime);
}

// from BotPack.TournamentMale
function PlayDying(name DamageType, vector HitLoc)
{
	MeshInfo.static.PlayDying(self, DamageType, HitLoc);
}

function PlayDecap()
{
	MeshInfo.static.PlayDecap(self);
}

function PlayGutHit(float tweentime)
{
	MeshInfo.static.PlayGutHit(self, tweentime);
}

function PlayHeadHit(float tweentime)
{
	MeshInfo.static.PlayHeadHit(self, tweentime);
}

function PlayLeftHit(float tweentime)
{
	MeshInfo.static.PlayLeftHit(self, tweentime);
}

function PlayRightHit(float tweentime)
{
	MeshInfo.static.PlayRightHit(self, tweentime);
}

// "GetAnimGroup()" functions from "Engine.Pawn"
function SwimAnimUpdate(bool bNotForward)
{
	MeshInfo.static.SwimAnimUpdate(self, bNotForward);
}

state PlayerSwimming
{
	function AnimEnd()
	{
		MeshInfo.static.SwimAnimEnd(self);
	}
}

// From Engine.PlayerPawn
state PlayerWalking
{
	function Dodge(eDodgeDir DodgeMove)
	{
		MeshInfo.static.Dodge(self, DodgeMove);
	}

	function AnimEnd()
	{
		MeshInfo.static.WalkingAnimEnd(self);
	}
}

function PlayWaiting()
{
	MeshInfo.static.PlayWaiting(self);
}

function PlayChatting()
{
	MeshInfo.static.PlayChatting(self);
}

defaultproperties
{
	MeshInfo=None
	SoundInfo=None
	CollisionRadius=0.000000
	CollisionHeight=0.000000
	PlayerSetupWindowClass=class'WFD_DPMSPlayerWindow'
}