/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-12-15 20:26:45 +0100 by sebastia

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

#ifndef _DSAWEAPONLONGRANGE_H_
#define _DSAWEAPONLONGRANGE_H_

#import "DSAObjectWeapon.h"

@interface DSAObjectWeaponLongRange : DSAObjectWeapon
@property (nonatomic, assign) NSInteger maxDistance;
@property (nonatomic, strong) NSDictionary *distancePenalty;
@property (nonatomic, strong) NSArray *hitPointsLongRange;


- (instancetype) initWithName: (NSString *) name
                     withIcon: (NSString *) icon
                   inCategory: (NSString *) category
                inSubCategory: (NSString *) subCategory
             inSubSubCategory: (NSString *) subSubCategory
                   withWeight: (NSInteger) weight
                    withPrice: (float) price
              withMaxDistance: (NSInteger) maxDistance
          withDistancePenalty: (NSDictionary *) distancePenalty
       withHitPointsLongRange: (NSArray *) hitPointsLongRange
      validInventorySlotTypes: (NSArray *) validSlotTypes  
            occupiedBodySlots: (NSArray *) occupiedBodySlots                
                  withRegions: (NSArray *) regions;
@end

#endif // _DSAWEAPONLONGRANGE_H_

