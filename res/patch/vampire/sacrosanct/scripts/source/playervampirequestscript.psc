;/ Decompiled by Champollion v1.3.2
PEX format v3.2 GameID: 1
Source   : PlayerVampireQuestScript.psc
Modified : 2020-12-07 13:57:40
Compiled : 2020-12-07 13:57:41
User     : maxim
Computer : CANOPUS
/;
ScriptName PlayerVampireQuestScript Extends Quest conditional

;-- Variables ---------------------------------------

;-- Properties --------------------------------------
FormList Property CrimeFactions Auto
Race Property CureRace Auto
FormList Property DLC1CrimeFactions Auto
Spell Property DLC1VampireChange Auto
MagicEffect Property DLC1VampireChangeEffect Auto
MagicEffect Property DLC1VampireChangeFXEffect Auto
FormList Property DLC1VampireHateFactions Auto
Spell Property DiseasePorphyricHemophelia Auto
Float Property FeedTimer Auto
GlobalVariable Property GameDaysPassed Auto
Float Property LastFeedTime Auto
Sound Property MagVampireTransform01 Auto
Race Property NordRace Auto
Race Property NordRaceVampire Auto
GlobalVariable Property PlayerIsVampire Auto
Spell Property SCS_Abilities_Reward_Spell_NoHate Auto
Spell Property SCS_Abilities_Reward_Spell_SlowerHunger Auto
Spell Property SCS_Abilities_Reward_Spell_UltimatePredator_Ab Auto
Spell Property SCS_Abilities_StrongBlood_Spell_04_Ab Auto
Spell Property SCS_Abilities_Vanilla_Spell_Ab_IllusionSpells_AndAbilityHolder Auto
Spell Property SCS_Abilities_Vanilla_Spell_Ab_NewMoonlitWaters Auto
Spell Property SCS_Abilities_Vanilla_Spell_Ab_ResistFrost_Stage1 Auto
Spell Property SCS_Abilities_Vanilla_Spell_Ab_ResistFrost_Stage2 Auto
Spell Property SCS_Abilities_Vanilla_Spell_Ab_ResistFrost_Stage3 Auto
Spell Property SCS_Abilities_Vanilla_Spell_Ab_ResistFrost_Stage4 Auto
Spell Property SCS_Abilities_Vanilla_Spell_Ab_ReverseProgression_Stage1 Auto
Spell Property SCS_Abilities_Vanilla_Spell_Ab_ReverseProgression_Stage2 Auto
Spell Property SCS_Abilities_Vanilla_Spell_Ab_ReverseProgression_Stage2N Auto
Spell Property SCS_Abilities_Vanilla_Spell_Ab_ReverseProgression_Stage2N_Proc Auto
Spell Property SCS_Abilities_Vanilla_Spell_Ab_ReverseProgression_Stage3 Auto
Spell Property SCS_Abilities_Vanilla_Spell_Ab_ReverseProgression_Stage3N Auto
Spell Property SCS_Abilities_Vanilla_Spell_Ab_ReverseProgression_Stage4 Auto
Spell Property SCS_Abilities_Vanilla_Spell_Ab_ReverseProgression_Stage5 Auto
Spell Property SCS_Abilities_Vanilla_Spell_Ab_SneakBonus Auto
Spell Property SCS_Abilities_Vanilla_Spell_Ab_Status_Stage1 Auto
Spell Property SCS_Abilities_Vanilla_Spell_Ab_Status_Stage2 Auto
Spell Property SCS_Abilities_Vanilla_Spell_Ab_Status_Stage3 Auto
Spell Property SCS_Abilities_Vanilla_Spell_Ab_Status_Stage4 Auto
Spell Property SCS_Abilities_Vanilla_Spell_Ab_SunDamage_Stage1 Auto
Spell Property SCS_Abilities_Vanilla_Spell_Ab_SunDamage_Stage2 Auto
Spell Property SCS_Abilities_Vanilla_Spell_Ab_SunDamage_Stage3 Auto
Spell Property SCS_Abilities_Vanilla_Spell_Ab_SunDamage_Stage4 Auto
Spell Property SCS_Abilities_Vanilla_Spell_Ab_TrespassingCurse Auto
Spell Property SCS_Abilities_Vanilla_Spell_Ab_WeaknessToFire_Stage1 Auto
Spell Property SCS_Abilities_Vanilla_Spell_Ab_WeaknessToFire_Stage2 Auto
Spell Property SCS_Abilities_Vanilla_Spell_Ab_WeaknessToFire_Stage3 Auto
Spell Property SCS_Abilities_Vanilla_Spell_Ab_WeaknessToFire_Stage4 Auto
Message Property SCS_Help_HungerStage2 Auto
Float Property SCS_HungerChance Auto
Float Property SCS_HungerChanceSlower Auto
scs_futil_script Property SCS_Main500_Quest Auto
GlobalVariable Property SCS_Mechanics_Global_DelayBetweenStages Auto
GlobalVariable Property SCS_Mechanics_Global_DisableHate Auto
GlobalVariable Property SCS_Mechanics_Global_HasLiftAndDrop Auto
GlobalVariable Property SCS_Mechanics_Global_Wassail_Current Auto
GlobalVariable Property SCS_Mechanics_Global_Wassail_NerfAmount Auto
Message Property SCS_Mechanics_Message_RaceBroken Auto
Message Property SCS_Mechanics_Message_VampireFeed Auto
Message Property SCS_Mechanics_Message_VampireProgression Auto
Message Property SCS_Mechanics_Message_VampireProgressionStage2 Auto
Message Property SCS_Mechanics_Message_VampireProgressionStage3 Auto
Message Property SCS_Mechanics_Message_VampireProgressionStage4 Auto
Message Property SCS_Mechanics_Message_VampireProgressionStage4_HasMasquerade Auto
FormList Property SCS_Races Auto
FormList Property SCS_RacesVampire Auto
String Property SCS_Stat0 Auto
String Property SCS_Stat1 Auto
String Property SCS_Stat2 Auto
Spell Property SCS_VampireSpells_Reward_Power_Spell_LamaesShroud Auto
Spell Property SCS_VampireSpells_Reward_Power_Spell_VampiresCall Auto
Spell Property SCS_VampireSpells_Vanilla_Power_Spell_BloodCauldron Auto
Spell Property SCS_VampireSpells_Vanilla_Power_Spell_BloodIsPower Auto
Spell Property SCS_VampireSpells_Vanilla_Power_Spell_Flaywind Auto
Spell Property SCS_VampireSpells_Vanilla_Power_Spell_NewObfuscate Auto
Spell Property SCS_VampireSpells_Vanilla_Power_Spell_Nightwalk2 Auto
Spell Property SCS_VampireSpells_Vanilla_Power_Spell_VampiresCommand2 Auto
Spell Property SCS_VampireSpells_Vanilla_Power_Spell_VampiresSeduction Auto
Spell Property SCS_VampireSpells_Vanilla_Power_Spell_VampiresSight Auto
Spell Property SCS_VampireSpells_Vanilla_Power_Spell_VampiresWill Auto
Spell Property SCS_VampireSpells_Vanilla_Spell_VampiricDrain Auto
Quest Property VC01 Auto
EffectShader Property VampireChangeFX Auto
Spell Property VampireCureDisease Auto
GlobalVariable Property VampireFeedReady Auto
Idle Property VampireFeedingBedRight Auto
Idle Property VampireFeedingBedrollRight Auto
Faction Property VampirePCFaction Auto
Int Property VampireStatus Auto conditional
ImageSpaceModifier Property VampireTransformDecreaseISMD Auto
ImageSpaceModifier Property VampireTransformIncreaseISMD Auto
Static Property XMarker Auto

