scriptName magicAttachAshPileOnVampireDeathNPC extends ActiveMagicEffect
{Scripted effect for on death ash pile}

import debug
import FormList

;======================================================================================;
;  PROPERTIES  /
;=============/

float property fDelay = 1.00 auto
									{time to wait before Spawning Ash Pile}
; float property fDelayAlpha = 1.65 auto
; 									{time to wait before Setting alpha to zero.}
float property fDelayEnd = 1.65 auto
									{time to wait before Removing Base Actor}
float property ShaderDuration = 0.00 auto
									{Duration of Effect Shader.}
Activator property AshPileObject auto
									{The object we use as a pile.}
EffectShader property MagicEffectShader auto
									{The Effect Shader we want.}
Bool property bSetAlphaZero = True auto
									{The Effect Shader we want.}
FormList Property ImmunityList auto
									{If the target is in this list, they will not be disintegrated.}
Bool property bSetAlphaToZeroEarly = False Auto
									{Use this if we want to set the acro to invisible somewhere before the effect shader is done.}

TextureSet Property BVEyesMaleHumanVampire auto
TextureSet Property BVSkinEyesKhajiitVampire auto
TextureSet Property BVSkinEyesMaleArgonianVampire auto		
TextureSet Property EyesMaleHumanVampire auto
TextureSet Property SkinEyesKhajiitVampire auto
TextureSet Property SkinEyesMaleArgonianVampire auto						
TextureSet Property EyesMaleHumanBrown Auto				
TextureSet Property SkinEyesKhajiitBase auto
TextureSet Property SkinEyesMaleArgonian auto					
									
Faction Property VampirePCFaction  Auto  
Faction Property VampirePCFamily  Auto
Faction Property PotentialFollowerFaction  Auto
Faction Property CurrentFollowerFaction Auto
Faction Property CrimeFactionEastmarch  Auto
Faction Property CrimeFactionFalkreath  Auto
Faction Property CrimeFactionHjaalmarch  Auto
Faction Property CrimeFactionImperial  Auto
Faction Property CrimeFactionOrcs  Auto
Faction Property CrimeFactionPale  Auto
Faction Property CrimeFactionReach  Auto
Faction Property CrimeFactionRift  Auto
Faction Property CrimeFactionSons  Auto
Faction Property CrimeFactionWhiterun  Auto
Faction Property CrimeFactionWinterhold  Auto
Faction Property VigilantOfStendarrFaction  Auto
Faction Property VampireHunter  Auto
Faction Property DummyFaction  Auto
Faction Property DLC1HunterFaction  Auto
Faction Property DLC1DawnguardFaction  Auto
Faction Property DLC1DawnguardExteriorGuardFaction  Auto

Faction Property WERoad02BodyguardFaction Auto
Faction Property MorthalGuardhouseFaction Auto
Faction Property dunDawnstarSanctuaryGuardianFaction Auto
Faction Property MS03ChaletGuardEnemyFaction Auto
Faction Property MQ201ExteriorGuardFaction Auto
Faction Property MQ201PartyGuardFaction Auto
Faction Property DragonsreachBasementGuards Auto
Faction Property CWWhiterunGuardNeutralFaction Auto
Faction Property GuardFactionWindhelm Auto
Faction Property GuardFactionRiften Auto
Faction Property CaravanGuard Auto
Faction Property OrcGuardFaction Auto
Faction Property DA02GuardsPlayerEnemy Auto
Faction Property DA02GuardFaction Auto
Faction Property IsGuardFaction Auto
Faction Property JobGuardCaptainFaction Auto
Faction Property KarthwastenSilverFishGuards Auto
Faction Property GuardFactionCidhnaMine Auto
Faction Property GuardFactionKolskeggr Auto
Faction Property GuardFactionSoljund Auto
Faction Property GuardFactionDawnstar Auto
Faction Property GuardFactionHaafingar Auto
Faction Property GuardFactionSolitude Auto
Faction Property GuardFactionDragonbridge Auto
Faction Property GuardFactionFalkreath Auto	
Faction Property GuardFactionKarthwasten Auto	
Faction Property GuardFactionMarkarth Auto
Faction Property GuardFactionWhiterun Auto
Faction Property CWSonsFaction Auto
Faction Property CWSonsFactionNPC Auto
Faction Property CWImperialFaction Auto
Faction Property CWImperialFactionNPC Auto
			
Faction Property CWMission08AllGiantsPlayerFriendFaction Auto
Faction Property DA02CulistsPlayerEnemy Auto
Faction Property DA02CultistsAreEnemies Auto
Faction Property DA02ElisifAfraidOfPlayer Auto
Faction Property DA07PlayerEnemyFaction Auto
Faction Property DA10PlayerEnemyFaction Auto
Faction Property DA11AttackPlayerFaction Auto
Faction Property DA16OrcAmbushFaction Auto
Faction Property DA16VaerminaHostileFaction Auto
Faction Property DB11KatariahCrewFaction Auto
Faction Property dunMarkarthWizard_SecureAreaFaction Auto
Faction Property dunYsgramorsTombGhostFaction Auto
Faction Property dunKarthwastenPlayerEnemyFaction Auto
Faction Property MarriageRivalAttackFaction Auto
Faction Property MG03CallerFaction Auto
Faction Property MGThalmorFaction Auto
Faction Property MS01PlayerEnemyFaction Auto
Faction Property RiftenRatwayFactionEnemy Auto
Faction Property RiftenSkoomaDealerFactionEnemy Auto
Faction Property T03HatePlayerFaction Auto
Faction Property TG02AringothPlayerEnemyFaction Auto
Faction Property TG04EastEmpireFactionHostile Auto
Faction Property TG07ValdFactionHatesPlayer Auto
Faction Property TG08BMercerHatesPlayerFaction Auto
Faction Property TG09NightingaleEnemyFaction Auto
Faction Property TGTQ04NiranyeAttacksFaction Auto
Faction Property WEAdventureHorseRiderFaction Auto
Faction Property WEPlayerEnemy Auto
Faction Property WEThalmorPlayerEnemyFaction Auto
Faction Property WIPlayerEnemyFaction Auto
Faction Property WIPlayerEnemySpecialCombatFaction Auto

Spell Property crVampireSunDamage Auto						
Spell Property VampireTurnToAshPile Auto
Spell Property ABVampireSkills Auto
Spell Property ABVampireSkills02 Auto
Spell Property AbVampire02 Auto
Spell Property AbVampire02b Auto
Spell Property VampireVampirism Auto
Spell Property crVampireDrain03 Auto	
Spell Property VampireCharm Auto
Spell Property VampireRaiseThrall02 Auto
Spell Property VampireStrength02 Auto
Spell Property VampireSunDamageNPC Auto
Spell Property VampireCharisma02 Auto
Spell Property VampireSleep Auto
Spell Property TurnedVictimInvisibilityVampiric Auto
Spell Property VampireRankMistFormSpell Auto
Spell Property VampireRankFrostCloud04 Auto
Spell Property VampireRankIceFleshSpell04 Auto

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

