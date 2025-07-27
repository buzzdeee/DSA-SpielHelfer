/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-09-08 00:03:31 +0200 by sebastia

   This application is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This application is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
*/

#ifndef _DSACHARACTER_H_
#define _DSACHARACTER_H_

#import <Foundation/Foundation.h>
#import "DSAObject.h"
#import "DSAInventory.h"
#import "DSABodyParts.h"
#import "DSAAventurianDate.h"
#import "DSATalent.h"

NS_ASSUME_NONNULL_BEGIN

@class DSAPositiveTrait;
@class DSANegativeTrait;
@class DSATalentResult;
@class DSASpellResult;
@class DSARegenerationResult;
@class DSALocation;
@class DSAWallet;
@class DSAMiracleResult;

typedef NS_ENUM(NSUInteger, DSACharacterState)
{
  DSACharacterStateWounded,                 // the character is wounded
  DSACharacterStateSick,                    // if the character is sick
  DSACharacterStateDrunken,                 // the level of drunkenes
  DSACharacterStatePoisoned,                // if the character is poisoned
  DSACharacterStateDead,                    // the character is dead
  DSACharacterStateUnconscious,             // the character is unconscious
  DSACharacterStateSpellbound,              // a spell was casted onto the character
  DSACharacterStateHunger,                  // level of hunger
  DSACharacterStateThirst,                  // level of thirst
};

typedef NS_ENUM(NSUInteger, DSASleepQuality)
{
    DSASleepQualityTerrible,    // z. B. in der Gosse, nass, voller Ungeziefer
    DSASleepQualityLousy,       // unbequem, laut, kalt – kaum erholsam
    DSASleepQualityMediocre,    // akzeptabel, aber nicht gut (z. B. Lager ohne Decke)
    DSASleepQualityNormal,      // Standardherberge oder Feldbett mit Decke
    DSASleepQualityGood,        // ruhiges Zimmer, gutes Bett, warm, trocken
    DSASleepQualityExcellent,   // luxuriöse Suite, Duftöle, Federn, evtl. Bonus durch Zauber o.ä.
    DSASleepQualityUnknown
};

typedef NS_ENUM(NSInteger, DSACharacterEffectType) {
    DSACharacterEffectTypeTraitBoost,                    // basic traits are boosted
    DSACharacterEffectTypeTalentBoost,                   // talents are boosted
    DSACharacterEffectTypeMagicBoost,                    // a spell is boosted, or all spells ???
    DSACharacterEffectTypeTalentAutoSuccess,             // Auto success for a given talent
    DSACharacterEffectTypeMRBoost,                       // Magic Resistance boost
    DSACharacterEffectTypeMagicProtection,               // protection against magic
    DSACharacterEffectTypeSeaProtection,                 // protection when travelling on the sea
    DSACharacterEffectTypeRemoveCurse,                   // this removes an applied curse
    DSACharacterEffectTypeCureDisease,                   // this heals a disease/illness
    DSACharacterEffectTypeRevive,                        // a character is revived from dead
    DSACharacterEffectTypeSatiation,                     // thirst and hunger will vanish
    DSACharacterEffectTypeNoHungerThirst,                // no hunger and thirst for a given amount of time
    DSACharacterEffectTypeHeal,                          // some LE get restored
    DSACharacterEffectTypeFullHeal,                      // full LE healing
    DSACharacterEffectTypeNightPeace,                    // sleep well at night, without attacks
    DSACharacterEffectTypeProtectionAgainstUndead,       // undeads won't harm
    DSACharacterEffectTypeFearOfDead,                    // TA goes down
    DSACharacterEffectTypeWeaponBlessing,                // weapon "healing" ;)
    DSACharacterEffectTypeUpgradeWeaponToMagic,          // weapon becomes magic
    DSACharacterEffectTypeEnchantWeapon,                 // weapon becomes magic
    DSACharacterEffectTypeRepairAndEnchant,              // weapon repaired and magic
    DSACharacterEffectTypePlaceholder,                   // what's that?
    DSACharacterEffectTypeRoomBooked,                    // has a room booked in an inn
    DSACharacterEffectTypeIllness,                       // character is sick/ill 
    DSACharacterEffectTypeNothing
};

typedef NS_ENUM(NSUInteger, DSAIllnessStage) {
  DSAIllnessStageIncubation,
  DSAIllnessStageActiveUnknown,
  DSAIllnessStageActiveIdentified,
  DSAIllnessStageUnderTreatment,
  DSAIllnessStageChronicInactive,
  DSAIllnessStageChronicActive
};


