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

#import "DSACharacterWindowController.h"
#import "DSACharacterDocument.h"
#import "DSACharacterHero.h"
#import "DSAFightingTalent.h"
#import "DSAOtherTalent.h"
#import "NSFlippedView.h"
#import "DSATabView.h"
#import "DSATabViewItem.h"
#import "MoneyViewModel.h"

@implementation DSACharacterWindowController

// don't do anything here
// we don't want the window loaded on application start
- (DSACharacterWindowController *)init
{
  NSLog(@"DSACharacterWindowController: init called");    

  return self;
}

- (void)dealloc
{
  // Clean up KVO observer
  DSACharacterDocument *document = (DSACharacterDocument *)self.document;
  
  // the two below are silly, and should go away!
  [document.model removeObserver:self forKeyPath:@"name"];
  [document.model removeObserver:self forKeyPath:@"age"];    
  
  [document.model removeObserver:self forKeyPath:@"adventurePoints"];
}

- (DSACharacterWindowController *)initWithWindowNibName:(NSString *)nibNameOrNil
{
  NSLog(@"DSACharacterWindowController initWithWindowNibName %@", nibNameOrNil);
  self = [super initWithWindowNibName:nibNameOrNil];
  if (self)
    {
      NSLog(@"DSACharacterWindowController initialized with nib: %@", nibNameOrNil);
    }
  else
    {
      NSLog(@"DSACharacterWindowController had trouble initializing");
    }
  return self;
}

- (void)windowDidLoad
{
  [super windowDidLoad];
  // Perform additional setup after loading the window
  NSLog(@"DSACharacterWindowController: windowDidLoad called");
  
  // Find the menu item (level Up Character) by tag
  NSMenu *mainMenu = [NSApp mainMenu];
  NSMenuItem *menuItem = [self menuItemWithTag:22 inMenu:mainMenu];
    
  if (menuItem)
    {
      NSLog(@"DSACharacterWindowController windowDidLoad FOUND THE MENU ITEM, setting action to myself levelUp: method" );
      // Set the target and action for the menu item
      [menuItem setTarget:self];
      [menuItem setAction:@selector(levelUp:)];
    }  
  
  // central KVO observers
  DSACharacterDocument *document = (DSACharacterDocument *)self.document;
  [document.model addObserver:self
                   forKeyPath:@"adventurePoints"
                      options:NSKeyValueObservingOptionNew
                      context:NULL];  
  
  [self populateBasicsTab];
  [self populateFightingTalentsTab];
  [self populateOtherTalentsTab];
  
  [self handleAdventurePointsChange];
}

// private method, used in windowDidLoad, to find menu items of interest
// iterates through submenus to find the correct one...
- (NSMenuItem *)menuItemWithTag:(NSInteger)tag inMenu:(NSMenu *)menu {
    for (NSMenuItem *item in [menu itemArray]) {
        if ([item tag] == tag) {
            return item;
        }
        if ([item submenu]) {
            NSMenuItem *subMenuItem = [self menuItemWithTag:tag inMenu:[item submenu]];
            if (subMenuItem) {
                return subMenuItem;
            }
        }
    }
    return nil;
}

