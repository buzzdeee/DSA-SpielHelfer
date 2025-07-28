/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-07-12 20:07:15 +0200 by sebastia

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

#ifndef _DSAILLNESS_H_
#define _DSAILLNESS_H_

#import <Foundation/Foundation.h>
#import "DSACharacter.h"
#import "Utils.h"
@class DSAIllnessEffect;

NS_ASSUME_NONNULL_BEGIN

@interface DSAIllness : NSObject <NSCoding, NSCopying>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy, nullable) NSString *alternativeName;
@property (nonatomic, strong) NSDictionary<NSString *, id> *recognition;       // "Erkennung"
@property (nonatomic, assign) NSInteger dangerLevel;                           // "Gefährlichkeit"
@property (nonatomic, strong) NSDictionary<NSString *, id> *incubationPeriod;  // "Inkubationszeit"
@property (nonatomic, strong) NSDictionary<NSString *, id> *duration;          // "Dauer"
@property (nonatomic, strong) NSDictionary<NSString *, id> *treatment;         // "Behandlung"
@property (nonatomic, strong) NSDictionary<NSString *, id> *cause;             // "Ursache"
@property (nonatomic, strong) NSDictionary<NSString *, id> *remedies;          // "Gegenmittel"
@property (nonatomic, strong) NSDictionary<NSString *, id> *damage;            // "Schaden"
@property (nonatomic, copy, nullable) NSString *specialNotes;                  // "Besonderheiten"
@property (nonatomic, strong, nullable) NSDictionary<NSString *, NSNumber *> *followUpIllnessChance;    // Chance to get sick on follow-up illness in %

- (instancetype)initWithName:(NSString *)name dictionary:(NSDictionary *)dict;
- (nullable DSAIllnessEffect *)generateEffectForCharacter:(DSACharacter *)character;
- (DSAAventurianDate *)endDateOfStage:(DSAIllnessStage)currentStage
                             fromDate:(DSAAventurianDate *)currentDate;
                            
-(NSDictionary <NSString *, id>*) oneTimeDamage;
-(NSDictionary <NSString *, id>*) dailyDamage;
-(DSASeverityLevel) dangerLevelToSeverityLevel;
@end

@interface DSAIllnessRegistry : NSObject

@property (nonatomic, strong, readonly) NSDictionary<NSString *, DSAIllness *> *illnesses;
@property (nonatomic, strong, readonly) NSDictionary<NSString *, DSAIllness *> *alternateNames;

+ (instancetype)sharedRegistry;

- (nullable DSAIllness *)illnessWithName:(NSString *)name;
- (nullable DSAIllness *)illnessWithUniqueID:(NSString *)uniqueID;  // uniqueIDs are Illness_<Illness Name>
- (NSArray<NSString *> *)allIllnessNames;
@end

NS_ASSUME_NONNULL_END
#endif // _DSAILLNESS_H_

