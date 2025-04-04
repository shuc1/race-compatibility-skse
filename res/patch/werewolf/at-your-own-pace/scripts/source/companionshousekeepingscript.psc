Scriptname CompanionsHousekeepingScript extends Quest Conditional
{USKP 2.0.0 has several edits for adding Stage 255 blocks to all of the CRxx quests. This was necessary for the bloat bomb fix.
 Stage 255 in each CR quest manually processes what the cleanup() functions would ordinarily do.
 cleanup() cannot be called from within this script or it will result in endless recursion and eventually lead to Papyrus freezing up and throwing stack dumps.
 Nevermind that it would also improperly reward the player for a quest this hackishly bad system is cycling out for no good reason anyway.}

bool Property USKPFarkasIntroDone auto hidden Conditional ; USKP 2.0.4 - Stop Farkas from running a double intro.

Faction property CompanionsFaction auto

MiscObject property GoldReward auto
int property GoldRewardMinorAmount auto
int property GoldRewardModerateAmount auto
int property GoldRewardMajorAmount auto

; for introductory loop
bool property PlayerWalkedAwayDuringKVScene auto conditional
bool property PlayerWalkedAwayDuringSAScene auto conditional
bool property PlayerIgnoredVilkasOutside auto conditional
bool property PlayerMetKodlak auto conditional
bool property PlayerMetVilkas auto conditional
bool property PlayerMetEorlund auto conditional
bool property PlayerMetAela auto conditional
bool property PlayerMetSkjor auto conditional
bool property PlayerMetFarkas auto conditional
bool property FarkasLastSceneStarted auto conditional
bool property AelaShouldForceGreet auto conditional
bool property EorlundShouldForceGreet auto conditional
bool property FarkasSceneGo auto conditional
Quest property TrainingQuest auto
ReferenceAlias property VilkasSword auto
ReferenceAlias property VilkasQuestSword auto
bool property VilkasHasHisSwordBack auto conditional
bool Property PlayerMetCompanionsAtGiant auto conditional
bool Property PlayerHelpedCompanionsAtGiant auto conditional

; got reward for full joining
bool Property GotWeaponReward auto conditional
bool Property EorlundToldAboutSkyforge auto conditional

; the person following you (mostly for dialogue conditions)
ReferenceAlias Property CurrentFollower auto

; so we can wrangle your followers
DialogueFollowerScript Property FollowerScript auto
GlobalVariable Property PlayerFollowerCount auto
DarkBrotherhood Property DBScript auto
Actor Property CiceroFollower auto
Actor Property DBInitiateFollower1 auto
Actor Property DBInitiateFollower2 auto

; the circle (tm) + kodlak (collect all five)
ReferenceAlias property Skjor auto
ReferenceAlias property Aela auto
ReferenceAlias property Farkas auto
ReferenceAlias property Vilkas auto
ReferenceAlias property Kodlak auto

; other jerks
ReferenceAlias Property Athis auto
ReferenceAlias Property Njada auto
ReferenceAlias Property Ria auto
ReferenceAlias Property Torvar auto

; not technically a companion, but he's still cool
ReferenceAlias Property Eorlund auto

; the faction for trainers to get put into when the player joins
Faction Property TrainerFaction auto

; that guy (or gal) who follows you
ReferenceAlias property TrialObserver auto

; the weapon that we'll give to Vilkas
Weapon property VilkasWeapon auto

; setting up Eorlund to sell you Companions gear
LeveledItem Property CompanionsArmor auto
LeveledItem Property SkyforgeSteelWeapons auto
ObjectReference Property EorlundVendorChest auto
GlobalVariable Property GearChance auto

; naughty naughty
bool property PlayerThievingAndNotPaying auto conditional
int property PlayerThievingThreshold auto conditional

