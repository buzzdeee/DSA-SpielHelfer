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
#import "DSAInventorySlotView.h"
#import "DSAActionIcon.h"

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
@property (weak) IBOutlet NSTextField *fieldLoad;
@property (weak) IBOutlet NSTextField *fieldArmor;
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
@property (weak) IBOutlet NSTextField *fieldLogs;
@property (weak) IBOutlet NSTabView *tabViewMain;
@property (weak) IBOutlet NSImageView *imageViewPortrait;
@property (weak) IBOutlet NSImageView *imageViewBodyShape;
@property (weak) IBOutlet DSAInventorySlotView *bodySlot0;
@property (weak) IBOutlet DSAInventorySlotView *bodySlot1;
@property (weak) IBOutlet DSAInventorySlotView *bodySlot2;
@property (weak) IBOutlet DSAInventorySlotView *bodySlot3;
@property (weak) IBOutlet DSAInventorySlotView *bodySlot4;
@property (weak) IBOutlet DSAInventorySlotView *bodySlot5;
@property (weak) IBOutlet DSAInventorySlotView *bodySlot6;
@property (weak) IBOutlet DSAInventorySlotView *bodySlot7;
@property (weak) IBOutlet DSAInventorySlotView *bodySlot8;
@property (weak) IBOutlet DSAInventorySlotView *bodySlot9;
@property (weak) IBOutlet DSAInventorySlotView *bodySlot10;
@property (weak) IBOutlet DSAInventorySlotView *bodySlot11;
@property (weak) IBOutlet DSAInventorySlotView *bodySlot12;
@property (weak) IBOutlet DSAInventorySlotView *bodySlot13;
@property (weak) IBOutlet DSAInventorySlotView *bodySlot14;
@property (weak) IBOutlet DSAInventorySlotView *bodySlot15;
@property (weak) IBOutlet DSAInventorySlotView *bodySlot16;
@property (weak) IBOutlet DSAInventorySlotView *bodySlot17;
@property (weak) IBOutlet DSAInventorySlotView *bodySlot18;
@property (weak) IBOutlet DSAInventorySlotView *bodySlot19;
@property (weak) IBOutlet DSAInventorySlotView *bodySlot20;
@property (weak) IBOutlet DSAInventorySlotView *bodySlot21;
@property (weak) IBOutlet DSAInventorySlotView *bodySlot22;
@property (weak) IBOutlet DSAInventorySlotView *bodySlot23;
@property (weak) IBOutlet DSAInventorySlotView *bodySlot24;
@property (weak) IBOutlet DSAInventorySlotView *bodySlot25;
@property (weak) IBOutlet DSAInventorySlotView *bodySlot26;
@property (weak) IBOutlet DSAInventorySlotView *bodySlot27;
@property (weak) IBOutlet DSAInventorySlotView *bodySlot28;
@property (weak) IBOutlet DSAInventorySlotView *bodySlot29;
@property (weak) IBOutlet DSAInventorySlotView *bodySlot30;
@property (weak) IBOutlet DSAInventorySlotView *bodySlot31;
@property (weak) IBOutlet DSAInventorySlotView *bodySlot32;
@property (weak) IBOutlet DSAInventorySlotView *bodySlot33;
@property (weak) IBOutlet DSAInventorySlotView *bodySlot34;
@property (weak) IBOutlet DSAInventorySlotView *bodySlot35;
@property (weak) IBOutlet DSAInventorySlotView *bodySlot36;
@property (weak) IBOutlet DSAInventorySlotView *inventorySlot0;
@property (weak) IBOutlet DSAInventorySlotView *inventorySlot1;
@property (weak) IBOutlet DSAInventorySlotView *inventorySlot2;
@property (weak) IBOutlet DSAInventorySlotView *inventorySlot3;
@property (weak) IBOutlet DSAInventorySlotView *inventorySlot4;
@property (weak) IBOutlet DSAInventorySlotView *inventorySlot5;
@property (weak) IBOutlet DSAInventorySlotView *inventorySlot6;
@property (weak) IBOutlet DSAInventorySlotView *inventorySlot7;
@property (weak) IBOutlet DSAInventorySlotView *inventorySlot8;
@property (weak) IBOutlet DSAInventorySlotView *inventorySlot9;
@property (weak) IBOutlet DSAInventorySlotView *inventorySlot10;
@property (weak) IBOutlet DSAInventorySlotView *inventorySlot11;
@property (weak) IBOutlet DSAInventorySlotView *inventorySlot12;
@property (weak) IBOutlet DSAInventorySlotView *inventorySlot13;
@property (weak) IBOutlet DSAInventorySlotView *inventorySlot14;
@property (weak) IBOutlet DSAInventorySlotView *inventorySlot15;
@property (weak) IBOutlet DSAInventorySlotView *inventorySlot16;
@property (weak) IBOutlet DSAInventorySlotView *inventorySlot17;
@property (weak) IBOutlet DSAInventorySlotView *inventorySlot18;
@property (weak) IBOutlet DSAInventorySlotView *inventorySlot19;
@property (weak) IBOutlet DSAInventorySlotView *inventorySlot20;
@property (weak) IBOutlet DSAInventorySlotView *inventorySlot21;
@property (weak) IBOutlet DSAInventorySlotView *inventorySlot22;
@property (weak) IBOutlet DSAInventorySlotView *inventorySlot23;
@property (weak) IBOutlet DSAInventorySlotView *inventorySlot24;
@property (weak) IBOutlet DSAInventorySlotView *inventorySlot25;
@property (weak) IBOutlet DSAInventorySlotView *inventorySlot26;
@property (weak) IBOutlet DSAInventorySlotView *inventorySlot27;
@property (weak) IBOutlet DSAInventorySlotView *inventorySlot28;
@property (weak) IBOutlet DSAInventorySlotView *inventorySlot29;
@property (weak) IBOutlet DSAInventorySlotView *inventorySlot30;
@property (weak) IBOutlet DSAInventorySlotView *inventorySlot31;
@property (weak) IBOutlet DSAInventorySlotView *inventorySlot32;
@property (weak) IBOutlet DSAActionIcon *imageEye;
@property (weak) IBOutlet DSAActionIcon *imageMouth;
@property (weak) IBOutlet DSAActionIcon *imageTrash;
@property (weak) IBOutlet NSProgressIndicator *progressBarHunger;
@property (weak) IBOutlet NSProgressIndicator *progressBarThirst;


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



