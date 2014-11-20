//=============================================================================
// WFCloaker.
//=============================================================================
class WFCloaker extends TournamentPickup;

var() int MaxCharge;
var() int MinChargeToActivate;

var WFCloakEffect MyEffect;
var effects MotionEffect;
var bool bFadeIn;
var int ActivateDelay;

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
	/*if (!bActive)
		Charge = Min(Charge + 1, MaxCharge);
	else
	{
		Charge--;
		Pawn(Owner).Visibility = 10;
		if (Charge <= 0)
			Activate();
	}*/
}

state Activated
{
	function BeginState()
	{
		bActive = true;
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
		else if (((pawn(Owner).bFire != 0) || (pawn(Owner).bAltFire != 0))
			&& !ValidWeapon(pawn(Owner).Weapon))
		{
			ActivateDelay = 0;
			Activate();
		}
		else if (VSize(Owner.Velocity) < 50.0)
			Owner.bHidden = true;
		else if (!Owner.IsInState('Dying'))
			Owner.bHidden = false;

		if (MotionEffect != None)
			MotionEffect.bHidden = !bActive || (bActive && (VSize(Owner.Velocity) < 250.0));

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
		if( PawnOwner.Inventory != None )
			PawnOwner.Inventory.SetOwnerDisplay();
		MotionEffect.bHidden = True;
	}
}

function bool ValidWeapon(Weapon Other, optional bool bAltFired)
{
	if ((Other == None) || Other.IsA('WFTranslocator')
		|| (bAltFired && Other.IsA('WFTaser')) )
		return true;
	return false;
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
			ActivateDelay = 2;
		}
		SetTimer(1.0, true);
		MotionEffect.bHidden = True;
	}

	function Tick( float DeltaTime )
	{
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

		//if ((Charge > 0) && (Charge >= MinChargeToActivate))
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

defaultproperties
{
	bActivatable=True
	bDisplayableInv=True
	MaxCharge=30
	Charge=30
	RemoteRole=ROLE_DumbProxy
	PickupViewMesh=LodMesh'Botpack.invis2M'
	Mesh=LodMesh'Botpack.invis2M'
	ActivateSound=Sound'UnrealI.Pickups.Invisible'
	DeActivateSound=Sound'UnrealI.Pickups.Invisible'
	MinChargeToActivate=5
}
