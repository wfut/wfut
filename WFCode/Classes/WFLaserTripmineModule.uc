class WFLaserTripmineModule expands Projectile;

var float BeamSize;
var WFLaserTripmineBeamHead HeadBeam;
var WFLaserTripmineBeamTail TailBeam;
var texture TeamTexture;
var string TeamTextureStrings[4];
var texture TeamTextures[4];
var bool bActivateAlertSent;
var bool bAlreadyDestroyed;
var int i;
var int MaxSegments;
var float RealLocX, RealLocY, RealLocZ;
var int RealRotR, RealRotY, RealRotP;
var Actor BasedWall;
var bool bWantsToFlicker;

var PlayerReplicationInfo OwnerPRI;

var bool bAlreadyExploded;

replication
{
	reliable if (Role == ROLE_Authority)
		RealRotR, RealRotY, RealRotP, RealLocX, RealLocY, RealLocZ, BasedWall;
	reliable if (Role == ROLE_Authority)
		/*TeamTexture,*/ bAlreadyDestroyed, /*bActivateAlertSent,*/ bWantsToFlicker;

	// Ob1: just to be safe, the clientside beam waits for this to be replicated
	reliable if (Role == ROLE_Authority)
		OwnerPRI;
}


function TakeDamage( int DamageAmount, Pawn instigatedBy, Vector hitlocation, vector momentum, name damageType )
{
	// OB1 - Please fixme :-), only blow up if shot by yourself or someone not on your team
	// Ob1: fixed so that anyone (except owner) on same team can't damage mine
	//Log("-- Takedamage called");
	if ( (instigatedBy == None) || (InstigatedBy != Owner && InstigatedBy.PlayerReplicationInfo.Team == OwnerPRI.Team) )
		return;
	//Log("Takedamage OK");
	if ( DamageAmount > 10 )
	{
		bWantsToFlicker=true;
		//Log("Wants to flicker.");
	}
}

simulated function Tick(float DeltaTime)
{
	if ((Role == ROLE_Authority) && (Instigator != None) && (OwnerPRI == None))
		OwnerPRI = Instigator.PlayerReplicationInfo;
	if ( bWantsToFlicker )
	{
		//Log("Going to flickering state.");
		//bWantsToFlicker=false;
		GotoState('Flickering');
	}

	// Received good data from server. Create beam!
	if ( OwnerPRI != None && RealLocX != -1 && RealLocY != -1 && RealLocZ != -1 && RealRotY != -1 && RealRotP != -1 && RealRotR != -1 && HeadBeam == None && BasedWall != None )
	{
		CreateBeam();
	}
}

simulated state Flickering
{
	function Tick(float DeltaTime)
	{
	}

Begin:
	//Log("Executing Flickering state code.");
	//bWantsToFlicker=false;
	for (i=0;i<10;i++)
	{
		SendAlert("displayoff");
		Sleep(frand()/10);
		SendAlert("displayon");
		Sleep(frand()/10);
	}
	//Log("Boom.");
	if (!bAlreadyExploded)
		Explosion(Location, 50, 125); // ob1: changed destroyed damage and range
}

// Send the message both on the client and server beam pipes.
simulated function SendAlert( coerce string alert )
{
	HeadBeam.SendAlert(Alert, 1, None);
}

simulated event Destroyed()
{
	if ( !bAlreadyDestroyed )
	{
		if( HeadBeam != None )
			HeadBeam.DestroyBeam();
		bAlreadyDestroyed = true;
	}
}

function HitWall (vector HitNormal, actor Wall)
{
	local Rotator TrueRot;

	// if attached to mover, remove mine
	if ( (Wall.Brush != None) || (Brush(Wall) != None) )
	{
		// make it look like it transports away
		spawn(class'EnhancedRespawn', self,, Location);
		Destroy();
		return;
	}

	BasedWall = Wall;
	SetPhysics( PHYS_None );
	//Log( "Tripmine set and beam created." );
	TrueRot = Rotator(HitNormal);
	RealRotY = TrueRot.Yaw;
	RealRotP = TrueRot.Pitch;
	RealRotR = TrueRot.Roll;
	RealLocX = Location.X;
	RealLocY = Location.Y;
	RealLocZ = Location.Z;
}

// handle encroachment (movers cause mine to vanish)
function bool EncroachingOn( actor Other )
{
	if ((Other.Brush != None) || (Brush(Other) != None))
	{
		// make it look like it transports away
		spawn(class'EnhancedRespawn', self,, Location);
		Destroy();
	}
	return false;
}

function EncroachedBy( actor Other )
{
	if ((Other.Brush != None) || (Brush(Other) != None))
	{
		// make it look like it transports away
		spawn(class'EnhancedRespawn', self,, Location);
		Destroy();
	}
}

function BlowUp(vector HitLocation, int DamageAmnt, float Range)
{
	HurtRadius(damageamnt, range, 'WFLaserTripMine', MomentumTransfer, HitLocation);
	MakeNoise(1.0);
}

/*simulated */function Explosion(vector HitLocation, int DamageAmnt, float Range)
{
	local UT_SpriteBallExplosion s;

	bAlreadyExploded = true;

	BlowUp(HitLocation, DamageAmnt, Range);
	if ( Level.NetMode != NM_DedicatedServer )
	{
		spawn(class'WarExplosion',,,Location);
	}
 	Destroy();
}

simulated function Timer()
{
	if( !bActivateAlertSent && HeadBeam != None )
	{
		//Log (self$": Sending activate alert!");
		HeadBeam.SendAlert("activate", 1, None, 2.0);
		bActivateAlertSent = true;
	}
}

simulated function Shutdown()
{
	HeadBeam.SendAlert("deactivate", -1, None, 2.0);
}

