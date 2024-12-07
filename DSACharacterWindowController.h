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
@property (weak) IBOutlet NSImageView *bodySlot0;
@property (weak) IBOutlet NSImageView *bodySlot1;
@property (weak) IBOutlet NSImageView *bodySlot2;
@property (weak) IBOutlet NSImageView *bodySlot3;
@property (weak) IBOutlet NSImageView *bodySlot4;
@property (weak) IBOutlet NSImageView *bodySlot5;
@property (weak) IBOutlet NSImageView *bodySlot6;
@property (weak) IBOutlet NSImageView *bodySlot7;
@property (weak) IBOutlet NSImageView *bodySlot8;
@property (weak) IBOutlet NSImageView *bodySlot9;
@property (weak) IBOutlet NSImageView *bodySlot10;
@property (weak) IBOutlet NSImageView *bodySlot11;
@property (weak) IBOutlet NSImageView *bodySlot12;
@property (weak) IBOutlet NSImageView *bodySlot13;
@property (weak) IBOutlet NSImageView *bodySlot14;
@property (weak) IBOutlet NSImageView *bodySlot15;
@property (weak) IBOutlet NSImageView *bodySlot16;
@property (weak) IBOutlet NSImageView *bodySlot17;
@property (weak) IBOutlet NSImageView *bodySlot18;
@property (weak) IBOutlet NSImageView *bodySlot19;
@property (weak) IBOutlet NSImageView *bodySlot20;
@property (weak) IBOutlet NSImageView *bodySlot21;
@property (weak) IBOutlet NSImageView *bodySlot22;
@property (weak) IBOutlet NSImageView *bodySlot23;
@property (weak) IBOutlet NSImageView *bodySlot24;
@property (weak) IBOutlet NSImageView *bodySlot25;
@property (weak) IBOutlet NSImageView *bodySlot26;
@property (weak) IBOutlet NSImageView *bodySlot27;
@property (weak) IBOutlet NSImageView *bodySlot28;
@property (weak) IBOutlet NSImageView *bodySlot29;
@property (weak) IBOutlet NSImageView *bodySlot30;
@property (weak) IBOutlet NSImageView *bodySlot31;
@property (weak) IBOutlet NSImageView *bodySlot32;
@property (weak) IBOutlet NSImageView *bodySlot33;
@property (weak) IBOutlet NSImageView *bodySlot34;
@property (weak) IBOutlet NSImageView *bodySlot35;
@property (weak) IBOutlet NSImageView *bodySlot36;
@property (weak) IBOutlet NSImageView *inventorySlot0;
@property (weak) IBOutlet NSImageView *inventorySlot1;
@property (weak) IBOutlet NSImageView *inventorySlot2;
@property (weak) IBOutlet NSImageView *inventorySlot3;
@property (weak) IBOutlet NSImageView *inventorySlot4;
@property (weak) IBOutlet NSImageView *inventorySlot5;
@property (weak) IBOutlet NSImageView *inventorySlot6;
@property (weak) IBOutlet NSImageView *inventorySlot7;
@property (weak) IBOutlet NSImageView *inventorySlot8;
@property (weak) IBOutlet NSImageView *inventorySlot9;
@property (weak) IBOutlet NSImageView *inventorySlot10;
@property (weak) IBOutlet NSImageView *inventorySlot11;
@property (weak) IBOutlet NSImageView *inventorySlot12;
@property (weak) IBOutlet NSImageView *inventorySlot13;
@property (weak) IBOutlet NSImageView *inventorySlot14;
@property (weak) IBOutlet NSImageView *inventorySlot15;
@property (weak) IBOutlet NSImageView *inventorySlot16;
@property (weak) IBOutlet NSImageView *inventorySlot17;
@property (weak) IBOutlet NSImageView *inventorySlot18;
@property (weak) IBOutlet NSImageView *inventorySlot19;
@property (weak) IBOutlet NSImageView *inventorySlot20;
@property (weak) IBOutlet NSImageView *inventorySlot21;
@property (weak) IBOutlet NSImageView *inventorySlot22;
@property (weak) IBOutlet NSImageView *inventorySlot23;
@property (weak) IBOutlet NSImageView *inventorySlot24;
@property (weak) IBOutlet NSImageView *inventorySlot25;
@property (weak) IBOutlet NSImageView *inventorySlot26;
@property (weak) IBOutlet NSImageView *inventorySlot27;
@property (weak) IBOutlet NSImageView *inventorySlot28;
@property (weak) IBOutlet NSImageView *inventorySlot29;
@property (weak) IBOutlet NSImageView *inventorySlot30;
@property (weak) IBOutlet NSImageView *inventorySlot31;
@property (weak) IBOutlet NSImageView *inventorySlot32;
@property (weak) IBOutlet NSImageView *imageEye;
@property (weak) IBOutlet NSImageView *imageMouth;

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

