//=============================================================================
// WFFireEffect.
//=============================================================================
class WFFireEffect extends Effects;

simulated function Tick(float DeltaTime)
{
	if (Level.bDropDetail || !Level.bHighDetailMode)
		bOwnerNoSee = True;
}

defaultproperties
{
	Physics=PHYS_Trailer
	RemoteRole=ROLE_None
	DrawType=DT_Mesh
	Texture=FireTexture'SmallFire1'
	LODBias=0.000000
	Style=STY_Translucent
	bAnimByOwner=true
	bTrailerSameRotation=True
	bNetTemporary=False
	bParticles=True
	bUnlit=True
	PrePivot=(Z=15.000000)
}