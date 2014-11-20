class WFLaserTripmineBeamTail expands WFLaserTripmineBeam;

var WFLaserTripmineCap TailFX;
var texture TailFXTexture[5];
var bool bPongNextMessage;
var int PongSpeed;
var string PongReply;
var string PongChallenge;

simulated function ProcessAlert( string Alert, Actor AssociatedActor )
{
	if ( Alert == PongChallenge && bPongNextMessage )
	{
		PrevBeam.SendAlert(PongReply,-1,Self,PongSpeed);
		bPongNextMessage = false;
		return;
	}
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

function AddTail(vector Loc, rotator Rot)
{
	TailFX = spawn(class'WFLaserTripmineCap', Self,, Loc - ((-vector(Rot))*-4.0), rotator(-vector(Rot)));
	//TailFX.DrawScale = 1.25;
	TailFX.DrawScale = 0.5;
	if (OwnerPRI.Team < 4)
		TailFX.Texture = TailFXTexture[OwnerPRI.Team];
	else TailFX.Texture = TailFXTexture[4];
	TailFX.LifeSpan = 0.0;
	//TailFX.LoopAnim('Flying');
}

simulated function DoCleanup()
{
	if ( TailFX != None)
		TailFX.Destroy();
	Super.DoCleanUp();
}

simulated function RelayAlert( string Alert, int Direction, Actor PActor, optional float Delay)
{
	if (Direction == -1)
		PrevBeam.SendAlert( Alert, Direction, PActor, Delay );
}

defaultproperties
{
	TailFXTexture(0)=Texture'RedSkin2'
	TailFXTexture(1)=Texture'BlueSkin2'
	TailFXTexture(2)=Texture'UnrealShare.Belt_fx.ShieldBelt.NewGreen'
	TailFXTexture(3)=Texture'GoldSkin2'
	TailFXTexture(4)=Texture'JDomN0'
}