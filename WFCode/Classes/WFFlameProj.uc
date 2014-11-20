class WFFlameProj expands WFAnimatedProj;

var float FinalDrawScale;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	//Velocity = speed * vector(rotation);
	//Velocity += Owner.Velocity;
}

simulated function HitWall( vector HitNormal, actor Wall )
{
	Velocity = 0.75*(( Velocity dot HitNormal ) * HitNormal * (-1.0) + Velocity);   // Reflect off Wall w/damping
	speed = VSize(Velocity);
	if ( speed < 20 )
	{
		bBounce = False;
		SetPhysics(PHYS_None);
	}
}

simulated function ZoneChange(zoneinfo NewZone)
{
	local effects e;
	super.ZoneChange(NewZone);
	if (NewZone.bWaterZone)
	{
		e = spawn(class'UT_SpriteSmokePuff',,, Location);
		e.RemoteRole = ROLE_None;
		Destroy();
	}
}

simulated function Tick(float DeltaTime)
{
	DrawScale = default.DrawScale + ( (FinalDrawScale - default.DrawScale)*(1.0 - (LifeSpan/default.LifeSpan)) );
	super.Tick(DeltaTime);
}

auto state Flying
{
	simulated function ProcessTouch (Actor Other, Vector HitLocation)
	{
		local vector momentum;
		local pawn aPawn;
		local float damageScale, dist;
		local vector dir;
		local WFStatusOnFire s;
		local bool bGiveStatus;
		local class<WFPlayerClassInfo> PCI;

		if ((Level.NetMode == NM_Client) || (Role != ROLE_Authority) || (Other == Instigator))
			return;

		Other.TakeDamage(Damage, Instigator, HitLocation, vect(0,0,0), 'OnFireStatus');
		aPawn = Pawn(Other);
		if ((aPawn != None) && (aPawn.Health > 0) && aPawn.bIsPlayer)
		{
			// Status code based on Napalm Rocket.
			If ( Other!=Instigator && WFFlameProj(Other)==None && aPawn != None )
				if (aPawn.bIsPlayer && (aPawn.Health > 0))
				{
					PCI = class<WFPlayerClassInfo>(class'WFS_PlayerClassInfo'.static.GetPCIFor(aPawn));
					bGiveStatus = (PCI == None) || !PCI.static.IsImmuneTo(class'WFStatusOnFire');

					if (bGiveStatus && (aPawn.PlayerReplicationInfo.Team != Instigator.PlayerReplicationInfo.Team))
					{
						s = WFStatusOnFire(aPawn.FindInventoryType(class'WFStatusOnFire'));
						if (s != None)
						{
							s.OnFireTimeCount = 0;
							s.DamageTimeLeft = s.DamageTime;
							s.DamageAmount = s.default.DamageAmount;
						}
						else
						{
							s = spawn(class'WFStatusOnFire',,,aPawn.Location);
							s.GiveStatusTo(aPawn, Instigator);
						}
					}
				}
		}
	}
}


defaultproperties
{
	//Speed=325
	FinalDrawScale=1.0
	DrawScale=0.25
	Damage=3
	//Speed=450
	Speed=650
	DelayTime=0.04
	LifeSpan=0.5
	CollisionHeight=35
	CollisionRadius=35
	bCollideActors=true
	bCollideWorld=true
	AnimStyle=ANIM_Array
	TextureList(0)=texture'UnrealShare.s_exp001'
	TextureList(1)=texture'UnrealShare.s_exp002'
	TextureList(2)=texture'UnrealShare.s_exp003'
	TextureList(3)=texture'UnrealShare.s_exp004'
	TextureList(4)=texture'UnrealShare.s_exp005'
	TextureList(5)=texture'UnrealShare.s_exp006'
	TextureList(6)=texture'UnrealShare.s_exp007'
	TextureList(7)=texture'UnrealShare.s_exp008'
	TextureList(8)=texture'UnrealShare.s_exp009'
	TextureList(9)=texture'UnrealShare.s_exp010'
	TextureList(10)=texture'UnrealShare.s_exp011'
	TextureList(11)=texture'UnrealShare.s_exp012'
	TextureList(12)=texture'UnrealShare.s_exp013'
	TextureNum=12
	bBounce=True
	bNetTemporary=True
	RemoteRole=ROLE_None
}