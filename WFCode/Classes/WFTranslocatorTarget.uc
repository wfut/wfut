class WFTranslocatorTarget extends TranslocatorTarget;

auto state Pickup
{
	singular function Touch( Actor Other )
	{
		local bool bMasterTouch;
		local vector NewPos;

		if ( !Other.bIsPawn )
		{
			if ( (Physics == PHYS_Falling) && !Other.IsA('Inventory') && !Other.IsA('Triggers') && !Other.IsA('NavigationPoint')
				&& !Other.IsA('Projectile') )
				HitWall(-1 * Normal(Velocity), Other);
			return;
		}
		bMasterTouch = ( Other == Instigator );

		if ( Physics == PHYS_None )
		{
			if ( bMasterTouch )
			{
				PlaySound(Sound'Botpack.Pickups.AmmoPick',,2.0);
				Master.TTarget = None;
				Master.bTTargetOut = false;
				if ( Other.IsA('PlayerPawn') )
					PlayerPawn(Other).ClientWeaponEvent('TouchTarget');
				destroy();
			}
			return;
		}
		/*if ( bMasterTouch )
			return;
		NewPos = Other.Location;
		NewPos.Z = Location.Z;
		SetLocation(NewPos);
		Velocity = vect(0,0,0);
		if ( Level.Game.bTeamGame
			&& (Instigator.PlayerReplicationInfo.Team == Pawn(Other).PlayerReplicationInfo.Team) )
			return;

		if ( Instigator.IsA('Bot') )
			Master.Translocate();*/
	}
}