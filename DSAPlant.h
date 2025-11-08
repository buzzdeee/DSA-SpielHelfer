/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-09-24 21:06:09 +0200 by sebastia

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

#ifndef _DSAPLANT_H_
#define _DSAPLANT_H_

#import <Foundation/Foundation.h>
#import "DSAObject.h"
#import "DSADefinitions.h"
@class DSAPoisonEffect;
@class DSACharacter;
@class DSAAventurianDate;

NS_ASSUME_NONNULL_BEGIN

@interface DSAPlant : DSAObject <NSCoding, NSCopying>
@property (nonatomic, assign) NSInteger recognition;              // Bekanntheit
@property (nonatomic, strong) NSDictionary *shelfLife;            // Haltbarkeit
@property (nonatomic, strong) NSDictionary *harvest; // entspricht "Ernte" aus JSON

// Init
- (instancetype)initWithName:(NSString *)name fromDictionary:(NSDictionary *)dict;
@end

#pragma mark - Registry

@interface DSAPlantRegistry : NSObject

+ (instancetype)sharedRegistry;

- (NSArray<DSAPlant *> *)allPlants;
- (NSArray<DSAPlant *> *)sortedPlantsByName;
- (nullable DSAPlant *)plantWithName:(NSString *)name;
- (nullable DSAPlant *)plantWithUniqueID:(NSString *)uniqueID;
- (NSArray<NSString *> *)allPlantNames;
@end
NS_ASSUME_NONNULL_END

#endif // _DSAPLANT_H_