; to shut them up when there are more important things going on
ReferenceAlias Property GenericDialogueSuppressor1 auto
ReferenceAlias Property GenericDialogueSuppressor2 auto
ReferenceAlias Property GenericDialogueSuppressor3 auto
ReferenceAlias Property GenericDialogueSuppressor4 auto

; track whether the player currently has werewolf ability
bool Property PlayerHasBeastBlood = false auto conditional
GlobalVariable Property PlayerIsWerewolf auto
	; gets set true when you join (so we can still debug the werewolf transform)
	bool Property PlayerIsWerewolfVirgin = false auto conditional 

; so Skjor can let you in to the Underforge before you're a werewolf
bool Property TempUnderforgeAccess = false auto conditional

Quest Property WerewolfChangeTrackingQuest auto
Spell Property WerewolfImmunity auto
Spell Property BeastForm auto
; FIX FOR 81462
Spell Property HircinesRingPower auto
; END FIX FOR 81462

Race Property PlayerOriginalRace auto

Race Property ArgonianRace auto
Race Property ArgonianRaceVampire auto
Race Property BretonRace auto
Race Property BretonRaceVampire auto
Race Property DarkElfRace auto
Race Property DarkElfRaceVampire auto
Race Property HighElfRace auto
Race Property HighElfRaceVampire auto
Race Property ImperialRace auto
Race Property ImperialRaceVampire auto
Race Property KhajiitRace auto
Race Property KhajiitRaceVampire auto
Race Property NordRace auto
Race Property NordRaceVampire auto
Race Property OrcRace auto
Race Property OrcRaceVampire auto
Race Property RedguardRace auto
Race Property RedguardRaceVampire auto
Race Property WoodElfRace auto
Race Property WoodElfRaceVampire auto

Shout Property CurrentHowl auto
WordOfPower Property CurrentHowlWord1 auto
WordOfPower Property CurrentHowlWord2 auto
WordOfPower Property CurrentHowlWord3 auto

;;; quest tracking from here down ;;;
int property RadiantQuestsDone auto conditional
int property RadiantQuestsDoneInCurrentSegment auto conditional
ReferenceAlias property RadiantQuestgiver auto
Faction Property CurrentFollowerFaction auto

int Property C04MinLevel auto ; because there are Hagravens involved

CompanionsRadiantQuest Property AelaCurrentQuest auto
CompanionsRadiantQuest Property VilkasCurrentQuest auto
CompanionsRadiantQuest Property FarkasCurrentQuest auto
CompanionsRadiantQuest Property SkjorCurrentQuest auto

CompanionsRadiantQuest Property AelaNextQuest auto
CompanionsRadiantQuest Property VilkasNextQuest auto
CompanionsRadiantQuest Property FarkasNextQuest auto
CompanionsRadiantQuest Property SkjorNextQuest auto

Keyword property AelaRadiantKeyword auto
Keyword property SkjorRadiantKeyword auto
Keyword property VilkasRadiantKeyword auto
Keyword property FarkasRadiantKeyword auto
Keyword property ReconRadiantKeyword auto

bool property RadiantAelaBlock auto conditional
bool property RadiantSkjorBlock auto conditional
bool property RadiantFarkasBlock auto conditional
bool property RadiantVilkasBlock auto conditional

Quest Property RadiantMiscObjQuest auto
bool property StoryQuestIsRunning auto conditional
bool property RadiantQuestAccepted auto conditional
bool property RadiantQuestFinished auto conditional
bool property IsCurrentSilverHandTarget auto conditional
int  property LastRadiantQuestDoneIndex auto conditional

bool property AelaInReconMode auto conditional
bool property DoneReconQuestForAela auto conditional
ObjectReference property QuestgiverStandMarker auto conditional

int property RadiantQuestsUntilC01 auto
int property RadiantQuestsUntilC03 auto
int property RadiantQuestsUntilC04 auto

CompanionsStoryQuest property C01 auto
CompanionsStoryQuest property C02 auto
CompanionsStoryQuest property C03 auto
CompanionsStoryQuest property C04 auto
CompanionsStoryQuest property C05 auto
CompanionsStoryQuest property C06 auto

