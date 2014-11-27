class WFRDUJumpEffect extends WFMasterEffect;

#exec OBJ LOAD FILE=..\Textures\UT_ArtFX.utx PACKAGE=UT_ArtFX

var() float FinalDrawScale;

simulated function UpdateEffect(float DeltaTime)
{
	//DrawScale = FinalDrawScale * (LifeSpan/default.LifeSpan);
	DrawScale = FinalDrawScale * cos(PI*0.5*(LifeSpan/default.LifeSpan));
	ScaleGlow = 1 - cos(PI*0.5*(LifeSpan/default.LifeSpan));
}

defaultproperties
{
     FinalDrawScale=1.000000
     NumEffects=0
     LifeSpan=0.500000
     DrawType=DT_Mesh
     Style=STY_Translucent
     Texture=Texture'UT_ArtFX.ColdDot'
     Mesh=LodMesh'WFMedia.rdubounce'
     bUnlit=True
     MultiSkins(0)=Texture'UT_ArtFX.ColdDot'
     MultiSkins(1)=Texture'UT_ArtFX.ColdDot'
}
