class WFStatusLegDamage extends WFPlayerStatus;

var() float MovementScale;

function ServerInitialise()
{
	SetPlayerMovement();
}

function SetPlayerMovement()
{
	local float MovementScaling;
	local pawn PawnOwner;
	MovementScaling = MovementScale;// * 1.0/ScaleFactor;

	PawnOwner = pawn(Owner);
	if (PawnOwner != None)
	{
		PawnOwner.GroundSpeed *= MovementScaling;
		PawnOwner.WaterSpeed *= MovementScaling;
		PawnOwner.AirSpeed *= MovementScaling;
		PawnOwner.AccelRate *= MovementScaling;
	}
}

function ResetPlayerMovement()
{
	local pawn PawnOwner;
	local float SpeedScaling;
	local class<WFS_PlayerClassInfo> PCI;
	local WFStatusTranquilised TranqStatus;

	if (DeathMatchPlus(Level.Game).bMegaSpeed)
		SpeedScaling = 1.4;
	else SpeedScaling = 1.0;

	PawnOwner = pawn(Owner);
	if (PawnOwner != None)
	{
		PCI = class'WFS_PlayerClassInfo'.static.GetPCIFor(PawnOwner);

		PawnOwner.GroundSpeed = PawnOwner.default.GroundSpeed * SpeedScaling;
		PawnOwner.WaterSpeed = PawnOwner.default.WaterSpeed * SpeedScaling;
		PawnOwner.AirSpeed = PawnOwner.default.AirSpeed * SpeedScaling;
		PawnOwner.AccelRate = PawnOwner.default.AccelRate * SpeedScaling;

		if (PCI != None)
			PCI.static.ModifyPlayer(PawnOwner);

		// make sure this sets movement after status is removed
		TranqStatus = WFStatusTranquilised(PawnOwner.FindInventoryType(class'WFStatusTranquilised'));
		if ((TranqStatus != None) && !TranqStatus.bDeleteMe && (PawnOwner.Health > 0)
			&& (TranqStatus.Owner == Owner))
			TranqStatus.SetPlayerMovement();

		// let the current weapon know that the players movement has been reset
		if ((PawnOwner.Weapon != None) && !PawnOwner.Weapon.bDeleteMe && PawnOwner.Weapon.IsA('WFWeapon')
			&& (PawnOwner.Health > 0) && (PawnOwner.Weapon.Owner == Owner))
			WFWeapon(PawnOwner.Weapon).WeaponEvent('PlayerMovementReset');
	}
}

simulated function Destroyed()
{
	if (Role == ROLE_Authority)
		ResetPlayerMovement();
	super.Destroyed();
}

defaultproperties
{
	PickupMessage="Leg damage - Movement slowed by 50%!"
	ExpireMessage="Leg damage healed."
	MovementScale=0.500000
	StatusType="Leg damage"
	StatusID=7
}