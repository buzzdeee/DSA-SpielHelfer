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

#import "DSASlot.h"
#import "DSAObject.h"

@implementation DSASlot

static NSMutableDictionary<NSUUID *, DSASlot *> *slotRegistry = nil;

+ (DSASlot *)slotWithSlotID:(NSUUID *)slotID {
    @synchronized(slotRegistry) {
        // Just look up the slot by slotID (NSUUID key)
        DSASlot *slot = slotRegistry[slotID];
        if (slot) {
            NSLog(@"Found matching slotID: %@", [slotID UUIDString]);
        } else {
            NSLog(@"Slot with slotID: %@ not found", [slotID UUIDString]);
        }
        return slot;
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // Generate a unique UUID for modelID
        @synchronized([DSASlot class]) {
            if (!slotRegistry) {
                slotRegistry = [NSMutableDictionary dictionary];
            }
            if (_slotID == nil)
              {
                _slotID = [NSUUID UUID]; // Use NSUUID for a truly unique ID
                //NSLog(@"DSASlot init: Generated slotID: %@", _slotID);
              }

            if (!slotRegistry[_slotID]) {
                slotRegistry[_slotID] = self; // Register the character
            } else {
                NSLog(@"Warning: slotID %@ already exists!", _slotID);
            }
        }
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"DSACharacter dealloc called");
    @synchronized([DSASlot class]) {
        [slotRegistry removeObjectForKey:_slotID];
        NSLog(@"Slot with slotID %@ removed from registry.", _slotID);
    }
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
  self = [super init];
  if (self)
    {
      @synchronized([DSASlot class]) {
          if (!slotRegistry) {
              slotRegistry = [NSMutableDictionary dictionary];
          }
          if (_slotID == nil)
            {
              _slotID = [NSUUID UUID]; // Use NSUUID for a truly unique ID
              //NSLog(@"DSASlot initWithCoder: Generated slotID: %@", _slotID);
            }
           if (!slotRegistry[_slotID]) {
              slotRegistry[_slotID] = self; // Register the character
          } else {
              NSLog(@"DSASlot initWithCoder: Warning: slotID %@ already exists!", _slotID);
          }
      }    
      self.object = [coder decodeObjectForKey:@"object"];
      self.quantity = [coder decodeIntegerForKey:@"quantity"];
      self.slotType = [coder decodeIntegerForKey:@"slotType"];
      self.maxItemsPerSlot = [coder decodeIntegerForKey:@"maxItemsPerSlot"];
    }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  //[coder encodeObject:self.slotID forKey:@"slotID"];   // we don't need this, regenerating slots on initWithCoder
  [coder encodeObject:self.object forKey:@"object"];
  [coder encodeInteger:self.quantity forKey:@"quantity"];
  [coder encodeInteger:self.slotType forKey:@"slotType"];
  [coder encodeInteger:self.maxItemsPerSlot forKey:@"maxItemsPerSlot"];
}

- (NSInteger)addObject:(DSAObject *)object quantity:(NSInteger)quantity {
    if (self.object == nil) {
        // Empty slot, add the object
        self.object = object;
        NSInteger itemsToAdd = MIN(quantity, self.maxItemsPerSlot);
        self.quantity = itemsToAdd;
        return itemsToAdd;
    } else if ([self.object isCompatibleWithObject:object]) {
        // Compatible object, increase quantity
        NSInteger availableSpace = self.maxItemsPerSlot - self.quantity;
        NSInteger itemsToAdd = MIN(quantity, availableSpace);
        self.quantity += itemsToAdd;
        return itemsToAdd;
    }
    // Incompatible object
    return 0;
}

- (NSInteger)removeObjectWithQuantity:(NSInteger)quantityToRemove {
    if (self.quantity > quantityToRemove) {
        // Reduce the quantity but keep the object in the slot
        self.quantity -= quantityToRemove;
        return quantityToRemove;
    } else {
        // Remove all remaining items
        NSInteger itemsRemoved = self.quantity;
        self.object = nil;
        self.quantity = 0;
        return itemsRemoved;
    }
}
@end