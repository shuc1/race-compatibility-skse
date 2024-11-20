;/ Decompiled by Champollion v1.3.2
PEX format v3.2 GameID: 1
Source   : SCS_FUtil_Script.psc
Modified : 2020-12-07 14:41:18
Compiled : 2020-12-07 14:41:19
User     : maxim
Computer : CANOPUS
/;
ScriptName SCS_FUtil_Script Extends Quest

;-- Variables ---------------------------------------
Bool HasShownAgeMessage = False
Bool IsAging = False
Int NextMessage = 0
Bool QualifiesForUpgrade = False

;-- Properties --------------------------------------
Faction Property CWImperialFaction Auto
Faction Property CWImperialFactionNPC Auto
Faction Property CWSonsFaction Auto
Faction Property CWSonsFactionNPC Auto
Faction Property CWWhiterunGuardNeutralFaction Auto
Faction Property CaravanGuard Auto
Faction Property CrimeFactionEastmarch Auto
Faction Property CrimeFactionFalkreath Auto
Faction Property CrimeFactionHaafingar Auto
Faction Property CrimeFactionHjaalmarch Auto
Faction Property CrimeFactionImperial Auto
Faction Property CrimeFactionOrcs Auto
Faction Property CrimeFactionPale Auto
Faction Property CrimeFactionReach Auto
Faction Property CrimeFactionRift Auto
Faction Property CrimeFactionSons Auto
Faction Property CrimeFactionWhiterun Auto
Faction Property CrimeFactionWinterhold Auto
Faction Property DA02CulistsPlayerEnemy Auto
Faction Property DA02CultistsAreEnemies Auto
Faction Property DA02GuardFaction Auto
Faction Property DA02GuardsPlayerEnemy Auto
Faction Property DA07PlayerEnemyFaction Auto
Faction Property DA10PlayerEnemyFaction Auto
Faction Property DA11AttackPlayerFaction Auto
Faction Property DA16OrcAmbushFaction Auto
Faction Property DA16VaerminaHostileFaction Auto
Faction Property DB11KatariahCrewFaction Auto
Faction Property DLC1DawnguardExteriorGuardFaction Auto
Faction Property DLC1DawnguardFaction Auto
Faction Property DLC1HunterFaction Auto
MagicEffect Property DLC1VampireChangeEffect Auto
MagicEffect Property DLC1VampireChangeFXEffect Auto
Faction Property DragonsreachBasementGuards Auto
Faction Property GuardFactionCidhnaMine Auto
Faction Property GuardFactionDawnstar Auto
Faction Property GuardFactionDragonbridge Auto
Faction Property GuardFactionFalkreath Auto
Faction Property GuardFactionHaafingar Auto
Faction Property GuardFactionKarthwasten Auto
Faction Property GuardFactionKolskeggr Auto
Faction Property GuardFactionMarkarth Auto
Faction Property GuardFactionRiften Auto
Faction Property GuardFactionSolitude Auto
Faction Property GuardFactionSoljund Auto
Faction Property GuardFactionWhiterun Auto
Faction Property GuardFactionWindhelm Auto
Faction Property IsGuardFaction Auto
Faction Property JobGuardCaptainFaction Auto
Faction Property KarthwastenSilverFishGuards Auto
Faction Property MG03CallerFaction Auto
Faction Property MGThalmorFaction Auto
Faction Property MQ201ExteriorGuardFaction Auto
Faction Property MQ201PartyGuardFaction Auto
Faction Property MS01PlayerEnemyFaction Auto
Faction Property MS03ChaletGuardEnemyFaction Auto
Faction Property MarriageRivalAttackFaction Auto
Faction Property MorthalGuardhouseFaction Auto
Faction Property OrcGuardFaction Auto
GlobalVariable Property PlayerIsVampire Auto
Actor Property PlayerRef Auto
Faction Property RiftenRatwayFactionEnemy Auto
Faction Property RiftenSkoomaDealerFactionEnemy Auto
Spell Property SCS_Abilities_Vanilla_Spell_Ab_ReverseProgression_Stage2N Auto
Spell Property SCS_Abilities_Vanilla_Spell_Ab_ReverseProgression_Stage3N Auto
Float Property SCS_AgeRate Auto
Message Property SCS_Age_Message Auto
Message Property SCS_Help_Age Auto
FormList Property SCS_Mechanics_FormList_RewardAbilities Auto
FormList Property SCS_Mechanics_FormList_RewardAbilitiesCurrent Auto
FormList Property SCS_Mechanics_FormList_RewardMessages Auto
FormList Property SCS_Mechanics_FormList_RewardMessagesCurrent Auto
FormList Property SCS_Mechanics_FormList_RewardStorage Auto
GlobalVariable Property SCS_Mechanics_Global_Age Auto
GlobalVariable Property SCS_Mechanics_Global_Age_BonusFromFeed Auto
GlobalVariable Property SCS_Mechanics_Global_Age_GainMult Auto
GlobalVariable Property SCS_Mechanics_Global_Age_Threshold Auto
GlobalVariable Property SCS_Mechanics_Global_Age_ThresholdIncrement Auto
Message[] Property SCS_Mechanics_Message_AgeType Auto
Perk Property SCS_Mechanics_Perk_VampireFeed Auto
Faction Property T03HatePlayerFaction Auto
Faction Property TG02AringothPlayerEnemyFaction Auto
Faction Property TG04EastEmpireFactionHostile Auto
Faction Property TG07ValdFactionHatesPlayer Auto
Faction Property TG08BMercerHatesPlayerFaction Auto
Faction Property TG09NightingaleEnemyFaction Auto
Faction Property TGTQ04NiranyeAttacksFaction Auto
Faction Property VigilantOfStendarrFaction Auto
Faction Property WEAdventurerHorseRiderFaction Auto
Faction Property WEPlayerEnemy Auto
Faction Property WERoad02BodyguardFaction Auto
Faction Property WEThalmorPlayerEnemyFaction Auto
Faction Property WIPlayerEnemyFaction Auto
Faction Property WIPlayerEnemySpecialCombatFaction Auto
Faction Property dunDawnstarSanctuaryGuardianFaction Auto
Faction Property dunMarkarthWizard_SecureAreaFaction Auto
Faction Property dunYsgramorsTombGhostFaction Auto

