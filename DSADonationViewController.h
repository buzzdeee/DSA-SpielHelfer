/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-06-17 21:54:09 +0200 by sebastia

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

#ifndef _DSADONATIONVIEWCONTROLLER_H_
#define _DSADONATIONVIEWCONTROLLER_H_

#import <AppKit/AppKit.h>
#import "DSADonationViewController.h"

@class DSAAdventureGroup;

@interface DSADonationViewController : NSWindowController

@property (nonatomic, copy) void (^completionHandler)(BOOL result);

@property (nonatomic, weak) IBOutlet NSSlider *sliderSilver;
@property (nonatomic, weak) IBOutlet NSTextField *fieldMaxSilver;
@property (nonatomic, weak) IBOutlet NSTextField *fieldFinalSilver;
@property (nonatomic, weak) IBOutlet NSButton *buttonCancel;
@property (nonatomic, weak) IBOutlet NSButton *buttonDonate;

@property (nonatomic, weak) DSAAdventureGroup *activeGroup;

@end
#endif // _DSADONATIONVIEWCONTROLLER_H_