@interface DSACharacterEffect : NSObject <NSCoding, NSCopying>

@property (nonatomic, copy) NSString *uniqueKey;
@property (nonatomic, assign) DSACharacterEffectType effectType;
@property (nonatomic, strong, nullable) DSAAventurianDate *expirationDate;
@property (nonatomic, strong) NSDictionary<NSString *, NSNumber *> *reversibleChanges;
@end

@interface DSAIllnessEffect : DSACharacterEffect <NSCoding, NSCopying>

@property (nonatomic, strong, nullable) NSDictionary<NSString *, NSDictionary<NSString *, id> *> *dailyDamage;
@property (nonatomic, strong, nullable) DSAAventurianDate * dailyDamageApplyNextDate;  // when to apply next daily damage
@property (nonatomic, strong, nullable) NSDictionary<NSString *, NSDictionary<NSString *, id> *> *oneTimeDamage;
@property (nonatomic, assign) DSAIllnessStage currentStage;
@property (nonatomic, strong, nullable) NSDictionary<NSString *, NSNumber *> *followUpIllnessChance;  // chance to get sick on a follow-up sickness in %

@end

@interface DSACharacter : NSObject <NSCoding>

@property (nonatomic, strong, readonly) NSUUID *modelID; // Unique ID for each model

// copy properties, to prevent others fiddling with the model...
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *archetype;
@property (nonatomic, assign) NSInteger level; 
@property (nonatomic, assign) NSInteger adventurePoints;
@property (nonatomic, copy) NSString *origin;
@property (nonatomic, copy) NSString *mageAcademy;
@property (nonatomic, copy) NSString *element;
@property (nonatomic, copy) NSString *sex;
@property (nonatomic, copy) NSString *hairColor;
@property (nonatomic, copy) NSString *eyeColor;
@property (nonatomic, assign) float height;
@property (nonatomic, assign) float weight;
@property (nonatomic, strong) DSAAventurianDate *birthday;
@property (nonatomic, copy) NSString *god;
@property (nonatomic, copy) NSString *stars;
@property (nonatomic, copy) NSString *religion;
@property (nonatomic, copy) NSString *socialStatus;
@property (nonatomic, copy) NSString *parents;
@property (nonatomic, copy) NSArray *siblings;                         // the siblings
@property (nonatomic, copy) NSString *birthPlace;                      // where did birth happen
@property (nonatomic, copy) NSString *birthEvent;                      // something noteworthy happend while being born?
@property (nonatomic, copy) NSString *legitimation;
@property (nonatomic, copy) NSArray *childhoodEvents;
@property (nonatomic, copy) NSArray *youthEvents;
@property (nonatomic, copy) DSAWallet *wallet;
@property (nonatomic, copy) NSMutableDictionary<NSString *, DSAPositiveTrait *> *positiveTraits;
@property (nonatomic, copy) NSMutableDictionary<NSString *, DSANegativeTrait *> *negativeTraits;
@property (nonatomic, copy) NSMutableDictionary<NSString *, DSAPositiveTrait *> *currentPositiveTraits;
@property (nonatomic, copy) NSMutableDictionary<NSString *, DSANegativeTrait *> *currentNegativeTraits;
@property (nonatomic, assign) NSInteger lifePoints;
@property (nonatomic, assign) NSInteger currentLifePoints;
@property (nonatomic) BOOL isNPC;
@property (nonatomic) BOOL isMagic;
@property (nonatomic) BOOL isMagicalDabbler;
@property (nonatomic) BOOL isBlessedOne;
@property (nonatomic, assign) NSInteger astralEnergy;
@property (nonatomic, assign) NSInteger currentAstralEnergy;
@property (nonatomic, assign) NSInteger karmaPoints;
@property (nonatomic, assign) NSInteger currentKarmaPoints;
@property (nonatomic, assign) NSInteger mrBonus;
@property (nonatomic, assign) NSInteger currentMrBonus;
@property (nonatomic, assign) NSInteger armorBaseValue;                  // esp. for different types of NPCs 
@property (nonatomic, strong, readonly) NSImage *portrait;
@property (nonatomic, copy) NSString *portraitName;
@property (nonatomic, strong) DSAInventory *inventory;
@property (nonatomic, strong) DSABodyParts *bodyParts;
@property (nonatomic, copy) NSMutableDictionary <NSString *, DSATalent *> *talents;
@property (nonatomic, copy) NSMutableDictionary <NSString *, DSATalent *> *currentTalents;
@property (nonatomic, copy, nullable) NSMutableDictionary <NSString *, DSAProfession *> *professions;
@property (nonatomic, copy, nullable) NSMutableDictionary <NSString *, DSAProfession *> *currentProfessions;
@property (nonatomic, copy, nullable) NSMutableDictionary <NSString *, DSASpell *> *spells;
@property (nonatomic, copy, nullable) NSMutableDictionary <NSString *, DSASpell *> *currentSpells;
@property (nonatomic, strong, nullable) NSMutableDictionary *specials;
@property (nonatomic, strong, nullable) NSMutableDictionary *currentSpecials;
@property (nonatomic, assign) NSInteger firstLevelUpTalentTriesPenalty;  // might have less than usual tries to level up talents to level 1
@property (nonatomic, assign) NSInteger maxLevelUpTalentsTries;          // how often to try to level up all talents/professions (professions mix in here...)
@property (nonatomic, assign) NSInteger maxLevelUpSpellsTries;           // how often to try to level up all spells
@property (nonatomic, assign) NSInteger maxLevelUpTalentsTriesTmp;       // holding nr of overall talent tries, once variable tries is distributed
@property (nonatomic, assign) NSInteger maxLevelUpSpellsTriesTmp;        // holding nr of overall spell tries, once variable tries is distributed
@property (nonatomic, assign) NSInteger maxLevelUpVariableTries;         // variable tries, that can be added to talent or spell level ups
@property (nonatomic, strong) NSMutableDictionary<NSString*, DSASpell *> *appliedSpells;  // spells casted onto a character, and having effect on it
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSNumber *> *statesDict;

