/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-06-09 22:49:05 +0200 by sebastia

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

#ifndef _DSASHOPITEMBUTTON_H_
#define _DSASHOPITEMBUTTON_H_

#import <AppKit/AppKit.h>

@class DSAObject;
@class DSAShoppingCart;

@interface DSAShopItemButton : NSButton
@property (nonatomic, strong) DSAObject *object;
@property (nonatomic, weak) DSAShoppingCart *shoppingCart;

@property (nonatomic, assign) BOOL isHovered;

- (void)updateDisplay;

@end

#endif // _DSASHOPITEMBUTTON_H_

