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
#import "DSAObjectContainer.h"
#import "DSAObjectWeapon.h"
#import "DSAObjectArmor.h"
#import "DSAObjectShield.h"
#import "DSAAventurianDate.h"
#import "DSATalent.h"

@class DSAPositiveTrait;

@interface DSACharacter : NSObject <NSCoding>

@property (nonatomic, strong, readonly) NSString *modelID; // Unique ID for each model

// copy properties, to prevent others fiddling with the model...
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *archetype;
@property (nonatomic, copy) NSNumber *level; 
@property (nonatomic, copy) NSNumber *adventurePoints;
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
@property (nonatomic, copy) NSMutableDictionary *negativeTraits;
@property (nonatomic, copy) NSNumber *lifePoints;
@property (nonatomic, copy) NSNumber *currentLifePoints;
@property (nonatomic) BOOL isMagic;
@property (nonatomic) BOOL isMagicalDabbler;
@property (nonatomic) BOOL isBlessedOne;
@property (nonatomic, copy) NSNumber *astralEnergy;
@property (nonatomic, copy) NSNumber *currentAstralEnergy;
@property (nonatomic, copy) NSNumber *karmaPoints;
@property (nonatomic, copy) NSNumber *currentKarmaPoints;
@property (nonatomic, copy) NSNumber *mrBonus;
@property (nonatomic, strong, readonly) NSImage *portrait;
@property (nonatomic, copy) NSString *portraitName;
@property (nonatomic, strong) DSAInventory *inventory;
@property (nonatomic, strong) DSABodyParts *bodyParts;
@property (nonatomic, copy) NSMutableDictionary *talents;
@property (nonatomic, copy) NSMutableDictionary *spells;
@property (nonatomic, copy) NSMutableDictionary *specials;

@property (readonly, copy) NSNumber *attackBaseValue;
@property (readonly, copy) NSNumber *carryingCapacity;
@property (readonly, copy) NSNumber *dodge;
@property (readonly, assign) float encumbrance;         // Behinderung durch Sachen/Rüstung etc.
@property (readonly, copy) NSNumber *endurance;           // Ausdauer
@property (readonly, assign) float load;                // Last der mitgeschleppten Gegenstände
@property (readonly, assign) float armor;
@property (readonly, copy) NSNumber *magicResistance;
@property (readonly, copy) NSNumber *parryBaseValue;
@property (readonly, copy) NSNumber *rangedCombatBaseValue;

+ (DSACharacter *)characterWithModelID:(NSString *)modelID;

- (NSString *) siblingsString;

// used to decide, if a body inventory slot can hold a given item, based on character constraints
- (BOOL) canUseItem: (DSAObject *) item;
// to decide if currently a spell can be casted
- (BOOL) canCastSpell;
// to decide, if currently a talent can be used
- (BOOL) canUseTalent;
// to decide, if the character can regenerate AE or LP
- (BOOL) canRegenerate;

- (BOOL) useTalent: (NSString *) talentName withPenalty: (NSInteger) penalty;

@end

#endif // _DSACHARACTER_H_