@property (nonatomic, strong) NSMutableDictionary<NSString *, DSACharacterEffect *> *appliedEffects;

@property (readonly, assign) NSInteger attackBaseValue;
@property (nonatomic, assign) NSInteger attackBaseBaseValue;  // may be changed in case of effects on characters
@property (readonly, assign) NSInteger carryingCapacity;
@property (readonly, assign) NSInteger dodge;
@property (readonly, assign) float encumbrance;         // Behinderung durch Sachen/Rüstung etc.
@property (readonly, assign) NSInteger endurance;       // Ausdauer
@property (nonatomic, assign) NSInteger enduranceBaseValue;  // usually 0, but can be affected, i.e. become negative due to illness
@property (readonly, assign) float load;                // Last der mitgeschleppten Gegenstände
@property (readonly, assign) float armor;
@property (readonly, assign) NSInteger magicResistance;
@property (readonly, assign) NSInteger parryBaseValue;
@property (nonatomic, assign) NSInteger parryBaseBaseValue;    // may be changed in case of effects on characters
@property (readonly, assign) NSInteger rangedCombatBaseValue;

@property (nonatomic, strong) NSMutableSet<NSString *> *receivedUniqueMiracles;  // some miracles can only be received once per character

// those static values used for simpler NPC types, with less calculations...
@property (nonatomic, assign) NSInteger staticAttackBaseValue;
@property (nonatomic, assign) NSInteger staticParryBaseValue;

@property (nonatomic, strong) DSALocation *currentLocation;

+ (instancetype)characterWithType:(NSString *)type;     // create a character of given arche-(type)

+ (DSACharacter *)characterWithModelID:(NSUUID *)modelID;

- (NSString *) siblingsString;

// sleep, and regenerate
- (DSARegenerationResult *) sleepForHours: (NSInteger) hours
                             sleepQuality: (DSASleepQuality) quality;

// Check if the character is able to do anything basic
- (BOOL) isDeadOrUnconscious;

// used to decide, if a body inventory slot can hold a given item, based on character constraints
- (BOOL) canUseItem: (DSAObject *) item;
// to decide if currently a spell can be casted
- (BOOL) canCastSpells;
- (BOOL) canCastSpellWithName: (NSString *) name;
// to decide if currently a ritual can be casted
- (BOOL) canCastRituals;
- (BOOL) canCastRitualWithName: (NSString *) name;
// to decide, if currently a talent can be used
- (BOOL) canUseTalents;
- (BOOL) canUseTalentWithName: (NSString *) name;
// to decide, if the character can regenerate AE or LP
- (BOOL) canRegenerate;

- (BOOL) consumeItem: (DSAObject *) item;