ReferenceAlias Property VampireTurnedVictimAlias01 Auto
ReferenceAlias Property VampireTurnedVictimAlias02 Auto
ReferenceAlias Property VampireTurnedVictimAlias03 Auto
ReferenceAlias Property VampireTurnedVictimAlias04 Auto
ReferenceAlias Property VampireTurnedVictimAlias05 Auto
ReferenceAlias Property VampireTurnedVictimAlias06 Auto
ReferenceAlias Property VampireTurnedVictimAlias07 Auto
ReferenceAlias Property VampireTurnedVictimAlias08 Auto
ReferenceAlias Property VampireTurnedVictimAlias09 Auto
ReferenceAlias Property VampireTurnedVictimAlias10 Auto
ReferenceAlias Property VampireTurnedVictimAlias11 Auto
ReferenceAlias Property VampireTurnedVictimAlias12 Auto
ReferenceAlias Property VampireTurnedVictimAlias13 Auto
ReferenceAlias Property VampireTurnedVictimAlias14 Auto
ReferenceAlias Property VampireTurnedVictimAlias15 Auto
ReferenceAlias Property VampireTurnedVictimAlias16 Auto
ReferenceAlias Property VampireTurnedVictimAlias17 Auto
ReferenceAlias Property VampireTurnedVictimAlias18 Auto
ReferenceAlias Property VampireTurnedVictimAlias19 Auto
ReferenceAlias Property VampireTurnedVictimAlias20 Auto
ReferenceAlias Property VampireTurnedVictimAlias21 Auto
ReferenceAlias Property VampireTurnedVictimAlias22 Auto
ReferenceAlias Property VampireTurnedVictimAlias23 Auto
ReferenceAlias Property VampireTurnedVictimAlias24 Auto
ReferenceAlias Property VampireTurnedVictimAlias25 Auto
ReferenceAlias Property VampireTurnedVictimAlias26 Auto
ReferenceAlias Property VampireTurnedVictimAlias27 Auto
ReferenceAlias Property VampireTurnedVictimAlias28 Auto
ReferenceAlias Property VampireTurnedVictimAlias29 Auto
ReferenceAlias Property VampireTurnedVictimAlias30 Auto

Float Property FeedingDayTime Auto
Int Property HoursSinceTurned Auto
Int Property CurrentlySearching Auto
Idle Property VampireFeedingBedrollLeft_Loose Auto
Idle Property VampireFeedingBedrollRight_Loose Auto
Idle Property VampireFeedingBedLeft_Loose Auto
Idle Property VampireFeedingBedRight_Loose Auto
Idle Property IdleVampireStandingBack Auto
Idle Property IdleVampireStandingFront Auto
Idle Property pa_HugA Auto
Spell Property ParalyzeNPCVampire Auto
Spell Property VampireRankBlinkAttackSpellNPC Auto
Spell Property VampireTurnToAshPileNPC Auto
Keyword Property ActorTypeNPC Auto
Keyword Property ActorTypeUndead Auto
Keyword Property Vampire Auto
Keyword Property ImATurnedVampire Auto

ReferenceAlias Property TurnedVampireHungry Auto
ReferenceAlias Property TurnedVampireVictim Auto

Sound Property MagVampireTransform01  Auto  

MagicEffect Property InfluenceAggDownFFAimed Auto

GlobalVariable Property GameDaysPassed Auto
GlobalVariable Property VampireLastTimeFed Auto
GlobalVariable Property VampirePraestareRemoveAllFactions Auto
GlobalVariable Property VampireVictimSkills Auto
GlobalVariable Property VampireVictimAppearance Auto
GlobalVariable Property VampireTurnToAshes Auto
Globalvariable Property VampireDawnguardInstalled Auto
Globalvariable Property VampireVictimsWillFeed Auto
GlobalVariable Property VampireIdentifyingTurnedNPCs Auto
GlobalVariable Property SEVersion Auto
						
;======================================================================================;
;  VARIABLES   /
;=============/


actor VampTarget
race VictimRace
bool TargetIsImmune = True
; bool DeadAlready = FALSE

Float Function GetCurrentTimeOfDay() 
 
	FeedingDayTime = Utility.GetCurrentGameTime()
	FeedingDayTime -= Math.Floor(FeedingDayTime) ; Remove "previous in-game days passed" bit
	FeedingDayTime *= 24 ; Convert from fraction of a day to number of hours
	Return FeedingDayTime
 
EndFunction

;======================================================================================;
;   EVENTS     /
;=============/