;-- Functions ---------------------------------------

; Skipped compiler generated GetState

; Skipped compiler generated GotoState

Bool Function TestIntegrity()
  Return True
EndFunction

Event OnUpdateGameTime()
  Actor Player = Game.GetPlayer()
  FeedTimer = (GameDaysPassed.value - LastFeedTime) * 24.010000229 / SCS_Mechanics_Global_DelayBetweenStages.GetValue()
  If Game.IsMovementControlsEnabled() && Game.IsFightingControlsEnabled() && Player.GetCombatState() == 0 && !Player.HasMagicEffect(DLC1VampireChangeEffect) && !Player.HasMagicEffect(DLC1VampireChangeFXEffect)
    Float Chance
    If Player.HasSpell(SCS_Abilities_Reward_Spell_SlowerHunger as Form)
      Chance = SCS_HungerChance
    Else
      Chance = SCS_HungerChanceSlower
    EndIf
    If Utility.RandomFloat(0.0, 1.0) < SCS_HungerChance
      SCS_Help_HungerStage2.ShowAsHelpMessage("SCS_HungerStage2Event", 5.0, 0 as Float, 1)
      Self.Devolve(False)
    EndIf
  EndIf
EndEvent

Bool Function Devolve(Bool abForceDevolve)
  Actor Player = Game.GetPlayer()
  If ((FeedTimer >= 3 as Float) || abForceDevolve == True) && VampireStatus == 3
    VampireFeedReady.SetValue(3 as Float)
    If (SCS_Mechanics_Global_DisableHate.GetValue() == 0 as Float) && !Player.HasSpell(SCS_Abilities_Reward_Spell_NoHate as Form)
      SCS_Mechanics_Message_VampireProgressionStage4.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    Else
      SCS_Mechanics_Message_VampireProgressionStage4_HasMasquerade.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    EndIf
    VampireStatus = 4
    Self.VampireProgression(Player, 4)
    Self.UnregisterforUpdateGameTime()
  ElseIf ((FeedTimer >= 2 as Float) || abForceDevolve == True) && VampireStatus == 2
    If abForceDevolve
      LastFeedTime -= 1 as Float
    EndIf
    VampireFeedReady.SetValue(2 as Float)
    SCS_Mechanics_Message_VampireProgressionStage3.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    VampireStatus = 3
    Self.VampireProgression(Player, 3)
  ElseIf ((FeedTimer >= 1 as Float) || abForceDevolve == True) && VampireStatus == 1
    If abForceDevolve
      LastFeedTime -= 1 as Float
    EndIf
    VampireFeedReady.SetValue(1 as Float)
    SCS_Mechanics_Message_VampireProgressionStage2.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    VampireStatus = 2
    Self.VampireProgression(Player, 2)
  EndIf
