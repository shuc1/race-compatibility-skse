;/ Decompiled by Champollion v1.3.2
PEX format v3.2 GameID: 1
Source   : PlayerVampireQuestScript.psc
Modified : 2021-05-02 19:06:38
Compiled : 2021-05-02 19:06:39
User     : maxim
Computer : CANOPUS
/;
ScriptName PlayerVampireQuestScript Extends Quest conditional

;-- Variables ---------------------------------------
Int CurrentAge = 0
Spell CurrentSpell
Spell RacialSpell

;-- Properties --------------------------------------
FormList Property CrimeFactions Auto
Race Property CureRace Auto
FormList Property DLC1CrimeFactions Auto
Race Property DLC1VampireBeastRace Auto
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
Actor Property Player Auto
GlobalVariable Property PlayerIsVampire Auto
String Property SQL_ActorValue Auto
String Property SQL_ActorValueNegative Auto
String Property SQL_ActorValueNegativeHalf Auto
Message Property SQL_Age_Message_AgeTo2 Auto
Message Property SQL_Age_Message_AgeTo3 Auto
Message Property SQL_Age_Message_AgeTo4 Auto
Message Property SQL_Age_Message_AgeTo5 Auto
Message Property SQL_Age_Message_AgeTo6 Auto
Message Property SQL_Help_Hunger Auto
GlobalVariable Property SQL_Mechanics_Global_Age Auto
GlobalVariable Property SQL_Mechanics_Global_AgeToStarveResistMult Auto
GlobalVariable Property SQL_Mechanics_Global_Age_Threshold Auto
GlobalVariable Property SQL_Mechanics_Global_Age_Threshold_Add Auto
GlobalVariable Property SQL_Mechanics_Global_Age_Threshold_Base Auto
Message Property SQL_Mechanics_Message_RaceBroken Auto
Message Property SQL_Mechanics_Message_ScriptsBroken Auto
Message Property SQL_Mechanics_Message_VampireFeed Auto
Message Property SQL_Mechanics_Message_VampireProgressionStage2 Auto
Message Property SQL_Mechanics_Message_VampireProgressionStage3 Auto
Message Property SQL_Mechanics_Message_VampireProgressionStage4 Auto
Spell Property SQL_Mechanics_Spell_HiddenVampireAbilities_Ab Auto
Spell Property SQL_Mortal_Spell_Bad_Forsaken_Ab Auto
Spell Property SQL_Mortal_Spell_Bad_MockeryOfLife_Ab Auto
Spell Property SQL_Mortal_Spell_Good_Dominate_Ab Auto
Spell Property SQL_Mortal_Spell_Good_FierceHunger_Ab Auto
Spell Property SQL_Mortal_Spell_Good_NightstalkersStrength_Ab Auto
Spell Property SQL_Mortal_Spell_Good_StillHeart_Ab Auto
Spell Property SQL_Mortal_Spell_Good_UnderTheIce_Ab Auto
Spell Property SQL_Mortal_Spell_Power_VampiresSeduction Auto
Spell Property SQL_Mortal_Spell_Power_VampiresSight Auto
Spell Property SQL_Mortal_Spell_ResistDisease_Ab Auto
Spell Property SQL_Mortal_Spell_ResistFrost_Ab_Stage1 Auto
Spell Property SQL_Mortal_Spell_ResistFrost_Ab_Stage2 Auto
Spell Property SQL_Mortal_Spell_ResistFrost_Ab_Stage3 Auto
Spell Property SQL_Mortal_Spell_ResistFrost_Ab_Stage4 Auto
Spell Property SQL_Mortal_Spell_SunDamage_Ab_Stage1 Auto
Spell Property SQL_Mortal_Spell_SunDamage_Ab_Stage2 Auto
Spell Property SQL_Mortal_Spell_SunDamage_Ab_Stage3 Auto
Spell Property SQL_Mortal_Spell_SunDamage_Ab_Stage4 Auto
Spell Property SQL_Mortal_Spell_VampiricDrain_Stage1 Auto
Spell Property SQL_Mortal_Spell_VampiricDrain_Stage2_Deprecated Auto
Spell Property SQL_Mortal_Spell_VampiricDrain_Stage3_Deprecated Auto
Spell Property SQL_Mortal_Spell_VampiricDrain_Stage4_Deprecated Auto
Spell Property SQL_Mortal_Spell_WeaknessToFire_Ab_Stage1 Auto
Spell Property SQL_Mortal_Spell_WeaknessToFire_Ab_Stage2 Auto
Spell Property SQL_Mortal_Spell_WeaknessToFire_Ab_Stage3 Auto
Spell Property SQL_Mortal_Spell_WeaknessToFire_Ab_Stage4 Auto
FormList Property SQL_Races Auto
FormList Property SQL_RacesVampire Auto
FormList Property SQL_Racial Auto
MagicEffect Property SQL_Racial_Effect_HighElf_Ab Auto
MagicEffect Property SQL_Racial_Effect_Redguard_Ab Auto
MagicEffect Property SQL_Racial_Effect_SnowElf_Ab Auto
GlobalVariable Property SQL_Ranks_Global_Negative_025 Auto
GlobalVariable Property SQL_Ranks_Global_Negative_050 Auto
GlobalVariable Property SQL_Ranks_Global_Positive_105 Auto
GlobalVariable Property SQL_Ranks_Global_Positive_110 Auto
Spell Property SQL_Scaling_Spell_Stage1_Ab Auto
Spell Property SQL_Scaling_Spell_Stage2_Ab Auto
Spell Property SQL_Scaling_Spell_Stage3_Ab Auto
Spell Property SQL_Scaling_Spell_Stage4_Ab Auto
GlobalVariable Property SQL_Stages_Global_Dominate_IllusionBonus Auto
Spell Property SQL_Stages_Spell_Stage2_Power Auto
Spell Property SQL_Stages_Spell_Stage3_Power Auto
Spell Property SQL_Stages_Spell_Stage4_Power Auto
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

