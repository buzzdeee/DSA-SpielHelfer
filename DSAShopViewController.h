/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-06-09 22:03:15 +0200 by sebastia

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

#ifndef _DSASHOPVIEWCONTROLLER_H_
#define _DSASHOPVIEWCONTROLLER_H_

#import <AppKit/AppKit.h>

@class DSAObject;
@class DSAShopItemButton;
@class DSAShoppingCart;
@class DSASlot;

typedef NS_ENUM(NSUInteger, DSAShopMode) {
    DSAShopModeBuy,
    DSAShopModeSell
};

@interface DSAShopViewController : NSWindowController

@property (nonatomic, copy) void (^completionHandler)(DSAShoppingCart *shoppingCart);

@property (nonatomic, strong) DSAShoppingCart *shoppingCart;
@property (nonatomic, assign) float maxSilber;

@property (nonatomic, assign) DSAShopMode mode;
@property (nonatomic, strong) NSArray<DSAObject *> *allItems;        // used in DSAShopModeBuy
@property (nonatomic, strong) NSArray<DSASlot *> *allSlots;          // used in DSAShopModeSell
@property (nonatomic, weak) DSAShopItemButton *buttonItem0;
@property (nonatomic, weak) DSAShopItemButton *buttonItem1;
@property (nonatomic, weak) DSAShopItemButton *buttonItem2;
@property (nonatomic, weak) DSAShopItemButton *buttonItem3;
@property (nonatomic, weak) DSAShopItemButton *buttonItem4;
@property (nonatomic, weak) DSAShopItemButton *buttonItem5;
@property (nonatomic, weak) DSAShopItemButton *buttonItem6;
@property (nonatomic, weak) DSAShopItemButton *buttonItem7;
@property (nonatomic, weak) DSAShopItemButton *buttonItem8;
@property (nonatomic, weak) DSAShopItemButton *buttonItem9;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) NSInteger itemsPerPage;

@property (nonatomic, weak) IBOutlet NSButton *buttonPrevious;
@property (nonatomic, weak) IBOutlet NSButton *buttonNext;
@property (nonatomic, weak) IBOutlet NSTextField *fieldCount;
@property (nonatomic, weak) IBOutlet NSTextField *fieldSum;
@property (nonatomic, weak) IBOutlet NSButton *buttonConfirm;

@end

#endif // _DSASHOPVIEWCONTROLLER_H_

