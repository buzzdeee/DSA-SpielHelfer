/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-09-07 23:41:00 +0200 by sebastia

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

#ifndef _DSACHARACTERWINDOWCONTROLLER_H_
#define _DSACHARACTERWINDOWCONTROLLER_H_

#import <AppKit/AppKit.h>
#import "DSASpell.h"

@interface DSACharacterWindowController : NSWindowController

// Add weak UI outlets here
@property (weak) IBOutlet NSTextField *fieldAG;
@property (weak) IBOutlet NSTextField *fieldAdventurePoints;
@property (weak) IBOutlet NSTextField *fieldArchetype;
@property (weak) IBOutlet NSTextField *fieldMageAcademy;
@property (weak) IBOutlet NSTextField *fieldMageAcademyBold;
@property (weak) IBOutlet NSTextField *fieldMagicalDabbler;
@property (weak) IBOutlet NSTextField *fieldAstralEnergy;
@property (weak) IBOutlet NSTextField *fieldAttackBaseValue;
@property (weak) IBOutlet NSTextField *fieldBirthday;
@property (weak) IBOutlet NSTextField *fieldCH;
@property (weak) IBOutlet NSTextField *fieldCarryingCapacity;
@property (weak) IBOutlet NSTextField *fieldDodge;
@property (weak) IBOutlet NSTextField *fieldEncumbrance;
@property (weak) IBOutlet NSTextField *fieldEndurance;
@property (weak) IBOutlet NSTextField *fieldEyeColor;
@property (weak) IBOutlet NSTextField *fieldFF;
@property (weak) IBOutlet NSTextField *fieldGE;
@property (weak) IBOutlet NSTextField *fieldGG;
@property (weak) IBOutlet NSTextField *fieldGod;
@property (weak) IBOutlet NSTextField *fieldHA;
@property (weak) IBOutlet NSTextField *fieldHairColor;
@property (weak) IBOutlet NSTextField *fieldHeight;
@property (weak) IBOutlet NSTextField *fieldIN;
@property (weak) IBOutlet NSTextField *fieldJZ;
@property (weak) IBOutlet NSTextField *fieldKK;
@property (weak) IBOutlet NSTextField *fieldKL;
@property (weak) IBOutlet NSTextField *fieldKarmaPoints;
@property (weak) IBOutlet NSTextField *fieldLevel;
@property (weak) IBOutlet NSTextField *fieldLifePoints;
@property (weak) IBOutlet NSTextField *fieldMU;
@property (weak) IBOutlet NSTextField *fieldMagicResistance;
@property (weak) IBOutlet NSTextField *fieldMoney;
@property (weak) IBOutlet NSTextField *fieldNG;
@property (weak) IBOutlet NSTextField *fieldName;
@property (weak) IBOutlet NSTextField *fieldOrigin;
@property (weak) IBOutlet NSTextField *fieldParents;
@property (weak) IBOutlet NSTextField *fieldParryBaseValue;
@property (weak) IBOutlet NSTextField *fieldProfession;
@property (weak) IBOutlet NSTextField *fieldRA;
@property (weak) IBOutlet NSTextField *fieldRangedCombatBaseValue;
@property (weak) IBOutlet NSTextField *fieldSex;
@property (weak) IBOutlet NSTextField *fieldSocialStatus;
@property (weak) IBOutlet NSTextField *fieldStars;
@property (weak) IBOutlet NSTextField *fieldReligion;
@property (weak) IBOutlet NSTextField *fieldTA;
@property (weak) IBOutlet NSTextField *fieldTitle;
@property (weak) IBOutlet NSTextField *fieldWeight;
@property (weak) IBOutlet NSTabView *tabViewMain;
@property (weak) IBOutlet NSImageView *imageViewPortrait;

// For the secondary .gorm file DSACharacterLevelUp
@property (nonatomic, strong) IBOutlet NSPanel *congratsPanel;
@property (weak) IBOutlet NSTextField *fieldCongratsHeadline;
@property (weak) IBOutlet NSTextField *fieldCongratsMainText;
@property (weak) IBOutlet NSTextField *fieldCongratsMainTextLine2;
@property (weak) IBOutlet NSButton *buttonCongratsNow;
@property (weak) IBOutlet NSButton *buttonCongratsLater;
@property (nonatomic, strong) IBOutlet NSPanel *levelUpPanel;
@property (weak) IBOutlet NSTextField *fieldLevelUpHeadline;
@property (weak) IBOutlet NSTextField *fieldLevelUpMainText;
@property (weak) IBOutlet NSTextField *fieldLevelUpTrialsCounter;
@property (weak) IBOutlet NSTextField *fieldLevelUpFeedback;
@property (weak) IBOutlet NSPopUpButton *popupLevelUpTop;
@property (weak) IBOutlet NSPopUpButton *popupLevelUpBottom;
@property (weak) IBOutlet NSButton *buttonLevelUpDoIt;

// For adding adventure points
@property (nonatomic, strong) IBOutlet NSPanel *adventurePointsPanel;
@property (weak) IBOutlet NSTextField *fieldAdditionalAdventurePoints;
// to track spells and spell names NSText field relationships to be able to change color
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSTextField *> *spellItemFieldMap;


- (IBAction)closePanel:(id)sender;


@property (nonatomic, weak) IBOutlet NSMenuItem *menuItemLevelUp;

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem;

-(void)levelUpBaseValues:(id)sender;
-(void)addAdventurePoints: (id)sender;
-(void)manageMoney: (id)sender;
-(void)useTalent: (id)sender;


@end

#endif // _DSACHARACTERWINDOWCONTROLLER_H_

