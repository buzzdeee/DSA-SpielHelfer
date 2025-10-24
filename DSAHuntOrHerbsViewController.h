/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-10-24 22:46:41 +0200 by sebastia

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

#ifndef _DSAHUNTORHERBSVIEWCONTROLLER_H_
#define _DSAHUNTORHERBSVIEWCONTROLLER_H_

#import <AppKit/AppKit.h>

typedef NS_ENUM(NSInteger, DSAHuntOrHerbsViewMode) {
    DSAHuntOrHerbsViewModeUnknown = 0,
    DSAHuntOrHerbsViewModeHunt,
    DSAHuntOrHerbsViewModeHerbs,
    // more modes ...
};

@interface DSAHuntOrHerbsViewController : NSWindowController

@property (nonatomic, copy) void (^completionHandler)(BOOL result);
@property (nonatomic, assign) DSAHuntOrHerbsViewMode mode;

@property (nonatomic, weak) IBOutlet NSPopUpButton *popupCharacters;
@property (nonatomic, weak) IBOutlet NSTextField *fieldQuestionWho;
@property (nonatomic, weak) IBOutlet NSTextField *fieldQuestionHours;
@property (nonatomic, weak) IBOutlet NSSlider *sliderHours;
@property (nonatomic, weak) IBOutlet NSTextField *fieldHours;
@property (nonatomic, weak) IBOutlet NSButton *buttonConfirm;

-(IBAction) sliderValueChanged: (NSSlider *)sender;

@end

#endif // _DSAHUNTORHERBSVIEWCONTROLLER_H_

