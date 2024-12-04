/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-11-28 21:43:49 +0100 by sebastia

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

#ifndef _DSAINVENTORY_H_
#define _DSAINVENTORY_H_

#import <Foundation/Foundation.h>
#import "DSASlot.h"

@interface DSAInventory : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSMutableArray<DSASlot *> *slots;


// Default initializer (33 slots, 99 maxItemsPerSlot)
- (instancetype)init;

// Configurable initializer
- (instancetype)initWithSlotTypes:(NSArray<NSNumber *> *)slotTypes maxItemsPerSlot: (NSInteger) maxItemsPerSlot;  // for an inventory with different types per slot
- (instancetype)initWithSlotType:(NSInteger)slotType quantity:(NSInteger)quantity maxItemsPerSlot: (NSInteger) maxItemsPerSlot; // for an inventory with a single type of slots

- (NSInteger)addObject:(DSAObject *)object quantity:(NSInteger)quantity;
- (NSInteger)removeObject:(DSAObject *)object quantity:(NSInteger)quantity;
- (DSASlot *)slotAtIndex:(NSInteger)index;

@end

#endif // _DSAINVENTORY_H_

