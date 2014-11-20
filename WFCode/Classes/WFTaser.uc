//=============================================================================
// WFTaser.
//=============================================================================
class WFTaser extends WFWeapon;

/*
DISGUISE ABILITY
	- alt mode toggles weapon disguising
	- disguise displayed in 3rd person instead of taser
	- main disguise disabled after firing pri. if weapon disguise active
*/

var() sound RechargeSound;

var float LastDisguise;
var bool bWeaponDisguised;
var class<Weapon> DisguiseClass;
var WFDisguise MainDisguise;

/*replication
{
	reliable if (bNetOwner && (Role == ROLE_Authority))
		bWeaponDisguised, DisguiseClass;
}*/

function GiveTo(pawn Other)
{
	super.GiveTo(Other);
	//RemoveWeaponDisguise();
	LastDisguise = Level.TimeSeconds;
}

simulated function PlayFiring()
{
	PlayAnim( 'Fire1', 0.9, 0.05 );
	PlayOwnedSound(FireSound, SLOT_None, 1.7*Pawn(Owner).SoundDampening);
	// NOTE: animation *must* finish, ie. use PlayAnim, or TweenAnim
}

simulated function PlayAltFiring()
{
	// play owned sound
	//PlayOwnedSound(AltFireSound, SLOT_Misc, 1.7*Pawn(Owner).SoundDampening);
	// play anim

	//PlayAnim( 'Fire2', 0.9, 0.05 );

	// NOTE: animation *must* finish, ie. use PlayAnim, or TweenAnim
}

simulated function PlayRecharging()
{
	// NOTE: animation *must* finish, ie. use PlayAnim, or TweenAnim
	PlayOwnedSound(RechargeSound, SLOT_None, 1.7*Pawn(Owner).SoundDampening);

	PlayAnim( 'recharge', 0.2, 0.05 );
}

simulated function PlayIdleAnim()
{
	if ( Mesh == PickupViewMesh )
		return;
	LoopAnim('Walking',0.2,0.1);
	Enable('AnimEnd');
}

// server side code
function Fire( float Value )
{
	if (!WeaponActive())
		return;

	// no ammo used to fire weapon
	if (bWeaponDisguised)
	{
		RemoveWeaponDisguise();
		MainDisguise.RemoveDisguise();
	}

	GotoState('NormalFire');
	bPointing=True;
	Pawn(Owner).PlayRecoil(0.25);
	bCanClientFire = true;
	ClientFire(Value);
	TraceFire(0.0);
}

function AltFire( float Value )
{
	if (!WeaponActive())
        return;

    if (MainDisguise == None)
    	MainDisguise = WFDisguise(pawn(Owner).FindInventoryType(class'WFDisguise'));

	if ((Level.TimeSeconds - LastDisguise) >= 0.5)
	{
		//GotoState('WeaponDisguised');
		if (bWeaponDisguised)
		{
			PlaySound(DeactivateSound, SLOT_Misc, 1.7*Pawn(Owner).SoundDampening);
			RemoveWeaponDisguise();
		}
		else
		{
			PlaySound(ActivateSound, SLOT_Misc, 1.7*Pawn(Owner).SoundDampening);
			SetWeaponDisguise();
		}
		LastDisguise = Level.TimeSeconds;
		//bPointing=True;
		//bCanClientFire = true;
		//ClientAltFire(Value);
	}
}

