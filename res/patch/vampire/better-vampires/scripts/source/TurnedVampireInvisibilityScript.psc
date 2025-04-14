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

	; If (akTarget.GetActorBase().GetRace() == ArgonianRace)
	; 	akTarget.SetEyeTexture(BVSkinEyesMaleArgonianVampire)
	; ElseIf (akTarget.GetActorBase().GetRace() == KhajiitRace)
	; 	akTarget.SetEyeTexture(BVSkinEyesKhajiitVampire)
	; Else
	; 	akTarget.SetEyeTexture(BVEyesMaleHumanVampire)
	; EndIf
	; RCS
	; head part type: Argonian-1 Khajiit-11
	Race akTargetRace = akTarget.GetActorBase().GetRace()
	Int RcsHeadPartType = RaceCompatibility.GetHeadPartTypeByRace(akTargetRace)
	If akTargetRace == ArgonianRace ||  RcsHeadPartType == 1
		akTarget.SetEyeTexture(BVSkinEyesMaleArgonianVampire)
	ElseIf akTargetRace == KhajiitRace || RcsHeadPartType == 11
		akTarget.SetEyeTexture(BVSkinEyesKhajiitVampire)
	Else
		akTarget.SetEyeTexture(BVEyesMaleHumanVampire)
	EndIf


EndEvent
