//=============================================================================
// WFStatusConcussed.
// Author: Ob1-Kenobi (ob1@planetunreal.com)
//
// Give this item to a player for a concussion effect.
// Sub-class to create custom view swaying player status effects.
//=============================================================================
class WFStatusConcussed extends WFPlayerStatus;

var() rotator PlayerViewSway;
var() float PitchCycles, YawCycles, RollCycles;
var() float PitchPhase, YawPhase, RollPhase; // phase shift (between -1.0 and 1.0)
var() float InitialFOV;

var() vector SwayTime; // X=Yaw time, Y=Pitch time, Z=Roll time
var() float FOVTime;

var() bool bDampening; // decrease the sway magnitude over time

// These flags specify whether a sway component stops after SwayTime seconds, or
// it continues until the status is removed/destroyed.
//     True   - component continues until status removed
//     False  - component stops after time
var() bool bConstantYaw;	// if false, Yaw sway stops after SwayTime.X seconds
var() bool bConstantPitch;	// if false, Pitch sway stops after SwayTime.Y seconds
var() bool bConstantRoll;	// if false, Roll sway stops after SwayTime.Z seconds

var playerpawn PlayerOwner;

var float DeltaYaw, DeltaPitch, DeltaRoll;
var float PitchTheta, YawTheta, RollTheta; // (phase shift -- not yet implemented)

var vector SwayTimeLeft;
var float FOVTimeLeft;

var bool bInitialised;
var bool bFOVComplete;

function bool HandleStatusFor(pawn Other)
{
	local inventory Inv;

	// remove any current status of this type
	Inv = Other.FindInventoryType(self.class);
	if (Inv != None) Inv.Destroy();

	return false;
}

simulated function ClientInitialise()
{
	PlayerOwner = PlayerPawn(Owner);
	if ((PlayerOwner != None) && (ViewPort(PlayerOwner.Player) != None))
	{
		InitialFOV = FClamp( InitialFOV, 1, 170 );

		// scale all the values by the status ScaleFactor
		if (ScaleFactor > 0.0)
		{
			SwayTime *= ScaleFactor;
			FOVTime *= ScaleFactor;
			PitchCycles *= ScaleFactor;
			YawCycles *= ScaleFactor;
			RollCycles *= ScaleFactor;
			InitialFOV = (InitialFOV - PlayerOwner.default.FOVAngle)*ScaleFactor + PlayerOwner.default.FOVAngle;
		}

		SwayTimeLeft = SwayTime;
		FOVTimeLeft = FOVTime;

		PlayerOwner.SetFOVAngle(InitialFOV);

		// calculate the angle change
		if (SwayTime.X > 0.0)
			DeltaYaw = ((2.0*pi) / SwayTime.X) * YawCycles;
		else DeltaYaw = 0;

		if (SwayTime.Y > 0.0)
			DeltaPitch = ((2.0*pi) / SwayTime.Y) * PitchCycles;
		else DeltaPitch = 0;

		if (SwayTime.Z > 0.0)
			DeltaRoll = ((2.0*pi) / SwayTime.Z) * RollCycles;
		else DeltaRoll = 0;

		bInitialised = true;
	}
	else Disable('StatusTick');
}

function ServerInitialise()
{
	local float ExpireTime;

	// set up the timer to remove the concussion effect
	if (Role == ROLE_Authority)
	{
		// find the longest effect time
		ExpireTime = 0;
		if (SwayTime.X > ExpireTime)
			ExpireTime = SwayTime.X;
		if (SwayTime.Y > ExpireTime)
			ExpireTime = SwayTime.Y;
		if (SwayTime.Z > ExpireTime)
			ExpireTime = SwayTime.Z;
		if (FOVTime > ExpireTime)
			ExpireTime = FOVTime;

		// set up the timer
		SetTimer(ExpireTime + 0.5, false);
	}
}

function Timer()
{
	UsedUp();
}

simulated function StatusTick( float DeltaTime )
{
	if (bInitialised)
		SwayView(DeltaTime);
}

