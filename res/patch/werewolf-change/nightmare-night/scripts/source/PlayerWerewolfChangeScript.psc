Scriptname PlayerWerewolfChangeScript extends Quest  
{Main Script for Player Werewolf}

int Property INTEGRITY_CHECK = 0 Auto
{ Set to 1 in the .esp, if this Script or the .esp Quest Object is overriden, accessing this will return 0 }

; =============================== VANILLA PROPERTIES
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

Quest Property C03Rampage auto

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

; =============================== VANILLA PROPERTIES (DLC1)
Float Property DLC1GorgingDurationSeconds  Auto  
{How long (in real seconds) that feeding on Creatures extends werewolf time}

Keyword Property ActorTypeNPC Auto  

Perk Property DLC1GorgingPerk Auto  
Perk Property DLC1SavageFeedingPerk Auto  
Perk Property DLC1AnimalVigor Auto

GlobalVariable Property DLC1WerewolfTotalPerksEarned Auto
GlobalVariable Property DLC1WerewolfMaxPerks Auto

; =============================== NIGHTMARE NIGHT PROPERTIES
NNLunarTransform Property Lunar Auto
GlobalVariable Property LunarPhase Auto
Message Property LunarExtendTime Auto

GlobalVariable Property IsWerewolf Auto
Race Property DLC2WerebearRace Auto
Armor Property BearSkinFXArmor Auto
Formlist Property BearFXArmorList Auto
Formlist Property WolfFXArmorList Auto

Keyword Property NightmareRequiem Auto
Spell Property NightmaresRequiemDispel Auto

DefaultObjectManager DefObjMananager
Form RIWR ; Werewolf Race
Form RIVR ; Vampire Race
Form RIVS ; Vampire Spells

FormList Property WerewolfAbilities Auto
{List of all WW Abilities that should be displayed in the Ability Selection Menu}
Shout Property HowlTerror Auto
WordOfPower Property HowlTerrorWord1 Auto
WordOfPower Property HowlTerrorWord2 Auto
WordOfPower Property HowlTerrorWord3 Auto
Shout Property HowlSummon Auto
WordOfPower Property HowlSummonWord1 Auto
WordOfPower Property HowlSummonWord2 Auto
WordOfPower Property HowlSummonWord3 Auto
Shout Property HowlLiftDetect Auto
WordOfPower Property HowlLiftDetectWord1 Auto
; WordOfPower Property HowlLiftDetectWord2 Auto
; WordOfPower Property HowlLiftDetectWord3 Auto

GlobalVariable Property HungerLevel Auto
GlobalVariable Property LastFeeding Auto
GlobalVariable Property Feedings Auto

Perk Property Wrath Auto
Perk Property NightmareNight Auto

GlobalVariable Property FrenzyStacks Auto
GlobalVariable Property DefPenalty Auto
GlobalVariable Property AtkBonus Auto
GlobalVariable Property SpdBonus Auto
MagicEffect Property BloodFrenzyEffect Auto
Spell Property BloodFrenzySpell Auto
Perk Property BloodFrenzyPerk Auto

Spell Property DestroyObjSpell Auto

EffectShader Property TransformFX02 Auto

Shout LastEquippedShout
Spell LastEquippedPower

Form WerebeastFXArmor
Form Property TransitionArmor Auto Hidden
Race PlayerRace

Keyword SLActive

; =============================================================
; =============================== FRENZY
; =============================================================

Function SetUpFrenzy()
  ; Debug.Trace("[NIGHTMARE NIGHT] Setting up Frenzy")
  If(Game.GetPlayer().HasPerk(Wrath))
    FrenzyStacks.SetValueInt(5)
    SetFrenzyStats(5)
    CastFrenzy()
  Else
    FrenzyStacks.SetValueInt(0)
  EndIf
EndFunction

Function ApplyFrenzy(int aiLevelUp)
  ; Debug.Trace("[NIGHTMARE NIGHT] Applying Frenzy, adding " + aiLevelUp + " levels")
  int level = FrenzyStacks.GetValueInt() + aiLevelUp
  If level > 10
    level = 10
  EndIf
  FrenzyStacks.SetValueInt(level)
  SetFrenzyStats(level)
  CastFrenzy()
EndFunction

Function SetFrenzyStats(int aiLevel)
  ; Debug.Trace("[NIGHTMARE NIGHT] Setting Frenzy to Level " + aiLevel)
  int ww = IsWerewolf.GetValueInt()
  float dmg = (AtkBonus.Value * (1 - 0.25 * ww)) * aiLevel
  float spd = (SpdBonus.Value * (1 + 1.40 * ww)) * aiLevel
  float def = DefPenalty.Value * aiLevel
  ; Debug.Trace("[NIGHTMARE NIGHT] - Blood Frenzy Stats Update - damage = " + dmg + "; speed = " + spd + "; defense = " + def)

  BloodFrenzyPerk.SetNthEntryValue(0, 1, dmg) ; Damage
  BloodFrenzyPerk.SetNthEntryValue(2, 1, spd) ; Speed
  BloodFrenzyPerk.SetNthEntryValue(4, 0, def) ; Inc Dmg Physical
  BloodFrenzyPerk.SetNthEntryValue(5, 0, def) ; Inc Dmg Magical
