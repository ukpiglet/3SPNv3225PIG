/* some code taken from L7's freeze tag mod */

class Freon_Pawn extends Misc_Pawn;

var bool            bFrozen;
var bool            bClientFrozen;
var bool			bGivesGit;

var Freon_Trigger   MyTrigger;

var float           DecimalHealth;    // used server-side only, to allow decimals to be added to health

var Material        FrostMaterial;
var Material        FrostMap;

var bool            bThawFast;

var array<TAM_Mutator.WeaponData> MyWD;

var Sound           ImpactSounds[6];
var Controller		LastKiller;
var float           TimeKilled;

var protected const Class<DamageType> ShatteredDamageTypeClass;
var(Gib) protected const Class<xPawnGibGroup> FrozenGibGroupClass;
var() const Vector NullVector;

replication
{
    reliable if(bNetDirty && Role == ROLE_Authority)
        bFrozen;
}

simulated function UpdatePrecacheMaterials()
{
    Super.UpdatePrecacheMaterials();

    Level.AddPrecacheMaterial(FrostMaterial);
    Level.AddPrecacheMaterial(FrostMap);
}

simulated function Destroyed()
{
    if(MyTrigger != None)
    {
        MyTrigger.Destroy();
        MyTrigger = None;
    }

    Super.Destroyed();
}

function PossessedBy(Controller C)
{
    Super.PossessedBy(C);

    if(MyTrigger == None)
        MyTrigger = spawn(class'Freon_Trigger', self,, Location, Rotation);
}

function TakeDamage(int Damage, Pawn InstigatedBy, Vector HitLocation, Vector Momentum, class<DamageType> DamageType)
{
    local vector zeroVec;
    local int ActualDamage;
    local Controller Killer;

    zeroVec = vect(0.0,0.0,0.0);

	if(IsSpawnProtectionEnabled())
    {
        Super.TakeDamage(0, instigatedBy, hitlocation, zeroVec, damageType);
        return;
    }

    if ( DamageType == None )
    {
        if ( InstigatedBy != None )
            Warn( "No DamageType for damage by "$InstigatedBy$" with weapon "$InstigatedBy.Weapon );
        DamageType = class'DamageType';
    }

    if ( Role < ROLE_Authority )
    {
        //Log( self$" client DamageType "$DamageType$" by "$InstigatedBy );
        return;
    }

	if (DamageType == class'DamTypeTelefrag' && !Misc_BaseGRI(Level.GRI).bAllowTelefrags){
		Super.TakeDamage(0, instigatedBy, hitlocation, zeroVec, damageType);
        return;
	}

    if ( Health <= 0 )
        return;

    if ( ( InstigatedBy == None || InstigatedBy.Controller == None ) &&
         ( DamageType.default.bDelayedDamage ) &&
         ( DelayedDamageInstigatorController != None ) )
        InstigatedBy = DelayedDamageInstigatorController.Pawn;

    if ( Physics == PHYS_None && DrivenVehicle == None )
        SetMovementPhysics();

    if ( Physics == PHYS_Walking && DamageType.default.bExtraMomentumZ )
        Momentum.Z = FMax( Momentum.Z, 0.4 * VSize( Momentum ) );

    if ( InstigatedBy == self )
        Momentum *= 0.6;

    Momentum = Momentum / Mass;

    if ( Weapon != None )
        Weapon.AdjustPlayerDamage( Damage, InstigatedBy, HitLocation, Momentum, DamageType );

    if ( DrivenVehicle != None )
        DrivenVehicle.AdjustDriverDamage( Damage, InstigatedBy, HitLocation, Momentum, DamageType );

    if ( ( InstigatedBy != None ) && InstigatedBy.HasUDamage() )
        Damage *= 2;

    ActualDamage = Level.Game.ReduceDamage( Damage, self, InstigatedBy, HitLocation, Momentum, DamageType );

    if( DamageType.default.bArmorStops && ( ActualDamage > 0 ) )
        ActualDamage = ShieldAbsorb( ActualDamage );

    Health -= ActualDamage;

    if ( HitLocation == vect(0,0,0) )
        HitLocation = Location;

/* L7 out
    PlayHit( ActualDamage, InstigatedBy, HitLocation, DamageType, Momentum );
L7 out */

    if ( Health <= 0 )
    {
        // pawn froze or died -->

        if ( DamageType.default.bCausedByWorld && ( InstigatedBy == None || InstigatedBy == self ) && LastHitBy != None )
            Killer = LastHitBy;
        else if ( InstigatedBy != None )
            Killer = InstigatedBy.GetKillerController();

        if ( Killer == None && DamageType.default.bDelayedDamage )
            Killer = DelayedDamageInstigatorController;

        if(Level.Game.PreventDeath(self, Killer, DamageType, HitLocation))
        {
            Health = Max(Health, 1);

            PlayHit(ActualDamage, InstigatedBy, HitLocation, DamageType, Momentum);

            if(bPhysicsAnimUpdate)
                TearOffMomentum = Momentum;
        }
        else if(Froze(Killer, DamageType, HitLocation)){
            PlayFreezingHit();
			LastKiller = Killer;
			TimeKilled = Level.TimeSeconds;
		}
        else
        {
            PlayHit(ActualDamage, InstigatedBy, HitLocation, DamageType, Momentum);

            if (bPhysicsAnimUpdate)
                TearOffMomentum = Momentum;

            Died(Killer, DamageType, HitLocation);
        }
    }
    else
    {
        // pawn only damaged -->
// L7 -->
        PlayHit( ActualDamage, InstigatedBy, HitLocation, DamageType, Momentum );
// L7 <--
        AddVelocity( Momentum );

        if ( Controller != None )
            Controller.NotifyTakeHit( InstigatedBy, HitLocation, ActualDamage, DamageType, Momentum );

        if ( InstigatedBy != None && InstigatedBy != self )
            LastHitBy = InstigatedBy.Controller;
    }
    MakeNoise( 1.0 );
}

