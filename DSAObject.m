/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-09-12 00:00:58 +0200 by sebastia

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

#import <objc/runtime.h>
#import "DSAObject.h"
#import "DSAObjectArmor.h"
#import "DSAObjectWeaponHandWeapon.h"
#import "DSAObjectWeaponHandAndLongRangeWeapon.h"
#import "DSAObjectWeaponLongRange.h"
#import "DSAObjectShield.h"
#import "DSAObjectShieldAndParry.h"
#import "DSAObjectContainer.h"
#import "DSAObjectCloth.h"

#import "Utils.h"
#import "DSASlot.h"

@implementation DSAObject

- (instancetype) initWithName: (NSString *) name
{
  self = [super init];
  NSDictionary *objectInfo = [Utils getDSAObjectInfoByName: name];
  NSLog(@"THE OBJECT INFO: %@", objectInfo);
  if ([[objectInfo objectForKey: @"isHandWeapon"] isEqualTo: @YES] && 
      ! [[objectInfo objectForKey: @"isDistantWeapon"] isEqualTo: @YES] && 
      ! [[objectInfo objectForKey: @"isArmor"] isEqualTo: @YES] &&
      ! [[objectInfo objectForKey: @"isShield"] isEqualTo: @YES])
    {
      NSLog(@"a normal hand weapon");
      self = [[DSAObjectWeaponHandWeapon alloc] initWithName: name
                                         withIcon: [objectInfo objectForKey: @"Icon"] ? [[objectInfo valueForKey: @"Icon"] objectAtIndex: 0]: nil
                                       inCategory: [objectInfo objectForKey: @"category"]
                                    inSubCategory: [objectInfo objectForKey: @"category1"]
                                 inSubSubCategory: [objectInfo objectForKey: @"category2"]
                                       withWeight: [[objectInfo objectForKey: @"Gewicht"] integerValue]
                                        withPrice: [[objectInfo objectForKey: @"Preis"] floatValue]
                                       withLength: [[objectInfo objectForKey: @"Länge"] floatValue]
                                    withHitPoints: [objectInfo objectForKey: @"Trefferpunkte"]  // Array of NSNumbers 
                                  withHitPointsKK: [[objectInfo objectForKey: @"TrefferpunkteKK"] integerValue]
                                  withBreakFactor: [[objectInfo objectForKey: @"Bruchfaktor"] integerValue]
                                  withAttackPower: [[objectInfo objectForKey: @"attackPower"] integerValue]
                                   withParryValue: [[objectInfo objectForKey: @"parryValue"] integerValue]
                          validInventorySlotTypes: [objectInfo objectForKey: @"validSlotTypes"]
                                occupiedBodySlots: [objectInfo objectForKey: @"occupiedBodySlots"]
                                      withRegions: [objectInfo objectForKey: @"Regionen"]];      
    }
  else if (! [[objectInfo objectForKey: @"isHandWeapon"] isEqualTo: @YES] && 
           [[objectInfo objectForKey: @"isDistantWeapon"] isEqualTo: @YES] && 
           ! [[objectInfo objectForKey: @"isArmor"] isEqualTo: @YES] &&
           ! [[objectInfo objectForKey: @"isShield"] isEqualTo: @YES])
    {
      NSLog(@"a normal distant weapon");
      self = [[DSAObjectWeaponLongRange alloc] initWithName: name
                                         withIcon: [objectInfo objectForKey: @"Icon"] ? [[objectInfo valueForKey: @"Icon"] objectAtIndex: 0]: nil
                                       inCategory: [objectInfo objectForKey: @"category"]
                                    inSubCategory: [objectInfo objectForKey: @"category1"]
                                 inSubSubCategory: [objectInfo objectForKey: @"category2"]
                                       withWeight: [[objectInfo objectForKey: @"Gewicht"] integerValue]
                                        withPrice: [[objectInfo objectForKey: @"Preis"] floatValue]
                                  withMaxDistance: [[objectInfo objectForKey: @"Reichweite"] integerValue]
                              withDistancePenalty: [objectInfo objectForKey: @"TP Entfernung"]                                        
                           withHitPointsLongRange: [objectInfo objectForKey: @"Trefferpunkte Fernwaffe"]  // Array of NSNumbers 
                          validInventorySlotTypes: [objectInfo objectForKey: @"validSlotTypes"]
                                occupiedBodySlots: [objectInfo objectForKey: @"occupiedBodySlots"]
                                      withRegions: [objectInfo objectForKey: @"Regionen"]];      
    }
  else if ([[objectInfo objectForKey: @"isHandWeapon"] isEqualTo: @YES] && 
           [[objectInfo objectForKey: @"isDistantWeapon"] isEqualTo: @YES] && 
           ! [[objectInfo objectForKey: @"isArmor"] isEqualTo: @YES] &&
           ! [[objectInfo objectForKey: @"isShield"] isEqualTo: @YES])
    {
      NSLog(@"a hand weapon but also a distant weapon");
      self = [[DSAObjectWeaponHandAndLongRangeWeapon alloc] initWithName: name
                                         withIcon: [objectInfo objectForKey: @"Icon"] ? [[objectInfo valueForKey: @"Icon"] objectAtIndex: 0]: nil
                                       inCategory: [objectInfo objectForKey: @"category"]
                                    inSubCategory: [objectInfo objectForKey: @"category1"]
                                 inSubSubCategory: [objectInfo objectForKey: @"category2"]
                                       withWeight: [[objectInfo objectForKey: @"Gewicht"] integerValue]
                                        withPrice: [[objectInfo objectForKey: @"Preis"] floatValue]
                                       withLength: [[objectInfo objectForKey: @"Länge"] floatValue]
                                    withHitPoints: [objectInfo objectForKey: @"Trefferpunkte"]  // Array of NSNumbers 
                                  withHitPointsKK: [[objectInfo objectForKey: @"TrefferpunkteKK"] integerValue]
                                  withBreakFactor: [[objectInfo objectForKey: @"Bruchfaktor"] integerValue]
                                  withAttackPower: [[objectInfo objectForKey: @"attackPower"] integerValue]
                                   withParryValue: [[objectInfo objectForKey: @"parryValue"] integerValue]
                                  withMaxDistance: [[objectInfo objectForKey: @"Reichweite"] integerValue]
                              withDistancePenalty: [objectInfo objectForKey: @"TP Entfernung"]                                        
                           withHitPointsLongRange: [objectInfo objectForKey: @"Trefferpunkte Fernwaffe"]  // Array of NSNumbers                                   
                          validInventorySlotTypes: [objectInfo objectForKey: @"validSlotTypes"]
                                occupiedBodySlots: [objectInfo objectForKey: @"occupiedBodySlots"]
                                      withRegions: [objectInfo objectForKey: @"Regionen"]];           
    }
  else if ([[objectInfo objectForKey: @"isShield"] isEqualTo: @YES] && 
           [[objectInfo objectForKey: @"isHandWeapon"] isEqualTo: @YES] )
    {
      NSLog(@"a shield and a parry weapon");
      self = [[DSAObjectShieldAndParry alloc] initWithName: name
                                         withIcon: [objectInfo objectForKey: @"Icon"] ? [[objectInfo valueForKey: @"Icon"] objectAtIndex: 0]: nil
                                       inCategory: [objectInfo objectForKey: @"category"]
                                    inSubCategory: [objectInfo objectForKey: @"category1"]
                                 inSubSubCategory: [objectInfo objectForKey: @"category2"]
                                       withWeight: [[objectInfo objectForKey: @"Gewicht"] integerValue]
                                        withPrice: [[objectInfo objectForKey: @"Preis"] floatValue]
                                       withLength: [[objectInfo objectForKey: @"Länge"] floatValue]
                                      withPenalty: [[objectInfo objectForKey: @"Behinderung"] integerValue]
                            withShieldAttackPower: [[objectInfo objectForKey: @"shieldAttackPower"] integerValue]
                             withShieldParryValue: [[objectInfo objectForKey: @"shieldParryValue"] integerValue]
                                    withHitPoints: [objectInfo objectForKey: @"Trefferpunkte"]  // Array of NSNumbers 
                                  withHitPointsKK: [[objectInfo objectForKey: @"TrefferpunkteKK"] integerValue]
                                  withBreakFactor: [[objectInfo objectForKey: @"Bruchfaktor"] integerValue]
                                  withAttackPower: [[objectInfo objectForKey: @"attackPower"] integerValue]
                                   withParryValue: [[objectInfo objectForKey: @"parryValue"] integerValue]                                                        
                          validInventorySlotTypes: [objectInfo objectForKey: @"validSlotTypes"]
                                occupiedBodySlots: [objectInfo objectForKey: @"occupiedBodySlots"]
                                      withRegions: [objectInfo objectForKey: @"Regionen"]];                
    }
  else if ([[objectInfo objectForKey: @"isShield"] isEqualTo: @YES] && 
           ! [[objectInfo objectForKey: @"isHandWeapon"] isEqualTo: @YES] )
    {
      NSLog(@"a shield and a parry weapon");
      self = [[DSAObjectShield alloc] initWithName: name
                                         withIcon: [objectInfo objectForKey: @"Icon"] ? [[objectInfo valueForKey: @"Icon"] objectAtIndex: 0]: nil
                                       inCategory: [objectInfo objectForKey: @"category"]
                                    inSubCategory: [objectInfo objectForKey: @"category1"]
                                 inSubSubCategory: [objectInfo objectForKey: @"category2"]
                                       withWeight: [[objectInfo objectForKey: @"Gewicht"] integerValue]
                                        withPrice: [[objectInfo objectForKey: @"Preis"] floatValue]
                                  withBreakFactor: [[objectInfo objectForKey: @"Bruchfaktor"] integerValue]                                        
                                      withPenalty: [[objectInfo objectForKey: @"Behinderung"] integerValue]
                            withShieldAttackPower: [[objectInfo objectForKey: @"shieldAttackPower"] integerValue]
                             withShieldParryValue: [[objectInfo objectForKey: @"shieldParryValue"] integerValue]
                          validInventorySlotTypes: [objectInfo objectForKey: @"validSlotTypes"]
                                occupiedBodySlots: [objectInfo objectForKey: @"occupiedBodySlots"]
                                      withRegions: [objectInfo objectForKey: @"Regionen"]];                                                   
    }             
  else if ([[objectInfo objectForKey: @"isArmor"] isEqualTo: @YES])
    {
    NSLog(@"HERE IN isArmor");
      self = [[DSAObjectArmor alloc] initWithName: name
                                         withIcon: [objectInfo objectForKey: @"Icon"] ? [[objectInfo valueForKey: @"Icon"] objectAtIndex: 0]: nil
                                       inCategory: [objectInfo objectForKey: @"category"]
                                    inSubCategory: [objectInfo objectForKey: @"category1"]
                                 inSubSubCategory: [objectInfo objectForKey: @"category2"]
                                       withWeight: [[objectInfo objectForKey: @"Gewicht"] integerValue]
                                        withPrice: [[objectInfo objectForKey: @"Preis"] floatValue]
                                   withProtection: [[objectInfo objectForKey: @"Rüstschutz"] integerValue]
                                      withPenalty: [[objectInfo objectForKey: @"Behinderung"] integerValue]
                          validInventorySlotTypes: [objectInfo objectForKey: @"validSlotTypes"]
                                occupiedBodySlots: [objectInfo objectForKey: @"occupiedBodySlots"]
                                      withRegions: [objectInfo objectForKey: @"Regionen"]];
    }
    
  else if ([[objectInfo objectForKey: @"isContainer"] isEqualTo: @YES])
    {
      self = [[DSAObjectContainer alloc] initWithName: name
                                             withIcon: [objectInfo objectForKey: @"Icon"] ? [[objectInfo valueForKey: @"Icon"] objectAtIndex: 0]: nil
                                           inCategory: [objectInfo objectForKey: @"category"]
                                        inSubCategory: [objectInfo objectForKey: @"category1"]
                                     inSubSubCategory: [objectInfo objectForKey: @"category2"]
                                           withWeight: [[objectInfo objectForKey: @"Gewicht"] integerValue]
                                            withPrice: [[objectInfo objectForKey: @"Preis"] floatValue]
                                           ofSlotType: [objectInfo objectForKey: @"Slottypen" ] ? [Utils slotTypeFromString: [[objectInfo objectForKey: @"Slottypen" ] objectAtIndex: 0]] : DSASlotTypeGeneral
                                        withNrOfSlots: [objectInfo objectForKey: @"Slots" ] ? [[objectInfo objectForKey: @"Slots" ] integerValue] : 1
                                      maxItemsPerSlot: [objectInfo objectForKey: @"MaximumPerSlot" ] ? [[objectInfo objectForKey: @"MaximumPerSlot" ] integerValue] : 1
                              validInventorySlotTypes: [objectInfo objectForKey: @"validSlotTypes"]
                                    occupiedBodySlots: [objectInfo objectForKey: @"occupiedBodySlots"]
                                          withRegions: [objectInfo objectForKey: @"Regionen"]];                                          
                                            
    }
  else
    {
      NSLog(@"Unsure how to handle object creation for: %@, just going with DSAObject", name);
      self = [[DSAObject alloc] initWithName: name
                                    withIcon: [objectInfo objectForKey: @"Icon"] ? [[objectInfo valueForKey: @"Icon"] objectAtIndex: 0]: nil
                                  inCategory: [objectInfo objectForKey: @"category"]
                               inSubCategory: [objectInfo objectForKey: @"category1"]
                            inSubSubCategory: [objectInfo objectForKey: @"category2"]
                                  withWeight: [[objectInfo objectForKey: @"Gewicht"] integerValue]
                                   withPrice: [[objectInfo objectForKey: @"Preis"] floatValue]
                     validInventorySlotTypes: [objectInfo objectForKey: @"validSlotTypes"]
                           occupiedBodySlots: [objectInfo objectForKey: @"occupiedBodySlots"]                     
                                canShareSlot: [[objectInfo objectForKey: @"canShareSlot"] boolValue]
                                 withRegions: [objectInfo objectForKey: @"Regionen"]];     
    }
  
  return self;
}

