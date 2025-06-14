/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-06-12 21:42:00 +0200 by sebastia

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

#ifndef _DSASHOPBARGAINCONTROLLER_H_
#define _DSASHOPBARGAINCONTROLLER_H_

#import <AppKit/AppKit.h>
#import "DSAShopViewController.h"

@class DSAAdventureGroup;
@class DSAShoppingCart;

@interface DSAShopBargainController : NSWindowController

@property (nonatomic, copy) void (^completionHandler)(BOOL result);
@property (nonatomic, assign) DSAShopMode mode;
@property (nonatomic, weak) DSAShoppingCart *shoppingCart;

@property (nonatomic, weak) IBOutlet NSPopUpButton *popupCharacter;
@property (nonatomic, weak) IBOutlet NSSlider *sliderPercent;
@property (nonatomic, weak) IBOutlet NSTextField *fieldPercentValue;
@property (nonatomic, weak) IBOutlet NSTextField *fieldBargainResult;
@property (nonatomic, weak) IBOutlet NSButton *buttonConfirm;

// max three rounds ...
@property (nonatomic, assign) NSInteger bargainRound;
@property (nonatomic, weak) DSAAdventureGroup *activeGroup;

@end

#endif // _DSASHOPBARGAINCONTROLLER_H_