function Died(Controller Killer, class<DamageType> DamageType, vector HitLocation)
{
    local Freon_PRI xPRI;
    local Freon Freon;
    local Misc_Player Gitter;

	//piglet - test weapon activate on death (but not client side
	if (Role == ROLE_Authority)
		if ( Weapon != None && Freon(Level.Game).bDeathFire)
		{
			if ( Controller != None )
				Controller.LastPawnWeapon = Weapon.Class;
				
			Weapon.HolderDied();
		}
	
    if(bGivesGit)
    {
        if(Killer!=None)
            Gitter = Misc_Player(Killer);
        else if(LastHitBy!=None)
            Gitter = Misc_Player(LastHitBy);
        else
            Gitter = None;

        if(Gitter!=None && self.Controller!=Gitter)
        {
            xPRI = Freon_PRI(Gitter.PlayerReplicationInfo);
            if(xPRI!=None)
            {
                ++xPRI.Git;

                Freon = Freon(Level.Game);
                if(Freon.KillGitters)
                {
                    if(xPRI.Git==Freon.MaxGitsAllowed)
                    {
                        Gitter.ClientMessage("Warning:"@Class'GameInfo'.static.MakeColorCode(Freon.KillGitterMsgColour)$Freon.KillGitterMsg);
                    }
                    else if(xPRI.Git>Freon.MaxGitsAllowed)
                    {
                        Gitter.BroadcastAnnouncement(class'Message_Git');
                        if(Gitter.Pawn!=None)
                            Gitter.Pawn.Suicide();
                    }
                }
                else
                {
                    if(Freon.iAdrenGitters != 0 && xPRI.Git%Freon.iAdrenGitters == 0) 
                    {
                        if(Gitter!=None)
                            Gitter.BroadcastAnnouncement(class'Message_Git');
                        Gitter.Adrenaline = Max(0,Gitter.Adrenaline-Freon.AdrenGitLose);
                    }
                }
            }
        }
    }

    if(MyTrigger != None)
        MyTrigger.OwnerDied();

    Super.Died(Killer, DamageType, HitLocation);
}

