/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-12-16 22:53:43 +0100 by sebastia

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

#import "DSAObjectShieldAndParry.h"

@implementation DSAObjectShieldAndParry
- (instancetype) initWithName: (NSString *) name
                     withIcon: (NSString *) icon
                   inCategory: (NSString *) category
                inSubCategory: (NSString *) subCategory
             inSubSubCategory: (NSString *) subSubCategory
                   withWeight: (NSInteger) weight
                    withPrice: (NSInteger) price
                   withLength: (NSInteger) length
                  withPenalty: (NSInteger) penalty
        withShieldAttackPower: (NSInteger) shieldAttackPower
         withShieldParryValue: (NSInteger) shieldParryValue
                withHitPoints: (NSArray *) hitPoints
              withHitPointsKK: (NSInteger) hitPointsKK
              withBreakFactor: (NSInteger) breakFactor              
              withAttackPower: (NSInteger) attackPower
               withParryValue: (NSInteger) parryValue
      validInventorySlotTypes: (NSArray *) validSlotTypes  
            occupiedBodySlots: (NSArray *) occupiedBodySlots                
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
      self.length = length;
      self.breakFactor = breakFactor;
      self.penalty = penalty;
      self.hitPoints = hitPoints;
      self.hitPointsKK = hitPointsKK;
      self.attackPower = attackPower;
      self.parryValue = parryValue;    
      self.shieldAttackPower = shieldAttackPower;
      self.shieldParryValue = shieldParryValue;
      self.validSlotTypes = validSlotTypes;
      self.occupiedBodySlots = occupiedBodySlots;      
      self.regions = regions;
    }  
  return self;
}                  

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder: coder];
    if (self)
      {
        self.length = [coder decodeIntegerForKey:@"length"];
        self.hitPoints = [coder decodeObjectForKey:@"hitPoints"];
        self.hitPointsKK = [coder decodeIntegerForKey:@"hitPointsKK"];
        self.penalty = [coder decodeIntegerForKey:@"penalty"];
        self.attackPower = [coder decodeIntegerForKey:@"attackPower"];
        self.parryValue = [coder decodeIntegerForKey:@"parryValue"];
      }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  [super encodeWithCoder: coder];
  [coder encodeInteger:self.length forKey:@"length"];
  [coder encodeObject:self.hitPoints forKey:@"hitPoints"];
  [coder encodeInteger:self.hitPointsKK forKey:@"hitPointsKK"];  
  [coder encodeInteger:self.attackPower forKey:@"attackPower"];
  [coder encodeInteger:self.parryValue forKey:@"parryValue"];
}                  
@end
