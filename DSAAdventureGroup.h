/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-05-27 20:53:36 +0200 by sebastia

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

#ifndef _DSAADVENTUREGROUP_H_
#define _DSAADVENTUREGROUP_H_

#import "DSABaseObject.h"
#import "DSALocation.h"

@class DSAPosition;
@class DSAWeather;
@class DSAObject;
@class DSASlot;
@class DSACharacter;
@class DSAMiracleResult;

extern NSString * const DSALocalMapTileBuildingInnTypeHerberge;
extern NSString * const DSALocalMapTileBuildingInnTypeHerbergeMitTaverne;
extern NSString * const DSALocalMapTileBuildingInnTypeTaverne;

@interface DSAAdventureGroup : DSABaseObject <NSCoding>

@property (nonatomic, strong) NSMutableArray<NSUUID *> *partyMembers;
@property (nonatomic, strong) NSMutableArray<NSUUID *> *npcMembers;
@property (nonatomic, readonly) NSArray<NSUUID *> *allMembers;
@property (nonatomic, readonly) NSArray<DSACharacter *> *partyCharacters;
@property (nonatomic, readonly) NSArray<DSACharacter *> *npcCharacters;
@property (nonatomic, readonly) NSArray<DSACharacter *> *allCharacters;
@property (nonatomic, readonly) NSInteger membersCount;                 // count of all members in the group
@property (nonatomic, strong) NSMutableArray<NSUUID *> *nightGuards;
@property (nonatomic, strong) DSAPosition *position;
@property (nonatomic, assign) DSADirection headingDirection;
@property (nonatomic, strong) DSAWeather *weather;

- (instancetype)initWithPartyMembers:(NSArray<NSUUID *> *)members
                            position:(DSAPosition *)position
                             weather:(DSAWeather *)weather;

- (float)totalWealthOfGroup;           // in Silber
- (void)subtractSilber:(float)silber;  // evenly pay in a shop or Inn ...
- (void)addSilber:(float)silber;       // evenly distribute after sell in shop, or find after fight...
- (DSACharacter *)findOwnerOfInventorySlot:(DSASlot *)slot; 
- (void)distributeItems:(DSAObject*)item count: (NSInteger) count; // distributes found or bought items
- (NSArray<DSASlot *> *)getAllDSASlotsForShop:(NSString *)shopType;  // all inventory slots containing items that can be traded in the given shop type

- (BOOL)hasCharacterWithoutUniqueMiracle:(NSString *)miracleKey;     // checks if the group has a member without a given permanent miracle
- (NSArray<DSACharacter *> *)charactersWithoutUniqueMiracle:(NSString *)miracleKey;  // returns all Characters that don't yet have received a given permanent miracle
- (BOOL)hasMageInGroup;                                        // returns YES if a mage is in the group
- (NSInteger) charactersWithBookedRoomOfKey: (NSString *) roomKey;   // Number of characters that have a room booked
- (NSArray<DSACharacter *> *)illCharactersIncludingNPCs: (BOOL) includeNPCs;
- (NSArray<DSACharacter *> *)woundedCharactersIncludingNPCs: (BOOL) includeNPCs;
- (NSArray<DSACharacter *> *)poisonedCharactersIncludingNPCs: (BOOL) includeNPCs;
- (NSArray<DSACharacter *> *)charactersAbleToUseTalentsIncludingNPCs: (BOOL) includeNPCs;
- (NSArray<DSACharacter *> *)charactersAbleToCastSpellsIncludingNPCs: (BOOL) includeNPCs;
- (NSArray<DSACharacter *> *)charactersAbleToCastRitualsIncludingNPCs: (BOOL) includeNPCs;

- (void)applyMiracle:(DSAMiracleResult *)miracleResult;        // to all, or an individual of the group

@end                             

@interface DSAAdventureGroup (moveGroup)
- (DSAPosition *)moveGroupInDirection:(DSADirection)direction;
- (void) leaveLocation;
@end

#endif // _DSAADVENTUREGROUP_H_

