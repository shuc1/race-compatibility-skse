;/ Decompiled by Champollion v1.3.2
PEX format v3.2 GameID: 1
Source   : C03RampageQuest.psc
Modified : 2020-09-17 02:09:10
Compiled : 2020-09-17 02:09:11
User     : maxim
Computer : CANOPUS
/;
ScriptName C03RampageQuest Extends Quest

;-- Variables ---------------------------------------
Race __originalRace
Bool __turningBack = False

;-- Properties --------------------------------------
ReferenceAlias Property Aela Auto
ObjectReference Property AelaLycanStash Auto
Outfit Property AelaOutfit Auto
ReferenceAlias Property Athis Auto
Spell Property BeastForm Auto
Idle Property BleedOutIdle Auto
MusicType Property CombatMusic Auto
FormList Property CrimeFactions Auto
Shout Property CurrentHowl Auto
WordOfPower Property CurrentHowlWord1 Auto
WordOfPower Property CurrentHowlWord2 Auto
WordOfPower Property CurrentHowlWord3 Auto
ImageSpaceModifier Property FadeFromBlack Auto
Float Property FadeSeconds Auto
ImageSpaceModifier Property FadeToBlack Auto
ReferenceAlias Property Farkas Auto
VisualEffect Property FeedBloodVFX Auto
Spell Property FeedBoost Auto
Float Property HLI_UnshiftHealthThreshold Auto
Quest Property HRI_Manager_Quest Auto
ImageSpaceModifier Property HoldBlack Auto
Spell Property Immunity Auto
ReferenceAlias Property Kodlak Auto
ObjectReference Property LycanStash Auto
ReferenceAlias Property Njada Auto
Race Property NordRace Auto
Actor Property PlayerRef Auto
Quest Property PlayerVampireQuest Auto
Quest Property PlayerWerewolfCureQuest Auto
Faction Property PlayerWerewolfFaction Auto
Scene Property PostRampageScene Auto
Float Property RampageMinutesGameTime Auto
ObjectReference Property RampageStartMarker Auto
ReferenceAlias Property Ria Auto
Idle Property SpecialFeeding Auto
ReferenceAlias Property Torvar Auto
Keyword Property VampireKeyword Auto
ReferenceAlias Property Vilkas Auto
ImageSpaceModifier Property WerewolfChange Auto
Spell Property WerewolfCureDisease Auto
Faction Property WerewolfFaction Auto
Race Property WerewolfRace Auto

;-- Functions ---------------------------------------

; Skipped compiler generated GetState

; Skipped compiler generated GotoState

