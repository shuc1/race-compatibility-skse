Scriptname PlayerWerewolfChangeScript extends Quest  

float Property StandardDurationSeconds auto
{How long (in real seconds) the transformation lasts}

float Property DurationWarningTimeSeconds auto
{How long (in real seconds) before turning back we should warn the player}

float Property FeedExtensionTimeSeconds auto
{How long (in real seconds) that feeding extends werewolf time}

VisualEffect property FeedBloodVFX auto
{Visual Effect on Wolf for Feeding Blood}

Race Property WerewolfBeastRace auto
ObjectReference Property LycanStash auto
Perk Property PlayerWerewolfFeed auto

Faction Property PlayerWerewolfFaction auto
Faction Property WerewolfFaction auto

Message Property PlayerWerewolfExpirationWarning auto
Message Property PlayerWerewolfFeedMessage auto
GlobalVariable Property GameDaysPassed auto
GlobalVariable Property TimeScale auto
GlobalVariable Property PlayerWerewolfShiftBackTime auto

ImageSpaceModifier Property WerewolfWarn auto
ImageSpaceModifier Property WerewolfChange auto

Race Property WerewolfRace auto
Sound Property NPCWerewolfTransformation auto
Sound Property WerewolfIMODSound auto
Idle Property WerewolfTransformBack auto
Idle Property SpecialFeeding auto

Quest Property CompanionsTrackingQuest auto
Quest Property C03Rampage auto

Shout Property CurrentHowl auto
WordOfPower Property CurrentHowlWord1 auto
WordOfPower Property CurrentHowlWord2 auto
WordOfPower Property CurrentHowlWord3 auto

Spell Property PlayerWerewolfLvl10AndBelowAbility auto
Spell Property PlayerWerewolfLvl15AndBelowAbility auto
Spell Property PlayerWerewolfLvl20AndBelowAbility auto
Spell Property PlayerWerewolfLvl25AndBelowAbility auto
Spell Property PlayerWerewolfLvl30AndBelowAbility auto
Spell Property PlayerWerewolfLvl35AndBelowAbility auto
Spell Property PlayerWerewolfLvl40AndBelowAbility auto
Spell Property PlayerWerewolfLvl45AndBelowAbility auto
Spell Property PlayerWerewolfLvl50AndOverAbility auto

Spell Property FeedBoost auto
Spell property BleedingFXSpell auto
{This Spell is for making the target of feeding bleed.}

Armor Property WolfSkinFXArmor auto

bool Property Untimed auto

FormList Property CrimeFactions auto
FormList Property WerewolfDispelList auto

float __durationWarningTime = -1.0
float __feedExtensionTime = -1.0
float __gorgeExtensionTime = -1.0
bool __tryingToShiftBack = false
bool __shiftingBack = false
bool __shuttingDown = false
bool __trackingStarted = false

float Function RealTimeSecondsToGameTimeDays(float realtime)
    float scaledSeconds = realtime * TimeScale.Value
    return scaledSeconds / (60 * 60 * 24)
EndFunction

float Function GameTimeDaysToRealTimeSeconds(float gametime)
    float gameSeconds = gametime * (60 * 60 * 24)
    return (gameSeconds / TimeScale.Value)
EndFunction

Function PrepShift()
;     Debug.Trace("WEREWOLF: Prepping shift...")
    (CompanionsTrackingQuest as CompanionsHousekeepingScript).SetPlayerOriginalRace()
    Actor playerRef = Game.GetPlayer()

    ; sets up the UI restrictions
    Game.SetBeastForm(True)
    Game.EnableFastTravel(False)

    ; set up perks/abilities
    ;  (don't need to do this anymore since it's on from gamestart)
    ; Game.GetPlayer().AddPerk(PlayerWerewolfFeed)

    ; screen effect
    WerewolfChange.Apply()
    WerewolfIMODSound.Play(playerRef)

    ; get rid of your summons
    int count = 0
    while (count < WerewolfDispelList.GetSize())
        Spell gone = WerewolfDispelList.GetAt(count) as Spell
        if (gone != None)
            playerRef.DispelSpell(gone)
        endif
        count += 1
    endwhile


    Game.DisablePlayerControls(abMovement = false, abFighting = false, abCamSwitch = true, abMenu = false, abActivate = false, abJournalTabs = false, aiDisablePOVType = 1)
    Game.ForceThirdPerson()
    Game.ShowFirstPersonGeometry(false)
