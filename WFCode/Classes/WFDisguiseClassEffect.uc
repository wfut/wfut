class WFDisguiseClassEffect extends EnhancedRespawn;

/* too slow at LODBias = 1.0
auto state Explode
{
	simulated function Tick(float DeltaTime)
	{
		if (Level.bDropDetail || !Level.bHighDetailMode)
			LODBias = 0.0;
		super.Tick(DeltaTime);
	}
}*/

defaultproperties
{
	Physics=PHYS_Trailer
	bTrailerSameRotation=True
	bAnimByOwner=True
	bOwnerNoSee=True
	bNetOptional=False
	LODBias=0.0
	DrawScale=2.0
}