class WFGrenShockBoltParent extends WFTeslaChainParent;

function bool ValidTarget(actor Other)
{
	if (!super.ValidTarget(Other))
		return false;

	// don't target anything on same team as instigator, or cloaked/disguised infiltrators
	if (Other.bIsPawn && (Instigator != None) && Level.Game.IsA('TeamGamePlus')
		&& ( ( !class'WFCloaker'.static.IsHalfCloaked(Pawn(other))
				&& ( class'WFCloaker'.static.IsCloaked(Pawn(other)))
					|| class'WFDisguise'.static.IsDisguised(pawn(Other).PlayerReplicationInfo)) )
			|| TeamGamePlus(Level.Game).IsOnTeam(pawn(Other), Instigator.PlayerReplicationInfo.Team) )
		return false;

	return true;
}

defaultproperties
{
	ChainBoltClass=class'WFGrenShockBoltStarter'
	RemoteRole=ROLE_SimulatedProxy
	bNetTemporary=False
}