Event OnEffectStart(Actor VampTargetActor, Actor Caster)

	Utility.Wait(1.0)

	VampTarget = VampTargetActor
	
	If VampTarget.HasKeyword(ImATurnedVampire) == True	
	
		If VampTarget.GetAV("Variable01") < 0
			VampTarget.SetAV("Variable01", 0)
		EndIf	

		VampTarget.SetAV("Variable01", (VampTarget.GetAV("Variable01")+1))

		; DeadAlready = VampTarget.IsDead()
		trace("VampTarget == " + VampTarget + ", is this right?")

			VampTarget.StopCombat()

			;Remove From Crime Factions
			VampTarget.RemoveFromFaction(CrimeFactionEastmarch)			
			VampTarget.RemoveFromFaction(CrimeFactionFalkreath)	
			VampTarget.RemoveFromFaction(CrimeFactionHjaalmarch)	
			VampTarget.RemoveFromFaction(CrimeFactionImperial)	
			VampTarget.RemoveFromFaction(CrimeFactionOrcs)	
			VampTarget.RemoveFromFaction(CrimeFactionPale)	
			VampTarget.RemoveFromFaction(CrimeFactionReach)	
			VampTarget.RemoveFromFaction(CrimeFactionRift)	
			VampTarget.RemoveFromFaction(CrimeFactionSons)	
			VampTarget.RemoveFromFaction(CrimeFactionWhiterun)	
			VampTarget.RemoveFromFaction(CrimeFactionWinterhold)	
			VampTarget.RemoveFromFaction(VigilantOfStendarrFaction)
			VampTarget.RemoveFromFaction(VampireHunter)
			VampTarget.RemoveFromFaction(DLC1HunterFaction)
			VampTarget.RemoveFromFaction(DLC1DawnguardFaction)
			VampTarget.RemoveFromFaction(DLC1DawnguardExteriorGuardFaction)			
			
			;Remove From Guard Factions
			VampTarget.RemoveFromFaction(WERoad02BodyguardFaction)
			VampTarget.RemoveFromFaction(MorthalGuardhouseFaction)
			VampTarget.RemoveFromFaction(dunDawnstarSanctuaryGuardianFaction)
			VampTarget.RemoveFromFaction(MS03ChaletGuardEnemyFaction)
			VampTarget.RemoveFromFaction(MQ201ExteriorGuardFaction)
			VampTarget.RemoveFromFaction(MQ201PartyGuardFaction)
			VampTarget.RemoveFromFaction(DragonsreachBasementGuards)
			VampTarget.RemoveFromFaction(CWWhiterunGuardNeutralFaction)
			VampTarget.RemoveFromFaction(GuardFactionWindhelm)
			VampTarget.RemoveFromFaction(GuardFactionRiften)
			VampTarget.RemoveFromFaction(CaravanGuard)
			VampTarget.RemoveFromFaction(OrcGuardFaction)
			VampTarget.RemoveFromFaction(DA02GuardsPlayerEnemy)
			VampTarget.RemoveFromFaction(DA02GuardFaction)
			VampTarget.RemoveFromFaction(IsGuardFaction)
			VampTarget.RemoveFromFaction(JobGuardCaptainFaction)
			VampTarget.RemoveFromFaction(KarthwastenSilverFishGuards)
			VampTarget.RemoveFromFaction(GuardFactionCidhnaMine)
			VampTarget.RemoveFromFaction(GuardFactionKolskeggr)
			VampTarget.RemoveFromFaction(GuardFactionSoljund)
			VampTarget.RemoveFromFaction(GuardFactionDawnstar)
			VampTarget.RemoveFromFaction(GuardFactionHaafingar)
			VampTarget.RemoveFromFaction(GuardFactionSolitude)
			VampTarget.RemoveFromFaction(GuardFactionDragonbridge)
			VampTarget.RemoveFromFaction(GuardFactionFalkreath)	
			VampTarget.RemoveFromFaction(GuardFactionKarthwasten)	
			VampTarget.RemoveFromFaction(GuardFactionMarkarth)
			VampTarget.RemoveFromFaction(GuardFactionWhiterun)
			VampTarget.RemoveFromFaction(CWSonsFaction)
			VampTarget.RemoveFromFaction(CWSonsFactionNPC)
			VampTarget.RemoveFromFaction(CWImperialFaction)
			VampTarget.RemoveFromFaction(CWImperialFactionNPC)			
			
			;Remove From Player Hated Factions			
			VampTarget.RemoveFromFaction(CWMission08AllGiantsPlayerFriendFaction)
			VampTarget.RemoveFromFaction(DA02CulistsPlayerEnemy)
			VampTarget.RemoveFromFaction(DA02CultistsAreEnemies)
			VampTarget.RemoveFromFaction(DA02ElisifAfraidOfPlayer)
			VampTarget.RemoveFromFaction(DA07PlayerEnemyFaction)
			VampTarget.RemoveFromFaction(DA10PlayerEnemyFaction)
			VampTarget.RemoveFromFaction(DA11AttackPlayerFaction)
			VampTarget.RemoveFromFaction(DA16OrcAmbushFaction)
			VampTarget.RemoveFromFaction(DA16VaerminaHostileFaction)
			VampTarget.RemoveFromFaction(DB11KatariahCrewFaction)
			VampTarget.RemoveFromFaction(dunMarkarthWizard_SecureAreaFaction)
			VampTarget.RemoveFromFaction(dunYsgramorsTombGhostFaction)
			VampTarget.RemoveFromFaction(dunKarthwastenPlayerEnemyFaction)
			VampTarget.RemoveFromFaction(MarriageRivalAttackFaction)
			VampTarget.RemoveFromFaction(MG03CallerFaction)
			VampTarget.RemoveFromFaction(MGThalmorFaction)
			VampTarget.RemoveFromFaction(MS01PlayerEnemyFaction)
			VampTarget.RemoveFromFaction(RiftenRatwayFactionEnemy)
			VampTarget.RemoveFromFaction(RiftenSkoomaDealerFactionEnemy)
			VampTarget.RemoveFromFaction(T03HatePlayerFaction)
			VampTarget.RemoveFromFaction(TG02AringothPlayerEnemyFaction)
			VampTarget.RemoveFromFaction(TG04EastEmpireFactionHostile)
			VampTarget.RemoveFromFaction(TG07ValdFactionHatesPlayer)
			VampTarget.RemoveFromFaction(TG08BMercerHatesPlayerFaction)
			VampTarget.RemoveFromFaction(TG09NightingaleEnemyFaction)
			VampTarget.RemoveFromFaction(TGTQ04NiranyeAttacksFaction)
			VampTarget.RemoveFromFaction(WEAdventureHorseRiderFaction)
			VampTarget.RemoveFromFaction(WEPlayerEnemy)
			VampTarget.RemoveFromFaction(WEThalmorPlayerEnemyFaction)
			VampTarget.RemoveFromFaction(WIPlayerEnemyFaction)
			VampTarget.RemoveFromFaction(WIPlayerEnemySpecialCombatFaction)

			VampTarget.StopCombat()				
			
			utility.wait(0.5)			
			VampTarget.AddtoFaction(VampirePCFamily)
			VampTarget.SetFactionRank(VampirePCFamily, 0)
			VampTarget.SetRelationshipRank(Game.GetPlayer(), 4)
			Game.GetPlayer().SetRelationshipRank(VampTarget, 4)			
			
			
			If VampTarget.IsInFaction(PotentialFollowerFaction) || VampTarget.IsInFaction(CurrentFollowerFaction)
			Else
				VampTarget.AddtoFaction(PotentialFollowerFaction)
				VampTarget.SetFactionRank(PotentialFollowerFaction, 0)
				VampTarget.AddtoFaction(CurrentFollowerFaction)
				VampTarget.SetFactionRank(CurrentFollowerFaction, -1)					
			EndIf

			VampTarget.SetActorValue("Assistance", 2)
			VampTarget.SetActorValue("Aggression", 1)
			VampTarget.SetActorValue("Confidence", 4)
			VampTarget.SetActorValue("Morality", 0)				

				
			If VampireVictimAppearance.GetValue() == 0
			
				If (VampTarget.GetActorBase().GetRace() == ArgonianRace)
					;VampTarget.SetEyeTexture(BVSkinEyesMaleArgonianVampire)
					VampTarget.SetEyeTexture(SkinEyesMaleArgonianVampire)
				ElseIf (VampTarget.GetActorBase().GetRace() == KhajiitRace)
					;VampTarget.SetEyeTexture(BVSkinEyesKhajiitVampire)
					VampTarget.SetEyeTexture(SkinEyesKhajiitVampire)
				Else
					;VampTarget.SetEyeTexture(BVEyesMaleHumanVampire)	
					VampTarget.SetEyeTexture(EyesMaleHumanVampire)
				EndIf	
				
			EndIf
			
			If VampireVictimAppearance.GetValue() == 20000
				; RCS
				Race VampTargetRace = VampTarget.GetActorBase().GetRace()
				Race VampTargetRaceVampire = RaceCompatibility.GetVampireRaceByRace(VampTargetRace)
				If (VampTargetRaceVampire != None)
					VampTarget.SetRace(VampTargetRaceVampire)
				EndIf
				; If (VampTarget.GetActorBase().GetRace() == ArgonianRace)
				; 	VampTarget.SetRace(ArgonianRaceVampire)
				; ElseIf (VampTarget.GetActorBase().GetRace() == BretonRace)
				; 	VampTarget.SetRace(BretonRaceVampire)
				; ElseIf (VampTarget.GetActorBase().GetRace() == DarkElfRace)
				; 	VampTarget.SetRace(DarkElfRaceVampire)
				; ElseIf (VampTarget.GetActorBase().GetRace() == ElderRace)
				; 	VampTarget.SetRace(ElderRaceVampire)				
				; ElseIf (VampTarget.GetActorBase().GetRace() == HighElfRace)
				; 	VampTarget.SetRace(HighElfRaceVampire)
				; ElseIf (VampTarget.GetActorBase().GetRace() == ImperialRace)
				; 	VampTarget.SetRace(ImperialRaceVampire)
				; ElseIf (VampTarget.GetActorBase().GetRace() == KhajiitRace)
				; 	VampTarget.SetRace(KhajiitRaceVampire)
				; ElseIf (VampTarget.GetActorBase().GetRace() == NordRace)
				; 	VampTarget.SetRace(NordRaceVampire)
				; ElseIf (VampTarget.GetActorBase().GetRace() == OrcRace)
				; 	VampTarget.SetRace(OrcRaceVampire)
				; ElseIf (VampTarget.GetActorBase().GetRace() == RedguardRace)
				; 	VampTarget.SetRace(RedguardRaceVampire)
				; ElseIf (VampTarget.GetActorBase().GetRace() == WoodElfRace)
				; 	VampTarget.SetRace(WoodElfRaceVampire)
				; EndIf
		
				;Many NPCs, like guards, are actually part of the Fox Race
				If (VampTargetRace == FoxRace)
					VampTarget.SetRace(NordRaceVampire)
					VampTarget.RemoveFromAllFactions()
				EndIf		

				If VampTarget.IsOnMount() == False
				
					If  SEVersion.GetValue() == 0 && VampireVictimAppearance.GetValue() == 20000
					
						If SKSE.GetVersionRelease() > 0 				
							;Utility.Wait(0.5)
							;VampTarget.SetWeight(45)	
							;Utility.Wait(0.5)
							;VampTarget.SetWeight(50)
							;;Debug.Notification("Weight changed")
							float VampTargetOrigWeight = VampTarget.GetWeight() ;Collect the Player's original weight.
							float VampTargetNewWeight = Utility.RandomFloat(45, 55)
							Float NeckDelta = (VampTargetOrigWeight / 100) - (VampTargetNewWeight / 100) ;Work out the neckdelta.
							VampTarget.GetActorBase().SetWeight(VampTargetNewWeight) ;Set Player's weight to a random float between 0.0 and 100.0.
							VampTarget.UpdateWeight(NeckDelta) ;Apply the changes.	
							String facegen = "bUseFaceGenPreprocessedHeads:General"
							Utility.SetINIBool(facegen, False)
							Utility.Wait(0.5)
							VampTarget.QueueNiNodeUpdate() 
							;VampTarget.RegenerateHead()
							Utility.Wait(0.5)			
							Utility.SetINIBool(facegen, True)
						EndIf	
						
					EndIf	
				EndIf				
				
			EndIf
			
			If VampireVictimSkills.GetValue() == 0
			
				Float PlayerHealth = Game.GetPlayer().GetBaseActorValue("Health")
				Float VampTargetHealth = PlayerHealth
				VampTarget.SetActorValue("Health", VampTargetHealth)
				
				Float PlayerMagicka = Game.GetPlayer().GetBaseActorValue("Magicka")
				VampTarget.SetActorValue("Magicka", PlayerMagicka)			
				
				Float PlayerStamina = Game.GetPlayer().GetBaseActorValue("Stamina")
				VampTarget.SetActorValue("Stamina", PlayerStamina)						
				
				VampTarget.SetActorValue("Sneak", 100)				
				
				Float Player1Hand = Game.GetPlayer().GetActorValue("OneHanded")
				VampTarget.SetActorValue("OneHanded", Player1Hand)
				
				Float Player2Hand= Game.GetPlayer().GetActorValue("TwoHanded")
				VampTarget.SetActorValue("TwoHanded", Player2Hand)

				Float PlayerMarksman = Game.GetPlayer().GetActorValue("Marksman")
				VampTarget.SetActorValue("Marksman", PlayerMarksman)	
				
				Float PlayerDestruction = Game.GetPlayer().GetActorValue("Destruction")
				VampTarget.SetActorValue("Destruction", PlayerDestruction)				
				
				Float PlayerBlock = Game.GetPlayer().GetActorValue("Block")
				VampTarget.SetActorValue("Block", PlayerBlock)
				
				Float PlayerDamageResist = Game.GetPlayer().GetActorValue("DamageResist")
				VampTarget.SetActorValue("DamageResist", PlayerDamageResist)
				
			EndIf	
			
			VampTarget.SetActorValue("Sneak", 100)				
			
			VampTarget.SetAttackActorOnSight(False)	
			
			utility.wait(1.0)			

			VampTarget.StopCombat()
			
			If VampTarget.GetAV("Variable01") >= 5 && CurrentlySearching == 0
				LookForFeedingVictim()
			EndIf
			
			
		;VampireIdentifyingTurnedNPCs.SetValue(0)	
		
		;Debug.Notification("NPC Vampire Spell is Attached")
		RegisterForUpdateGameTime(1)
		
	EndIf	
	