; CR12 persistent tracking
int Property TotemsFound auto conditional
bool Property AelaIsConfused auto conditional

; CR13 persistent tracking
bool Property VilkasHasBeastBlood auto conditional
bool Property FarkasHasBeastBlood auto conditional

;; Radiant Quests
; grunt work
;CompanionsRadiantQuest property CR01 auto ; a beast loose in someone's house
;CompanionsRadiantQuest property CR02 auto ; beasts in a den near town harassing people
;CompanionsRadiantQuest property CR03 auto ; collect pelts
;CompanionsRadiantQuest property CR04 auto ; intimidation missions
;CompanionsRadiantQuest property CR05 auto ; clear a dungeon
;CompanionsRadiantQuest property CR06 auto ; family heirloom
; "real" quests
;CompanionsRadiantQuest property CR07 auto ; capture criminals
;CompanionsRadiantQuest property CR08 auto ; rescue people
; silver hand quests with Aela
;CompanionsRadiantQuest property CR09 auto ; assasinate lieutenants
;CompanionsRadiantQuest property CR10 auto ; steal plans
;CompanionsRadiantQuest property CR11 auto ; retrieve pieces of blade
;CompanionsRadiantQuest property CR12 auto ; wipe out camps
; leader work
;CompanionsRadiantQuest property CR13 auto ; curing vilkas/farkas
;CompanionsRadiantQuest property CR14 auto ; let a newbie in

CompanionsStoryQuest property CurrentStoryQuest auto

int property FavoriteQuestgiver auto conditional
	; 0 --> None (default behavior defined in quest)
	; 1 --> Aela
	; 3 --> Vilkas
	; 2 --> Farkas
	; 4 --> Skjor
bool Property AelaIsObserver auto conditional
bool Property FarkasIsObserver auto conditional
int property AelaQuests auto
int property FarkasQuests auto
int property VilkasQuests auto
int property SkjorQuests auto

;; location tracking for reservations
LocationAlias Property DustmansCairn auto
LocationAlias Property GallowsRock auto
LocationAlias Property YsgramorsTomb auto


; Quest Designer needs arrays badly. Quest Designer is about to die.
CompanionsRadiantQuest Function GetRadiantQuestFromIndex(int questIndex)
	;
EndFunction

int Function GetIndexFromRadiantQuest(Quest rQuest)
	;
EndFunction


Function OnInit()
	; PlayerJoin() ; for debugging, usually commented out
EndFunction

