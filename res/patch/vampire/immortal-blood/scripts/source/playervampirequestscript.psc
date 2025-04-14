ScriptName PlayerVampireQuestScript extends Quest Conditional

;Variable to track if the player is a vampire
;0 = Not a Vampire
;1 = Vampire
;2 = Vampire Stage 2
;3 = Vampire Stage 3
;4 = Vampire Stage 4
Int Property VampireStatus Auto Conditional

Message Property VampireFeedMessage Auto
Message Property VampireStageProgressionMessage Auto
Message Property VampireFeedReverseProgressionMessage Auto
Message Property VampireStageReverseProgressionMessage Auto
Race Property ArgonianRace  Auto  
Race Property ArgonianRaceVampire  Auto  
Race Property BretonRace  Auto  
Race Property BretonRaceVampire  Auto  
Race Property DarkElfRace  Auto  
Race Property DarkElfRaceVampire  Auto  
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
Race Property WoodElfRace  Auto  
Race Property WoodElfRaceVampire  Auto  
Race Property CureRace Auto
Static Property XMarker Auto

Faction Property VampirePCFaction  Auto  

Float Property LastFeedTime Auto
Float Property FeedTimer Auto
GlobalVariable Property GameDaysPassed Auto
GlobalVariable Property VampireShunnedGlobal Auto
GlobalVariable Property VampireReverseProgressionGlobal Auto

Idle Property VampireFeedingBedRight Auto
Idle Property VampireFeedingBedrollRight Auto
GlobalVariable Property VampireFeedReady Auto
imageSpaceModifier Property VampireTransformIncreaseISMD  Auto
imageSpaceModifier Property VampireTransformDecreaseISMD  Auto 
effectShader property VampireChangeFX auto

Event OnUpdateGameTime()

	;Feed timer
	FeedTimer = GameDaysPassed.Value - LastFeedTime
; 	debug.trace(self + "Feed Timer is:" + FeedTimer + "days")
	
	
	;Vampire progression should not happen if player is in combat or controls are locked or the player can't fast travel 
	; DLC01 - also skip progression if player is currently vampire lord
	actor player = Game.GetPlayer()
	If  Game.IsMovementControlsEnabled() && Game.IsFightingControlsEnabled() && player.GetCombatState() == 0 && player.HasMagicEffect(DLC1VampireChangeEffect) == false && player.HasMagicEffect(DLC1VampireChangeFXEffect) == false
		;If player hasn't fed, progress Vampirism
		If (FeedTimer >= 3) && (VampireStatus == 3) && VampireReverseProgressionGlobal.Value == 0
			;add Stage 4 Vampire buffs and spells
			VampireFeedReady.SetValue(3)
			VampireStageProgressionMessage.Show()
			VampireStatus = 4
			VampireProgression(Game.GetPlayer(), 4)

			;All NPCs  hate the evil Vampire
			If VampireShunnedGlobal.Value == 1
				Game.GetPlayer().AddtoFaction(VampirePCFaction)
				Game.GetPlayer().SetAttackActorOnSight()
				VampireStage4Message.Show()
				int cfIndex = 0
; 				Debug.Trace("VAMPIRE update: DLC1CrimeFactions = " + DLC1CrimeFactions)
; 				Debug.Trace("VAMPIRE update: CrimeFactions before = " + CrimeFactions)
				CrimeFactions = DLC1CrimeFactions
; 				Debug.Trace("VAMPIRE update: CrimeFactions after = " + CrimeFactions)
   				while (cfIndex < CrimeFactions.GetSize())
