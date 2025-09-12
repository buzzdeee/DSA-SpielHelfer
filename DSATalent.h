/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-09-12 20:41:26 +0200 by sebastia

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

#ifndef _DSATALENT_H_
#define _DSATALENT_H_

#import "DSABaseObject.h"
#import "DSADefinitions.h"
@class DSACharacter;

NS_ASSUME_NONNULL_BEGIN

@interface DSATalent : DSABaseObject <NSCoding>

@property (nonatomic, assign) NSInteger level;
@property (nonatomic, assign) DSAActionTargetType targetType;           // the target type of a talent
@property (nonatomic, assign) NSInteger maxUpPerLevel;
@property (nonatomic, assign) NSInteger maxTriesPerLevelUp;
@property (nonatomic, assign) NSInteger levelUpCost;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *talentDescription;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *subCategory;
@property (nonatomic, strong) NSArray *test;
@property (nonatomic) BOOL isPersonalTalent;              // set to YES, for i.e. Musizieren for Skald or Bard
@property (nonatomic, strong) NSMutableDictionary *influencesTalents;

+ (instancetype)talentWithName: (NSString *) talentName
                  forCharacter: (nullable DSACharacter *) character;

+ (instancetype)talentWithName: (NSString *) name
                 inSubCategory: (nullable NSString *) subCategory
                    ofCategory: (NSString *) category
                       onLevel: (NSInteger) level
                      withTest: (nullable NSArray *) test
        withMaxTriesPerLevelUp: (NSInteger) maxTriesPerLevelUp
             withMaxUpPerLevel: (NSInteger) maxUpPerLevel
               withLevelUpCost: (NSInteger) levelUpCost
        influencesOtherTalents: (nullable NSMutableDictionary *)otherInfluencedTalents;

- (instancetype)initTalent: (NSString *) name
             inSubCategory: (nullable NSString *) subCategory
                ofCategory: (NSString *) category
                   onLevel: (NSInteger) level
                  withTest: (nullable NSArray *) test
    withMaxTriesPerLevelUp: (NSInteger) maxTriesPerLevelUp
         withMaxUpPerLevel: (NSInteger) maxUpPerLevel
           withLevelUpCost: (NSInteger) levelUpCost
    influencesOtherTalents: (nullable NSMutableDictionary *) otherInfluencedTalents;           

- (BOOL) levelUp;

@end
// End of DSATalent

@interface DSAFightingTalent : DSATalent

@end
// End of DSAFightingTalent

@interface DSAGeneralTalent : DSATalent                          

@end
// End of DSAGeneralTalent

@interface DSAProfession : DSAGeneralTalent

@end
// End of DSAProfession

@interface DSASpecialTalent : DSATalent
                          
@end
// End of DSASpecialTalent

#endif // _DSATALENT_H_

@interface DSATalentResult : DSABaseObject
@property (nonatomic, assign) DSAActionResultValue result;
@property (nonatomic, strong) NSArray *diceResults;
@property (nonatomic, assign) NSInteger remainingTalentPoints;

+(NSString *) resultNameForResultValue: (DSAActionResultValue) value;
@end
// End of DSATalentResult


@interface DSATalentManager : NSObject
@property (nonatomic, strong, nullable) NSMutableDictionary <NSString *, NSMutableDictionary *> *talentsByCategory;
@property (nonatomic, strong, nullable) NSMutableDictionary <NSString *, NSMutableDictionary *> *professionsByName;
+ (instancetype)sharedManager;

- (NSDictionary *) getTalentsDict;
- (NSDictionary *) getTalentsDictForCharacter: (DSACharacter *)character;
- (NSMutableDictionary <NSString *, DSATalent*>*)getTalentsForCharacter: (DSACharacter *)character;
- (NSMutableDictionary <NSString *, DSASpecialTalent*>*)getMagicalDabblerTalentsByTalentsNameArray: (NSArray *) specialTalentNames;

- (NSDictionary *) getProfessionsDict;
- (NSArray *) getProfessionsForArchetype: (nullable NSString *) archetype;
@end

NS_ASSUME_NONNULL_END