simulated function SwayView(float DeltaTime)
{
	local float SwayOffsetMag;
	local int SwayOffset;
	local float Dampening, Scaling;

	// adjust the FOV
	if (FOVTimeLeft > 0.0)
	{
		FOVTimeLeft -= DeltaTime;
		Scaling = FOVTimeLeft/FOVTime;
		PlayerOwner.SetFOVAngle((InitialFOV-PlayerOwner.default.FOVAngle)*Scaling + PlayerOwner.default.FOVAngle);
	}
	else if (!bFOVComplete)
	{
		bFOVComplete = true;
		PlayerOwner.SetFOVAngle(PlayerOwner.default.FOVAngle);
	}

	if ( (VSize(SwayTimeLeft) > 0.0) || bConstantYaw || bConstantPitch || bConstantRoll )
	{
		SwayTimeLeft.X -= DeltaTime;
		SwayTimeLeft.Y -= DeltaTime;
		SwayTimeLeft.Z -= DeltaTime;

		// offset the Yaw
		if ((SwayTimeLeft.X > 0.0) || bConstantYaw)
		{
			// calculate the offset
			if (bDampening && !bConstantYaw)
				Dampening = SwayTimeLeft.X / SwayTime.X; // linear dampening
			else Dampening = 1.0; // no dampening

			SwayOffsetMag = sin( DeltaYaw * SwayTimeLeft.X );
			PlayerOwner.ViewRotation.Yaw += (SwayOffsetMag * PlayerViewSway.Yaw) * Dampening;
		}

		// offset the Pitch
		if ((SwayTimeLeft.Y > 0.0) || bConstantPitch)
		{
			// calculate the offset
			if (bDampening && !bConstantPitch)
				Dampening = SwayTimeLeft.Y / SwayTime.Y; // linear dampening
			else Dampening = 1.0; // no dampening

			SwayOffsetMag = sin( DeltaPitch * SwayTimeLeft.Y );
			SwayOffset = (SwayOffsetMag * PlayerViewSway.Pitch) * Dampening;
			PlayerOwner.ViewRotation.Pitch += SwayOffset;

			// adjust the pitch
			if ((PlayerOwner.ViewRotation.Pitch > 18000) && (PlayerOwner.ViewRotation.Pitch < 49152))
			{
				if (SwayOffset > 0)
					PlayerOwner.ViewRotation.Pitch = 18000;
				else
					PlayerOwner.ViewRotation.Pitch = 49152;
			}
		}

		// offset the Roll
		if ((SwayTimeLeft.Z > 0.0) || bConstantRoll)
		{
			// calculate the offset
			if (bDampening && !bConstantRoll)
				Dampening = SwayTimeLeft.Z / SwayTime.Z; // linear dampening
			else Dampening = 1.0; // no dampening

			SwayOffsetMag = sin( DeltaRoll * SwayTimeLeft.Z );
			PlayerOwner.ViewRotation.Roll += (SwayOffsetMag * PlayerViewSway.Roll) * Dampening;
		}
	}
}

simulated function Destroyed()
{
	// reset the FOVAngle
	if (bInitialised && (FOVTimeLeft > 0.0))
		PlayerOwner.SetFOVAngle(PlayerOwner.default.FOVAngle);

	super.Destroyed();
}

defaultproperties
{
	PickupMessage="You have been concussed!"
	ExpireMessage="The concussion has worn off."
	//InitialFOV=130.000000
	InitialFOV=100.000000
	//FOVTime=30.000000
	FOVTime=15.000000
	//SwayTime=(X=30.000000,Y=30.000000,Z=30.000000)
	SwayTime=(X=15.000000,Y=15.000000,Z=15.000000)
	//PlayerViewSway=(Pitch=1000,Yaw=1000,Roll=1000)
	PlayerViewSway=(Pitch=750,Yaw=750,Roll=750)
	//PitchCycles=20.000000
	//YawCycles=15.000000
	//RollCycles=15.000000
	PitchCycles=10.000000
	YawCycles=7.500000
	RollCycles=7.500000
	bRenderStatus=True
	bDampening=True
	StatusID=1
	StatusType="Concussed"
}