;          				Debug.Trace("VAMPIRE update: Setting enemy flag on " + CrimeFactions.GetAt(cfIndex))
        				(CrimeFactions.GetAt(cfIndex) as Faction).SetPlayerEnemy()
        				cfIndex += 1
    				endwhile
			EndIf
			;stop checking GameTime until the player feeds again
			UnregisterforUpdateGameTime()
		ElseIf FeedTimer >= 2 && (VampireStatus == 2) && VampireReverseProgressionGlobal.Value == 0
			;add Stage 3 Vampire buffs and spells
			VampireFeedReady.SetValue(2)
			VampireStageProgressionMessage.Show()
			VampireStatus = 3
			VampireProgression(Game.GetPlayer(), 3)	
		ElseIf FeedTimer >= 1 && (VampireStatus == 1) && VampireReverseProgressionGlobal.Value == 0
			;add Stage 2 Vampire buffs and spells
			VampireFeedReady.SetValue(1)
			VampireStageProgressionMessage.Show()
			VampireStatus = 2
			VampireProgression(Game.GetPlayer(), 2)	
		ElseIf FeedTimer >= 1 && (VampireStatus == 4) && VampireReverseProgressionGlobal.Value == 1
			;add Stage 3 Vampire buffs and spells
			VampireFeedReady.SetValue(2)
			VampireStageReverseProgressionMessage.Show()
			VampireStatus = 3
			VampireProgression(Game.GetPlayer(), 3)	
		ElseIf FeedTimer >= 2 && (VampireStatus == 3) && VampireReverseProgressionGlobal.Value == 1
			;add Stage 2 Vampire buffs and spells
			VampireFeedReady.SetValue(1)
			VampireStageReverseProgressionMessage.Show()
			VampireStatus = 2
			VampireProgression(Game.GetPlayer(), 2)	
		ElseIf FeedTimer >= 3 && (VampireStatus == 2) && VampireReverseProgressionGlobal.Value == 1
			;add Stage 1 Vampire buffs and spells
			VampireFeedReady.SetValue(0)
			VampireStageReverseProgressionMessage.Show()
			VampireStatus = 1
			VampireProgression(Game.GetPlayer(), 1)	
		EndIf
	Endif
	
EndEvent


Function VampireFeedBed()

	Game.GetPlayer().PlayIdle(VampireFeedingBedRight)

EndFunction

Function VampireFeedBedRoll()

	Game.GetPlayer().PlayIdle(VampireFeedingBedrollRight)

EndFunction

