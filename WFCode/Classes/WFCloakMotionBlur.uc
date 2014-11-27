class WFCloakMotionBlur extends WFMotionBlurGenerator;

simulated function Tick(float DeltaTime)
{
	Mesh = Owner.Mesh;
	Texture = Texture'JDomN0';
	PrePivot = Owner.PrePivot;
	DrawScale = Owner.DrawScale;

	super.Tick(DeltaTime);
}

simulated function bool ShouldCreateEffect()
{
	return !bHidden && (VSize(Owner.Velocity) > 10.0);
}

defaultproperties
{
	MotionBlurEffectClass=class'WFCloakBlurEffect'
	bHidden=True
	bOwnerNoSee=True
	bUnlit=True
	bMeshEnviroMap=True
	DrawType=DT_Mesh
}