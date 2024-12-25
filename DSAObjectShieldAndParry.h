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

#ifndef _DSAOBJECTSHIELDANDPARRY_H_
#define _DSAOBJECTSHIELDANDPARRY_H_

#import "DSAObjectShield.h"

@interface DSAObjectShieldAndParry : DSAObjectShield
@property (nonatomic, assign) float length;
@property (nonatomic, strong) NSArray *hitPoints;
@property (nonatomic, assign) NSInteger hitPointsKK;
@property (nonatomic, assign) NSInteger attackPower;
@property (nonatomic, assign) NSInteger parryValue;

- (instancetype) initWithName: (NSString *) name
                     withIcon: (NSString *) icon
                   inCategory: (NSString *) category
                inSubCategory: (NSString *) subCategory
             inSubSubCategory: (NSString *) subSubCategory
                   withWeight: (float) weight
                    withPrice: (float) price
                   withLength: (float) length
                  withPenalty: (float) penalty
        withShieldAttackPower: (NSInteger) shieldAttackPower
         withShieldParryValue: (NSInteger) shieldParryValue
                withHitPoints: (NSArray *) hitPoints
              withHitPointsKK: (NSInteger) hitPointsKK
              withBreakFactor: (NSInteger) breakFactor              
              withAttackPower: (NSInteger) attackPower
               withParryValue: (NSInteger) parryValue
      validInventorySlotTypes: (NSArray *) validSlotTypes  
            occupiedBodySlots: (NSArray *) occupiedBodySlots    
                    withSpell: (NSString *) spell
                withOwnerUUID: (NSString *) ownerUUID                        
                  withRegions: (NSArray *) regions;

@end

#endif // _DSAOBJECTSHIELDANDPARRY_H_

