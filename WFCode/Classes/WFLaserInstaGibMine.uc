class WFLaserInstaGibMine expands WFLaserTripMineModule;

var int Charge;
var bool bReady;

simulated function ReceiveAlert( string AlertType, int Dir, actor Blah)
{
	//Log("Instagibber:"@Blah);
	switch( AlertType )
	{
	case "activate":
		bReady = true;
		break;
	case "explode":
		if ( bReady )
			DoInstaGib( blah );
		break;
	case "deactivate":
		Destroy();
		break;
	}
}

function DoInstaGib( Actor TargetActor )
{
	if ( Charge > 0 )
	{
		SpawnEffect(TargetActor.Location, Location);
		Spawn(class'ut_SuperRing2',,,TargetActor.Location);
		TargetActor.TakeDamage(1000, Pawn(Owner), TargetActor.Location, 60000*vect(1,1,1), 'WFLaserInstaGibMine');
		Charge--;
	}

	if (Charge <= 0)
	{
		Explosion(Location, 50, 125);
		return;
	}

	bReady = false;
	/* no more recharge delay :o)
	TailBeam.bPongNextMessage = true;
	TailBeam.PongSpeed = 3;
	TailBeam.PongChallenge = "deactivate";
	TailBeam.PongReply = "activate";
	SendAlert("deactivate");
	*/
}

function SpawnEffect(vector HitLocation, vector SmokeLocation)
{
	local SuperShockBeam Smoke,shock;
	local Vector DVector;
	local int NumPoints;
	local rotator SmokeRotation;

	DVector = HitLocation - SmokeLocation;
	NumPoints = VSize(DVector)/135.0;
	if ( NumPoints < 1 )
		return;
	SmokeRotation = rotator(DVector);
	SmokeRotation.roll = Rand(65535);

	Smoke = Spawn(class'SuperShockBeam',,,SmokeLocation,SmokeRotation);
	Smoke.MoveAmount = DVector/NumPoints;
	Smoke.NumPuffs = NumPoints - 1;
}

simulated function Tick(float DeltaTime)
{
	super.Tick(DeltaTime);
	if (!bReady)
		bReady = true;
}

defaultproperties
{
	Charge=5
	bReady=true
	ScaleGlow=0.8
	Mesh=LodMesh'WFInstagibMine'
	MaxSegments=75
}