;-- Functions ---------------------------------------

; Skipped compiler generated GetState

; Skipped compiler generated GotoState

Function FactionTame(Actor akTarget)
  akTarget.RemoveFromFaction(CaravanGuard)
  akTarget.RemoveFromFaction(CrimeFactionEastmarch)
  akTarget.RemoveFromFaction(CrimeFactionFalkreath)
  akTarget.RemoveFromFaction(CrimeFactionHaafingar)
  akTarget.RemoveFromFaction(CrimeFactionHjaalmarch)
  akTarget.RemoveFromFaction(CrimeFactionImperial)
  akTarget.RemoveFromFaction(CrimeFactionOrcs)
  akTarget.RemoveFromFaction(CrimeFactionPale)
  akTarget.RemoveFromFaction(CrimeFactionReach)
  akTarget.RemoveFromFaction(CrimeFactionRift)
  akTarget.RemoveFromFaction(CrimeFactionSons)
  akTarget.RemoveFromFaction(CrimeFactionWhiterun)
  akTarget.RemoveFromFaction(CrimeFactionWinterhold)
  akTarget.RemoveFromFaction(CWImperialFaction)
  akTarget.RemoveFromFaction(CWImperialFactionNPC)
  akTarget.RemoveFromFaction(CWSonsFaction)
  akTarget.RemoveFromFaction(CWSonsFactionNPC)
  akTarget.RemoveFromFaction(CWWhiterunGuardNeutralFaction)
  akTarget.RemoveFromFaction(DA02CulistsPlayerEnemy)
  akTarget.RemoveFromFaction(DA02CultistsAreEnemies)
  akTarget.RemoveFromFaction(DA02GuardFaction)
  akTarget.RemoveFromFaction(DA02GuardsPlayerEnemy)
  akTarget.RemoveFromFaction(DA07PlayerEnemyFaction)
  akTarget.RemoveFromFaction(DA10PlayerEnemyFaction)
  akTarget.RemoveFromFaction(DA11AttackPlayerFaction)
  akTarget.RemoveFromFaction(DA16OrcAmbushFaction)
  akTarget.RemoveFromFaction(DA16VaerminaHostileFaction)
  akTarget.RemoveFromFaction(DB11KatariahCrewFaction)
  akTarget.RemoveFromFaction(DLC1DawnguardExteriorGuardFaction)
  akTarget.RemoveFromFaction(DLC1DawnguardFaction)
  akTarget.RemoveFromFaction(DLC1HunterFaction)
  akTarget.RemoveFromFaction(DragonsreachBasementGuards)
  akTarget.RemoveFromFaction(dunDawnstarSanctuaryGuardianFaction)
  akTarget.RemoveFromFaction(dunMarkarthWizard_SecureAreaFaction)
  akTarget.RemoveFromFaction(dunYsgramorsTombGhostFaction)
  akTarget.RemoveFromFaction(GuardFactionCidhnaMine)
  akTarget.RemoveFromFaction(GuardFactionDawnstar)
  akTarget.RemoveFromFaction(GuardFactionDragonbridge)
  akTarget.RemoveFromFaction(GuardFactionFalkreath)
  akTarget.RemoveFromFaction(GuardFactionHaafingar)
  akTarget.RemoveFromFaction(GuardFactionKarthwasten)
  akTarget.RemoveFromFaction(GuardFactionKolskeggr)
  akTarget.RemoveFromFaction(GuardFactionMarkarth)
  akTarget.RemoveFromFaction(GuardFactionRiften)
  akTarget.RemoveFromFaction(GuardFactionSolitude)
  akTarget.RemoveFromFaction(GuardFactionSoljund)
  akTarget.RemoveFromFaction(GuardFactionWhiterun)
  akTarget.RemoveFromFaction(GuardFactionWindhelm)
  akTarget.RemoveFromFaction(IsGuardFaction)
  akTarget.RemoveFromFaction(JobGuardCaptainFaction)
  akTarget.RemoveFromFaction(KarthwastenSilverFishGuards)
  akTarget.RemoveFromFaction(MarriageRivalAttackFaction)
  akTarget.RemoveFromFaction(MG03CallerFaction)
  akTarget.RemoveFromFaction(MGThalmorFaction)
  akTarget.RemoveFromFaction(MorthalGuardhouseFaction)
  akTarget.RemoveFromFaction(MQ201ExteriorGuardFaction)
  akTarget.RemoveFromFaction(MQ201PartyGuardFaction)
  akTarget.RemoveFromFaction(MS01PlayerEnemyFaction)
  akTarget.RemoveFromFaction(MS03ChaletGuardEnemyFaction)
  akTarget.RemoveFromFaction(OrcGuardFaction)
  akTarget.RemoveFromFaction(RiftenRatwayFactionEnemy)
  akTarget.RemoveFromFaction(RiftenSkoomaDealerFactionEnemy)
  akTarget.RemoveFromFaction(T03HatePlayerFaction)
  akTarget.RemoveFromFaction(TG02AringothPlayerEnemyFaction)
  akTarget.RemoveFromFaction(TG04EastEmpireFactionHostile)
  akTarget.RemoveFromFaction(TG07ValdFactionHatesPlayer)
  akTarget.RemoveFromFaction(TG09NightingaleEnemyFaction)
  akTarget.RemoveFromFaction(VigilantOfStendarrFaction)
  akTarget.RemoveFromFaction(WEAdventurerHorseRiderFaction)
  akTarget.RemoveFromFaction(WEPlayerEnemy)
  akTarget.RemoveFromFaction(WERoad02BodyguardFaction)
  akTarget.RemoveFromFaction(WEThalmorPlayerEnemyFaction)
  akTarget.RemoveFromFaction(WIPlayerEnemyFaction)
  akTarget.RemoveFromFaction(WIPlayerEnemySpecialCombatFaction)
