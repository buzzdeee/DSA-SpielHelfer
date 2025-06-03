/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-05-31 22:15:14 +0200 by sebastia

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

#ifndef _DSACHARACTERMULTISELECTIONWINDOWCONTROLLER_H_
#define _DSACHARACTERMULTISELECTIONWINDOWCONTROLLER_H_

#import <AppKit/AppKit.h>

@class DSACharacter;

@interface DSACharacterMultiSelectionWindowController : NSWindowController

@property (nonatomic, copy) void (^completionHandler)(NSArray *selectedCharacters);
@property (nonatomic, strong) NSArray<DSACharacter *> *characters;  // Set before showing

@property (weak) IBOutlet NSButton *switchCharacter0;
@property (weak) IBOutlet NSButton *switchCharacter1;
@property (weak) IBOutlet NSButton *switchCharacter2;
@property (weak) IBOutlet NSButton *switchCharacter3;
@property (weak) IBOutlet NSButton *switchCharacter4;
@property (weak) IBOutlet NSButton *switchCharacter5;
@property (weak) IBOutlet NSButton *switchCharacter6;
@property (weak) IBOutlet NSButton *switchCharacter7;
@property (weak) IBOutlet NSButton *switchCharacter8;
@property (weak) IBOutlet NSButton *buttonSelect;

@end

#endif // _DSACHARACTERMULTISELECTIONWINDOWCONTROLLER_H_