Spell Function GetCurrentSpell()
  Return CurrentSpell
EndFunction

Spell Function SetCurrentSpell(Spell akSpell)
  CurrentSpell = akSpell
EndFunction

Int Function TestIntegrity()
  Return 777
EndFunction

Event OnUpdateGameTime()
  Self.SetAgeVariables()
  FeedTimer = GameDaysPassed.value - LastFeedTime
  If Game.IsMovementControlsEnabled() && Game.IsFightingControlsEnabled() && Player.GetCombatState() == 0 && !Player.HasMagicEffect(DLC1VampireChangeEffect) && !Player.HasMagicEffect(DLC1VampireChangeFXEffect)
    SQL_Help_Hunger.ShowAsHelpMessage("SQL_HungerStage2Event", 5.0, 0 as Float, 1)
    Self.Devolve(False)
  EndIf
  If Player.GetRace() == DLC1VampireBeastRace
    Self.AdvanceAge(Player, 2 as Float)
  ElseIf Player.HasMagicEffect(SQL_Racial_Effect_HighElf_Ab) && VampireStatus == 1
    Self.AdvanceAge(Player, 1.299999952)
  ElseIf Player.HasMagicEffect(SQL_Racial_Effect_Redguard_Ab)
    Self.AdvanceAge(Player, 1.149999976)
  Else
    Self.AdvanceAge(Player, 1 as Float)
  EndIf
EndEvent

