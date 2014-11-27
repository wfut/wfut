class WFReconDefenseUnit extends WFWeapon;

// -- Impact Hammer Vars --
var float ChargeSize, Count;
var() sound AltFireSound;
var() sound TensionSound;
// ------------------------

var() float AbsorbtionRatio; // for plasma shield
var() float ForceMag; // force players are pushed
var() float MaxForceMag;
var() float ForceRadius;
var() float ForceDamage;
var() float MaxForceDamage;
var() float MaxChargeSize;
var() float ChargeCount;

var() int PlasmaEnergyRate; // energy used for shield per second

var bool bPlasmaActive; // damage shield active
var bool bForceActive; // force field active

var float ShieldAngle;

var effects MyEffect;

var private float PiercingDamageScale;

var float UpwardPush, ForwardPush;

replication
{
	reliable if (Role == ROLE_Authority)
		bPlasmaActive;
}

simulated event RenderTexture(ScriptedTexture Tex)
{
	local Color C;

	C.R = 255;
	C.G = 0;
	C.B = 0;

	Tex.DrawColoredText( 12, 16.5, string(AmmoType.AmmoAmount), Font'LEDFont2', C );
}

simulated event RenderOverlays( canvas Canvas )
{
	Texture'MiniAmmoled'.NotifyActor = Self;
	Super.RenderOverlays(Canvas);
	Texture'MiniAmmoled'.NotifyActor = None;
}

// call this to allow the next damage call to pass shield
function ShieldPierced(float DamageScale)
{
	PiercingDamageScale = DamageScale;
}

function Fire( float Value )
{
	if (!WeaponActive())
		return;

	if (AmmoType == None)
		GiveAmmo(pawn(Owner));
	if (AmmoType.AmmoAmount > 0)
	{
		NotifyFired();
		bPointing=True;
		bCanClientFire = true;
		ClientFire(Value);
		Pawn(Owner).PlayRecoil(FiringSpeed);
		GoToState('Firing');
	}
}

state Firing
{
	function AltFire(float F)
	{
	}

	function Tick( float DeltaTime )
	{
		local Pawn P;
		local Rotator EnemyRot;
		local vector HitLocation, HitNormal, StartTrace, EndTrace, X, Y, Z;
		local actor HitActor;

		if (  Bot(Owner) != None )
		{
			if ( Bot(Owner).Enemy == None )
				Bot(Owner).bFire = 0;
			else
				Bot(Owner).bFire = 1;
		}
		P = Pawn(Owner);
		if ( P == None )
		{
			AmbientSound = None;
			GotoState('');
			return;
		}
		else if( P.bFire==0 )
		{
			RadiusPush();
			PlayFiring();
			GoToState('FireBlast');
			return;
		}

		Count += DeltaTime;
		if ( Count > 0.2 )
		{
			Count = 0;
			Owner.MakeNoise(1.0);
		}

		if (ChargeSize < MaxChargeSize)
		{
			ChargeCount += DeltaTime;
			if ((ChargeCount >= 0.5) && AmmoType.UseAmmo(1))
			{
				ChargeSize = FMin(ChargeSize + ChargeCount, MaxChargeSize);
				ChargeCount = 0;
			}
		}
	}

	function BeginState()
	{
		ChargeSize = 0.0;
		Count = 0.0;
		WFRDUAmmo(AmmoType).bRecharge = false;
	}

	function EndState()
	{
		super.EndState();
		AmbientSound = None;
		WFRDUAmmo(AmmoType).bRecharge = !bPlasmaActive;
	}

Begin:
	FinishAnim();
	AmbientSound = TensionSound;
	SoundVolume = 255*Pawn(Owner).SoundDampening;
	LoopAnim('Shake', 0.9);
}