- (void) updateStateHungerWithValue: (NSNumber*) value;
- (void) updateStateThirstWithValue: (NSNumber*) value;
- (void) updateStatesDictState: (NSNumber *) DSACharacterState
                     withValue: (NSNumber *) value;

- (void)addEffect:(DSACharacterEffect *)effect;                       // To add any type of effect, that doesn't need to apply anything special
- (BOOL) applyIllnessEffect: (DSAIllnessEffect *) illnessEffect;      // To apply illnesses to characters
- (BOOL) isIll;                                                       // to test if a character is ill, or not
- (BOOL) applyMiracleEffect: (DSAMiracleResult *) miracleResult;      // to add miracle effects, which may change some values when applying
- (BOOL) hasAppliedCharacterEffectWithKey: (NSString *)key;
- (DSACharacterEffect *) appliedCharacterEffectWithKey: (NSString *) key;
- (void)removeExpiredEffectsAtDate:(DSAAventurianDate *)currentDate;
- (void)removeCharacterEffectForKey: (NSString *)key;


- (NSArray <DSATalent *>*) activeTalentsWithNames: (NSArray <NSString *>*) names;
- (NSArray <DSASpell *>*) activeSpellsWithNames: (NSArray <NSString *>*) names;
- (NSArray <DSASpell *>*) activeRitualsWithNames: (NSArray <NSString *>*) names;
                     
- (DSATalentResult *) useTalent: (NSString *) talentName withPenalty: (NSInteger) penalty;
- (DSASpellResult *) castSpell: (DSASpell *) spell
                     ofVariant: (nullable NSString *) variant 
             ofDurationVariant: (nullable NSString *) durationVariant
                      onTarget: (DSACharacter *) targetCharacter 
                    atDistance: (NSInteger) distance
                   investedASP: (NSInteger) investedASP 
          spellOriginCharacter: (nullable DSACharacter *) originCharacter;

- (DSASpellResult *) castRitual: (NSString *) ritualName 
                      ofVariant: (nullable NSString *) variant
              ofDurationVariant: (nullable NSString *) durationVariant
                       onTarget: (id) target
                     atDistance: (NSInteger) distance
                    investedASP: (NSInteger) investedASP 
           spellOriginCharacter: (nullable DSACharacter *) originCharacter;          
          
- (DSARegenerationResult *) regenerateBaseEnergiesForHours: (NSInteger) hours
                                              sleepQuality: (DSASleepQuality) quality;

// - (DSAObject *)findObjectWithName:(NSString *)name;

// Location related methods
- (void)moveToLocation:(DSALocation *)newLocation;

- (void)removeExpiredEffectsAtDate:(DSAAventurianDate *)currentDate;

@end

@interface DSACharacterHero : DSACharacter
@property (nonatomic, copy, nullable) NSMutableDictionary *levelUpTalents;       // used to track talent level up attempts when reching a new level
@property (nonatomic, copy, nullable) NSMutableDictionary *levelUpSpells;        // used to track spell level up attempts when reching a new level
@property (nonatomic, copy, nullable) NSMutableDictionary *levelUpProfessions;   // used to track profession level up attempts when reching a new level
@property (nonatomic) BOOL isLevelingUp;                               // keeps track of the fact, if a character is in the phase of leveling up...
@property (nonatomic, assign) NSInteger tempDeltaLpAe;                   // some characters roll one dice to level up LP and AE, and have to ask user how to distribute, here we temporarily save the result

- (NSDictionary *) levelUpBaseEnergies;
- (BOOL) levelUpPositiveTrait: (NSString *) trait;
- (BOOL) levelDownNegativeTrait: (NSString *) trait;
- (BOOL) levelUpTalent: (DSATalent *)talent;
- (BOOL) canLevelUpTalent: (DSATalent *)talent;
- (BOOL) levelUpSpell: (DSASpell *)spell;
- (BOOL) canLevelUpSpell: (DSASpell *)spell;
- (BOOL) canLevelUp;
- (void) prepareLevelUp;
- (void) finishLevelUp;

@end
// End of DSACharacterHero

@interface DSACharacterHeroElf : DSACharacterHero
@end
// End of DSACharacterHeroElf

@interface DSACharacterHeroElfSnow : DSACharacterHeroElf
@end
// End of DSACharacterHEroElfSnow

@interface DSACharacterHeroElfWood : DSACharacterHeroElf
@end
// End of DSACahracterHEroElfWood

