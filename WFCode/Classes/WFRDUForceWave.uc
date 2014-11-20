class WFRDUForceWave extends shockrifleWave;

var() float ScaleFactor;

simulated function Tick( float DeltaTime )
{
	local float ShockSize;

	ShockSize = ScaleFactor/(ScaleGlow+0.05);
	if ( Level.NetMode != NM_DedicatedServer )
	{
		ScaleGlow = (Lifespan/Default.Lifespan);
		AmbientGlow = ScaleGlow * 255;
		DrawScale = ShockSize;
	}
}

defaultproperties
{
	ScaleFactor=0.35
	LifeSpan=0.75
}