EndFunction

Function VampireFeedBed()
  Game.GetPlayer().PlayIdle(VampireFeedingBedRight)
EndFunction

Function VampireFeedBedRoll()
  Game.GetPlayer().PlayIdle(VampireFeedingBedrollRight)
EndFunction

Function VampireChange(Actor Target)
  Actor Player = Game.GetPlayer()
  Game.DisablePlayerControls(True, True, False, False, False, True, True, False, 0)
  VampireChangeFX.play(Target as ObjectReference, -1.0)
  VampireTransformIncreaseISMD.applyCrossFade(2.0)
  ObjectReference myXmarker = Target.PlaceAtMe(XMarker as Form, 1, False, False)
  MagVampireTransform01.play(myXmarker)
  myXmarker.Disable(False)
  Utility.Wait(2.0)
  ImageSpaceModifier.removeCrossFade(1.0)
  VampireChangeFX.stop(Target as ObjectReference)
  Race PlayerRace = Target.GetActorBase().GetRace()
  CureRace = PlayerRace
  Int RaceID = SCS_Races.Find(PlayerRace as Form)
  If RaceID >= 0
    Target.SetRace(SCS_RacesVampire.GetAt(RaceID) as Race)
  Else
    ; RCS
    Race PlayerVampireRace = RaceCompatibility.GetVampireRaceByRace(PlayerRace)
    If PlayerVampireRace != None
      Target.SetRace(PlayerVampireRace)
    Else
      SCS_Mechanics_Message_RaceBroken.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
      Target.SetRace(NordRaceVampire)
    EndIf
  EndIf
  VampireCureDisease.Cast(Target as ObjectReference, None)
  VampireStatus = 1
  Self.VampireProgression(Player, 1)
  Self.RegisterForUpdateGameTime(3 as Float)
  LastFeedTime = GameDaysPassed.value
  PlayerIsVampire.SetValue(1 as Float)
  SCS_Main500_Quest.RebuildRewardSpells()
  Utility.Wait(1.0)
  Game.EnablePlayerControls(True, True, True, True, True, True, True, True, 0)
  If VC01.GetStageDone(200) == 1 as Bool
    VC01.SetStage(25)
  EndIf