EndFunction

Function CastFrenzy()
  ; Debug.Trace("[NIGHTMARE NIGHT] Casting Frenzy")
  If(SKSE.GetPluginVersion("NightmareNight") == -1)
    ; LE compatiblity, using Flash to start the timer
    ; SendModEvent("NightmareNightFrenzyStart", FrenzyStacks.Value, BloodFrenzySpell.GetNthEffectDuration(0))
    Debug.MessageBox("[Nightmare Night]\n\nERROR:\nMissing NightmareNight.dll in your game")
    return
  EndIf
  BloodFrenzySpell.Cast(Game.GetPlayer())
EndFunction

; =============================================================
; =============================== UTILITY
; =============================================================
float Function RealTimeSecondsToGameTimeDays(float realtime)
  float scaledSeconds = realtime * TimeScale.Value
  return scaledSeconds / (60 * 60 * 24)
EndFunction

float Function GameTimeDaysToRealTimeSeconds(float gametime)
  float gameSeconds = gametime * (60 * 60 * 24)
  return (gameSeconds / TimeScale.Value)
EndFunction

Function SetObjectManagerObjects()
  If(IsWerewolf.Value == 1)
    DefObjMananager.SetForm("RIVR", WerewolfBeastRace)
  Else
    DefObjMananager.SetForm("RIWR", DLC2WerebearRace)
    DefObjMananager.SetForm("RIVR", DLC2WerebearRace)
  EndIf
  DefObjMananager.SetForm("RIVS", WerewolfAbilities)
EndFunction

float Function GetTimeFollowingMorning()
  float currentTime = GameDaysPassed.GetValue()
  float currentDay = Math.floor(currentTime)
  float currentHour = currentTime - currentDay
  float five = 0.2083 ; = 5.00 / 24.00
  float nextmorning = currentDay + five
  If(currentHour > five) ; If current day is already past the deadline, set to the next day
    nextmorning += 1.0
  EndIf
  return nextmorning
EndFunction

; =============================================================
; =============================== TRANSFORMATION
; =============================================================
; Called on Quest Start (read: when WW Transform is called)
Function PrepShift()
  ; Debug.Trace("WEREWOLF: Prepping shift...")
  ; Cache Race..
  Actor Player = Game.GetPlayer()
  PlayerRace = Player.GetRace()
  ; RCS
  Race OrignialRace = RaceCompatibility.GetRaceByVampireRace(PlayerRace)
  If(OrignialRace != None)
    PlayerRace = OrignialRace
  EndIf
  ; Debug.Trace("NIGHTMARE NIGHT - Player Original Race = " + PlayerRace)
  ; Set up Default Object Manager Objects..
  DefObjMananager = Game.GetFormFromFile(0x00000031, "Skyrim.esm") as DefaultObjectManager
  RIWR = DefObjMananager.GetForm("RIWR") ; Werewolf Race
  RIVR = DefObjMananager.GetForm("RIVR") ; Vampire Race
  RIVS = DefObjMananager.GetForm("RIVS") ; Vampire Spells
  SetObjectManagerObjects()

  ; sets up the UI restrictions
  Game.SetBeastForm(True)
  Game.EnableFastTravel(False)

  ; set up perks/abilities
  ; (don't need to do this anymore since it's on from gamestart)
  ; Game.GetPlayer().AddPerk(PlayerWerewolfFeed)

  ; screen effect
  WerewolfChange.Apply()
  WerewolfIMODSound.Play(Player)

  ; end Nightmares Requiem if running
  If(Player.HasMagicEffectWithKeyword(NightmareRequiem))
    NightmaresRequiemDispel.Cast(Player)
  EndIf

  ; get rid of your summons
  int count = 0
  while (count < WerewolfDispelList.GetSize())
    Spell gone = WerewolfDispelList.GetAt(count) as Spell
    if (gone != None)
      Player.DispelSpell(gone)
    endif
    count += 1
  endwhile

  Game.DisablePlayerControls(abMovement = false, abFighting = false, abCamSwitch = true, abMenu = false, abActivate = false, abJournalTabs = false, aiDisablePOVType = 1)
  Game.ForceThirdPerson()
  Game.ShowFirstPersonGeometry(false)

  ; Disable Magicka Bar
  UI.SetNumber("HUD Menu", "_root.HUDMovieBaseInstance.Magica._alpha", 0)

  ; Misc stuff
  SLActive = Keyword.GetKeyword("SexLabActive")
EndFunction

