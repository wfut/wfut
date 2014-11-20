class WFPlasmaWave extends ShockWave;

var() name DamageType;

simulated function Timer()
{

	local actor Victims;
	local float damageScale, dist, MoScale;
	local vector dir;
	local float FFScale;

	ShockSize =  13 * (Default.LifeSpan - LifeSpan) + 3.5/(LifeSpan/Default.LifeSpan+0.05);
	if ( Level.NetMode != NM_DedicatedServer )
	{
		if (ICount==4) spawn(class'WarExplosion2',,,Location);
		ICount++;

		if ( Level.NetMode == NM_Client )
		{
			foreach VisibleCollidingActors( class 'Actor', Victims, ShockSize*29, Location )
				if ( Victims.Role == ROLE_Authority )
				{
					dir = Victims.Location - Location;
					dist = FMax(1,VSize(dir));
					dir = dir/dist +vect(0,0,0.3);
					if ( (dist> OldShockDistance) || (dir dot Victims.Velocity <= 0))
					{
						MoScale = FMax(0, 1100 - 1.1 * Dist);
						Victims.Velocity = Victims.Velocity + dir * (MoScale + 20);
						Victims.TakeDamage
						(
							MoScale,
							Instigator,
							Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
							(1000 * dir),
							DamageType
						);
					}
				}
			return;
		}
	}

	foreach VisibleCollidingActors( class 'Actor', Victims, ShockSize*29, Location )
	{
		dir = Victims.Location - Location;
		dist = FMax(1,VSize(dir));
		dir = dir/dist + vect(0,0,0.3);
		if (dist> OldShockDistance || (dir dot Victims.Velocity < 0))
		{
			MoScale = FMax(0, 1100 - 1.1 * Dist);
			if ( Victims.bIsPawn )
			{
				if (Level.Game.bTeamGame && (Instigator != None) && (Instigator != Victims)
					&& TeamGamePlus(Level.Game).IsOnTeam(pawn(Victims), Instigator.PlayerReplicationInfo.Team))
						FFScale = TeamGamePlus(Level.Game).FriendlyFireScale;
				else FFScale = 1.0;

				Pawn(Victims).AddVelocity(dir * (MoScale + 20) * FFScale);
			}
			else
				Victims.Velocity = Victims.Velocity + dir * (MoScale + 20);
			Victims.TakeDamage
			(
				MoScale,
				Instigator,
				Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
				(1000 * dir),
				DamageType
			);
		}
	}
	OldShockDistance = ShockSize*29;
}

defaultproperties
{
	DamageType=WFPlasmaDeath
}