function AltFire( float Value )
{
	if (!WeaponActive())
		return;

	if (AmmoType == None)
		GiveAmmo(pawn(Owner));

	if (AmmoType.AmmoAmount <= 0)
		return;

	NotifyFired();
	bPointing=True;
	bCanClientFire = true;
	Pawn(Owner).PlayRecoil(FiringSpeed);
	//TraceAltFire();
	ClientAltFire(value);

	bPlasmaActive = !bPlasmaActive;

	if (MyEffect == None)
		CreateEffect();

	if (bPlasmaActive)
	{
		if (MyEffect != None)
			MyEffect.bHidden = false;
		pawn(owner).ClientMessage("Defense shield activated.", 'CriticalEvent');
		if ( Owner.IsA('PlayerPawn') )
			PlayerPawn(Owner).ClientAdjustGlow(-0.2,vect(0,0,200));
	}
	else
	{
		if (MyEffect != None)
			MyEffect.bHidden = true;
		pawn(owner).ClientMessage("Defense shield deactivated.", 'CriticalEvent');
		if ( Owner.IsA('PlayerPawn') )
			PlayerPawn(Owner).ClientAdjustGlow(0.2,vect(0,0,-200));
	}

	if (AmmoType != None)
	{
		AmmoType.bActive = bPlasmaActive;
		WFRDUAmmo(AmmoType).bRecharge = !bPlasmaActive;
	}

	GotoState('AltFiring');
}

function CreateEffect()
{
	MyEffect = spawn(class'WFRDUShieldEffect', Owner);
}

function NotEnoughAmmo()
{
	if (bPlasmaActive)
	{
		bPlasmaActive = false;
		pawn(owner).ClientMessage("Defense shield deactivated.", 'CriticalEvent');
		if (MyEffect != None)
			MyEffect.bHidden = true;
		if ( Owner.IsA('PlayerPawn') )
			PlayerPawn(Owner).ClientAdjustGlow(0.2,vect(0,0,-200));
	}
}

function int ArmorAbsorbDamage(int Damage, name DamageType, vector HitLocation)
{
	local int ArmorDamage;
	local vector X, Y, Z;
	local float Scale;

	if ( DamageType != 'Drowned' )
		ArmorImpactEffect(HitLocation);
	if( (DamageType!='None') && ((ProtectionType1==DamageType) || (ProtectionType2==DamageType)) )
		return 0;

	//if ((DamageType=='Drowned') || (DamageType=='Railed'))
	//	Return Damage;
	if (DamageType=='Drowned')
		Return Damage;

	if (bPlasmaActive && (HitLocation != vect(0,0,0)))
	{
		GetAxes(Owner.Rotation, X, Y, Z);
		if (PiercingDamageScale > 0.0)
		{
			Scale = PiercingDamageScale;
			PiercingDamageScale = 0.0; // reset piercing damage coef
		}
		else if ((Normal(HitLocation - Owner.Location) Dot X) > ShieldAngle)
			Scale = AbsorbtionRatio;
		else Scale = 1.0;

		return Damage * Scale;
	}

	return Damage;
}

function ArmorImpactEffect(vector HitLocation)
{
	local vector X, Y, Z;
	if (bPlasmaActive && (HitLocation != vect(0,0,0)))
	{
		GetAxes(Owner.Rotation, X, Y, Z);
		if ((Normal(HitLocation - Owner.Location) Dot X) > ShieldAngle)
		{
			if (FRand() < 0.5)
				spawn(class'WFSparks',,, HitLocation, rotator(HitLocation-Owner.Location));
		}
	}
}

simulated function PlayAltFiring()
{
	if (Owner != None)
	{
		if ( Affector != None )
			Affector.FireEffect();
		PlayOwnedSound(AltFireSound, SLOT_Misc, 1.7*Pawn(Owner).SoundDampening);
		PlayAnim( 'Fire', 0.65);
	}
}

function Destroyed()
{
	if (MyEffect != None)
		MyEffect.Destroy();
	if (bPlasmaActive && Owner.IsA('PlayerPawn'))
		PlayerPawn(Owner).ClientAdjustGlow(0.2,vect(0,0,-200));
	super.Destroyed();
}

