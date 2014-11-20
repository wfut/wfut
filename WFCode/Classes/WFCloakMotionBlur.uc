class WFCloakMotionBlur extends WFMotionBlurGenerator;

simulated function Tick(float DeltaTime)
{
	super.Tick(DeltaTime);

	Mesh = Owner.Mesh;
	Texture = Texture'JDomN0';
	PrePivot = Owner.PrePivot;
	DrawScale = Owner.DrawScale;
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