function bool Froze(Controller Killer, class<DamageType> DamageType, Vector HitLocation)
{
    //local Vector TossVel;
    local Trigger T;
    local NavigationPoint N;
	local Freon_PawnReplicationInfo FPRI;

    // DETERMINE IF PAWN FROZE -->

    if(bDeleteMe || Level.bLevelChange || Level.Game == None)
        return false;

	//piglet - weapon activate on death (but not client side!)
	if (Role == ROLE_Authority)
		if ( Weapon != None && Freon(Level.Game).bDeathFire)
		{
			if ( Controller != None )
				Controller.LastPawnWeapon = Weapon.Class;
				
			Weapon.HolderDied();
		}
			
    if(Controller == None || DrivenVehicle != None)
        return false;

    if(DamageType == class'DamageType' || DamageType.default.bCausedByWorld){
        return false;
	}

    if(IsInPain()){
        return false;
	}

    // PAWN FROZE -->

    bFrozen = true;

    FPRI = Freon_PawnReplicationInfo(Freon_PRI(PlayerReplicationInfo).PawnReplicationInfo);
	if(FPRI != None)
        FPRI.PawnFroze();

    FillWeaponData();
    Health = 0;
    AmbientSound = None;
    bProjTarget = false;
    bCanPickupInventory = false;
    //bNoWeaponFiring = true;

    PlayerReplicationInfo.bOutOfLives = true;
    NetUpdateTime = Level.TimeSeconds - 1;
    Controller.WasKilledBy(Killer);
    Level.Game.Killed(Killer, Controller, self, DamageType);

    if ( Killer != None )
        TriggerEvent( Event, self, Killer.Pawn );
    else
        TriggerEvent( Event, self, None );

    // make sure to untrigger any triggers requiring player touch
    if ( IsPlayerPawn() || WasPlayerPawn() )
    {
        PhysicsVolume.PlayerPawnDiedInVolume( self );

        ForEach TouchingActors( class'Trigger', T )
            T.PlayerToucherDied( self );
        ForEach TouchingActors( class'NavigationPoint', N )
        {
            if ( N.bReceivePlayerToucherDiedNotify )
                N.PlayerToucherDied( self );
        }
    }

    // remove powerup effects, etc.
    RemovePowerups();

    //Velocity.Z *= 1.3;

    if ( IsHumanControlled() )
        PlayerController( Controller ).ForceDeathUpdate();

    Freon(Level.Game).PawnFroze(self);
    Freeze();
    return true;
}

function PlayFreezingHit()
{
    if(PhysicsVolume.bDestructive && ( PhysicsVolume.ExitActor != None))
        Spawn(PhysicsVolume.ExitActor);
}

function Freeze()
{
    if(MyTrigger != None)
        MyTrigger.OwnerFroze();

    bPlayedDeath = true;
    StopAnimating(true);

    GotoState('Frozen');
}

function FillWeaponData()
{
    local Inventory inv;
    local int i;
	local Weapon W;

    for(inv = Inventory; inv != None; inv = inv.Inventory)
    {
        W = Weapon(inv);
		if(W == None)
            continue;

        i = MyWD.Length;
        MyWD.Length = i + 1;

        MyWD[i].WeaponName = string(inv.Class);
        MyWD[i].Ammo[0] = W.AmmoCharge[0];
        MyWD[i].Ammo[1] = W.AmmoCharge[1];
    }
}


