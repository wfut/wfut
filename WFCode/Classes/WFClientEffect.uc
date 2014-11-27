class WFClientEffect extends WFSpecialEffect;

var() bool bSelfManaged; // effect handles its own drawscale, etc

var WFClientEffect NextEffect;

simulated function AddEffect(WFClientEffect newEffect)
{
	GetLast().NextEffect = newEffect;
}

simulated function WFClientEffect GetLast()
{
	local WFClientEffect e;

	if (NextEffect == None)
		return self;

	e = NextEffect;
	while (e.NextEffect!=None)
		e = e.NextEffect;

	return e;
}

simulated function EffectDestroyed()
{
	if (NextEffect != None)
		NextEffect.EffectDestroyed();

	Destroy();
}

defaultproperties
{
     RemoteRole=ROLE_None
     DrawType=DT_Mesh
     Style=STY_Translucent
     Mesh=LodMesh'WFMedia.geotwos'
     bUnlit=True
}
