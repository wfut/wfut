class WFFlameThrowerFlameGen extends Projectile;

var class<projectile> FlameClass;
var bool bCenter, bRight;
var float AimError, NewError;
var rotator AimRotation;
var vector FireOffset;
var float OldError, StartError;
var float FlameRate;

replication
{
	unreliable if (Role == ROLE_Authority)
		bCenter, bRight;

	unreliable if( Role==ROLE_Authority )
		AimError, NewError, AimRotation;
}

auto simulated state GenerateFlames
{
Begin:
	UpdateLocation();
	SpawnFlameProj();
	Sleep(FlameRate);
	goto 'Begin';
}

simulated function UpdateLocation()
{
	local vector X,Y,Z, AimSpot, DrawOffset, AimStart;
	local int YawErr;
	local float dAdjust;
	local Bot MyBot;
	local float DeltaTime;
	DeltaTime = FlameRate; // the delay between flames

	if (Instigator != None)
	{
		if ( (Level.NetMode == NM_Client) && (!Instigator.IsA('PlayerPawn') || (PlayerPawn(Instigator).Player == None)) )
		{
			SetRotation(AimRotation);
			Instigator.ViewRotation = AimRotation;
			DrawOffset = ((0.01 * class'WFFlameThrower'.Default.PlayerViewOffset) >> Rotation);
			DrawOffset += (Instigator.EyeHeight * vect(0,0,1));
		}
		else
		{
			MyBot = Bot(instigator);
			if ( MyBot != None  )
			{
				if ( Instigator.Target == None )
					Instigator.Target = Instigator.Enemy;
				if ( Instigator.Target == Instigator.Enemy )
				{
					if (MyBot.bNovice )
						dAdjust = DeltaTime * (4 + instigator.Skill) * 0.075;
					else
						dAdjust = DeltaTime * (4 + instigator.Skill) * 0.12;
					if ( OldError > NewError )
						OldError = FMax(OldError - dAdjust, NewError);
					else
						OldError = FMin(OldError + dAdjust, NewError);

					if ( OldError == NewError )
						NewError = FRand() - 0.5;
					if ( StartError > 0 )
						StartError -= DeltaTime;
					else if ( MyBot.bNovice && (Level.TimeSeconds - MyBot.LastPainTime < 0.2) )
						StartError = MyBot.LastPainTime;
					else
						StartError = 0;
					AimSpot = 1.25 * Instigator.Target.Velocity + 0.75 * Instigator.Velocity;
					if ( Abs(AimSpot.Z) < 120 )
						AimSpot.Z *= 0.25;
					else
						AimSpot.Z *= 0.5;
					if ( Instigator.Target.Physics == PHYS_Falling )
						AimSpot = Instigator.Target.Location - 0.0007 * AimError * OldError * AimSpot;
					else
						AimSpot = Instigator.Target.Location - 0.0005 * AimError * OldError * AimSpot;
					if ( (Instigator.Physics == PHYS_Falling) && (Instigator.Velocity.Z > 0) )
						AimSpot = AimSpot - 0.0003 * AimError * OldError * AimSpot;

					AimStart = Instigator.Location + FireOffset.X * X + FireOffset.Y * Y + (1.2 * FireOffset.Z - 2) * Z;
					if ( FastTrace(AimSpot - vect(0,0,10), AimStart) )
						AimSpot	= AimSpot - vect(0,0,10);
					GetAxes(Instigator.Rotation,X,Y,Z);
					AimRotation = Rotator(AimSpot - AimStart);
					AimRotation.Yaw = AimRotation.Yaw + (OldError + StartError) * 0.75 * aimerror;
					YawErr = (AimRotation.Yaw - (Instigator.Rotation.Yaw & 65535)) & 65535;
					if ( (YawErr > 3000) && (YawErr < 62535) )
					{
						if ( YawErr < 32768 )
							AimRotation.Yaw = Instigator.Rotation.Yaw + 3000;
						else
							AimRotation.Yaw = Instigator.Rotation.Yaw - 3000;
					}
				}
				else if ( Instigator.Target != None )
					AimRotation = Rotator(Instigator.Target.Location - Instigator.Location);
				else
					AimRotation = Instigator.ViewRotation;
				Instigator.ViewRotation = AimRotation;
				SetRotation(AimRotation);
			}
			else
			{
				AimRotation = Instigator.ViewRotation;
				SetRotation(AimRotation);
			}
			Drawoffset = Instigator.Weapon.CalcDrawOffset();
		}


		DrawOffset = ((0.9/Instigator.FOVAngle * class'WFFlamethrower'.default.PlayerViewOffset) >> Instigator.ViewRotation);
		DrawOffset += (Instigator.BaseEyeHeight * vect(0,0,1));
		GetAxes(Instigator.ViewRotation,X,Y,Z);
		if ( bCenter )
		{
			FireOffset.Z = Default.FireOffset.Z * 1.5;
			FireOffset.Y = 0;
		}
		else
		{
			FireOffset.Z = Default.FireOffset.Z;
			if ( bRight )
				FireOffset.Y = Default.FireOffset.Y;
			else
				FireOffset.Y = -1 * Default.FireOffset.Y;
		}
		DrawOffset = Owner.Location + DrawOffset + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
		SetLocation(DrawOffset);
	}
}

simulated function SpawnFlameProj()
{
	local effects e;
	local projectile p;
	if (Instigator != None)
	{
		if (Role == ROLE_Authority)
			Instigator.MakeNoise(Instigator.SoundDampening);
		//AdjustedAim = Instigator.AdjustAim(FlameSpeed, Location, AimError, True, True);
		if (!Region.Zone.bWaterZone)
		{
			p = Spawn(FlameClass,,, Location,Instigator.ViewRotation);
			if (p != None)
				p.Velocity = p.Speed*vector(Instigator.ViewRotation) + Instigator.Velocity;
		}
		else
		{
			e = spawn(class'UT_SpriteSmokePuff',,, Location);
			e.RemoteRole = ROLE_None;
		}
	}
}

defaultproperties
{
	FlameRate=0.07
	bNetTemporary=False
	FireOffset=(X=15.000000,Y=-9.000000,Z=-16.000000)
	//DrawType=DT_Sprite
	RemoteRole=ROLE_SimulatedProxy
	Texture=Texture'Flakmuz'
	Style=STY_Translucent
	DrawScale=0.15
	FlameClass=class'WFFlameProj'
	bCollideActors=False
	bCollideWorld=False
	//AmbientSound=Sound'UnrealShare.BRocket'
	AmbientSound=Sound'Flames_1'
	SoundRadius=64
	SoundVolume=255
}