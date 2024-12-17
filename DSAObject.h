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

#ifndef _DSAOBJECT_H_
#define _DSAOBJECT_H_

#import <Foundation/Foundation.h>


@interface DSAObject : NSObject <NSCoding, NSCopying>
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *icon;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *subCategory;
@property (nonatomic, strong) NSString *subSubCategory;
@property (nonatomic, assign) NSInteger weight;
@property (nonatomic, assign) float price;
@property (nonatomic, strong) NSArray *regions;

@property (nonatomic) BOOL isMagic;
@property (nonatomic) BOOL isPoisoned;
@property (nonatomic) BOOL isConsumable;
@property (nonatomic) BOOL canShareSlot;
@property (nonatomic, strong) NSArray<NSNumber *> *occupiedBodySlots; // Body parts this item occupies
@property (nonatomic, strong) NSArray<NSNumber *> *validSlotTypes; // List of DSASlotTypes this object can be placed in


- (instancetype) initWithName: (NSString *) name;
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
                  withRegions: (NSArray *) regions;
                  
- (BOOL)isCompatibleWithObject:(DSAObject *)otherObject;                    
                    

@end

#endif // _DSAOBJECT_H_