- (instancetype) initWithName: (NSString *) name
                     withIcon: (NSString *) icon
                   inCategory: (NSString *) category
                inSubCategory: (NSString *) subCategory
             inSubSubCategory: (NSString *) subSubCategory
                   withWeight: (NSInteger) weight
                    withPrice: (float) price
      validInventorySlotTypes: (NSArray *) validSlotTypes
            occupiedBodySlots: (NSArray *) occupiedBodySlots
                 canShareSlot: (BOOL) canShareSlot
                  withRegions: (NSArray *) regions
{
  self = [super init];
  if (self)
    {
      self.name = name;
      self.icon = icon;
      self.category = category;
      self.subCategory = subCategory;
      self.subSubCategory = subSubCategory;
      self.weight = weight;
      self.price = price;
      self.isMagic = NO;
      self.isPoisoned = NO;
      self.isConsumable = NO;
      self.canShareSlot = canShareSlot;
      self.validSlotTypes = validSlotTypes;
      self.occupiedBodySlots = occupiedBodySlots;
      self.regions = regions;
    }  
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
  self = [super init];
  if (self)
    {
      self.name = [coder decodeObjectForKey:@"name"];
      self.icon = [coder decodeObjectForKey:@"icon"];
      self.category = [coder decodeObjectForKey:@"category"];
      self.subCategory = [coder decodeObjectForKey:@"subCategory"];
      self.subSubCategory = [coder decodeObjectForKey:@"subSubCategory"];
      self.weight = [coder decodeIntegerForKey:@"weight"];
      self.price = [[coder decodeObjectForKey:@"price"] floatValue];
      self.regions = [coder decodeObjectForKey:@"regions"];
      self.isMagic = [coder decodeBoolForKey:@"isMagic"];
      self.isPoisoned = [coder decodeBoolForKey:@"isPoisoned"];
      self.isConsumable = [coder decodeBoolForKey:@"isConsumable"];
      self.canShareSlot = [coder decodeBoolForKey:@"canShareSlot"];
      self.validSlotTypes = [coder decodeObjectForKey:@"validSlotTypes"];
      self.occupiedBodySlots = [coder decodeObjectForKey:@"occupiedBodySlots"];
    }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  [coder encodeObject:self.name forKey:@"name"];
  [coder encodeObject:self.icon forKey:@"icon"];
  [coder encodeObject:self.category forKey:@"category"];
  [coder encodeObject:self.subCategory forKey:@"subCategory"];
  [coder encodeObject:self.subSubCategory forKey:@"subSubCategory"];
  [coder encodeInteger:self.weight forKey:@"weight"];
  [coder encodeObject:@(self.price) forKey:@"price"];
  [coder encodeObject:self.regions forKey:@"regions"];
  [coder encodeBool:self.isMagic forKey:@"isMagic"];
  [coder encodeBool:self.isPoisoned forKey:@"isPoisoned"];
  [coder encodeBool:self.isConsumable forKey:@"isConsumable"];
  [coder encodeBool:self.canShareSlot forKey:@"canShareSlot"];
  [coder encodeObject:self.validSlotTypes forKey:@"validSlotTypes"];
  [coder encodeObject:self.occupiedBodySlots forKey:@"occupiedBodySlots"];
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
  DSAObject *copy = [[[self class] allocWithZone:zone] init];

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


// used to determine, if the object can share an inventory slot
- (BOOL)isCompatibleWithObject:(DSAObject *)otherObject
{
  if (![self.name isEqualToString:otherObject.name])
    {
      return NO; // Different types of objects
    }
  if (!self.canShareSlot || !otherObject.canShareSlot)
    {
      return NO; // Slot-sharing not allowed
    }
  if (self.isMagic != otherObject.isMagic || self.isPoisoned != otherObject.isPoisoned)
    {
      return NO; // Mismatched properties
    }
  return YES;
}

@end