function TraceFire(float accuracy)
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X, Y, Z;
	local actor Other;

	Owner.MakeNoise(Pawn(Owner).SoundDampening);
	GetAxes(Pawn(owner).ViewRotation, X, Y, Z);
	StartTrace = Owner.Location + CalcDrawOffset() + FireOffset.Y * Y + FireOffset.Z * Z;
	AdjustedAim = pawn(owner).AdjustAim(1000000, StartTrace, AimError, False, False);
	EndTrace = StartTrace + 120.0 * vector(AdjustedAim);
	Other = Pawn(Owner).TraceShot(HitLocation, HitNormal, EndTrace, StartTrace);
	ProcessTraceHit(Other, HitLocation, HitNormal, vector(AdjustedAim), Y, Z);
}

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local vector PlayerRot, OtherRot;
	local float TaserRange;

	if ( (Other == None) || (Other == Owner) || (Other == self) || (Owner == None))
		return;

	OtherRot = vector(Other.Rotation);
	OtherRot.Z = 0; // not interested in the virtical components value
	PlayerRot = vector(Owner.Rotation);
	PlayerRot.Z = 0; // not interested in the virtical components value

	if ( (Other == Level) || Other.IsA('Mover') )
	{
		if ( VSize(HitLocation - Owner.Location) < 80 )
			Spawn(class'ImpactMark',,, HitLocation+HitNormal, Rotator(HitNormal));
		Spawn(class'WFTaserSmallSparkEffect',,, HitLocation+HitNormal, Rotator(HitNormal));
		//Owner.TakeDamage(36.0, Pawn(Owner), HitLocation, -69000.0 * ChargeSize * X, MyDamageType);
	}

	if ( Other != Level )
	{
		// change this value to alter the effective range of the attack
		TaserRange = 120.0;
		if ( Other.bIsPawn && (VSize(HitLocation - Owner.Location) > TaserRange) )
			return;
		if (Other.bIsPawn && pawn(Other).bIsPlayer && ((OtherRot dot PlayerRot) > 0.5))
		{
			Other.TakeDamage(350.0, Pawn(Owner), HitLocation, 80000.0 * X, MyDamageType);
			Spawn(class'WFTaserSparkEffect',,, HitLocation+HitNormal, Rotator(HitNormal));
		}
		else
		{
			Spawn(class'WFTaserSmallSparkEffect',,, HitLocation+HitNormal, Rotator(HitNormal));
			Other.TakeDamage(40.0, Pawn(Owner), HitLocation, 40000.0 * X, MyDamageType);
		}
		if ( !Other.bIsPawn && !Other.IsA('Carcass') )
			spawn(class'UT_SpriteSmokePuff',,,HitLocation+HitNormal*9);
	}
}

// client states
state ClientFiring
{
	simulated function AnimEnd()
	{
		PlayRecharging();
		GotoState('ClientRecharging');
	}
}

state ClientRecharging
{
	simulated function bool ClientFire(float Value)
	{
		return false;
	}

	simulated function bool ClientAltFire(float Value)
	{
		return false;
	}

	simulated function AnimEnd()
	{
		if (Pawn(Owner) == None)
		{
			PlayIdleAnim();
			GotoState('');
		}
		else if ( !bCanClientFire )
			GotoState('');
		else if ( Pawn(Owner).bFire != 0 )
			Global.ClientFire(0);
		//else if ( Pawn(Owner).bAltFire != 0 )
		//	Global.ClientAltFire(0);
		else
		{
			PlayIdleAnim();
			GotoState('');
		}
	}
}

simulated function bool ClientAltFire( float Value )
{
	PlayIdleAnim();
	GotoState('');
	return true;
}

// server states
state NormalFire
{
	function AnimEnd()
	{
		PlayRecharging();
		GotoState('Recharging');
	}
}

// lasts until recharging animation finishes
state Recharging
{
	function ForceFire()
	{
		bForceFire = true;
	}

	function ForceAltFire()
	{
		bForceAltFire = true;
	}

	function Fire(float F)
	{
	}
	function AltFire(float F)
	{
	}

	function AnimEnd()
	{
		Finish();
	}
}

function Finish()
{
	local Pawn PawnOwner;
	local bool bForce, bForceAlt;

	bForce = bForceFire;
	bForceAlt = bForceAltFire;
	bForceFire = false;
	bForceAltFire = false;

	if ( bChangeWeapon )
	{
		GotoState('DownWeapon');
		return;
	}

	PawnOwner = Pawn(Owner);
	if ( PawnOwner == None )
		return;
	if ( PlayerPawn(Owner) == None )
	{
		if ( (AmmoType != None) && (AmmoType.AmmoAmount<=0) )
		{
			PawnOwner.StopFiring();
			PawnOwner.SwitchToBestWeapon();
			if ( bChangeWeapon )
				GotoState('DownWeapon');
		}
		else if ( (PawnOwner.bFire != 0) && (FRand() < RefireRate) )
			Global.Fire(0);
		//else if ( (PawnOwner.bAltFire != 0) && (FRand() < AltRefireRate) )
		//	Global.AltFire(0);
		else
		{
			PawnOwner.StopFiring();
			GotoState('Idle');
		}
		return;
	}
	if ( ((AmmoType != None) && (AmmoType.AmmoAmount<=0)) || (PawnOwner.Weapon != self) )
		GotoState('Idle');
	else if ( (PawnOwner.bFire!=0) || bForce )
		Global.Fire(0);
	//else if ( (PawnOwner.bAltFire!=0) || bForceAlt )
	//	Global.AltFire(0);
	else
		GotoState('Idle');
}