EndFunction

Function InitialShift()
;     Debug.Trace("WEREWOLF: Player beginning transformation.")

    WerewolfWarn.Apply()

    if (Game.GetPlayer().IsDead())
;         Debug.Trace("WEREWOLF: Player is dead; bailing out.")
        return
    endif

    ; actual switch
    Game.GetPlayer().SetRace(WerewolfBeastRace)
EndFunction

Function StartTracking()
    if (__trackingStarted)
        return
    endif

	actor playerRef = Game.GetPlayer()
    __trackingStarted = true

;     Debug.Trace("WEREWOLF: Race swap done; starting tracking and effects.")
    
    ; take all the player's stuff (since he/she can't use it anyway)
    ; Game.GetPlayer().RemoveAllItems(LycanStash)
	playerRef.UnequipAll()
    playerRef.EquipItem(WolfSkinFXArmor, False, True)

    ;Add Blood Effects
    ;FeedBloodVFX.Play(Game.GetPlayer())

    ; make everyone hate you
    playerRef.SetAttackActorOnSight(true)

    ; alert anyone nearby that they should now know the player is a werewolf
    Game.SendWereWolfTransformation()

    playerRef.AddToFaction(PlayerWerewolfFaction)
    playerRef.AddToFaction(WerewolfFaction)
    int cfIndex = 0
    while (cfIndex < CrimeFactions.GetSize())
;         Debug.Trace("WEREWOLF: Setting enemy flag on " + CrimeFactions.GetAt(cfIndex))
        (CrimeFactions.GetAt(cfIndex) as Faction).SetPlayerEnemy()
        cfIndex += 1
    endwhile

    ; but they also don't know that it's you
    Game.SetPlayerReportCrime(false)

    ; recalc times
    __durationWarningTime = RealTimeSecondsToGameTimeDays(DurationWarningTimeSeconds)
    __feedExtensionTime   = RealTimeSecondsToGameTimeDays(FeedExtensionTimeSeconds)
    __gorgeExtensionTime   = RealTimeSecondsToGameTimeDays(DLC1GorgingDurationSeconds)

    ; unequip magic
    Spell left = playerRef.GetEquippedSpell(0)
    Spell right = playerRef.GetEquippedSpell(1)
    Spell power = playerRef.GetEquippedSpell(2)
    Shout voice = playerRef.GetEquippedShout()
    if (left != None)
        playerRef.UnequipSpell(left, 0)
    endif
    if (right != None)
        playerRef.UnequipSpell(right, 1)
    endif
    if (power != None)
        ; some players are overly clever and sneak a power equip between casting
        ;  beast form and when we rejigger them there. this will teach them.
;         Debug.Trace("WEREWOLF: " + power + " was equipped; removing.")
        playerRef.UnequipSpell(power, 2)
    else
;         Debug.Trace("WEREWOLF: No power equipped.")
    endif
    if (voice != None)
        ; same deal here, but for shouts
;         Debug.Trace("WEREWOLF: " + voice + " was equipped; removing.")
        playerRef.UnequipShout(voice)
 ;   else