EndEvent


;==============================================================================================


Event OnUpdateGameTime()

	Utility.Wait(1.0)

	If VampTarget.HasKeyword(ImATurnedVampire) == True
	
		;Debug.Notification("Updating Game Time")
	
		If VampTarget.GetAV("Variable01") < 0
			VampTarget.SetAV("Variable01", 0)
		EndIf	

		VampTarget.SetAV("Variable01", (VampTarget.GetAV("Variable01")+1))
	
		utility.wait(0.5)			
		VampTarget.AddtoFaction(VampirePCFamily)
		VampTarget.SetFactionRank(VampirePCFamily, 0)
		VampTarget.SetRelationshipRank(Game.GetPlayer(), 4)
		Game.GetPlayer().SetRelationshipRank(VampTarget, 4)			
		
		
		If VampTarget.IsInFaction(PotentialFollowerFaction) || VampTarget.IsInFaction(CurrentFollowerFaction)
		Else
			VampTarget.AddtoFaction(PotentialFollowerFaction)
			VampTarget.SetFactionRank(PotentialFollowerFaction, 0)
			VampTarget.AddtoFaction(CurrentFollowerFaction)
			VampTarget.SetFactionRank(CurrentFollowerFaction, -1)					
		EndIf	
	
		If VampireVictimAppearance.GetValue() == 0
		
			If (VampTarget.GetActorBase().GetRace() == ArgonianRace)
				;VampTarget.SetEyeTexture(BVSkinEyesMaleArgonianVampire)
				VampTarget.SetEyeTexture(SkinEyesMaleArgonianVampire)
			ElseIf (VampTarget.GetActorBase().GetRace() == KhajiitRace)
				;VampTarget.SetEyeTexture(BVSkinEyesKhajiitVampire)
				VampTarget.SetEyeTexture(SkinEyesKhajiitVampire)
			Else
				;VampTarget.SetEyeTexture(BVEyesMaleHumanVampire)	
				VampTarget.SetEyeTexture(EyesMaleHumanVampire)
			EndIf	
			
		EndIf
		
		If VampireVictimAppearance.GetValue() == 20000
			; RCS
			Race VampTargetRace = VampTarget.GetActorBase().GetRace()
			Race VampTargetRaceVampire = RaceCompatibility.GetVampireRaceByRace(VampTargetRace)
			If (VampTargetRaceVampire != None)
				VampTarget.SetRace(VampTargetRaceVampire)
			EndIf	
			; If (VampTarget.GetActorBase().GetRace() == ArgonianRace)
			; 	VampTarget.SetRace(ArgonianRaceVampire)
			; ElseIf (VampTarget.GetActorBase().GetRace() == BretonRace)
			; 	VampTarget.SetRace(BretonRaceVampire)
			; ElseIf (VampTarget.GetActorBase().GetRace() == DarkElfRace)
			; 	VampTarget.SetRace(DarkElfRaceVampire)
			; ElseIf (VampTarget.GetActorBase().GetRace() == ElderRace)
			; 	VampTarget.SetRace(ElderRaceVampire)				
			; ElseIf (VampTarget.GetActorBase().GetRace() == HighElfRace)
			; 	VampTarget.SetRace(HighElfRaceVampire)
			; ElseIf (VampTarget.GetActorBase().GetRace() == ImperialRace)
			; 	VampTarget.SetRace(ImperialRaceVampire)
			; ElseIf (VampTarget.GetActorBase().GetRace() == KhajiitRace)
			; 	VampTarget.SetRace(KhajiitRaceVampire)
			; ElseIf (VampTarget.GetActorBase().GetRace() == NordRace)
			; 	VampTarget.SetRace(NordRaceVampire)
			; ElseIf (VampTarget.GetActorBase().GetRace() == OrcRace)
			; 	VampTarget.SetRace(OrcRaceVampire)
			; ElseIf (VampTarget.GetActorBase().GetRace() == RedguardRace)
			; 	VampTarget.SetRace(RedguardRaceVampire)
			; ElseIf (VampTarget.GetActorBase().GetRace() == WoodElfRace)
			; 	VampTarget.SetRace(WoodElfRaceVampire)
			; EndIf
	
			;Many NPCs, like guards, are actually part of the Fox Race
			If (VampTargetRace == FoxRace)
				VampTarget.SetRace(NordRaceVampire)
				VampTarget.RemoveFromAllFactions()
			EndIf		

			If VampTarget.IsOnMount() == False
			
				If  SEVersion.GetValue() == 0 && VampireVictimAppearance.GetValue() == 20000
				
					If SKSE.GetVersionRelease() > 0 				
						;Utility.Wait(0.5)
						;VampTarget.SetWeight(45)	
						;Utility.Wait(0.5)
						;VampTarget.SetWeight(50)
						;;Debug.Notification("Weight changed")
						float VampTargetOrigWeight = VampTarget.GetWeight() ;Collect the Player's original weight.
						float VampTargetNewWeight = Utility.RandomFloat(45, 55)
						Float NeckDelta = (VampTargetOrigWeight / 100) - (VampTargetNewWeight / 100) ;Work out the neckdelta.
						VampTarget.GetActorBase().SetWeight(VampTargetNewWeight) ;Set Player's weight to a random float between 0.0 and 100.0.
						VampTarget.UpdateWeight(NeckDelta) ;Apply the changes.	
						String facegen = "bUseFaceGenPreprocessedHeads:General"
						Utility.SetINIBool(facegen, False)
						Utility.Wait(0.5)
						VampTarget.QueueNiNodeUpdate() 
						;VampTarget.RegenerateHead()
						Utility.Wait(0.5)			
						Utility.SetINIBool(facegen, True)
					EndIf	
					
				EndIf	
			EndIf				
			
		EndIf
		
		If VampireVictimSkills.GetValue() == 0
		
			Float PlayerHealth = Game.GetPlayer().GetBaseActorValue("Health")
			Float VampTargetHealth = PlayerHealth
			VampTarget.SetActorValue("Health", VampTargetHealth)
			
			Float PlayerMagicka = Game.GetPlayer().GetBaseActorValue("Magicka")
			VampTarget.SetActorValue("Magicka", PlayerMagicka)			
			
			VampTarget.SetActorValue("Sneak", 100)				
			
			Float Player1Hand = Game.GetPlayer().GetActorValue("OneHanded")
			VampTarget.SetActorValue("OneHanded", Player1Hand)
			
			Float Player2Hand= Game.GetPlayer().GetActorValue("TwoHanded")
			VampTarget.SetActorValue("TwoHanded", Player2Hand)

			Float PlayerMarksman = Game.GetPlayer().GetActorValue("Marksman")
			VampTarget.SetActorValue("Marksman", PlayerMarksman)	
			
			Float PlayerBlock = Game.GetPlayer().GetActorValue("Block")
			VampTarget.SetActorValue("Block", PlayerBlock)
			
			Float PlayerDamageResist = Game.GetPlayer().GetActorValue("DamageResist")
			VampTarget.SetActorValue("DamageResist", PlayerDamageResist)
			
		EndIf	
		
		VampTarget.SetActorValue("Sneak", 100)				
		
		VampTarget.SetAttackActorOnSight(False)	
		
		utility.wait(1.0)			

		If VampTarget.GetAV("Variable01") >= 5 && CurrentlySearching == 0
			LookForFeedingVictim()
		EndIf
			
	
	ElseIf VampTarget.HasKeyword(ImATurnedVampire) == False
	
		VampTarget.DispelSpell(VampireTurnToAshPileNPC)	 
		VampTarget.RemoveSpell(VampireTurnToAshPileNPC)
	
	EndIf		


