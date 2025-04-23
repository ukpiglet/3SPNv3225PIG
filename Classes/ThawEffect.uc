class ThawEffect extends Actor;

simulated event PostBeginPlay()
{
    Super.PostBeginPlay();

    if (Level.NetMode != NM_DedicatedServer)
        Spawn(class'LavaDeath', , , Location, Rotation);
}

defaultproperties
{
     DrawType=DT_None
     bNetTemporary=True
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=2.000000
}
