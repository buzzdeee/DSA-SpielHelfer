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
            slot.maxItemsPerSlot = maxItemsPerSlot;
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


- (NSString *)description
{
  NSMutableString *descriptionString = [NSMutableString stringWithFormat:@"%@:\n", [self class]];

  // Start from the current class
  Class currentClass = [self class];

  // Loop through the class hierarchy
  while (currentClass && currentClass != [NSObject class])
    {
      // Get the list of properties for the current class
      unsigned int propertyCount;
      objc_property_t *properties = class_copyPropertyList(currentClass, &propertyCount);

      // Iterate through all properties of the current class
      for (unsigned int i = 0; i < propertyCount; i++)
        {
          objc_property_t property = properties[i];
          const char *propertyName = property_getName(property);
          NSString *key = [NSString stringWithUTF8String:propertyName];
            
          // Get the value of the property using KVC (Key-Value Coding)
          id value = [self valueForKey:key];

          // Append the property and its value to the description string
          [descriptionString appendFormat:@"%@ = %@\n", key, value];
        }

      // Free the property list since it's a C array
      free(properties);

      // Move to the superclass
      currentClass = [currentClass superclass];
    }

  return descriptionString;
}

// Ignores readonly variables with the assumption
// they are all calculated
- (id)copyWithZone:(NSZone *)zone
{
  // Create a new instance of the class
  DSAInventory *copy = [[[self class] allocWithZone:zone] init];

  Class currentClass = [self class];
  while (currentClass != [NSObject class])
    {  // Loop through class hierarchy
      // Get a list of all properties for this class
      unsigned int propertyCount;
      objc_property_t *properties = class_copyPropertyList(currentClass, &propertyCount);
        
      // Iterate over each property
      for (unsigned int i = 0; i < propertyCount; i++)
        {
          objc_property_t property = properties[i];
          // Get the property name
          const char *propertyName = property_getName(property);
          NSString *key = [NSString stringWithUTF8String:propertyName];

          // Get the property attributes
          const char *attributes = property_getAttributes(property);
          NSString *attributesString = [NSString stringWithUTF8String:attributes];
          // Check if the property is readonly by looking for the "R" attribute
          if ([attributesString containsString:@",R"])
            {
              // This is a readonly property, skip copying it
              continue;
            }
            
          // Get the value of the property for the current object
          id value = [self valueForKey:key];

          if (value)
            {
              // Handle arrays specifically
              if ([value isKindOfClass:[NSArray class]])
                {
                  // Create a mutable array to copy the elements
                  NSMutableArray *copiedArray = [[NSMutableArray alloc] initWithCapacity:[(NSArray *)value count]];
                  for (id item in (NSArray *)value)
                    {
                      if ([item conformsToProtocol:@protocol(NSCopying)])
                        {
                          [copiedArray addObject:[item copyWithZone:zone]];
                        } else {
                          [copiedArray addObject:item]; // Fallback to shallow copy
                        }
                    }
                  [copy setValue:[NSArray arrayWithArray:copiedArray] forKey:key];
                }
              // Check if the property conforms to NSCopying
              else if ([value conformsToProtocol:@protocol(NSCopying)])
                {
                  [copy setValue:[value copyWithZone:zone] forKey:key];
                }
              else
                {
                    // Just assign the reference (shallow copy)
                    [copy setValue:value forKey:key];
                }
            }
        }

      // Free the property list memory
      free(properties);
        
      // Move to superclass
      currentClass = [currentClass superclass];
    }    
  return copy;
}

- (NSInteger)addObject:(DSAObject *)object quantity:(NSInteger)quantity {
    NSInteger totalAdded = 0;

    // Try to add to existing compatible slots first
    for (DSASlot *slot in self.slots) {
        if ([slot.object isCompatibleWithObject:object]) {
            NSInteger added = [slot addObject:object quantity:quantity];
            totalAdded += added;
            quantity -= added;
            if (quantity <= 0) {
                return totalAdded; // All items added
            }
        }
    }

    // Add to empty slots if any items remain
    for (DSASlot *slot in self.slots) {
        if (slot.object == nil && [self isAllowedObject:object inSlot:slot]) {
            NSInteger added = [slot addObject:object quantity:quantity];
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
    for (NSNumber *validSlotType in object.validSlotTypes) {
        if (validSlotType.integerValue == slot.slotType) {
            return YES; // Object is allowed in this slot
        }
    }
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