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

#import "DSAShoppingCart.h"
#import "DSAObject.h"
#import "DSASlot.h"

@implementation DSAShoppingCart

- (instancetype)init {
    self = [super init];
    if (self) {
        _cartContents = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)addObject:(DSAObject *)object count:(NSInteger)count price:(float)price slot: (NSString *) slotID {
    //NSLog(@"DSAShoppingCart addObject: %@", object);
    if (!object || count <= 0) return;

    NSString *key;
    //NSLog(@"DSAShoppingCart addObject slotID: %@ Shop Mode: %ld", slotID, self.mode);
    if (self.mode == DSAShopModeBuy)
      {
        key = object.name;
      }
    else
      {
        key = [NSString stringWithFormat: @"%@|%@", object.name, slotID];
      }
    if (!key) return;
    //NSLog(@"DSAShoppingCart addObject key: %@", key);
    NSDictionary *existingEntry = self.cartContents[key];
    //NSLog(@"DSAShoppingCart addObject existingEntry: %@", nil);
    if (existingEntry) {
        NSMutableArray *existingItems = existingEntry[@"items"];
        for (NSInteger i = 0; i < count; i++) {
            [existingItems addObject:[object copy]];
        }
    } else {
        NSMutableArray *items = [NSMutableArray array];
        for (NSInteger i = 0; i < count; i++) {
            //NSLog(@"DSAShoppingCart addObject: adding to items, the object via copy: %@", object);
            [items addObject:[object copy]];
        }
        NSLog(@"DSAShoppingCart addObject: the items: %@", items);
        NSMutableDictionary *entry = [@{
                                         @"items": items,
                                         @"price": @(price),
                                       } mutableCopy];
        NSLog(@"DSAShoppingCart addObject: the entry: %@", entry);
        self.cartContents[key] = entry;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DSAShoppingCartUpdated" object:self];
}

- (void)removeObject:(DSAObject *)object count:(NSInteger)count slot: (NSString *) slotID {
    if (!object || count <= 0) return;
    
    NSString *key;
    if (self.mode == DSAShopModeBuy)
      {
        key = object.name;
      }
    else
      {
        key = [NSString stringWithFormat: @"%@|%@", object.name, slotID];
      }
    //NSLog(@"DSAShoppingCart removeObject key: %@", key);
    //NSMutableDictionary *entry = self.cartContents[key];
    NSDictionary *entry = self.cartContents[key];
    if (!entry) return;

    NSMutableArray *items = entry[@"items"];
    if (items.count <= count) {
        [self.cartContents removeObjectForKey:key];
    } else {
        NSRange range = NSMakeRange(0, count);
        [items removeObjectsInRange:range];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DSAShoppingCartUpdated" object:self];
}


- (NSInteger)countForObject:(DSAObject *)object andSlotID: (NSString *) uuid {
    if (!object || !object.name) return 0;
    NSString *key;
    if (uuid)
      {
        key = [NSString stringWithFormat: @"%@|%@", object.name, uuid];
      }
    else
      {
        key = object.name;
      }
    NSDictionary *entry = self.cartContents[key];
    return [entry[@"items"] count];
}

- (NSInteger)countAllObjects {
    NSInteger count = 0;
    for (NSDictionary *entry in [self.cartContents allValues])
      {
        //NSLog(@"DSAShoppingCart countAllObjects: entry: %@", entry);
        count += [[entry objectForKey: @"items"] count];
      }
    return count;
}

- (float)totalSum {
    float total = 0;
    for (NSDictionary *entry in self.cartContents.allValues) {
        NSArray *items = entry[@"items"];
        float price = [entry[@"price"] floatValue];
        total += price * items.count;
    }
    return total;
}

- (void)clearCart {
    [self.cartContents removeAllObjects];
}

@end