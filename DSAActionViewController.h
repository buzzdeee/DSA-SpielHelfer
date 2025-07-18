/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-07-17 20:46:37 +0200 by sebastia

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

#ifndef _DSAACTIONVIEWCONTROLLER_H_
#define _DSAACTIONVIEWCONTROLLER_H_

#import <AppKit/AppKit.h>
@class DSAAdventureGroup;

typedef NS_ENUM(NSInteger, DSAActionViewMode) {
    DSAActionViewModeTalent,
    DSAActionViewModeSpell
};

@interface DSAActionViewController : NSWindowController

@property (nonatomic, copy) void (^completionHandler)(BOOL result);
@property (nonatomic, assign) DSAActionViewMode viewMode;                    // to either use talents or spells
@property (nonatomic, strong) DSAAdventureGroup *activeGroup;
@property (nonatomic, strong) NSArray <NSString *> *talents;                 // strings of talent names
@property (nonatomic, strong) NSArray <NSString *> *spells;                  // strings of spell names
@property (nonatomic, strong) NSArray <NSString *> *specials;                // strings of ritual names

@property (nonatomic, weak) IBOutlet NSTextField *fieldActionHeadline;
@property (nonatomic, weak) IBOutlet NSTextField *fieldActionQuestionWho;
@property (nonatomic, weak) IBOutlet NSTextField *fieldActionQuestionWhat;
@property (nonatomic, weak) IBOutlet NSTextField *fieldActionQuestionTarget;
@property (nonatomic, weak) IBOutlet NSPopUpButton *popupActors;
@property (nonatomic, weak) IBOutlet NSPopUpButton *popupActions;
@property (nonatomic, weak) IBOutlet NSPopUpButton *popupTargets;
@property (nonatomic, weak) IBOutlet NSButton *buttonCancel;
@property (nonatomic, weak) IBOutlet NSButton *buttonDoIt;

@end

#endif // _DSAACTIONVIEWCONTROLLER_H_

