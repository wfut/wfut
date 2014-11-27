class WFDarkSphereEffect extends WFMasterEffect;

simulated function UpdateClientEffect(float DeltaTime, WFClientEffect effect, int Index)
{
	local float phase, scale;

	phase = float(Index)/float(NumEffects);
	scale = GetDrawScaleCoef(phase);

	effect.DrawScale = MinScale + ((MaxScale - MinScale)*scale);
	effect.Style = ERenderStyle.STY_Modulated;
	effect.MultiSkins[0] = class'WFModTex'.static.GetTex(Clamp(128.0*scale,0,255));
	effect.MultiSkins[1] = class'WFModTex'.static.GetTex(Clamp(128.0*scale,0,255));
	effect.bHidden = false;
	effect.Mesh = Mesh'geonormal';
	if (Owner != none)
		effect.SetLocation(Owner.Location);
}

defaultproperties
{
     ScaleEffect=SCALE_ExpandFastSlow
}