State DownWeapon
{
	function BeginState()
	{
		if (bPlasmaActive)
		{
			bPlasmaActive = false;
			pawn(owner).ClientMessage("Defense shield deactivated.", 'CriticalEvent');
			if (MyEffect != None)
				MyEffect.bHidden = true;
			if (Owner.IsA('PlayerPawn'))
				PlayerPawn(Owner).ClientAdjustGlow(0.2,vect(0,0,-200));
			if (AmmoType != None)
			{
				AmmoType.bActive = bPlasmaActive;
				WFRDUAmmo(AmmoType).bRecharge = !bPlasmaActive;
			}
		}
		super.BeginState();
	}
}
//-----------------
// Radius push code
function RadiusPush()
{
	local effects e;
	local vector momentum, X, Y, Z;
	local float scale;

	if (Owner != None)
	{
		scale = FClamp(ChargeSize, 0.5, 4);

		// calculate upward push
		momentum = vect(0,0,1)*UpwardPush*scale;

		// add some directional momentum
		//GetAxes(Pawn(Owner).ViewRotation, X, Y, Z);
		//X.Z = 0.0; // only interested in left/right direction
		//momentum += normal(X)*ForwardPush*scale;
		//if ((owner.Physics == PHYS_Falling) && (Owner.Velocity.Z < 0.0))
		//	Owner.Velocity.Z = 0.0;

		Pawn(Owner).AddVelocity(momentum);

		if (ChargeSize > 2.0)
			e = spawn(class'WFRDUJumpEffect',,, Owner.Location - vect(0,0,0.9)*owner.CollisionHeight, rotator(vect(1,0,0)));
		else
			e = spawn(class'WFRDUJumpEffectSmall',,, Owner.Location - vect(0,0,0.9)*owner.CollisionHeight, rotator(vect(1,0,0)));

		if (e != None)
			e.PlaySound(sound'Expl04');
	}
}

// ------------------
// Impact Hammer code

function float RateSelf( out int bUseAltMode )
{
	local float EnemyDist;
	local bool bRetreating;
	local Pawn P;

	bUseAltMode = 0;
	P = Pawn(Owner);

	if ( (P == None) || (P.Enemy == None) )
		return 0;

	EnemyDist = VSize(P.Enemy.Location - Owner.Location);
	if ( (EnemyDist < 750) && P.IsA('Bot') && Bot(P).bNovice && (P.Skill <= 2) && !P.Enemy.IsA('Bot') && (ImpactHammer(P.Enemy.Weapon) != None) )
		return FClamp(300/(EnemyDist + 1), 0.6, 0.75);

	if ( EnemyDist > 400 )
		return 0.1;
	if ( (P.Weapon != self) && (EnemyDist < 120) )
		return 0.25;

	return ( FMin(0.8, 81/(EnemyDist + 1)) );
}

function float SuggestAttackStyle()
{
	return 10.0;
}

function float SuggestDefenseStyle()
{
	return -2.0;
}

simulated function PlayPostSelect()
{
	local Bot B;

	if ( Level.NetMode == NM_Client )
	{
		Super.PlayPostSelect();
		return;
	}

	B = Bot(Owner);

	if ( (B != None) && (B.Enemy != None) )
	{
		B.PlayFiring();
		B.bFire = 1;
		B.bAltFire = 0;
		Fire(1.0);
	}
}

simulated function bool ClientFire( float Value )
{
	if ( bCanClientFire )
	{
		if ( (PlayerPawn(Owner) != None)
			&& ((Level.NetMode == NM_Standalone) || PlayerPawn(Owner).Player.IsA('ViewPort')) )
		{
			if ( InstFlash != 0.0 )
				PlayerPawn(Owner).ClientInstantFlash( InstFlash, InstFog);
			PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
		}
		if ( Affector != None )
			Affector.FireEffect();
		Owner.PlayOwnedSound(Misc1Sound, SLOT_Misc, 1.3*Pawn(Owner).SoundDampening);
		PlayAnim('Pull', 0.2, 0.05);
		if ( Role < ROLE_Authority )
			GotoState('ClientFiring');
		return true;
	}
	return false;
}

simulated function ClientWeaponEvent(name EventType)
{
	if ( EventType == 'FireBlast' )
	{
		PlayFiring();
		GotoState('ClientFireBlast');
	}
}

simulated function PlayFiring()
{
	if (Owner != None)
	{
		if ( Affector != None )
			Affector.FireEffect();
		Owner.PlayOwnedSound(FireSound, SLOT_Misc, 1.7*Pawn(Owner).SoundDampening,,,);
		if ( PlayerPawn(Owner) != None )
			PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
		PlayAnim( 'Fire', 0.65 );
	}
}

