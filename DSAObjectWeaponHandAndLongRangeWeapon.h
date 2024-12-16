/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-12-16 22:13:15 +0100 by sebastia

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

#ifndef _DSAOBJECTWEAPONHANDANDLONGRANGEWEAPON_H_
#define _DSAOBJECTWEAPONHANDANDLONGRANGEWEAPON_H_

#import "DSAObjectWeaponHandWeapon.h"

@interface DSAObjectWeaponHandAndLongRangeWeapon : DSAObjectWeaponHandWeapon
@property (nonatomic, assign) NSInteger maxDistance;
@property (nonatomic, strong) NSDictionary *distancePenalty;
@property (nonatomic, strong) NSArray *hitPointsLongRange;

- (instancetype) initWithName: (NSString *) name
                     withIcon: (NSString *) icon
                   inCategory: (NSString *) category
                inSubCategory: (NSString *) subCategory
             inSubSubCategory: (NSString *) subSubCategory
                   withWeight: (NSInteger) weight
                    withPrice: (NSInteger) price
                   withLength: (NSInteger) length
                withHitPoints: (NSArray *) hitPoints
              withHitPointsKK: (NSInteger) hitPointsKK
              withBreakFactor: (NSInteger) breakFactor              
              withAttackPower: (NSInteger) attackPower
               withParryValue: (NSInteger) parryValue
              withMaxDistance: (NSInteger) maxDistance
          withDistancePenalty: (NSDictionary *) distancePenalty
       withHitPointsLongRange: (NSArray *) hitPointsLongRange               
      validInventorySlotTypes: (NSArray *) validSlotTypes  
            occupiedBodySlots: (NSArray *) occupiedBodySlots                
                  withRegions: (NSArray *) regions;


@end

#endif // _DSAOBJECTWEAPONHANDANDLONGRANGEWEAPON_H_