; Called from Stage1 (e.g. when Transform Script completes)
Function InitialShift()
  ; Debug.Trace("WEREWOLF: Player beginning transformation.")
  WerewolfWarn.Apply()
  if (Game.GetPlayer().IsDead())
    ; Debug.Trace("WEREWOLF: Player is dead; bailing out.")
    return
  endif
  ; actual switch
  If(IsWerewolf.Value == 1)
    Game.GetPlayer().SetRace(WerewolfBeastRace)
  Else
    Game.GetPlayer().SetRace(DLC2WerebearRace)
  EndIf
EndFunction

; Called when the Race is fully donw switching
Function StartTracking()
  if (__trackingStarted)
    return
  endif
  __trackingStarted = true

  ; Debug.Trace("WEREWOLF: Race swap done; starting tracking and effects.")
  Actor Player = Game.GetPlayer()
  ; take all the player's stuff (since he/she can't use it anyway)
  ; Game.GetPlayer().RemoveAllItems(LycanStash)
  Player.UnequipAll()
  If(IsWerewolf.Value == 1)
    If(Lunar.MCM.WolfIndex)
      WerebeastFXArmor = WolfFXArmorList.GetAt(Lunar.MCM.WolfIndex - 1)
    Else
      WerebeastFXArmor = WolfSkinFXArmor
    EndIf
  Else
    If(Lunar.MCM.BearIndex)
      WerebeastFXArmor = BearFXArmorList.GetAt(Lunar.MCM.BearIndex - 1)
    Else
      WerebeastFXArmor = BearSkinFXArmor
    EndIf
  EndIf
  Player.EquipItem(WerebeastFXArmor, true, true)

  ; Add Blood Effects
  ; FeedBloodVFX.Play(Game.GetPlayer())

  ; make everyone hate you
  Player.SetAttackActorOnSight(true)

  ; alert anyone nearby that they should now know the player is a werewolf
  Game.SendWereWolfTransformation()

  Player.AddToFaction(PlayerWerewolfFaction)
  Player.AddToFaction(WerewolfFaction)
  int cfIndex = 0
  while (cfIndex < CrimeFactions.GetSize())
    ; Debug.Trace("WEREWOLF: Setting enemy flag on " + CrimeFactions.GetAt(cfIndex))
    (CrimeFactions.GetAt(cfIndex) as Faction).SetPlayerEnemy()
    cfIndex += 1
  endwhile

  ; but they also don't know that it's you
  Game.SetPlayerReportCrime(false)

  ; recalc times
  __durationWarningTime = RealTimeSecondsToGameTimeDays(DurationWarningTimeSeconds)
  __feedExtensionTime = RealTimeSecondsToGameTimeDays(FeedExtensionTimeSeconds)
  __gorgeExtensionTime = RealTimeSecondsToGameTimeDays(DLC1GorgingDurationSeconds)

  ; unequip magic
  Spell left = Player.GetEquippedSpell(0)
  Spell right = Player.GetEquippedSpell(1)
  Spell power = Player.GetEquippedSpell(2)
  Shout voice = Player.GetEquippedShout()
  if (left != None)
    Player.UnequipSpell(left, 0)
  endif
  if (right != None)
    Player.UnequipSpell(right, 1)
  endif
  if (power != None)
    ; some players are overly clever and sneak a power equip between casting
    ; beast form and when we rejigger them there. this will teach them.
    ; Debug.Trace("WEREWOLF: " + power + " was equipped; removing.")
    Player.UnequipSpell(power, 2)
  else
    ; Debug.Trace("WEREWOLF: No power equipped.")
  endif
  if (voice != None)
    ; same deal here, but for shouts
    ; Debug.Trace("WEREWOLF: " + voice + " was equipped; removing.")
    Player.UnequipShout(voice)
  else
    ; Debug.Trace("WEREWOLF: No shout equipped.")
  endif

  ; but make up for it by giving you the sweet howl
  ; Totem Buffs are handled by a new Global. We no logner need the Companion Variables here, still want to add the shouts though I guess
  Player.AddShout(HowlTerror)
  Game.UnlockWord(HowlTerrorWord1)
  Game.UnlockWord(HowlTerrorWord2)
  Game.UnlockWord(HowlTerrorWord3)

  Player.AddShout(HowlSummon)
  Game.UnlockWord(HowlSummonWord1)
  Game.UnlockWord(HowlSummonWord2)
  Game.UnlockWord(HowlSummonWord3)

  Player.AddShout(HowlLiftDetect)
  Game.UnlockWord(HowlLiftDetectWord1)
  ; Game.UnlockWord(HowlLiftDetectWord2)
  ; Game.UnlockWord(HowlLiftDetectWord3)

  ; if the player had a power or shout equipped beforre transforming back, do them a favor and equip it back on :>
  If(LastEquippedShout != none)
    Player.EquipShout(LastEquippedShout)
  ElseIf(LastEquippedPower != none)
    Player.EquipSpell(LastEquippedPower, 2)
  EndIf

  ; and some rad claws
  int playerLevel = Player.GetLevel()
  if (playerLevel <= 10)
    Player.AddSpell(PlayerWerewolfLvl10AndBelowAbility, false)
  elseif (playerLevel <= 15)
    Player.AddSpell(PlayerWerewolfLvl15AndBelowAbility, false)
  elseif (playerLevel <= 20)
    Player.AddSpell(PlayerWerewolfLvl20AndBelowAbility, false)
  elseif (playerLevel <= 25)
    Player.AddSpell(PlayerWerewolfLvl25AndBelowAbility, false)
  elseif (playerLevel <= 30)
    Player.AddSpell(PlayerWerewolfLvl30AndBelowAbility, false)
  elseif (playerLevel <= 35)
    Player.AddSpell(PlayerWerewolfLvl35AndBelowAbility, false)
  elseif (playerLevel <= 40)
    Player.AddSpell(PlayerWerewolfLvl40AndBelowAbility, false)
  elseif (playerLevel <= 45)
    Player.AddSpell(PlayerWerewolfLvl45AndBelowAbility, false)
  else
    Player.AddSpell(PlayerWerewolfLvl50AndOverAbility, false)
  endif

  ; set moonphase for Nightmare Passives
  float g = GameDaysPassed.Value
  g = (g - g as int) * 24
  If(g < 19.00 && g > 5.00)
    LunarPhase.Value = -1
  Else
    LunarPhase.Value = Lunar.GetMoonPhase() as int
  EndIf

  ; calculate when the player turns back into a pumpkin
  float currentTime = GameDaysPassed.GetValue()
  float currentHour = currentTime - (currentTime as int)
  ; Debug.Trace("NIGHTMARE NIGHT - currentTime = " + currentTime + " currentHour = " + currentHour)
  ; Papyrus is incapable to divide 2 constants...
  bool nighttime = currentHour > 0.8333 ;/ 20.00 / 24.00 /; || currentHour < 0.0833 ; 2.00 / 24.00
  ; Debug.Trace("NIGHTMARE NIGHT - nighttime = " + nighttime)
  float regressTime
  If(nighttime && (Lunar.LunarTransform || Player.HasPerk(NightmareNight)))
    ; If this is a Lunar Shift or Nightmare Night at Night, override the default Duration. Stay transformed until 5am
    regressTime = GetTimeFollowingMorning()
  Else
    regressTime = currentTime + RealTimeSecondsToGameTimeDays(StandardDurationSeconds)
  EndIf
  ; Debug.Trace("NIGHTMARE NIGHT - WEREWOLF: currentTime = " + currentTime)
  ; Debug.Trace("NIGHTMARE NIGHT - WEREWOLF: regressTime = " + regressTime)
  PlayerWerewolfShiftBackTime.SetValue(regressTime)

  ; increment stats
  Game.IncrementStat("Werewolf Transformations")
  ; set us up to check when we turn back
  RegisterForUpdate(5)
  ; we're done with the transformation handling
  SetStage(10)
  ; add Frenzy Lv5 if player has Wrath
  SetUpFrenzy()
  ; and quick spell for destroying webs..
  RegisterForAnimationEvent(Player, "WeaponSwing")
  RegisterForAnimationEvent(Player, "WeaponLeftSwing")