;         Debug.Trace("WEREWOLF: No shout equipped.")
    endif

    ; but make up for it by giving you the sweet howl
    CurrentHowlWord1 = (CompanionsTrackingQuest as CompanionsHousekeepingScript).CurrentHowlWord1
    CurrentHowlWord2 = (CompanionsTrackingQuest as CompanionsHousekeepingScript).CurrentHowlWord2
    CurrentHowlWord3 = (CompanionsTrackingQuest as CompanionsHousekeepingScript).CurrentHowlWord3
    CurrentHowl = (CompanionsTrackingQuest as CompanionsHousekeepingScript).CurrentHowl

    Game.UnlockWord(CurrentHowlWord1)
    Game.UnlockWord(CurrentHowlWord2)
    Game.UnlockWord(CurrentHowlWord3)
    playerRef.AddShout(CurrentHowl)
    playerRef.EquipShout(CurrentHowl)

    ; and some rad claws
    int playerLevel = playerRef.GetLevel()
    if     (playerLevel < 11)
        playerRef.AddSpell(PlayerWerewolfLvl10AndBelowAbility, false)
    elseif (playerLevel < 16)
        playerRef.AddSpell(PlayerWerewolfLvl15AndBelowAbility, false)
    elseif (playerLevel < 21)
        playerRef.AddSpell(PlayerWerewolfLvl20AndBelowAbility, false)
    elseif (playerLevel < 26)
        playerRef.AddSpell(PlayerWerewolfLvl25AndBelowAbility, false)
    elseif (playerLevel < 31)
        playerRef.AddSpell(PlayerWerewolfLvl30AndBelowAbility, false)
    elseif (playerLevel < 36)
        playerRef.AddSpell(PlayerWerewolfLvl35AndBelowAbility, false)
    elseif (playerLevel < 41)
        playerRef.AddSpell(PlayerWerewolfLvl40AndBelowAbility, false)
    elseif (playerLevel < 46)
        playerRef.AddSpell(PlayerWerewolfLvl45AndBelowAbility, false)
    else
        playerRef.AddSpell(PlayerWerewolfLvl50AndOverAbility, false)
    endif

    ; calculate when the player turns back into a pumpkin
    float currentTime = GameDaysPassed.GetValue()
    float regressTime = currentTime + RealTimeSecondsToGameTimeDays(StandardDurationSeconds)
    PlayerWerewolfShiftBackTime.SetValue(regressTime)
;     Debug.Trace("WEREWOLF: Current day -- " + currentTime)
;     Debug.Trace("WEREWOLF: Player will turn back at day " + regressTime)

    ; increment stats
    Game.IncrementStat("Werewolf Transformations")

    ; set us up to check when we turn back
    RegisterForUpdate(5.0)

    SetCurrentStageID(10) ; we're done with the transformation handling
EndFunction


Event OnUpdate()
    if (Untimed)
        return
    endif
;    Debug.Trace("WEREWOLF: NumWerewolfPerks = " + Game.QueryStat("NumWerewolfPerks"))
    if Game.QueryStat("NumWerewolfPerks") >= DLC1WerewolfMaxPerks.Value
;        debug.trace("WEREWOLF: achievement granted")
        Game.AddAchievement(57)
    endif

    float currentTime = GameDaysPassed.GetValue()
    float regressTime = PlayerWerewolfShiftBackTime.GetValue()

    if (  (currentTime >= regressTime) && (!Game.GetPlayer().IsInKillMove()) && !__tryingToShiftBack )
        UnregisterForUpdate()
        SetCurrentStageID(100) ; time to go, buddy
        return
    endif

    if (currentTime >= regressTime - __durationWarningTime)
        if (GetCurrentStageID() == 10)
            SetCurrentStageID(20)  ; almost there
            return
        endif
    endif

;     Debug.Trace("WEREWOLF: Checking, still have " + GameTimeDaysToRealTimeSeconds(regressTime - currentTime) + " seconds to go.")
EndEvent

Function SetUntimed(bool untimedValue)
    Untimed = untimedValue
    if (Untimed)
        UnregisterForUpdate()
    endif
EndFunction

; called from stage 11
Function Feed(Actor victim)
;    Debug.Trace("WEREWOLF: start newShiftTime = " + GameTimeDaysToRealTimeSeconds(PlayerWerewolfShiftBackTime.GetValue()) + ", __feedExtensionTime = " + GameTimeDaysToRealTimeSeconds(__feedExtensionTime))
    float newShiftTime = PlayerWerewolfShiftBackTime.GetValue() + __feedExtensionTime / 2.0
    if victim.HasKeyword(ActorTypeNPC)
        newShiftTime = newShiftTime + __feedExtensionTime / 2.0