Function VampireChange(Actor Target)
	;Effects for hiding the change
	Game.DisablePlayerControls()
	VampireChangeFX.play(Target)
	VampireTransformIncreaseISMD.applyCrossFade(2.0)
	ObjectReference myXmarker = Target.PlaceAtMe(Xmarker)
	MAGVampireTransform01.Play(myXmarker)
	myXmarker.Disable()
	utility.wait(2.0)
	imageSpaceModifier.removeCrossFade()
	VampireChangeFX.stop(Target)

	;Change player's race, defaults to Nord Vampire
	; if (Target.GetActorBase().GetRace() == ArgonianRace)
	; 	CureRace = ArgonianRace
	; 	Target.SetRace(ArgonianRaceVampire)
	; elseif (Target.GetActorBase().GetRace() == BretonRace)
	; 	CureRace = BretonRace
	; 	Target.SetRace(BretonRaceVampire) 
	; elseif (Target.GetActorBase().GetRace() == DarkElfRace)
	; 	CureRace = DarkElfRace
	; 	Target.SetRace(DarkElfRaceVampire) 
	; elseif (Target.GetActorBase().GetRace() == HighELfRace)
	; 	CureRace = HighELfRace
	; 	Target.SetRace(HighELfRaceVampire) 
	; elseif (Target.GetActorBase().GetRace() == ImperialRace)
	; 	CureRace = ImperialRace
	; 	Target.SetRace(ImperialRaceVampire) 
	; elseif (Target.GetActorBase().GetRace() == KhajiitRace)
	; 	CureRace = KhajiitRace
	; 	Target.SetRace(KhajiitRaceVampire) 
	; elseif (Target.GetActorBase().GetRace() == NordRace)
	; 	CureRace = NordRace
	; 	Target.SetRace(NordRaceVampire) 
	; elseif (Target.GetActorBase().GetRace() == OrcRace)
	; 	CureRace = OrcRace
	; 	Target.SetRace(OrcRaceVampire) 
	; elseif (Target.GetActorBase().GetRace() == RedguardRace)
	; 	CureRace = RedguardRace
	; 	Target.SetRace(RedguardRaceVampire) 
	; elseif (Target.GetActorBase().GetRace() == WoodElfRace)
	; 	CureRace = WoodElfRace
	; 	Target.SetRace(WoodElfRaceVampire) 
	; endif
	; RCS
	Race PlayerRace = Target.GetActorBase().GetRace()
	Race PlayerVampireRace = RaceCompatibility.GetVampireRaceByRace(PlayerRace)
	If (PlayerVampireRace != None)
		CureRace = PlayerRace
		Target.SetRace(PlayerVampireRace)
	EndIf

	;Clear player's diseases
	VampireCureDisease.Cast(Target)
	Target.RemoveSpell(DiseaseBoneBreakFever)
	Target.RemoveSpell(DiseaseBrainRot )
	Target.RemoveSpell(DiseaseRattles )
	Target.RemoveSpell(DiseaseRockjoint )
	Target.RemoveSpell(DiseaseWitbane )
	Target.RemoveSpell(DiseasePorphyricHemophelia)
	Target.RemoveSpell(DiseaseAtaxia)

	;Clear player's trap diseases
	;VampireCureDisease.Cast(Target)
	Target.RemoveSpell(TrapDiseaseBoneBreakFever)
	Target.RemoveSpell(TrapDiseaseBrainRot )
	Target.RemoveSpell(TrapDiseaseRattles )
	Target.RemoveSpell(TrapDiseaseRockjoint )
	Target.RemoveSpell(TrapDiseaseWitbane )
	Target.RemoveSpell(TrapDiseasePorphyricHemophelia)
	Target.RemoveSpell(TrapDiseaseAtaxia)

	;Make player Vampire Stage 1
	If VampireReverseProgressionGlobal.Value == 0
		VampireStatus = 1
		VampireProgression(Game.GetPlayer(), 1)
	Else
		VampireStatus = 4
		VampireProgression(Game.GetPlayer(), 4)
	EndIf

	
	;Setup the Feed Timers
	RegisterForUpdateGameTime(12)
	LastFeedTime =  GameDaysPassed.Value

	;Set the Global for stat tracking
	PlayerIsVampire.SetValue(1)
	
	Utility.Wait(1)
	Game.EnablePlayerControls()	

	;If the player has been cured before, restart the cure quest
	If VC01.GetStageDone(200) == 1
		VC01.SetStage(25)
	EndIf
	
	;Let everyone know the player is now a vampire
	Target.SendVampirismStateChanged(true)

EndFunction

Function VampireFeed()
	;Effects for hiding the change
	;VampireChangeFX.play(game.getPlayer())
	VampireTransformDecreaseISMD.applyCrossFade(2.0)
	utility.wait(2.0)
	imageSpaceModifier.removeCrossFade()
	;VampireChangeFX.stop(game.getPlayer())
	
	Game.IncrementStat( "Necks Bitten" )
	;Game.ForceThirdPerson()
	;Game.GetPlayer().PlayIdle(VampireFeedingBedRight)
	;Player has fed, regress to Stage 1 Vampirisim
	;Remove Stage 2, 3, and 4 buffs and spells
	LastFeedTime =  GameDaysPassed.Value
	If VampireReverseProgressionGlobal.Value == 0
		VampireStatus = 1
		VampireProgression(Game.GetPlayer(), 1)
		VampireFeedMessage.Show()
		VampireFeedReady.SetValue(0)
	Else
		VampireStatus = 4
		VampireProgression(Game.GetPlayer(), 4)
		VampireFeedReverseProgressionMessage.Show()
		VampireFeedReady.SetValue(3)
	EndIf

	;Player is no longer hated. Only used for players that load DLC as a vampire
	Game.GetPlayer().RemoveFromFaction(VampirePCFaction)
	Game.GetPlayer().SetAttackActorOnSight(False)

	int cfIndex = 0
; 	Debug.Trace("VAMPIRE feed: DLC1CrimeFactions = " + DLC1CrimeFactions)
; 	Debug.Trace("VAMPIRE feed: CrimeFactions before = " + CrimeFactions)
	CrimeFactions = DLC1CrimeFactions
; 	Debug.Trace("VAMPIRE feed: CrimeFactions after = " + CrimeFactions)
	while (cfIndex < CrimeFactions.GetSize())