//This only appears to be being used when playing *online*. No idea why.
simulated function Tick(float DeltaTime)
{
    Super.Tick(DeltaTime);

    if(Level.NetMode == NM_DedicatedServer)
        return;

    if(bFrozen && !bClientFrozen)
    {
		bPhysicsAnimUpdate = false;
		bClientFrozen = true;
		StopAnimating(true);

		if(Level.bDropDetail || Level.DetailMode == DM_Low)
			ApplyLowQualityIce();
		else
			ApplyHighQualityIce();

		bScriptPostRender = true;
    }
}

simulated function ApplyLowQualityIce()
{
    local Combiner Body;
    local Combiner Head;

    if(MyOwner != None && MyOwner.PlayerReplicationInfo == PlayerReplicationInfo)
    {
        ApplyHighQualityIce();
        return;
    }

    Body = new(none)class'Combiner';
    Head = new(none)class'Combiner';

    SetOverlayMaterial(None, 0.0, true);
    SetStandardSkin();

    Body.CombineOperation = CO_Add;
    Body.Material1 = Skins[0];
    Body.Material2 = FrostMaterial;

    Head.CombineOperation = CO_Add;
    Head.Material1 = Skins[1];
    Head.Material2 = FrostMaterial;

    Skins[0] = Body;
    Skins[1] = Head;
}

simulated function ApplyHighQualityIce()
{
    local Combiner Body;
    local Combiner Head;
    local Combiner Ice;

    Body = new(none)class'Combiner';
    Head = new(none)class'Combiner';
    Ice = new(none)class'Combiner';

    SetOverlayMaterial(None, 0.0, true);
	SetStandardSkin();

    Ice.CombineOperation = CO_Subtract;
    Ice.Material1 = FrostMap;
    Ice.Material2 = FrostMaterial;

    Body.CombineOperation = CO_Add;
    Body.Material1 = Skins[0];
    Body.Material2 = Ice;

    Head.CombineOperation = CO_Add;
    Head.Material1 = Skins[1];
    Head.Material2 = Ice;

    Skins[0] = Body;
    Skins[1] = Head;
}

simulated function SetSkin(int OverrideTeamIndex)
{
    if(bClientFrozen)
        return;

    Super.SetSkin(OverrideTeamIndex);
}

function DiedFrozen(Controller Killer, class<DamageType> DamageType, vector HitLocation)
{
	local Freon F;

	F = Freon(Level.Game);
    if(F != None){
		F.PlayerThawed(self, 0, 0);
	}
    Died(Killer, DamageType, HitLocation);
}

function Thaw()
{
local Controller C;
local Freon F;

	C = Controller;

	bGivesGit = false;
	F = Freon(Level.Game);
    if(F != None){
     	 F.PlayerThawed(self, 0, 0);
		 F.ReTrigger(C);
	}
	
}

function ThawByTouch(array<Freon_Pawn> Thawers, optional float mosthealth)
{
local Controller C;
local Freon F;

	C = Controller;

	bGivesGit = false;
	F = Freon(Level.Game);
    if(F != None){
        F.PlayerThawedByTouch(self, Thawers, mosthealth, shieldstrength);
		F.ReTrigger(C);
	}
}

/*
Pawn was killed - detach any controller, and die
*/
simulated function ChunkUp( Rotator HitRotation, float ChunkPerterbation )
{
	if ( (Level.NetMode != NM_Client) && (Controller != None) )
	{
		if ( Controller.bIsPlayer )
			Controller.PawnDied(self);
		else
			Controller.Destroy();
	}

	bTearOff = true;

	if ( (Level.NetMode == NM_DedicatedServer) || (Level.NetMode == NM_ListenServer) )
		GotoState('TimingOut');
	if ( Level.NetMode == NM_DedicatedServer )
		return;
	if ( class'GameInfo'.static.UseLowGore() )
	{
		Destroy();
		return;
	}
	SpawnGibs(HitRotation,ChunkPerterbation);

	if ( Level.NetMode != NM_ListenServer )
		Destroy();
}

