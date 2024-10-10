/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-09-11 21:31:33 +0200 by sebastia

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

#ifndef _DSACHARACTERHERO_H_
#define _DSACHARACTERHERO_H_

#import <Foundation/Foundation.h>
#import "DSACharacter.h"

@class DSATalent;

@interface DSACharacterHero : DSACharacter

@property (nonatomic, copy) NSMutableDictionary *talents;
@property (nonatomic, copy) NSMutableDictionary *spells;
@property (nonatomic, copy) NSMutableDictionary *specials;
@property (nonatomic, copy) NSMutableDictionary *professions;
@property (nonatomic, copy) NSMutableDictionary *levelUpTalents;       // used to track talent level up attempts when reching a new level
@property (nonatomic, copy) NSMutableDictionary *levelUpSpells;        // used to track spell level up attempts when reching a new level
@property (nonatomic, copy) NSMutableDictionary *levelUpProfessions;   // used to track profession level up attempts when reching a new level
@property (nonatomic, copy) NSNumber *maxLevelUpTalentsTries;          // how often to try to level up all talents/professions (professions mix in here...)
@property (nonatomic, copy) NSNumber *maxLevelUpSpellsTries;           // how often to try to level up all spells
@property (nonatomic, copy) NSNumber *maxLevelUpTalentsTriesTmp;       // holding nr of overall talent tries, once variable tries is distributed
@property (nonatomic, copy) NSNumber *maxLevelUpSpellsTriesTmp;        // holding nr of overall spell tries, once variable tries is distributed
@property (nonatomic, copy) NSNumber *maxLevelUpVariableTries;         // variable tries, that can be added to talent or spell level ups
@property (nonatomic) BOOL isLevelingUp;                               // keeps track of the fact, if a character is in the phase of leveling up...
@property (nonatomic, copy) NSNumber *tempDeltaLpAe;                   // some characters roll one dice to level up LP and AE, and have to ask user how to distribute, here we temporarily save the result

- (NSDictionary *) levelUpBaseEnergies;
- (BOOL) levelUpPositiveTrait: (NSString *) trait;
- (BOOL) levelDownNegativeTrait: (NSString *) trait;
- (BOOL) levelUpTalent: (DSATalent *)talent;
- (BOOL) canLevelUpTalent: (DSATalent *)talent;
- (BOOL) canLevelUp;
- (void) prepareLevelUp;
- (void) finishLevelUp;

@end

#endif // _DSACHARACTERHERO_H_

