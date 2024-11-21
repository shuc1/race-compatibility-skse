;/ Decompiled by Champollion v1.3.2
PEX format v3.2 GameID: 1
Source   : PlayerWerewolfChangeScript.psc
Modified : 2022-01-21 20:15:34
Compiled : 2022-01-21 20:15:35
User     : maxim
Computer : CANOPUS
/;
ScriptName PlayerWerewolfChangeScript Extends Quest

;-- Variables ---------------------------------------
Spell CurrentScalingEffect
Shout EquippedShout
Spell EquippedSpellL
Spell EquippedSpellR
Spell EquippedSpellV
Float ShoutCooldown = 0.0
Bool WasHardCast
Float __durationWarningTime = -1.0
Float __feedExtensionTime = -1.0
Bool __shiftingBack = False
Bool __shuttingDown = False
Bool __trackingStarted = False
Bool __tryingToShiftBack = False

;-- Properties --------------------------------------
Spell Property BeastForm Auto
Idle Property BleedOutStart Auto
Spell Property BleedingFXSpell Auto
{ This Spell is for making the target of feeding bleed. }
Quest Property C03Rampage Auto
Quest Property CompanionsTrackingQuest Auto
FormList Property CrimeFactions Auto
Shout Property CurrentHowl Auto
WordOfPower Property CurrentHowlWord1 Auto
WordOfPower Property CurrentHowlWord2 Auto
WordOfPower Property CurrentHowlWord3 Auto
Armor Property DLC2ArmorFXWerebearTransitionSkin Auto
Armor Property DLC2SkinNakedWereBearBeast Auto
Race Property DLC2WerebearBeastRace Auto
Float Property DurationWarningTimeSeconds Auto
{ How long (in real seconds) before turning back we should warn the player }
VisualEffect Property FeedBloodVFX Auto
{ Visual Effect on Wolf for Feeding Blood }
Spell Property FeedBoost Auto
Float Property FeedExtensionTimeSeconds Auto
{ How long (in real seconds) that feeding extends werewolf time }
GlobalVariable Property GameDaysPassed Auto
Float Property HLI_UnshiftHealthThreshold Auto
Message Property HRI_Events_Message_WerebearTotem Auto
MagicEffect Property HRI_Lycan_Effect_BeastForm_WasHardCastState Auto
GlobalVariable Property HRI_Lycan_Global_BeastFormDuration Auto
GlobalVariable Property HRI_Lycan_Global_BeastFormDurationExtension Auto
GlobalVariable Property HRI_Lycan_Global_HuntersMoon_WentOff Auto
GlobalVariable Property HRI_Lycan_Global_InvulnerableDuringChange Auto
GlobalVariable Property HRI_Lycan_Global_WerebearTotem Auto
Message Property HRI_Lycan_Message_RunningOut Auto
Spell Property HRI_Lycan_Spell_BeastForm Auto
Spell Property HRI_Lycan_Spell_BeastFormCooldown Auto
Spell Property HRI_Lycan_Spell_BeastFormCooldownSmall Auto
Spell Property HRI_Lycan_Spell_BeastForm_ReplacerOnCooldown_Fail Auto
Spell Property HRI_Lycan_Spell_BeastForm_RingOverride Auto
hri_manager_script Property HRI_Manager_Quest Auto
Perk Property HRI_Werewolf_Perk_Invulnerable Auto
Spell Property Immunity Auto
ObjectReference Property LycanStash Auto
Race Property MortalFormRace Auto
Sound Property NPCWerewolfTransformation Auto
Actor Property PlayerRef Auto
Quest Property PlayerVampireQuest Auto
Quest Property PlayerWerewolfCureQuest Auto
Message Property PlayerWerewolfExpirationWarning Auto
Faction Property PlayerWerewolfFaction Auto
Perk Property PlayerWerewolfFeed Auto
Message Property PlayerWerewolfFeedMessage Auto
Spell Property PlayerWerewolfLvl10AndBelowAbility Auto
Spell Property PlayerWerewolfLvl15AndBelowAbility Auto
Spell Property PlayerWerewolfLvl20AndBelowAbility Auto
Spell Property PlayerWerewolfLvl25AndBelowAbility Auto
Spell Property PlayerWerewolfLvl30AndBelowAbility Auto
Spell Property PlayerWerewolfLvl35AndBelowAbility Auto
Spell Property PlayerWerewolfLvl40AndBelowAbility Auto
Spell Property PlayerWerewolfLvl45AndBelowAbility Auto
Spell Property PlayerWerewolfLvl50AndOverAbility Auto
GlobalVariable Property PlayerWerewolfShiftBackTime Auto
Idle Property SpecialFeeding Auto
Float Property StandardDurationSeconds Auto
{ How long (in real seconds) the transformation lasts }
GlobalVariable Property TimeScale Auto
Weapon Property Unarmed Auto
Bool Property Untimed Auto
Keyword Property VampireKeyword Auto
Race Property WerewolfBeastRace Auto
ImageSpaceModifier Property WerewolfChange Auto
Spell Property WerewolfCureDisease Auto
FormList Property WerewolfDispelList Auto
Faction Property WerewolfFaction Auto
Sound Property WerewolfIMODSound Auto
Race Property WerewolfRace Auto
Idle Property WerewolfTransformBack Auto
ImageSpaceModifier Property WerewolfWarn Auto
Armor Property WolfSkinFXArmor Auto

