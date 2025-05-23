class BioEffect extends xEmitter
	;

///*

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

//*/

DefaultProperties
{
	bHighDetail=true
    Skins(0)=Texture'EmitSmoke_t'
    mNumTileColumns=4
    mNumTileRows=4
    Style=STY_Translucent
    mParticleType=PCL_Burst
    mDirDev=(X=0.25,Y=0.25,Z=0.25)
    mPosDev=(X=8.0,Y=8.0,Z=8.0)
    mDelayRange(0)=0.0
    mDelayRange(1)=0.15
    mLifeRange(0)=1.0
    mLifeRange(1)=2.0
    mSpeedRange(0)=20.0
    mSpeedRange(1)=80.0
    mSizeRange(0)=20.0
    mSizeRange(1)=30.0
    mGrowthRate=10.0
    mRegen=false
    mRandOrient=true
    mRandTextures=true
    mAttenuate=true
    mAttenKa=0.1
    mStartParticles=10
    mMaxParticles=10
    mAirResistance=1.1
    mColorRange(0)=(R=255,G=50,B=0,A=255)
    mColorRange(1)=(R=255,G=153,B=0,A=255)
    mSpinRange(0)=-100.0
    mSpinRange(1)=100.0
    RemoteRole=ROLE_None
}