class WFGrenShockBoltParent extends WFTeslaChainParent;

function bool ValidTarget(actor Other)
{
	if (!super.ValidTarget(Other))
		return false;

	// don't target anything on same team as instigator
	if (Other.bIsPawn && (Instigator != None) && Level.Game.IsA('TeamGamePlus')
		&& TeamGamePlus(Level.Game).IsOnTeam(pawn(Other), Instigator.PlayerReplicationInfo.Team))
		return false;

	return true;
}

defaultproperties
{
	ChainBoltClass=class'WFGrenShockBoltStarter'
	RemoteRole=ROLE_SimulatedProxy
	bNetTemporary=False
}