; 		Debug.Trace("VAMPIRE: Removing enemy flag from " + CrimeFactions.GetAt(cfIndex))
		(CrimeFactions.GetAt(cfIndex) as Faction).SetPlayerEnemy(false)
		cfIndex += 1
	endwhile
	
	;Start checking GameTime again if we weren't already
	UnregisterforUpdateGameTime()
	RegisterForUpdateGameTime(12)
	
	
EndFunction

Function VampireProgression(Actor Player, int VampireStage)
	;Swap out abilities depending on stage of Vampirism	
	If VampireStage == 2
		VampireTransformIncreaseISMD.applyCrossFade(2.0)
		utility.wait(2.0)
		imageSpaceModifier.removeCrossFade()		
		Player.RemoveSpell(AbVampire01)
		Player.RemoveSpell(AbVampire01b)
		Player.RemoveSpell(AbVampire01c)
		Player.RemoveSpell(AbVampire01d)
		Player.RemoveSpell(AbVampire01e)
		Player.RemoveSpell(AbVampire03)
		Player.RemoveSpell(AbVampire03b)
		Player.RemoveSpell(AbVampire03c)
		Player.RemoveSpell(AbVampire03d)
		Player.RemoveSpell(AbVampire03e)
		Player.AddSpell(AbVampire02b, abVerbose = False)
		Player.AddSpell(AbVampire02c, abVerbose = False)
		Player.AddSpell(AbVampire02d, abVerbose = False)
		Player.AddSpell(AbVampire02e, abVerbose = False)
		Player.AddSpell(AbVampire02, abVerbose = False)
		Player.RemoveSpell(VampireStrength01)
		Player.RemoveSpell(VampireStrength03)
		Player.AddSpell(VampireStrength02, abVerbose = False)
		Player.RemoveSpell(VampireSunDamage01)
		Player.RemoveSpell(VampireSunDamage03)
		Player.AddSpell(VampireSunDamage02, abVerbose = False)		
		
		;Player.AddSpell(VampireDrain02, abVerbose = False)
		;check to see if player has power equipped and switch them out
		;If Player.GetEquippedSpell(0) == VampireDrain01
			;Player.EquipSpell(VampireDrain02, 0)			
		;EndIf
		
		;If Player.GetEquippedSpell(1) == VampireDrain01
			;Player.EquipSpell(VampireDrain02, 1)
		;EndIf
		;Player.RemoveSpell(VampireDrain01)
		
		;Player.AddSpell(VampireRaiseThrall02, abVerbose = False)
		;Player.RemoveSpell(VampireRaiseThrall01)
		
		Player.AddSpell(VampireCharm)
		Player.RemoveSpell(VampireCloak)
	ElseIf VampireStage == 3
		VampireTransformIncreaseISMD.applyCrossFade(2.0)
		utility.wait(2.0)
		imageSpaceModifier.removeCrossFade()
		Player.RemoveSpell(AbVampire01)
		Player.RemoveSpell(AbVampire02)
		Player.RemoveSpell(AbVampire04)
		Player.RemoveSpell(AbVampire01b)
		Player.RemoveSpell(AbVampire02b)
		Player.RemoveSpell(AbVampire04b)
		Player.RemoveSpell(AbVampire01c)
		Player.RemoveSpell(AbVampire02c)
		Player.RemoveSpell(AbVampire04c)
		Player.RemoveSpell(AbVampire01d)
		Player.RemoveSpell(AbVampire02d)
		Player.RemoveSpell(AbVampire04d)
		Player.RemoveSpell(AbVampire01e)
		Player.RemoveSpell(AbVampire02e)
		Player.RemoveSpell(AbVampire04e)
		Player.AddSpell(AbVampire03b, abVerbose = False)
		Player.AddSpell(AbVampire03c, abVerbose = False)
		Player.AddSpell(AbVampire03d, abVerbose = False)
		Player.AddSpell(AbVampire03e, abVerbose = False)
		Player.AddSpell(AbVampire03, abVerbose = False)

		;Player.AddSpell(VampireDrain03, abVerbose = False)
		;check to see if player has power equipped and switch them out
		;If Player.GetEquippedSpell(0) == VampireDrain02 || Player.GetEquippedSpell(0) == VampireDrain01
			;Player.EquipSpell(VampireDrain03, 0)			
		;EndIf
		
		;If Player.GetEquippedSpell(1) == VampireDrain02 || Player.GetEquippedSpell(1) == VampireDrain01
			;Player.EquipSpell(VampireDrain03, 1)
		;EndIf
		;Player.RemoveSpell(VampireDrain01)
		;Player.RemoveSpell(VampireDrain02)
		
		;Player.RemoveSpell(VampireRaiseThrall01)
		;Player.RemoveSpell(VampireRaiseThrall02)
		;Player.AddSpell(VampireRaiseThrall03, abVerbose = False)
		Player.RemoveSpell(VampireStrength01)
		Player.RemoveSpell(VampireStrength02)
		Player.RemoveSpell(VampireStrength04)
		Player.AddSpell(VampireStrength03, abVerbose = False)
		Player.RemoveSpell(VampireSunDamage01)
		Player.RemoveSpell(VampireSunDamage02)
		Player.RemoveSpell(VampireSunDamage04)
		Player.AddSpell(VampireSunDamage03, abVerbose = False)
		Player.RemoveSpell(VampireInvisibilityPC)

		
		;Player.AddSpell(VampireHuntersSight)
		Player.AddSpell(VampireCloak)
	ElseIf VampireStage == 4
		If VampireReverseProgressionGlobal.Value == 0
			VampireTransformIncreaseISMD.applyCrossFade(2.0)
			utility.wait(2.0)
			imageSpaceModifier.removeCrossFade()
		EndIf
		Player.RemoveSpell(AbVampire01)
		Player.RemoveSpell(AbVampire02)
		Player.RemoveSpell(AbVampire03)
		Player.RemoveSpell(AbVampire01b)
		Player.RemoveSpell(AbVampire02b)
		Player.RemoveSpell(AbVampire03b)
		Player.RemoveSpell(AbVampire01c)
		Player.RemoveSpell(AbVampire02c)
		Player.RemoveSpell(AbVampire03c)
		Player.RemoveSpell(AbVampire01d)
		Player.RemoveSpell(AbVampire02d)
		Player.RemoveSpell(AbVampire03d)
		Player.RemoveSpell(AbVampire01e)
		Player.RemoveSpell(AbVampire02e)
		Player.RemoveSpell(AbVampire03e)
		Player.AddSpell(AbVampire04, abVerbose = False)
		Player.AddSpell(AbVampire04b, abVerbose = False)
		Player.AddSpell(AbVampire04c, abVerbose = False)
		Player.AddSpell(AbVampire04d, abVerbose = False)
		Player.AddSpell(AbVampire04e, abVerbose = False)

		;Player.AddSpell(VampireDrain04, abVerbose = False)		
		;check to see if player has power equipped and switch them out
		;If Player.GetEquippedSpell(0) == VampireDrain03 || Player.GetEquippedSpell(0) == VampireDrain02 || Player.GetEquippedSpell(0) == VampireDrain01
			;Player.EquipSpell(VampireDrain04, 0)			
		;EndIf
		
		;If Player.GetEquippedSpell(1) == VampireDrain03 || Player.GetEquippedSpell(1) == VampireDrain02 || Player.GetEquippedSpell(1) == VampireDrain01
			;Player.EquipSpell(VampireDrain04, 1)
		;EndIf
		;Player.RemoveSpell(VampireDrain01)
		;Player.RemoveSpell(VampireDrain02)
		;Player.RemoveSpell(VampireDrain03)		
		
		;Player.RemoveSpell(VampireRaiseThrall01)
		;Player.RemoveSpell(VampireRaiseThrall02)
		;Player.RemoveSpell(VampireRaiseThrall03)
		;Player.AddSpell(VampireRaiseThrall04, abVerbose = False)
		Player.RemoveSpell(VampireStrength01)
		Player.RemoveSpell(VampireStrength02)
		Player.RemoveSpell(VampireStrength03)
		Player.AddSpell(VampireStrength04, abVerbose = False)
		Player.RemoveSpell(VampireSunDamage01)
		Player.RemoveSpell(VampireSunDamage02)
		Player.RemoveSpell(VampireSunDamage03)
		Player.AddSpell(VampireSunDamage04, abVerbose = False)
		Player.AddSpell(VampireCharm)
		Player.AddSpell(VampireCloak)
		Player.AddSpell(VampireInvisibilityPC)	
		
		
	ElseIf VampireStage == 1
		If VampireReverseProgressionGlobal.Value == 1
			VampireTransformIncreaseISMD.applyCrossFade(2.0)
			utility.wait(2.0)
			imageSpaceModifier.removeCrossFade()
		EndIf
		Player.RemoveSpell(AbVampire04)
		Player.RemoveSpell(AbVampire02)
		Player.RemoveSpell(AbVampire03)
		Player.RemoveSpell(AbVampire04b)
		Player.RemoveSpell(AbVampire02b)
		Player.RemoveSpell(AbVampire03b)
		Player.RemoveSpell(AbVampire04c)
		Player.RemoveSpell(AbVampire02c)
		Player.RemoveSpell(AbVampire03c)
		Player.RemoveSpell(AbVampire04d)
		Player.RemoveSpell(AbVampire02d)
		Player.RemoveSpell(AbVampire03d)
		Player.RemoveSpell(AbVampire04e)
		Player.RemoveSpell(AbVampire02e)
		Player.RemoveSpell(AbVampire03e)
		Player.AddSpell(AbVampire01, abVerbose = False)
		Player.AddSpell(AbVampire01b, abVerbose = False)
		Player.AddSpell(AbVampire01c, abVerbose = False)
		Player.AddSpell(AbVampire01d, abVerbose = False)
		Player.AddSpell(AbVampire01e, abVerbose = False)
		
		Player.AddSpell(VampireDrain01, abVerbose = False)
		;check to see if player has power equipped and switch them out
		;If Player.GetEquippedSpell(0) == VampireDrain03 || Player.GetEquippedSpell(0) == VampireDrain04 || Player.GetEquippedSpell(0) == VampireDrain02
			;Player.EquipSpell(VampireDrain01, 0)			
		;EndIf
		
		;If Player.GetEquippedSpell(1) == VampireDrain03 || Player.GetEquippedSpell(1) == VampireDrain04 || Player.GetEquippedSpell(1) == VampireDrain02
			;Player.EquipSpell(VampireDrain01, 1)
		;EndIf
		;Player.RemoveSpell(VampireDrain04)
		;Player.RemoveSpell(VampireDrain02)
		;Player.RemoveSpell(VampireDrain03)
		
		;Player.RemoveSpell(VampireRaiseThrall04)
		;Player.RemoveSpell(VampireRaiseThrall02)
		;Player.RemoveSpell(VampireRaiseThrall03)
		;Player.AddSpell(VampireRaiseThrall01, abVerbose = False)
		Player.RemoveSpell(VampireStrength04)
		Player.RemoveSpell(VampireStrength02)
		Player.RemoveSpell(VampireStrength03)
		Player.AddSpell(VampireStrength01, abVerbose = False)
		Player.RemoveSpell(VampireSunDamage04)
		Player.RemoveSpell(VampireSunDamage02)
		Player.RemoveSpell(VampireSunDamage03)
		Player.AddSpell(VampireSunDamage01, abVerbose = False)
		 Player.RemoveSpell(VampireCharm)
		 Player.RemoveSpell(VampireCloak)
		 Player.RemoveSpell(VampireInvisibilityPC)
	EndIf
