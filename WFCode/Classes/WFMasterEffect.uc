class WFMasterEffect extends WFSpecialEffect;

// TODO: could use a more accurate timer method here

var() int NumEffects;
var() float ExpandRate; // not used
var() class<WFClientEffect> EffectClass;

var WFClientEffect ClientEffects;

var() float MinScale, MaxScale;

var() enum EScaleChangeType
{
	SCALE_None,
	SCALE_ExpandLinear,
	SCALE_ExpandFastSlow,
	SCALE_ExpandSlowFast,
	SCALE_ShrinkLinear,
	SCALE_ShrinkFastSlow,
	SCALE_ShrinkSlowFast
} ScaleEffect;

replication
{
	reliable if (Role == ROLE_Authority)
		ScaleEffect;
}

simulated function UpdateEffect(float DeltaTime)
{
	local WFClientEffect effect;
	local float phase, delta;
	local int count;

	// update effect positions and scale glow
	count=0;
	for (effect=ClientEffects; effect!=None; effect=effect.NextEffect)
	{
		if (!effect.bSelfManaged)
			UpdateClientEffect(DeltaTime, effect, Count);
		count++;
	}
}

simulated function UpdateClientEffect(float DeltaTime, WFClientEffect effect, int Index)
{
	local float phase, scale;

	phase = float(Index)/float(NumEffects);
	scale = GetDrawScaleCoef(phase);

	effect.DrawScale = MinScale + ((MaxScale - MinScale)*scale);
	//effect.ScaleGlow = (1-scale)*ScaleGlow; // fade while expanding
	//effect.Texture = class'WFModTex'.static.GetTex(255);
	effect.Style = ERenderStyle.STY_Modulated;
	effect.MultiSkins[0] = class'WFModTex'.static.GetTex(Clamp(128.0*scale,0,255));
	effect.MultiSkins[1] = class'WFModTex'.static.GetTex(Clamp(128.0*scale,0,255));
}

simulated function float GetDrawScaleCoef(float Phase)
{
	local float theta, scale;

	Phase = FClamp(Phase, 0.0, 1.0);

	switch (ScaleEffect)
	{
		// expanding styles
		case SCALE_ExpandLinear:
			return (EffectTime + Phase) % 1.0;
			break;

		case SCALE_ExpandFastSlow:
			theta = PI/2;
			scale = EffectTime - Phase*theta;
			if (scale > theta)
				scale = scale % theta;
			else if (scale < 0.0)
				scale = theta - (Phase*theta - EffectTime);
			return sin(scale); // from 0 to PI*0.5
			break;

		case SCALE_ExpandSlowFast:
			theta = PI/2;
			scale = EffectTime - Phase*theta;
			if (scale > theta)
				scale = scale % theta;
			else if (scale < 0.0)
				scale = theta - (Phase*theta - EffectTime);
			return 1.0 - sin(theta + scale); // from PI*0.5 to PI
			break;

		// shrinking styles
		case SCALE_ShrinkLinear:
			return 1.0 - ((EffectTime + Phase) % 1.0);
			break;

		case SCALE_ShrinkFastSlow:
			theta = PI/2;
			scale = EffectTime - Phase*theta;
			if (scale > theta)
				scale = scale % theta;
			else if (scale < 0.0)
				scale = theta - (Phase*theta - EffectTime);
			return 1.0 - sin(scale); // from 0 to PI*0.5
			break;

		case SCALE_ShrinkSlowFast:
			theta = PI/2;
			scale = EffectTime - Phase*theta;
			if (scale > theta)
				scale = scale % theta;
			else if (scale < 0.0)
				scale = theta - (Phase*theta - EffectTime);
			return sin(theta + scale); // from PI*0.5 to PI
			break;
	}


	return DrawScale;
}

simulated function Destroyed()
{
	// clean up
	if (ClientEffects != None)
	{
		ClientEffects.EffectDestroyed();
		ClientEffects = None;
	}

	super.Destroyed();
}

simulated function bool InitialiseEffect()
{
	local int count;

	for (count=0; count<NumEffects; count++)
	{
		if (ClientEffects == None)
			ClientEffects = spawn(EffectClass, self,, Location, Rotation);
		else ClientEffects.AddEffect(spawn(EffectClass, self,, Location, Rotation));
	}

	//EffectTime = PI/2;
	return true;
}

defaultproperties
{
     NumEffects=2
     EffectClass=Class'WFCode.WFClientEffect'
     MaxScale=1.000000
     ScaleEffect=SCALE_ExpandLinear
}
