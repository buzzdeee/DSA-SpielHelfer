/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-03-24 20:33:28 +0100 by sebastia

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

#ifndef _DSAADVENTUREGENERATIONCONTROLLER_H_
#define _DSAADVENTUREGENERATIONCONTROLLER_H_

#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DSAAdventureGenerationController : NSWindowController <NSComboBoxDelegate, NSComboBoxDataSource>

// Completion handler for passing back the selected location
@property (nonatomic, copy) void (^completionHandler)(NSString * _Nullable selectedLocation);

// UI elements
@property (strong) NSComboBox *locationField;
@property (strong) NSButton *okButton;
@property (strong) NSArray<NSString *> *locationsArray;
@property (strong) NSArray<NSString *> *filteredLocations;

// Method to start the adventure location selection UI
- (void)startAdventureGeneration:(id)sender;

@end
NS_ASSUME_NONNULL_END

#endif // _DSAADVENTUREGENERATIONCONTROLLER_H_

