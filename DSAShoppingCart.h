/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-06-10 20:13:51 +0200 by sebastia

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

#ifndef _DSASHOPPINGCART_H_
#define _DSASHOPPINGCART_H_

#import <Foundation/Foundation.h>
#import "DSAShopViewController.h"
@class DSAObject;

@interface DSAShoppingCart : NSObject

// Key: NSString (item name)
// Value: NSDictionary with keys:
//   - "items": NSArray<DSAObject *> *
//   - "price": NSNumber * (float value)
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, NSDictionary *> *cartContents;
@property (nonatomic, assign) DSAShopMode mode;

// Add copies of the object to the cart (count times), with given price
- (void)addObject:(DSAObject *)object count:(NSInteger)count price:(float)price slot:(NSString *)slotID;

- (void)removeObject:(DSAObject *)object count:(NSInteger)count slot:(NSString *) slotID;

// returns count of a specific object in the shopping cart
- (NSInteger)countForObject:(DSAObject *)object andSlotID: (NSString *) uuid;

// Calculate total price of all items in cart
- (float)totalSum;

- (NSInteger)countAllObjects;

// Clear the entire cart
- (void)clearCart;

@end
#endif // _DSASHOPPINGCART_H_

