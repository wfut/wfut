class WFRailBeam extends ShockBeam
	abstract;

simulated function Timer()
{
	local ShockBeam r;

	if (NumPuffs>0)
	{
		r = Spawn(class,,,Location+MoveAmount);
		r.RemoteRole = ROLE_None;
		r.NumPuffs = NumPuffs -1;
		r.MoveAmount = MoveAmount;
	}
}

defaultproperties
{
	Texture=Texture'Sparky'
}