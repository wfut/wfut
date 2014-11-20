class WFDisguiseTeamEffect extends Effects;

var() float FadeDelay;
var() float FadeScale;

var pawn PawnOwner;

simulated function Tick(float DeltaTime)
{
	Mesh = Owner.Mesh;
	PrePivot = Owner.PrePivot;

	if (FadeDelay > 0.0)
		FadeDelay -= DeltaTime;

	if (FadeDelay <= 0.0)
	{
		Style = ERenderStyle.STY_Translucent;
		ScaleGlow -= DeltaTime * FadeScale;
	}

	if ((ScaleGlow <= 0.0) || Owner.IsInState('Dying'))
		Destroy();
}

defaultproperties
{
	Texture=texture'JDomN0'
	bNetTemporary=True
	bMeshEnviroMap=True
	Physics=PHYS_Trailer
	bTrailerSameRotation=True
	bAnimByOwner=True
	bOwnerNoSee=True
	DrawType=DT_Mesh
	RemoteRole=ROLE_SimulatedProxy
	Style=STY_Translucent
	Fatness=142
	FadeDelay=0.0
	FadeScale=1.0
	ScaleGlow=2.0
	bUnlit=True
}