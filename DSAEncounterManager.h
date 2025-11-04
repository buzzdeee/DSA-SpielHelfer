/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-11-04 20:35:14 +0100 by sebastia

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

#ifndef _DSAENCOUNTERMANAGER_H_
#define _DSAENCOUNTERMANAGER_H_

#import <Foundation/Foundation.h>

@class DSAAdventure;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, DSAEncounterSeverity) {
    DSAEncounterSeverityTrivial,
    DSAEncounterSeverityMinor,
    DSAEncounterSeverityMajor,
    DSAEncounterSeverityDeadly
};

@interface DSAEncounterManager : NSObject

@property (nonatomic, weak) DSAAdventure *adventure;          // Kontext
@property (nonatomic, copy) NSString *terrainKey;             // e.g. @"road", @"forest", @"mountain", @"swamp"
@property (nonatomic, assign) double baseChancePerHour;       // e.g. 0.10 = 10% per hour
@property (nonatomic, assign) double accumulatedMinutes;      // internal
@property (nonatomic, assign) BOOL enabled;

// Optional external tables (if nil, use built-in defaults)
@property (nonatomic, strong, nullable) NSDictionary *encounterTables; // loaded from JSON or bundle

- (instancetype)initWithAdventure:(DSAAdventure *)adventure;
- (void)subscribeToClock;    // registers for DSAGameTimeAdvanced
- (void)unsubscribeFromClock;
- (void)setTerrainKey:(NSString*)terrainKey withModifier:(double)modifier; // change terrain & optional modifier
- (void)processMinutes:(double)minutes; // can be called manually (useful for testing)

@end

NS_ASSUME_NONNULL_END

#endif // _DSAENCOUNTERMANAGER_H_

