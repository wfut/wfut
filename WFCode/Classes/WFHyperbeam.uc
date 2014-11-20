//=============================================================================
// WFHyperbeam.
//=============================================================================
class WFHyperbeam extends ShockBeam;

simulated function Timer()
{
	local ShockBeam r;

	if (NumPuffs>0)
	{
		r = Spawn(class'WFHyperbeam',,,Location+MoveAmount);
		r.RemoteRole = ROLE_None;
		r.NumPuffs = NumPuffs -1;
		r.MoveAmount = MoveAmount;
	}
}

defaultproperties
{
     //DrawScale=0.15
     DrawScale=0.25
     Texture=Texture'Botpack.FlareFX.utflare4'
     //Texture=Texture'Botpack.FlareFX.utflare3'
}
