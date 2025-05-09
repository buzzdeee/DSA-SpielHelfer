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
@class DSAAventurianDate;

@interface DSACharacterGenerationController : NSWindowController

@property (readonly) NSMutableArray *portraitsArray;
@property (nonatomic, assign) NSInteger currentPortraitIndex; // To track the current image index

@property (nonatomic, strong) DSACharacter *generatedCharacter;
@property (nonatomic, copy) void (^completionHandler)(DSACharacter *newCharacter);
// used to juggle around positive and negative traits
@property (nonatomic, strong) NSMutableDictionary *traitsDict;
// used to keep track, how many switches to select at a maximum in the Magical Dabbler creation
@property (nonatomic) NSInteger magicalDabblerMaxSwitchesToBeSelected;
@property (nonatomic) NSInteger magicalDabblerDiceResult;
@property (nonatomic) NSInteger magicalDabblerAE;
@property (nonatomic, weak) NSMutableArray *magicalDabblerSpells;
@property (nonatomic, weak) NSMutableArray *magicalDabblerSpecialTalents;
// UI elements

@property (weak) IBOutlet NSPopUpButton *popupCategories;
@property (weak) IBOutlet NSPopUpButton *popupArchetypes;
@property (weak) IBOutlet NSPopUpButton *popupOrigins;
@property (weak) IBOutlet NSPopUpButton *popupProfessions;
@property (weak) IBOutlet NSPopUpButton *popupMageAcademies;
@property (weak) IBOutlet NSPopUpButton *popupElements;
@property (weak) IBOutlet NSPopUpButton *popupReligions;
@property (weak) IBOutlet NSPopUpButton *popupSex;
@property (weak) IBOutlet NSButton *buttonGenerate;
@property (weak) IBOutlet NSButton *buttonGenerateName;
@property (weak) IBOutlet NSButton *buttonFinish;
@property (weak) IBOutlet NSTextField *fieldMageSchool;
@property (weak) IBOutlet NSTextField *fieldElement;
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
@property (weak) IBOutlet NSButton *buttonMU;
@property (weak) IBOutlet NSButton *buttonKL;
@property (weak) IBOutlet NSButton *buttonIN;
@property (weak) IBOutlet NSButton *buttonCH;
@property (weak) IBOutlet NSButton *buttonFF;
@property (weak) IBOutlet NSButton *buttonGE;
@property (weak) IBOutlet NSButton *buttonKK;
@property (weak) IBOutlet NSButton *buttonAG;
@property (weak) IBOutlet NSButton *buttonHA;
@property (weak) IBOutlet NSButton *buttonRA;
@property (weak) IBOutlet NSButton *buttonTA;
@property (weak) IBOutlet NSButton *buttonNG;
@property (weak) IBOutlet NSButton *buttonGG;
@property (weak) IBOutlet NSButton *buttonJZ;
@property (weak) IBOutlet NSImageView *imageViewPortrait;


// following properties are Magical Dabbler window related
@property (weak) IBOutlet NSWindow *windowMagicalDabbler;
@property (weak) IBOutlet NSTextField *fieldHeadline;
@property (weak) IBOutlet NSTextField *fieldSecondLine;
@property (weak) IBOutlet NSButton *switchMagicalDabbler0;
@property (weak) IBOutlet NSButton *switchMagicalDabbler1;
@property (weak) IBOutlet NSButton *switchMagicalDabbler2;
@property (weak) IBOutlet NSButton *switchMagicalDabbler3;
@property (weak) IBOutlet NSButton *switchMagicalDabbler4;
@property (weak) IBOutlet NSButton *switchMagicalDabbler5;
@property (weak) IBOutlet NSButton *switchMagicalDabbler6;
@property (weak) IBOutlet NSButton *switchMagicalDabbler7;
@property (weak) IBOutlet NSButton *switchMagicalDabbler8;
@property (weak) IBOutlet NSButton *switchMagicalDabbler9;
@property (weak) IBOutlet NSButton *switchMagicalDabbler10;
@property (weak) IBOutlet NSButton *switchMagicalDabbler11;
@property (weak) IBOutlet NSButton *switchMagicalDabbler12;
@property (weak) IBOutlet NSButton *switchMagicalDabbler13;
@property (weak) IBOutlet NSButton *switchMagicalDabbler14;
@property (weak) IBOutlet NSButton *switchMagicalDabbler15;
@property (weak) IBOutlet NSButton *switchMagicalDabbler16;
@property (weak) IBOutlet NSButton *switchMagicalDabbler17;
@property (weak) IBOutlet NSButton *switchMagicalDabbler18;
@property (weak) IBOutlet NSButton *switchMagicalDabbler19;
@property (weak) IBOutlet NSButton *buttonMagicalDabblerFinish;

// Trigger character generation
- (void)startCharacterGeneration: (id) sender;

@end

#endif // _DSACHARACTERGENERATIONCONTROLLER_H_