EndFunction

Function VampireFeed()
  Actor Player = Game.GetPlayer()
  VampireTransformDecreaseISMD.applyCrossFade(2.0)
  Utility.Wait(2.0)
  ImageSpaceModifier.removeCrossFade(1.0)
  Game.IncrementStat("Necks Bitten", 1)
  SCS_Mechanics_Message_VampireFeed.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
  VampireFeedReady.SetValue(0 as Float)
  LastFeedTime = GameDaysPassed.value
  VampireStatus = 1
  Self.VampireProgression(Player, 1)
  Self.StopHate(Player, False)
  Self.UnregisterforUpdateGameTime()
  Self.RegisterForUpdateGameTime(3 as Float)
EndFunction

Function VampireProgression(Actor Player, Int VampireStage)
  Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_TrespassingCurse)
  Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_NewMoonlitWaters)
  Bool HasCall = False
  Bool HasShroud = False
  Bool GiveBackMyth = False
  If VampireStage == 2
    VampireTransformIncreaseISMD.applyCrossFade(2.0)
    Utility.Wait(2.0)
    ImageSpaceModifier.removeCrossFade(1.0)
    Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_ResistFrost_Stage1)
    Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_WeaknessToFire_Stage1)
    Player.AddSpell(SCS_Abilities_Vanilla_Spell_Ab_WeaknessToFire_Stage2, False)
    Player.AddSpell(SCS_Abilities_Vanilla_Spell_Ab_ResistFrost_Stage2, False)
    Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_SunDamage_Stage1)
    Player.AddSpell(SCS_Abilities_Vanilla_Spell_Ab_SunDamage_Stage2, False)
    Player.AddSpell(SCS_VampireSpells_Vanilla_Spell_VampiricDrain, False)
    Player.AddSpell(SCS_VampireSpells_Vanilla_Power_Spell_VampiresWill, False)
    Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_ReverseProgression_Stage3N)
    Player.AddSpell(SCS_Abilities_Vanilla_Spell_Ab_ReverseProgression_Stage2N, False)
    Player.RemoveSpell(SCS_VampireSpells_Vanilla_Power_Spell_BloodCauldron)
    Player.AddSpell(SCS_VampireSpells_Vanilla_Power_Spell_BloodIsPower, True)
    Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_Status_Stage1)
    Player.AddSpell(SCS_Abilities_Vanilla_Spell_Ab_Status_Stage2, False)
  ElseIf VampireStage == 3
    VampireTransformIncreaseISMD.applyCrossFade(2.0)
    Utility.Wait(2.0)
    ImageSpaceModifier.removeCrossFade(1.0)
    Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_ResistFrost_Stage1)
    Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_ResistFrost_Stage2)
    Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_WeaknessToFire_Stage1)
    Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_WeaknessToFire_Stage2)
    Player.AddSpell(SCS_Abilities_Vanilla_Spell_Ab_WeaknessToFire_Stage3, False)
    Player.AddSpell(SCS_Abilities_Vanilla_Spell_Ab_ResistFrost_Stage3, False)
    Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_SunDamage_Stage1)
    Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_SunDamage_Stage2)
    Player.AddSpell(SCS_Abilities_Vanilla_Spell_Ab_SunDamage_Stage3, False)
    Player.AddSpell(SCS_VampireSpells_Vanilla_Spell_VampiricDrain, False)
    Player.AddSpell(SCS_VampireSpells_Vanilla_Power_Spell_VampiresWill, False)
    Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_ReverseProgression_Stage3N)
    Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_ReverseProgression_Stage2)
    Player.AddSpell(SCS_Abilities_Vanilla_Spell_Ab_ReverseProgression_Stage2N, False)
    Player.AddSpell(SCS_Abilities_Vanilla_Spell_Ab_ReverseProgression_Stage3, False)
    Player.RemoveSpell(SCS_VampireSpells_Vanilla_Power_Spell_BloodCauldron)
    Player.RemoveSpell(SCS_VampireSpells_Vanilla_Power_Spell_Nightwalk2)
    Player.AddSpell(SCS_VampireSpells_Vanilla_Power_Spell_NewObfuscate, True)
    Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_Status_Stage2)
    Player.AddSpell(SCS_Abilities_Vanilla_Spell_Ab_Status_Stage3, False)
  ElseIf VampireStage == 4
    VampireTransformIncreaseISMD.applyCrossFade(2.0)
    Utility.Wait(2.0)
    ImageSpaceModifier.removeCrossFade(1.0)
    Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_ResistFrost_Stage1)
    Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_ResistFrost_Stage2)
    Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_ResistFrost_Stage3)
    Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_WeaknessToFire_Stage1)
    Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_WeaknessToFire_Stage2)
    Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_WeaknessToFire_Stage3)
    Player.AddSpell(SCS_Abilities_Vanilla_Spell_Ab_ResistFrost_Stage4, False)
    Player.AddSpell(SCS_Abilities_Vanilla_Spell_Ab_WeaknessToFire_Stage4, False)
    Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_SunDamage_Stage1)
    Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_SunDamage_Stage2)
    Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_SunDamage_Stage3)
    Player.AddSpell(SCS_Abilities_Vanilla_Spell_Ab_SunDamage_Stage4, False)
    Player.AddSpell(SCS_VampireSpells_Vanilla_Spell_VampiricDrain, False)
    Player.AddSpell(SCS_VampireSpells_Vanilla_Power_Spell_VampiresWill, False)
    Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_ReverseProgression_Stage1)
    Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_ReverseProgression_Stage2)
    Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_ReverseProgression_Stage3N)
    Player.AddSpell(SCS_Abilities_Vanilla_Spell_Ab_ReverseProgression_Stage2N, False)
    Player.AddSpell(SCS_Abilities_Vanilla_Spell_Ab_ReverseProgression_Stage3, False)
    Player.AddSpell(SCS_Abilities_Vanilla_Spell_Ab_ReverseProgression_Stage4, False)
    Player.RemoveSpell(SCS_VampireSpells_Vanilla_Power_Spell_BloodCauldron)
    Player.RemoveSpell(SCS_VampireSpells_Vanilla_Power_Spell_Nightwalk2)
    Player.RemoveSpell(SCS_VampireSpells_Vanilla_Power_Spell_VampiresCommand2)
    Player.AddSpell(SCS_VampireSpells_Vanilla_Power_Spell_Flaywind, True)
    Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_Status_Stage3)
    Player.AddSpell(SCS_Abilities_Vanilla_Spell_Ab_Status_Stage4, False)
    Self.StartHate(Player)
  ElseIf VampireStage == 1
    HasCall = Player.HasSpell(SCS_VampireSpells_Reward_Power_Spell_VampiresCall as Form)
    HasShroud = Player.HasSpell(SCS_VampireSpells_Reward_Power_Spell_LamaesShroud as Form)
    If HasCall
      Player.RemoveSpell(SCS_VampireSpells_Reward_Power_Spell_VampiresCall)
    EndIf
    Player.AddSpell(SCS_Abilities_Vanilla_Spell_Ab_NewMoonlitWaters, False)
    Player.AddSpell(SCS_Abilities_Vanilla_Spell_Ab_IllusionSpells_AndAbilityHolder, False)
    Player.AddSpell(SCS_Abilities_Vanilla_Spell_Ab_SneakBonus, False)
    Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_ResistFrost_Stage4)
    Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_ResistFrost_Stage2)
    Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_ResistFrost_Stage3)
    Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_WeaknessToFire_Stage4)
    Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_WeaknessToFire_Stage2)
    Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_WeaknessToFire_Stage3)
    Player.AddSpell(SCS_Abilities_Vanilla_Spell_Ab_ResistFrost_Stage1, False)
    Player.AddSpell(SCS_Abilities_Vanilla_Spell_Ab_WeaknessToFire_Stage1, False)
    Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_SunDamage_Stage4)
    Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_SunDamage_Stage2)
    Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_SunDamage_Stage3)
    Player.AddSpell(SCS_Abilities_Vanilla_Spell_Ab_SunDamage_Stage1, False)
    Player.AddSpell(SCS_VampireSpells_Vanilla_Spell_VampiricDrain, False)
    Player.AddSpell(SCS_VampireSpells_Vanilla_Power_Spell_VampiresWill, False)
    Player.AddSpell(SCS_Abilities_Vanilla_Spell_Ab_ReverseProgression_Stage1, False)
    Player.AddSpell(SCS_Abilities_Vanilla_Spell_Ab_ReverseProgression_Stage2, False)
    Player.AddSpell(SCS_Abilities_Vanilla_Spell_Ab_ReverseProgression_Stage3N, False)
    Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_ReverseProgression_Stage2N)
    Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_ReverseProgression_Stage3)
    Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_ReverseProgression_Stage4)
    If !Player.HasSpell(SCS_Abilities_Reward_Spell_UltimatePredator_Ab as Form)
      Player.RemoveSpell(SCS_VampireSpells_Vanilla_Power_Spell_BloodIsPower)
      Player.RemoveSpell(SCS_VampireSpells_Vanilla_Power_Spell_NewObfuscate)
      Player.RemoveSpell(SCS_VampireSpells_Vanilla_Power_Spell_Flaywind)
    EndIf
    Player.AddSpell(SCS_VampireSpells_Vanilla_Power_Spell_VampiresSeduction, True)
    Player.AddSpell(SCS_VampireSpells_Vanilla_Power_Spell_VampiresCommand2, True)
    Player.AddSpell(SCS_VampireSpells_Vanilla_Power_Spell_Nightwalk2, True)
    Player.AddSpell(SCS_VampireSpells_Vanilla_Power_Spell_BloodCauldron, True)
    Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_Status_Stage2)
    Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_Status_Stage3)
    Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_Status_Stage4)
    Player.AddSpell(SCS_Abilities_Vanilla_Spell_Ab_Status_Stage1, False)
    Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_ReverseProgression_Stage5)
    If Player.HasSpell(SCS_Abilities_StrongBlood_Spell_04_Ab as Form)
      Player.RemoveSpell(SCS_Abilities_StrongBlood_Spell_04_Ab)
      GiveBackMyth = True
    EndIf
  EndIf
  Utility.Wait(1.5)
  Player.AddSpell(SCS_Abilities_Vanilla_Spell_Ab_NewMoonlitWaters, False)
  Player.AddSpell(SCS_Abilities_Vanilla_Spell_Ab_TrespassingCurse, False)
  If HasCall
    Player.AddSpell(SCS_VampireSpells_Reward_Power_Spell_VampiresCall, False)
  EndIf
  If GiveBackMyth
    Player.AddSpell(SCS_Abilities_StrongBlood_Spell_04_Ab, False)
  EndIf
