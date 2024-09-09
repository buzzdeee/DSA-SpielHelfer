/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-09-08 20:45:23 +0200 by sebastia

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

#ifndef _DSACHARACTERGENERATIONCONTROLLER_H_
#define _DSACHARACTERGENERATIONCONTROLLER_H_

#import <AppKit/AppKit.h>

@class DSACharacter;

@interface DSACharacterGenerationController : NSWindowController
{

}

@property (readonly) NSMutableDictionary *talentsDict;
@property (readonly) NSMutableDictionary *archetypesDict;
@property (readonly) NSMutableDictionary *professionsDict;
@property (readonly) NSMutableDictionary *originsDict;
@property (readonly) NSMutableDictionary *mageAcademiesDict;
@property (readonly) NSMutableDictionary *eyeColorsDict;
@property (readonly) NSMutableDictionary *birthdaysDict;
@property (readonly) NSMutableDictionary *godsDict;

@property (nonatomic, strong) DSACharacter *generatedCharacter;
@property (nonatomic, copy) void (^completionHandler)(DSACharacter *newCharacter);

// UI elements

@property (weak) IBOutlet NSPopUpButton *popupCategories;
@property (weak) IBOutlet NSPopUpButton *popupArchetypes;
@property (weak) IBOutlet NSPopUpButton *popupOrigins;
@property (weak) IBOutlet NSPopUpButton *popupProfessions;
@property (weak) IBOutlet NSPopUpButton *popupMageAcademies;
@property (weak) IBOutlet NSButton *buttonGenerate;
@property (weak) IBOutlet NSButton *buttonFinish;
@property (weak) IBOutlet NSTextField *fieldMageSchool;
@property (weak) IBOutlet NSTextField *fieldName;
@property (weak) IBOutlet NSTextField *fieldTitle;
@property (weak) IBOutlet NSTextField *fieldHairColor;
@property (weak) IBOutlet NSTextField *fieldEyeColor;
@property (weak) IBOutlet NSTextField *fieldHeight;
@property (weak) IBOutlet NSTextField *fieldWeight;
@property (weak) IBOutlet NSTextField *fieldBirthday;
@property (weak) IBOutlet NSTextField *fieldGod;
@property (weak) IBOutlet NSTextField *fieldStars;
@property (weak) IBOutlet NSTextField *fieldSocialStatus;
@property (weak) IBOutlet NSTextField *fieldParents;
@property (weak) IBOutlet NSTextField *fieldWealth;
@property (weak) IBOutlet NSTextField *fieldMU;
@property (weak) IBOutlet NSTextField *fieldKL;
@property (weak) IBOutlet NSTextField *fieldIN;
@property (weak) IBOutlet NSTextField *fieldCH;
@property (weak) IBOutlet NSTextField *fieldFF;
@property (weak) IBOutlet NSTextField *fieldGE;
@property (weak) IBOutlet NSTextField *fieldKK;
@property (weak) IBOutlet NSTextField *fieldAG;
@property (weak) IBOutlet NSTextField *fieldHA;
@property (weak) IBOutlet NSTextField *fieldRA;
@property (weak) IBOutlet NSTextField *fieldTA;
@property (weak) IBOutlet NSTextField *fieldNG;
@property (weak) IBOutlet NSTextField *fieldGG;
@property (weak) IBOutlet NSTextField *fieldJZ;
@property (weak) IBOutlet NSTextField *fieldMUConstraint;
@property (weak) IBOutlet NSTextField *fieldKLConstraint;
@property (weak) IBOutlet NSTextField *fieldINConstraint;
@property (weak) IBOutlet NSTextField *fieldCHConstraint;
@property (weak) IBOutlet NSTextField *fieldFFConstraint;
@property (weak) IBOutlet NSTextField *fieldGEConstraint;
@property (weak) IBOutlet NSTextField *fieldKKConstraint;
@property (weak) IBOutlet NSTextField *fieldAGConstraint;
@property (weak) IBOutlet NSTextField *fieldHAConstraint;
@property (weak) IBOutlet NSTextField *fieldRAConstraint;
@property (weak) IBOutlet NSTextField *fieldTAConstraint;
@property (weak) IBOutlet NSTextField *fieldNGConstraint;
@property (weak) IBOutlet NSTextField *fieldGGConstraint;
@property (weak) IBOutlet NSTextField *fieldJZConstraint;


// Trigger character generation
- (void)startCharacterGeneration: (id) sender;

@end

#endif // _DSACHARACTERGENERATIONCONTROLLER_H_

