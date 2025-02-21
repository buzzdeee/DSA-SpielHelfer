/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-09-11 23:01:49 +0200 by sebastia

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

#ifndef _DSASPELL_H_
#define _DSASPELL_H_

#import <Foundation/Foundation.h>
@class DSACharacter;
@class DSASpellResult;

@interface DSASpell : NSObject <NSCoding, NSCopying>

@property (nonatomic, assign) NSInteger level;
@property (nonatomic, strong) NSArray *origin;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *longName;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *element;
@property (nonatomic, strong) NSString *technique;
@property (nonatomic, strong) NSArray *test;
@property (nonatomic, strong) NSArray <NSString *> *variants;          // variant versions of a spell, i.e. depending on element, or others
@property (nonatomic, strong) NSString *variant;                       // the selected variant
@property (nonatomic, strong) NSArray <NSString *> *durationVariants;  // variant versions of a spell, some have standard duration, some additionally permanent
@property (nonatomic, strong) NSString *durationVariant;               // the selected time variant

// for spells, that have a fixed cost
@property (nonatomic, assign) NSInteger aspCost;
@property (nonatomic, assign) NSInteger permanentASPCost;
@property (nonatomic, assign) NSInteger lpCost;
@property (nonatomic, assign) NSInteger permanentLPCost;

@property (nonatomic, assign) NSInteger spellDuration;           // in seconds, -1 means permanent
@property (nonatomic, assign) NSInteger spellingDuration;        // in seconds
@property (nonatomic, assign) NSInteger maxDistance;             // in Schritt
@property (nonatomic, assign) NSInteger removalCostASP;          // how much it will cost to remove the spell from an object (i.e. using Destructibo Arcanitas)
@property (nonatomic, assign) NSInteger casterLevel;             // level of the magical character that casted the spell
@property (nonatomic, assign) NSInteger penalty;                 // some spells, esp. rituals have some general penalty on the test
@property (nonatomic, assign) NSInteger levelUpCost;
@property (nonatomic, assign) NSInteger maxUpPerLevel;
@property (nonatomic, assign) NSInteger maxTriesPerLevelUp;
@property (nonatomic) BOOL canCastOnSelf;
@property (nonatomic, strong) NSArray<NSString *> *allowedTargetTypes;   // Strings of class names target types
@property (nonatomic, strong) NSDictionary *targetTypeRestrictions; // eventual restrictions applied to target types, i.e. DSAObject but only when name == XXX
@property (nonatomic) BOOL everLeveledUp;
@property (nonatomic) BOOL isTraditionSpell;
@property (nonatomic, readonly) BOOL isActiveSpell;

// creates subclass from class cluster
+ (instancetype)spellWithName: (NSString *) name
                    ofVariant: (NSString *) variant
            ofDurationVariant: (NSString *) durationVariant
                   ofCategory: (NSString *) category
                      onLevel: (NSInteger) level
                   withOrigin: (NSArray *) origin
                     withTest: (NSArray *) test
              withMaxDistance: (NSInteger) maxDistance
                 withVariants: (NSArray *) variants   
         withDurationVariants: (NSArray *) durationVariants
       withMaxTriesPerLevelUp: (NSInteger) maxTriesPerLevelUp
            withMaxUpPerLevel: (NSInteger) maxUpPerLevel
              withLevelUpCost: (NSInteger) levelUpCost;

// just creates simple DSASpell
- (instancetype)initSpell: (NSString *) newName
                ofVariant: (NSString *) variant
        ofDurationVariant: (NSString *) durationVariant
               ofCategory: (NSString *) newCategory 
                  onLevel: (NSInteger) newLevel
               withOrigin: (NSArray *) newOrigin
                 withTest: (NSArray *) newTest
          withMaxDistance: (NSInteger) maxDistance        
             withVariants: (NSArray *) variants        
     withDurationVariants: (NSArray *) durationVariants
   withMaxTriesPerLevelUp: (NSInteger) newMaxTriesPerLevelUp
        withMaxUpPerLevel: (NSInteger) newMaxUpPerLevel        
          withLevelUpCost: (NSInteger) levelUpCost;
        
        
- (BOOL) levelUp;

- (DSASpellResult *) castOnTarget: (id) target                        // The target of the spell, a DSACharacter or DSAObject
                        ofVariant: (NSString *) variant               // Spells might have slight variations
                ofDurationVariant: (NSString *) durationVariant       // might be of a "standard" time, or even permanent
                       atDistance: (NSInteger) distance               // the distance the target is away in Schritt
                      investedASP: (NSInteger) invested               // for some spells, the casting character can define how many ASP to invest
             spellOriginCharacter: (DSACharacter *) originCharacter   // character who spelled a cast on the target before
            spellCastingCharacter: (DSACharacter *) castingCharacter; // the character actually casting the spell
            
// helper methods related to casting spells            
- (BOOL) verifyDistance: (NSInteger) distance;  
- (BOOL) verifyTarget: (id) target andOrigin: (DSACharacter *) origin;  
- (DSASpellResult *) testTraitsWithSpellLevel: (NSInteger) level castingCharacter: (DSACharacter *) castingCharacter;
- (BOOL) applyEffectOnTarget: (id) target forOwner: (DSACharacter *) owner;
@end

// all the DSASpell subclasses
// Antimagie
@interface DSASpellBeherrschungenBrechen : DSASpell
@end
@interface DSASpellBewegungenStoeren : DSASpell
@end
@interface DSASpellDestructiboArcanitas : DSASpell
@end

#endif // _DSASPELL_H_

