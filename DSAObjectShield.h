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

#ifndef _DSAOBJECTSHIELD_H_
#define _DSAOBJECTSHIELD_H_

#import "DSAObject.h"

@interface DSAObjectShield : DSAObject
@property (nonatomic, assign) NSInteger breakFactor;
@property (nonatomic, assign) NSInteger penalty;
@property (nonatomic, assign) NSInteger shieldAttackPower;
@property (nonatomic, assign) NSInteger shieldParryValue;

- (instancetype) initWithName: (NSString *) name
                     withIcon: (NSString *) icon
                   inCategory: (NSString *) category
                inSubCategory: (NSString *) subCategory
             inSubSubCategory: (NSString *) subSubCategory
                   withWeight: (NSInteger) weight
                    withPrice: (NSInteger) price
              withBreakFactor: (NSInteger) breakFactor
                  withPenalty: (NSInteger) penalty
        withShieldAttackPower: (NSInteger) shieldAttackPower
         withShieldParryValue: (NSInteger) shieldParryValue
      validInventorySlotTypes: (NSArray *) validSlotTypes  
            occupiedBodySlots: (NSArray *) occupiedBodySlots                
                  withRegions: (NSArray *) regions;

@end

#endif // _DSAOBJECTSHIELD_H_