Bool Function Devolve(Bool abForceDevolve)
  Float RacialThresholdMult = 1.0
  If Player.HasMagicEffect(SQL_Racial_Effect_Redguard_Ab)
    RacialThresholdMult = 1.5
  ElseIf Player.HasMagicEffect(SQL_Racial_Effect_HighElf_Ab) && VampireStatus == 1
    RacialThresholdMult = 2.0
  EndIf
  Float AgeThresholdMult = 1.0 + (CurrentAge as Float * SQL_Mechanics_Global_AgeToStarveResistMult.GetValue())
  Float TotalMult = RacialThresholdMult * AgeThresholdMult
  If (FeedTimer >= (3 as Float * TotalMult) || abForceDevolve) && VampireStatus == 3 && !Player.HasMagicEffect(SQL_Racial_Effect_SnowElf_Ab)
    VampireFeedReady.SetValue(3 as Float)
    SQL_Mechanics_Message_VampireProgressionStage4.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    VampireStatus = 4
    Self.VampireProgression(Player, 4)
    FeedTimer == (3 as Float * RacialThresholdMult)
    Self.UnregisterforUpdateGameTime()
  ElseIf (FeedTimer >= (2 as Float * TotalMult) || abForceDevolve) && VampireStatus == 2
    VampireFeedReady.SetValue(2 as Float)
    SQL_Mechanics_Message_VampireProgressionStage3.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    VampireStatus = 3
    Self.VampireProgression(Player, 3)
    FeedTimer == (2 as Float * RacialThresholdMult)
  ElseIf (FeedTimer >= (1 as Float * TotalMult) || abForceDevolve) && VampireStatus == 1
    VampireFeedReady.SetValue(1 as Float)
    SQL_Mechanics_Message_VampireProgressionStage2.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    VampireStatus = 2
    Self.VampireProgression(Player, 2)
    FeedTimer == (1 as Float * RacialThresholdMult)
  EndIf
EndFunction

Function VampireFeedBed()
  Game.GetPlayer().PlayIdle(VampireFeedingBedRight)
EndFunction

Function VampireFeedBedRoll()
  Game.GetPlayer().PlayIdle(VampireFeedingBedrollRight)
EndFunction

Function VampireChange(Actor Target)
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
  Int RaceID = SQL_Races.Find(PlayerRace as Form)
  If RaceID >= 0
    RacialSpell = SQL_Racial.GetAt(RaceID) as Spell
    Target.SetRace(SQL_RacesVampire.GetAt(RaceID) as Race)
    Target.AddSpell(RacialSpell, False)
  Else
    ; RCS
    Race PlayerVampireRace = RaceCompatibility.GetVampireRaceByRace(PlayerRace)
    If PlayerVampireRace != None
      ; Default racial spell for custom races
      Target.SetRace(PlayerVampireRace)
      RacialSpell = SQL_Racial.GetAt(0) as Spell
      Target.AddSpell(RacialSpell, False)
    Else
      SQL_Mechanics_Message_RaceBroken.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
      Target.SetRace(NordRaceVampire)
    EndIf
  EndIf
  VampireCureDisease.Cast(Target as ObjectReference, None)
  VampireStatus = 1
  Self.VampireProgression(Player, 1)
  Self.AddVampireSpells(Player)
  Self.RegisterForUpdateGameTime(1.0)
  LastFeedTime = GameDaysPassed.value
  PlayerIsVampire.SetValue(1 as Float)
  Utility.Wait(1.0)
  Game.EnablePlayerControls(True, True, True, True, True, True, True, True, 0)
  If VC01.GetStageDone(200) == 1 as Bool
    VC01.SetStage(25)
  EndIf
  CurrentAge = 0
  Player.SetActorValue(SQL_ActorValue, 0.0)
  Player.SetActorValue(SQL_ActorValueNegative, 0.25)
  SQL_Mechanics_Global_Age_Threshold.SetValue(SQL_Mechanics_Global_Age_Threshold_Base.GetValue())
  SQL_Ranks_Global_Positive_105.SetValue(5 as Float)
  SQL_Ranks_Global_Positive_110.SetValue(10 as Float)
  SQL_Ranks_Global_Negative_025.SetValue(75 as Float)
  Player.SendVampirismStateChanged(True)
  Self.SetAgeVariables()
EndFunction

Function VampireFeed()
  VampireTransformDecreaseISMD.applyCrossFade(2.0)
  Utility.Wait(2.0)
  ImageSpaceModifier.removeCrossFade(1.0)
  Game.IncrementStat("Necks Bitten", 1)
  SQL_Mechanics_Message_VampireFeed.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
  VampireFeedReady.SetValue(0 as Float)
  LastFeedTime = GameDaysPassed.value
  VampireStatus = 1
  Self.VampireProgression(Player, 1)
  Self.StopHate(Player, False)
  Self.UnregisterforUpdateGameTime()
  Self.RegisterForUpdateGameTime(1.0)
