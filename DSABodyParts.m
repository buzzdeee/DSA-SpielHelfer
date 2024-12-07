/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-11-28 22:43:54 +0100 by sebastia

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

#import "DSABodyParts.h"

@implementation DSABodyParts
- (instancetype)init
{
  self = [super init];
  if (self)
    {
       // Initialize inventories for each body part with appropriate constraints
       self.head = [[DSAInventory alloc] initWithSlotTypes: @[@(DSASlotTypeHeadgear)] maxItemsPerSlot: 1];
       self.neck = [[DSAInventory alloc] initWithSlotType: DSASlotTypeNecklace quantity: 2 maxItemsPerSlot: 1];       
       self.eyes = [[DSAInventory alloc] initWithSlotType: DSASlotTypeGlasses quantity: 1 maxItemsPerSlot: 1];
       self.leftEar = [[DSAInventory alloc] initWithSlotType: DSASlotTypeEarring quantity: 1 maxItemsPerSlot: 1];
       self.rightEar = [[DSAInventory alloc] initWithSlotType: DSASlotTypeEarring quantity: 1 maxItemsPerSlot: 1];
       self.nose = [[DSAInventory alloc] initWithSlotType: DSASlotTypeEarring quantity: 1 maxItemsPerSlot: 1];
       self.face = [[DSAInventory alloc] initWithSlotType: DSASlotTypeMask quantity: 1 maxItemsPerSlot: 1];    
       self.back = [[DSAInventory alloc] initWithSlotTypes: @[@(DSASlotTypeBackquiver), @(DSASlotTypeBackpack)] maxItemsPerSlot: 1];
       self.shoulder = [[DSAInventory alloc] initWithSlotType: DSASlotTypeSash quantity: 2 maxItemsPerSlot: 1];                
       self.leftArm = [[DSAInventory alloc] initWithSlotTypes: @[@(DSASlotTypeArmArmor)] maxItemsPerSlot: 1];
       self.rightArm = [[DSAInventory alloc] initWithSlotTypes: @[@(DSASlotTypeArmArmor)] maxItemsPerSlot: 1];
       self.leftHand = [[DSAInventory alloc] initWithSlotTypes: @[@(DSASlotTypeGeneral), @(DSASlotTypeGloves)] maxItemsPerSlot: 1];
       self.rightHand = [[DSAInventory alloc] initWithSlotTypes: @[@(DSASlotTypeGeneral), @(DSASlotTypeGloves)] maxItemsPerSlot: 1];
       self.leftHandFingers = [[DSAInventory alloc] initWithSlotType: DSASlotTypeNecklace quantity: 1 maxItemsPerSlot: 1];
       self.rightHandFingers = [[DSAInventory alloc] initWithSlotType: DSASlotTypeNecklace quantity: 1 maxItemsPerSlot: 1];
       self.hip = [[DSAInventory alloc] initWithSlotTypes: @[@(DSASlotTypeHip)] maxItemsPerSlot: 1];       
       self.upperBody = [[DSAInventory alloc] initWithSlotTypes: @[@(DSASlotTypeBodyArmor), @(DSASlotTypeVest), @(DSASlotTypeJacket), @(DSASlotTypeShirt), @(DSASlotTypeUnderwear)] maxItemsPerSlot: 1];
       self.lowerBody = [[DSAInventory alloc] initWithSlotTypes: @[@(DSASlotTypeUnderwear)] maxItemsPerSlot: 1];
       self.leftLeg = [[DSAInventory alloc] initWithSlotTypes: @[@(DSASlotTypeLegArmor), @(DSASlotTypeTrousers)] maxItemsPerSlot: 1];
       self.rightLeg = [[DSAInventory alloc] initWithSlotTypes: @[@(DSASlotTypeLegArmor), @(DSASlotTypeTrousers)] maxItemsPerSlot: 1];
       self.leftFoot = [[DSAInventory alloc] initWithSlotTypes: @[@(DSASlotTypeSocks), @(DSASlotTypeShoes)] maxItemsPerSlot: 1];
       self.rightFoot = [[DSAInventory alloc] initWithSlotTypes: @[@(DSASlotTypeSocks), @(DSASlotTypeShoes)] maxItemsPerSlot: 1];
    }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
  self = [super init];
  if (self)
    {
      self.head = [coder decodeObjectForKey:@"head"];
      self.neck = [coder decodeObjectForKey:@"neck"];
      self.eyes = [coder decodeObjectForKey:@"eyes"];
      self.leftEar = [coder decodeObjectForKey:@"leftEar"];
      self.rightEar = [coder decodeObjectForKey:@"rightEar"];
      self.nose = [coder decodeObjectForKey:@"nose"];
      self.face = [coder decodeObjectForKey:@"face"];
      self.back = [coder decodeObjectForKey:@"back"];
      self.shoulder = [coder decodeObjectForKey:@"shoulder"];           
      self.leftArm = [coder decodeObjectForKey:@"leftArm"];
      self.rightArm = [coder decodeObjectForKey:@"rightArm"];
      self.leftHand = [coder decodeObjectForKey:@"leftHand"];
      self.rightHand = [coder decodeObjectForKey:@"rightHand"];
      self.leftHandFingers = [coder decodeObjectForKey:@"leftHandFingers"];
      self.rightHandFingers = [coder decodeObjectForKey:@"rightHandFingers"];
      self.hip = [coder decodeObjectForKey:@"hip"];      
      self.upperBody = [coder decodeObjectForKey:@"upperBody"];
      self.lowerBody = [coder decodeObjectForKey:@"lowerBody"];
      self.leftLeg = [coder decodeObjectForKey:@"leftLeg"];
      self.rightLeg = [coder decodeObjectForKey:@"rightLeg"];
      self.leftFoot = [coder decodeObjectForKey:@"leftFoot"];
      self.rightFoot = [coder decodeObjectForKey:@"rightFoot"];
    }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  [coder encodeObject:self.head forKey:@"head"];
  [coder encodeObject:self.neck forKey:@"neck"];
  [coder encodeObject:self.eyes forKey:@"eyes"];
  [coder encodeObject:self.leftEar forKey:@"leftEar"];
  [coder encodeObject:self.rightEar forKey:@"rightEar"];
  [coder encodeObject:self.nose forKey:@"nose"]; 
  [coder encodeObject:self.face forKey:@"face"];
  [coder encodeObject:self.back forKey:@"back"];
  [coder encodeObject:self.shoulder forKey:@"shoulder"];
  [coder encodeObject:self.leftArm forKey:@"leftArm"];
  [coder encodeObject:self.rightArm forKey:@"rightArm"];
  [coder encodeObject:self.leftHand forKey:@"leftHand"];
  [coder encodeObject:self.rightHand forKey:@"rightHand"];
  [coder encodeObject:self.leftHandFingers forKey:@"leftHandFingers"];
  [coder encodeObject:self.rightHandFingers forKey:@"rightHandFingers"];
  [coder encodeObject:self.hip forKey:@"hip"];
  [coder encodeObject:self.upperBody forKey:@"upperBody"];
  [coder encodeObject:self.lowerBody forKey:@"lowerBody"];
  [coder encodeObject:self.leftLeg forKey:@"leftLeg"];
  [coder encodeObject:self.rightLeg forKey:@"rightLeg"];
  [coder encodeObject:self.leftFoot forKey:@"leftFoot"];
  [coder encodeObject:self.rightFoot forKey:@"rightFoot"];  
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
  DSABodyParts *copy = [[[self class] allocWithZone:zone] init];

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

- (DSAEquipResult *)equipObject:(DSAObject *)object {
    DSAEquipResult *result = [[DSAEquipResult alloc] init];
    result.error = DSAEquipErrorNone;
    
    if (!object.occupiedBodyParts || object.occupiedBodyParts.count == 0) {
        result.error = DSAEquipErrorNoFreeSlot;
        result.errorMessage = @"The object does not specify any body parts to occupy.";
        return result;
    }

    for (NSString *bodyPart in object.occupiedBodyParts) {
        DSAInventory *inventory = [self inventoryForBodyPart:bodyPart];
        DSASlot *freeSlot = [self findFreeSlotInInventory:inventory forObject:object];
        if (!freeSlot) {
            result.error = DSAEquipErrorNoFreeSlot;
            result.errorMessage = [NSString stringWithFormat:@"No free slot available in %@", bodyPart];
            return result;
        }
    }

    // If no errors, proceed to equip
    for (NSString *bodyPart in object.occupiedBodyParts) {
        DSAInventory *inventory = [self inventoryForBodyPart:bodyPart];
        DSASlot *freeSlot = [self findFreeSlotInInventory:inventory forObject:object];
        freeSlot.object = object;
        freeSlot.quantity = 1;
    }
    
    return result; // Return result indicating success
}

- (DSASlot *)findFreeSlotInInventory:(DSAInventory *)inventory forObject:(DSAObject *)object {
    DSASlotType requiredSlotType = [self determineSlotTypeForObject:object];
    
    // Sort slots by priority (e.g., reserved slots first, then general slots)
    NSArray *sortedSlots = [inventory.slots sortedArrayUsingComparator:^NSComparisonResult(DSASlot *slot1, DSASlot *slot2) {
        if (slot1.slotType == requiredSlotType && slot2.slotType != requiredSlotType) {
            return NSOrderedAscending;
        } else if (slot1.slotType != requiredSlotType && slot2.slotType == requiredSlotType) {
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];
    
    for (DSASlot *slot in sortedSlots) {
        if (slot.object == nil && slot.slotType == requiredSlotType) {
            return slot;
        }
    }
    return nil; // No suitable slot found
}

- (DSASlotType)determineSlotTypeForObject:(DSAObject *)object {
    if ([object.subCategory isEqualToString:@"Underwear"]) {
        return DSASlotTypeUnderwear;
    } else if ([object.subCategory isEqualToString:@"Armor"]) {
        return DSASlotTypeBodyArmor;
    } else if ([object.subCategory isEqualToString:_(@"Helme")]) {
        return DSASlotTypeHeadgear;
    }
    return DSASlotTypeGeneral; // Default type
}

- (BOOL)isBodyPartAvailable:(DSAInventory *)inventory {
    for (DSASlot *slot in inventory.slots) {
        if (slot.object == nil) {
            return YES; // At least one slot is free
        }
    }
    return NO; // No free slots
}

// Map body part names to their corresponding inventory
- (DSAInventory *)inventoryForBodyPart:(NSString *)bodyPart {
    if ([bodyPart isEqualToString:@"head"]) return self.head;
    if ([bodyPart isEqualToString:@"neck"]) return self.neck;
    if ([bodyPart isEqualToString:@"eyes"]) return self.eyes;
    if ([bodyPart isEqualToString:@"leftEar"]) return self.leftEar;
    if ([bodyPart isEqualToString:@"rightEar"]) return self.rightEar;
    if ([bodyPart isEqualToString:@"nose"]) return self.nose;
    if ([bodyPart isEqualToString:@"face"]) return self.face;
    if ([bodyPart isEqualToString:@"back"]) return self.back;
    if ([bodyPart isEqualToString:@"shoulder"]) return self.shoulder;
    if ([bodyPart isEqualToString:@"leftArm"]) return self.leftArm;
    if ([bodyPart isEqualToString:@"leftArm"]) return self.leftArm;
    if ([bodyPart isEqualToString:@"rightArm"]) return self.rightArm;
    if ([bodyPart isEqualToString:@"leftHand"]) return self.leftHand;
    if ([bodyPart isEqualToString:@"rightHand"]) return self.rightHand;
    if ([bodyPart isEqualToString:@"leftHandFingers"]) return self.leftHandFingers;
    if ([bodyPart isEqualToString:@"rightHandFingers"]) return self.rightHandFingers;
    if ([bodyPart isEqualToString:@"hip"]) return self.hip;
    if ([bodyPart isEqualToString:@"lowerBody"]) return self.lowerBody;
    if ([bodyPart isEqualToString:@"leftLeg"]) return self.leftLeg;
    if ([bodyPart isEqualToString:@"rightLeg"]) return self.rightLeg;
    if ([bodyPart isEqualToString:@"leftFoot"]) return self.leftFoot;
    if ([bodyPart isEqualToString:@"rightFoot"]) return self.rightFoot;    
    return nil; // Invalid body part
}

- (void)unequipObject:(DSAObject *)object {
    for (NSString *bodyPart in object.occupiedBodyParts) {
        DSAInventory *inventory = [self inventoryForBodyPart:bodyPart];
        for (DSASlot *slot in inventory.slots) {
            if ([slot.object isEqual:object]) {
                [slot removeObjectWithQuantity: 1];
            }
        }
    }
}

- (NSInteger)countInventories {
    return [[self inventoryPropertyNames] count];
}

- (NSArray<NSString *> *)inventoryPropertyNames {
    return @[
        @"head",
        @"neck",
        @"eyes",
        @"leftEar",
        @"rightEar",
        @"nose",
        @"face",
        @"back",
        @"shoulder",
        @"leftArm",
        @"rightArm",
        @"leftHand",
        @"rightHand",
        @"leftHandFingers",
        @"rightHandFingers",
        @"hip",
        @"upperBody",
        @"lowerBody",
        @"leftLeg",
        @"rightLeg",
        @"leftFoot",
        @"rightFoot"
    ];
}

@end
