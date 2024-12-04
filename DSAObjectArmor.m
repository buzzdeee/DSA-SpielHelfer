/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-11-23 20:25:03 +0100 by sebastia

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

#import "DSAObjectArmor.h"

@implementation DSAObjectArmor

- (instancetype) initWithName: (NSString *) name
                     withIcon: (NSString *) icon
                   inCategory: (NSString *) category
                inSubCategory: (NSString *) subCategory
             inSubSubCategory: (NSString *) subSubCategory
                   withWeight: (NSNumber *) weight
                    withPrice: (NSNumber *) price
               withProtection: (NSNumber *) protection
                  withPenalty: (NSNumber *) penalty
      validInventorySlotTypes: (NSArray *) validSlotTypes
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
      self.protection = protection;
      self.penalty = penalty;
      self.validSlotTypes = validSlotTypes;
      self.regions = regions;
    }  
  return self;
}                  

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder: coder];
    if (self)
      {
        self.protection = [coder decodeObjectForKey:@"protection"];
        self.penalty = [coder decodeObjectForKey:@"penalty"];
      }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  [super encodeWithCoder: coder];
  [coder encodeObject:self.protection forKey:@"protection"];
  [coder encodeObject:self.penalty forKey:@"penalty"];
}
@end
