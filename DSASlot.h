/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-11-28 21:35:30 +0100 by sebastia

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

#ifndef _DSASLOT_H_
#define _DSASLOT_H_

#import "DSABaseObject.h"
#import "DSADefinitions.h"
@class DSAObject;



@interface DSASlot : DSABaseObject <NSCoding>

@property (nonatomic, strong) NSUUID *slotID;       // UUID to eas tracking the slot
@property (nonatomic, assign) DSASlotType slotType; // Define what this slot can hold
@property (nonatomic, strong) DSAObject *object;    // a DSAobject in the slot
@property (nonatomic, assign) NSInteger quantity;   // how many objects share the slot
@property (nonatomic, assign) NSInteger maxItemsPerSlot;  // if a object is in a slot, that can share a single slot, limit to this maximum number

+ (DSASlot *)slotWithSlotID:(NSUUID *)slotID;

- (NSInteger)addObject:(DSAObject *)object quantity:(NSInteger)quantity;
- (NSInteger)removeObjectWithQuantity: (NSInteger)quantityToRemove;

@end

#endif // _DSASLOT_H_