Function SetUpCompanions()
; 	Debug.Trace("C00: Waiting to set up Companions.")
	Utility.Wait(60) ; giving other quests the chance to finish their reservations
					 ;  (very conservative time buffer, but chargen takes a while, 
					 ;  so let's be safe)

; 	Debug.Trace("C00: Setting up Companions...")
		
	RadiantQuestsDone = 0
	StoryQuestIsRunning = False
	RadiantQuestAccepted = False
	RadiantQuestFinished = False

	AelaCurrentQuest = None
	VilkasCurrentQuest = None
	FarkasCurrentQuest = None
	SkjorCurrentQuest = None
	
	AelaNextQuest = None
	VilkasNextQuest = None
	FarkasNextQuest = None
	SkjorNextQuest = None

	RadiantAelaBlock = False
	RadiantFarkasBlock = False
	RadiantSkjorBlock = False
	RadiantVilkasBlock = False

	; do this twice to queue up two quests
	CycleRadiantQuests()
	; while (\
	; 	   (SkjorCurrentQuest == None || !SkjorCurrentQuest.GetStageDone(1)) \
	; 	&& (AelaCurrentQuest == None || !AelaCurrentQuest.GetStageDone(1)) \
	; 	&& (FarkasCurrentQuest == None || !FarkasCurrentQuest.GetStageDone(1)) \
	; 	&& (VilkasCurrentQuest == None || !VilkasCurrentQuest.GetStageDone(1)) \
	; 	)
; 	; 	Debug.Trace("C00: Waiting on RQ cycle...")
	; 	Utility.Wait(0.1)
	; endwhile
	CycleRadiantQuests()
	
	CurrentStoryQuest = None
	
; 	Debug.Trace("C00: Setup done; setting stage 1.")
	SetStage(1)
EndFunction

; RCS
Function SetPlayerOriginalRace()
	; get player's race so we have it permanently for werewolf switch back
	PlayerOriginalRace = Game.GetPlayer().GetRace()
; 	Debug.Trace("CSQ: Storing player's race as " + PlayerOriginalRace)
	; RCS, cure vampirism
	Race OriginalRace = RaceCompatibility.GetRaceByVampireRace(PlayerOriginalRace)
	If (OriginalRace != None)
		PlayerOriginalRace = OriginalRace
	EndIf
EndFunction

Function PlayerJoin()
; 	Debug.Trace("C00: Player joined Companions.")
	if (Game.GetPlayer().IsInFaction(CompanionsFaction))
		return
	endif
	
	Game.GetPlayer().AddToFaction(CompanionsFaction)

	; start misc pointer for radiant quests
	RadiantMiscObjQuest.Start()

	; allow trainers
	Athis.GetActorReference().AddToFaction(TrainerFaction)
	Aela.GetActorReference().AddToFaction(TrainerFaction)
	Njada.GetActorReference().AddToFaction(TrainerFaction)
	Vilkas.GetActorReference().AddToFaction(TrainerFaction)
	Eorlund.GetActorReference().AddToFaction(TrainerFaction)
	Farkas.GetActorReference().AddToFaction(TrainerFaction)

	; set up the spell tracking so the first time you cast it doesn't count
	PlayerIsWerewolfVirgin = true

	; get player's race so we have it permanently for werewolf switch back
	SetPlayerOriginalRace()
	; PlayerOriginalRace = Game.GetPlayer().GetRace()
; 	Debug.Trace("CSQ: Storing player's race as " + PlayerOriginalRace)

; 	if     (PlayerOriginalRace == ArgonianRaceVampire)
; ; 		Debug.Trace("CSQ: Player was Argonian Vampire; storing as Argonian.")
; 		PlayerOriginalRace = ArgonianRace
; 	elseif (PlayerOriginalRace == BretonRaceVampire)
; ; 		Debug.Trace("CSQ: Player was Breton Vampire; storing as Breton.")
; 		PlayerOriginalRace = BretonRace
; 	elseif (PlayerOriginalRace == DarkElfRaceVampire)
; ; 		Debug.Trace("CSQ: Player was Dark Elf Vampire; storing as Dark Elf.")
; 		PlayerOriginalRace = DarkElfRace
; 	elseif (PlayerOriginalRace == HighElfRaceVampire)
; ; 		Debug.Trace("CSQ: Player was High Elf Vampire; storing as High Elf.")
; 		PlayerOriginalRace = HighElfRace
; 	elseif (PlayerOriginalRace == ImperialRaceVampire)
; ; 		Debug.Trace("CSQ: Player was Imperial Vampire; storing as Imperial.")
; 		PlayerOriginalRace = ImperialRace
; 	elseif (PlayerOriginalRace == KhajiitRaceVampire)
; ; 		Debug.Trace("CSQ: Player was Khajiit Vampire; storing as Khajiit.")
; 		PlayerOriginalRace = KhajiitRace
; 	elseif (PlayerOriginalRace == NordRaceVampire)
; ; 		Debug.Trace("CSQ: Player was Nord Vampire; storing as Nord.")
; 		PlayerOriginalRace = NordRace
; 	elseif (PlayerOriginalRace == OrcRaceVampire)
; ; 		Debug.Trace("CSQ: Player was Orc Vampire; storing as Orc.")
; 		PlayerOriginalRace = OrcRace
; 	elseif (PlayerOriginalRace == RedguardRaceVampire)
; ; 		Debug.Trace("CSQ: Player was Redguard Vampire; storing as Redguard.")
; 		PlayerOriginalRace = RedguardRace
; 	elseif (PlayerOriginalRace == WoodElfRaceVampire)
; ; 		Debug.Trace("CSQ: Player was Wood Elf Vampire; storing as Wood Elf.")
; 		PlayerOriginalRace = WoodElfRace
; 	endif

; 	Debug.Trace("CSQ: Storing player's race as " + PlayerOriginalRace)
	
	; achievements YAY
	Game.AddAchievement(9)
EndFunction

Function OpenSkyforge()
	; set up Eorlund to sell you stuff
	GearChance.SetValueInt(0)

	; add them right now in case you run up
	EorlundVendorChest.AddItem(CompanionsArmor)
	EorlundVendorChest.AddItem(SkyforgeSteelWeapons)
EndFunction

; super specialized
Function GiveVilkasBackHisSword()
	ObjectReference vs = VilkasSword.GetReference()
	; make sure it's been cleared as a quest item
	VilkasQuestSword.Clear()
	;VilkasSword.Clear() - Commented out by USKP 2.0.1. The main sword alias is not optional and cannot be cleared.
	
	Eorlund.GetReference().RemoveItem(vs)

	Vilkas.GetReference().AddItem(VilkasWeapon)

	VilkasHasHisSwordBack = True
EndFunction

Function CycleRadiantQuests()
	;
EndFunction

Function PickRadiantQuest(Actor questgiver)
	;
EndFunction

Function RegisterRadiantQuest(CompanionsRadiantQuest newRadiant)
	;
EndFunction

Function AcceptRadiantQuest(Actor questgiver, bool comesAlong)
	;
EndFunction

Function ShutdownRadiantQuests(Actor exception = None)
	;
EndFunction

Function ShutdownRadiantQuestsFor(Actor busy)
	;
EndFunction

Function ReOpenAllRadiantQuests()
	;
EndFunction

bool __reconKicked = false

; One off to kick Aela's recon radiant quests post C03
Function KickOffReconQuests()
	;
EndFunction

int function CompleteRadiantQuest(CompanionsRadiantQuest rq)
; 	Debug.Trace("CRQ: Completing radiant quest: " + rq)
	bool success = rq.Succeeded
	
	; store the questgiver for checking later in this function
	Actor qg = rq.Questgiver.GetActorReference()

	if (success)
		; increment questgiver count
		if     (qg == Aela.GetActorReference())
			AelaQuests += 1
		elseif (qg == Skjor.GetActorReference())
			SkjorQuests += 1
		elseif (qg == Vilkas.GetActorReference())
			VilkasQuests += 1
		elseif (qg == Farkas.GetActorReference())
			FarkasQuests += 1
		endif

		; increment overall radiant quest count
		RadiantQuestsDone += 1
		RadiantQuestsDoneInCurrentSegment += 1
	endif
	
	; pay the player (even if not successful, there might be a midway reward)
	;Game.GetPlayer().AddItem(GoldReward, rq.RewardAmount)
		
	; Mr. Book: SHUT IT DOWN!
	; rq.Stop()
	rq.IsAccepted = False ; so it can get cleared with the cycle
	ReOpenAllRadiantQuests()

	CycleRadiantQuests()
		
	; update favorite questgiver
	FavoriteQuestgiver = 0
	int fqgCount = 0
	if (AelaQuests > fqgCount)
		FavoriteQuestgiver = 1
		fqgCount = AelaQuests
	endif
	if (FarkasQuests > fqgCount)
		FavoriteQuestgiver = 2
		fqgCount = FarkasQuests
	endif
	if (VilkasQuests > fqgCount)
		FavoriteQuestgiver = 3
		fqgCount = VilkasQuests
	endif
	if (SkjorQuests > fqgCount)
		FavoriteQuestgiver = 4
		fqgCount = SkjorQuests
	endif
	
	return RadiantQuestsDone
endFunction

Actor function GetFavoriteQuestgiver()
	;
endFunction

function StartStoryQuest(CompanionsStoryQuest storyToStart)
	CurrentStoryQuest = storyToStart
; 	Debug.Trace("CSQ: Starting story quest: " + CurrentStoryQuest)
	storyToStart.SetStage(1)
	StoryQuestIsRunning = True
	;RadiantMiscObjQuest.SetObjectiveDisplayed(10, false)
endFunction

function CompleteStoryQuest(CompanionsStoryQuest storyToEnd)
; 	Debug.Trace("CSQ: Ending " + storyToEnd)
	
	storyToEnd.Teardown()
	storyToEnd.Stop()
	while(storyToEnd.IsRunning())
; 		Debug.Trace("CSQ: Waiting for quest to end: " + storyToEnd)
		Utility.Wait(0.5)
	endwhile
	
	CurrentStoryQuest = None
	StoryQuestIsRunning = False
	if ( (storyToEnd != C03) && (storyToEnd != C04) && (storyToEnd != C05) )
		;RadiantMiscObjQuest.SetObjectiveDisplayed(10, true)
	endif
	if (storyToEnd == C02)
		OpenSkyforge()
	endif
endFunction

Function AddHarbingerPerks()
	Aela.GetActorReference().SetRelationshipRank(Game.GetPlayer(), 2)
	Farkas.GetActorReference().SetRelationshipRank(Game.GetPlayer(), 2)
	Vilkas.GetActorReference().SetRelationshipRank(Game.GetPlayer(), 2)
	Athis.GetActorReference().SetRelationshipRank(Game.GetPlayer(), 2)
	Ria.GetActorReference().SetRelationshipRank(Game.GetPlayer(), 2)
	Njada.GetActorReference().SetRelationshipRank(Game.GetPlayer(), 2)
	Torvar.GetActorReference().SetRelationshipRank(Game.GetPlayer(), 2)
EndFunction

Function CurePlayer()
; 	Debug.Trace("WEREWOLF: Curing the player of lycanthropy.")

	; turn you back if you're currently a werewolf
	if (WerewolfChangeTrackingQuest.IsRunning() && WerewolfChangeTrackingQuest.GetStage() < 100)
    	WerewolfChangeTrackingQuest.SetStage(100)
    endif

    ; take away spell and immunity
    Game.GetPlayer().RemoveSpell(BeastForm)
    Game.GetPlayer().RemoveSpell(WerewolfImmunity)

    ; FIX FOR 81462
    Game.GetPlayer().RemoveSpell(HircinesRingPower)
    ; END FIX FOR 81462

    ; you can't get into the Underforge anymore, either
    TempUnderforgeAccess = false
    PlayerHasBeastBlood = false
	
	; Let everyone know you are no longer a werewolf
	Game.GetPlayer().SendLycanthropyStateChanged(false) ;Official Patch 1.5.3
	PlayerIsWerewolf.SetValueInt(0) ; Added by USKP 1.2.2 - This global was never unset.
EndFunction


Function Shutup(Actor toBeShut)
	if     (GenericDialogueSuppressor1.GetReference() == None)
		GenericDialogueSuppressor1.ForceRefTo(toBeShut)
	elseif (GenericDialogueSuppressor2.GetReference() == None)
		GenericDialogueSuppressor2.ForceRefTo(toBeShut)
	elseif (GenericDialogueSuppressor3.GetReference() == None)
		GenericDialogueSuppressor3.ForceRefTo(toBeShut)
	elseif (GenericDialogueSuppressor4.GetReference() == None)
		GenericDialogueSuppressor4.ForceRefTo(toBeShut)
	else
; 		Debug.Trace("C00: Can't shut anyone else up.")
	endif
EndFunction

Function UnShutup(Actor toBeUnShut)
	if     (GenericDialogueSuppressor1.GetReference() == toBeUnShut)
		GenericDialogueSuppressor1.Clear()
	elseif (GenericDialogueSuppressor2.GetReference() == toBeUnShut)
		GenericDialogueSuppressor2.Clear()
	elseif (GenericDialogueSuppressor3.GetReference() == toBeUnShut)
		GenericDialogueSuppressor3.Clear()
	elseif (GenericDialogueSuppressor4.GetReference() == toBeUnShut)
		GenericDialogueSuppressor4.Clear()
	else
; 		Debug.Trace("C00: " + toBeUnShut + " was never shut up.")
	endif
EndFunction

Function SwapFollowers()
; 	Debug.Trace("CSQ: Swapping followers.")
	; called when a story quest is assigning you a follower (C01, C03, C05, and C06)
	;  so that you don't end up with too big of an entourage.
	if (PlayerFollowerCount.GetValue() > 0)
		FollowerScript.DismissFollower(2)

		; Because the Dark Brotherhood does its own jimminess instead of 
		;  using the normal follower system, we have to dismiss manually. 
		if (DBScript.CiceroFollower == 1)
			CiceroFollower.SetPlayerTeammate(false)
			DBScript.CiceroFollower = 0
			DBScript.CiceroState = 1
			CiceroFollower.EvaluatePackage()
		endif

		if (DBScript.Initiate1Follower == 1)
			DBInitiateFollower1.SetPlayerTeammate(false)
			DBScript.Initiate1Follower = 0
			DBScript.Initiate1State = 1
			DBInitiateFollower1.EvaluatePackage()
		endif

		if (DBScript.Initiate2Follower == 1)
			DBInitiateFollower2.SetPlayerTeammate(false)
			DBScript.Initiate2Follower = 0
			DBScript.Initiate2State = 1
			DBInitiateFollower2.EvaluatePackage()
		endif
	endif
	PlayerFollowerCount.SetValue(1)
EndFunction

Function CleanupFollowerState()
	PlayerFollowerCount.SetValue(0)
EndFunction

GlobalVariable Property AYOPCPRadiantsForC01  Auto  

GlobalVariable Property AYOPCPRadiantsForC03  Auto  

GlobalVariable Property AYOPCPRadiantsForC04  Auto  

Function AYOPStartQuest()

	bool startedStory = False
	if     (C01.GetStage() < 1)
			StartStoryQuest(C01)
			startedStory = True
	elseif (C03.GetStage() < 1)
			StartStoryQuest(C03)
			startedStory = True
	elseif (C04.GetStage() < 1)
			StartStoryQuest(C04)
			startedStory = True
	endif

	; reset tracking
	if (!startedStory)
		RadiantMiscObjQuest.SetObjectiveDisplayed(10, true)
	endif
	RadiantQuestAccepted = False
	RadiantQuestFinished = False
	RadiantQuestgiver.Clear()
		
	; reset tracking number
	if (startedStory)
		RadiantQuestsDoneInCurrentSegment = 0
	endif
		
	; return total radiant quests done for Companions
	;return RadiantQuestsDone
	
EndFunction

Function AYOPStartQuestC04()

	bool startedStory = False
	StartStoryQuest(C04)
	startedStory = True

	; reset tracking
	if (!startedStory)
		RadiantMiscObjQuest.SetObjectiveDisplayed(10, true)
	endif
	RadiantQuestAccepted = False
	RadiantQuestFinished = False
	RadiantQuestgiver.Clear()
		
	; reset tracking number
	if (startedStory)
		RadiantQuestsDoneInCurrentSegment = 0
	endif
		
	; return total radiant quests done for Companions
	;return RadiantQuestsDone
	
EndFunction