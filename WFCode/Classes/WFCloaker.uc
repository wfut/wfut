//=============================================================================
// WFCloaker.
//=============================================================================
class WFCloaker extends WFPickup;

var() int MaxCharge;
var() int MinChargeToActivate;
var() int ReChargeRate;

var WFCloakEffect MyEffect;
var effects MotionEffect;
var bool bFadeIn;
var int ActivateDelay;

var bool bPlayerMoving;
var bool bMovementDrainOnly;

var int WeaponCost, GrenadeCost;

function PreBeginPlay()
{
	bAutoActivate = false;
}

function bool HandlePickupQuery( inventory Item )
{
	if (Item.IsA('ut_invisibility'))
	{
		Charge = Min(Charge + Item.Charge, MaxCharge);
		if (Level.Game.LocalLog != None)
			Level.Game.LocalLog.LogPickup(Item, Pawn(Owner));
		if (Level.Game.WorldLog != None)
			Level.Game.WorldLog.LogPickup(Item, Pawn(Owner));
		if ( Item.PickupMessageClass == None )
			Pawn(Owner).ClientMessage(item.PickupMessage, 'Pickup');
		else
			Pawn(Owner).ReceiveLocalizedMessage( item.PickupMessageClass, 0, None, None, item.Class );
		Item.PlaySound(Item.PickupSound,,2.0);
		Item.SetReSpawn();
		return true;
	}

	if (Inventory == None)
		return false;

	return Inventory.HandlePickupQuery(Item);
}

function Timer()
{
	if (ActivateDelay > 0)
		ActivateDelay--;
	if (!bActive)
		Charge = Min(Charge + ReChargeRate, MaxCharge);
	else
	{
		if (!bMovementDrainOnly || bPlayerMoving)
			Charge = Max(Charge - 1, 0);
		Pawn(Owner).Visibility = 10;
	}
	bPlayerMoving = false;
}

state Activated
{
	function BeginState()
	{
		bActive = true;
		if (Owner != None)
			Owner.PlaySound(ActivateSound,,12.0);
		SetOwnerDisplay();
		MyEffect.FadeOut();
		SetTimer(1.0, true);
		ActivateDelay = 2;
	}

	function SetOwnerDisplay()
	{
		if ( !bActive )
			return;
		Owner.SetDisplayProperties(ERenderStyle.STY_Translucent,
							 FireTexture'unrealshare.Belt_fx.Invis',
							 true,
							 true);
		if( Inventory != None )
			Inventory.SetOwnerDisplay();
	}

	function ChangedWeapon()
	{
		if ( !bActive )
			return;
		if( Inventory != None )
			Inventory.ChangedWeapon();

		// Make new weapon invisible.
		if ( Pawn(Owner).Weapon != None )
			Pawn(Owner).Weapon.SetDisplayProperties(ERenderStyle.STY_Translucent,
									 FireTexture'Unrealshare.Belt_fx.Invis',
									 true,
									 true);
	}

	function Tick(float DeltaTime)
	{
		if ((Owner != None) && (pawn(Owner).PlayerReplicationInfo.HasFlag != None))
		{
			ActivateDelay = 0;
			Activate();
		}
		bPlayerMoving = bPlayerMoving || (VSize(Owner.Velocity) > 10);
		// FIXME - move this notify to WFWeapon
		//else if (((pawn(Owner).bFire != 0) || (pawn(Owner).bAltFire != 0))
		//	&& !ValidWeapon(pawn(Owner).Weapon, pawn(Owner).bAltFire != 0))
		//	PlayerFired(pawn(Owner).Weapon);

		if (Charge == 0)
		{
			// render cloak useless vs defences when charge is 0
			Owner.texture = Texture'JDomN0';
			Owner.bHidden = false;
			Owner.ScaleGlow = 0.5;
			if (pawn(Owner).Visibility == 10)
				pawn(Owner).Visibility = pawn(Owner).default.Visibility;
		}
		else if (VSize(Owner.Velocity) < 50.0)
			Owner.bHidden = true;
		else if (!Owner.IsInState('Dying'))
			Owner.bHidden = false;

		if (MotionEffect != None)
			MotionEffect.bHidden = !bActive || (bActive && (Charge > 0));

		super.Tick(DeltaTime);
	}

	function Activate()
	{
		if (ActivateDelay > 0)
			return;

		super.Activate();
	}

	function EndState()
	{
		local pawn PawnOwner;
		PawnOwner = pawn(Owner);

		bActive = false;
		bFadeIn = true;

		if (!PawnOwner.IsInState('Dying'))
			PawnOwner.bHidden = false;
		if (PawnOwner.Visibility == 10)
			PawnOwner.Visibility = PawnOwner.default.Visibility;
		PawnOwner.SetDefaultDisplayProperties();
		Owner.ScaleGlow = 1.0; // should be the default
		if( PawnOwner.Inventory != None )
			PawnOwner.Inventory.SetOwnerDisplay();
		MotionEffect.bHidden = True;
	}
}