EndFunction

Function StopAge()
  Self.UnregisterForUpdateGameTime()
  IsAging = False
  HasShownAgeMessage = False
EndFunction

Event OnUpdateGameTime()
  Self.Age(1.0)
  Self.RegisterforSingleUpdateGameTime(SCS_AgeRate)
EndEvent

Function Age(Float akAmount)
  If IsAging != True
    IsAging = True
    Self.RegisterforSingleUpdateGameTime(SCS_AgeRate)
  EndIf
  akAmount *= SCS_Mechanics_Global_Age_GainMult.GetValue() / 100.0
  If akAmount > 0 as Float
    SCS_Mechanics_Global_Age.Mod(akAmount)
    If SCS_Mechanics_Global_Age.GetValue() > SCS_Mechanics_Global_Age_Threshold.GetValue() && HasShownAgeMessage == False
      If Game.IsMovementControlsEnabled() && Game.IsFightingControlsEnabled() && PlayerRef.GetCombatState() == 0 && !PlayerRef.HasMagicEffect(DLC1VampireChangeEffect) && !PlayerRef.HasMagicEffect(DLC1VampireChangeFXEffect)
        SCS_Mechanics_Message_AgeType[NextMessage].Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
        HasShownAgeMessage = True
        QualifiesForUpgrade = True
        Self.RegisterForSleep()
      EndIf
    EndIf
  EndIf
