class WFSmokeTrailEffect extends WFSmokeEffect;

var() vector SpawnOffset;

Auto State Active
{
	Simulated function Timer()
	{
		local Effects d;

		if (!bHidden && (Level.NetMode != NM_DedicatedServer))
		{
			d = Spawn(GenerationType,,, Location + SpawnOffset);
			d.DrawScale = BasePuffSize+FRand()*SizeVariance;
			d.RemoteRole = ROLE_None;
			i++;
			if (i>TotalNumPuffs && TotalNumPuffs!=0) Destroy();
		}
	}
}

defaultproperties
{
	SmokeDelay=0.100000
	RemoteRole=ROLE_SimulatedProxy
	DrawType=DT_None
	bNetTemporary=False
	bHighDetail=False
	bNetOptional=False
	bHidden=True
}