;-- Functions ---------------------------------------

; Skipped compiler generated GetState

; Skipped compiler generated GotoState

Float Function RealTimeSecondsToGameTimeDays(Float realtime)
  Float scaledSeconds = realtime * TimeScale.value
  Return scaledSeconds / (60 * 60 * 24) as Float
EndFunction

Float Function GameTimeDaysToRealTimeSeconds(Float gametime)
  Float gameSeconds = gametime * (60 * 60 * 24) as Float
  Return gameSeconds / TimeScale.value
EndFunction

Function PrepShift()
  ; RaceCompatibility: in case player changed race before shift
  (CompanionsTrackingQuest as CompanionsHousekeepingScript).SetPlayerOriginalRace()

  If !PlayerRef.HasSpell(Immunity as Form)
    Self.GibBeastbloodPlz()
  EndIf
  WasHardCast = PlayerRef.HasMagicEffect(HRI_Lycan_Effect_BeastForm_WasHardCastState)
  Game.SetBeastForm(True)
  Game.EnableFastTravel(False)
  If HRI_Lycan_Global_InvulnerableDuringChange.GetValue() == 1 as Float
    PlayerRef.AddPerk(HRI_Werewolf_Perk_Invulnerable)
  EndIf
  WerewolfChange.Apply(1.0)
  WerewolfIMODSound.Play(PlayerRef as ObjectReference)
  Int count = 0
  While count < WerewolfDispelList.GetSize()
    Spell gone = WerewolfDispelList.GetAt(count) as Spell
    If gone != None
      PlayerRef.DispelSpell(gone)
    EndIf
    count += 1
  EndWhile
  Game.DisablePlayerControls(False, False, True, False, False, False, False, False, 1)
  Game.ForceThirdPerson()
  Game.ShowFirstPersonGeometry(False)
EndFunction

Function InitialShift()
  WerewolfWarn.Apply(1.0)
  If PlayerRef.IsDead()
    Return 
  EndIf
  MortalFormRace = PlayerRef.GetRace()
  PlayerRef.SetRace(WerewolfBeastRace)
EndFunction