EndEvent


;==============================================================================================


Event OnLoad()
	
	Utility.Wait(5.0)
	
	If VampTarget.HasKeyword(ImATurnedVampire) == True
	
		;Debug.Notification("NPC Loaded")
	
		utility.wait(0.5)			
		VampTarget.AddtoFaction(VampirePCFamily)
		VampTarget.SetFactionRank(VampirePCFamily, 0)
		VampTarget.SetRelationshipRank(Game.GetPlayer(), 4)
		Game.GetPlayer().SetRelationshipRank(VampTarget, 4)			
		
		
		If VampTarget.IsInFaction(PotentialFollowerFaction) || VampTarget.IsInFaction(CurrentFollowerFaction)
		Else
			VampTarget.AddtoFaction(PotentialFollowerFaction)
			VampTarget.SetFactionRank(PotentialFollowerFaction, 0)
			VampTarget.AddtoFaction(CurrentFollowerFaction)
			VampTarget.SetFactionRank(CurrentFollowerFaction, -1)					
		EndIf	
	
	
		If VampireVictimAppearance.GetValue() == 0
		
			If (VampTarget.GetActorBase().GetRace() == ArgonianRace)
				;VampTarget.SetEyeTexture(BVSkinEyesMaleArgonianVampire)
				VampTarget.SetEyeTexture(SkinEyesMaleArgonianVampire)
			ElseIf (VampTarget.GetActorBase().GetRace() == KhajiitRace)
				;VampTarget.SetEyeTexture(BVSkinEyesKhajiitVampire)
				VampTarget.SetEyeTexture(SkinEyesKhajiitVampire)
			Else
				;VampTarget.SetEyeTexture(BVEyesMaleHumanVampire)	
				VampTarget.SetEyeTexture(EyesMaleHumanVampire)
			EndIf		
			
		EndIf
		
		If VampireVictimAppearance.GetValue() == 20000
			; RCS
			Race VampTargetRace = VampTarget.GetActorBase().GetRace()
			Race VampTargetRaceVampire = RaceCompatibility.GetVampireRaceByRace(VampTargetRace)
			If (VampTargetRaceVampire != None)
				VampTarget.SetRace(VampTargetRaceVampire)
			EndIf		
			; If (VampTarget.GetActorBase().GetRace() == ArgonianRace)
			; 	VampTarget.SetRace(ArgonianRaceVampire)
			; ElseIf (VampTarget.GetActorBase().GetRace() == BretonRace)
			; 	VampTarget.SetRace(BretonRaceVampire)
			; ElseIf (VampTarget.GetActorBase().GetRace() == DarkElfRace)
			; 	VampTarget.SetRace(DarkElfRaceVampire)
			; ElseIf (VampTarget.GetActorBase().GetRace() == ElderRace)
			; 	VampTarget.SetRace(ElderRaceVampire)				
			; ElseIf (VampTarget.GetActorBase().GetRace() == HighElfRace)
			; 	VampTarget.SetRace(HighElfRaceVampire)
			; ElseIf (VampTarget.GetActorBase().GetRace() == ImperialRace)
			; 	VampTarget.SetRace(ImperialRaceVampire)
			; ElseIf (VampTarget.GetActorBase().GetRace() == KhajiitRace)
			; 	VampTarget.SetRace(KhajiitRaceVampire)
			; ElseIf (VampTarget.GetActorBase().GetRace() == NordRace)
			; 	VampTarget.SetRace(NordRaceVampire)
			; ElseIf (VampTarget.GetActorBase().GetRace() == OrcRace)
			; 	VampTarget.SetRace(OrcRaceVampire)
			; ElseIf (VampTarget.GetActorBase().GetRace() == RedguardRace)
			; 	VampTarget.SetRace(RedguardRaceVampire)
			; ElseIf (VampTarget.GetActorBase().GetRace() == WoodElfRace)
			; 	VampTarget.SetRace(WoodElfRaceVampire)
			; EndIf

			;Many NPCs, like guards, are actually part of the Fox Race
			If (VampTargetRace == FoxRace)
				VampTarget.SetRace(NordRaceVampire)
				VampTarget.RemoveFromAllFactions()
			EndIf		

			If VampTarget.IsOnMount() == False
			
				If  SEVersion.GetValue() == 0 && VampireVictimAppearance.GetValue() == 20000
				
					If SKSE.GetVersionRelease() > 0 				
						;Utility.Wait(0.5)
						;VampTarget.SetWeight(45)	
						;Utility.Wait(0.5)
						;VampTarget.SetWeight(50)
						;;Debug.Notification("Weight changed")
						float VampTargetOrigWeight = VampTarget.GetWeight() ;Collect the Player's original weight.
						float VampTargetNewWeight = Utility.RandomFloat(45, 55)
						Float NeckDelta = (VampTargetOrigWeight / 100) - (VampTargetNewWeight / 100) ;Work out the neckdelta.
						VampTarget.GetActorBase().SetWeight(VampTargetNewWeight) ;Set Player's weight to a random float between 0.0 and 100.0.
						VampTarget.UpdateWeight(NeckDelta) ;Apply the changes.	
						String facegen = "bUseFaceGenPreprocessedHeads:General"
						Utility.SetINIBool(facegen, False)
						Utility.Wait(0.5)
						VampTarget.QueueNiNodeUpdate() 
						;VampTarget.RegenerateHead()
						Utility.Wait(0.5)			
						Utility.SetINIBool(facegen, True)
					EndIf	
					
				EndIf	
			EndIf			
			
		EndIf
	
	ElseIf VampTarget.HasKeyword(ImATurnedVampire) == False
	
		VampTarget.DispelSpell(VampireTurnToAshPileNPC)	 
		VampTarget.RemoveSpell(VampireTurnToAshPileNPC)
		
	EndIf	
	