EndFunction

Function VampireCure(Actor Player)
  Game.IncrementStat("Vampirism Cures", 1)
  Self.UnregisterforUpdateGameTime()
  VampireStatus = 0
  Self.StopHate(Player, True)
  Player.RemoveSpell(DLC1VampireChange)
  Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_TrespassingCurse)
  Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_NewMoonlitWaters)
  Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_IllusionSpells_AndAbilityHolder)
  Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_SneakBonus)
  Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_ResistFrost_Stage1)
  Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_ResistFrost_Stage2)
  Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_ResistFrost_Stage3)
  Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_ResistFrost_Stage4)
  Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_WeaknessToFire_Stage1)
  Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_WeaknessToFire_Stage2)
  Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_WeaknessToFire_Stage3)
  Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_WeaknessToFire_Stage4)
  Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_SunDamage_Stage1)
  Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_SunDamage_Stage2)
  Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_SunDamage_Stage3)
  Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_SunDamage_Stage4)
  Player.RemoveSpell(SCS_VampireSpells_Vanilla_Spell_VampiricDrain)
  Player.RemoveSpell(SCS_VampireSpells_Vanilla_Power_Spell_VampiresWill)
  Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_ReverseProgression_Stage1)
  Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_ReverseProgression_Stage2)
  Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_ReverseProgression_Stage3)
  Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_ReverseProgression_Stage4)
  Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_Status_Stage1)
  Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_Status_Stage2)
  Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_Status_Stage3)
  Player.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_Status_Stage4)
  Player.RemoveSpell(SCS_VampireSpells_Vanilla_Power_Spell_VampiresSeduction)
  Player.RemoveSpell(SCS_VampireSpells_Vanilla_Power_Spell_Flaywind)
  Player.RemoveSpell(SCS_VampireSpells_Vanilla_Power_Spell_NewObfuscate)
  Player.RemoveSpell(SCS_VampireSpells_Vanilla_Power_Spell_BloodIsPower)
  Player.RemoveSpell(SCS_VampireSpells_Vanilla_Power_Spell_VampiresCommand2)
  Player.RemoveSpell(SCS_VampireSpells_Vanilla_Power_Spell_Nightwalk2)
  Player.RemoveSpell(SCS_VampireSpells_Vanilla_Power_Spell_BloodCauldron)
  If !CureRace
    ; RCS
    Race PlayerRace = RaceCompatibility.GetRaceByVampireRace(Player.GetRace())
    If PlayerRace != None
      Player.SetRace(PlayerRace)
    Else
      Player.SetRace(NordRace)
    EndIf
  Else
    Player.SetRace(CureRace)
  EndIf
  PlayerIsVampire.SetValue(0 as Float)
  Player.DispelSpell(SCS_VampireSpells_Vanilla_Power_Spell_VampiresSight)
  Player.RemoveSpell(SCS_VampireSpells_Vanilla_Power_Spell_VampiresSight)
  SCS_Main500_Quest.TearDownRewardSpells()
  SCS_Mechanics_Global_Wassail_Current.SetValue(0.0)
  Float RestoreAmount = SCS_Mechanics_Global_Wassail_NerfAmount.GetValue()
  If SCS_Stat0
    Player.ModActorValue("Health", RestoreAmount)
  EndIf
  If SCS_Stat1
    Player.ModActorValue(SCS_Stat1, RestoreAmount)
  EndIf
  If SCS_Stat2
    Player.ModActorValue(SCS_Stat2, RestoreAmount)
  EndIf
  SCS_Mechanics_Global_Wassail_NerfAmount.SetValue(0.0)
  Player.DispelSpell(SCS_Abilities_Vanilla_Spell_Ab_ReverseProgression_Stage2N_Proc)
EndFunction

Function StartHate(Actor Player)
  If (SCS_Mechanics_Global_DisableHate.GetValue() == 0 as Float) && !Player.HasSpell(SCS_Abilities_Reward_Spell_NoHate as Form)
    Debug.Trace("SACROSANCT DEBUG: You become hated due to stage 3 -> 4", 0)
    Player.AddtoFaction(VampirePCFaction)
    Int i = 0
    While i < DLC1VampireHateFactions.GetSize()
      (DLC1VampireHateFactions.GetAt(i) as Faction).SetPlayerEnemy(True)
      i += 1
    EndWhile
  EndIf
EndFunction

Function StopHate(Actor Player, Bool akForceStopHate)
  If VampireStatus != 4 || akForceStopHate == True
    Player.RemoveFromFaction(VampirePCFaction)
    Player.SetAttackActorOnSight(False)
    Int i = 0
    While i < DLC1VampireHateFactions.GetSize()
      (DLC1VampireHateFactions.GetAt(i) as Faction).SetPlayerEnemy(False)
      i += 1
    EndWhile
  EndIf
EndFunction