EndFunction

; =============================================================
; =============================== WEREWOLF CYCLE
; =============================================================

Event OnUpdate()
  If(Untimed)
    return
  EndIf

  Actor Player = Game.GetPlayer()
  If (Player.HasPerk(Wrath) && Player.HasMagicEffect(BloodFrenzyEffect))
    return
  ElseIf (SLActive && Player.HasKeyword(SLActive))
    return
  EndIf

  ; Debug.Trace("WEREWOLF: NumWerewolfPerks = " + Game.QueryStat("NumWerewolfPerks") + "/" + DLC1WerewolfMaxPerks.Value)
  If(Game.QueryStat("NumWerewolfPerks") >= DLC1WerewolfMaxPerks.Value)
    debug.trace("WEREWOLF: achievement granted")
    ; Game.AddAchievement(57)
  EndIf

  float currentTime = GameDaysPassed.GetValue()
  float regressTime = PlayerWerewolfShiftBackTime.GetValue()
  If(GetStageDone(20) == 1)
    If(currentTime >= regressTime && !Player.IsInKillMove() && !__tryingToShiftBack)
      UnregisterForUpdate()
      SetStage(100) ; time to go, buddy
    EndIf
  ElseIf(currentTime >= regressTime - __durationWarningTime)
    SetStage(20) ; almost there
  EndIf

  ; Debug.Trace("WEREWOLF: Checking, still have " + GameTimeDaysToRealTimeSeconds(regressTime - currentTime) + " seconds to go.")
EndEvent

Function SetUntimed(bool untimedValue)
  Untimed = untimedValue
  if (Untimed)
    UnregisterForUpdate()
  endif
EndFunction

; The Default Object Manager Objects are apparently resettet after a Gameload
; I guess thats a good thing but we dont want that to happen while still transformed
Function PlayerReloadGame()
  SetObjectManagerObjects()
EndFunction