function SetWeaponDisguise()
{
	local int i, best;
	local class<WFS_InventoryInfo> InvClass;

	if (bWeaponDisguised)
		return;

    if (MainDisguise == None)
    	MainDisguise = WFDisguise(pawn(Owner).FindInventoryType(class'WFDisguise'));

	if (MainDisguise.bDisguised && (MainDisguise.DisguisePCI != None))
	{
		InvClass = MainDisguise.DisguisePCI.default.DefaultInventory;
		best = 0;
		for (i=0; i<10; i++)
		{
			if (InvClass.default.Weapons[i] == None)
				break;
			else if ((InvClass.default.Weapons[i].default.AutoSwitchPriority >= best))
			{
				best = InvClass.default.Weapons[i].default.AutoSwitchPriority;
				DisguiseClass = InvClass.default.Weapons[i];
			}
		}
	}
	else DisguiseClass = self.class;

	if (DisguiseClass != None)
	{
		ThirdPersonMesh = DisguiseClass.default.ThirdPersonMesh;
		ThirdPersonScale = DisguiseClass.default.ThirdPersonScale;
		Mass = DisguiseClass.default.Mass;
		MultiSkins[4] = FireTexture'fireeffect27';
		bWeaponDisguised = true;
	}
}

function SetDefaultDisplayProperties()
{
	Style = Default.Style;
	texture = Default.Texture;
	bUnlit = Default.bUnlit;
	bMeshEnviromap = Default.bMeshEnviromap;
	if (bWeaponDisguised)
		MultiSkins[4] = FireTexture'fireeffect27';
	else MultiSkins[4] = default.MultiSkins[4];
}

function RemoveWeaponDisguise()
{
	if (!bWeaponDisguised)
		return;

	bWeaponDisguised = false;
	DisguiseClass = None;
	MultiSkins[4] = default.MultiSkins[4];
	ThirdPersonMesh = default.ThirdPersonMesh;
	ThirdPersonScale = default.ThirdPersonScale;
	Mass = default.Mass;
}

function WeaponEvent(name EventType)
{
	if (EventType == 'DisguiseRemoved')
		RemoveWeaponDisguise();
	else if ((EventType == 'DisguiseChanged') && bWeaponDisguised)
	{
		bWeaponDisguised = false;
		DisguiseClass = None;
		SetWeaponDisguise();
	}
}

State DownWeapon
{
	function BeginState()
	{
		RemoveWeaponDisguise();
		super.BeginState();
	}
}

defaultproperties
{
     RechargeSound=Sound'Recharge'
     WeaponDescription="Classification: Melee Taser"
     InstFog=(X=475.000000,Y=325.000000,Z=145.000000)
     bMeleeWeapon=True
     //bRapidFire=True
     MyDamageType=electrocuted
     RefireRate=1.000000
     AltRefireRate=1.000000
     FireSound=Sound'taserprime'
     ActivateSound=Sound'dampndea'
     DeactivateSound=Sound'DampSnd'
     SelectSound=Sound'Botpack.ASMD.ImpactPickup'
     Misc1Sound=Sound'Botpack.ASMD.ImpactAltFireStart'
     DeathMessage="%o got fried by %k's taser."
     NameColor=(G=192,B=0)
     PickupMessage="You got the Taser."
     ItemName="Taser"
     PlayerViewOffset=(X=2.500000,Y=-2.000000,Z=-1.700000)
     PlayerViewMesh=LodMesh'inftaser'
     PlayerViewScale=0.120000
     PickupViewMesh=LodMesh'taserpick'
     ThirdPersonMesh=LodMesh'taser3rd'
     ThirdPersonScale=0.900000
     StatusIcon=Texture'Botpack.Icons.UseHammer'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Icon=Texture'Botpack.Icons.UseHammer'
     bNoSmooth=False
     SoundRadius=50
     SoundVolume=200
     AutoSwitchPriority=2
     InventoryGroup=2
     Mass=15.0
     MultiSkins(4)=FireTexture'UnrealShare.EffectASMD.fireeffectASMD'
     bWeaponDisguised=False
}