EndFunction

Function VampireProgression(Actor akPlayer, Int VampireStage)
  If VampireStage == 2
    VampireTransformIncreaseISMD.applyCrossFade(2.0)
    Utility.Wait(2.0)
    ImageSpaceModifier.removeCrossFade(1.0)
    Player.RemoveSpell(SQL_Mortal_Spell_ResistFrost_Ab_Stage1)
    Player.AddSpell(SQL_Mortal_Spell_ResistFrost_Ab_Stage2, False)
    Player.RemoveSpell(SQL_Mortal_Spell_ResistFrost_Ab_Stage3)
    Player.RemoveSpell(SQL_Mortal_Spell_ResistFrost_Ab_Stage4)
    Player.RemoveSpell(SQL_Mortal_Spell_WeaknessToFire_Ab_Stage1)
    Player.AddSpell(SQL_Mortal_Spell_WeaknessToFire_Ab_Stage2, False)
    Player.RemoveSpell(SQL_Mortal_Spell_WeaknessToFire_Ab_Stage3)
    Player.RemoveSpell(SQL_Mortal_Spell_WeaknessToFire_Ab_Stage4)
    Player.RemoveSpell(SQL_Mortal_Spell_SunDamage_Ab_Stage1)
    Player.AddSpell(SQL_Mortal_Spell_SunDamage_Ab_Stage2, False)
    Player.RemoveSpell(SQL_Mortal_Spell_SunDamage_Ab_Stage3)
    Player.RemoveSpell(SQL_Mortal_Spell_SunDamage_Ab_Stage4)
    Player.RemoveSpell(SQL_Stages_Spell_Stage2_Power)
    Player.AddSpell(SQL_Stages_Spell_Stage3_Power, False)
    Player.AddSpell(SQL_Stages_Spell_Stage4_Power, False)
    Player.RemoveSpell(SQL_Scaling_Spell_Stage1_Ab)
    Player.AddSpell(SQL_Scaling_Spell_Stage2_Ab, False)
    Player.RemoveSpell(SQL_Scaling_Spell_Stage3_Ab)
    Player.RemoveSpell(SQL_Scaling_Spell_Stage4_Ab)
  ElseIf VampireStage == 3
    VampireTransformIncreaseISMD.applyCrossFade(2.0)
    Utility.Wait(2.0)
    ImageSpaceModifier.removeCrossFade(1.0)
    Player.RemoveSpell(SQL_Mortal_Spell_ResistFrost_Ab_Stage1)
    Player.RemoveSpell(SQL_Mortal_Spell_ResistFrost_Ab_Stage2)
    Player.AddSpell(SQL_Mortal_Spell_ResistFrost_Ab_Stage3, False)
    Player.RemoveSpell(SQL_Mortal_Spell_ResistFrost_Ab_Stage4)
    Player.RemoveSpell(SQL_Mortal_Spell_WeaknessToFire_Ab_Stage1)
    Player.RemoveSpell(SQL_Mortal_Spell_WeaknessToFire_Ab_Stage2)
    Player.AddSpell(SQL_Mortal_Spell_WeaknessToFire_Ab_Stage3, False)
    Player.RemoveSpell(SQL_Mortal_Spell_WeaknessToFire_Ab_Stage4)
    Player.RemoveSpell(SQL_Mortal_Spell_SunDamage_Ab_Stage1)
    Player.RemoveSpell(SQL_Mortal_Spell_SunDamage_Ab_Stage2)
    Player.AddSpell(SQL_Mortal_Spell_SunDamage_Ab_Stage3, False)
    Player.RemoveSpell(SQL_Mortal_Spell_SunDamage_Ab_Stage4)
    Player.RemoveSpell(SQL_Stages_Spell_Stage2_Power)
    Player.RemoveSpell(SQL_Stages_Spell_Stage3_Power)
    Player.AddSpell(SQL_Stages_Spell_Stage4_Power, False)
    Player.RemoveSpell(SQL_Scaling_Spell_Stage1_Ab)
    Player.RemoveSpell(SQL_Scaling_Spell_Stage2_Ab)
    Player.AddSpell(SQL_Scaling_Spell_Stage3_Ab, False)
    Player.RemoveSpell(SQL_Scaling_Spell_Stage4_Ab)
  ElseIf VampireStage == 4
    VampireTransformIncreaseISMD.applyCrossFade(2.0)
    Utility.Wait(2.0)
    ImageSpaceModifier.removeCrossFade(1.0)
    Player.RemoveSpell(SQL_Mortal_Spell_ResistFrost_Ab_Stage1)
    Player.RemoveSpell(SQL_Mortal_Spell_ResistFrost_Ab_Stage2)
    Player.RemoveSpell(SQL_Mortal_Spell_ResistFrost_Ab_Stage3)
    Player.AddSpell(SQL_Mortal_Spell_ResistFrost_Ab_Stage4, False)
    Player.RemoveSpell(SQL_Mortal_Spell_WeaknessToFire_Ab_Stage1)
    Player.RemoveSpell(SQL_Mortal_Spell_WeaknessToFire_Ab_Stage2)
    Player.RemoveSpell(SQL_Mortal_Spell_WeaknessToFire_Ab_Stage3)
    Player.AddSpell(SQL_Mortal_Spell_WeaknessToFire_Ab_Stage4, False)
    Player.RemoveSpell(SQL_Mortal_Spell_SunDamage_Ab_Stage1)
    Player.RemoveSpell(SQL_Mortal_Spell_SunDamage_Ab_Stage2)
    Player.RemoveSpell(SQL_Mortal_Spell_SunDamage_Ab_Stage3)
    Player.AddSpell(SQL_Mortal_Spell_SunDamage_Ab_Stage4, False)
    Player.RemoveSpell(SQL_Stages_Spell_Stage2_Power)
    Player.RemoveSpell(SQL_Stages_Spell_Stage3_Power)
    Player.RemoveSpell(SQL_Stages_Spell_Stage4_Power)
    Player.RemoveSpell(SQL_Scaling_Spell_Stage1_Ab)
    Player.RemoveSpell(SQL_Scaling_Spell_Stage2_Ab)
    Player.RemoveSpell(SQL_Scaling_Spell_Stage3_Ab)
    Player.AddSpell(SQL_Scaling_Spell_Stage4_Ab, False)
    Self.StartHate(Player)
  ElseIf VampireStage == 1
    Player.AddSpell(SQL_Mortal_Spell_ResistFrost_Ab_Stage1, False)
    Player.RemoveSpell(SQL_Mortal_Spell_ResistFrost_Ab_Stage2)
    Player.RemoveSpell(SQL_Mortal_Spell_ResistFrost_Ab_Stage3)
    Player.RemoveSpell(SQL_Mortal_Spell_ResistFrost_Ab_Stage4)
    Player.AddSpell(SQL_Mortal_Spell_WeaknessToFire_Ab_Stage1, False)
    Player.RemoveSpell(SQL_Mortal_Spell_WeaknessToFire_Ab_Stage2)
    Player.RemoveSpell(SQL_Mortal_Spell_WeaknessToFire_Ab_Stage3)
    Player.RemoveSpell(SQL_Mortal_Spell_WeaknessToFire_Ab_Stage4)
    Player.RemoveSpell(SQL_Mortal_Spell_SunDamage_Ab_Stage2)
    Player.RemoveSpell(SQL_Mortal_Spell_SunDamage_Ab_Stage3)
    Player.RemoveSpell(SQL_Mortal_Spell_SunDamage_Ab_Stage4)
    Player.AddSpell(SQL_Mortal_Spell_SunDamage_Ab_Stage1, False)
    Player.AddSpell(SQL_Stages_Spell_Stage2_Power, False)
    Player.AddSpell(SQL_Stages_Spell_Stage3_Power, False)
    Player.AddSpell(SQL_Stages_Spell_Stage4_Power, False)
    Player.AddSpell(SQL_Scaling_Spell_Stage1_Ab, False)
    Player.RemoveSpell(SQL_Scaling_Spell_Stage2_Ab)
    Player.RemoveSpell(SQL_Scaling_Spell_Stage3_Ab)
    Player.RemoveSpell(SQL_Scaling_Spell_Stage4_Ab)
  EndIf