Function StartTracking()
  If __trackingStarted
    Return 
  EndIf
  __trackingStarted = True
  PlayerRef.UnequipAll()
  If HRI_Lycan_Global_WerebearTotem.GetValue() == 1 as Float
    PlayerRef.EquipItem(DLC2ArmorFXWerebearTransitionSkin as Form, True, True)
    PlayerRef.EquipItem(DLC2SkinNakedWereBearBeast as Form, True, True)
  Else
    PlayerRef.EquipItem(WolfSkinFXArmor as Form, True, True)
  EndIf
  PlayerRef.EquipItem(Unarmed as Form, True, True)
  PlayerRef.SetAttackActorOnSight(True)
  Game.SendWereWolfTransformation()
  PlayerRef.AddToFaction(PlayerWerewolfFaction)
  PlayerRef.AddToFaction(WerewolfFaction)
  Int cfIndex = 0
  While cfIndex < CrimeFactions.GetSize()
    (CrimeFactions.GetAt(cfIndex) as Faction).SetPlayerEnemy(True)
    cfIndex += 1
  EndWhile
  Game.SetPlayerReportCrime(False)
  __durationWarningTime = Self.RealTimeSecondsToGameTimeDays(DurationWarningTimeSeconds)
  __feedExtensionTime = Self.RealTimeSecondsToGameTimeDays(HRI_Lycan_Global_BeastFormDurationExtension.GetValue())
  EquippedSpellL = PlayerRef.GetEquippedSpell(0)
  EquippedSpellR = PlayerRef.GetEquippedSpell(1)
  EquippedSpellV = PlayerRef.GetEquippedSpell(2)
  EquippedShout = PlayerRef.GetEquippedShout()
  If EquippedSpellL
    PlayerRef.UnequipSpell(EquippedSpellL, 0)
  EndIf
  If EquippedSpellR
    PlayerRef.UnequipSpell(EquippedSpellR, 1)
  EndIf
  If EquippedSpellV
    PlayerRef.UnequipSpell(EquippedSpellV, 2)
  EndIf
  If EquippedShout
    PlayerRef.UnequipShout(EquippedShout)
  EndIf
  CurrentHowlWord1 = (CompanionsTrackingQuest as companionshousekeepingscript).CurrentHowlWord1
  CurrentHowlWord2 = (CompanionsTrackingQuest as companionshousekeepingscript).CurrentHowlWord2
  CurrentHowlWord3 = (CompanionsTrackingQuest as companionshousekeepingscript).CurrentHowlWord3
  CurrentHowl = (CompanionsTrackingQuest as companionshousekeepingscript).CurrentHowl
  Game.UnlockWord(CurrentHowlWord1)
  Game.UnlockWord(CurrentHowlWord2)
  Game.UnlockWord(CurrentHowlWord3)
  PlayerRef.AddShout(CurrentHowl)
  PlayerRef.EquipShout(CurrentHowl)
  Int playerLevel = PlayerRef.GetLevel()
  If playerLevel <= 10
    CurrentScalingEffect = PlayerWerewolfLvl10AndBelowAbility
  ElseIf playerLevel <= 15
    CurrentScalingEffect = PlayerWerewolfLvl15AndBelowAbility
  ElseIf playerLevel <= 20
    CurrentScalingEffect = PlayerWerewolfLvl20AndBelowAbility
  ElseIf playerLevel <= 25
    CurrentScalingEffect = PlayerWerewolfLvl25AndBelowAbility
  ElseIf playerLevel <= 30
    CurrentScalingEffect = PlayerWerewolfLvl30AndBelowAbility
  ElseIf playerLevel <= 35
    CurrentScalingEffect = PlayerWerewolfLvl35AndBelowAbility
  ElseIf playerLevel <= 40
    CurrentScalingEffect = PlayerWerewolfLvl40AndBelowAbility
  ElseIf playerLevel <= 45
    CurrentScalingEffect = PlayerWerewolfLvl45AndBelowAbility
  Else
    CurrentScalingEffect = PlayerWerewolfLvl50AndOverAbility
  EndIf
  PlayerRef.AddSpell(CurrentScalingEffect, False)
  ShoutCooldown = PlayerRef.GetVoiceRecoveryTime()
  If HRI_Lycan_Global_HuntersMoon_WentOff.GetValue() == 1 as Float
    PlayerRef.SetVoiceRecoveryTime(30.0)
    HRI_Lycan_Global_HuntersMoon_WentOff.SetValue(0 as Float)
  Else
    PlayerRef.SetVoiceRecoveryTime(10.0)
  EndIf
  PlayerRef.RemovePerk(HRI_Werewolf_Perk_Invulnerable)
  Float currentTime = GameDaysPassed.GetValue()
  Float regressTime = currentTime + Self.RealTimeSecondsToGameTimeDays(HRI_Lycan_Global_BeastFormDuration.GetValue())
  PlayerWerewolfShiftBackTime.SetValue(regressTime)
  Game.IncrementStat("Werewolf Transformations", 1)
  Self.RegisterForUpdate(2.0)
  Self.SetStage(10)
