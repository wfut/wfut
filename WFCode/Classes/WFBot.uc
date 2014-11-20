class WFBot extends WFS_PCSystemBot;

var bool bNoFrozenAnim;
var bool bFlagTouchDisabled;

var byte Armor; // the bots armor (maintained by WFArmor)

replication
{
	reliable if (Role == ROLE_Authority)
		Armor;
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						Vector momentum, name damageType)
{
	local int actualDamage;
	local bool bAlreadyDead;
	local byte bIgnoreDamage;

	if ( Role < ROLE_Authority )
	{
		log(self$" client damage type "$damageType$" by "$instigatedBy);
		return;
	}

	// notify PCI
	bIgnoreDamage = 0;
	if (PCInfo != none)
		PCInfo.static.PlayerTakeDamage(self, Damage, instigatedBy, hitlocation, momentum, damageType, bIgnoreDamage);

	if (bool(bIgnoreDamage))
		return;

	//log(self@"take damage in state"@GetStateName());
	bAlreadyDead = (Health <= 0);

	if (Physics == PHYS_None)
		SetMovementPhysics();
	if (Physics == PHYS_Walking)
		momentum.Z = FMax(momentum.Z, 0.4 * VSize(momentum));
	if ( instigatedBy == self )
		momentum *= 0.6;
	momentum = momentum/Mass;

	actualDamage = Level.Game.ReduceDamage(Damage, DamageType, self, instigatedBy);
	if ( bIsPlayer )
	{
		if (ReducedDamageType == 'All') //God mode
			actualDamage = 0;
		else if ((Inventory != None) && CanReduceDamageFor(DamageType)) //then check if carrying armor
			actualDamage = Inventory.ReduceDamage(actualDamage, DamageType, HitLocation);
		/* Ob1: no point doing this, as it'll cancel out Level.Game.ReduceDamage()
		        if "Inventory==None", or if the damage type can't be reduced by armor.
		else
			actualDamage = Damage;
		*/
	}
	else if ( (InstigatedBy != None) &&
				(InstigatedBy.IsA(Class.Name) || self.IsA(InstigatedBy.Class.Name)) )
		ActualDamage = ActualDamage * FMin(1 - ReducedDamagePct, 0.35);
	else if ( (ReducedDamageType == 'All') ||
		((ReducedDamageType != '') && (ReducedDamageType == damageType)) )
		actualDamage = float(actualDamage) * (1 - ReducedDamagePct);

	if ( Level.Game.DamageMutator != None )
		Level.Game.DamageMutator.MutatorTakeDamage( ActualDamage, Self, InstigatedBy, HitLocation, Momentum, DamageType );

	AddVelocity( momentum );
	Health -= actualDamage;
	if (CarriedDecoration != None)
		DropDecoration();
	if ( HitLocation == vect(0,0,0) )
		HitLocation = Location;
	if (Health > 0)
	{
		if ( (instigatedBy != None) && (instigatedBy != Self) )
			damageAttitudeTo(instigatedBy);
		PlayHit(actualDamage, hitLocation, damageType, Momentum);
	}
	else if ( !bAlreadyDead )
	{
		//log(self$" died");
		NextState = '';
		PlayDeathHit(actualDamage, hitLocation, damageType, Momentum);
		if ( actualDamage > mass )
			Health = -1 * actualDamage;
		if ( (instigatedBy != None) && (instigatedBy != Self) )
			damageAttitudeTo(instigatedBy);
		Died(instigatedBy, damageType, HitLocation);
	}
	else
	{
		//Warn(self$" took regular damage "$damagetype$" from "$instigator$" while already dead");
		// SpawnGibbedCarcass();
		if ( bIsPlayer )
		{
			HidePlayer();
			GotoState('Dying');
		}
		else
			Destroy();
	}
	MakeNoise(1.0);
}

// return false if damage caused by this damage type shouldn't
// be reduced by carried armor
function bool CanReduceDamageFor(name DamageType)
{
	local WFPCIList list;
	local WFS_PCSystemGRI GRI;
	local int BotsTeam;

	GRI = WFS_PCSystemGRI(Level.Game.GameReplicationInfo);
	BotsTeam = PlayerReplicationInfo.Team;
	if (BotsTeam < 4)
	{
		list = WFPCIList(GRI.TeamClassList[BotsTeam]);
		if (list != None)
			return list.CanReduceDamageFor(DamageType);
	}

	return true;
}

state Frozen
{
	// can prevent animations and effects from playing while player is frozen
	// by setting bNoFrozenAnim to true (used by the WFStatusFrozen player status)
	function PlayHit(float Damage, vector HitLocation, name damageType, vector Momentum)
	{
		if (bNoFrozenAnim)
			return;

		Global.PlayHit(Damage, HitLocation, damageType, Momentum);
	}

	function PlayInAir()
	{
		if (bNoFrozenAnim)
			return;

		Global.PlayInAir();
	}

	function PlayLanded(float impactVel)
	{
		if (bNoFrozenAnim)
			return;

		Global.PlayLanded(impactVel);
	}
}

defaultproperties
{
	PlayerReplicationInfoClass=class'WF_BotPRI'
}