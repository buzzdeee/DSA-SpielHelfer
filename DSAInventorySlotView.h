/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-12-04 21:57:37 +0100 by sebastia

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

#ifndef _DSAINVENTORYSLOTVIEW_H_
#define _DSAINVENTORYSLOTVIEW_H_

#import <AppKit/AppKit.h>
#import "DSAObject.h"
#import "DSACharacter.h"

@interface DSAInventorySlotView : NSImageView 
@property (nonatomic, strong) DSAObject *item;
@property (nonatomic, assign) NSInteger slotIndex;
@property (nonatomic, strong) NSString *inventoryIdentifier;
@property (nonatomic, strong) NSString *inventoryType;
@property (nonatomic, strong) DSACharacter *model;  // Add a reference to the model
@property (nonatomic, strong) DSASlot *slot;                     // Link to the corresponding slot

@property (nonatomic, strong) DSAInventorySlotView *sourceImageView;   // The source image view for the drag
@property (nonatomic, strong) DSAInventorySlotView *targetImageView;   // The target image view for the drop
@property (nonatomic, strong) NSBox *highlightView; // Add this property to track the highlight

- (void)highlightTargetView:(BOOL)highlight;
- (void)updateQuantityLabelWithQuantity:(NSInteger)quantity;
- (void)updateToolTip;
              
@end

#endif // _DSAINVENTORYSLOTVIEW_H_