EndFunction

Event OnSleepStop(Bool abInterrupted)
  If !abInterrupted && QualifiesForUpgrade
    Self.UnregisterForSleep()
    SCS_Mechanics_Global_Age.SetValue(0 as Float)
    SCS_Mechanics_Global_Age_Threshold.Mod(SCS_Mechanics_Global_Age_ThresholdIncrement.GetValue())
    Int i = 0
    Int Choice = 1
    SCS_Age_Message.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    While Choice == 1
      Choice = (SCS_Mechanics_FormList_RewardMessagesCurrent.GetAt(i) as Message).Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
      If Choice != 1
        Spell TheSpell = SCS_Mechanics_FormList_RewardAbilitiesCurrent.GetAt(i) as Spell
        Message TheMessage = SCS_Mechanics_FormList_RewardMessagesCurrent.GetAt(i) as Message
        PlayerRef.AddSpell(TheSpell, True)
        SCS_Mechanics_FormList_RewardStorage.AddForm(TheSpell as Form)
        SCS_Mechanics_FormList_RewardAbilitiesCurrent.RemoveAddedform(TheSpell as Form)
        SCS_Mechanics_FormList_RewardMessagesCurrent.RemoveAddedform(TheMessage as Form)
        NextMessage += 1
      Else
        i += 1
        If i >= SCS_Mechanics_FormList_RewardAbilitiesCurrent.GetSize()
          i = 0
        EndIf
      EndIf
    EndWhile
    HasShownAgeMessage = False
    QualifiesForUpgrade = False
  EndIf
EndEvent

Event OnInit()
  Utility.Wait(8.0)
  PlayerRef.AddPerk(SCS_Mechanics_Perk_VampireFeed)
  Int i = 0
  While i < SCS_Mechanics_FormList_RewardAbilities.GetSize()
    SCS_Mechanics_FormList_RewardAbilitiesCurrent.AddForm((SCS_Mechanics_FormList_RewardAbilities.GetAt(i) as Spell) as Form)
    SCS_Mechanics_FormList_RewardMessagesCurrent.AddForm((SCS_Mechanics_FormList_RewardMessages.GetAt(i) as Message) as Form)
    i += 1
  EndWhile
  Debug.Trace("SACROSANCT 5.00 DEBUG: Filled out Age lists", 0)
EndEvent

Function TearDownRewardSpells()
  Int i
  While i < SCS_Mechanics_FormList_RewardStorage.GetSize()
    PlayerRef.RemoveSpell(SCS_Mechanics_FormList_RewardStorage.GetAt(i) as Spell)
    i += 1
  EndWhile
  Self.StopAge()
  If PlayerIsVampire.GetValue() == 0 as Float
    PlayerRef.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_ReverseProgression_Stage2N)
    PlayerRef.RemoveSpell(SCS_Abilities_Vanilla_Spell_Ab_ReverseProgression_Stage3N)
  EndIf
EndFunction

Function RebuildRewardSpells()
  Int i
  While i < SCS_Mechanics_FormList_RewardStorage.GetSize()
    PlayerRef.AddSpell(SCS_Mechanics_FormList_RewardStorage.GetAt(i) as Spell, False)
    i += 1
  EndWhile
  Self.Age(0.0)
EndFunction
