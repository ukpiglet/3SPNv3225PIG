class GibIceEffect extends xEmitter
	;

// #

state Ticking
{
	simulated function Tick( float dt )
	{
		if( LifeSpan < 1.0 )
		{
			mRegenRange[0] *= LifeSpan;
			mRegenRange[1] = mRegenRange[0];
		}
	}
}

simulated function timer()
{
	GotoState('Ticking');
}

simulated function PostNetBeginPlay()
{
	SetTimer(LifeSpan - 1.0,false);
}

// #

defaultproperties
{
     mRegen=False
     mStartParticles=10
     mMaxParticles=10
     mDelayRange(1)=0.150000
     mLifeRange(0)=1.000000
     mLifeRange(1)=2.000000
     mDirDev=(X=0.250000,Y=0.250000,Z=0.250000)
     mPosDev=(X=8.000000,Y=8.000000,Z=8.000000)
     mSpeedRange(0)=20.000000
     mSpeedRange(1)=80.000000
     mAirResistance=1.100000
     mRandOrient=True
     mSpinRange(0)=-100.000000
     mSpinRange(1)=100.000000
     mSizeRange(0)=20.000000
     mSizeRange(1)=30.000000
     mGrowthRate=10.000000
     mColorRange(0)=(R=127)
     mAttenKa=0.100000
     mRandTextures=True
     mNumTileColumns=4
     mNumTileRows=4
     bHighDetail=True
     Skins(0)=Texture'XEffects.EmitSmoke_t'
     Style=STY_Translucent
}
