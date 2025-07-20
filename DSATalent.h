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

#import <Foundation/Foundation.h>
#import "DSADefinitions.h"
@class DSACharacter;

@interface DSATalent : NSObject <NSCoding, NSCopying>

@property (nonatomic, assign) NSInteger level;
@property (nonatomic, assign) DSAActionTargetType targetType;           // the target type of a talent
@property (nonatomic, assign) NSInteger maxUpPerLevel;
@property (nonatomic, assign) NSInteger maxTriesPerLevelUp;
@property (nonatomic, assign) NSInteger levelUpCost;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *talentDescription;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSArray *test;
@property (nonatomic) BOOL isPersonalTalent;              // set to YES, for i.e. Musizieren for Skald or Bard

- (BOOL) levelUp;

@end
// End of DSATalent

@interface DSAFightingTalent : DSATalent
@property (nonatomic, strong) NSString *subCategory;
- (instancetype)initTalent: (NSString *) name
             inSubCategory: (NSString *) subCategory
                ofCategory: (NSString *) category
                   onLevel: (NSInteger) level
    withMaxTriesPerLevelUp: (NSInteger) maxTriesPerLevelUp
         withMaxUpPerLevel: (NSInteger) maxUpPerLevel
           withLevelUpCost: (NSInteger) levelUpCost;
@end
// End of DSAFightingTalent

@interface DSAOtherTalent : DSATalent
- (instancetype)initTalent: (NSString *) name
                ofCategory: (NSString *) category 
                   onLevel: (NSInteger) level
                  withTest: (NSArray *) test
    withMaxTriesPerLevelUp: (NSInteger) maxTriesPerLevelUp
         withMaxUpPerLevel: (NSInteger) maxUpPerLevel
           withLevelUpCost: (NSInteger) levelUpCost;                          

@end
// End of DSAOtherTalent

@interface DSAProfession : DSAOtherTalent <NSCoding, NSCopying>
@property (nonatomic, strong) NSMutableDictionary *influencesTalents;
- (instancetype)initProfession: (NSString *) name
                    ofCategory: (NSString *) category
                       onLevel: (NSInteger) level
                      withTest: (NSArray *) test
        withMaxTriesPerLevelUp: (NSInteger) maxTriesPerLevelUp
             withMaxUpPerLevel: (NSInteger) maxUpPerLevel
             influencesTalents: (NSMutableDictionary *)talents;
@end
// End of DSAProfession

@interface DSASpecialTalent : DSATalent
- (instancetype)initTalent: (NSString *) name
                ofCategory: (NSString *) category 
                   onLevel: (NSInteger) level
                  withTest: (NSArray *) test
    withMaxTriesPerLevelUp: (NSInteger) maxTriesPerLevelUp
         withMaxUpPerLevel: (NSInteger) maxUpPerLevel
           withLevelUpCost: (NSInteger) levelUpCost;                          
@end
// End of DSASpecialTalent

#endif // _DSATALENT_H_

typedef NS_ENUM(NSUInteger, DSATalentResultValue)
{
  DSATalentResultNone,             // no result yet
  DSATalentResultSuccess,          // normal success
  DSATalentResultAutoSuccess,      // two times 1 as dice result
  DSATalentResultEpicSuccess,      // three times 1 as dice result
  DSATalentResultFailure,          // normal failure
  DSATalentResultAutoFailure,      // two times 20 as dice result
  DSATalentResultEpicFailure       // three times 20 as dice result
};

@interface DSATalentResult : NSObject
@property (nonatomic, assign) DSATalentResultValue result;
@property (nonatomic, strong) NSArray *diceResults;
@property (nonatomic, assign) NSInteger remainingTalentPoints;

+(NSString *) resultNameForResultValue: (DSATalentResultValue) value;
@end
// End of DSATalentResult