- (void) populateBasicsTab
{
  DSACharacterDocument *document = (DSACharacterDocument *)self.document;
  [self.fieldName bind:NSValueBinding toObject:document.model withKeyPath:@"name" options:nil];
  [self.fieldTitle bind:NSValueBinding toObject:document.model withKeyPath:@"title" options:nil];  
  [self.fieldArchetype bind:NSValueBinding toObject:document.model withKeyPath:@"archetype" options:nil];
  [self.fieldOrigin bind:NSValueBinding toObject:document.model withKeyPath:@"origin" options:nil];
  [self.fieldSex bind:NSValueBinding toObject:document.model withKeyPath:@"sex" options:nil];
  [self.fieldHairColor bind:NSValueBinding toObject:document.model withKeyPath:@"hairColor" options:nil];  
  [self.fieldEyeColor bind:NSValueBinding toObject:document.model withKeyPath:@"eyeColor" options:nil];
  [self.fieldHeight bind:NSValueBinding toObject:document.model withKeyPath:@"height" options:nil];    
  [self.fieldWeight bind:NSValueBinding toObject:document.model withKeyPath:@"weight" options:nil];    
  [self.fieldBirthday bind:NSValueBinding toObject:document.model withKeyPath:@"birthday.date" options:nil];      
  [self.fieldGod bind:NSValueBinding toObject:document.model withKeyPath:@"god" options:nil];      
  [self.fieldStars bind:NSValueBinding toObject:document.model withKeyPath:@"stars" options:nil];      
  [self.fieldSocialStatus bind:NSValueBinding toObject:document.model withKeyPath:@"socialStatus" options:nil];  
  [self.fieldParents bind:NSValueBinding toObject:document.model withKeyPath:@"parents" options:nil];  

  // Create and configure your view model
  MoneyViewModel *viewModel = [[MoneyViewModel alloc] init];
  viewModel.money = [document.model valueForKeyPath:@"money"];
    
  // Bind the NSTextField to the formattedMoney property
  [self.fieldMoney bind:NSValueBinding
               toObject:viewModel
            withKeyPath:@"formattedMoney"
                options:nil];                                              
    
  [self.imageViewPortrait setImage:document.model.portrait];
  [self.imageViewPortrait setImageScaling:NSImageScaleProportionallyUpOrDown];                                                                                                          
                                              
//  [self.fieldProfession bind:NSValueBinding toObject:document.model withKeyPath:@"profession" options:nil];  


  for (NSString *field in @[ @"MU", @"KL", @"IN", @"CH", @"FF", @"GE", @"KK" ])
    {
      NSString *fieldKey = [NSString stringWithFormat:@"field%@", field]; // Constructs "fieldAG", "fieldHA", etc.
      NSTextField *fieldControl = [self valueForKey:fieldKey]; // Dynamically retrieves self.fieldAG, self.fieldHA, etc.

      [fieldControl bind:NSValueBinding
                toObject:document.model
             withKeyPath:[NSString stringWithFormat:@"positiveTraits.%@.level", field]
                 options:nil];
      [document.model addObserver:self 
                       forKeyPath:[NSString stringWithFormat:@"positiveTraits.%@.level", field]
                          options:NSKeyValueObservingOptionNew 
                          context:NULL];                 
    }
  for (NSString *field in @[ @"AG", @"HA", @"RA", @"TA", @"NG", @"GG", @"JZ" ])
    {
      NSString *fieldKey = [NSString stringWithFormat:@"field%@", field]; // Constructs "fieldAG", "fieldHA", etc.
      NSTextField *fieldControl = [self valueForKey:fieldKey]; // Dynamically retrieves self.fieldAG, self.fieldHA, etc.

      [fieldControl bind:NSValueBinding
                toObject:document.model
             withKeyPath:[NSString stringWithFormat:@"negativeTraits.%@.level", field]
                 options:nil];
      [document.model addObserver:self 
                       forKeyPath:[NSString stringWithFormat:@"negativeTraits.%@.level", field]
                          options:NSKeyValueObservingOptionNew 
                          context:NULL];                 
    }
  [self.fieldAttackBaseValue bind:NSValueBinding toObject:document.model withKeyPath:@"attackBaseValue" options:nil];    
  [document.model addObserver:self forKeyPath: @"attackBaseValue" options:NSKeyValueObservingOptionNew context: NULL];
  [self.fieldCarryingCapacity bind:NSValueBinding toObject:document.model withKeyPath:@"carryingCapacity" options:nil];    
  [document.model addObserver:self forKeyPath: @"carryingCapacity" options:NSKeyValueObservingOptionNew context: NULL];
  [self.fieldDodge bind:NSValueBinding toObject:document.model withKeyPath:@"dodge" options:nil];    
  [document.model addObserver:self forKeyPath: @"dodge" options:NSKeyValueObservingOptionNew context: NULL];
  [self.fieldEncumbrance bind:NSValueBinding toObject:document.model withKeyPath:@"encumbrance" options:nil];    
  [document.model addObserver:self forKeyPath: @"encumbrance" options:NSKeyValueObservingOptionNew context: NULL];
  [self.fieldEndurance bind:NSValueBinding toObject:document.model withKeyPath:@"endurance" options:nil];    
  [document.model addObserver:self forKeyPath: @"endurance" options:NSKeyValueObservingOptionNew context: NULL];
  [self.fieldMagicResistance bind:NSValueBinding toObject:document.model withKeyPath:@"magicResistance" options:nil];    
  [document.model addObserver:self forKeyPath: @"magicResistance" options:NSKeyValueObservingOptionNew context: NULL];
  [self.fieldParryBaseValue bind:NSValueBinding toObject:document.model withKeyPath:@"parryBaseValue" options:nil];    
  [document.model addObserver:self forKeyPath: @"parryBaseValue" options:NSKeyValueObservingOptionNew context: NULL];
  [self.fieldRangedCombatBaseValue bind:NSValueBinding toObject:document.model withKeyPath:@"rangedCombatBaseValue" options:nil];    
  [document.model addObserver:self forKeyPath: @"rangedCombatBaseValue" options:NSKeyValueObservingOptionNew context: NULL];              
  [self.fieldLifePoints bind:NSValueBinding toObject:document.model withKeyPath:@"lifePoints" options:nil];    
  [document.model addObserver:self forKeyPath: @"lifePoints" options:NSKeyValueObservingOptionNew context: NULL];
  [self.fieldAstralEnergy bind:NSValueBinding toObject:document.model withKeyPath:@"astralEnergy" options:nil];    
  [document.model addObserver:self forKeyPath: @"astralEnergy" options:NSKeyValueObservingOptionNew context: NULL];  
  [self.fieldKarmaPoints bind:NSValueBinding toObject:document.model withKeyPath:@"karmaPoints" options:nil];    
  [document.model addObserver:self forKeyPath: @"karmaPoints" options:NSKeyValueObservingOptionNew context: NULL]; 
  [self.fieldLevel bind:NSValueBinding toObject:document.model withKeyPath:@"level" options:nil];    
  [document.model addObserver:self forKeyPath: @"level" options:NSKeyValueObservingOptionNew context: NULL];
  [self.fieldAdventurePoints bind:NSValueBinding toObject:document.model withKeyPath:@"adventurePoints" options:nil];    
  [document.model addObserver:self forKeyPath: @"adventurePoints" options:NSKeyValueObservingOptionNew context: NULL];

  
      
}

