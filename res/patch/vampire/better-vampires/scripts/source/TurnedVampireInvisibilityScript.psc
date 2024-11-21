Scriptname TurnedVampireInvisibilityScript extends activemagiceffect

GlobalVariable Property SEVersion Auto
Race Property ArgonianRace Auto
Race Property KhajiitRace Auto

TextureSet Property BVEyesMaleHumanVampire auto
TextureSet Property BVSkinEyesKhajiitVampire auto
TextureSet Property BVSkinEyesMaleArgonianVampire auto							


EVENT OnEffectStart(Actor akTarget, Actor akCaster)



EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	
	If SEVersion.GetValue() == 0

		If SKSE.GetVersionRelease() > 0
	
			If akTarget.IsOnMount()
			Else
				Float Weight = akTarget.GetWeight()
				akTarget.SetWeight(50)		
				akTarget.SetWeight(Weight)
				akTarget.QueueNiNodeUpdate()
			EndIf	
		
		EndIf
		
	EndIf

	;RCS
	Race TargetRace = akTarget.GetActorBase().GetRace()
	Int HeadPartFlag = RaceCompatibility.GetHeadPartFlagByRace(TargetRace)
	; If (akTarget.GetActorBase().GetRace() == ArgonianRace)
	; 'A': 65
	If (TargetRace == ArgonianRace) || (RaceCompatibility.GetIsRaceByProxy(TargetRace, ArgonianRace) && HeadPartFlag == 65) 
		akTarget.SetEyeTexture(BVSkinEyesMaleArgonianVampire)
	; ElseIf (akTarget.GetActorBase().GetRace() == KhajiitRace)
	; 'K': 75
	ElseIf (TargetRace == KhajiitRace) || (RaceCompatibility.GetIsRaceByProxy(TargetRace, KhajiitRace) && HeadPartFlag == 75) 
		akTarget.SetEyeTexture(BVSkinEyesKhajiitVampire)
	Else	
		akTarget.SetEyeTexture(BVEyesMaleHumanVampire)
	EndIf
		
EndEvent