EndFunction

Function AddVampireSpells(Actor akPlayer)
  Player.AddSpell(SQL_Mortal_Spell_VampiricDrain_Stage1, False)
  Player.AddSpell(SQL_Mortal_Spell_Power_VampiresSight, False)
  Player.AddSpell(SQL_Mortal_Spell_Power_VampiresSeduction, False)
  Player.AddSpell(SQL_Mortal_Spell_Bad_Forsaken_Ab, False)
  Player.AddSpell(SQL_Mortal_Spell_Bad_MockeryOfLife_Ab, False)
  Player.AddSpell(SQL_Mortal_Spell_Good_Dominate_Ab, False)
  Player.AddSpell(SQL_Mortal_Spell_Good_FierceHunger_Ab, False)
  Player.AddSpell(SQL_Mortal_Spell_Good_StillHeart_Ab, False)
  Player.AddSpell(SQL_Mortal_Spell_Good_UnderTheIce_Ab, False)
  Player.AddSpell(SQL_Mechanics_Spell_HiddenVampireAbilities_Ab, False)
  Player.AddSpell(SQL_Mortal_Spell_Good_NightstalkersStrength_Ab, False)
EndFunction

Function VampireCure(Actor akPlayer)
  Game.IncrementStat("Vampirism Cures", 1)
  Self.UnregisterforUpdateGameTime()
  VampireStatus = 0
  Self.StopHate(Player, True)
  Player.RemoveSpell(SQL_Mortal_Spell_ResistFrost_Ab_Stage1)
  Player.RemoveSpell(SQL_Mortal_Spell_ResistFrost_Ab_Stage2)
  Player.RemoveSpell(SQL_Mortal_Spell_ResistFrost_Ab_Stage3)
  Player.RemoveSpell(SQL_Mortal_Spell_ResistFrost_Ab_Stage4)
  Player.RemoveSpell(SQL_Mortal_Spell_WeaknessToFire_Ab_Stage1)
  Player.RemoveSpell(SQL_Mortal_Spell_WeaknessToFire_Ab_Stage2)
  Player.RemoveSpell(SQL_Mortal_Spell_WeaknessToFire_Ab_Stage3)
  Player.RemoveSpell(SQL_Mortal_Spell_WeaknessToFire_Ab_Stage4)
  Player.RemoveSpell(SQL_Mortal_Spell_SunDamage_Ab_Stage1)
  Player.RemoveSpell(SQL_Mortal_Spell_SunDamage_Ab_Stage2)
  Player.RemoveSpell(SQL_Mortal_Spell_SunDamage_Ab_Stage3)
  Player.RemoveSpell(SQL_Mortal_Spell_SunDamage_Ab_Stage4)
  Player.RemoveSpell(SQL_Stages_Spell_Stage2_Power)
  Player.RemoveSpell(SQL_Stages_Spell_Stage3_Power)
  Player.RemoveSpell(SQL_Stages_Spell_Stage4_Power)
  Player.RemoveSpell(SQL_Scaling_Spell_Stage1_Ab)
  Player.RemoveSpell(SQL_Scaling_Spell_Stage2_Ab)
  Player.RemoveSpell(SQL_Scaling_Spell_Stage3_Ab)
  Player.RemoveSpell(SQL_Scaling_Spell_Stage4_Ab)
  Player.RemoveSpell(SQL_Mortal_Spell_VampiricDrain_Stage1)
  Player.RemoveSpell(SQL_Mortal_Spell_VampiricDrain_Stage2_Deprecated)
  Player.RemoveSpell(SQL_Mortal_Spell_VampiricDrain_Stage3_Deprecated)
  Player.RemoveSpell(SQL_Mortal_Spell_VampiricDrain_Stage4_Deprecated)
  Player.RemoveSpell(SQL_Mortal_Spell_Power_VampiresSight)
  Player.RemoveSpell(SQL_Mortal_Spell_Power_VampiresSeduction)
  Player.RemoveSpell(SQL_Mortal_Spell_Bad_Forsaken_Ab)
  Player.RemoveSpell(SQL_Mortal_Spell_Bad_MockeryOfLife_Ab)
  Player.RemoveSpell(SQL_Mortal_Spell_Good_Dominate_Ab)
  Player.RemoveSpell(SQL_Mortal_Spell_Good_FierceHunger_Ab)
  Player.RemoveSpell(SQL_Mortal_Spell_Good_StillHeart_Ab)
  Player.RemoveSpell(SQL_Mortal_Spell_Good_UnderTheIce_Ab)
  Player.RemoveSpell(SQL_Mortal_Spell_Good_NightstalkersStrength_Ab)
  CurrentAge = 0
  Player.SetActorValue(SQL_ActorValue, 0.0)
  Player.SetActorValue(SQL_ActorValueNegative, 0.25)
  SQL_Mechanics_Global_Age_Threshold.SetValue(SQL_Mechanics_Global_Age_Threshold_Base.GetValue())
  SQL_Ranks_Global_Positive_105.SetValue(5 as Float)
  SQL_Ranks_Global_Positive_110.SetValue(10 as Float)
  SQL_Ranks_Global_Negative_025.SetValue(75 as Float)
  SQL_Stages_Global_Dominate_IllusionBonus.SetValue(15 as Float)
  If CurrentSpell
    Player.RemoveSpell(CurrentSpell)
    CurrentSpell = None
  EndIf
  Player.RemoveSpell(SQL_Mechanics_Spell_HiddenVampireAbilities_Ab)
  If !CureRace
    ; RCS, default to Nord
    Race PlayerRace = RaceCompatibility.GetRaceByVampireRace(Player.GetRace())
    If PlayerRace != None
      Player.SetRace(PlayerRace)
    Else
      Player.SetRace(NordRace)
    EndIf
  Else
    Player.SetRace(CureRace)
  EndIf
  Player.RemoveSpell(RacialSpell)
  PlayerIsVampire.SetValue(0 as Float)
  Player.DispelSpell(SQL_Mortal_Spell_Power_VampiresSight)
  Player.RemoveSpell(SQL_Mortal_Spell_Power_VampiresSight)
  Player.SendVampirismStateChanged(False)