;        Debug.Trace("WEREWOLF: victim is NPC")
    endif
;    Debug.Trace("WEREWOLF: default newShiftTime = " + GameTimeDaysToRealTimeSeconds(newShiftTime) + ", __feedExtensionTime = " + GameTimeDaysToRealTimeSeconds(__feedExtensionTime))
	actor playerRef = Game.GetPlayer()
    if playerRef.HasPerk(DLC1GorgingPerk) == 1
        newShiftTime = newShiftTime + __GorgeExtensionTime / 2.0
        if victim.HasKeyword(ActorTypeNPC)
            newShiftTime = newShiftTime + __GorgeExtensionTime / 2.0
        endif
    endif
    playerRef.PlayIdle(SpecialFeeding)
    
    ;This is for adding a spell that simulates bleeding
    BleedingFXSpell.Cast(victim,victim)
    
    if (!C03Rampage.IsRunning())
        PlayerWerewolfShiftBackTime.SetValue(newShiftTime)
        PlayerWerewolfFeedMessage.Show()
        FeedBoost.Cast(playerRef)
        ; victim.SetActorValue("Variable08", 100)
;         Debug.Trace("WEREWOLF: Player feeding -- new regress day is " + newShiftTime)
    endif
    SetCurrentStageID(10)
EndFunction


; called from stage 20
Function WarnPlayer()
;     Debug.Trace("WEREWOLF: Player about to transform back.")
    WerewolfWarn.Apply()
EndFunction


; called from stage 100
Function ShiftBack()
    __tryingToShiftBack = true

	actor playerRef = Game.GetPlayer()
    while (playerRef.GetAnimationVariableBool("bIsSynced"))
;         Debug.Trace("WEREWOLF: Waiting for synced animation to finish...")
        Utility.Wait(0.1)
    endwhile
;     Debug.Trace("WEREWOLF: Sending transform event to turn player back to normal.")

    __shiftingBack = false
    ; RegisterForAnimationEvent(Game.GetPlayer(), "TransformToHuman")
    ; Game.GetPlayer().PlayIdle(WerewolfTransformBack)
    ; Utility.Wait(10)
    ActuallyShiftBackIfNecessary()
EndFunction

Event OnAnimationEvent(ObjectReference akSource, string asEventName)
    if (asEventName == "TransformToHuman")
        ActuallyShiftBackIfNecessary()
    endif
EndEvent

Function ActuallyShiftBackIfNecessary()
    if (__shiftingBack)
        return
    endif
	actor playerRef = Game.GetPlayer()

    __shiftingBack = true

;     Debug.Trace("WEREWOLF: Player returning to normal.")

    Game.SetInCharGen(true, true, false)

    UnRegisterForAnimationEvent(playerRef, "TransformToHuman")
    UnRegisterForUpdate() ; just in case

    if (playerRef.IsDead())
;         Debug.Trace("WEREWOLF: Player is dead; bailing out.")
        return
    endif

    ;Remove Blood Effects
    ;FeedBloodVFX.Stop(Game.GetPlayer())

    ; imod
    WerewolfChange.Apply()
    WerewolfIMODSound.Play(playerRef)

    ; get rid of your summons if you have any
    int count = 0
    while (count < WerewolfDispelList.GetSize())
        Spell gone = WerewolfDispelList.GetAt(count) as Spell
        if (gone != None)
;             Debug.Trace("WEREWOLF: Dispelling " + gone)
            playerRef.DispelSpell(gone)
        endif
        count += 1
    endwhile

    ; make sure the transition armor is gone. We RemoveItem here, because the SetRace stored all equipped items
    ; at that time, and we equip this armor prior to setting the player to a beast race. When we switch back,
    ; if this were still in the player's inventory it would be re-equipped.
    playerRef.RemoveItem(WolfSkinFXArmor, 1, True)

    ; clear out perks/abilities
    ;  (don't need to do this anymore since it's on from gamestart)
    ; Game.GetPlayer().RemovePerk(PlayerWerewolfFeed)

    ; make sure your health is reasonable before turning you back
    ; Game.GetPlayer().GetActorBase().SetInvulnerable(true)
    playerRef.SetGhost()
    float currHealth = playerRef.GetActorValue("health")
    if (currHealth < 102)
