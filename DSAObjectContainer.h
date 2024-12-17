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

#ifndef _DSAOBJECTCONTAINER_H_
#define _DSAOBJECTCONTAINER_H_

#import "DSAObject.h"
#import "DSASlot.h"

@interface DSAObjectContainer : DSAObject
@property (nonatomic, strong) NSMutableArray<DSASlot *> *slots;  // The slots the container holds

- (instancetype) initWithName: (NSString *) name
                     withIcon: (NSString *) icon
                   inCategory: (NSString *) category
                inSubCategory: (NSString *) subCategory
             inSubSubCategory: (NSString *) subSubCategory
                   withWeight: (NSInteger) weight
                    withPrice: (float) price
                   ofSlotType: (NSInteger) slotType
                withNrOfSlots: (NSInteger) nrOfSlots
              maxItemsPerSlot: (NSInteger) maxItemsPerSlot
      validInventorySlotTypes: (NSArray *) validSlotTypes
            occupiedBodySlots: (NSArray *) occupiedBodySlots
                  withRegions: (NSArray *) regions;

@end

#endif // _DSAOBJECTCONTAINER_H_

