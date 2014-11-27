//=============================================================================
// WFGunner.
//=============================================================================
class WFGunner extends WFPlayerClassInfo;

var int MaxTripmines;

static function ModifyPlayer(pawn Other)
{
	Other.GroundSpeed = Other.default.GroundSpeed * 0.85;
	Other.WaterSpeed = Other.default.WaterSpeed * 0.85;
	Other.AirSpeed = Other.default.AirSpeed * 0.85;
	Other.AccelRate = Other.default.AccelRate * 0.85;
	Other.AirControl = Other.default.AirControl * 0.85;
	Other.Mass = Other.default.Mass * 1.15;
}

static function bool IsClientSideCommand(string SpecialString)
{
	if (SpecialString == "")
		return true;

	return false;
}

static function DoSpecial(pawn Other, string SpecialString, optional name Type)
{
	if ((Other.Role != ROLE_Authority) && (Type != 'ClientSide'))
		return;

	if ((SpecialString == "") && Other.IsA('WFS_PCSystemPlayer'))
		WFS_PCSystemPlayer(Other).ClientDisplayHUDMenu(default.HUDMenu);

	if (SpecialString ~= "DeployAlarm")
		DeployAlarm(Other);
	if (SpecialString ~= "SetMine")
		SetTripmine(Other);
	else if (SpecialString ~= "RemoveMine")
		RemoveTripmine(Other);
	/*else if (SpecialString ~= "RemoveDecloaker")
	{
		if (!RemoveDecloakers(Other))
			Other.ClientMessage("No Decloakers to remove");
	}*/
}


static function SetTripmine(pawn Other)
{
	//Log("Setting mine");
	TraceMineWall(Other);
}

static function RemoveTripmine(pawn Other)
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor HitActor;
	local WFLaserInstaGibMine WFL, best;
	local float bestproduct, dotproduct;

	GetAxes(Other.ViewRotation,X,Y,Z);
	bestproduct = 0.0;
	best = None;
	foreach Other.VisibleCollidingActors(class'WFLaserInstaGibMine', WFL, 250.0, Other.Location)
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

// NOTE: If MaxTripmines is higher than 7 then the tripmine deployment checking code
//       needs to be done in the same way as the Demoman.
static function TraceMineWall(pawn Other)
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor HitActor;
	local WFLaserInstaGibMine WFL;

	if (RelatedActorCount(Other, class'WFLaserInstaGibMine') >= default.MaxTripmines)
	{
		Other.ClientMessage("Cannot set more than "$default.MaxTripmines$" Instagib Tripmines.", 'Critical');
		return;
	}

	GetAxes(Other.ViewRotation,X,Y,Z);
	StartTrace = Other.Location + Other.Eyeheight * Z;

	// spawn Tripmine
	WFL = Other.spawn(class'WFLaserInstaGibMine', Other,, StartTrace, Other.ViewRotation);
	WFL.SetPhysics(PHYS_Falling);
	WFL.Instigator = Other;
	WFL.Velocity = vector(Other.ViewRotation) * 350 + vect(0,0,1)*100;
	AddRelatedActor(Other, WFL);
}

static function DeployAlarm(pawn Other)
{
	local WFAlarm Alarm;
	local vector dir;

	Alarm = WFAlarm(FindRelatedActorClass(Other, class'WFAlarm'));
	if ((Alarm != None) && !Alarm.bCanRemove)
	{
		Other.ClientMessage("Cannot re-deploy an alarm within 2 seconds of deploying on a surface or wall.", 'Critical');
		return;
	}
	RemoveRelatedActor(Other, alarm);
	Alarm.Destroy();
	Alarm = None;

	dir = vector(Other.ViewRotation);
	dir.z = dir.Z + 0.35 * (1 - Abs(dir.Z));

	alarm = Other.spawn(class'WFAlarm',,, Other.Location, Other.Rotation);
	alarm.OwnerTeam = Other.PlayerReplicationInfo.Team;
	alarm.Velocity = 500.0 * Normal(dir);

	AddRelatedActor(Other, alarm);
}

static function PlayerDied(pawn Other, pawn Killer, name damageType, vector HitLocation)
{
	RemoveDecloakers(Other);
}

static function bool RemoveDecloakers(pawn Other)
{
	local WFGrenDecloakerProj g;
	local bool bRemoved;

	// remove any active Decloaker Grenades
	bRemoved = false;
	foreach Other.AllActors(class'WFGrenDecloakerProj', g)
	{
		if ((g != None) && !g.bDeleteMe && (g.Instigator == Other))
		{
			g.ServerExplosion(g.Location);
			bRemoved = true;
		}
	}

	return bRemoved;
}

static function DestroyAllRelatedActors(pawn Other)
{
	local WFGrenDecloakerProj gren;

	foreach Other.AllActors(class'WFGrenDecloakerProj', gren)
		if ((gren != None) && !gren.bDeleteMe && (gren.Instigator == Other))
			gren.Destroy();

	super.DestroyAllRelatedActors(Other);
}

defaultproperties
{
	ClassName="Gunner"
	ClassNamePlural="Gunners"
	Health=120
	Armor=199
	ArmorAbsorption=75
	bNoEnforcer=True
	MaxTripmines=1
	//bNoTranslocator=True
	DefaultInventory=class'WFGunnerInv'
	MeshInfo=class'WFD_TFemale2MeshInfo'
	AltMeshInfo=class'WFD_TFemale2BotMeshInfo'
	ClassDescription="WFCode.WFClassHelpGunner"
	TranslocatorAmmoUsed=25
	HUDMenu=class'WFGunnerHUDMenu'
	ClassSkinName="WFSkins.gunn"
	ClassFaceName="WFSkins.lana"
	VoiceType="BotPack.VoiceFemaleTwo"
}
