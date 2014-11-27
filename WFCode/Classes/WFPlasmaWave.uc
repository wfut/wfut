class WFPlasmaWave extends ShockWave;

var() name DamageType;
var() float BaseDamage, DamageCoef, WaveScale;
var() bool bUniformDamage;

var string DamageList; // list of damaged actors so far "actor1,actor2,actor24,..etc"

simulated function Tick( float DeltaTime )
{
	if ( Level.NetMode != NM_DedicatedServer )
	{
		ShockSize = WaveScale * (13 * (Default.LifeSpan - LifeSpan) + 3.5/(LifeSpan/Default.LifeSpan+0.05));
		ScaleGlow = Lifespan;
		AmbientGlow = ScaleGlow * 255;
		DrawScale = ShockSize;
	}
}

simulated function Timer()
{

	local actor Victims;
	local float damageScale, dist, MoScale;
	local vector dir;
	local float FFScale;

	ShockSize = WaveScale * (13 * (Default.LifeSpan - LifeSpan) + 3.5/(LifeSpan/Default.LifeSpan+0.05));
	if ( Level.NetMode != NM_DedicatedServer )
	{
		if (ICount==4) spawn(class'WarExplosion2',,,Location);
		ICount++;

		if ( Level.NetMode == NM_Client )
		{
			foreach VisibleCollidingActors( class 'Actor', Victims, WaveScale*ShockSize*29, Location )
				if ( Victims.Role == ROLE_Authority )
				{
					dir = Victims.Location - Location;
					dist = FMax(1,VSize(dir));
					dir = dir/dist +vect(0,0,0.3);
					if ( (dist> OldShockDistance) || (dir dot Victims.Velocity <= 0))
					{
						if (bUniformDamage)
							MoScale = BaseDamage;
						else MoScale = FMax(0, BaseDamage - DamageCoef * Dist);
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


	foreach VisibleCollidingActors( class 'Actor', Victims, WaveScale*ShockSize*29, Location )
  	{
		if (CanDamageActor(Victims))
  		{
			dir = Victims.Location - Location;
			dist = FMax(1,VSize(dir));
			dir = dir/dist + vect(0,0,0.3);
			if (dist> OldShockDistance || (dir dot Victims.Velocity < 0))
  			{
				if (bUniformDamage)
					MoScale = BaseDamage;
				else MoScale = FMax(0, BaseDamage - DamageCoef*Dist);
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
				if (damagelist == "")
					Damagelist = string(victims.name);
				else damagelist = damagelist $","$victims.name;
  			}
  		}
  	}
	OldShockDistance = ShockSize*29*WaveScale;
}

function bool CanDamageActor(actor Other)
{
	local string list, next;

	if (Other == None)
		return false;

	list = damagelist;
	next = GetNextDamageActor(list);
	while (next != "")
	{
		if (next == string(other.name))
			return false;
		next = GetNextDamageActor(list);
	}

	return true;
}

function string GetNextDamageActor(out string actorlist)
{
	local string actorname;
	local int pos;

	pos = instr(actorlist, ",");

	actorname = "";
	if (pos >= 0)
	{
		actorname = Left(actorlist, pos);
		actorlist = right(actorlist, len(actorlist) - (pos+1));
	}
	else if (actorlist != "")
	{
		actorname = actorlist;
		actorlist = "";
	}

	return actorname;
}

defaultproperties
{
	DamageType=WFPlasmaDeath
    BaseDamage=1100.000000
    DamageCoef=1.100000
    WaveScale=1.000000
    bUniformDamage=True
}
