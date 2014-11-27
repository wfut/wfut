//=============================================================================
// WFDemoMan.
//=============================================================================
class WFDemoMan extends WFPlayerClassInfo;

var int MaxTripmines;

static function bool IsClientSideCommand(string SpecialString)
{
	if (SpecialString == "")
		return true;

	return false;
}

static function PlayerDied(pawn Other, pawn Killer, name damageType, vector HitLocation)
{
	local WFGrenFreezeProj g;
	local WFPipeBombTrigger PBT;

	// remove any active Freeze Grenades
	foreach Other.AllActors(class'WFGrenFreezeProj', g)
	{
		if ((g != None) && !g.bDeleteMe && (g.Instigator == Other))
			g.Timer(); // make grenades expire early
	}

	// remove any active Pipebomb Triggers
	foreach Other.AllActors(class'WFPipeBombTrigger', PBT)
	{
		if ((PBT != None) && !PBT.bDeleteMe && (PBT.Instigator == Other))
			PBT.Destroy();
	}
}

static function DoSpecial(pawn Other, string SpecialString, optional name Type)
{
	if ((Other.Role != ROLE_Authority) && (Type != 'ClientSide'))
		return;

	if ((SpecialString == "") && Other.IsA('WFS_PCSystemPlayer'))
		WFS_PCSystemPlayer(Other).ClientDisplayHUDMenu(default.HUDMenu);

	if (SpecialString ~= "SetMine")
		SetTripmine(Other);
	else if (SpecialString ~= "RemoveMine")
		RemoveTripmine(Other);
	else if (Left(SpecialString, 13) ~= "DeployTrigger")
		DeployPipeTrigger(Other, Right(SpecialString, Len(SpecialString) - 14));
}

static function RemoveTripmine(pawn Other)
{

	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor HitActor;
	local WFLaserTripmineModule WFL, best;
	local float bestproduct, dotproduct;

	GetAxes(Other.ViewRotation,X,Y,Z);
	bestproduct = 0.0;
	best = None;
	foreach Other.VisibleCollidingActors(class'WFLaserTripmineModule', WFL, 250.0, Other.Location)
	{
		if ((WFL != None) && (WFL.Owner == Other))
		{
			dotproduct = Normal(WFL.Location - Other.Location) dot X;
			if ((dotproduct > 0.5) && (dotproduct > bestproduct))
			{
				best = WFL;
				bestProduct = dotproduct;
			}
		}
	}

	if (best != None)
	{
		best.Shutdown();
	}

}

static function DestroyAllRelatedActors(pawn Other)
{
	RemoveAllTripmines(Other);
	super.DestroyAllRelatedActors(Other);
}

static function RemoveAllTripmines(pawn Other)
{
	local WFLaserTripmineModule WFL;
	foreach Other.AllActors(class'WFLaserTripmineModule', WFL, Other.Name)
		if ((WFL != None) && !WFL.bDeleteMe) WFL.Destroy();
}

static function SetTripmine(pawn Other)
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor HitActor;
	local WFLaserTripmineModule WFL;
	local int count;

	count = 0;
	foreach Other.AllActors(class'WFLaserTripmineModule', WFL, Other.Name)
		if (WFL != None) count++;

	//if (RelatedActorCount(Other, class'WFLaserTripmineModule') == 50)
	if (count >= default.MaxTripmines)
	{
		Other.ClientMessage("Cannot set more than "$default.MaxTripmines$" Tripmines.", 'Critical');
		return;
	}

	GetAxes(Other.ViewRotation,X,Y,Z);
	StartTrace = Other.Location + Other.Eyeheight * Z;

	// spawn Tripmine
	WFL = None;
	WFL = Other.spawn(class'WFLaserTripmineModule', Other, Other.name, StartTrace, Other.ViewRotation);
	WFL.SetPhysics(PHYS_Falling);
	WFL.Instigator = Other;
	WFL.Velocity = vector(Other.ViewRotation) * 350 + vect(0,0,1)*100;
	//AddRelatedActor(Other, WFL);

}


static function DeployPipeTrigger(pawn Other, string Delay)
{
	local vector X, Y, Z;
	local WFPipeBombTrigger PBT;
	local float TriggerDelay;

	TriggerDelay = FClamp(float(Delay), 1.0, 3.0);
	if (Delay == "") Delay = "1";

	foreach Other.AllActors(class'WFPipeBombTrigger', PBT)
		if ((PBT != None) && (PBT.Instigator == Other))
			break;

	if ((PBT != None) && !PBT.bCanMove)
	{
		Other.ClientMessage("Cannot re-deploy a Proximity Trigger within 2 seconds of deploying on a surface or wall.", 'Critical');
		return;
	}

	Other.ClientMessage("Deploying "$delay$" second delay Proximity Trigger.", 'Critical');

	if (PBT != None)
	{
		PBT.spawn(class'EnhancedRespawn', PBT,, PBT.Location);
		PBT.Destroy();
		PBT = None;
	}

	PBT = None;
	GetAxes(Other.ViewRotation,X,Y,Z);
	PBT = Other.spawn(class'WFPipeBombTrigger', Other,, Other.Location + Other.Eyeheight*Z, Other.ViewRotation);
	PBT.SetPhysics(PHYS_Falling);
	PBT.Instigator = Other;
	PBT.TriggerDelay = TriggerDelay;
	PBT.OwnerTeam = Other.PlayerReplicationInfo.Team;
	PBT.Velocity = vector(Other.ViewRotation) * 350 + vect(0,0,1)*100;
}

defaultproperties
{
	ClassName="Demoman"
	ClassNamePlural="Demomen"
	Health=100
	Armor=150
	MaxTripmines=4
	DefaultInventory=class'WFDemoManInv'
	MeshInfo=class'WFD_TMale2MeshInfo'
	AltMeshInfo=class'WFD_TMale2BotMeshInfo'
	ClassDescription="WFCode.WFClassHelpDemoMan"
	bNoEnforcer=True
	HUDMenu=class'WFDemomanHUDMenu'
	ClassSkinName="WFSkins.demo"
	ClassFaceName="WFSkins.tyral"
	VoiceType="BotPack.VoiceMaleTwo"
	//bNoTranslocator=True
}