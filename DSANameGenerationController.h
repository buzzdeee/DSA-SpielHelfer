/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-01-10 23:31:28 +0100 by sebastia

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

#ifndef _DSANAMEGENERATIONCONTROLLER_H_
#define _DSANAMEGENERATIONCONTROLLER_H_

#import <AppKit/AppKit.h>

@interface DSANameGenerationController : NSWindowController
@property (weak) IBOutlet NSPopUpButton *popupOrigins;
@property (weak) IBOutlet NSPopUpButton *popupGenders;
@property (weak) IBOutlet NSPopUpButton *popupNobles;
@property (weak) IBOutlet NSTextField *fieldName;
@property (weak) IBOutlet NSButton *buttonGenerate;

-(IBAction) generate: (id) sender;

@end

#endif // _DSANAMEGENERATIONCONTROLLER_H_