; Called by Lunar Transform if were shifted while a Lunar Shift triggers. Extending duration of the Shift till dawn
Function ExtendToDawn()
  float regressTime = GetTimeFollowingMorning()
  PlayerWerewolfShiftBackTime.SetValue(regressTime)
  LunarExtendTime.Show()
  ; Debug.Trace("NIGHTMARE NIGHT - WEREWOLF: Current day -- " + currentTime)
  ; Debug.Trace("NIGHTMARE NIGHT - WEREWOLF: Player will turn back at day " + regressTime)
EndFunction

;/ =======================================
  In NN, feeding Restores Health, extends Transformation Time(?)
  and Sates
  Healing is handled in its own Spell, see NNWerewolfFeed.psc
======================================= /;
Function Feed(Actor victim)
  ; Debug.Trace("NIGHTMARE NIGHT: Feeding Start -- Current Shift Time = " + PlayerWerewolfShiftBackTime.Value + ", __feedExtensionTime = " + GameTimeDaysToRealTimeSeconds(__feedExtensionTime))
  Actor player = Game.GetPlayer()
  player.PlayIdle(SpecialFeeding)
  ; This is for adding a spell that simulates bleeding
  BleedingFXSpell.Cast(victim, victim)
  ; Extend Transformation Time
  If(!C03Rampage.IsRunning())
    float addShiftTime = __feedExtensionTime
    If(player.HasPerk(DLC1GorgingPerk))
      addShiftTime += __GorgeExtensionTime
    EndIf
    If(!victim.HasKeyword(ActorTypeNPC))
      ; Debug.Trace("NIGHTMARE NIGHT - Feeding on Creature, cutting Transformation Time Gain in Half")
      addShiftTime /= 2
    EndIf
    PlayerWerewolfShiftBackTime.Value += addShiftTime
    PlayerWerewolfFeedMessage.Show()
    FeedBoost.Cast(player) ; All the Healing & Feeding Buffs are handled in this Script. This also resets Blood Frenzy
    ; Debug.Trace("NIGHTMARE NIGHT: Player feeding -- new regress day is " + PlayerWerewolfShiftBackTime.Value)
  EndIf
  ; Progress Hunger
  ; Feedings.Value += 1
  ; LastFeeding.Value = GameDaysPassed.Value
  ; If(Feedings.Value > Math.pow(2, HungerLevel.Value + 1))
  ;   ; Debug.Trace("NIGHTMARE NIGHT: Progressing Player Hunger -- Level = " + HungerLevel.Value + ", Feedings = " + Feedings.Value)
  ;   HungerLevel.Value += 1
  ;   Feedings.Value = 0
  ; EndIf
  SetStage(10)
EndFunction

; =============================================================
; =============================== TRANSFORMATION END
; =============================================================
; called from stage 20
Function WarnPlayer()
;   Debug.Trace("WEREWOLF: Player about to transform back.")
  WerewolfWarn.Apply()
EndFunction

; called from stage 100
Function ShiftBack()
  __tryingToShiftBack = true
  while (Game.GetPlayer().GetAnimationVariableBool("bIsSynced"))
    ; Debug.Trace("WEREWOLF: Waiting for synced animation to finish...")
    Utility.Wait(0.1)
  endwhile
  ; Debug.Trace("WEREWOLF: Sending transform event to turn player back to normal.")
  __shiftingBack = false
  ; RegisterForAnimationEvent(Game.GetPlayer(), "TransformToHuman")
  ; Game.GetPlayer().PlayIdle(WerewolfTransformBack)
  ; Utility.Wait(10)
  ActuallyShiftBackIfNecessary()
EndFunction

Event OnAnimationEvent(ObjectReference akSource, string asEventName)
  if (asEventName == "TransformToHuman")
    ActuallyShiftBackIfNecessary()
  ElseIf(asEventName == "WeaponSwing") || (asEventName == "WeaponLeftSwing")
    DestroyObjSpell.Cast(Game.GetPlayer(), none)
  endif
EndEvent

