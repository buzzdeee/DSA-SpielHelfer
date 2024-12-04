/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-11-28 21:35:30 +0100 by sebastia

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

#ifndef _DSASLOT_H_
#define _DSASLOT_H_

#import <Foundation/Foundation.h>
#import "DSAObject.h"

typedef NS_ENUM(NSUInteger, DSASlotType) {
    DSASlotTypeGeneral,                         // can hold anything
    DSASlotTypeUnderwear,                       // will hold underwear
    DSASlotTypeBodyArmor,                       // holds armor on upper body
    DSASlotTypeHeadgear,                        // holds headgear, i.e. helmet, cap etc.
    DSASlotTypeShoes,                           // holds shoes
    DSASlotTypeNecklace,                        // holds necklaces, medaillons
    DSASlotTypeEarring,                         // holds earrings
    DSASlotTypeGlasses,                         // holds glasses
    DSASlotTypeMask,                            // holds mask
    DSASlotTypeBackpack,                        // holds backpacks on the back of character
    DSASlotTypeBackquiver,                      // holds quivers on the back of character
    DSASlotTypeSash,                            // holds Schärpe, or shoulder band
    DSASlotTypeArmArmor,                        // armor at the arms
    DSASlotTypeGloves,                          // holds gloves at hands
    DSASlotTypeHip,                             // to hold belts etc.
    DSASlotTypeRing,                            // to hold rings on fingers
    DSASlotTypeVest,                            // to hold vests on upper body
    DSASlotTypeShirt,                           // to hold shirts, blouse etc.
    DSASlotTypeJacket,                          // to hold jackets, robe, etc.
    DSASlotTypeLegbelt,                         // to hold belt on legs
    DSASlotTypeLegArmor,                        // to hold armor on legs
    DSASlotTypeTrousers,                        // to hold trousers
    DSASlotTypeSocks,                           // to hold socks
    DSASlotTypeShoeaccessories,                 // to hold spurs, skies, snowshoes
    DSASlotTypeBag,                             // an ordinary bag, anything that can goes into a bag
    DSASlotTypeBasket,                          // an ordinary basket, holds anything that can go into a basket
    DSASlotTypeQuiver,                          // a quiver for arrows
    DSASlotTypeBoltbag,                         // a quiver/bag for bolts
    DSASlotTypeBottle,                          // a bottle to hold liquids
    DSASlotTypeSword,                           // a shaft to hold swords
    DSASlotTypeDagger,                          // a shaft to hold daggers 
    DSASlotTypeAxe                              // a special thing to hold axes
    // Add other specific types as needed
};

@interface DSASlot : NSObject <NSCoding, NSCopying>

@property (nonatomic, assign) DSASlotType slotType; // Define what this slot can hold
@property (nonatomic, strong) DSAObject *object;    // a DSAobject in the slot
@property (nonatomic, assign) NSInteger quantity;   // how many objects share the slot
@property (nonatomic, assign) NSInteger maxItemsPerSlot;  // if a object is in a slot, that can share a single slot, limit to this maximum number

- (NSInteger)addObject:(DSAObject *)object quantity:(NSInteger)quantity;
- (NSInteger)removeObjectWithQuantity: (NSInteger)quantityToRemove;

@end

#endif // _DSASLOT_H_