EndFunction

Event OnUpdate()
  If Untimed
    Return 
  EndIf
  Float currentTime = GameDaysPassed.GetValue()
  Float regressTime = PlayerWerewolfShiftBackTime.GetValue()
  If currentTime >= regressTime && !PlayerRef.IsInKillMove() && !__tryingToShiftBack
    Self.UnregisterForUpdate()
    Self.SetStage(100)
  ElseIf currentTime >= regressTime - __durationWarningTime
    If Self.GetStage() == 10
      Self.SetStage(20)
    EndIf
  EndIf
EndEvent

Function SetUntimed(Bool untimedValue)
  Untimed = untimedValue
  If Untimed
    Self.UnregisterForUpdate()
  EndIf
EndFunction

Function Feed(Actor victim)
  Float newShiftTime = PlayerWerewolfShiftBackTime.GetValue() + __feedExtensionTime
  PlayerRef.PlayIdle(SpecialFeeding)
  BleedingFXSpell.Cast(victim as ObjectReference, victim as ObjectReference)
  If !C03Rampage.IsRunning()
    PlayerWerewolfShiftBackTime.SetValue(newShiftTime)
    PlayerWerewolfFeedMessage.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    FeedBoost.Cast(PlayerRef as ObjectReference, None)
  EndIf
  Self.SetStage(10)
EndFunction

Function WarnPlayer()
  WerewolfWarn.Apply(1.0)
  HRI_Lycan_Message_RunningOut.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
EndFunction

Function ShiftBack()
  __tryingToShiftBack = True
  While PlayerRef.GetAnimationVariableBool("bIsSynced")
    Utility.Wait(0.100000001)
  EndWhile
  __shiftingBack = False
  Self.ActuallyShiftBackIfNecessary()
EndFunction

Event OnAnimationEvent(ObjectReference akSource, String asEventName)
  If asEventName == "TransformToHuman"
    Self.ActuallyShiftBackIfNecessary()
  EndIf
EndEvent