Function ActuallyShiftBackIfNecessary()
  if (__shiftingBack)
    return
  endif
  __shiftingBack = true
  ; Debug.Trace("WEREWOLF: Player returning to normal.")
  Game.SetInCharGen(true, true, false)

  Actor Player = Game.GetPlayer()
  
  UnRegisterForAnimationEvent(Player, "TransformToHuman")
  UnRegisterForUpdate() ; just in case

  if (Player.IsDead())
    ; Debug.Trace("WEREWOLF: Player is dead; bailing out.")
    return
  endif
  ; Remove Blood Effects
  ; FeedBloodVFX.Stop(Game.GetPlayer())
  ; imod
  WerewolfChange.Apply()
  WerewolfIMODSound.Play(Player)

  ; get rid of your summons if you have any
  int count = 0
  while (count < WerewolfDispelList.GetSize())
    Spell gone = WerewolfDispelList.GetAt(count) as Spell
    if (gone != None)
      ; Debug.Trace("WEREWOLF: Dispelling " + gone)
      Player.DispelSpell(gone)
    endif
    count += 1
  endwhile

  ; Dont have the player die now..
  Player.SetGhost()

  ; Bleedout Anim if enabled...
  If(Lunar.MCM.bTurnBackAnimation)
    Debug.SendAnimationEvent(Player, "bleedoutStart")
    Utility.Wait(2)
    TransformFX02.Play(Player)
    Utility.Wait(1)
  EndIf

  ; Reset Frenzy..
  Player.DispelSpell(BloodFrenzySpell)
  If(SKSE.GetPluginVersion("NightmareNight") == -1)
    SendModEvent("NightmareNightFrenzyEnd")
  EndIf

  ; make sure the transition armor is gone. We RemoveItem here, because the SetRace stored all equipped items
  ; at that time, and we equip this armor prior to setting the player to a beast race. When we switch back,
  ; if this were still in the player's inventory it would be re-equipped.
  ; Player.RemoveItem(WolfSkinFXArmor, 1, True)
  Player.RemoveItem(TransitionArmor, abSilent = true)

  ; clear out perks/abilities
  ; (don't need to do this anymore since it's on from gamestart)
  ; Game.GetPlayer().RemovePerk(PlayerWerewolfFeed)

  ; make sure your health is reasonable before turning you back
  ; Heal the Player to have at least 1Hp left before transforming back..
  float currHealth = Player.GetActorValue("health")
  float minHealth = 150.0 + (150 * Player.HasPerk(NightmareNight) as int)
  if (currHealth <= minHealth)
    ; Debug.Trace("WEREWOLF: Player's health is only " + currHealth + "; restoring.")
    Player.RestoreAV("health", minHealth - currHealth)
  endif
  ; change you back
  ; Debug.Trace("WEREWOLF: Setting race " + (CompanionsTrackingQuest as CompanionsHousekeepingScript).PlayerOriginalRace + " on " + Game.GetPlayer())
  ; Player.SetRace((CompanionsTrackingQuest as CompanionsHousekeepingScript).PlayerOriginalRace)
  Player.RemoveItem(WerebeastFXArmor, abSilent = true)
  Player.SetRace(PlayerRace)
  If(Lunar.MCM.bTurnBackNude)
    Player.UnequipAll()
  EndIf
  If(Lunar.MCM.bTurnBackStagger)
    Utility.Wait(0.7)
    Debug.SendAnimationEvent(Player, "staggerStart")
  EndIf

  ; release the player controls
  ; Debug.Trace("WEREWOLF: Restoring camera controls")
  Game.EnablePlayerControls(abMovement = false, abFighting = false, abCamSwitch = true, abLooking = false, abSneaking = false, abMenu = false, abActivate = false, abJournalTabs = false, aiDisablePOVType = 1)
  Game.ShowFirstPersonGeometry(true)

  ; Reset the Hack into the Vampire Ability Menu
	DefObjMananager.SetForm("RIWR", RIWR) ; Werewolf Race
	DefObjMananager.SetForm("RIVR", RIVR) ; Vampire Race
	DefObjMananager.SetForm("RIVS", RIVS) ; Vampire Spells

  ; cache currently equipped shout (lil QoL)
  LastEquippedShout = Player.GetEquippedShout()
  If(!LastEquippedShout) ; No Shout equipped.. but maybe an Ability?
    LastEquippedPower = Player.GetEquippedSpell(2)
  EndIf

  ; no more howling for you
  Player.RemoveShout(HowlTerror)
	Player.RemoveShout(HowlSummon)
	Player.RemoveShout(HowlLiftDetect)

  ; Game.GetPlayer().UnequipShout(CurrentHowl)
  ; Game.GetPlayer().RemoveShout(CurrentHowl)

  ; or those claws
  Player.RemoveSpell(PlayerWerewolfLvl10AndBelowAbility)
  Player.RemoveSpell(PlayerWerewolfLvl15AndBelowAbility)
  Player.RemoveSpell(PlayerWerewolfLvl20AndBelowAbility)
  Player.RemoveSpell(PlayerWerewolfLvl25AndBelowAbility)
  Player.RemoveSpell(PlayerWerewolfLvl30AndBelowAbility)
  Player.RemoveSpell(PlayerWerewolfLvl35AndBelowAbility)
  Player.RemoveSpell(PlayerWerewolfLvl40AndBelowAbility)
  Player.RemoveSpell(PlayerWerewolfLvl45AndBelowAbility)
  Player.RemoveSpell(PlayerWerewolfLvl50AndOverAbility)

  ; gimme back mah stuff
  ; LycanStash.RemoveAllItems(Game.GetPlayer())

  ; people don't hate you no more
  Player.SetAttackActorOnSight(false)
  Player.RemoveFromFaction(PlayerWerewolfFaction)
  Player.RemoveFromFaction(WerewolfFaction)
  int cfIndex = 0
  while (cfIndex < CrimeFactions.GetSize())
    ; Debug.Trace("WEREWOLF: Removing enemy flag from " + CrimeFactions.GetAt(cfIndex))
    (CrimeFactions.GetAt(cfIndex) as Faction).SetPlayerEnemy(false)
    cfIndex += 1
  endwhile

  ; and you're now recognized
  Game.SetPlayerReportCrime(true)
  ; alert anyone nearby that they should now know the player is a werewolf
  Game.SendWereWolfTransformation()
  ; Disable the FX stuff from the Animation here
  TransformFX02.Stop(Player)
  ; give the set race event a chance to come back, otherwise shut us down
  Utility.Wait(5)
  Shutdown()
