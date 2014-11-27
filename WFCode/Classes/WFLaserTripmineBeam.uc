class WFLaserTripmineBeam expands Projectile;

// Must be active before being able to trigger explosions. Active set by an "activate"
// message.
var bool bActive;

// Linked list.
var WFLaserTripmineBeam PrevBeam;
var WFLaserTripmineBeam NextBeam;

// Message buffer and relay system;
var bool bPendingAlert;
var int PendCount;
var float PDelayTicks;
var string PendingAlert;
var int PendingAlertDir;
var actor PendingActor;
var bool bWavingTex;
var actor PendingOther;
var bool bWaitForNextTickToSendDestroy;
var PlayerReplicationInfo OwnerPRI; // the PRI of the tripmines owner

// handle encroachment (don't cause movers to abort)
function bool EncroachingOn( actor Other )
{
	return false;
}

function Touch( actor Other )
{
	local int TeamN;
	local WFLaserTripmineBeam B;
	//Log(Self$": I got touched!");
	// OB1 - Fixme. Only explode if Other == self or Other is not on your team.
	//if ( WFLaserTripmineBeam(Other) == None && /*WFLaserDefense(Other) == None &&*/ bActive == true )
	//		SendAlert("explode", -1, Other);
	if (OwnerPRI == None)
	{
		warn("-- OwnerPRI == None!");
		return;
	}
	if ( bActive && (Other != None) && Other.bIsPawn && !IsCloaked(pawn(Other)) && (Pawn(Other).PlayerReplicationInfo != None)) // Other.bIsPawn covers (WFLaserTripmine(Owner) == None)
	{
		//if (!class'WFDisguise'.static.IsDisguised(pawn(Other).PlayerReplicationInfo) && (OwnerPRI.Team != pawn(Other).PlayerReplicationInfo.Team))
		if ( (IsHalfCloaked(pawn(Other)) || !class'WFDisguise'.static.IsDisguised(pawn(Other).PlayerReplicationInfo))
			&& (OwnerPRI.Team != pawn(Other).PlayerReplicationInfo.Team))
		{
			bWaitForNextTickToSendDestroy = true;
			PendingOther = Other;
		}
		else
		{
			for(B=WFLaserTripMineModule(Owner).Headbeam;B!=None;B=B.NextBeam)
			{
				if ( bWavingTex )
					return;
			}
			ProcessAlert("wavetex",Self);	// fake it
			if (PrevBeam != None)
				PrevBeam.SendAlert( "wavetex", -1, Other, 2.0 );
			if (NextBeam != None)
				NextBeam.SendAlert( "wavetex", 1, Other, 2.0 );
		}
	}
}

// returns true if player is cloaked
function bool IsCloaked(pawn Other)
{
	return (Other == None) || (Other.bMeshEnviroMap && (Other.Texture == FireTexture'Unrealshare.Belt_fx.Invis'));
}

function bool IsHalfCloaked(pawn Other)
{
	return (Other == None) || (Other.bMeshEnviroMap && (Other.Texture == Texture'JDomN0'));
}

simulated function DoCleanUp()
{
}

simulated function DestroyBeam()
{
	DoCleanUp();
	if ((NextBeam != None) && !NextBeam.bDeleteMe)
		NextBeam.DestroyBeam();
	Destroy();
}

simulated function texture CalculateRippleTex( int TeamN )
{
	if ( TeamN == 0 )
		TeamN = 1;
	else if ( TeamN == 1 )
		TeamN = 0;
	else if ( TeamN == 2 )
		TeamN = 3;
	else if ( TeamN == 3 )
		TeamN = 2;
	return WFLaserTripmineModule(Owner).TeamTextures[TeamN];
}

