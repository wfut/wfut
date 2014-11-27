class WFMedKitFieldEffect extends WFMasterEffect;

var() texture TeamTexture;

simulated function Tick(float DeltaTime)
{
	if (Owner != none)
		SetLocation(Owner.Location);
	super.Tick(DeltaTime);
}

simulated function UpdateClientEffect(float DeltaTime, WFClientEffect effect, int Index)
{
	local float phase, scale;

	phase = float(Index)/float(NumEffects);
	scale = GetDrawScaleCoef(phase);

	effect.DrawScale = MinScale + ((MaxScale - MinScale)*scale);
	effect.Style = ERenderStyle.STY_Translucent;
	effect.ScaleGlow = (1-scale)*ScaleGlow; // fade while expanding
	effect.MultiSkins[0] = TeamTexture;
	effect.MultiSkins[1] = TeamTexture;
	effect.bHidden = false;
	effect.Mesh = LodMesh'geonormal';
	effect.bOwnerNoSee = True;
	if (Owner != none)
		effect.SetLocation(Owner.Location);
}

defaultproperties
{
     MaxScale=3.000000
     ScaleEffect=SCALE_ExpandFastSlow
     EffectRate=0.900000
     bOwnerNoSee=True
     ScaleGlow=2.500000
}