@interface DSACharacterHeroElfMeadow : DSACharacterHeroElf
@end
// End of DSACharacterHeroElfMeadow

@interface DSACharacterHeroElfHalf : DSACharacterHeroElf
@end
// End of DSACharacterHeroElfHalf

@interface DSACharacterHeroDwarf : DSACharacterHero
@end
// End of DSACharacterHeroDwarf

@interface DSACharacterHeroDwarfAngroschPriest : DSACharacterHeroDwarf
@end
// End of DSACharacterHeroDwarfAngroschPriest

@interface DSACharacterHeroDwarfGeode : DSACharacterHeroDwarf
@end
// End of DSACharacterHeroDwarfGeode

@interface DSACharacterHeroDwarfFighter : DSACharacterHeroDwarf
@end
// End of DSACharacterHeroDwarfFighter

@interface DSACharacterHeroDwarfCavalier : DSACharacterHeroDwarf
@end
// End of DSACharacterHeroDwarfCavalier

@interface DSACharacterHeroDwarfJourneyman : DSACharacterHeroDwarf
@end
// End of DSACharacterHeroDwarfJourneyman

@interface DSACharacterHeroHuman : DSACharacterHero
@end
// End of DSACharacterHeroHuman

@interface DSACharacterHeroHumanAlchemist : DSACharacterHeroHuman
@end
// End of DSACharacterHeroHumanAlchemist

@interface DSACharacterHeroHumanAmazon : DSACharacterHeroHuman
@end
// End of DSACharacterHeroHumanAmazon

@interface DSACharacterHeroHumanBard : DSACharacterHeroHuman
@end
// End of DSACharacterHeroHumanBard

@interface DSACharacterHeroHumanCharlatan : DSACharacterHeroHuman
@end
// End of DSACharacterHeroHumanCharlatan

@interface DSACharacterHeroHumanDruid : DSACharacterHeroHuman
@end
// End of DSACharacterHeroHumanDruid

@interface DSACharacterHeroHumanHuntsman : DSACharacterHeroHuman
@end
// End of DSACharacterHeroHumanHuntsman

@interface DSACharacterHeroHumanJester : DSACharacterHeroHuman
@end
// End of DSACharacterHeroHumanJester

@interface DSACharacterHeroHumanJuggler : DSACharacterHeroHuman
@end
// End of DSACharacterHeroHumanJuggler

@interface DSACharacterHeroHumanMage : DSACharacterHeroHuman
@end
// End of DSACharacterHeroHumanMage

@interface DSACharacterHeroHumanMercenary : DSACharacterHeroHuman
@end
// End of DSACharacterHeroHumanMercenary

@interface DSACharacterHeroHumanMoha : DSACharacterHeroHuman
@end
// End of DSACharacterHeroHumanMoha

@interface DSACharacterHeroHumanNivese : DSACharacterHeroHuman
@end
// End of DSACharacterHeroHumanNivese

@interface DSACharacterHeroHumanNorbarde : DSACharacterHeroHuman
@end
// End of DSACharacterHeroHumanNorbarde

@interface DSACharacterHeroHumanNovadi : DSACharacterHeroHuman
@end
// End of DSACharacterHeroHumanNovadi

@interface DSACharacterHeroHumanPhysician : DSACharacterHeroHuman
@end
// End of DSACharacterHeroHumanPhysician

@interface DSACharacterHeroHumanRogue : DSACharacterHeroHuman
@end
// End of DSACharacterHeroHumanRogue

@interface DSACharacterHeroHumanSeafarer : DSACharacterHeroHuman
@end
// End of DSACharacterHeroHumanSeafarer

@interface DSACharacterHeroHumanShaman : DSACharacterHeroHuman
@end
// End of DSACharacterHeroHumanShaman

@interface DSACharacterHeroHumanSharisad : DSACharacterHeroHuman
@end
// End of DSACharacterHeroHumanSharisad

@interface DSACharacterHeroHumanSkald : DSACharacterHeroHuman
@end
// End of DSACharacterHeroHumanSkald

@interface DSACharacterHeroHumanThorwaler : DSACharacterHeroHuman
@end
// End of DSACharacterHeroHumanThorwaler

@interface DSACharacterHeroHumanWarrior : DSACharacterHeroHuman
@end
// End of DSACharacterHeroHumanWarrior

@interface DSACharacterHeroHumanWitch : DSACharacterHeroHuman
@end
// End of DSACharacterHeroHumanWitch

