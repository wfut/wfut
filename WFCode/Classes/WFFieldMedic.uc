//=============================================================================
// WFFieldMedic.
//=============================================================================
class WFFieldMedic extends WFPlayerClassInfo;

static function bool IsImmuneTo(class<WFPlayerStatus> StatusClass)
{
	if ((StatusClass == class'WFStatusInfected') || (StatusClass == class'WFStatusOnFire'))
		return true;

	return false;
}

static function PlayerTakeDamage(pawn Other, out int Damage, out Pawn instigatedBy,	out vector hitlocation, out vector momentum, out name damageType, out byte bIgnoreDamage)
{
	if (damageType == 'Corroded')
		Damage *= 0.5;

	super.PlayerTakeDamage(Other, Damage, instigatedBy, hitlocation, momentum, damageType, bIgnoreDamage);
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

	if (SpecialString ~= "DeployDepot")
		DeployHealingDepot(Other);

	if (SpecialString ~= "RemoveDepot")
		RemoveHealingDepot(Other);
}

static function DeployHealingDepot(pawn Other)
{
	local WFHealingDepot depot;
	local rotator buildRot, viewRot;
	local vector buildLoc;
	local inventory Inv;

	buildRot.Yaw = Other.Rotation.Yaw;
	viewRot.Yaw = Other.ViewRotation.Yaw;
	buildLoc = Other.Location + (72 * Vector(viewRot)) + (vect(0,0,1) * 15) - vect(0,0,32);

	if (RelatedActorCount(Other, class'WFHealingDepot') != 0)
	{
		depot = WFHealingDepot(FindRelatedActorClass(Other, class'WFHealingDepot'));
		if (depot.MoveDepot(buildLoc))
			depot.SetPhysics(PHYS_Falling);
		return;
	}

	Depot = Other.Spawn(class'WFHealingDepot', Other,, buildLoc, buildRot);
	if (Depot == none)
	{
		Other.ClientMessage("Not enough room to deploy here.", 'Critical');
		return;
	}

	Depot.SetTeam(Other.PlayerReplicationInfo.Team);
	Depot.SetPlayerOwner(Other);
	SendEvent(Other, "h_depot_deployed");
	AddRelatedActor(Other, Depot);
}

static function RemoveHealingDepot(pawn Other)
{
	local WFHealingDepot depot;

	if (RelatedActorCount(Other, class'WFHealingDepot') != 0)
	{
		depot = WFHealingDepot(FindRelatedActorClass(Other, class'WFHealingDepot'));
		if (VSize(depot.Location - Other.Location) < 100)
			depot.RemoveDepot();
		else Other.ClientMessage("Too far away from Healing Depot.", 'Critical');
	}
}

defaultproperties
{
	ClassName="Field Medic"
	ShortName="Medic"
	ClassNamePlural="Field Medics"
	Health=100
	Armor=50
	ExtendedHUD=class'WFS_CTFHUDInfo'
	DefaultInventory=class'WFFieldMedicInv'
	MeshInfo=class'WFD_TFemale1MeshInfo'
	AltMeshInfo=class'WFD_TFemale1BotMeshInfo'
	HUDMenu=class'WFFieldMedicMenu'
	bNoImpactHammer=True
	bNoEnforcer=True
	//bNoTranslocator=True
	ClassDescription="WFCode.WFClassHelpFieldMedic"
	ClassSkinName="WFSkins.medi"
	ClassFaceName="WFSkins.medic"
	VoiceType="BotPack.VoiceFemaleOne"
}