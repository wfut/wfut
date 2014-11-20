class WFCloakFadeEffect extends Effects;

var float FadeScale;

state FadingIn
{
	function BeginState()
	{
		//Log(self$" Fading out"@Level.TimeSeconds);
		ScaleGlow = 0.0;
		FadeScale = 1.0;
		bHidden = false;
		Mesh = Owner.Mesh;
	}

	function Tick( float DeltaTime )
	{
		if ((Owner == None) || Owner.IsInState('Dying'))
			return;
		Mesh = Owner.Mesh;
		PrePivot = Owner.PrePivot;
		ScaleGlow += DeltaTime * FadeScale;
		if (ScaleGlow >= 1.0)
		{
			bHidden = True;
			GotoState('Idle');
		}
	}
}

state FadingOut
{
	function BeginState()
	{
		//Log(self$" Fading in"@Level.TimeSeconds);
		ScaleGlow = 1.0;
		FadeScale = 1.0;
		bHidden = false;
		Mesh = Owner.Mesh;
	}

	function Tick( float DeltaTime )
	{
		if ((Owner == None) || Owner.IsInState('Dying'))
			return;
		Mesh = Owner.Mesh;
		PrePivot = Owner.PrePivot;
		ScaleGlow -= DeltaTime * FadeScale;
		if (ScaleGlow <= 0.0)
		{
			bHidden = True;
			GotoState('Idle');
		}
	}
}

state Idle
{
	function BeginState()
	{
		//Log(self$" entered idle state"@Level.TimeSeconds);
	}
}

defaultproperties
{
	bHidden=True
	bCollideActors=False
	bCollideWorld=False
	bBlockActors=False
	bBlockPlayers=False
	bAnimByOwner=True
	bOwnerNoSee=True
	bNetTemporary=False
	bTrailerSameRotation=True
	Physics=PHYS_Trailer
	RemoteRole=ROLE_None
	DrawType=DT_Mesh
	Style=STY_Translucent
	Skin=Texture'JDomN0'
	Texture=Texture'JDomN0'
	ScaleGlow=1.000000
	//Fatness=136
	bMeshEnviroMap=True
}