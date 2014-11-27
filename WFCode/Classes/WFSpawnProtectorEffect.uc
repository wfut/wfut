class WFSpawnProtectorEffect extends Effects;

var float PulseSpeed, PulseTime;
var float BaseGlow;

var() bool bPulse;

var() string TextureString;

simulated function Tick(float DeltaTime)
{
	if (owner != None)
	{
		Mesh = Owner.Mesh;
		DrawScale = Owner.DrawScale;
		PrePivot = Owner.PrePivot;
	}

	if (bPulse)
	{
		// pulse effect
		if (Level.NetMode != NM_DedicatedServer)
		{
			PulseTime += DeltaTime*PulseSpeed;
			ScaleGlow = BaseGlow + abs(sin(PulseTime));
		}
	}

	if (Texture == None)
		Texture = texture(DynamicLoadObject(TextureString, class'Texture'));
}

defaultproperties
{
     PulseSpeed=4.000000
     TextureString="UnrealShare.newred"
     bAnimByOwner=True
     bOwnerNoSee=True
     bNetTemporary=False
     bTrailerSameRotation=True
     Physics=PHYS_Trailer
     RemoteRole=ROLE_SimulatedProxy
     DrawType=DT_Mesh
     Style=STY_Translucent
     Texture=FireTexture'UnrealShare.Belt_fx.ShieldBelt.RedShield'
     ScaleGlow=2.000000
     AmbientGlow=64
     Fatness=140
     bUnlit=True
     bMeshEnviroMap=True
}