EndFunction

Function StartHate(Actor akPlayer)
  Player.AddtoFaction(VampirePCFaction)
  Int i = 0
  While i < DLC1VampireHateFactions.GetSize()
    (DLC1VampireHateFactions.GetAt(i) as Faction).SetPlayerEnemy(True)
    i += 1
  EndWhile
EndFunction

Function StopHate(Actor akPlayer, Bool akForceStopHate)
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

Function AdvanceAge(Actor akPlayer, Float afAgeAmount)
  If CurrentAge < 5
    SQL_Mechanics_Global_Age.Mod(afAgeAmount)
    If SQL_Mechanics_Global_Age.GetValue() >= SQL_Mechanics_Global_Age_Threshold.GetValue()
      CurrentAge += 1
      If CurrentAge == 1
        SQL_Age_Message_AgeTo2.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
        Self.SetAgeVariables()
      ElseIf CurrentAge == 2
        SQL_Age_Message_AgeTo3.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
        Self.SetAgeVariables()
      ElseIf CurrentAge == 3
        SQL_Age_Message_AgeTo4.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
        Self.SetAgeVariables()
      ElseIf CurrentAge == 4
        SQL_Age_Message_AgeTo5.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
        Self.SetAgeVariables()
      ElseIf CurrentAge == 5
        SQL_Age_Message_AgeTo6.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
        Self.SetAgeVariables()
      EndIf
      If CurrentAge < 5
        SQL_Mechanics_Global_Age.SetValue(0 as Float)
        SQL_Mechanics_Global_Age_Threshold.Mod(SQL_Mechanics_Global_Age_Threshold.GetValue() + SQL_Mechanics_Global_Age_Threshold_Add.GetValue())
      Else
        SQL_Mechanics_Global_Age.SetValue(SQL_Mechanics_Global_Age_Threshold.GetValue())
      EndIf
    EndIf
  EndIf