simulated event PlayDying (Class<DamageType> DamageTypeClass, Vector HitLoc)
{
	if(bFrozen)
	{
		PlayShattered();
	}
	else
	{
		super.PlayDying (DamageTypeClass, HitLoc);
	}

}

State Frozen
{
    ignores AnimEnd, Trigger, Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer;

    event ChangeAnimation() {}
    event StopPlayFiring() {}
    function PlayFiring( float Rate, name FiringMode ) {}
    function PlayWeaponSwitch( Weapon NewWeapon ) {}
    function PlayTakeHit( Vector HitLoc, int Damage, class<DamageType> DamageType ) {}
    simulated function PlayNextAnimation() {}
    function TakeFallingDamage() {}

    event Landed( vector HitNormal )
    {
        Velocity = vect(0,0,0);
        SetPhysics(PHYS_Walking);
        LastHitBy = None;
        PlaySound(default.ImpactSounds[Rand(6)], SLOT_Pain, 1.5 * TransientSoundVolume);
    }

	//This only appears to be being used when playing *offline*. No idea why.
    event Tick( float DeltaTime )
    {
        if(Physics==PHYS_Walking || Physics==PHYS_Swimming || Physics==PHYS_None)
            bGivesGit = true;
        
	    if(Level.NetMode != NM_DedicatedServer){
            if(bFrozen && !bClientFrozen){
				bPhysicsAnimUpdate = false;
				bClientFrozen = true;
				StopAnimating(true);

				if(Level.bDropDetail || Level.DetailMode == DM_Low)
					ApplyLowQualityIce();
				else
					ApplyHighQualityIce();

				bScriptPostRender = true;
			}
		}
		
        Global.Tick(DeltaTime);
    }

    function TakeDamage( int Damage, Pawn InstigatedBy, Vector HitLocation, Vector Momentum, class<DamageType> DamageType )
    {
		local Freon F;
		local Freon_Pawn FP;
      		
        if ( DamageType == None )
        {
            if ( InstigatedBy != None )
                Warn( "No DamageType for damage by "$InstigatedBy$" with weapon "$InstigatedBy.Weapon );
            DamageType = class'DamageType';
        }

        if ( Role < ROLE_Authority )
        {
            //Log( self$" client DamageType "$DamageType$" by "$InstigatedBy );
            return;
        }

		if(DamageType == class'DamTypeTelefrag'){
			return;
		}
		
        if ( HitLocation == vect(0,0,0) )
            HitLocation = Location;

        if(DamageType.default.bCausedByWorld)
        {
			if(DamageType.IsA('FellLava')){
				Thaw();
				F = Freon(Level.Game);
				if (!F.bAllowSelfKillThaw && LastKiller != None && LastKiller == Controller && Level.TimeSeconds - TimeKilled <= F.SelfKillLavaThawtime){
					FP = Freon_Pawn(Controller.Pawn);
					FP.DeactivateSpawnProtection();
					FP.Health = 1;
					FP.ShieldStrength = 1;
				}
			}
			else{
				DiedFrozen(None, DamageType, HitLocation);
			}
			return;
        }

		PlayHit (Damage, InstigatedBy, HitLocation, DamageType, Momentum);
        if ( Physics == PHYS_Walking && DamageType.default.bExtraMomentumZ )
            Momentum.Z = FMax( Momentum.Z, 0.4 * VSize( Momentum ) );

        Momentum = Momentum / (Mass * 1.5);
        SetPhysics(PHYS_Falling);
        Velocity += Momentum;

        if ( ( InstigatedBy == None || InstigatedBy.Controller == None ) &&
             ( DamageType.default.bDelayedDamage ) &&
             ( DelayedDamageInstigatorController != None ) )
            InstigatedBy = DelayedDamageInstigatorController.Pawn;

        if ( InstigatedBy != None && InstigatedBy != self )
            LastHitBy = InstigatedBy.Controller;
    
		if ( InstigatedBy != None && Freon(Level.Game).bEnemyBioThaws &&
			(self.GetTeamNum() != InstigatedBy.GetTeamNum()) && 
			(DamageType == class'DamTypeBioGlob' || DamageType == class'DamType_BioGlob')){
			GiveHealth(Freon(Level.Game).EnemyBioThawPercent*Damage/100, 99);
		}
    }

    function BeginState()
    {
		local Freon_Player FP;
		local Freon_Bot FB;

        SetPhysics(PHYS_Falling);

        LastHitBy = None;
        Acceleration = vect(0,0,0);
        TearOffMomentum = vect(0,0,0);

		FP = Freon_Player(Controller);
        if(FP != None)
        {
            FP.FrozenPawn = self;
            FP.Freeze();
        }
        else
		{
			FB  = Freon_Bot(Controller);
			if(FB != None)
				FB.Freeze();
		}
			
		if (Freon(Level.Game).bCanStandOnIcicle)
			bCanBeBaseForPawns = True;
    }
	
	function EndState(){
		if (Freon(Level.Game).bCanStandOnIcicle)
			bCanBeBaseForPawns = False;
	}

    event PlayDyingSound ()
	{
	}
	
	event PlayHit (float Damage, Pawn InstigatedBy, Vector HitLocation, Class<DamageType> DamageTypeClass, Vector Momentum)
	{
		local Team_GameBase GB;

		if(!bDeleteMe && !Level.bLevelChange && (Level.Game != None)){
			//if(!Freon_GRI(Level.GRI).bLiveRound && ( ((Class<DamTypeShieldImpact>(DamageTypeClass) != None) && (Damage >= 60)) || (Class<DamTypeShieldImpact>(DamageTypeClass) == None)))
			
			GB = Team_GameBase(Level.Game);
			if((GB.bEndOfRound || GB.EndOfRoundTime > 0) && Shatters(DamageTypeClass)){
				Shattered ();
			}
			else if ((Level.TimeSeconds - LastPainTime) > 0.1f)
			{
				PlayTakeHit (HitLocation, Damage, DamageTypeClass);
				LastPainTime = Level.TimeSeconds;
			}
		}
	}
	
	function bool Shatters(Class<DamageType> DamageTypeClass){
		return	Class<DamTypeShieldImpact>(DamageTypeClass) != None ||
				Class<DamTypeShockBeam>(DamageTypeClass) != None ||
				Class<DamTypeShockCombo>(DamageTypeClass) != None ||
				Class<DamType_FlakShell>(DamageTypeClass) != None ||
				Class<DamTypeShockBall>(DamageTypeClass) != None;
	}
	

	
	protected function Shattered ()
	{
		Health = 0;
		Super.Died(None, ShatteredDamageTypeClass, Location);
		
		//PlayerReplicationInfo.Deaths = PlayerReplicationInfo.Deaths - 1; //From Frozen...doesn't count as a death. Not needed now Shattered doesn't count as a death
	}

	event Died (Controller Killer, Class<DamageType> DamageTypeClass, Vector HitLocation ){
		Health = 0;
		Super.Died (None, ShatteredDamageTypeClass, HitLocation); // Ignore Global.Died () because already thawing.
		if(PlayerReplicationInfo != None)
			PlayerReplicationInfo.Deaths = PlayerReplicationInfo.Deaths - 1; //From Frozen...doesn't count as a death.
	}

	simulated event PlayDying (Class<DamageType> DamageTypeClass, Vector HitLoc)
	{
		PlayShattered ();
	}

	event KilledBy (Pawn IgnoredEventInstigator)
	{
		Health = 0;
		Super.Died (None, ShatteredDamageTypeClass, Location);
	}

	event GibbedBy (Actor Other)
	{
		local Pawn P;
		if (Role == ROLE_Authority)
		{
			Health = 0;
			P = Pawn(Other);
			if (P != None)
			{
				if (P.Weapon != None && P.Weapon.IsA ('Translauncher') )
					Super.Died (None, P.Weapon.GetDamageType (), Location);
				else
					Super.Died (None, ShatteredDamageTypeClass, Location);
			}
			else
				Super.Died (None, ShatteredDamageTypeClass, Location);
		}
	}
}