EndEvent


;==============================================================================================


Function LookForFeedingVictim()

		GetCurrentTimeOfDay()
		
		If VampireVictimsWillFeed.GetValue() == 0 && VampTarget.GetAV("Variable01") >= 5 && CurrentlySearching == 0 && (VampTarget.IsInInterior() == 1 || (VampTarget.IsInInterior() == 0 && FeedingDayTime < 5) || (VampTarget.IsInInterior() == 0 && FeedingDayTime > 20))

			Utility.Wait(0.1)

			Int SearchForVictim = 40				
		
			;Debug.Notification("NPC Vampire is searching!")
		
			While SearchForVictim > 0
				
				Actor RandomFeedTarget = Game.FindRandomActorFromRef(VampTarget, 1200)
				CurrentlySearching = 1
				Race RandomFeedTargetRace = RandomFeedTarget.GetRace()
				
				; If (RandomFeedTargetRace == ArgonianRace) || (RandomFeedTargetRace == BretonRace) || (RandomFeedTargetRace == DarkElfRace) || (RandomFeedTargetRace == HighElfRace) || (RandomFeedTargetRace == ImperialRace) || (RandomFeedTargetRace == KhajiitRace) || (RandomFeedTargetRace == NordRace) || (RandomFeedTargetRace == OrcRace) || (RandomFeedTargetRace == RedguardRace) || (RandomFeedTargetRace == FoxRace) || (RandomFeedTargetRace == WoodElfRace)
				; RCS
				If (RandomFeedTargetRace == FoxRace) || (RaceCompatibility.GetVampireRaceByRace(RandomFeedTargetRace) != None)

					If RandomFeedTarget.HasKeyword(ActorTypeNPC) && RandomFeedTarget.HasKeyword(ActorTypeUndead) == False && RandomFeedTarget.HasKeyword(Vampire) == False && RandomFeedTarget != VampTarget && RandomFeedTarget != Game.GetPlayer() && RandomFeedTarget.IsChild() == False && RandomFeedTarget.IsGhost() == False  && RandomFeedTarget.IsDead() == False

						;Debug.Notification("NPC Vampire has found " + RandomFeedTarget)
						TurnedVampireHungry.Clear()
						TurnedVampireVictim.Clear()							
						TurnedVampireHungry.ForceRefTo(VampTarget)
						TurnedVampireVictim.ForceRefTo(RandomFeedTarget)
						VampTarget.EvaluatePackage()
						
						VampTarget.SetLookAt(RandomFeedTarget)
						
						Int SneakingToVictim = 60

						While VampTarget.GetDistance(RandomFeedTarget) > 100 && SneakingToVictim > 0
							;Debug.Notification("NPC Vampire is sneaking to target")
							SneakingToVictim -= 1
							Utility.Wait(1.0)
						EndWhile
						
						Int TryingToFeed = 5
						Bool NPCIsFeeding = False
						
						;Debug.Notification("NPC Vampire trying to feed ...")							
						
						Int PCIsInDialogue = 180
						
						While UI.IsMenuOpen("Dialogue Menu") == True && PCIsInDialogue > 0
							Utility.Wait(1.0)
							PCIsInDialogue -= 1
						EndWhile
						
						While VampTarget.GetDistance(RandomFeedTarget) < 400 && TryingToFeed > 0 && NPCIsFeeding == False && VampTarget.GetDialogueTarget() != Game.GetPlayer()
					
							If RandomFeedTarget.GetSleepState() >= 3
								If RandomFeedTarget.IsInInterior() == True
									If RandomFeedTarget.GetHeadingAngle(VampTarget) > 0
										NPCIsFeeding = VampTarget.PlayIdle(VampireFeedingBedLeft_Loose)
										;Int instanceID1 = MAGVampireTransform01.Play(RandomFeedTarget)
										;Sound.SetInstanceVolume(instanceID1, 0.5)
										If NPCIsFeeding == True
											;Debug.Notification("Bed Feeding")
											VampTarget.SetAV("Variable01", 0)
										EndIf	
									Else
										NPCIsFeeding = VampTarget.PlayIdle(VampireFeedingBedRight_Loose)
										;Int instanceID1 = MAGVampireTransform01.Play(RandomFeedTarget)
										;Sound.SetInstanceVolume(instanceID1, 0.5)
										If NPCIsFeeding == True
											;Debug.Notification("Bed Feeding")
											VampTarget.SetAV("Variable01", 0)
										EndIf	
									EndIf			
								ElseIf RandomFeedTarget.IsInInterior() == False
									If RandomFeedTarget.GetHeadingAngle(VampTarget) > 0	
										NPCIsFeeding = VampTarget.PlayIdle(VampireFeedingBedrollLeft_Loose)
										;Int instanceID1 = MAGVampireTransform01.Play(RandomFeedTarget)
										;Sound.SetInstanceVolume(instanceID1, 0.5)
										If NPCIsFeeding == True
											;Debug.Notification("Bedroll Feeding")
											VampTarget.SetAV("Variable01", 0)
										EndIf	
									Else
										NPCIsFeeding = VampTarget.PlayIdle(VampireFeedingBedrollRight_Loose)
										;Int instanceID1 = MAGVampireTransform01.Play(RandomFeedTarget)
										;Sound.SetInstanceVolume(instanceID1, 0.5)
										If NPCIsFeeding == True
											;Debug.Notification("Bedroll Feeding")
											VampTarget.SetAV("Variable01", 0)
										EndIf	
									EndIf	
								EndIf
							ElseIf RandomFeedTarget.GetSleepState() < 3
								If VampireDawnguardInstalled.GetValue() == 10000
									If !RandomFeedTarget.HasMagicEffect(InfluenceAggDownFFAimed) 
										VampireCharm.Cast(VampTarget, RandomFeedTarget)
										VampTarget.DoCombatSpellApply(VampireCharm, RandomFeedTarget)
									EndIf
									VampTarget.MoveToInteractionLocation(RandomFeedTarget)	
									Utility.Wait(3.0)
									If RandomFeedTarget.HasLOS(VampTarget) == True
										NPCIsFeeding = VampTarget.PlayIdleWithTarget(IdleVampireStandingFront, RandomFeedTarget as ObjectReference)
									Else
										NPCIsFeeding = VampTarget.PlayIdleWithTarget(IdleVampireStandingBack, RandomFeedTarget as ObjectReference)
									EndIf	
									;Int instanceID1 = MAGVampireTransform01.Play(RandomFeedTarget)
									;Sound.SetInstanceVolume(instanceID1, 0.5)
									If NPCIsFeeding == True
										;Debug.Notification("Grapple Feeding")
										VampTarget.SetAV("Variable01", 0)
									EndIf										
								ElseIf VampireDawnguardInstalled.GetValue() == 0
									If !RandomFeedTarget.HasMagicEffect(InfluenceAggDownFFAimed) 
										VampireCharm.Cast(VampTarget, RandomFeedTarget)
										VampTarget.DoCombatSpellApply(VampireCharm, RandomFeedTarget)
									EndIf
									VampTarget.MoveToInteractionLocation(RandomFeedTarget)	
									Utility.Wait(3.0)
									NPCIsFeeding = VampTarget.PlayIdleWithTarget(pa_HugA, RandomFeedTarget as ObjectReference)
									;Int instanceID1 = MAGVampireTransform01.Play(RandomFeedTarget)
									;Sound.SetInstanceVolume(instanceID1, 0.5)
									If NPCIsFeeding == True
										;Debug.Notification("Hug Feeding")
										VampTarget.SetAV("Variable01", 0)
									EndIf		
								EndIf		
							EndIf
							
							TryingToFeed -= 1
							
						EndWhile
						
						VampTarget.ClearLookAt()
						CurrentlySearching = 0
						SearchForVictim = 0
						
						;Debug.Notification("NPC Vampire is now finished searching.")
						TurnedVampireHungry.Clear()
						TurnedVampireVictim.Clear()
						
						If RandomFeedTarget.GetSleepState() >= 3
						Else
							Utility.Wait(4.0)
							If VampTarget.GetDistance(RandomFeedTarget) < 200
								TurnedVictimInvisibilityVampiric.Cast(VampTarget, VampTarget)
							EndIf	
						EndIf	
						
					Else
					
						;Debug.Notification("No specific target...")
						
					EndIf
				
					;Debug.Notification("No racial target...")
				
				EndIf
			
				SearchForVictim -= 1
			
				Utility.Wait(1.0)				
			
			EndWhile
		
			CurrentlySearching = 0
		
		EndIf
		
		;Debug.Notification("NPC Vampire will not feed at this time.")
		
		CurrentlySearching = 0