EndFunction

Function SetAgeVariables()
  If CurrentAge == 0
    Player.SetActorValue(SQL_ActorValue, 0.0)
    Player.SetActorValue(SQL_ActorValueNegative, 0.25)
    Player.SetActorValue(SQL_ActorValueNegativeHalf, 0.5)
    SQL_Ranks_Global_Positive_105.SetValue(5 as Float)
    SQL_Ranks_Global_Positive_110.SetValue(10 as Float)
    SQL_Ranks_Global_Negative_025.SetValue(75 as Float)
    SQL_Ranks_Global_Negative_050.SetValue(50 as Float)
    SQL_Stages_Global_Dominate_IllusionBonus.SetValue(15 as Float)
  ElseIf CurrentAge == 1
    Player.SetActorValue(SQL_ActorValue, 100.0)
    Player.SetActorValue(SQL_ActorValueNegative, 0.349999994)
    Player.SetActorValue(SQL_ActorValueNegativeHalf, 0.550000012)
    SQL_Ranks_Global_Positive_105.SetValue(10 as Float)
    SQL_Ranks_Global_Positive_110.SetValue(20 as Float)
    SQL_Ranks_Global_Negative_025.SetValue(65 as Float)
    SQL_Ranks_Global_Negative_050.SetValue(45 as Float)
    SQL_Stages_Global_Dominate_IllusionBonus.SetValue(20 as Float)
  ElseIf CurrentAge == 2
    Player.SetActorValue(SQL_ActorValue, 200.0)
    Player.SetActorValue(SQL_ActorValueNegative, 0.449999988)
    Player.SetActorValue(SQL_ActorValueNegativeHalf, 0.600000024)
    SQL_Ranks_Global_Positive_105.SetValue(15 as Float)
    SQL_Ranks_Global_Positive_110.SetValue(30 as Float)
    SQL_Ranks_Global_Negative_025.SetValue(55 as Float)
    SQL_Ranks_Global_Negative_050.SetValue(40 as Float)
    SQL_Stages_Global_Dominate_IllusionBonus.SetValue(25 as Float)
  ElseIf CurrentAge == 3
    Player.SetActorValue(SQL_ActorValue, 300.0)
    Player.SetActorValue(SQL_ActorValueNegative, 0.550000012)
    Player.SetActorValue(SQL_ActorValueNegativeHalf, 0.649999976)
    SQL_Ranks_Global_Positive_105.SetValue(20 as Float)
    SQL_Ranks_Global_Positive_110.SetValue(40 as Float)
    SQL_Ranks_Global_Negative_025.SetValue(45 as Float)
    SQL_Ranks_Global_Negative_050.SetValue(35 as Float)
    SQL_Stages_Global_Dominate_IllusionBonus.SetValue(30 as Float)
  ElseIf CurrentAge == 4
    Player.SetActorValue(SQL_ActorValue, 400.0)
    Player.SetActorValue(SQL_ActorValueNegative, 0.649999976)
    Player.SetActorValue(SQL_ActorValueNegativeHalf, 0.699999988)
    SQL_Ranks_Global_Positive_105.SetValue(25 as Float)
    SQL_Ranks_Global_Positive_110.SetValue(50 as Float)
    SQL_Ranks_Global_Negative_025.SetValue(35 as Float)
    SQL_Ranks_Global_Negative_050.SetValue(30 as Float)
    SQL_Stages_Global_Dominate_IllusionBonus.SetValue(35 as Float)
  ElseIf CurrentAge == 5
    Player.SetActorValue(SQL_ActorValue, 500.0)
    Player.SetActorValue(SQL_ActorValueNegative, 0.75)
    Player.SetActorValue(SQL_ActorValueNegativeHalf, 0.75)
    SQL_Ranks_Global_Positive_105.SetValue(30 as Float)
    SQL_Ranks_Global_Positive_110.SetValue(60 as Float)
    SQL_Ranks_Global_Negative_025.SetValue(25 as Float)
    SQL_Ranks_Global_Negative_050.SetValue(25 as Float)
    SQL_Stages_Global_Dominate_IllusionBonus.SetValue(40 as Float)
  EndIf
EndFunction
