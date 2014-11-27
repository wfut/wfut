class WFMutator extends DMMutator;

var bool bRegistered;

function bool AlwaysKeep(Actor Other)
{
	local bool bTemp;

	if ( Other.IsA('StationaryPawn') || Other.IsA('WFS_PCSBotWeaponMarker') || Other.IsA('WFS_PCSBotPickupMarker'))
		return true;

	if ( NextMutator != None )
		return ( NextMutator.AlwaysKeep(Other) );
	return false;
}

function CreateInventoryMarkerFor(inventory Item)
{
	local WFS_PCSBotWeaponMarker WM;
	local WFS_PCSBotPickupMarker PM;

	if (Item != None)
	{
		if (Item.IsA('Weapon') && !Item.IsA('WFS_PCSBotWeaponMarker'))
		{
			WM = spawn(class'WFS_PCSBotWeaponMarker',,, Item.Location, Item.Rotation);
			if (WM == None) Log(self$": WARNING: WM == none!");
			WM.InitFor(weapon(Item));
			if (Item.MyMarker != None)
				Item.MyMarker.MarkedItem = WM;
		}

		if (Item.IsA('Pickup') && !Item.IsA('WFS_PCSBotPickupMarker'))
		{
			PM = spawn(class'WFS_PCSBotPickupMarker',,, Item.Location, Item.Rotation);
			if (PM == None) Log(self$": WARNING: PM == none!");
			PM.InitFor(pickup(Item));
			if (Item.MyMarker != None)
				Item.MyMarker.MarkedItem = PM;
		}
	}
}

function Tick(float DeltaTime)
{
	if (!bRegistered)
	{
		Level.Game.RegisterMessageMutator(self);
		bRegistered = True;
		Disable('Tick');
	}
}

// catch and filter mesage broadcasts
function bool MutatorBroadcastLocalizedMessage( Actor Sender, Pawn Receiver, out class<LocalMessage> Message, out optional int Switch, out optional PlayerReplicationInfo RelatedPRI_1, out optional PlayerReplicationInfo RelatedPRI_2, out optional Object OptionalObject )
{
	local actor theOwner;

	for (theOwner=Sender; theOwner!=None; theOwner=theOwner.Owner)
		if (theOwner.IsA('PlayerPawn') && (NetConnection(playerpawn(theOwner).Player)!=None))
			return false; // quietly filter out the attempt

	if ( NextMessageMutator != None )
		return NextMessageMutator.MutatorBroadcastLocalizedMessage( Sender, Receiver, Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );
	else
		return true;
}

function bool MutatorBroadcastMessage( Actor Sender, Pawn Receiver, out coerce string Msg, optional bool bBeep, out optional name Type )
{
	local actor theOwner;
	local string IP;
	local int j;

	for (theOwner=Sender; theOwner!=None; theOwner=theOwner.Owner)
		if (theOwner.IsA('PlayerPawn') && (NetConnection(playerpawn(theOwner).Player)!=None))
			return false; // quietly filter out the message

	if ( NextMessageMutator != None )
		return NextMessageMutator.MutatorBroadcastMessage( Sender, Receiver, Msg, bBeep, Type );
	else
		return true;
}