function Timer()
{
	if ( bWavingTex )
	{
		Skin = WFLaserTripmineModule(Owner).TeamTexture;
		//Log(Self$": resetting skin to"@Skin);
		bWavingTex = false;
		Disable('Timer');
	}
	else
	{
		//Log(Self$": Timer else Setting skin to"@Skin);
		//Skin = CalculateRippleTex( OwnerPRI.Team );
		Skin = WFLaserTripmineModule(Owner).TeamTexture;
		bWavingTex = true;
	}
}

simulated function ProcessAlert( string Alert, Actor AssociatedActor )
{
	switch (Alert)
	{
	case "activate":
		Skin = WFLaserTripmineModule(Owner).TeamTexture;
		bActive = true;
		break;
	case "deactivate":
		Skin = default.Skin;
		bActive=false;
		break;
	case "displayoff":
		DrawType=DT_None;
		break;
	case "displayon":
		DrawType=DT_Mesh;
		break;
	case "wavetex":
		Enable('Timer');
		SetTimer(0.5,true);
		Timer();
		break;
	case "destroy":
		DoCleanUp();
		Destroy();
		break;
	}
}

simulated singular function SendAlert( string AlertType, int Direction, Actor AssociatedActor, optional float DelayTicks)
{
	//Log( Self@": Got alert"@AlertType@"with direction"@Direction@"and associatedactor"@AssociatedActor);
	ProcessAlert( AlertType, AssociatedActor );
	if ( DelayTicks > 0 )
	{
		DelayAlert( AlertType, Direction, DelayTicks, AssociatedActor );
	}
	else
	{
		RelayAlert( AlertType, Direction, AssociatedActor );
	}
}

// This is the function that needs to be overriden in child classes.
simulated function RelayAlert( string Alert, int Direction, Actor PActor, optional float Delay)
{
	if ( Direction == 1 )
	{
		if (NextBeam != self)
			NextBeam.SendAlert( Alert, Direction, PActor, Delay );
	}
	else if (Direction == -1)
	{
		if (PrevBeam != self)
			PrevBeam.SendAlert( Alert, Direction, PActor, Delay );
	}
}

simulated function DelayAlert( string Alert, int Dir, float DelayTicks, actor PActor )
{
	// Dispatch waiting message IMMEDIALTY!
	if( bPendingAlert )
	{
		RelayAlert( PendingAlert, PendingAlertDir, PendingActor, 0);
	}

	PDelayTicks = DelayTicks;
	PendingActor = PActor;
	PendingAlert = Alert;
	PendingAlertDir = Dir;
	PendCount = 0;
	bPendingAlert = true;
}

function Tick(float deltatime)
{
	if ( bWavingTex )
	{
		ScaleGlow += 1.5 * Deltatime;
	}
	if ( ScaleGlow > default.ScaleGlow && !bWavingTex )
	{
		ScaleGlow -= 1.5 * DeltaTime;
		if ( ScaleGlow < default.ScaleGlow )
			ScaleGlow = default.ScaleGlow;
	}
	if ( bWaitForNextTickToSendDestroy )
	{
		bWaitForNextTickToSendDestroy = false;
		//SendAlert("explode", -1, PendingOther);
		// Ob1: send the explode message *directly* to the module
		WFLaserTripmineModule(Owner).ReceiveAlert("explode", -1, PendingOther);
	}
	if( bPendingAlert )
	{
		PendCount++;
		if( PendCount >= PDelayTicks )
		{
			RelayAlert( PendingAlert, PendingAlertDir, PendingActor, PDelayTicks);
			bPendingAlert = false;
		}
	}

}

defaultproperties
{
	 Physics=PHYS_None
	 RemoteRole=ROLE_None
	 CollisionHeight=2
	 CollisionRadius=2
     bNetTemporary=False
     Physics=PHYS_None
     Style=STY_Translucent
	 Skin=texture'WFMedia.BeamWhiteTex'
     Mesh=LodMesh'Botpack.PBolt'
     bCollideActors=True
	 DrawScale=0.300000
     bUnlit=True
	 ScaleGlow=0.4
	 LifeSpan=0.0
	 bCollideWorld=false
}