Function StartRampage()
  FadeToBlack.Apply(1.0)
  Utility.Wait(FadeSeconds)
  FadeToBlack.PopTo(HoldBlack, 1.0)
  Game.EnableFastTravel(False)
  Game.DisablePlayerControls(False, False, True, False, False, False, False, False, 1)
  Game.ForceThirdPerson()
  Game.ShowFirstPersonGeometry(False)
  PlayerRef.MoveTo(RampageStartMarker, 0.0, 0.0, 0.0, True)
  Kodlak.GetReference().MoveToMyEditorLocation()
  Aela.GetReference().MoveToMyEditorLocation()
  Farkas.GetReference().MoveToMyEditorLocation()
  Vilkas.GetReference().MoveToMyEditorLocation()
  Athis.GetReference().MoveToMyEditorLocation()
  Njada.GetReference().MoveToMyEditorLocation()
  Ria.GetReference().MoveToMyEditorLocation()
  Torvar.GetReference().MoveToMyEditorLocation()
  (HRI_Manager_Quest as hri_manager_script).BlockSpellBasedWereformation = True
  If PlayerRef.HasKeyword(VampireKeyword)
    (PlayerVampireQuest as playervampirequestscript).VampireCure(PlayerRef)
  EndIf
  WerewolfCureDisease.Cast(PlayerRef as ObjectReference, None)
  PlayerRef.AddSpell(Immunity, False)
  PlayerWerewolfCureQuest.Start()
  __originalRace = PlayerRef.GetRace()
  PlayerRef.SetRace(WerewolfRace)
  FeedBloodVFX.Play(PlayerRef as ObjectReference, -1 as Float, None)
  Aela.GetActorReference().SetRace(NordRace)
  AelaLycanStash.RemoveAllItems(Aela.GetActorReference() as ObjectReference, False, False)
  Aela.GetActorReference().SetOutfit(AelaOutfit, False)
  PlayerRef.AddSpell(BeastForm, True)
  BeastForm.Cast(PlayerRef as ObjectReference, None)
  PlayerRef.SetAttackActorOnSight(True)
  PlayerRef.AddToFaction(PlayerWerewolfFaction)
  PlayerRef.AddToFaction(WerewolfFaction)
  Int cfIndex = 0
  While cfIndex < CrimeFactions.GetSize()
    (CrimeFactions.GetAt(cfIndex) as Faction).SetPlayerEnemy(True)
    cfIndex += 1
  EndWhile
  Game.SetPlayerReportCrime(False)
  Game.SetBeastForm(True)
  PlayerRef.UnequipAll()
  Spell left = PlayerRef.GetEquippedSpell(0)
  Spell right = PlayerRef.GetEquippedSpell(1)
  Spell power = PlayerRef.GetEquippedSpell(2)
  Shout voice = PlayerRef.GetEquippedShout()
  If left
    PlayerRef.UnequipSpell(left, 0)
  EndIf
  If right
    PlayerRef.UnequipSpell(right, 1)
  EndIf
  If power
    PlayerRef.UnequipSpell(power, 2)
  EndIf
  If voice
    PlayerRef.UnequipShout(voice)
  EndIf
  Game.UnlockWord(CurrentHowlWord1)
  Game.UnlockWord(CurrentHowlWord2)
  Game.UnlockWord(CurrentHowlWord3)
  Game.GetPlayer().AddShout(CurrentHowl)
  Game.GetPlayer().EquipShout(CurrentHowl)
  Self.RegisterForSingleUpdateGameTime(RampageMinutesGameTime / 60.0)
  HoldBlack.PopTo(FadeFromBlack, 1.0)
  HoldBlack.Remove()
  CombatMusic.Add()
  Utility.Wait(3 as Float)
  FadeFromBlack.Remove()
EndFunction

Event OnUpdateGameTime()
  Self.TurnBack()
EndEvent

Function TurnBack()
  If __turningBack
    Return 
  EndIf
  __turningBack = True
  Self.UnregisterForUpdateGameTime()
  While PlayerRef.GetAnimationVariableBool("bIsSynced")
    Utility.Wait(0.100000001)
  EndWhile
  PlayerRef.SetGhost(True)
  Float currHealth = PlayerRef.GetActorValue("Health")
  If currHealth <= HLI_UnshiftHealthThreshold
    PlayerRef.RestoreActorValue("Health", HLI_UnshiftHealthThreshold - currHealth)
  EndIf
  FeedBloodVFX.Stop(PlayerRef as ObjectReference)
  WerewolfChange.Apply(1.0)
  FadeToBlack.Apply(1.0)
  Utility.Wait(FadeSeconds)
  FadeToBlack.PopTo(HoldBlack, 1.0)
  Game.EnablePlayerControls(False, False, True, False, False, False, False, False, 1)
  Game.ShowFirstPersonGeometry(True)
  PlayerRef.UnequipShout(CurrentHowl)
  PlayerRef.RemoveShout(CurrentHowl)
  PlayerRef.SetAttackActorOnSight(False)
  PlayerRef.RemoveFromFaction(PlayerWerewolfFaction)
  PlayerRef.RemoveFromFaction(WerewolfFaction)
  Int cfIndex = 0
  While cfIndex < CrimeFactions.GetSize()
    (CrimeFactions.GetAt(cfIndex) as Faction).SetPlayerEnemy(False)
    cfIndex += 1
  EndWhile
  Game.SetPlayerReportCrime(True)
  Game.SetBeastForm(False)
  Game.EnableFastTravel(True)
  PlayerRef.ResetHealthAndLimbs()
  CombatMusic.Remove()
  PostRampageScene.Start()
EndFunction

Function RestorePlayerRace()
  PlayerRef.SetRace(__originalRace)
  __originalRace = None
EndFunction

Function Feed(Actor victim)
  PlayerRef.PlayIdle(SpecialFeeding)
  FeedBoost.Cast(PlayerRef as ObjectReference, None)
  victim.SetActorValue("Variable08", 100 as Float)
EndFunction

Int Function PassIntegrityCheck()
  Return 777
EndFunction