@interface DSACharacterHeroBlessed : DSACharacterHero
@end
// End of DSACharacterHeroBlessed

@interface DSACharacterHeroBlessedPraios : DSACharacterHeroBlessed
@end
// End of DSACharacterHeroBlessedPraios

@interface DSACharacterHeroBlessedRondra : DSACharacterHeroBlessed
@end
// End of DSACharacterHeroBlessedRondra

@interface DSACharacterHeroBlessedEfferd : DSACharacterHeroBlessed
@end
// End of DSACharacterHeroBlessedEfferd

@interface DSACharacterHeroBlessedTravia : DSACharacterHeroBlessed
@end
// End of DSACharacterHeroBlessedTravia

@interface DSACharacterHeroBlessedBoron : DSACharacterHeroBlessed
@end
// End of DSACharacterHeroBlessedBoron

@interface DSACharacterHeroBlessedHesinde : DSACharacterHeroBlessed
@end
// End of DSACharacterHeroBlessedHesinde

@interface DSACharacterHeroBlessedFirun : DSACharacterHeroBlessed
@end
// End of DSACharacterHeroBlessedFirun

@interface DSACharacterHeroBlessedTsa : DSACharacterHeroBlessed
@end
// End of DSACharacterHeroBlessedTsa

@interface DSACharacterHeroBlessedPhex : DSACharacterHeroBlessed
@end
// End of DSACharacterHeroBlessedPhex

@interface DSACharacterHeroBlessedPeraine : DSACharacterHeroBlessed
@end
// End of DSACharacterHeroBlessedPeraine

@interface DSACharacterHeroBlessedIngerimm : DSACharacterHeroBlessed
@end
// End of DSACharacterHeroBlessedIngerimm

@interface DSACharacterHeroBlessedRahja : DSACharacterHeroBlessed
@end
// End of DSACharacterHeroBlessedRahja

@interface DSACharacterHeroBlessedSwafnir : DSACharacterHeroBlessed
@end
// End of DSACharacterHeroBlessedSwafnir

@interface DSACharacterNpc : DSACharacter
@end
// End of DSACharacterNpc

@interface DSACharacterNpcHumanoid : DSACharacterNpc
@end
// End of DSACharacterNpcHumanoid

@interface DSACharacterNpcHumanoidAchaz : DSACharacterNpcHumanoid
@end
// End of DSACharacterNpcHumanoidAchaz

@interface DSACharacterNpcHumanoidApeman : DSACharacterNpcHumanoid
@end
// End of DSACharacterNpcHumanoidApeman

@interface DSACharacterNpcHumanoidElf : DSACharacterNpcHumanoid
@end
// End of DSACharacterNpcHumanoidElf

@interface DSACharacterNpcHumanoidFerkina : DSACharacterNpcHumanoid
@end
// End of DSACharacterNpcHumanoidFerkina

@interface DSACharacterNpcHumanoidFishman : DSACharacterNpcHumanoid
@end
// End of DSACharacterNpcHumanoidFishman

@interface DSACharacterNpcHumanoidGoblin : DSACharacterNpcHumanoid
@end
// End of DSACharacterNpcHumanoidGoblin

@interface DSACharacterNpcHumanoidKrakonier : DSACharacterNpcHumanoid
@end
// End of DSACharacterNpcHumanoidKrakonier

@interface DSACharacterNpcHumanoidMarus: DSACharacterNpcHumanoid
@end
// End of DSACharacterNpcHumanoidMarus

@interface DSACharacterNpcHumanoidOger: DSACharacterNpcHumanoid
@end
// End of DSACharacterNpcHumanoidOger

@interface DSACharacterNpcHumanoidOrk: DSACharacterNpcHumanoid
@end
// End of DSACharacterNpcHumanoidOrk

@interface DSACharacterNpcHumanoidRiese: DSACharacterNpcHumanoid
@end
// End of DSACharacterNpcHumanoidRiese

@interface DSACharacterNpcHumanoidTroll: DSACharacterNpcHumanoid
@end
// End of DSACharacterNpcHumanoidTroll

@interface DSACharacterNpcHumanoidYeti: DSACharacterNpcHumanoid
@end
// End of DSACharacterNpcHumanoidYeti

@interface DSACharacterNpcHumanoidZyklop: DSACharacterNpcHumanoid
@end
// End of DSACharacterNpcHumanoidZyklop

#endif // _DSACHARACTER_H_
NS_ASSUME_NONNULL_END