Function ActuallyShiftBackIfNecessary()
  If __shiftingBack
    Return 
  EndIf
  __shiftingBack = True
  Game.SetInCharGen(True, True, False)
  Self.UnRegisterForAnimationEvent(PlayerRef as ObjectReference, "TransformToHuman")
  Self.UnregisterForUpdate()
  If PlayerRef.IsDead()
    Return 
  EndIf
  PlayerRef.SetVoiceRecoveryTime(ShoutCooldown)
  WerewolfChange.Apply(1.0)
  WerewolfIMODSound.Play(PlayerRef as ObjectReference)
  If PlayerRef.HasSpell(HRI_Lycan_Spell_BeastForm as Form)
    If !PlayerRef.HasSpell(HRI_Lycan_Spell_BeastForm_RingOverride as Form)
      HRI_Lycan_Spell_BeastFormCooldown.Cast(PlayerRef as ObjectReference, None)
    Else
      HRI_Lycan_Spell_BeastFormCooldownSmall.Cast(PlayerRef as ObjectReference, None)
    EndIf
  EndIf
  Int count = 0
  While count < WerewolfDispelList.GetSize()
    Spell gone = WerewolfDispelList.GetAt(count) as Spell
    If gone != None
      PlayerRef.DispelSpell(gone)
    EndIf
    count += 1
  EndWhile
  PlayerRef.SetGhost(True)
  Float currHealth = PlayerRef.GetActorValue("Health")
  If currHealth <= HLI_UnshiftHealthThreshold
    PlayerRef.RestoreActorValue("Health", HLI_UnshiftHealthThreshold - currHealth)
  EndIf
  PlayerRef.UnequipItem(WolfSkinFXArmor as Form, False, True)
  PlayerRef.UnequipItem(Unarmed as Form, False, True)
  PlayerRef.RemoveItem(WolfSkinFXArmor as Form, 999, True, None)
  PlayerRef.UnequipItem(DLC2ArmorFXWerebearTransitionSkin as Form, False, True)
  PlayerRef.RemoveItem(DLC2ArmorFXWerebearTransitionSkin as Form, 999, True, None)
  PlayerRef.UnequipItem(DLC2SkinNakedWereBearBeast as Form, False, True)
  PlayerRef.RemoveItem(DLC2SkinNakedWereBearBeast as Form, 999, True, None)
  If MortalFormRace
    PlayerRef.SetRace(MortalFormRace)
  Else
    PlayerRef.SetRace((CompanionsTrackingQuest as companionshousekeepingscript).PlayerOriginalRace)
  EndIf
  Game.ShowFirstPersonGeometry(True)
  PlayerRef.UnequipShout(CurrentHowl)
  PlayerRef.RemoveShout(CurrentHowl)
  PlayerRef.RemoveSpell(CurrentScalingEffect)
  If EquippedSpellV as Bool && EquippedSpellV != HRI_Lycan_Spell_BeastForm_ReplacerOnCooldown_Fail
    PlayerRef.EquipSpell(EquippedSpellV, 2)
  EndIf
  Game.EnablePlayerControls(False, False, True, False, False, False, False, False, 1)
  PlayerRef.SetAttackActorOnSight(False)
  PlayerRef.RemoveFromFaction(PlayerWerewolfFaction)
  PlayerRef.RemoveFromFaction(WerewolfFaction)
  Int cfIndex = 0
  While cfIndex < CrimeFactions.GetSize()
    (CrimeFactions.GetAt(cfIndex) as Faction).SetPlayerEnemy(False)
    cfIndex += 1
  EndWhile
  Game.SetPlayerReportCrime(True)
  Game.SendWereWolfTransformation()
  Utility.Wait(5.0)
  Self.Shutdown()
EndFunction

Function Shutdown()
  If __shuttingDown
    Return 
  EndIf
  __shuttingDown = True
  PlayerRef.RemovePerk(HRI_Werewolf_Perk_Invulnerable)
  PlayerRef.SetGhost(False)
  Game.SetBeastForm(False)
  Game.EnableFastTravel(True)
  Game.SetInCharGen(False, False, False)
  Self.Stop()
EndFunction

Function GibBeastbloodPlz()
  Int BeastType = HRI_Events_Message_WerebearTotem.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
  HRI_Lycan_Global_WerebearTotem.SetValue(BeastType as Float)
  If PlayerRef.HasKeyword(VampireKeyword)
    (PlayerVampireQuest as playervampirequestscript).VampireCure(PlayerRef)
  EndIf
  WerewolfCureDisease.Cast(PlayerRef as ObjectReference, None)
  PlayerWerewolfCureQuest.Start()
  PlayerRef.AddSpell(BeastForm, True)
  PlayerRef.AddSpell(Immunity, False)
  PlayerRef.SendLycanthropyStateChanged(True)
EndFunction

Int Function PassIntegrityCheck()
  Return 777
EndFunction
