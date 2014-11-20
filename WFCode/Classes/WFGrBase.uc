class WFGrBase extends WFS_PCSGrBase;

simulated function Tick(float DeltaTime)
{
	if (Owner != None)
	{
		if (Owner.Location != Location)
			SetLocation(Owner.Location);
		//if (Owner.Rotation != Rotation)
		//	SetRotation(Owner.Rotation);
	}
}

defaultproperties
{
	Physics=PHYS_None
	RemoteRole=ROLE_DumbProxy
	//bTrailerSameRotation=True
}