EndFunction

;==============================================================================================

Event OnDying(Actor Killer)

		utility.wait(0.5)
			 
		UnRegisterForUpdateGameTime()		 
			 
		If VampireTurnToAshes.GetValue() == 0			 
             VampTarget.SetCriticalStage(VampTarget.CritStage_DisintegrateStart)
             ;VampTarget.SetAlpha (0.99,False)
             MagicEffectShader.play(VampTarget,ShaderDuration)
             if bSetAlphaToZeroEarly
                   VampTarget.SetAlpha (0.0,True)
             endif
             utility.wait(fDelay)
             VampTarget.AttachAshpile(AshPileObject)
             ;AshPileRef = AshPileObject
             ;AshPileRef.SetAngle(0.0,0.0,(VampTarget.GetAngleZ()))
             utility.wait(fDelayEnd)
             MagicEffectShader.stop(VampTarget)
             if bSetAlphaZero == True
                    VampTarget.SetAlpha (0.0,True)
             endif
             VampTarget.SetCriticalStage(VampTarget.CritStage_DisintegrateEnd)
		EndIf	 
			 
		If (VampireTurnedVictimAlias01.GetActorReference() as Actor).IsDead()
			VampireTurnedVictimAlias01.Clear()
		EndIf
		If (VampireTurnedVictimAlias02.GetActorReference() as Actor).IsDead()
			VampireTurnedVictimAlias02.Clear()
		EndIf
		If (VampireTurnedVictimAlias03.GetActorReference() as Actor).IsDead()
			VampireTurnedVictimAlias03.Clear()
		EndIf
		If (VampireTurnedVictimAlias04.GetActorReference() as Actor).IsDead()
			VampireTurnedVictimAlias04.Clear()
		EndIf
		If (VampireTurnedVictimAlias05.GetActorReference() as Actor).IsDead()
			VampireTurnedVictimAlias05.Clear()
		EndIf
		If (VampireTurnedVictimAlias06.GetActorReference() as Actor).IsDead()
			VampireTurnedVictimAlias06.Clear()
		EndIf
		If (VampireTurnedVictimAlias07.GetActorReference() as Actor).IsDead()
			VampireTurnedVictimAlias07.Clear()
		EndIf
		If (VampireTurnedVictimAlias08.GetActorReference() as Actor).IsDead()
			VampireTurnedVictimAlias08.Clear()
		EndIf
		If (VampireTurnedVictimAlias09.GetActorReference() as Actor).IsDead()
			VampireTurnedVictimAlias09.Clear()
		EndIf
		If (VampireTurnedVictimAlias10.GetActorReference() as Actor).IsDead()
			VampireTurnedVictimAlias10.Clear()
		EndIf
		If (VampireTurnedVictimAlias11.GetActorReference() as Actor).IsDead()
			VampireTurnedVictimAlias11.Clear()
		EndIf
		If (VampireTurnedVictimAlias12.GetActorReference() as Actor).IsDead()
			VampireTurnedVictimAlias12.Clear()
		EndIf
		If (VampireTurnedVictimAlias13.GetActorReference() as Actor).IsDead()
			VampireTurnedVictimAlias13.Clear()
		EndIf
		If (VampireTurnedVictimAlias14.GetActorReference() as Actor).IsDead()
			VampireTurnedVictimAlias14.Clear()
		EndIf
		If (VampireTurnedVictimAlias15.GetActorReference() as Actor).IsDead()
			VampireTurnedVictimAlias15.Clear()
		EndIf
		If (VampireTurnedVictimAlias16.GetActorReference() as Actor).IsDead()
			VampireTurnedVictimAlias16.Clear()
		EndIf
		If (VampireTurnedVictimAlias17.GetActorReference() as Actor).IsDead()
			VampireTurnedVictimAlias17.Clear()
		EndIf
		If (VampireTurnedVictimAlias18.GetActorReference() as Actor).IsDead()
			VampireTurnedVictimAlias18.Clear()
		EndIf
		If (VampireTurnedVictimAlias19.GetActorReference() as Actor).IsDead()
			VampireTurnedVictimAlias19.Clear()
		EndIf
		If (VampireTurnedVictimAlias20.GetActorReference() as Actor).IsDead()
			VampireTurnedVictimAlias20.Clear()
		EndIf
		If (VampireTurnedVictimAlias21.GetActorReference() as Actor).IsDead()
			VampireTurnedVictimAlias21.Clear()
		EndIf
		If (VampireTurnedVictimAlias22.GetActorReference() as Actor).IsDead()
			VampireTurnedVictimAlias22.Clear()
		EndIf
		If (VampireTurnedVictimAlias23.GetActorReference() as Actor).IsDead()
			VampireTurnedVictimAlias23.Clear()
		EndIf
		If (VampireTurnedVictimAlias24.GetActorReference() as Actor).IsDead()
			VampireTurnedVictimAlias24.Clear()
		EndIf
		If (VampireTurnedVictimAlias25.GetActorReference() as Actor).IsDead()
			VampireTurnedVictimAlias25.Clear()
		EndIf
		If (VampireTurnedVictimAlias26.GetActorReference() as Actor).IsDead()
			VampireTurnedVictimAlias26.Clear()
		EndIf
		If (VampireTurnedVictimAlias27.GetActorReference() as Actor).IsDead()
			VampireTurnedVictimAlias27.Clear()
		EndIf
		If (VampireTurnedVictimAlias28.GetActorReference() as Actor).IsDead()
			VampireTurnedVictimAlias28.Clear()
		EndIf
		If (VampireTurnedVictimAlias29.GetActorReference() as Actor).IsDead()
			VampireTurnedVictimAlias29.Clear()
		EndIf
		If (VampireTurnedVictimAlias30.GetActorReference() as Actor).IsDead()
			VampireTurnedVictimAlias30.Clear()
		EndIf
			 
		VampTarget.DispelSpell(VampireTurnToAshPileNPC)	 
		VampTarget.RemoveSpell(VampireTurnToAshPileNPC)
		
		UnRegisterForUpdateGameTime()
			 