EndFunction

Function VampireCure(Actor Player)
	
	Game.IncrementStat( "Vampirism Cures" )
	;Stop tracking the Feed Timer
	UnregisterforUpdateGameTime()

	VampireStatus = 0
	;Player is no longer hated
	Player.RemoveFromFaction(VampirePCFaction)
	Player.SetAttackActorOnSight(False)
	
	;Remove all abilities
	Player.RemoveSpell(DLC1VampireChange)
	Player.RemoveSpell(ABVampireSkills)
	Player.RemoveSpell(ABVampireSkills02)	
	Player.RemoveSpell(ABVampireSkills03)	
	Player.RemoveSpell(AbVampire01)
	Player.RemoveSpell(AbVampire02)
	Player.RemoveSpell(AbVampire03)
	Player.RemoveSpell(AbVampire04)
	Player.RemoveSpell(AbVampire01b)
	Player.RemoveSpell(AbVampire02b)
	Player.RemoveSpell(AbVampire03b)
	Player.RemoveSpell(AbVampire04b)
	Player.RemoveSpell(AbVampire01c)
	Player.RemoveSpell(AbVampire02c)
	Player.RemoveSpell(AbVampire03c)
	Player.RemoveSpell(AbVampire04c)
	Player.RemoveSpell(AbVampire01d)
	Player.RemoveSpell(AbVampire02d)
	Player.RemoveSpell(AbVampire03d)
	Player.RemoveSpell(AbVampire04d)
	Player.RemoveSpell(AbVampire01e)
	Player.RemoveSpell(AbVampire02e)
	Player.RemoveSpell(AbVampire03e)
	Player.RemoveSpell(AbVampire04e)
	Player.RemoveSpell(VampireDrain01)
	Player.RemoveSpell(VampireDrain02)
	Player.RemoveSpell(VampireDrain03)
	Player.RemoveSpell(VampireDrain04)
	Player.RemoveSpell(VampireRaiseThrall01)
	Player.RemoveSpell(VampireRaiseThrall02)
	Player.RemoveSpell(VampireRaiseThrall03)
	Player.RemoveSpell(VampireRaiseThrall04)
	Player.RemoveSpell(VampireStrength01)
	Player.RemoveSpell(VampireStrength02)
	Player.RemoveSpell(VampireStrength03)
	Player.RemoveSpell(VampireStrength04)
	Player.RemoveSpell(VampireSunDamage01)
	Player.RemoveSpell(VampireSunDamage02)
	Player.RemoveSpell(VampireSunDamage03)
	Player.RemoveSpell(VampireSunDamage04)
	
	Player.RemoveSpell(VampireCharm)
	Player.RemoveSpell(VampireCloak)
	Player.RemoveSpell(VampireInvisibilityPC)
	Player.RemoveSpell(VampireBloodBoil)
	Player.RemoveSpell(VampireBloodCloak)
	Player.RemoveSpell(VampireBloodPlague)
	Player.RemoveSpell(VampireBloodRune)
	Player.RemoveSpell(VampireBloodSpear)
	Player.RemoveSpell(VampireBloodSpike)
	Player.RemoveSpell(VampireBloodStorm)
	Player.RemoveSpell(VampireBloodSurge)
	Player.RemoveSpell(VampireBloodTide)
	Player.RemoveSpell(VampireBloodTransfusion)
	Player.RemoveSpell(VampireBloodWave)
	Player.RemoveSpell(VampireWallOfBlood)
	
	;Change player's race, defaults to Nord
	; if (Player.GetRace() == ArgonianRaceVampire)
	; 	Player.SetRace(ArgonianRace)
	; elseif (Player.GetRace() == BretonRaceVampire)
	; 	Player.SetRace(BretonRace) 
	; elseif (Player.GetRace() == DarkElfRaceVampire)
	; 	Player.SetRace(DarkElfRace) 
	; elseif (Player.GetRace() == HighELfRaceVampire)
	; 	Player.SetRace(HighElfRace) 
	; elseif (Player.GetRace() == ImperialRaceVampire)
	; 	Player.SetRace(ImperialRace) 
	; elseif (Player.GetRace() == KhajiitRaceVampire)
	; 	Player.SetRace(KhajiitRace) 
	; elseif (Player.GetRace() == NordRaceVampire)
	; 	Player.SetRace(NordRace) 
	; elseif (Player.GetRace() == OrcRaceVampire)
	; 	Player.SetRace(OrcRace) 
	; elseif (Player.GetRace() == RedguardRaceVampire)
	; 	Player.SetRace(RedguardRace) 
	; elseif (Player.GetRace() == WoodElfRaceVampire)
	; 	Player.SetRace(WoodElfRace) 
	; endif
	; RCS
	Race CuredRace = RaceCompatibility.GetRaceByVampireRace(Player.GetRace())
	If (CuredRace != None)
		Player.SetRace(CuredRace)
	EndIf

	;Set the Global for stat tracking
	PlayerIsVampire.SetValue(0)
	
	;make sure Hunter's Sight is gone
	Player.RemoveSpell(VampireHuntersSight)
	
	;Let everyone know the player is no longer a vampire
	Player.SendVampirismStateChanged(false)
	
