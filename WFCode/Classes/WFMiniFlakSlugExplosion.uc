class WFMiniFlakSlugExplosion extends UT_FlameExplosion;

simulated function PostBeginPlay()
{
	local actor a;

	Super(AnimSpriteEffect).PostBeginPlay();
	if ( Level.NetMode != NM_DedicatedServer )
	{
		if (!Level.bHighDetailMode)
			Drawscale = 0.7;
		else
			Spawn(class'WFMiniFlakShortSmokeGen');
	}
	MakeSound();
}

defaultproperties
{
	DrawScale=1.0
}