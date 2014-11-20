//============================================================
// WFS_PCSBotWeaponMarker.
//
// Used for bot inventory AI purposes.
//============================================================
class WFS_PCSBotWeaponMarker expands TournamentWeapon;

var weapon WeaponItem;

event float BotDesireability(Pawn Bot)
{
	local WFS_PCSystemBot PCSBot;

	if (GetStateName() == 'Sleeping')
		return -1;

	PCSBot = WFS_PCSystemBot(Bot);
	if ((PCSBot != None) && !PCSBot.CanCollectItem(WeaponItem))
		return -1;

	return WeaponItem.BotDesireability(Bot);
}

auto state Pickup
{
	function BeginState()
	{
		super.BeginState();
		SetTimer(0.01, false);
	}

	function Timer()
	{
		if ((WeaponItem != None) && !WeaponItem.IsInState('Idle2'))
			DisableItem(WeaponItem);
		else if (WeaponItem == None)
		{
			Log(name$": Setting timer...");
			SetTimer(0.01, false);
		}
	}

	function bool ValidTouch( actor Other )
	{
		local Actor A;
		local bool bResult;

		if( Other.bIsPawn && Pawn(Other).bIsPlayer && (Pawn(Other).Health > 0)
			&& Level.Game.PickupQuery(Pawn(Other), WeaponItem) )
		{
			if( Event != '' )
				foreach AllActors( class 'Actor', A, WeaponItem.Event )
					A.Trigger( Other, Other.Instigator );
			return true;
		}

		if ((WeaponItem == none) || WeaponItem.bDeleteMe)
			Destroy();
		else if (WeaponItem.IsInState('Sleeping'))
		{
			DisableItem(WeaponItem);
			GotoState('Sleeping');
		}

		return bResult;
	}

	// When touched by an actor.
	function Touch( actor Other )
	{
		// If touched by a player pawn, let him pick this up.
		if( ValidTouch(Other) )
		{
			if (Level.Game.LocalLog != None)
				Level.Game.LocalLog.LogPickup(WeaponItem, Pawn(Other));
			if (Level.Game.WorldLog != None)
				Level.Game.WorldLog.LogPickup(WeaponItem, Pawn(Other));
			SpawnCopy(Pawn(Other));
			if ( WeaponItem.PickupMessageClass == None )
				Pawn(Other).ClientMessage(WeaponItem.PickupMessage, 'Pickup');
			else
				Pawn(Other).ReceiveLocalizedMessage( WeaponItem.PickupMessageClass, 0, None, None, WeaponItem.Class );
			PlaySound(WeaponItem.PickupSound);
			if ( Level.Game.Difficulty > 1 )
				Other.MakeNoise(0.1 * Level.Game.Difficulty);
			if ( Pawn(Other).MoveTarget == self )
				Pawn(Other).MoveTimer = -1.0;
		}
		/*else if ( bTossedOut && (Other.Class == Class)
				&& Inventory(Other).bTossedOut )
				Destroy();*/
	}
}

function InitFor(weapon Item)
{
	local int i;

	//Log(name$".InitFor() called for: "$Item);

	if (bDeleteMe || (Item == None))
	{
		Destroy();
		return;
	}

	//Log(name$" setting up properties for: "$Item);
	Acceleration = Item.Acceleration;
	Velocity = Item.Velocity;

	// hide the actual weapon
	WeaponItem = Item;
	if (WeaponItem.MyMarker != None)
		WeaponItem.MyMarker.MarkedItem = self;
	//	WeaponItem.MyMarker.MarkedItem = None;
	//DisableItem(WeaponItem);

	/* set up properties
	DrawScale = WeaponItem.DrawScale;
	PrePivot = WeaponItem.PrePivot;
	PickupViewMesh = WeaponItem.PickupViewMesh;
	PickupViewScale = WeaponItem.PickupViewScale;
	bRotatingPickup = WeaponItem.bRotatingPickup;
	RespawnTime = WeaponItem.RespawnTime;
	RespawnSound = WeaponItem.RespawnSound;
	Texture = WeaponItem.Texture;
	Skin = WeaponItem.Skin;
	AmbientGlow = WeaponItem.AmbientGlow;
	bToggleSteadyFlash = WeaponItem.bToggleSteadyFlash;
	bNoSmooth = WeaponItem.bNoSmooth;*/

	MaxDesireability = WeaponItem.MaxDesireability;
	SetCollisionSize(WeaponItem.CollisionRadius, WeaponItem.CollisionHeight);

	/*if (WeaponItem.bRotatingPickup)
		SetPhysics(PHYS_Rotating);
	for (i=0; i<8; i++)
		MultiSkins[i] = WeaponItem.MultiSkins[i];*/
}

function inventory SpawnCopy( pawn Other )
{
	local inventory Copy;
	local Weapon newWeapon;

	Copy = spawn(WeaponItem.Class,Other,,,rot(0,0,0));
	Copy.Tag         	= WeaponItem.Tag;
	Copy.Event       	= WeaponItem.Event;
	Copy.RespawnTime	= 0.0;
	Copy.bHeldItem 		= true;
	Copy.bTossedOut		= false;
	Copy.GiveTo( Other );

	newWeapon = Weapon(Copy);
	newWeapon.Instigator = Other;
	newWeapon.GiveAmmo(Other);
	newWeapon.SetSwitchPriority(Other);
	if ( !Other.bNeverSwitchOnPickup )
		newWeapon.WeaponSet(Other);
	newWeapon.AmbientGlow = 0;

	if (Level.Game.ShouldRespawn(WeaponItem))
	{
		if (!bWeaponStay)
			GotoState('Sleeping');
	}
	else
	{
		WeaponItem.Destroy();
		Destroy();
	}

	return newWeapon;
}

function DisableItem(inventory Item, optional bool bHideItem)
{
	//Log(name$".DisableItem() called for: "$Item);
	Item.bHidden = bHideItem;
	Item.SetCollision( false, false, false );
	Item.SetTimer(0.0,False);
	Item.GotoState('Idle2');
}

function BecomePickup()
{
	if (WeaponItem != None)
		WeaponItem.bHidden = false;
}

function BecomeItem()
{
}

State Sleeping
{
	ignores Touch;

	function BeginState()
	{
		WeaponItem.bHidden = true;
		bHidden = true;
	}

	function EndState()
	{
		local int i;

		bSleepTouch = false;
		for ( i=0; i<4; i++ )
			if ( (Touching[i] != None) && Touching[i].IsA('Pawn') )
				bSleepTouch = true;
	}
Begin:
	Sleep( WeaponItem.ReSpawnTime );
	PlaySound( WeaponItem.RespawnSound );
	Sleep( Level.Game.PlaySpawnEffect(WeaponItem) );
	GoToState( 'Pickup' );
}

defaultproperties
{
	RemoteRole=ROLE_None
}