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

@class DSAPositiveTrait;
@class DSANegativeTrait;
@class DSATalentResult;
@class DSASpellResult;
@class DSARegenerationResult;
@class DSALocation;

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
@property (nonatomic, copy) NSMutableDictionary *money;
@property (nonatomic, copy) NSMutableDictionary<NSString *, DSAPositiveTrait *> *positiveTraits;
@property (nonatomic, copy) NSMutableDictionary<NSString *, DSANegativeTrait *> *negativeTraits;
@property (nonatomic, copy) NSMutableDictionary<NSString *, DSAPositiveTrait *> *currentPositiveTraits;
@property (nonatomic, copy) NSMutableDictionary<NSString *, DSANegativeTrait *> *currentNegativeTraits;
@property (nonatomic, assign) NSInteger lifePoints;
@property (nonatomic, assign) NSInteger currentLifePoints;
@property (nonatomic) BOOL isMagic;
@property (nonatomic) BOOL isMagicalDabbler;
@property (nonatomic) BOOL isBlessedOne;
@property (nonatomic, assign) NSInteger astralEnergy;
@property (nonatomic, assign) NSInteger currentAstralEnergy;
@property (nonatomic, assign) NSInteger karmaPoints;
@property (nonatomic, assign) NSInteger currentKarmaPoints;
@property (nonatomic, assign) NSInteger mrBonus;
@property (nonatomic, strong, readonly) NSImage *portrait;
@property (nonatomic, copy) NSString *portraitName;
@property (nonatomic, strong) DSAInventory *inventory;
@property (nonatomic, strong) DSABodyParts *bodyParts;
@property (nonatomic, copy) NSMutableDictionary *talents;
@property (nonatomic, copy) NSMutableDictionary *professions;
@property (nonatomic, copy) NSMutableDictionary *spells;
@property (nonatomic, strong) NSMutableDictionary *specials;
@property (nonatomic, assign) NSInteger firstLevelUpTalentTriesPenalty;  // might have less than usual tries to level up talents to level 1
@property (nonatomic, assign) NSInteger maxLevelUpTalentsTries;          // how often to try to level up all talents/professions (professions mix in here...)
@property (nonatomic, assign) NSInteger maxLevelUpSpellsTries;           // how often to try to level up all spells
@property (nonatomic, assign) NSInteger maxLevelUpTalentsTriesTmp;       // holding nr of overall talent tries, once variable tries is distributed
@property (nonatomic, assign) NSInteger maxLevelUpSpellsTriesTmp;        // holding nr of overall spell tries, once variable tries is distributed
@property (nonatomic, assign) NSInteger maxLevelUpVariableTries;         // variable tries, that can be added to talent or spell level ups
@property (nonatomic, strong) NSMutableDictionary<NSString*, DSASpell *> *appliedSpells;  // spells casted onto a character, and having effect on it
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSNumber *> *statesDict;

@property (readonly, assign) NSInteger attackBaseValue;
@property (readonly, assign) NSInteger carryingCapacity;
@property (readonly, assign) NSInteger dodge;
@property (readonly, assign) float encumbrance;         // Behinderung durch Sachen/Rüstung etc.
@property (readonly, assign) NSInteger endurance;           // Ausdauer
@property (readonly, assign) float load;                // Last der mitgeschleppten Gegenstände
@property (readonly, assign) float armor;
@property (readonly, assign) NSInteger magicResistance;
@property (readonly, assign) NSInteger parryBaseValue;
@property (readonly, assign) NSInteger rangedCombatBaseValue;

@property (nonatomic, strong) DSALocation *currentLocation;

+ (instancetype)characterWithType:(NSString *)type;     // create a character of given arche-(type)

+ (DSACharacter *)characterWithModelID:(NSUUID *)modelID;

- (NSString *) siblingsString;

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
- (BOOL) canUseTalent;
// to decide, if the character can regenerate AE or LP
- (BOOL) canRegenerate;

- (BOOL) consumeItem: (DSAObject *) item;

- (void) updateStatesDictState: (NSNumber *) DSACharacterState
                     withValue: (NSNumber *) value;

- (DSATalentResult *) useTalent: (NSString *) talentName withPenalty: (NSInteger) penalty;
- (DSASpellResult *) castSpell: (NSString *) spellName
                     ofVariant: (NSString *) variant 
             ofDurationVariant: (NSString *) durationVariant
                      onTarget: (DSACharacter *) targetCharacter 
                    atDistance: (NSInteger) distance
                   investedASP: (NSInteger) investedASP 
          spellOriginCharacter: (DSACharacter *) originCharacter;

- (DSASpellResult *) castRitual: (NSString *) ritualName 
                      ofVariant: (NSString *) variant
              ofDurationVariant: (NSString *) durationVariant
                       onTarget: (id) target
                     atDistance: (NSInteger) distance
                    investedASP: (NSInteger) investedASP 
           spellOriginCharacter: (DSACharacter *) originCharacter;          
          
- (DSARegenerationResult *) regenerateBaseEnergiesForHours: (NSInteger) hours;

// - (DSAObject *)findObjectWithName:(NSString *)name;

// Location related methods
- (void)moveToLocation:(DSALocation *)newLocation;

@end

@interface DSACharacterHero : DSACharacter
@property (nonatomic, copy) NSMutableDictionary *levelUpTalents;       // used to track talent level up attempts when reching a new level
@property (nonatomic, copy) NSMutableDictionary *levelUpSpells;        // used to track spell level up attempts when reching a new level
@property (nonatomic, copy) NSMutableDictionary *levelUpProfessions;   // used to track profession level up attempts when reching a new level
@property (nonatomic) BOOL isLevelingUp;                               // keeps track of the fact, if a character is in the phase of leveling up...
@property (nonatomic, assign) NSInteger tempDeltaLpAe;                   // some characters roll one dice to level up LP and AE, and have to ask user how to distribute, here we temporarily save the result

- (NSDictionary *) levelUpBaseEnergies;
- (BOOL) levelUpPositiveTrait: (NSString *) trait;
- (BOOL) levelDownNegativeTrait: (NSString *) trait;
- (BOOL) levelUpTalent: (DSATalent *)talent;
- (BOOL) canLevelUpTalent: (DSATalent *)talent;
- (BOOL) canLevelUp;
- (void) prepareLevelUp;
- (void) finishLevelUp;

@end
// End of DSACharacterHero

@interface DSACharacterHeroElf : DSACharacterHero
- (BOOL) levelUpSpell: (DSASpell *)spell;
- (BOOL) canLevelUpSpell: (DSASpell *)spell;
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
- (BOOL) levelUpSpell: (DSASpell *)spell;
- (BOOL) canLevelUpSpell: (DSASpell *)spell;
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
- (BOOL) levelUpSpell: (DSASpell *)spell;
- (BOOL) canLevelUpSpell: (DSASpell *)spell;
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
- (BOOL) levelUpSpell: (DSASpell *)spell;
- (BOOL) canLevelUpSpell: (DSASpell *)spell;
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

#endif // _DSACHARACTER_H_