EndFunction

Function Shutdown()
  if (__shuttingDown)
    return
  endif
  __shuttingDown = true

  Actor Player = Game.GetPlayer()
  Player.GetActorBase().SetInvulnerable(false)
  Player.SetGhost(false)

  Game.SetBeastForm(False)
  Game.EnableFastTravel(True)
  Game.SetInCharGen(false, false, false)

  Lunar.RegisterForUpdateGameTime(1)

  Stop()
EndFunction


; =============================================================
; =============================== VANILLA IMPLEMENTATION
; =============================================================
; =======================================
; Unused Properties, leaving them here in case someone1 else references them for w/e reason
Quest Property CompanionsTrackingQuest auto
Shout Property CurrentHowl auto
WordOfPower Property CurrentHowlWord1 auto
WordOfPower Property CurrentHowlWord2 auto
WordOfPower Property CurrentHowlWord3 auto


;/ =======================================
Replaced Functions

Function InitialShift()
;   Debug.Trace("WEREWOLF: Player beginning transformation.")

  WerewolfWarn.Apply()
  
  if (Game.GetPlayer().IsDead())
;   Debug.Trace("WEREWOLF: Player is dead; bailing out.")
  return
  endif

  ; actual switch
  Game.GetPlayer().SetRace(WerewolfBeastRace)
EndFunction
; Called when the Race is fully donw switching
Function StartTracking()
  if (__trackingStarted)
  return
  endif

  __trackingStarted = true

;   Debug.Trace("WEREWOLF: Race swap done; starting tracking and effects.")
  
  ; take all the player's stuff (since he/she can't use it anyway)
  ; Game.GetPlayer().RemoveAllItems(LycanStash)
  Game.GetPlayer().UnequipAll()
  Game.GetPlayer().EquipItem(WolfSkinFXArmor, False, True)

  ;Add Blood Effects
  ;FeedBloodVFX.Play(Game.GetPlayer())

  ; make everyone hate you
  Game.GetPlayer().SetAttackActorOnSight(true)

  ; alert anyone nearby that they should now know the player is a werewolf
  Game.SendWereWolfTransformation()

  Game.GetPlayer().AddToFaction(PlayerWerewolfFaction)
  Game.GetPlayer().AddToFaction(WerewolfFaction)
  int cfIndex = 0
  while (cfIndex < CrimeFactions.GetSize())
;   Debug.Trace("WEREWOLF: Setting enemy flag on " + CrimeFactions.GetAt(cfIndex))
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
  Spell left = Game.GetPlayer().GetEquippedSpell(0)
  Spell right = Game.GetPlayer().GetEquippedSpell(1)
  Spell power = Game.GetPlayer().GetEquippedSpell(2)
  Shout voice = Game.GetPlayer().GetEquippedShout()
  if (left != None)
  Game.GetPlayer().UnequipSpell(left, 0)
  endif
  if (right != None)
  Game.GetPlayer().UnequipSpell(right, 1)
  endif
  if (power != None)
  ; some players are overly clever and sneak a power equip between casting
  ;  beast form and when we rejigger them there. this will teach them.
;   Debug.Trace("WEREWOLF: " + power + " was equipped; removing.")
  Game.GetPlayer().UnequipSpell(power, 2)
  else
;   Debug.Trace("WEREWOLF: No power equipped.")
  endif
  if (voice != None)
  ; same deal here, but for shouts
;   Debug.Trace("WEREWOLF: " + voice + " was equipped; removing.")
  Game.GetPlayer().UnequipShout(voice)
  else
