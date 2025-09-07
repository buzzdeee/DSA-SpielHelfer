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

#import "DSAInventory.h"
#import "DSAInventoryManager.h"

@implementation DSAInventory

- (instancetype)init {
    return [self initWithSlotType: DSASlotTypeGeneral quantity: 33 maxItemsPerSlot: 99];
}

- (instancetype)initWithSlotTypes:(NSArray<NSNumber *> *)slotTypes maxItemsPerSlot: (NSInteger) maxItemsPerSlot
{
    self = [super init];
    if (self) {
        _slots = [NSMutableArray arrayWithCapacity:slotTypes.count];
        for (NSNumber *slotType in slotTypes) {
            DSASlot *slot = [[DSASlot alloc] init];
            slot.slotType = slotType.unsignedIntegerValue;
            if ([slotType integerValue] == DSASlotTypeGeneral)
              {
                slot.maxItemsPerSlot = 99;
              }
            else
              {
                slot.maxItemsPerSlot = maxItemsPerSlot;
              }
            [_slots addObject:slot];
        }
    }
    return self;
}

// New initializer to create inventory with one slot type and a specified quantity
- (instancetype)initWithSlotType:(NSInteger)slotType quantity:(NSInteger)quantity maxItemsPerSlot: (NSInteger) maxItemsPerSlot
{
    self = [super init];
    if (self) {
        _slots = [NSMutableArray arrayWithCapacity:quantity];
        for (NSInteger i = 0; i < quantity; i++) {
            DSASlot *slot = [[DSASlot alloc] init];
            slot.slotType = slotType;  // Set the same slot type for all slots
            slot.maxItemsPerSlot = maxItemsPerSlot;
            [_slots addObject:slot];
        }
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
  self = [super init];
  if (self)
    {
      self.slots = [coder decodeObjectForKey:@"slots"];      
    }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  [coder encodeObject:self.slots forKey:@"slots"];
}

- (NSInteger)addObject:(DSAObject *)object quantity:(NSInteger)quantity {
    NSInteger totalAdded = 0;

    for (DSASlot *slot in self.slots) {
        if (slot.object == nil && [self isAllowedObject:object inSlot:slot]) {
            NSLog(@"DSAInventory: addObject: adding %@ to empty slot.", object.name);

            NSInteger amountToAdd = 0;

            if (object.canShareSlot) {
                // Add as many as possible in one slot
                amountToAdd = quantity;
            } else {
                // Only one item per slot
                amountToAdd = MIN(quantity, 1);
            }
            // we have top copy the object, to prevent referencing the same, over and over again...
            NSInteger added = [slot addObject:[object copy] quantity:amountToAdd];
            totalAdded += added;
            quantity -= added;

            if (quantity <= 0) {
                return totalAdded; // All items added
            }
        }
    }

    return totalAdded; // Return the total number of items added
}

- (BOOL)isAllowedObject:(DSAObject *)object inSlot:(DSASlot *)slot {
    NSLog(@"DSAInventory: isAllowedObject: Testing object slot type: %@ vs. slot.slotType: %ld", object.validSlotTypes, slot.slotType);
    for (NSNumber *validSlotType in object.validSlotTypes) {
        if (validSlotType.integerValue == slot.slotType) {
            return YES; // Object is allowed in this slot
        }
    }
    NSLog(@"DSAInventory isAllowedObject: %@ not allowed in slot!", object.name);
    return NO; // Object is not allowed in this slot
}

- (NSInteger)removeObject:(DSAObject *)object quantity:(NSInteger)quantity {
    NSInteger totalRemoved = 0;

    for (DSASlot *slot in self.slots) {
        if ([slot.object isCompatibleWithObject:object]) {
            NSInteger removed = [slot removeObjectWithQuantity:quantity];
            totalRemoved += removed;
            quantity -= removed;
            if (quantity <= 0) {
                return totalRemoved; // All items removed
            }
        }
    }

    return totalRemoved; // Return the total number of items removed
}

- (DSASlot *)slotAtIndex:(NSInteger)index {
    if (index < 0 || index >= self.slots.count) {
        return nil; // Out of bounds
    }
    return self.slots[index];
}

@end