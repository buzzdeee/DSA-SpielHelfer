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
#import "DSAObject.h"

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
       self.nose = [[DSAInventory alloc] initWithSlotType: DSASlotTypeNosering quantity: 1 maxItemsPerSlot: 1];
       self.face = [[DSAInventory alloc] initWithSlotType: DSASlotTypeMask quantity: 1 maxItemsPerSlot: 1];    
       self.back = [[DSAInventory alloc] initWithSlotTypes: @[@(DSASlotTypeBackquiver), @(DSASlotTypeBackpack)] maxItemsPerSlot: 1];
       self.shoulder = [[DSAInventory alloc] initWithSlotType: DSASlotTypeSash quantity: 2 maxItemsPerSlot: 1];                
       self.leftArm = [[DSAInventory alloc] initWithSlotTypes: @[@(DSASlotTypeArmArmor), @(DSASlotTypeArmRing)] maxItemsPerSlot: 1];
       self.rightArm = [[DSAInventory alloc] initWithSlotTypes: @[@(DSASlotTypeArmArmor), @(DSASlotTypeArmRing)] maxItemsPerSlot: 1];
       self.leftHand = [[DSAInventory alloc] initWithSlotTypes: @[@(DSASlotTypeGeneral), @(DSASlotTypeGloves), @(DSASlotTypeRing)] maxItemsPerSlot: 1];
       self.rightHand = [[DSAInventory alloc] initWithSlotTypes: @[@(DSASlotTypeGeneral), @(DSASlotTypeGloves), @(DSASlotTypeRing)] maxItemsPerSlot: 1];
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
  [coder encodeObject:self.hip forKey:@"hip"];
  [coder encodeObject:self.upperBody forKey:@"upperBody"];
  [coder encodeObject:self.lowerBody forKey:@"lowerBody"];
  [coder encodeObject:self.leftLeg forKey:@"leftLeg"];
  [coder encodeObject:self.rightLeg forKey:@"rightLeg"];
  [coder encodeObject:self.leftFoot forKey:@"leftFoot"];
  [coder encodeObject:self.rightFoot forKey:@"rightFoot"];  
}

- (DSAEquipResult *)equipObject:(DSAObject *)object {
    DSAEquipResult *result = [[DSAEquipResult alloc] init];
    result.error = DSAEquipErrorNone;
    
    if (!object.occupiedBodySlots || object.occupiedBodySlots.count == 0) {
        result.error = DSAEquipErrorNoFreeSlot;
        result.errorMessage = @"The object does not specify any body parts to occupy.";
        return result;
    }

    for (NSString *bodyPart in object.occupiedBodySlots) {
        DSAInventory *inventory = [self inventoryForBodyPart:bodyPart];
        DSASlot *freeSlot = [self findFreeSlotInInventory:inventory forObject:object];
        if (!freeSlot) {
            result.error = DSAEquipErrorNoFreeSlot;
            result.errorMessage = [NSString stringWithFormat:@"No free slot available in %@", bodyPart];
            return result;
        }
    }

    // If no errors, proceed to equip
    for (NSString *bodyPart in object.occupiedBodySlots) {
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

- (void)unequipObject:(DSAObject *)object {
    for (NSString *bodyPart in object.occupiedBodySlots) {
        DSAInventory *inventory = [self inventoryForBodyPart:bodyPart];
        for (DSASlot *slot in inventory.slots) {
            if ([slot.object isEqual:object]) {
                [slot removeObjectWithQuantity: 1];
            }
        }
    }
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
    if ([bodyPart isEqualToString:@"rightArm"]) return self.rightArm;
    if ([bodyPart isEqualToString:@"leftHand"]) return self.leftHand;
    if ([bodyPart isEqualToString:@"rightHand"]) return self.rightHand;
    if ([bodyPart isEqualToString:@"hip"]) return self.hip;
    if ([bodyPart isEqualToString:@"upperBody"]) return self.upperBody;
    if ([bodyPart isEqualToString:@"lowerBody"]) return self.lowerBody;
    if ([bodyPart isEqualToString:@"leftLeg"]) return self.leftLeg;
    if ([bodyPart isEqualToString:@"rightLeg"]) return self.rightLeg;
    if ([bodyPart isEqualToString:@"leftFoot"]) return self.leftFoot;
    if ([bodyPart isEqualToString:@"rightFoot"]) return self.rightFoot;    
    return nil; // Invalid body part
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
        @"leftHand",
        @"rightHand",
        @"leftArm",
        @"rightArm",        
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
