/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-07-27 19:17:06 +0200 by sebastia

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

#ifndef _DSAPOISON_H_
#define _DSAPOISON_H_

#import <Foundation/Foundation.h>
#import "DSAObject.h"
#import "DSADefinitions.h"
@class DSAPoisonEffect;
@class DSACharacter;
@class DSAAventurianDate;

NS_ASSUME_NONNULL_BEGIN

@interface DSAPoison : DSAObject <NSCoding, NSCopying>

@property (nonatomic, assign) NSInteger dangerLevel;              // formerly "Stufe"
@property (nonatomic, strong) NSArray<NSString *> *types;         // formerly "Typ"
@property (nonatomic, strong) NSDictionary *onset;                // formerly "Beginn"
@property (nonatomic, strong) NSDictionary *duration;             // formerly "Dauer"
@property (nonatomic, strong) NSDictionary<NSString *, id> *damage;   // "Schaden"
@property (nonatomic, strong) NSDictionary *shelfLife;            // formerly "Haltbarkeit"
@property (nonatomic, assign) float cost;                         // formerly "Preis"
@property (nonatomic, strong) NSArray<NSDictionary *> *crafting;  // formerly "Herstellung"

// Init
- (instancetype)initWithName:(NSString *)name fromDictionary:(NSDictionary *)dict;

- (nullable DSAPoisonEffect *)generateEffectForCharacter:(DSACharacter *)character;

- (DSAAventurianDate *)endDateOfStage:(DSAPoisonStage) currentStage
                             fromDate:(DSAAventurianDate *)currentDate;
-(NSDictionary <NSString *, id>*) oneTimeDamage;
-(NSDictionary <NSString *, id>*) recurringDamage;
-(DSASeverityLevel) dangerLevelToSeverityLevel;
@end

#pragma mark - Registry

@interface DSAPoisonRegistry : NSObject

+ (instancetype)sharedRegistry;

+ (DSAPoisonType)poisonTypeFromString:(NSString *)typeString;
+ (NSString *)stringFromPoisonType:(DSAPoisonType)type;

- (NSArray<DSAPoison *> *)allPoisons;
- (NSArray<DSAPoison *> *)sortedPoisonsByName;
- (NSDictionary<NSNumber *, NSArray<DSAPoison *> *> *)groupedByPoisonType;
- (nullable DSAPoison *)poisonWithName:(NSString *)name;
- (nullable DSAPoison *)poisonWithUniqueID:(NSString *)uniqueID;
- (NSDictionary<NSNumber *, NSArray<DSAPoison *> *> *)groupedByPoisonType;
- (NSArray<NSString *> *)allPoisonNames;
@end
NS_ASSUME_NONNULL_END
#endif // _DSAPOISON_H_

