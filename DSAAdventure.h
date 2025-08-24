/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-01-01 23:26:05 +0100 by sebastia

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

#ifndef _DSAADVENTURE_H_
#define _DSAADVENTURE_H_

#import <Foundation/Foundation.h>
#import "DSACharacter.h"
#import "DSAWeather.h"

NS_ASSUME_NONNULL_BEGIN

@class DSAAdventureClock;
@class DSAAdventureGroup;
@class DSAMapCoordinate;
@class DSAGod;

typedef NSString * DSAActionContext;

extern DSAActionContext const DSAActionContextResting;
extern DSAActionContext const DSAActionContextPrivateRoom;
extern DSAActionContext const DSAActionContextTavern;
extern DSAActionContext const DSAActionContextMarket;
extern DSAActionContext const DSAActionContextOnTheRoad;
extern DSAActionContext const DSAActionContextReception;


@interface DSAAdventure : NSObject

@property (nonatomic, strong) NSMutableArray<DSAAdventureGroup *> *groups; // index 0 = aktiv
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableSet<DSAMapCoordinate *> *> *discoveredCoordinates;

// Convenience Accessor
@property (nonatomic, readonly) DSAAdventureGroup *activeGroup;

@property (nonatomic, strong) DSAAdventureClock *gameClock; // In-game time
@property (nonatomic, strong) DSAWeather *gameWeather;      // the current weather
@property (nonatomic, strong) NSArray <DSAGod *> *gods;
@property (nonatomic, strong) NSDictionary<NSNumber *, DSAGod *> *godsByType;
@property (nonatomic, strong) NSDictionary<NSString *, DSAGod *> *godsByName;

@property (nonatomic, copy) NSDictionary<DSAActionContext, NSArray<NSString *> *> *availableTalentsByContext;
@property (nonatomic, copy) NSDictionary<DSAActionContext, NSArray<NSString *> *> *availableSpellsByContext;
@property (nonatomic, copy) NSDictionary<DSAActionContext, NSArray<NSString *> *> *availableRitualsByContext;


@property (strong) NSMutableDictionary<NSString *, NSString *> *characterFilePaths;

- (DSAAdventureGroup *)activeGroup;
- (void)switchToGroupAtIndex:(NSUInteger)index;
- (void)addCharacterToActiveGroup:(NSUUID *)characterUUID;
- (void)removeCharacterFromActiveGroup:(NSUUID *)characterUUID;

- (void)moveCharacter: (NSUUID *) characterUUID toGroup: (DSAAdventureGroup *) targetGroup;  // move from active group
- (void)discoverCoordinate:(DSAMapCoordinate *)coord forLocation:(NSString *)location;
- (BOOL)isCoordinateDiscovered:(DSAMapCoordinate *)coord forLocation:(NSString *)location;

@end

@interface DSAAdventureManager : NSObject
@property (nonatomic, strong, nullable) DSAAdventure *currentAdventure;
+ (instancetype)sharedManager;
@end

NS_ASSUME_NONNULL_END
#endif // _DSAADVENTURE_H_