EndEvent

;==============================================================================================

Event OnEffectFinish(Actor VampTargetActor, Actor Caster)
	
	Utility.Wait(1.0)
	
	VampTarget = VampTargetActor
	
	If VampTarget.HasKeyword(ImATurnedVampire) == False	
	
		UnRegisterForUpdateGameTime()
	
		If (VampTarget.GetActorBase().GetRace() == ArgonianRace)
			VampTarget.SetEyeTexture(SkinEyesMaleArgonian)
		ElseIf (VampTarget.GetActorBase().GetRace() == KhajiitRace)
			VampTarget.SetEyeTexture(SkinEyesKhajiitBase)
		Else
			VampTarget.SetEyeTexture(EyesMaleHumanBrown)
		EndIf

		;RCS
		Race VampTargetRace = VampTarget.GetActorBase().GetRace()
		Race VampTargetRaceNormal = RaceCompatibility.GetRaceByVampireRace(VampTargetRace)
		If (VampTargetRaceNormal != None)
			VampTarget.SetRace(VampTargetRaceNormal)
		EndIf
		; If (VampTarget.GetActorBase().GetRace() == ArgonianRaceVampire)
		; 	VampTarget.SetRace(ArgonianRace)
		; ElseIf (VampTarget.GetActorBase().GetRace() == BretonRaceVampire)
		; 	VampTarget.SetRace(BretonRace)
		; ElseIf (VampTarget.GetActorBase().GetRace() == DarkElfRaceVampire)
		; 	VampTarget.SetRace(DarkElfRace)
		; ElseIf (VampTarget.GetActorBase().GetRace() == ElderRaceVampire)
		; 	VampTarget.SetRace(ElderRace)				
		; ElseIf (VampTarget.GetActorBase().GetRace() == HighElfRaceVampire)
		; 	VampTarget.SetRace(HighElfRace)
		; ElseIf (VampTarget.GetActorBase().GetRace() == ImperialRaceVampire)
		; 	VampTarget.SetRace(ImperialRace)
		; ElseIf (VampTarget.GetActorBase().GetRace() == KhajiitRaceVampire)
		; 	VampTarget.SetRace(KhajiitRace)
		; ElseIf (VampTarget.GetActorBase().GetRace() == NordRaceVampire)
		; 	VampTarget.SetRace(NordRace)
		; ElseIf (VampTarget.GetActorBase().GetRace() == OrcRaceVampire)
		; 	VampTarget.SetRace(OrcRace)
		; ElseIf (VampTarget.GetActorBase().GetRace() == RedguardRaceVampire)
		; 	VampTarget.SetRace(RedguardRace)
		; ElseIf (VampTarget.GetActorBase().GetRace() == WoodElfRaceVampire)
		; 	VampTarget.SetRace(WoodElfRace)
		; EndIf
		
		If VampTarget.IsOnMount() == False
		
			If  SEVersion.GetValue() == 0 && VampireVictimAppearance.GetValue() == 20000
			
				If SKSE.GetVersionRelease() > 0 				
					;Utility.Wait(0.5)
					;VampTarget.SetWeight(45)	
					;Utility.Wait(0.5)
					;VampTarget.SetWeight(50)
					;;Debug.Notification("Weight changed")
					float VampTargetOrigWeight = VampTarget.GetWeight() ;Collect the Player's original weight.
					float VampTargetNewWeight = Utility.RandomFloat(45, 55)
					Float NeckDelta = (VampTargetOrigWeight / 100) - (VampTargetNewWeight / 100) ;Work out the neckdelta.
					VampTarget.GetActorBase().SetWeight(VampTargetNewWeight) ;Set Player's weight to a random float between 0.0 and 100.0.
					VampTarget.UpdateWeight(NeckDelta) ;Apply the changes.	
					String facegen = "bUseFaceGenPreprocessedHeads:General"
					Utility.SetINIBool(facegen, False)
					Utility.Wait(0.5)
					VampTarget.QueueNiNodeUpdate() 
					;VampTarget.RegenerateHead()
					Utility.Wait(0.5)			
					Utility.SetINIBool(facegen, True)
				EndIf	
				
			EndIf	
		EndIf			
		
		VampTarget.SetActorValue("Variable08", 0)	
		VampTarget.SetActorValue("Variable05", 0)
		
		VampTarget.RemoveFromFaction(VampirePCFamily)
		
		UnRegisterForUpdateGameTime()
		VampTarget.DispelSpell(VampireTurnToAshPileNPC)
		VampTarget.RemoveSpell(VampireTurnToAshPileNPC)	
		
	EndIf	
	
EndEvent
