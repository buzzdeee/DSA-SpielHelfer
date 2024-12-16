/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-12-15 14:37:35 +0100 by sebastia

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

#ifndef _DSAITEMINSPECTIONCONTROLLER_H_
#define _DSAITEMINSPECTIONCONTROLLER_H_

#import <AppKit/AppKit.h>
#import "DSAObject.h"

@protocol DSAItemInspectionControllerDelegate;

@interface DSAItemInspectionController : NSWindowController

@property (nonatomic, weak) id<DSAItemInspectionControllerDelegate> delegate;

@property (nonatomic, strong) DSAObject *itemToInspect;

// Properties for UI elements
@property (weak) IBOutlet NSImageView *itemImageView;
@property (weak) IBOutlet NSTextField *itemName;
@property (weak) IBOutlet NSTextField *itemInfoTextView;
@property (weak) IBOutlet NSButton *buttonClose;


-(IBAction)closeWindow: (id)sender;

// Public method to load and display the item
- (void)inspectItem:(DSAObject *)item;

@end

@protocol DSAItemInspectionControllerDelegate <NSObject>
@optional
- (void)itemInspectionControllerDidClose:(DSAItemInspectionController *)controller;
@end

#endif // _DSAITEMINSPECTIONCONTROLLER_H_

