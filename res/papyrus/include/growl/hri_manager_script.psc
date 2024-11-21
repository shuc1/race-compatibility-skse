;/ Decompiled by Champollion v1.3.2
PEX format v3.2 GameID: 1
Source   : HRI_Manager_Script.psc
Modified : 2022-01-21 20:16:51
Compiled : 2022-01-21 20:16:52
User     : maxim
Computer : CANOPUS
/;
ScriptName HRI_Manager_Script Extends Quest

;-- Variables ---------------------------------------
Float AccumulatedBounty = 0.0
Bool Reequip = False
Bool WillTempt = False

;-- Properties --------------------------------------
Bool Property BlockSpellBasedWereformation = False Auto
Quest Property C03Rampage Auto
LeveledItem Property DLC1DeathItemWerewolf Auto
LeveledItem Property DLC2LItemIngredientsRare Auto
ImageSpaceModifier Property FadeToBlackHoldImod Auto
GlobalVariable Property GameDaysPassed Auto
GlobalVariable Property GameHour Auto
Float Property HRI_Chance Auto
GlobalVariable Property HRI_Events_Global_ImproveHuntersStage Auto
GlobalVariable Property HRI_Events_Global_NightEnd Auto
GlobalVariable Property HRI_Events_Global_NightStart Auto
GlobalVariable Property HRI_Events_Global_TemptationRefusedDelay Auto
Message Property HRI_Events_Message_Spotted Auto
Message Property HRI_Events_Message_Temptation Auto
Message Property HRI_Events_Message_WerebearTotem Auto
Quest Property HRI_Hunters_Repeatable Auto
Spell Property HRI_Lycan_BeastForm_Spell_WasWerewolfChange Auto
MagicEffect Property HRI_Lycan_Effect_BeastForm_WasHardCastState Auto
GlobalVariable Property HRI_Lycan_Global_BattleReset_Amount_Base Auto
GlobalVariable Property HRI_Lycan_Global_BattleReset_Amount_Level Auto
GlobalVariable Property HRI_Lycan_Global_BeastForm_Cooldown Auto
GlobalVariable Property HRI_Lycan_Global_LastTempted Auto
GlobalVariable Property HRI_Lycan_Global_WerebearTotem Auto
GlobalVariable Property HRI_Lycan_Global_WerewolfHunters_Disable Auto
Ingredient Property HRI_Lycan_Ingredient_LycanthropesHeart Auto
Keyword Property HRI_Lycan_Keyword_IsWerecreature Auto
Sound Property HRI_Lycan_Marker_Howl Auto
Message Property HRI_Lycan_Message_BattleReset Auto
Message Property HRI_Lycan_Message_IntegrityError Auto
Message Property HRI_Lycan_Message_IntegrityError_ScriptCheck Auto
Message Property HRI_Lycan_Message_Morph_ReplacerOnCooldown_Fail Auto
Message Property HRI_Lycan_Message_Temptation_SweetDreamsDragonborn Auto
Spell Property HRI_Lycan_Spell_BeastForm Auto
Spell Property HRI_Lycan_Spell_BeastFormCooldown Auto
Spell Property HRI_Lycan_Spell_BeastForm_Beastblood_Ab Auto
Spell Property HRI_Lycan_Spell_BeastForm_ReplacerOnCooldown_Fail Auto
Perk Property HRI_MitigationPerk Auto
Float Property HRI_SendHuntersThreshold Auto
LeveledItem Property LItemApothecaryIngredienstRare75 Auto
LeveledItem Property LItemIngredientsRare Auto
ImageSpaceModifier Property MQ101FadeUpFromBlackImod Auto
Actor Property PlayerRef Auto
Quest Property PlayerWerewolfQuest Auto
GlobalVariable Property TimeScale Auto
Race Property WerewolfBeastRace Auto
ImageSpaceModifier Property WerewolfChangeImod Auto

;-- Functions ---------------------------------------

; Skipped compiler generated GetState

; Skipped compiler generated GotoState

Function StartCooldown()
  ; Empty function
EndFunction

Function TryAskAboutLycanthropy()
  ; Empty function
EndFunction