//when out of the `state frozen` block it works as intended, but inside the block it gets impacted by the user gore preferences
simulated event SpawnGiblet (Class<Gib> GibClass, Vector Location, Rotator Rotation, float GibPerterbation){
	local Gib Giblet;
	local Vector Direction, Dummy;

	if (GibClass != None)
	{
		Instigator = Self;

		Giblet = Spawn (GibClass,,, Location, Rotation);

		if (Giblet != None)
		{
			Giblet.bFlaming = bFlaming;
			Giblet.SpawnTrail ();

			GibPerterbation *= 32768.0;

			Rotation.Pitch += ( FRand() * 2.0 * GibPerterbation ) - GibPerterbation;
			Rotation.Yaw += ( FRand() * 2.0 * GibPerterbation ) - GibPerterbation;
			Rotation.Roll += ( FRand() * 2.0 * GibPerterbation ) - GibPerterbation;

			GetAxes( Rotation, Dummy, Dummy, Direction );

			Giblet.Velocity = Velocity + Normal(Direction) * (250 + 260 * FRand());
			Giblet.LifeSpan = Giblet.LifeSpan + 2 * FRand() - 1;
		}
	}
}

protected simulated function PlayShattered ()
{
	local class<Gib> CachedGibClass;
	local Vector HitNormal;
	local int Index;

	HitDamageType = ShatteredDamageTypeClass;

	TakeHitLocation = NullVector;

	AmbientSound = None;

	bCanTeleport = False;
	bReplicateMovement = False;
	bSkeletized = True; // Cheap way to get around playing death scream.
	bTearOff = True; // Calls PlayDying on client.
	bPlayedDeath = True;

	LifeSpan = RagdollLifeSpan;

	if (Level.NetMode != NM_DedicatedServer)
	{
		CachedGibClass = FrozenGibGroupClass.Static.GetGibClass (EGT_Head);

		for (Index = 0; Index < 8; ++Index)
		{
			HitNormal = Normal (Vect (0.0f, 0.0f, 1.0f) + VRand () * 0.2f + Vect (0.0f, 0.0f, 2.8f));

			SpawnGiblet (CachedGibClass, Location, Rotator(HitNormal), 1.0f);
		}
	}

	GotoState ('Dying');


	BaseEyeHeight = Default.BaseEyeHeight;


	SetInvisibility (0.0f);


	if (Physics == PHYS_Walking)
	{
		Velocity = NullVector;
	}


	bHidden = True;
}

defaultproperties
{
     FrostMaterial=Texture'AlleriaTerrain.ground.icebrg01'
     FrostMap=TexEnvMap'CubeMaps.Kretzig.Kretzig2TexENV'
     ImpactSounds(0)=Sound'PlayerSounds.BFootsteps.BFootstepSnow1'
     ImpactSounds(1)=Sound'PlayerSounds.BFootsteps.BFootstepSnow2'
     ImpactSounds(2)=Sound'PlayerSounds.BFootsteps.BFootstepSnow3'
     ImpactSounds(3)=Sound'PlayerSounds.BFootsteps.BFootstepSnow4'
     ImpactSounds(4)=Sound'PlayerSounds.BFootsteps.BFootstepSnow5'
     ImpactSounds(5)=Sound'PlayerSounds.BFootsteps.BFootstepSnow6'
     ShatteredDamageTypeClass=Class'3SPNv3225PIG.DamTypeShattered'
     FrozenGibGroupClass=Class'3SPNv3225PIG.xFrozenGibGroup'
}