EndFunction

Spell Property AbVampire01 Auto
Spell Property AbVampire02 Auto
Spell Property AbVampire03 Auto
Spell Property AbVampire04 Auto
Spell Property AbVampire01b Auto
Spell Property AbVampire02b Auto
Spell Property AbVampire03b Auto
Spell Property AbVampire04b Auto
Spell Property AbVampire01c Auto
Spell Property AbVampire02c Auto
Spell Property AbVampire03c Auto
Spell Property AbVampire04c Auto
Spell Property AbVampire01d Auto
Spell Property AbVampire02d Auto
Spell Property AbVampire03d Auto
Spell Property AbVampire04d Auto
Spell Property AbVampire01e Auto
Spell Property AbVampire02e Auto
Spell Property AbVampire03e Auto
Spell Property AbVampire04e Auto

Spell Property VampireDrain01 Auto
Spell Property VampireDrain02 Auto
Spell Property VampireDrain03 Auto
Spell Property VampireDrain04 Auto

Spell Property VampireRaiseThrall01 Auto
Spell Property VampireRaiseThrall02 Auto
Spell Property VampireRaiseThrall03 Auto
Spell Property VampireRaiseThrall04 Auto

Spell Property VampireStrength01 Auto
Spell Property VampireStrength02 Auto
Spell Property VampireStrength03 Auto
Spell Property VampireStrength04 Auto

