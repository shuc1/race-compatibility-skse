Scriptname HemalurgicSpikeScript Extends ActiveMagicEffect  


GlobalVariable Property VampireStatusMessages Auto
GlobalVariable Property VampireRank Auto
GlobalVariable Property EnableVampireBloodPoints Auto
GlobalVariable Property VampireBloodPoints Auto
GlobalVariable Property VampireDynamicStages Auto

Race Property ArgonianRace  Auto  
Race Property ArgonianRaceVampire  Auto  
Race Property BretonRace  Auto  
Race Property BretonRaceVampire  Auto  
Race Property DarkElfRace  Auto  
Race Property DarkElfRaceVampire  Auto  
Race Property ElderRace  Auto  
Race Property ElderRaceVampire  Auto  
Race Property HighElfRace  Auto  
Race Property HighElfRaceVampire  Auto  
Race Property ImperialRace  Auto  
Race Property ImperialRaceVampire  Auto  
Race Property KhajiitRace  Auto  
Race Property KhajiitRaceVampire  Auto  
Race Property NordRace  Auto  
Race Property NordRaceVampire  Auto  
Race Property OrcRace  Auto  
Race Property OrcRaceVampire  Auto  
Race Property RedguardRace  Auto  
Race Property RedguardRaceVampire  Auto  
Race Property FoxRace Auto
Race Property WoodElfRace  Auto  
Race Property WoodElfRaceVampire  Auto
Race Property DLC1VampireBeastRace Auto
Race Property WerewolfBeastRace Auto
Race Property FalmerRace Auto
Race Property SnowElfRace Auto
Race Property DremoraRace Auto

Faction Property CreatureFaction Auto

Keyword Property Vampire Auto
Keyword Property ActorTypeDwarven Auto

Spell Property HemalurgicStagger Auto
Spell Property HemalurgicVampire Auto
Spell Property HemalurgicWerewolf Auto

Spell Property HemalurgicArgonian Auto
MagicEffect Property HemalurgicArgonianEffect Auto
Spell Property HemalurgicBreton Auto
MagicEffect Property HemalurgicBretonEffect Auto
Spell Property HemalurgicDarkElf Auto
MagicEffect Property HemalurgicDarkElfEffect Auto
Spell Property HemalurgicElder Auto
MagicEffect Property HemalurgicElderEffect Auto
Spell Property HemalurgicHighElf Auto
MagicEffect Property HemalurgicHighElfEffect Auto
Spell Property HemalurgicImperial Auto
MagicEffect Property HemalurgicImperialEffect Auto
Spell Property HemalurgicKhajiit Auto
MagicEffect Property HemalurgicKhajiitEffect Auto
Spell Property HemalurgicNordLight Auto
MagicEffect Property HemalurgicNordLightEffect Auto
Spell Property HemalurgicNordHeavy Auto
MagicEffect Property HemalurgicNordHeavyEffect Auto
Spell Property HemalurgicOrc Auto
MagicEffect Property HemalurgicOrcOneHandEffect Auto
MagicEffect Property HemalurgicOrcTwoHandEffect Auto
Spell Property HemalurgicRedguard Auto
MagicEffect Property HemalurgicRedguardEffect Auto
Spell Property HemalurgicFox Auto
MagicEffect Property HemalurgicFoxEffect Auto
Spell Property HemalurgicWoodElf Auto
MagicEffect Property HemalurgicWoodElfEffect Auto

Spell Property HemalurgicFalmer Auto
MagicEffect Property HemalurgicFalmerEffect Auto
Spell Property HemalurgicSnowElf Auto
MagicEffect Property HemalurgicSnowElfEffect Auto
Spell Property HemalurgicDremora Auto
MagicEffect Property HemalurgicDremoraEffect Auto

;==================================================================================