simulated function SetTeamTexture()
{
	local int TeamN;
	local int i;

	//TeamN = PlayerPawn(Owner).PlayerReplicationInfo.Team;
	TeamN = OwnerPRI.Team;
	//Log (TeamN);
	if ( TeamTextures[TeamN] == None )
		TeamTextures[TeamN] = Texture(DynamicLoadObject(TeamTextureStrings[TeamN], class'Texture'));
	TeamTexture = TeamTextures[TeamN];
}

simulated function CreateBeam()
{
	local rotator BeamRot;
	local vector BeamVec;
	local vector TVect;
	local vector BeamLoc;
	local vector NextBeamLoc;
	local int BeamCtr;
	local bool bHitWall;
	local WFLaserTripmineBeam LastBeam;
	local WFLaserTripmineBeam ThisBeam;
	local bool bAtLeastOneBeamAdded;

	SetTeamTexture();
	SetBase( BasedWall );
	SetPhysics( PHYS_None );
	SetTimer(2.0,true);

	BeamRot.Yaw = RealRotY;
	BeamRot.Pitch = RealRotP;
	BeamRot.Roll = RealRotR;
	TVect.X = RealLocX;
	TVect.Y = RealLocY;
	TVect.Z = RealLocZ;
	SetLocation( TVect );
	SetRotation(BeamRot);
	BeamVec = vector(BeamRot);
	HeadBeam = spawn(class'WFLaserTripmineBeamHead', Self,, BeamLoc + Location, BeamRot);
	HeadBeam.MainDefense = Self;
	HeadBeam.OwnerPRI = OwnerPRI;
	LastBeam = HeadBeam;

	//log (Self$": Created HeadBeam:"@HeadBeam);
	for(BeamCtr=0;BeamCtr<MaxSegments;BeamCtr++)
	{
		if ( FastTrace( BeamLoc + Location, BeamLoc + (BeamVec * BeamSize) + Location ) )
		{
			bAtLeastOneBeamAdded = true;
			BeamLoc += BeamVec * BeamSize;
			//Log (BeamCtr@BeamVec@BeamLoc);
			ThisBeam = spawn(class'WFLaserTripmineBeam', Self,, BeamLoc + Location, BeamRot);
			ThisBeam.OwnerPRI = OwnerPRI;
			//log (Self$": Created ThisBeam:"@ThisBeam);
			LastBeam.NextBeam = ThisBeam;
			//log (Self$": Linked"@LastBeam$".NextBeam to "@ThisBeam);
			ThisBeam.PrevBeam = LastBeam;
			//log (Self$": Linked"@ThisBeam$".PrevBeam to "@LastBeam);
			LastBeam = ThisBeam;
		}
		else
		{
			bHitWall = true;
			break;
		}
	}
	ThisBeam = LastBeam.PrevBeam;
	LastBeam.Destroy();
	LastBeam = ThisBeam;
	TailBeam = spawn(class'WFLaserTripmineBeamTail', Self,, BeamLoc + Location, BeamRot);
	TailBeam.OwnerPRI = OwnerPRI;
	if (!bHitWall)
	{
		BeamLoc += BeamVec * BeamSize;
		TailBeam.AddTail( BeamLoc + Location, BeamRot );
	}
	//log (Self$": Created TailBeam:"@TailBeam);
	TailBeam.PrevBeam = LastBeam;
	//log (Self$": Linked Final"@TailBeam$".PrevBeam to "@LastBeam);
	LastBeam.NextBeam = TailBeam;
	//log (Self$": Linked Final"@LastBeam$".NextBeam to "@TailBeam);
	if ( HeadBeam == None || TailBeam == None || !bAtLeastOneBeamAdded )
	{
		if ( HeadBeam != None )
			HeadBeam.Destroy();
		if ( TailBeam != None )
		{
			TailBeam.DoCleanup(); // (make sure)
			TailBeam.Destroy();
		}
		if (Role == ROLE_Authority)
		{
			spawn(class'EnhancedRespawn', self,, Location);
			Destroy();
		}
	}
}

simulated function ReceiveAlert( string AlertType, int Dir, actor Blah)
{
	switch( AlertType )
	{
	case "explode":
		if (!bAlreadyExploded)
			Explosion(Location, 200, 500);
	case "deactivate":
		if (!bDeleteMe)
			Destroy();
	}
}


defaultproperties
{
     BeamSize=24.3
     bAlwaysRelevant=true
	 damage=75
	 ImpactSound=Sound'UnrealShare.Eightball.GrenadeFloor'
	 MaxSegments=30
	 bWantsToFlicker=false
	 RemoteRole=ROLE_SimulatedProxy
	 bNetTemporary=False
	 TeamTextures(0)=texture'WFMedia.BeamRedTex'
	 TeamTextures(1)=texture'WFMedia.BeamBlueTex'
	 TeamTextures(2)=texture'WFMedia.BeamGoldTex'
	 TeamTextures(3)=texture'WFMedia.BeamGreenTex'
	 TeamTextureStrings(0)="WFMedia.BeamRedTex"
	 TeamTextureStrings(1)="WFMedia.BeamBlueTex"
	 TeamTextureStrings(2)="WFMedia.BeamYellowTex"
	 TeamTextureStrings(3)="WFMedia.BeamGreenTex"
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=0.000000
	 DrawScale=1.5
     Mesh=LodMesh'WFMedia.Laserd'
     SoundRadius=20
     SoundVolume=100
     CollisionRadius=2
     CollisionHeight=5
     bProjTarget=True
     bBounce=True
     Mass=50.000000
	 RealLocX=-1.0
	 RealLocY=-1.0
	 RealLocZ=-1.0
	 RealRotY=-1
	 RealRotP=-1
	 RealRotR=-1
}