;         Debug.Trace("WEREWOLF: Player's health is only " + currHealth + "; restoring.")
        playerRef.RestoreActorValue("health", 101 - currHealth)
    endif

    ; change you back
;     Debug.Trace("WEREWOLF: Setting race " + (CompanionsTrackingQuest as CompanionsHousekeepingScript).PlayerOriginalRace + " on " + Game.GetPlayer())
    playerRef.SetRace((CompanionsTrackingQuest as CompanionsHousekeepingScript).PlayerOriginalRace)
     ; release the player controls
;     Debug.Trace("WEREWOLF: Restoring camera controls")
    Game.EnablePlayerControls(abMovement = false, abFighting = false, abCamSwitch = true, abLooking = false, abSneaking = false, abMenu = false, abActivate = false, abJournalTabs = false, aiDisablePOVType = 1)
    Game.ShowFirstPersonGeometry(true)

    ; no more howling for you
    playerRef.UnequipShout(CurrentHowl)
    playerRef.RemoveShout(CurrentHowl)

    ; or those claws
    playerRef.RemoveSpell(PlayerWerewolfLvl10AndBelowAbility)
    playerRef.RemoveSpell(PlayerWerewolfLvl15AndBelowAbility)
    playerRef.RemoveSpell(PlayerWerewolfLvl20AndBelowAbility)
    playerRef.RemoveSpell(PlayerWerewolfLvl25AndBelowAbility)
    playerRef.RemoveSpell(PlayerWerewolfLvl30AndBelowAbility)
    playerRef.RemoveSpell(PlayerWerewolfLvl35AndBelowAbility)
    playerRef.RemoveSpell(PlayerWerewolfLvl40AndBelowAbility)
    playerRef.RemoveSpell(PlayerWerewolfLvl45AndBelowAbility)
    playerRef.RemoveSpell(PlayerWerewolfLvl50AndOverAbility)

    ; gimme back mah stuff
    ; LycanStash.RemoveAllItems(Game.GetPlayer())

    ; people don't hate you no more
    playerRef.SetAttackActorOnSight(false)
    playerRef.RemoveFromFaction(PlayerWerewolfFaction)
    playerRef.RemoveFromFaction(WerewolfFaction)
    count = 0
    while (count < CrimeFactions.GetSize())
;         Debug.Trace("WEREWOLF: Removing enemy flag from " + CrimeFactions.GetAt(cfIndex))
        (CrimeFactions.GetAt(count) as Faction).SetPlayerEnemy(false)
        count += 1
    endwhile

    ; and you're now recognized
    Game.SetPlayerReportCrime(true)

    ; alert anyone nearby that they should now know the player is a werewolf
    Game.SendWereWolfTransformation()

    ; give the set race event a chance to come back, otherwise shut us down
    Utility.Wait(5.0)
    Shutdown()
EndFunction

Function Shutdown()
    if (__shuttingDown)
        return
    endif

    __shuttingDown = true

    Game.GetPlayer().GetActorBase().SetInvulnerable(false)
    Game.GetPlayer().SetGhost(false)

    Game.SetBeastForm(False)
    Game.EnableFastTravel(True)

    Game.SetInCharGen(false, false, false)

    Stop()
EndFunction

Float Property DLC1GorgingDurationSeconds  Auto  

Perk Property DLC1GorgingPerk  Auto  

Perk Property DLC1SavageFeedingPerk  Auto  

Keyword Property ActorTypeNPC  Auto  

Perk Property DLC1AnimalVigor  Auto  

GlobalVariable Property DLC1WerewolfTotalPerksEarned  Auto  

GlobalVariable Property DLC1WerewolfMaxPerks  Auto  