// For character dead window
@property (nonatomic, strong) IBOutlet NSPanel *deadPanel;
@property (weak) IBOutlet NSTextField *fieldCharacterDead;
@property (weak) IBOutlet NSImageView *imageCharacterDead;

// For using talents window
@property (nonatomic, strong) IBOutlet NSPanel *useTalentPanel;
@property (weak) IBOutlet NSTextField *fieldTalentFeedback;
@property (weak) IBOutlet NSPopUpButton *popupTalentCategorySelector;
@property (weak) IBOutlet NSPopUpButton *popupTalentSelector;
@property (weak) IBOutlet NSTextField *fieldTalentPenalty;
@property (weak) IBOutlet NSPopUpButton *buttonTalentDoIt;

// for using spell window
@property (nonatomic, strong) IBOutlet NSPanel *castSpellPanel;
@property (weak) IBOutlet NSTextField *fieldSpellFeedback;
@property (weak) IBOutlet NSTextField *fieldSpellFeedbackHeadline;
@property (weak) IBOutlet NSTextField *fieldSpellCreatorLevel;          // level of the mage who casted initial spell we want to do antimagic on...
@property (weak) IBOutlet NSTextField *fieldSpellDistance;
@property (weak) IBOutlet NSTextField *fieldSpellInvestedASP;
@property (weak) IBOutlet NSTextField *fieldSpellMagicResistance;
@property (weak) IBOutlet NSPopUpButton *popupSpellCategorySelector;
@property (weak) IBOutlet NSPopUpButton *popupSpellSelector;
@property (weak) IBOutlet NSPopUpButton *buttonSpellDoIt;

// for the rituals window
@property (nonatomic, strong) IBOutlet NSPanel *castRitualPanel;
@property (weak) IBOutlet NSTextField *fieldRitualFeedback;
@property (weak) IBOutlet NSTextField *fieldRitualFeedbackHeadline;
@property (weak) IBOutlet NSPopUpButton *popupRitualCategorySelector;
@property (weak) IBOutlet NSPopUpButton *popupRitualVariantSelector;
@property (weak) IBOutlet NSPopUpButton *popupRitualDurationVariantSelector;
@property (weak) IBOutlet NSPopUpButton *popupRitualSelector;
@property (weak) IBOutlet NSTextField *fieldRitualCreatorLevel;          // level of the mage who casted initial spell we want to do antimagic on...
@property (weak) IBOutlet NSTextField *fieldRitualDistance;
@property (weak) IBOutlet NSTextField *fieldRitualInvestedASP;
@property (weak) IBOutlet NSTextField *fieldRitualMagicResistance;
@property (weak) IBOutlet NSPopUpButton *buttonRitualDoIt;

// For setting temporary energies, and states
@property (nonatomic, strong) IBOutlet NSPanel *manageTempEnergiesPanel;
@property (weak) IBOutlet NSTextField *fieldTempEnergiesAE;
@property (weak) IBOutlet NSTextField *fieldTempEnergiesKE;
@property (weak) IBOutlet NSTextField *fieldTempEnergiesLE;
@property (weak) IBOutlet NSSlider    *sliderTempEnergiesHunger;
@property (weak) IBOutlet NSSlider    *sliderTempEnergiesThirst;
@property (weak) IBOutlet NSPopUpButton *popupTempEnergiesWounded;
@property (weak) IBOutlet NSPopUpButton *popupTempEnergiesSick;
@property (weak) IBOutlet NSPopUpButton *popupTempEnergiesDrunk;
@property (weak) IBOutlet NSPopUpButton *popupTempEnergiesPoisoned;
@property (weak) IBOutlet NSPopUpButton *popupTempEnergiesDead;
@property (weak) IBOutlet NSPopUpButton *popupTempEnergiesUnconscious;
@property (weak) IBOutlet NSPopUpButton *popupTempEnergiesSpellbound;

// for character regeneration
@property (nonatomic, strong) IBOutlet NSPanel *regenerationPanel;
@property (weak) IBOutlet NSTextField *fieldRegenerationSleepHours;
@property (weak) IBOutlet NSTextField *fieldRegenerationResult;




// to track spells and spell names NSText field relationships to be able to change color
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSTextField *> *spellItemFieldMap;
@property (nonatomic, strong) NSMutableSet *observedObjects;

- (IBAction)closePanel:(id)sender;


@property (nonatomic, strong) NSMutableDictionary<id<NSCopying>, NSMutableSet<NSString *> *> *observedKeyPaths;

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem;

-(void)levelUpBaseValues:(id)sender;
-(void)addAdventurePoints: (id)sender;
-(void)manageMoney: (id)sender;
-(void)showUseTalentPanel: (id)sender;
-(void)showEnergiesManagerPanel: (id)sender;
-(void)showCastSpellPanel: (id)sender;
-(void)showRegenerateCharacterPanel: (id)sender;
-(void)showRitualsPanel: (id)sender;


@end

#endif // _DSACHARACTERWINDOWCONTROLLER_H_

