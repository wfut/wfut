//============================================================
// WFS_PCSBotPickupMarker.
//
// Used for bot inventory AI purposes.
//============================================================
class WFS_PCSBotPickupMarker expands TournamentPickup;

var pickup PickupItem;
var bool bIsHealth;

event float BotDesireability(Pawn Bot)
{
	local WFS_PCSystemBot PCSBot;

	PCSBot = WFS_PCSystemBot(Bot);
	if ((PCSBot != None) && !PCSBot.CanCollectItem(PickupItem))
		return -1;

	return PickupItem.BotDesireability(Bot);
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
		if ((PickupItem != None) && !PickupItem.IsInState('Idle2'))
			DisableItem(PickupItem);
		else if (PickupItem == None)
		{
			Log(name$": Setting timer...");
			SetTimer(0.01, false);
		}
	}

	function bool ValidTouch( actor Other )
	{
		local Actor A;
		local pawn aPawn;

		if( Other.bIsPawn && Pawn(Other).bIsPlayer && (Pawn(Other).Health > 0)
			&& Level.Game.PickupQuery(Pawn(Other), PickupItem) )
		{
			if( Event != '' )
				foreach AllActors( class 'Actor', A, Event )
					A.Trigger( Other, Other.Instigator );
			return true;
		}

		if ((PickupItem == none) || PickupItem.bDeleteMe)
			Destroy();
		else if (PickupItem.IsInState('Sleeping'))
		{
			//Log(name$".ValidTouch(): calling disable item for: "$PickupItem);
			DisableItem(PickupItem);
			GotoState('Sleeping');
		}

		/*if (Other.bIsPawn)
		{
			aPawn = Pawn(Other);
			if (aPawn.MoveTarget == self)
				aPawn.MoveTimer = -1;
		}*/

		return false;
	}

	// When touched by an actor.
	function Touch( actor Other )
	{
		local Inventory Copy;
		local pawn aPawn;

		// If touched by a player pawn, let him pick this up.
		if ( ValidTouch(Other) )
		{
			aPawn = Pawn(Other);
			Copy = SpawnCopy(aPawn);
			if (Level.Game.LocalLog != None)
				Level.Game.LocalLog.LogPickup(PickupItem, aPawn);
			if (Level.Game.WorldLog != None)
				Level.Game.WorldLog.LogPickup(PickupItem, aPawn);
			if (PickupItem.bActivatable && aPawn.SelectedItem==None)
				aPawn.SelectedItem=Copy;
			if (PickupItem.bActivatable && PickupItem.bAutoActivate && aPawn.bAutoActivate) Copy.Activate();
			if ( PickupItem.PickupMessageClass == None )
				aPawn.ClientMessage(PickupItem.PickupMessage, 'Pickup');
			else
				aPawn.ReceiveLocalizedMessage( PickupItem.PickupMessageClass, 0, None, None, PickupItem.Class );
			PlaySound(PickupItem.PickupSound,,2.0);
			//if (aPawn.MoveTarget == self)
			//	aPawn.MoveTimer = -1;
			Pickup(Copy).PickupFunction(aPawn);

			if (PickupItem.IsInState('Sleeping'))
			{
				//Log(name$".ValidTouch(): calling disable item for: "$PickupItem);
				DisableItem(PickupItem);
				GotoState('Sleeping');
			}
		}
	}
}

function InitFor(pickup Item)
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
	//if (Item.Base != None)
	//	SetBase(Item.Base);

	// disable the item
	PickupItem = Item;
	if (PickupItem.MyMarker != None)
		PickupItem.MyMarker.MarkedItem = self;
	//	PickupItem.MyMarker.MarkedItem = None;
	//DisableItem(PickupItem);

	bIsHealth = PickupItem.IsA('TournamentHealth');

	/* set up properties
	DrawScale = PickupItem.DrawScale;
	PrePivot = PickupItem.PrePivot;
	PickupViewMesh = PickupItem.PickupViewMesh;
	bRotatingPickup = PickupItem.bRotatingPickup;
	RespawnTime = PickupItem.RespawnTime;
	RespawnSound = PickupItem.RespawnSound;
	Texture = PickupItem.Texture;
	Skin = PickupItem.Skin;
	AmbientGlow = PickupItem.AmbientGlow;
	bToggleSteadyFlash = PickupItem.bToggleSteadyFlash;*/

	MaxDesireability = PickupItem.MaxDesireability;
	SetCollisionSize(PickupItem.CollisionRadius, PickupItem.CollisionHeight);

	/*if (PickupItem.bRotatingPickup)
		SetPhysics(PHYS_Rotating);
	for (i=0; i<8; i++)
		MultiSkins[i] = PickupItem.MultiSkins[i];*/
}

function inventory SpawnCopy( pawn Other )
{
	local inventory Copy;

	if( Level.Game.ShouldRespawn(PickupItem) )
	{
		Copy = spawn(PickupItem.Class,Other,,,rot(0,0,0));
		Copy.Tag           = Tag;
		Copy.Event         = Event;
		GotoState('Sleeping');
	}
	else
	{
		PickupItem.Destroy();
		Destroy();
	}

	Copy.RespawnTime = 0.0;
	Copy.bHeldItem = true;
	Copy.GiveTo( Other );

	return Copy;
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
	if (PickupItem != None)
		PickupItem.bHidden = false;
}

function BecomeItem()
{
}

State Sleeping
{
	ignores Touch;

	function BeginState()
	{
		PickupItem.bHidden = true;
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
	Sleep( PickupItem.ReSpawnTime );
	PlaySound( PickupItem.RespawnSound );
	Sleep( Level.Game.PlaySpawnEffect(PickupItem) );
	GoToState( 'Pickup' );
}

defaultproperties
{
	RemoteRole=ROLE_None
}