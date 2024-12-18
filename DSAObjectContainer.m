/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-11-23 19:22:52 +0100 by sebastia

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

#import "DSAObjectContainer.h"

@implementation DSAObjectContainer

- (instancetype) initWithName: (NSString *) name
                     withIcon: (NSString *) icon
                   inCategory: (NSString *) category
                inSubCategory: (NSString *) subCategory
             inSubSubCategory: (NSString *) subSubCategory
                   withWeight: (float) weight
                    withPrice: (float) price
                   ofSlotType: (NSInteger) slotType
                withNrOfSlots: (NSInteger) nrOfSlots
              maxItemsPerSlot: (NSInteger) maxItemsPerSlot
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
      self.regions = regions;
      self.validSlotTypes = validSlotTypes;
      self.occupiedBodySlots = occupiedBodySlots;
      self.slots = [NSMutableArray arrayWithCapacity:nrOfSlots];
      for (NSInteger i = 0; i < nrOfSlots; i++)
        {
          DSASlot *slot = [[DSASlot alloc] init];
          slot.slotType = slotType;  // Set the same slot type for all slots
          slot.maxItemsPerSlot = maxItemsPerSlot;
          [self.slots addObject:slot];
        }
    }  
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder: coder];
    if (self)
      {
        self.slots = [coder decodeObjectForKey:@"slots"];
      }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  [super encodeWithCoder: coder];
  [coder encodeObject:self.slots forKey:@"slots"];
}


@end