Spell Property VampireSunDamage01 Auto
Spell Property VampireSunDamage02 Auto
Spell Property VampireSunDamage03 Auto
Spell Property VampireSunDamage04 Auto

Spell Property VampireHuntersSight Auto
Spell Property VampireCharm Auto
Spell Property VampireCloak Auto
Spell Property VampireInvisibilityPC Auto

Spell Property VampireCureDisease Auto

Spell Property ABVampireSkills Auto
Spell Property ABVampireSkills02 Auto
Spell Property ABVampireSkills03 Auto

Spell Property DiseasePorphyricHemophelia Auto


GlobalVariable Property PlayerIsVampire  Auto  

Sound  Property MagVampireTransform01  Auto  

Spell Property DiseaseAtaxia auto
Spell Property DiseaseBoneBreakFever Auto
Spell Property DiseaseBrainRot Auto
Spell Property DiseaseRattles Auto
Spell Property DiseaseRockjoint auto
Spell Property DiseaseWitbane Auto
;Trap Diseases that also need to be removed
Spell Property TrapDiseaseAtaxia auto
Spell Property TrapDiseaseBoneBreakFever Auto
Spell Property TrapDiseaseBrainRot Auto
Spell Property TrapDiseaseRattles Auto
Spell Property TrapDiseaseRockjoint auto
Spell Property TrapDiseaseWitbane Auto
Spell Property TrapDiseasePorphyricHemophelia Auto 

Message Property VampireStage4Message Auto

Quest Property VC01 Auto
FormList Property CrimeFactions  Auto  

SPELL Property DLC1VampireChange  Auto  

FormList Property DLC1CrimeFactions  Auto  

; used to check for player in vampire lord form
MagicEffect Property DLC1VampireChangeEffect Auto
MagicEffect Property DLC1VampireChangeFXEffect Auto

Spell Property VampireBloodBoil Auto
Spell Property VampireBloodCloak Auto
Spell Property VampireBloodPlague Auto
Spell Property VampireBloodRune Auto
Spell Property VampireBloodSpear Auto
Spell Property VampireBloodSpike Auto
Spell Property VampireBloodStorm Auto
Spell Property VampireBloodSurge Auto
Spell Property VampireBloodTide Auto
Spell Property VampireBloodTransfusion Auto
Spell Property VampireBloodWave Auto
Spell Property VampireWallOfBlood Auto