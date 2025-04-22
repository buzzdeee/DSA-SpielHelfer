/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-04-13 21:06:14 +0200 by sebastia

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

#ifndef _DSANPCGENERATIONCONTROLLER_H_
#define _DSANPCGENERATIONCONTROLLER_H_

#import <AppKit/AppKit.h>
@class DSACharacter;

@interface DSANPCGenerationController : NSWindowController

@property (weak) IBOutlet NSPopUpButton *popupCategories;
@property (weak) IBOutlet NSPopUpButton *popupTypes;
@property (weak) IBOutlet NSPopUpButton *popupSubtypes;
@property (weak) IBOutlet NSPopUpButton *popupLevel;
@property (weak) IBOutlet NSPopUpButton *popupOrigins;
@property (weak) IBOutlet NSPopUpButton *popupCount;

@property (weak) IBOutlet NSButton *buttonGenerate;

@property (nonatomic,strong) DSACharacter *generatedNpc;
@property (nonatomic, copy) void (^completionHandler)(DSACharacter *newCharacter);

- (void)startNpcGeneration: (id)sender;

@end

#endif // _DSANPCGENERATIONCONTROLLER_H_

