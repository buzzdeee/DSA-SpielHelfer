/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-12-16 22:42:56 +0100 by sebastia

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

#import "DSAObjectShield.h"

@implementation DSAObjectShield
- (instancetype) initWithName: (NSString *) name
                     withIcon: (NSString *) icon
                   inCategory: (NSString *) category
                inSubCategory: (NSString *) subCategory
             inSubSubCategory: (NSString *) subSubCategory
                   withWeight: (float) weight
                    withPrice: (float) price
              withBreakFactor: (NSInteger) breakFactor
                  withPenalty: (float) penalty
        withShieldAttackPower: (NSInteger) shieldAttackPower
         withShieldParryValue: (NSInteger) shieldParryValue
      validInventorySlotTypes: (NSArray *) validSlotTypes  
            occupiedBodySlots: (NSArray *) occupiedBodySlots            
                    withSpell: (NSString *) spell
                withOwnerUUID: (NSString *) ownerUUID                
                  withRegions: (NSArray *) regions;
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
      self.breakFactor = breakFactor;
      self.penalty = penalty;
      self.shieldAttackPower = shieldAttackPower;
      self.shieldParryValue = shieldParryValue;
      self.validSlotTypes = validSlotTypes;
      self.occupiedBodySlots = occupiedBodySlots;   
      self.spell = spell;
      self.ownerUUID = ownerUUID;   
      self.regions = regions;
    }  
  return self;
}                  

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder: coder];
    if (self)
      {
        self.breakFactor = [coder decodeIntegerForKey:@"breakFactor"];
        self.shieldAttackPower = [coder decodeIntegerForKey:@"shieldAttackPower"];
        self.shieldParryValue = [coder decodeIntegerForKey:@"shieldParryValue"];
      }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  [super encodeWithCoder: coder];
  [coder encodeInteger:self.breakFactor forKey:@"breakFactor"];
  [coder encodeInteger:self.shieldAttackPower forKey:@"shieldAttackPower"];
  [coder encodeInteger:self.shieldParryValue forKey:@"shieldParryValue"];
}

@end
