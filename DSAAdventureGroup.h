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

#import <Foundation/Foundation.h>
#import "DSALocation.h"

@class DSAPosition;
@class DSAWeather;
@class DSAObject;
@class DSASlot;
@class DSACharacter;

@interface DSAAdventureGroup : NSObject <NSCoding>

@property (nonatomic, strong) NSMutableArray<NSUUID *> *partyMembers;
@property (nonatomic, strong) NSMutableArray<NSUUID *> *npcMembers;
@property (nonatomic, readonly) NSArray<NSUUID *> *allMembers;
@property (nonatomic, strong) DSAPosition *position;
@property (nonatomic, assign) DSADirection headingDirection;
@property (nonatomic, strong) DSAWeather *weather;

- (instancetype)initWithPartyMembers:(NSArray<NSUUID *> *)members
                            position:(DSAPosition *)position
                             weather:(DSAWeather *)weather;

- (float)totalWealthOfGroup;
- (void)subtractSilber:(float)silber;  // evenly pay in a shop or Inn ...
- (void)addSilber:(float)silber;       // evenly distribute after sell in shop, or find after fight...
- (DSACharacter *)findOwnerOfInventorySlot:(DSASlot *)slot; 
- (void)distributeItems:(DSAObject*)item count: (NSInteger) count; // distributes found or bought items
- (NSArray<DSASlot *> *)getAllDSASlotsForShop:(NSString *)shopType;  // all inventory slots containing items that can be traded in the given shop type

@end                             

#endif // _DSAADVENTUREGROUP_H_