state ClientFiring
{
	simulated function AnimEnd()
	{
		AmbientSound = TensionSound;
		SoundVolume = 255*Pawn(Owner).SoundDampening;
		LoopAnim('Shake', 0.9);
		Disable('AnimEnd');
	}
}

state FireBlast
{
	function Fire(float F)
	{
	}
	function AltFire(float F)
	{
	}

Begin:
	if ( (Level.NetMode != NM_Standalone) && Owner.IsA('PlayerPawn')
		&& (ViewPort(PlayerPawn(Owner).Player) == None) )
		PlayerPawn(Owner).ClientWeaponEvent('FireBlast');
	FinishAnim();
	Finish();
}

state ClientFireBlast
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
		if ( Pawn(Owner) == None )
		{
			PlayIdleAnim();
			GotoState('');
		}
		else if ( !bCanClientFire )
			GotoState('');
		else if ( Pawn(Owner).bFire != 0 )
			Global.ClientFire(0);
		else if ( Pawn(Owner).bAltFire != 0 )
			Global.ClientAltFire(0);
		else
		{
			PlayIdleAnim();
			GotoState('');
		}
	}
}

simulated function PlayIdleAnim()
{
	local Bot B;

	B = Bot(Owner);

	if ( (B != None) && (B.Enemy != None) )
	{
		B.PlayFiring();
		B.bFire = 1;
		B.bAltFire = 0;
		Fire(1.0);
	}
	else if ( Mesh != PickupViewMesh )
		TweenAnim( 'Still', 1.0);
}

defaultproperties
{
	bIsAnArmor=True
	AbsorbtionRatio=0.0
	ForceMag=50000
	ForceDamage=10
	MaxForceDamage=40
	MaxForceMag=150000
	ForceRadius=350
	AmmoName=class'WFRDUAmmo'
	PickupAmmoCount=50
	MaxChargeSize=4.0
	PickupMessage="You got the Recon Defense Unit."
	ItemName="Recon Defense Unit"
	// need to change these
	RefireRate=1.000000
	AltRefireRate=1.000000
	AutoSwitchPriority=0
	DeathMessage="%o got caught in %k's air blast."
	//PlayerViewOffset=(X=5.000000,Y=-4.200000,Z=-7.000000)
	Mass=15
	//PlayerViewMesh=LodMesh'Botpack.Transloc'
	//PickupViewMesh=LodMesh'Botpack.Trans3loc'
	//ThirdPersonMesh=LodMesh'Botpack.Trans3loc'
     AltFireSound=Sound'Botpack.ASMD.ImpactFire'
     TensionSound=Sound'Botpack.ASMD.ImpactLoop'
     WeaponDescription="Classification: Recon Defense Unit\n\nPrimary Fire:\n\nSecondary Fire: Activates/Deactivates forward defense shield\n\nTechniques:"
     InstFog=(X=475.000000,Y=325.000000,Z=145.000000)
     bMeleeWeapon=True
     bRapidFire=True
     MyDamageType=impact
     RefireRate=1.000000
     AltRefireRate=1.000000
     FireSound=Sound'Botpack.ASMD.ImpactAltFireRelease'
     SelectSound=Sound'Botpack.ASMD.ImpactPickup'
     Misc1Sound=Sound'Botpack.ASMD.ImpactAltFireStart'
     NameColor=(G=192,B=0)
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Icon=Texture'Botpack.Icons.UseHammer'
     Mesh=LodMesh'Botpack.ImpPick'
     bNoSmooth=False
     SoundRadius=50
     SoundVolume=200
     //AutoSwitchPriority=1
     InventoryGroup=2
     AutoSwitchPriority=2
     PlasmaEnergyRate=3
     ShieldAngle=0.200000
     UpwardPush=165.000000
     PlayerViewOffset=(X=2.000000,Y=-1.500000,Z=-3.600000)
     PlayerViewMesh=SkeletalMesh'WFMedia.ckrdufirst1Mesh'
     PlayerViewScale=0.300000
     ThirdPersonMesh=LodMesh'WFMedia.rduthird'
     ThirdPersonScale=1.500000
     StatusIcon=Texture'WFMedia.WeaponRDU'
     AbsorptionPriority=255
     MultiSkins(4)=ScriptedTexture'Botpack.Ammocount.miniammoled'
}