Event OnInit()
  Utility.Wait(9.0)
  DLC1DeathItemWerewolf.AddForm(HRI_Lycan_Ingredient_LycanthropesHeart as Form, 1, 1)
  LItemIngredientsRare.AddForm(HRI_Lycan_Ingredient_LycanthropesHeart as Form, 1, 1)
  DLC2LItemIngredientsRare.AddForm(HRI_Lycan_Ingredient_LycanthropesHeart as Form, 1, 1)
  LItemApothecaryIngredienstRare75.AddForm(HRI_Lycan_Ingredient_LycanthropesHeart as Form, 1, 1)
  If PlayerRef.HasSpell(HRI_Lycan_Spell_BeastForm_Beastblood_Ab as Form)
    PlayerRef.RemoveSpell(HRI_Lycan_Spell_BeastForm_Beastblood_Ab)
    Utility.Wait(2.0)
    PlayerRef.AddSpell(HRI_Lycan_Spell_BeastForm_Beastblood_Ab, False)
  EndIf
  If !WerewolfBeastRace.HasKeyword(HRI_Lycan_Keyword_IsWerecreature)
    HRI_Lycan_Message_IntegrityError.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
  EndIf
  Bool Failed = False
  If (PlayerWerewolfQuest as playerwerewolfchangescript).PassIntegrityCheck() != 777 || (C03Rampage as c03rampagequest).PassIntegrityCheck() != 777
    HRI_Lycan_Message_IntegrityError_ScriptCheck.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
  EndIf
  Self.RegisterForTrackedStatsEvent()
EndEvent

Event OnTrackedStatsEvent(String asStatFilter, Int aiStatValue)
  If asStatFilter == "Eastmarch Bounty" || asStatFilter == "Falkreath Bounty" || asStatFilter == "Eastmarch Bounty" || asStatFilter == "Haafingar Bounty" || asStatFilter == "Hjaalmarch Bounty" || asStatFilter == "The Pale Bounty" || asStatFilter == "The Reach Bounty" || asStatFilter == "The Rift Bounty" || asStatFilter == "Tribal Orcs Bounty" || asStatFilter == "Whiterun Bounty" || asStatFilter == "Winterhold Bounty"
    If PlayerRef.HasMagicEffect(HRI_Lycan_Effect_BeastForm_WasHardCastState) && !HRI_Hunters_Repeatable.IsRunning() && !C03Rampage.IsRunning()
      If Utility.RandomFloat(0.0, 1.0) < HRI_Chance
        Self.AdvanceBounty(1.0)
      EndIf
    EndIf
  EndIf
EndEvent

Function AdvanceBounty(Float afAmount)
  If (HRI_Lycan_Global_WerewolfHunters_Disable.GetValue() != 1 as Float) && !HRI_Hunters_Repeatable.IsRunning()
    AccumulatedBounty += afAmount
    Self.TripQuest()
  EndIf
EndFunction

Function TripQuest()
  If (HRI_Lycan_Global_WerewolfHunters_Disable.GetValue() != 1 as Float) && !HRI_Hunters_Repeatable.IsRunning()
    Float SendHuntersThreshold = HRI_SendHuntersThreshold
    If PlayerRef.HasPerk(HRI_MitigationPerk)
      SendHuntersThreshold *= 5.0
    EndIf
    If AccumulatedBounty >= SendHuntersThreshold
      HRI_Hunters_Repeatable.Start()
      Utility.Wait(3.0)
      If HRI_Hunters_Repeatable.IsRunning()
        HRI_Events_Global_ImproveHuntersStage.Mod(1 as Float)
        AccumulatedBounty = 0.0
      EndIf
    EndIf
  EndIf
EndFunction

Function PrepareToTempt()
  Float Today = GameDaysPassed.GetValue()
  Float CanTemptFrom = HRI_Lycan_Global_LastTempted.GetValue()
  If CanTemptFrom <= Today && !PlayerRef.HasSpell(HRI_Lycan_BeastForm_Spell_WasWerewolfChange as Form) && (GameHour.GetValue() >= HRI_Events_Global_NightStart.GetValue() || GameHour.GetValue() < HRI_Events_Global_NightEnd.GetValue()) && !PlayerRef.IsInInterior() && Weather.GetCurrentWeather().GetClassification() == 0
    WillTempt = True
    HRI_Lycan_Message_Temptation_SweetDreamsDragonborn.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    FadeToBlackHoldImod.Apply(1.0)
  Else
    WillTempt = False
  EndIf
EndFunction

Function Tempt()
  If WillTempt
    If HRI_Events_Message_Temptation.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0) == 0
      HRI_Lycan_BeastForm_Spell_WasWerewolfChange.Cast(PlayerRef as ObjectReference, None)
    EndIf
    HRI_Lycan_Global_LastTempted.SetValue(GameDaysPassed.GetValue() + HRI_Events_Global_TemptationRefusedDelay.GetValue())
    MQ101FadeUpFromBlackImod.Apply(1.0)
    FadeToBlackHoldImod.Remove()
  EndIf
EndFunction

Function IncrementBattleReset(Int aiLevel)
  If PlayerRef.HasSpell(HRI_Lycan_Spell_BeastForm as Form)
    
  EndIf
EndFunction

Function ShowMessage()
  HRI_Lycan_Message_Morph_ReplacerOnCooldown_Fail.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
EndFunction

Function EndCooldown()
  WerewolfChangeImod.Apply(1.0)
  HRI_Lycan_Marker_Howl.Play(PlayerRef as ObjectReference)
  HRI_Lycan_Message_BattleReset.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
EndFunction