Event OnEffectStart(Actor akTarget, Actor akCaster)

	Int ChanceToAbsorb = Utility.RandomInt()

	If VampireRank.GetValue() == 40000
		ChanceToAbsorb = (ChanceToAbsorb + 30) ;45% Chance of Success
	ElseIf VampireRank.GetValue() == 50000
		ChanceToAbsorb = (ChanceToAbsorb + 50) ;65% Chance of Success
	ElseIf VampireRank.GetValue() >= 60000
		ChanceToAbsorb = (ChanceToAbsorb + 70) ;85% Chance of Success
	EndIf

	;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	; Chance To Absorb Skills or Abilities
	;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	If ChanceToAbsorb >=85
		; RCS
		Race akTargetRace = akTarget.GetRace()
		If RaceCompatibility.GetIsRaceByProxy(ArgonianRace, akTargetRace) && akTarget.GetAV("Variable03") != 666
			akCaster.DispelSpell(HemalurgicArgonian)
			akCaster.DispelSpell(HemalurgicBreton)
			akCaster.DispelSpell(HemalurgicDarkElf)
			akCaster.DispelSpell(HemalurgicElder)
			akCaster.DispelSpell(HemalurgicHighElf)
			akCaster.DispelSpell(HemalurgicImperial)
			akCaster.DispelSpell(HemalurgicKhajiit)
			akCaster.DispelSpell(HemalurgicNordLight)
			akCaster.DispelSpell(HemalurgicNordHeavy)
			akCaster.DispelSpell(HemalurgicOrc)
			akCaster.DispelSpell(HemalurgicRedguard)
			akCaster.DispelSpell(HemalurgicFox)
			akCaster.DispelSpell(HemalurgicWoodElf)
			akCaster.DispelSpell(HemalurgicFalmer)
			akCaster.DispelSpell(HemalurgicSnowElf)
			akCaster.DispelSpell(HemalurgicDremora)
			;-----------------------------
			akTarget.ModAV("HealRate", -20)
			akTarget.SetAV("Variable03", 666)
			If VampireStatusMessages.GetValue() == 0
				Debug.Notification("My victim's Heal Rate bonus has been absorbed.")
			EndIf
			HemalurgicStagger.Cast(akTarget,akTarget)
			HemalurgicArgonian.Cast(akCaster,akCaster)
			;-----------------------------
		ElseIf RaceCompatibility.GetIsRaceByProxy(BretonRace, akTargetRace) && akTarget.GetAV("Variable03") != 666
			akCaster.DispelSpell(HemalurgicArgonian)
			akCaster.DispelSpell(HemalurgicBreton)
			akCaster.DispelSpell(HemalurgicDarkElf)
			akCaster.DispelSpell(HemalurgicElder)
			akCaster.DispelSpell(HemalurgicHighElf)
			akCaster.DispelSpell(HemalurgicImperial)
			akCaster.DispelSpell(HemalurgicKhajiit)
			akCaster.DispelSpell(HemalurgicNordLight)
			akCaster.DispelSpell(HemalurgicNordHeavy)
			akCaster.DispelSpell(HemalurgicOrc)
			akCaster.DispelSpell(HemalurgicRedguard)
			akCaster.DispelSpell(HemalurgicFox)
			akCaster.DispelSpell(HemalurgicWoodElf)
			akCaster.DispelSpell(HemalurgicFalmer)
			akCaster.DispelSpell(HemalurgicSnowElf)
			akCaster.DispelSpell(HemalurgicDremora)
			;-----------------------------
			akTarget.ModAV("MagicResist", -25)
			akTarget.SetAV("Variable03", 666)
			If VampireStatusMessages.GetValue() == 0
				Debug.Notification("My victim's Magic Resistance bonus has been absorbed.")
			EndIf
			HemalurgicStagger.Cast(akTarget,akTarget)
			HemalurgicBreton.Cast(akCaster,akCaster)
			;-----------------------------
		ElseIf RaceCompatibility.GetIsRaceByProxy(DarkElfRace, akTargetRace) && akTarget.GetAV("Variable03") != 666
			akCaster.DispelSpell(HemalurgicArgonian)
			akCaster.DispelSpell(HemalurgicBreton)
			akCaster.DispelSpell(HemalurgicDarkElf)
			akCaster.DispelSpell(HemalurgicElder)
			akCaster.DispelSpell(HemalurgicHighElf)
			akCaster.DispelSpell(HemalurgicImperial)
			akCaster.DispelSpell(HemalurgicKhajiit)
			akCaster.DispelSpell(HemalurgicNordLight)
			akCaster.DispelSpell(HemalurgicNordHeavy)
			akCaster.DispelSpell(HemalurgicOrc)
			akCaster.DispelSpell(HemalurgicRedguard)
			akCaster.DispelSpell(HemalurgicFox)
			akCaster.DispelSpell(HemalurgicWoodElf)
			akCaster.DispelSpell(HemalurgicFalmer)
			akCaster.DispelSpell(HemalurgicSnowElf)
			akCaster.DispelSpell(HemalurgicDremora)
			;-----------------------------
			akTarget.ModAV("FireResist", -25)
			akTarget.SetAV("Variable03", 666)
			If VampireStatusMessages.GetValue() == 0
				Debug.Notification("My victim's Fire Resistance bonus has been absorbed.")
			EndIf
			HemalurgicStagger.Cast(akTarget,akTarget)
			HemalurgicDarkElf.Cast(akCaster,akCaster)
			;-----------------------------
		ElseIf RaceCompatibility.GetIsRaceByProxy(ElderRace, akTargetRace) && akTarget.GetAV("Variable03") != 666
			akCaster.DispelSpell(HemalurgicArgonian)
			akCaster.DispelSpell(HemalurgicBreton)
			akCaster.DispelSpell(HemalurgicDarkElf)
			akCaster.DispelSpell(HemalurgicElder)
			akCaster.DispelSpell(HemalurgicHighElf)
			akCaster.DispelSpell(HemalurgicImperial)
			akCaster.DispelSpell(HemalurgicKhajiit)
			akCaster.DispelSpell(HemalurgicNordLight)
			akCaster.DispelSpell(HemalurgicNordHeavy)
			akCaster.DispelSpell(HemalurgicOrc)
			akCaster.DispelSpell(HemalurgicRedguard)
			akCaster.DispelSpell(HemalurgicFox)
			akCaster.DispelSpell(HemalurgicWoodElf)
			akCaster.DispelSpell(HemalurgicFalmer)
			akCaster.DispelSpell(HemalurgicSnowElf)
			akCaster.DispelSpell(HemalurgicDremora)
			;-----------------------------
			akTarget.ModAV("Speechcraft", -20)
			akTarget.SetAV("Variable03", 666)
			If VampireStatusMessages.GetValue() == 0
				Debug.Notification("My victim's Persuasion skill has been absorbed.")
			EndIf
			HemalurgicStagger.Cast(akTarget,akTarget)
			HemalurgicElder.Cast(akCaster,akCaster)
			;-----------------------------
		ElseIf RaceCompatibility.GetIsRaceByProxy(HighElfRace, akTargetRace) && akTarget.GetAV("Variable03") != 666
			akCaster.DispelSpell(HemalurgicArgonian)
			akCaster.DispelSpell(HemalurgicBreton)
			akCaster.DispelSpell(HemalurgicDarkElf)
			akCaster.DispelSpell(HemalurgicElder)
			akCaster.DispelSpell(HemalurgicHighElf)
			akCaster.DispelSpell(HemalurgicImperial)
			akCaster.DispelSpell(HemalurgicKhajiit)
			akCaster.DispelSpell(HemalurgicNordLight)
			akCaster.DispelSpell(HemalurgicNordHeavy)
			akCaster.DispelSpell(HemalurgicOrc)
			akCaster.DispelSpell(HemalurgicRedguard)
			akCaster.DispelSpell(HemalurgicFox)
			akCaster.DispelSpell(HemalurgicWoodElf)
			akCaster.DispelSpell(HemalurgicFalmer)
			akCaster.DispelSpell(HemalurgicSnowElf)
			akCaster.DispelSpell(HemalurgicDremora)
			;-----------------------------
			akTarget.ModAV("Magicka", -50)
			akTarget.ModAV("MagickaRate", -15)
			akTarget.SetAV("Variable03", 666)
			If VampireStatusMessages.GetValue() == 0
				Debug.Notification("My victim's Magicka bonuses have been absorbed.")
			EndIf
			HemalurgicStagger.Cast(akTarget,akTarget)
			HemalurgicHighElf.Cast(akCaster,akCaster)
			;-----------------------------
		ElseIf RaceCompatibility.GetIsRaceByProxy(ImperialRace, akTargetRace) && akTarget.GetAV("Variable03") != 666
			akCaster.DispelSpell(HemalurgicArgonian)
			akCaster.DispelSpell(HemalurgicBreton)
			akCaster.DispelSpell(HemalurgicDarkElf)
			akCaster.DispelSpell(HemalurgicElder)
			akCaster.DispelSpell(HemalurgicHighElf)
			akCaster.DispelSpell(HemalurgicImperial)
			akCaster.DispelSpell(HemalurgicKhajiit)
			akCaster.DispelSpell(HemalurgicNordLight)
			akCaster.DispelSpell(HemalurgicNordHeavy)
			akCaster.DispelSpell(HemalurgicOrc)
			akCaster.DispelSpell(HemalurgicRedguard)
			akCaster.DispelSpell(HemalurgicFox)
			akCaster.DispelSpell(HemalurgicWoodElf)
			akCaster.DispelSpell(HemalurgicFalmer)
			akCaster.DispelSpell(HemalurgicSnowElf)
			akCaster.DispelSpell(HemalurgicDremora)
			;-----------------------------
			akTarget.ModAV("CritChance", -25)
			akTarget.SetAV("Variable03", 666)
			If VampireStatusMessages.GetValue() == 0
				Debug.Notification("My victim's Critical Hit Chance bonus has been absorbed.")
			EndIf
			HemalurgicStagger.Cast(akTarget,akTarget)
			HemalurgicImperial.Cast(akCaster,akCaster)
			;-----------------------------
		ElseIf RaceCompatibility.GetIsRaceByProxy(KhajiitRace, akTargetRace) && akTarget.GetAV("Variable03") != 666
			akCaster.DispelSpell(HemalurgicArgonian)
			akCaster.DispelSpell(HemalurgicBreton)
			akCaster.DispelSpell(HemalurgicDarkElf)
			akCaster.DispelSpell(HemalurgicElder)
			akCaster.DispelSpell(HemalurgicHighElf)
			akCaster.DispelSpell(HemalurgicImperial)
			akCaster.DispelSpell(HemalurgicKhajiit)
			akCaster.DispelSpell(HemalurgicNordLight)
			akCaster.DispelSpell(HemalurgicNordHeavy)
			akCaster.DispelSpell(HemalurgicOrc)
			akCaster.DispelSpell(HemalurgicRedguard)
			akCaster.DispelSpell(HemalurgicFox)
			akCaster.DispelSpell(HemalurgicWoodElf)
			akCaster.DispelSpell(HemalurgicFalmer)
			akCaster.DispelSpell(HemalurgicSnowElf)
			akCaster.DispelSpell(HemalurgicDremora)
			;-----------------------------
			akTarget.ModAV("Sneak", -15)
			akTarget.ModAV("Lockpicking", -15)
			akTarget.SetAV("Variable03", 666)
			If VampireStatusMessages.GetValue() == 0
				Debug.Notification("My victim's Sneaking and Lockpicking skills have been absorbed.")
			EndIf
			HemalurgicStagger.Cast(akTarget,akTarget)
			HemalurgicKhajiit.Cast(akCaster,akCaster)
			;-----------------------------
		ElseIf RaceCompatibility.GetIsRaceByProxy(NordRace, akTargetRace) && akTarget.GetAV("Variable03") != 666
			akCaster.DispelSpell(HemalurgicArgonian)
			akCaster.DispelSpell(HemalurgicBreton)
			akCaster.DispelSpell(HemalurgicDarkElf)
			akCaster.DispelSpell(HemalurgicElder)
			akCaster.DispelSpell(HemalurgicHighElf)
			akCaster.DispelSpell(HemalurgicImperial)
			akCaster.DispelSpell(HemalurgicKhajiit)
			akCaster.DispelSpell(HemalurgicNordLight)
			akCaster.DispelSpell(HemalurgicNordHeavy)
			akCaster.DispelSpell(HemalurgicOrc)
			akCaster.DispelSpell(HemalurgicRedguard)
			akCaster.DispelSpell(HemalurgicFox)
			akCaster.DispelSpell(HemalurgicWoodElf)
			akCaster.DispelSpell(HemalurgicFalmer)
			akCaster.DispelSpell(HemalurgicSnowElf)
			akCaster.DispelSpell(HemalurgicDremora)
			;-----------------------------
			akTarget.ModAV("HeavyArmor", -20)
			akTarget.ModAV("LightArmor", -20)
			akTarget.SetAV("Variable03", 666)
			If VampireStatusMessages.GetValue() == 0
				If akTarget.GetAV("LightArmor") > akTarget.GetAV("HeavyArmor")
					Debug.Notification("My victim's Light Armor skill has been absorbed.")
				ElseIf akTarget.GetAV("HeavyArmor") > akTarget.GetAV("LightArmor")
					Debug.Notification("My victim's Heavy Armor skill has been absorbed.")
				ElseIf akTarget.GetAV("HeavyArmor") == akTarget.GetAV("LightArmor")
					Debug.Notification("My victim's Armor skill has been absorbed.")
				EndIf
			EndIf
			HemalurgicStagger.Cast(akTarget,akTarget)
			If akTarget.GetAV("LightArmor") > akTarget.GetAV("HeavyArmor")
				HemalurgicNordLight.Cast(akCaster,akCaster)
			ElseIf akTarget.GetAV("HeavyArmor") > akTarget.GetAV("LightArmor")
				HemalurgicNordHeavy.Cast(akCaster,akCaster)
			ElseIf akTarget.GetAV("HeavyArmor") == akTarget.GetAV("LightArmor")
				int ArmorRandom = Utility.RandomInt()
				If ArmorRandom < 50
					HemalurgicNordLight.Cast(akCaster,akCaster)
				ElseIf ArmorRandom < 50
					HemalurgicNordHeavy.Cast(akCaster,akCaster)
				EndIf
			EndIf
			;-----------------------------
		ElseIf RaceCompatibility.GetIsRaceByProxy(OrcRace, akTargetRace) && akTarget.GetAV("Variable03") != 666
			akCaster.DispelSpell(HemalurgicArgonian)
			akCaster.DispelSpell(HemalurgicBreton)
			akCaster.DispelSpell(HemalurgicDarkElf)
			akCaster.DispelSpell(HemalurgicElder)
			akCaster.DispelSpell(HemalurgicHighElf)
			akCaster.DispelSpell(HemalurgicImperial)
			akCaster.DispelSpell(HemalurgicKhajiit)
			akCaster.DispelSpell(HemalurgicNordLight)
			akCaster.DispelSpell(HemalurgicNordHeavy)
			akCaster.DispelSpell(HemalurgicOrc)
			akCaster.DispelSpell(HemalurgicRedguard)
			akCaster.DispelSpell(HemalurgicFox)
			akCaster.DispelSpell(HemalurgicWoodElf)
			akCaster.DispelSpell(HemalurgicFalmer)
			akCaster.DispelSpell(HemalurgicSnowElf)
			akCaster.DispelSpell(HemalurgicDremora)
			;-----------------------------
			akTarget.ModAV("OneHanded", -15)
			akTarget.ModAV("TwoHanded", -15)
			akTarget.SetAV("Variable03", 666)
			If VampireStatusMessages.GetValue() == 0
				Debug.Notification("My victim's One and Two-handed skills have been absorbed.")
			EndIf
			HemalurgicStagger.Cast(akTarget,akTarget)
			HemalurgicOrc.Cast(akCaster,akCaster)
			;-----------------------------
		ElseIf akTarget.GetRace() == RedguardRace  && akTarget.GetAV("Variable03") != 666
			akCaster.DispelSpell(HemalurgicArgonian)
			akCaster.DispelSpell(HemalurgicBreton)
			akCaster.DispelSpell(HemalurgicDarkElf)
			akCaster.DispelSpell(HemalurgicElder)
			akCaster.DispelSpell(HemalurgicHighElf)
			akCaster.DispelSpell(HemalurgicImperial)
			akCaster.DispelSpell(HemalurgicKhajiit)
			akCaster.DispelSpell(HemalurgicNordLight)
			akCaster.DispelSpell(HemalurgicNordHeavy)
			akCaster.DispelSpell(HemalurgicOrc)
			akCaster.DispelSpell(HemalurgicRedguard)
			akCaster.DispelSpell(HemalurgicFox)
			akCaster.DispelSpell(HemalurgicWoodElf)
			akCaster.DispelSpell(HemalurgicFalmer)
			akCaster.DispelSpell(HemalurgicSnowElf)
			akCaster.DispelSpell(HemalurgicDremora)
			;-----------------------------
			akTarget.ModAV("StaminaRate", -20)
			akTarget.SetAV("Variable03", 666)
			If VampireStatusMessages.GetValue() == 0
				Debug.Notification("My victim's Stamina Rate bonus has been absorbed.")
			EndIf
			HemalurgicStagger.Cast(akTarget,akTarget)
			HemalurgicRedguard.Cast(akCaster,akCaster)
			;-----------------------------
		ElseIf akTargetRace == FoxRace && akTarget.IsInFaction(CreatureFaction) == False  && akTarget.GetAV("Variable03") != 666
			akCaster.DispelSpell(HemalurgicArgonian)
			akCaster.DispelSpell(HemalurgicBreton)
			akCaster.DispelSpell(HemalurgicDarkElf)
			akCaster.DispelSpell(HemalurgicElder)
			akCaster.DispelSpell(HemalurgicHighElf)
			akCaster.DispelSpell(HemalurgicImperial)
			akCaster.DispelSpell(HemalurgicKhajiit)
			akCaster.DispelSpell(HemalurgicNordLight)
			akCaster.DispelSpell(HemalurgicNordHeavy)
			akCaster.DispelSpell(HemalurgicOrc)
			akCaster.DispelSpell(HemalurgicRedguard)
			akCaster.DispelSpell(HemalurgicFox)
			akCaster.DispelSpell(HemalurgicWoodElf)
			akCaster.DispelSpell(HemalurgicFalmer)
			akCaster.DispelSpell(HemalurgicSnowElf)
			akCaster.DispelSpell(HemalurgicDremora)
			;-----------------------------
			akTarget.ModAV("Block", 20)
			akTarget.SetAV("Variable03", 666)
			If VampireStatusMessages.GetValue() == 0
				Debug.Notification("My victim's Blocking skill has been absorbed.")
			EndIf
			HemalurgicStagger.Cast(akTarget,akTarget)
			HemalurgicFox.Cast(akCaster,akCaster)
			;-----------------------------
		ElseIf RaceCompatibility.GetIsRaceByProxy(WoodElfRace, akTargetRace) && akTarget.GetAV("Variable03") != 666
			akCaster.DispelSpell(HemalurgicArgonian)
			akCaster.DispelSpell(HemalurgicBreton)
			akCaster.DispelSpell(HemalurgicDarkElf)
			akCaster.DispelSpell(HemalurgicElder)
			akCaster.DispelSpell(HemalurgicHighElf)
			akCaster.DispelSpell(HemalurgicImperial)
			akCaster.DispelSpell(HemalurgicKhajiit)
			akCaster.DispelSpell(HemalurgicNordLight)
			akCaster.DispelSpell(HemalurgicNordHeavy)
			akCaster.DispelSpell(HemalurgicOrc)
			akCaster.DispelSpell(HemalurgicRedguard)
			akCaster.DispelSpell(HemalurgicFox)
			akCaster.DispelSpell(HemalurgicWoodElf)
			akCaster.DispelSpell(HemalurgicFalmer)
			akCaster.DispelSpell(HemalurgicSnowElf)
			akCaster.DispelSpell(HemalurgicDremora)
			;-----------------------------
			akTarget.ModAV("Marksman", -20)
			akTarget.SetAV("Variable03", 666)
			If VampireStatusMessages.GetValue() == 0
				Debug.Notification("My victim's Marksman skill has been absorbed.")
			EndIf
			HemalurgicStagger.Cast(akTarget,akTarget)
			HemalurgicWoodElf.Cast(akCaster,akCaster)
			;-----------------------------
		ElseIf akTargetRace == FalmerRace && akTarget.GetAV("Variable03") != 666
			akCaster.DispelSpell(HemalurgicArgonian)
			akCaster.DispelSpell(HemalurgicBreton)
			akCaster.DispelSpell(HemalurgicDarkElf)
			akCaster.DispelSpell(HemalurgicElder)
			akCaster.DispelSpell(HemalurgicHighElf)
			akCaster.DispelSpell(HemalurgicImperial)
			akCaster.DispelSpell(HemalurgicKhajiit)
			akCaster.DispelSpell(HemalurgicNordLight)
			akCaster.DispelSpell(HemalurgicNordHeavy)
			akCaster.DispelSpell(HemalurgicOrc)
			akCaster.DispelSpell(HemalurgicRedguard)
			akCaster.DispelSpell(HemalurgicFox)
			akCaster.DispelSpell(HemalurgicWoodElf)
			akCaster.DispelSpell(HemalurgicFalmer)
			akCaster.DispelSpell(HemalurgicSnowElf)
			akCaster.DispelSpell(HemalurgicDremora)
			;-----------------------------
			akTarget.ModAV("Sneak", -30)
			akTarget.SetAV("Variable03", 666)
			If VampireStatusMessages.GetValue() == 0
				Debug.Notification("My victim's Sneaking skill has been absorbed.")
			EndIf
			HemalurgicStagger.Cast(akTarget,akTarget)
			HemalurgicFalmer.Cast(akCaster,akCaster)
			;-----------------------------
		ElseIf akTargetRace == SnowElfRace && akTarget.GetAV("Variable03") != 666
			akCaster.DispelSpell(HemalurgicArgonian)
			akCaster.DispelSpell(HemalurgicBreton)
			akCaster.DispelSpell(HemalurgicDarkElf)
			akCaster.DispelSpell(HemalurgicElder)
			akCaster.DispelSpell(HemalurgicHighElf)
			akCaster.DispelSpell(HemalurgicImperial)
			akCaster.DispelSpell(HemalurgicKhajiit)
			akCaster.DispelSpell(HemalurgicNordLight)
			akCaster.DispelSpell(HemalurgicNordHeavy)
			akCaster.DispelSpell(HemalurgicOrc)
			akCaster.DispelSpell(HemalurgicRedguard)
			akCaster.DispelSpell(HemalurgicFox)
			akCaster.DispelSpell(HemalurgicWoodElf)
			akCaster.DispelSpell(HemalurgicFalmer)
			akCaster.DispelSpell(HemalurgicSnowElf)
			akCaster.DispelSpell(HemalurgicDremora)
			;-----------------------------
			akTarget.ModAV("FrostResist", -25)
			akTarget.SetAV("Variable03", 666)
			If VampireStatusMessages.GetValue() == 0
				Debug.Notification("My victim's Frost Resistance bonus has been absorbed.")
			EndIf
			HemalurgicStagger.Cast(akTarget,akTarget)
			HemalurgicSnowElf.Cast(akCaster,akCaster)
			;-----------------------------
		ElseIf akTargetRace == DremoraRace && akTarget.GetAV("Variable03") != 666
			akCaster.DispelSpell(HemalurgicArgonian)
			akCaster.DispelSpell(HemalurgicBreton)
			akCaster.DispelSpell(HemalurgicDarkElf)
			akCaster.DispelSpell(HemalurgicElder)
			akCaster.DispelSpell(HemalurgicHighElf)
			akCaster.DispelSpell(HemalurgicImperial)
			akCaster.DispelSpell(HemalurgicKhajiit)
			akCaster.DispelSpell(HemalurgicNordLight)
			akCaster.DispelSpell(HemalurgicNordHeavy)
			akCaster.DispelSpell(HemalurgicOrc)
			akCaster.DispelSpell(HemalurgicRedguard)
			akCaster.DispelSpell(HemalurgicFox)
			akCaster.DispelSpell(HemalurgicWoodElf)
			akCaster.DispelSpell(HemalurgicFalmer)
			akCaster.DispelSpell(HemalurgicSnowElf)
			akCaster.DispelSpell(HemalurgicDremora)
			;-----------------------------
			akTarget.ModAV("Destruction", -20)
			akTarget.SetAV("Variable03", 666)
			If VampireStatusMessages.GetValue() == 0
				Debug.Notification("My victim's Destruction skill has been absorbed.")
			EndIf
			HemalurgicStagger.Cast(akTarget,akTarget)
			HemalurgicDremora.Cast(akCaster,akCaster)
			;-----------------------------
		EndIf

		If (akTarget.GetRace() == ArgonianRaceVampire || akTarget.GetRace() == BretonRaceVampire || akTarget.GetRace() == DarkElfRaceVampire || akTarget.GetRace() == ElderRaceVampire || akTarget.GetRace() == HighElfRaceVampire || akTarget.GetRace() == ImperialRaceVampire || akTarget.GetRace() == KhajiitRaceVampire || akTarget.GetRace() == NordRaceVampire || akTarget.GetRace() == OrcRaceVampire || akTarget.GetRace() == RedguardRaceVampire || akTarget.GetRace() == DLC1VampireBeastRace || akTarget.HasKeyword(Vampire))
			If akTarget.GetAV("Variable03") != 666
				akTarget.SetAV("Variable03", 666)
				If akTarget.GetAV("Magicka") > 200
					Int MagickaToDamage = (akTarget.GetAV("Magicka") - 200) as Int
					akTarget.DamageAV("Magicka", MagickaToDamage)
				EndIf
				HemalurgicStagger.Cast(akTarget,akTarget)
				HemalurgicVampire.Cast(akTarget,akTarget)
				akTarget.RestoreAV("Health", 20)
				If VampireStatusMessages.GetValue() == 0
					Debug.Notification("My victim's magicka regen is compromised.")
				EndIf
			EndIf
		EndIf

		If akTarget.GetRace() == WerewolfBeastRace
			If akTarget.GetAV("Variable03") != 666
				akTarget.SetAV("Variable03", 666)
				If akTarget.GetAV("Stamina") > 200
					Int StaminaToDamage = (akTarget.GetAV("Stamina") - 200) as Int
					akTarget.DamageAV("Stamina", StaminaToDamage)
				EndIf
				HemalurgicStagger.Cast(akTarget,akTarget)
				HemalurgicWerewolf.Cast(akTarget,akTarget)
				If VampireStatusMessages.GetValue() == 0
					Debug.Notification("My victim's health regen and speed are compromised.")
				EndIf
			EndIf
		EndIf

	EndIf


	;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	; Replenish Blood Points
	;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	If akTarget.HasKeyword(ActorTypeDwarven) == False

		If VampireRank.GetValue() == 40000 ; Vampire Nightstalker

			If EnableVampireBloodPoints.GetValue() <= 10000
				If VampireDynamicStages.GetValue() == 20000
					VampireBloodPoints.SetValue(VampireBloodPoints.GetValue()+10)
					If VampireBloodPoints.GetValue() > 100
						VampireBloodPoints.SetValue(100)
					EndIf
				ElseIf VampireDynamicStages.GetValue() < 20000
					VampireBloodPoints.SetValue(VampireBloodPoints.GetValue()+10)
					If VampireBloodPoints.GetValue() > 300
						VampireBloodPoints.SetValue(300)
					EndIf
				EndIf
			EndIf

		ElseIf VampireRank.GetValue() == 50000 ; Master Vampire 

			If EnableVampireBloodPoints.GetValue() <= 10000
				If VampireDynamicStages.GetValue() == 20000
					VampireBloodPoints.SetValue(VampireBloodPoints.GetValue()+15)
					If VampireBloodPoints.GetValue() > 100
						VampireBloodPoints.SetValue(100)
					EndIf
				ElseIf VampireDynamicStages.GetValue() < 20000
					VampireBloodPoints.SetValue(VampireBloodPoints.GetValue()+15)
					If VampireBloodPoints.GetValue() > 300
						VampireBloodPoints.SetValue(300)
					EndIf
				EndIf
			EndIf

		ElseIf VampireRank.GetValue() >= 60000 ; Vampire Nightlord

			If EnableVampireBloodPoints.GetValue() <= 10000
				If VampireDynamicStages.GetValue() == 20000
					VampireBloodPoints.SetValue(VampireBloodPoints.GetValue()+20)
					If VampireBloodPoints.GetValue() > 100
						VampireBloodPoints.SetValue(100)
					EndIf
				ElseIf VampireDynamicStages.GetValue() < 20000
					VampireBloodPoints.SetValue(VampireBloodPoints.GetValue()+20)
					If VampireBloodPoints.GetValue() > 300
						VampireBloodPoints.SetValue(300)
					EndIf
				EndIf
			EndIf

		EndIf

	EndIf

	;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	; Restore Some Health
	;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	If akTarget.HasKeyword(ActorTypeDwarven) == False

		If VampireRank.GetValue() == 40000 ; Vampire Nightstalker
			akCaster.RestoreAV("Health", 10)
		ElseIf VampireRank.GetValue() == 50000 ; Master Vampire 
			akCaster.RestoreAV("Health", 15)
		ElseIf VampireRank.GetValue() >= 60000 ; Vampire Nightlord
			akCaster.RestoreAV("Health", 20)
		EndIf

	EndIf


EndEvent

;==================================================================================

Event OnEffectFinish(Actor akTarget, Actor akCaster)



EndEvent