static function bool IsCloaked(pawn Other)
{
	return (Other == None) || (Other.bMeshEnviroMap && (Other.Texture == FireTexture'Unrealshare.Belt_fx.Invis'));
}

static function bool IsHalfCloaked(pawn Other)
{
	return (Other == None) || (Other.bMeshEnviroMap && (Other.Texture == Texture'JDomN0'));
}


function bool ValidWeapon(Weapon Other, optional bool bAltFired)
{
	if ((Other == None) || Other.IsA('WFTranslocator')
		|| (bAltFired && Other.IsA('WFTaser')) )
		return true;
	return false;
}

// send this from WFWeapon
function WeaponFired(Weapon WeaponUsed)
{
	local WFMotionBlurEffect e;
	if (!bActive)
		return;

	if (ValidWeapon(pawn(Owner).Weapon, pawn(Owner).bAltFire != 0))
		return; // ok to use this weapon type while cloaked

	e = spawn(class'WFCloakerShootPulse', Owner,, Owner.Location, Owner.Rotation);
	e.InitFor(owner);

	Charge = Max(Charge - WeaponCost, 0);
	//Owner.PlaySound(sound'TDisrupt', SLOT_None, 4.0);
}

function GrenadeThrown(WFGrenadeItem GrenadeUsed)
{
	local WFMotionBlurEffect e;

	if (!bActive)
		return;

	e = spawn(class'WFCloakerShootPulse', Owner,, Owner.Location, Owner.Rotation);
	e.InitFor(owner);

	Charge = Max(Charge - GrenadeCost, 0);
	//Owner.PlaySound(sound'TDisrupt', SLOT_None, 4.0);
}

auto state DeActivated
{
	function BeginState()
	{
		if (bFadeIn)
		{
			Owner.PlaySound(DeActivateSound);
			if (MyEffect != None)
				MyEffect.FadeIn();
			if (Charge <= 0) // need extra time if charge was all used up
				ActivateDelay = 5;
			else ActivateDelay = 2;
		}
		SetTimer(1.0, true);
		if (MotionEffect != None)
			MotionEffect.bHidden = True;
	}

	function Tick( float DeltaTime )
	{
		bPlayerMoving = bPlayerMoving || (VSize(Owner.Velocity) > 10);
		if ((MyEffect != None) && !(MyEffect.FadeMode == 1))
		{
			if (Owner != None)
			{
				Owner.SetDefaultDisplayProperties();
				if( Owner.Inventory != None )
					Owner.Inventory.SetOwnerDisplay();
			}
		}
	}

	function Activate()
	{
		if (ActivateDelay > 0)
			return;

		if (pawn(Owner).PlayerReplicationInfo.HasFlag != None)
			return;

		if ((Charge > 0) && (Charge >= MinChargeToActivate))
			GotoState('Activated');
	}

}

function Destroyed()
{
	local pawn PawnOwner;

	bActive = false; // just to be safe
	PawnOwner = pawn(Owner);
	if ( PawnOwner != None )
	{
		if (!PawnOwner.IsInState('Dying'))
			PawnOwner.bHidden = false;
		if (PawnOwner.Visibility == 10)
			PawnOwner.Visibility = PawnOwner.default.Visibility;
		PawnOwner.SetDefaultDisplayProperties();
		if( PawnOwner.Inventory != None )
			PawnOwner.Inventory.SetOwnerDisplay();
	}
	if ( MyEffect != None )
		MyEffect.Destroy();
	if ( MotionEffect != None )
		MotionEffect.Destroy();
	Super.Destroyed();
}

function GiveTo(pawn Other)
{
	super.GiveTo(Other);
	if (Owner != None)
		CreateEffect();
}

function CreateEffect()
{
	if ((MyEffect == None) && (Role == ROLE_Authority))
		MyEffect = spawn(class'wfcloakeffect', Owner,, Owner.Location, Owner.Rotation);
	if ((MotionEffect == None) && (Role == ROLE_Authority))
	{
		MotionEffect = spawn(class'WFCloakMotionBlur', Owner,, Owner.Location, Owner.Rotation);
		MotionEffect.ScaleGlow = 0.5;
		MotionEffect.Mesh = Owner.Mesh;
		MotionEffect.SetDisplayProperties(ERenderStyle.STY_Translucent,
							 Texture'JDomN0',
							 true,
							 true);
	}
}

function Tick(float DeltaTime)
{
	super.Tick(DeltaTime);
	bPlayerMoving = bPlayerMoving || (VSize(Owner.Velocity) > 10);
}

defaultproperties
{
	bActivatable=True
	bDisplayableInv=True
	MaxCharge=100
	Charge=100
	RemoteRole=ROLE_DumbProxy
	PickupViewMesh=LodMesh'Botpack.invis2M'
	Mesh=LodMesh'Botpack.invis2M'
	ActivateSound=Sound'UnrealI.Pickups.Invisible'
	DeActivateSound=Sound'UnrealI.Pickups.Invisible'
	MinChargeToActivate=5
	RechargeRate=2
	bMovementDrainOnly=True
	WeaponCost=5
	GrenadeCost=10
}