- (void) populateFightingTalentsTab
{
  DSACharacterDocument *document = (DSACharacterDocument *)self.document;
  DSACharacterHero *model = (DSACharacterHero *)document.model;

  NSTabViewItem *mainTabItem = [self.tabViewMain tabViewItemAtIndex: [self.tabViewMain indexOfTabViewItemWithIdentifier:@"item 2"]];
  NSRect subTabViewFrame = mainTabItem.view ? mainTabItem.view.bounds : NSMakeRect(0, 0, 400, 300);
  NSTabView *subTabView = [[NSTabView alloc] initWithFrame:subTabViewFrame];  
  //DSATabView *subTabView = [[DSATabView alloc] initWithFrame:subTabViewFrame];  
  [subTabView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
  
  NSMutableArray *fightingTalents = [NSMutableArray array];
  NSMutableSet *fightingCategories = [NSMutableSet set];
  
  // enumerate talents to find all fighting talents
  [model.talents enumerateKeysAndObjectsUsingBlock:^(id key, DSAFightingTalent *obj, BOOL *stop)
    {
      if ([[obj category] isEqualToString:@"Kampftechniken"])
        {
          [fightingTalents addObject: obj];
          [fightingCategories addObject: [obj subCategory]];
        }
    }];
  
//  NSLog(@"populateFightingTalentsTab: categories: %@", fightingCategories);  

  for (NSString *category in fightingCategories)
    {
      NSTabViewItem *innerTabItem = [[NSTabViewItem alloc] initWithIdentifier: category];
      //DSATabViewItem *innerTabItem = [[DSATabViewItem alloc] initWithIdentifier: category];
      innerTabItem.label = category;
      [subTabView addTabViewItem:innerTabItem];
      NSFlippedView *innerView = [[NSFlippedView alloc] initWithFrame: subTabView.bounds];
      [innerView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
      
      NSInteger Offset = 0;
      for (DSAFightingTalent *talent in fightingTalents)
        {
          if ([talent.subCategory isEqualTo: category])
            {
//              NSLog(@"Talent: %@ was equal to Category: %@", talent.name, category);
              Offset += 22;
              NSRect fieldRect = NSMakeRect(10,Offset, 300, 20);
              NSTextField *talentField = [[NSTextField alloc] initWithFrame: fieldRect];
              [talentField setIdentifier: [NSString stringWithFormat: @"talentField%@", talent]];
              [talentField setSelectable: NO];
              [talentField setEditable: NO];
              [talentField setBordered: NO];
              [talentField setBezeled: NO];
              [talentField setBackgroundColor: [NSColor lightGrayColor]];             
              [talentField setStringValue: [NSString stringWithFormat: @"%@ (%@)",
                                                                         talent.name,
                                                                         talent.maxUpPerLevel]];
              NSFont *boldFont = [NSFont boldSystemFontOfSize:[NSFont systemFontSize]];
              [talentField setFont:boldFont];                                                                         
              NSRect fieldValueRect = NSMakeRect(320, Offset, 20, 20);
              NSTextField *talentFieldValue = [[NSTextField alloc] initWithFrame: fieldValueRect];
              [talentFieldValue setIdentifier: [NSString stringWithFormat: @"talentFieldValue%@", talent]];
              [talentFieldValue setSelectable: NO];
              [talentFieldValue setEditable: NO];
              [talentFieldValue setBordered: NO];
              [talentFieldValue setBezeled: NO];
              [talentFieldValue setBackgroundColor: [NSColor lightGrayColor]];
              [talentFieldValue setStringValue: [talent.level stringValue]];  
              
              NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
              [paragraphStyle setAlignment:NSTextAlignmentRight];
              NSDictionary *attributes = @{NSParagraphStyleAttributeName: paragraphStyle};
              [talentFieldValue setAttributedStringValue:[[NSAttributedString alloc] initWithString:[talent.level stringValue] attributes:attributes]];
              
              [innerView addSubview: talentField];
              [innerView addSubview: talentFieldValue];
            }
        }
      [innerTabItem setView: innerView];
    }
  
    // Set the subTabView for item 2
    [mainTabItem setView:subTabView];
    
    // Programmatically select the tab to force loading its content
    [self.tabViewMain selectTabViewItem:mainTabItem];
    
    // Force layout to ensure views render immediately
    [subTabView layoutSubtreeIfNeeded];
    [mainTabItem.view layoutSubtreeIfNeeded];
    
    // Use setNeedsDisplay and displayIfNeeded for immediate rendering
    [subTabView setNeedsDisplay:YES];
    [subTabView displayIfNeeded];
    [mainTabItem.view setNeedsDisplay:YES];
    [mainTabItem.view displayIfNeeded];
    
    // Iterate through all sub-tabs to force them to layout
    for (NSTabViewItem *item in subTabView.tabViewItems) {
        [item.view setNeedsDisplay:YES];
        [item.view displayIfNeeded];
    }
    // Use performSelector:withObject:afterDelay: to force updates in the next run loop cycle
    [self performSelector:@selector(forceViewUpdate:) withObject:subTabView afterDelay:0.0];
        
  [self.tabViewMain selectTabViewItemAtIndex:0];  
    
}

- (void) populateOtherTalentsTab
{
  DSACharacterDocument *document = (DSACharacterDocument *)self.document;
  DSACharacterHero *model = (DSACharacterHero *)document.model;

  NSTabViewItem *mainTabItem = [self.tabViewMain tabViewItemAtIndex: [self.tabViewMain indexOfTabViewItemWithIdentifier:@"item 3"]];
  NSRect subTabViewFrame = mainTabItem.view ? mainTabItem.view.bounds : NSMakeRect(0, 0, 400, 300);
  NSTabView *subTabView = [[NSTabView alloc] initWithFrame:subTabViewFrame];  
  //DSATabView *subTabView = [[DSATabView alloc] initWithFrame:subTabViewFrame];  
  [subTabView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
  
  NSMutableArray *otherTalents = [NSMutableArray array];
  NSMutableSet *talentCategories = [NSMutableSet set];
  
  // enumerate talents to find all categories
  [model.talents enumerateKeysAndObjectsUsingBlock:^(id key, DSAOtherTalent *obj, BOOL *stop)
    {
      if (![[obj category] isEqualToString:@"Kampftechniken"])
        {
          [otherTalents addObject: obj];
          [talentCategories addObject: [obj category]];
        }
    }];
  
//  NSLog(@"populateOtherTalentsTab: categories: %@", talentCategories);  

  for (NSString *category in talentCategories)
    {
      NSTabViewItem *innerTabItem = [[NSTabViewItem alloc] initWithIdentifier: category];
      //DSATabViewItem *innerTabItem = [[DSATabViewItem alloc] initWithIdentifier: category];
      innerTabItem.label = category;
      [subTabView addTabViewItem:innerTabItem];
      NSFlippedView *innerView = [[NSFlippedView alloc] initWithFrame: subTabView.bounds];
      [innerView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
      
      NSInteger Offset = 0;
      for (DSAOtherTalent *talent in otherTalents)
        {
          if ([talent.category isEqualTo: category])
            {
//              NSLog(@"Talent: %@ was equal to Category: %@", talent.name, category);
              Offset += 22;
              NSRect fieldRect = NSMakeRect(10,Offset, 300, 20);
              NSTextField *talentField = [[NSTextField alloc] initWithFrame: fieldRect];
              [talentField setIdentifier: [NSString stringWithFormat: @"talentField%@", talent]];
              [talentField setSelectable: NO];
              [talentField setEditable: NO];
              [talentField setBordered: NO];
              [talentField setBezeled: NO];
              [talentField setBackgroundColor: [NSColor lightGrayColor]];             
              [talentField setStringValue: [NSString stringWithFormat: @"%@ (%@) (%@)",
                                                                         talent.name,
                                                                         [talent.test componentsJoinedByString:@"/"],
                                                                         talent.maxUpPerLevel]];
              NSFont *boldFont = [NSFont boldSystemFontOfSize:[NSFont systemFontSize]];
              [talentField setFont:boldFont];                                                                         
              NSRect fieldValueRect = NSMakeRect(320, Offset, 20, 20);
              NSTextField *talentFieldValue = [[NSTextField alloc] initWithFrame: fieldValueRect];
              [talentFieldValue setIdentifier: [NSString stringWithFormat: @"talentFieldValue%@", talent]];
              [talentFieldValue setSelectable: NO];
              [talentFieldValue setEditable: NO];
              [talentFieldValue setBordered: NO];
              [talentFieldValue setBezeled: NO];
              [talentFieldValue setBackgroundColor: [NSColor lightGrayColor]];
              [talentFieldValue setStringValue: [talent.level stringValue]];  
              
              NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
              [paragraphStyle setAlignment:NSTextAlignmentRight];
              NSDictionary *attributes = @{NSParagraphStyleAttributeName: paragraphStyle};
              [talentFieldValue setAttributedStringValue:[[NSAttributedString alloc] initWithString:[talent.level stringValue] attributes:attributes]];
              
              [innerView addSubview: talentField];
              [innerView addSubview: talentFieldValue];
            }
        }
      [innerTabItem setView: innerView];
    }
  
    // Set the subTabView for item 2
    [mainTabItem setView:subTabView];
    
    // Programmatically select the tab to force loading its content
    [self.tabViewMain selectTabViewItem:mainTabItem];
    
    // Force layout to ensure views render immediately
    [subTabView layoutSubtreeIfNeeded];
    [mainTabItem.view layoutSubtreeIfNeeded];
    
    // Use setNeedsDisplay and displayIfNeeded for immediate rendering
    [subTabView setNeedsDisplay:YES];
    [subTabView displayIfNeeded];
    [mainTabItem.view setNeedsDisplay:YES];
    [mainTabItem.view displayIfNeeded];
    
    // Iterate through all sub-tabs to force them to layout
    for (NSTabViewItem *item in subTabView.tabViewItems) {
        [item.view setNeedsDisplay:YES];
        [item.view displayIfNeeded];
    }
    // Use performSelector:withObject:afterDelay: to force updates in the next run loop cycle
    [self performSelector:@selector(forceViewUpdate:) withObject:subTabView afterDelay:0.0];
        
  [self.tabViewMain selectTabViewItemAtIndex:0];  
    
}


- (void)forceViewUpdate:(NSTabView *)subTabView {
    [subTabView setNeedsDisplay:YES];
    [subTabView displayIfNeeded];
//    [self.tabViewMain.view setNeedsDisplay:YES];
//    [self.tabViewMain.view displayIfNeeded];
    
    // Iterate through all sub-tabs to force them to layout
    for (NSTabViewItem *item in subTabView.tabViewItems) {
        [item.view setNeedsDisplay:YES];
        [item.view displayIfNeeded];
    }
}




// Dynamically enable/disable the "Level Up" menu item
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
  DSACharacterDocument *document = (DSACharacterDocument *)self.document;
  NSLog(@"DSACharacterWindowController validateMenuItem %@", menuItem);
  if ([menuItem tag] == 22) // Tag for the "Level Up" menu item
    {
      // Enable the "Level Up" menu item only if the character can level up
      return [(DSACharacterHero *)document.model canLevelUp];
    }
    return YES; // Default behavior for other menu items
}

- (IBAction)updateModel:(id)sender
{
  // Update the document's model when the user interacts with the UI
  NSLog(@"DSACharacterWindowController updateModel called by: %@", sender);
  DSACharacterDocument *document = (DSACharacterDocument *)self.document;
  // is this clever, or better to compare the sender against some values and have some maybe huge case
  // statement in case there are _MANY_ properties in the document?
  document.model.name = self.fieldName.stringValue;
  document.model.title = self.fieldTitle.stringValue;
  NSLog(@"Name value: %@", self.fieldName.stringValue);
  NSLog(@"Ttile value: %@", self.fieldTitle.stringValue);
  NSLog(@"Model Name after updating: %@", document.model.name);
  NSLog(@"Model Age after updating: %@", document.model.title);
  NSLog(@"DSACharacterWindowController updateModel: the document model: %@", document);
  // Mark doc as 'dirty'
  [document updateChangeCount:NSChangeDone];
}

// KVO observer method
// to make this work, it needs: https://github.com/gnustep/libs-base/pull/444
// otherwise replace NSKeyValueChangeKey with NSString*
- (void)observeValueForKeyPath:(NSString *)keyPath 
                      ofObject:(id)object 
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change 
                       context:(void *)context
{
NSLog(@"DSACharacterWindowController observeValueForKeyPath %@", keyPath);
  if ([keyPath isEqualToString:@"adventurePoints"])
    {
      [self handleAdventurePointsChange];
    }

}

- (IBAction)handleAdventurePointsChange {
  DSACharacterDocument *document = (DSACharacterDocument *)self.document;
  if ([(DSACharacterHero *)document.model canLevelUp])
    {
      [self showCongratsPanel];
    }
}


- (void)showCongratsPanel
{
  DSACharacterDocument *document = (DSACharacterDocument *)self.document;
  if (!self.congratsPanel)
    {
      // Load the panel from the separate .gorm file
      [NSBundle loadNibNamed:@"DSACharacterLevelUp" owner:self];
    }
  // Set the font size of the fieldCongratsHeadline
  NSFont *currentFont = [self.fieldCongratsHeadline font];
  NSFont *biggerFont = [[NSFontManager sharedFontManager] convertFont:currentFont toSize:20.0]; // Set size to 20
  [self.fieldCongratsHeadline setFont:biggerFont];    
  [self.fieldCongratsMainText setStringValue: [NSString stringWithFormat: @"%@ hat soeben eine neue Stufe erreicht.", document.model.name]];
  [self.congratsPanel makeKeyAndOrderFront:nil];
}

// Action when the "Level Up" menu item is clicked
- (IBAction)showLevelUpPositiveTraits:(id)sender
{
  NSLog(@"Level up menu item clicked!");
  if (!self.levelUpPanel)
    {
      // Load the panel from the separate .gorm file
      [NSBundle loadNibNamed:@"DSACharacterLevelUp" owner:self];
    }
  // Set the font size of the fieldCongratsHeadline
  NSFont *currentFont = [self.fieldLevelUpHeadline font];
  NSFont *biggerFont = [[NSFontManager sharedFontManager] convertFont:currentFont toSize:20.0]; // Set size to 20
  [self.fieldLevelUpHeadline setFont:biggerFont];
  [self.fieldLevelUpHeadline setStringValue: _(@"Positive Eigenschaft erhöhen")];
  [self.fieldLevelUpMainText setStringValue: _(@"Eigenschaft auswählen")];
 
  [self.popupLevelUpTop removeAllItems];
  [self.popupLevelUpTop addItemsWithTitles: @[
                             _(@"Mut"),
                             _(@"Klugheit"),
                             _(@"Intuition"),
                             _(@"Charisma"),
                             _(@"Fingerfertigkeit"),
                             _(@"Gewandheit"),
                             _(@"Körperkraft")]];

  [self.fieldLevelUpFeedback setHidden: YES];
  [self.fieldLevelUpTrialsCounter setHidden: YES];                                                            
  [self.popupLevelUpBottom setHidden: YES];  
  [self.buttonLevelUpDoIt setTarget:self];
  [self.buttonLevelUpDoIt setAction:@selector(levelUpPositiveTraits:)];
  [self.levelUpPanel makeKeyAndOrderFront:nil];
  [[sender window] close];
}

- (void)levelUpPositiveTraits:(id)sender {
    NSLog(@"Leveling up positive traits...");
    // Your logic to handle leveling up positive traits goes here
    
    DSACharacterDocument *document = (DSACharacterDocument *)self.document;
    DSACharacterHero *model = (DSACharacterHero *)document.model;
    NSString *selectedTrait = [[self.popupLevelUpTop selectedItem] title];

    BOOL result = NO;
    if ([selectedTrait isEqualTo: _(@"Mut")])
      {
        result = [model levelUpPositiveTrait: @"MU"];
      }
    else if ([selectedTrait isEqualTo: _(@"Klugheit")])
      {
        result = [model levelUpPositiveTrait: @"KL"];
      }
    else if ([selectedTrait isEqualTo: _(@"Intuition")])
      {
        result = [model levelUpPositiveTrait: @"IN"];
      }
    else if ([selectedTrait isEqualTo: _(@"Charisma")])
      {
        result = [model levelUpPositiveTrait: @"CH"];
      }
    else if ([selectedTrait isEqualTo: _(@"Fingerfertigkeit")])
      {
        result = [model levelUpPositiveTrait: @"FF"];
      }
    else if ([selectedTrait isEqualTo: _(@"Gewandheit")])
      {
        result = [model levelUpPositiveTrait: @"GE"];
      }
    else if ([selectedTrait isEqualTo: _(@"Körperkraft")])
      {
        result = [model levelUpPositiveTrait: @"KK"];
      }                              
      
  if (result)
    {
      [self.fieldLevelUpFeedback setStringValue: _(@"Geschafft!")];
      [self.fieldLevelUpFeedback setHidden: NO];
    }
  else
    {
      [self.fieldLevelUpFeedback setStringValue: _(@"Leider nicht geschafft.")];
      [self.fieldLevelUpFeedback setHidden: NO];    
    }
  [self.buttonLevelUpDoIt setTarget:self];
  [self.buttonLevelUpDoIt setAction:@selector(showLevelDownNegativeTraits:)]; 
  [self.buttonLevelUpDoIt setTitle: _(@"Weiter")];    
}

// Action when the "Level Up" menu item is clicked
- (IBAction)showLevelDownNegativeTraits:(id)sender
{
  NSLog(@"showLevelDownNegativeTraits");
  if (!self.levelUpPanel)
    {
      // Load the panel from the separate .gorm file
      [NSBundle loadNibNamed:@"DSACharacterLevelUp" owner:self];
    }
  // Set the font size of the fieldCongratsHeadline
  NSFont *currentFont = [self.fieldLevelUpHeadline font];
  NSFont *biggerFont = [[NSFontManager sharedFontManager] convertFont:currentFont toSize:20.0]; // Set size to 20
  [self.fieldLevelUpHeadline setFont:biggerFont];
  [self.fieldLevelUpHeadline setStringValue: _(@"Negative Eigenschaft senken")];
  [self.fieldLevelUpMainText setStringValue: _(@"Eigenschaft auswählen")];
 
  [self.popupLevelUpTop removeAllItems];
  [self.popupLevelUpTop addItemsWithTitles: @[
                             _(@"Aberglaube"),
                             _(@"Höhenangst"),
                             _(@"Raumangst"),
                             _(@"Totenangst"),
                             _(@"Neugier"),
                             _(@"Goldgier"),
                             _(@"Jähzorn")]];

  [self.fieldLevelUpFeedback setHidden: YES];
  [self.fieldLevelUpTrialsCounter setHidden: YES];                                                            
  [self.popupLevelUpBottom setHidden: YES];  
  [self.buttonLevelUpDoIt setTarget:self];
  [self.buttonLevelUpDoIt setAction:@selector(levelDownNegativeTraits:)]; 
  [self.buttonLevelUpDoIt setTitle: _(@"Senken")];                             
}


- (void)levelDownNegativeTraits:(id)sender {
    NSLog(@"Leveling down negative traits...");
    // Your logic to handle leveling up positive traits goes here
    
    DSACharacterDocument *document = (DSACharacterDocument *)self.document;
    DSACharacterHero *model = (DSACharacterHero *)document.model;
    NSString *selectedTrait = [[self.popupLevelUpTop selectedItem] title];

    BOOL result = NO;
    if ([selectedTrait isEqualTo: _(@"Aberglaube")])
      {
        result = [model levelDownNegativeTrait: @"AG"];
      }
    else if ([selectedTrait isEqualTo: _(@"Höhenangst")])
      {
        result = [model levelDownNegativeTrait: @"HA"];
      }
    else if ([selectedTrait isEqualTo: _(@"Raumangst")])
      {
        result = [model levelDownNegativeTrait: @"RA"];
      }
    else if ([selectedTrait isEqualTo: _(@"Totenangst")])
      {
        result = [model levelDownNegativeTrait: @"TA"];
      }
    else if ([selectedTrait isEqualTo: _(@"Neugier")])
      {
        result = [model levelDownNegativeTrait: @"NG"];
      }
    else if ([selectedTrait isEqualTo: _(@"Goldgier")])
      {
        result = [model levelDownNegativeTrait: @"GG"];
      }
    else if ([selectedTrait isEqualTo: _(@"Jähzorn")])
      {
        result = [model levelDownNegativeTrait: @"JZ"];
      }                              
      
  if (result)
    {
      [self.fieldLevelUpFeedback setStringValue: _(@"Geschafft!")];
      [self.fieldLevelUpFeedback setHidden: NO];
    }
  else
    {
      [self.fieldLevelUpFeedback setStringValue: _(@"Leider nicht geschafft.")];
      [self.fieldLevelUpFeedback setHidden: NO];    
    }
  [self.buttonLevelUpDoIt setTarget:self];
  [self.buttonLevelUpDoIt setAction:@selector(showLevelUpTalents:)]; 
  [self.buttonLevelUpDoIt setTitle: _(@"Weiter")];      
}

- (IBAction)showLevelUpTalents:(id)sender
{
  NSLog(@"showLevelUpTalents");
  DSACharacterDocument *document = (DSACharacterDocument *)self.document;
  DSACharacterHero *model = (DSACharacterHero *)document.model;
  if (!self.levelUpPanel)
    {
      // Load the panel from the separate .gorm file
      [NSBundle loadNibNamed:@"DSACharacterLevelUp" owner:self];
    }
  // Set the font size of the fieldCongratsHeadline
  
  NSMutableSet *talentCategories = [NSMutableSet set];
  
  // enumerate talents to find all categories
  [model.talents enumerateKeysAndObjectsUsingBlock:^(id key, DSAOtherTalent *obj, BOOL *stop)
    {
      [talentCategories addObject: [obj category]];
    }];  
  
  NSFont *currentFont = [self.fieldLevelUpHeadline font];
  NSFont *biggerFont = [[NSFontManager sharedFontManager] convertFont:currentFont toSize:20.0]; // Set size to 20
  [self.fieldLevelUpHeadline setFont:biggerFont];
  [self.fieldLevelUpHeadline setStringValue: _(@"Talente steigern")];
  [self.fieldLevelUpMainText setStringValue: _(@"Talent auswählen")];
 
  [self.popupLevelUpTop removeAllItems];
  [self.popupLevelUpTop addItemsWithTitles: [talentCategories allObjects]];
  [self.popupLevelUpBottom setHidden: NO];
  
  [self populateLevelUpBottomPopupWithTalents: nil];
  
  [self.popupLevelUpTop setTarget:self];
  [self.popupLevelUpTop setAction:@selector(populateLevelUpBottomPopupWithTalents:)];
  
  [self.fieldLevelUpFeedback setHidden: YES];
  [self.fieldLevelUpTrialsCounter setHidden: YES];                                                            

  [self.buttonLevelUpDoIt setTarget:self];
  [self.buttonLevelUpDoIt setAction:@selector(levelUpTalent:)]; 
  [self.buttonLevelUpDoIt setTitle: _(@"Steigern")];
}

- (void)populateLevelUpBottomPopupWithTalents:(id)sender
{
  NSLog(@"populateLevelUpBottomPopupWithTalents called");
}


- (void)levelUpTalent:(id)sender
{
  NSLog(@"Level Up Talent called!");
}

- (void)closePanel:(id)sender {

    [[sender window] close];
}

@end