;   Debug.Trace("WEREWOLF: No shout equipped.")
  endif

  ; but make up for it by giving you the sweet howl
  CurrentHowlWord1 = (CompanionsTrackingQuest as CompanionsHousekeepingScript).CurrentHowlWord1
  CurrentHowlWord2 = (CompanionsTrackingQuest as CompanionsHousekeepingScript).CurrentHowlWord2
  CurrentHowlWord3 = (CompanionsTrackingQuest as CompanionsHousekeepingScript).CurrentHowlWord3
  CurrentHowl = (CompanionsTrackingQuest as CompanionsHousekeepingScript).CurrentHowl

  Game.UnlockWord(CurrentHowlWord1)
  Game.UnlockWord(CurrentHowlWord2)
  Game.UnlockWord(CurrentHowlWord3)
  Game.GetPlayer().AddShout(CurrentHowl)
  Game.GetPlayer().EquipShout(CurrentHowl)

  ; and some rad claws
  int playerLevel = Game.GetPlayer().GetLevel()
  if   (playerLevel <= 10)
  Game.GetPlayer().AddSpell(PlayerWerewolfLvl10AndBelowAbility, false)
  elseif (playerLevel <= 15)
  Game.GetPlayer().AddSpell(PlayerWerewolfLvl15AndBelowAbility, false)
  elseif (playerLevel <= 20)
  Game.GetPlayer().AddSpell(PlayerWerewolfLvl20AndBelowAbility, false)
  elseif (playerLevel <= 25)
  Game.GetPlayer().AddSpell(PlayerWerewolfLvl25AndBelowAbility, false)
  elseif (playerLevel <= 30)
  Game.GetPlayer().AddSpell(PlayerWerewolfLvl30AndBelowAbility, false)
  elseif (playerLevel <= 35)
  Game.GetPlayer().AddSpell(PlayerWerewolfLvl35AndBelowAbility, false)
  elseif (playerLevel <= 40)
  Game.GetPlayer().AddSpell(PlayerWerewolfLvl40AndBelowAbility, false)
  elseif (playerLevel <= 45)
  Game.GetPlayer().AddSpell(PlayerWerewolfLvl45AndBelowAbility, false)
  else
  Game.GetPlayer().AddSpell(PlayerWerewolfLvl50AndOverAbility, false)
  endif

  ; calculate when the player turns back into a pumpkin
  float currentTime = GameDaysPassed.GetValue()
  float regressTime = currentTime + RealTimeSecondsToGameTimeDays(StandardDurationSeconds)
  PlayerWerewolfShiftBackTime.SetValue(regressTime)
;   Debug.Trace("WEREWOLF: Current day -- " + currentTime)
;   Debug.Trace("WEREWOLF: Player will turn back at day " + regressTime)

  ; increment stats
  Game.IncrementStat("Werewolf Transformations")

  ; set us up to check when we turn back
  RegisterForUpdate(5)

  SetStage(10) ; we're done with the transformation handling
EndFunction

Event OnUpdate()
  if (Untimed)
  return
  endif
;   Debug.Trace("WEREWOLF: NumWerewolfPerks = " + Game.QueryStat("NumWerewolfPerks"))
  if Game.QueryStat("NumWerewolfPerks") >= DLC1WerewolfMaxPerks.Value
;   debug.trace("WEREWOLF: achievement granted")
  Game.AddAchievement(57)
  endif

  float currentTime = GameDaysPassed.GetValue()
  float regressTime = PlayerWerewolfShiftBackTime.GetValue()

  if ((currentTime >= regressTime) && (!Game.GetPlayer().IsInKillMove()) && !__tryingToShiftBack )
  UnregisterForUpdate()
  SetStage(100) ; time to go, buddy
  return
  endif

  if (currentTime >= regressTime - __durationWarningTime)
  if (GetStage() == 10)
  SetStage(20)  ; almost there
  return
  endif
  endif

;   Debug.Trace("WEREWOLF: Checking, still have " + GameTimeDaysToRealTimeSeconds(regressTime - currentTime) + " seconds to go.")
EndEvent

-- called from stage 11 --
Function Feed(Actor victim)
;   Debug.Trace("WEREWOLF: start newShiftTime = " + GameTimeDaysToRealTimeSeconds(PlayerWerewolfShiftBackTime.GetValue()) + ", __feedExtensionTime = " + GameTimeDaysToRealTimeSeconds(__feedExtensionTime))
  float newShiftTime = PlayerWerewolfShiftBackTime.GetValue() + __feedExtensionTime / 2
  if victim.HasKeyword(ActorTypeNPC)
  newShiftTime =newShiftTime + __feedExtensionTime / 2
;   Debug.Trace("WEREWOLF: victim is NPC")
  endif
;   Debug.Trace("WEREWOLF: default newShiftTime = " + GameTimeDaysToRealTimeSeconds(newShiftTime) + ", __feedExtensionTime = " + GameTimeDaysToRealTimeSeconds(__feedExtensionTime))
  if Game.GetPlayer().HasPerk(DLC1GorgingPerk) == 1
  newShiftTime = newShiftTime + __GorgeExtensionTime / 2
  if victim.HasKeyword(ActorTypeNPC)
  newShiftTime = newShiftTime + __GorgeExtensionTime / 2
  endif
  endif
  Game.GetPlayer().PlayIdle(SpecialFeeding)
  
  ;This is for adding a spell that simulates bleeding
  BleedingFXSpell.Cast(victim,victim)
  
  if (!C03Rampage.IsRunning())
  PlayerWerewolfShiftBackTime.SetValue(newShiftTime)
  PlayerWerewolfFeedMessage.Show()
  FeedBoost.Cast(Game.GetPlayer())
  ; victim.SetActorValue("Variable08", 100)
;   Debug.Trace("WEREWOLF: Player feeding -- new regress day is " + newShiftTime)
  endif
  SetStage(10)
EndFunction
/;