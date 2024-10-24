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

#import <objc/message.h>
#import "DSACharacterWindowController.h"
#import "DSACharacterDocument.h"
#import "DSACharacterHero.h"
#import "DSACharacterHeroHumanMage.h"
#import "DSACharacterHeroHumanWarrior.h"
#import "DSACharacterHeroDwarfGeode.h"
#import "DSACharacterMagic.h"
#import "DSAFightingTalent.h"
#import "DSAOtherTalent.h"
#import "DSASpecialTalent.h"
#import "DSAProfession.h"
#import "DSASpell.h"
#import "NSFlippedView.h"
#import "DSACharacterViewModel.h"
#import "DSARightAlignedStringTransformer.h"

@implementation DSACharacterWindowController

// don't do anything here
// we don't want the window loaded on application start
- (DSACharacterWindowController *)init
{
  NSLog(@"DSACharacterWindowController: init called");    
  self = [super init];
  if (self)
    {
    }
  return self;
}

- (void)dealloc
{
  // Clean up KVO observer
  DSACharacterDocument *document = (DSACharacterDocument *)self.document;
  
  NSLog(@"DSACharacterWindowController is being deallocated.");   
  
  [document.model removeObserver:self forKeyPath:@"adventurePoints"];
}

- (DSACharacterWindowController *)initWithWindowNibName:(NSString *)nibNameOrNil
{
  NSLog(@"DSACharacterWindowController initWithWindowNibName %@", nibNameOrNil);
  self = [super initWithWindowNibName:nibNameOrNil];
  if (self)
    {
      NSLog(@"DSACharacterWindowController initialized with nib: %@", nibNameOrNil);
      self.spellItemFieldMap = [NSMutableDictionary dictionary];
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
      
  // central KVO observers
  
  // Register the value transformer
  [NSValueTransformer setValueTransformer:[[DSARightAlignedStringTransformer alloc] init] 
                                  forName:@"RightAlignedStringTransformer"];
  
  DSACharacterDocument *document = (DSACharacterDocument *)self.document;
  [document.model addObserver:self
                   forKeyPath:@"adventurePoints"
                      options:NSKeyValueObservingOptionNew
                      context:NULL];
                        
  [self populateBasicsTab];
  [self populateFightingTalentsTab];
  [self populateOtherTalentsTab];
  [self populateProfessionsTab];
  [self populateMagicTalentsTab];
  [self populateSpecialTalentsTab];
  [self populateBiographyTab];
  
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

  [self.fieldName setStringValue: [document.model name]];
  [self.fieldTitle setStringValue: [document.model title]];  
  [self.fieldArchetype setStringValue: [document.model archetype]];
  [self.fieldOrigin setStringValue: [document.model origin]];
  [self.fieldSex setStringValue: [document.model sex]];
  [self.fieldHairColor setStringValue: [document.model hairColor]];  
  [self.fieldEyeColor setStringValue: [document.model eyeColor]];
  [self.fieldHeight setStringValue: [document.model height]];    
  [self.fieldWeight setStringValue: [document.model weight]];    
  [self.fieldBirthday setStringValue: [[document.model birthday] objectForKey: @"date"]];      
  [self.fieldGod setStringValue: [document.model god]];      
  [self.fieldStars setStringValue: [document.model stars]];
  [self.fieldReligion setStringValue: [document.model religion]];      
  [self.fieldSocialStatus setStringValue: [document.model socialStatus]];  
  [self.fieldParents setStringValue: [document.model parents]];   
  
  [self.fieldMagicalDabbler setStringValue: [document.model isMagicalDabbler] ? _(@"Ja") : _(@"Nein")];
    
  if ([document.model element])
    {
      [self.fieldMageAcademy setStringValue: [NSString stringWithFormat: @"%@ (%@)", [document.model mageAcademy], [document.model element]]];
    }
  else
    {
      [self.fieldMageAcademy setStringValue: [document.model mageAcademy]];
    }
  if (![document.model mageAcademy])
    {
      [self.fieldMageAcademyBold setHidden: YES];
      [self.fieldMageAcademy setHidden: YES];
    }
  if ([document.model isMemberOfClass: [DSACharacterHeroHumanMage class]])
    {
      [self.fieldMageAcademyBold setStringValue: _(@"Magierakademie")];
    }
  else if ([document.model isMemberOfClass: [DSACharacterHeroHumanWarrior class]])
    {
      [self.fieldMageAcademyBold setStringValue: _(@"Kriegerakademie")];
    }
  else if ([document.model isMemberOfClass: [DSACharacterHeroDwarfGeode class]])
    {
      [self.fieldMageAcademyBold setStringValue: _(@"Geodische Schule")];
    }    
        
  // Create and configure your view model
  DSACharacterViewModel *viewModel = [[DSACharacterViewModel alloc] init];
  DSACharacterHero *model = (DSACharacterHero *)document.model;
  viewModel.model = model;  // Pass the entire model to the viewModel
  [self.fieldMoney bind:NSValueBinding
               toObject:viewModel
            withKeyPath:@"formattedMoney"
                options:nil];
  [self.fieldLifePoints bind:NSValueBinding
                    toObject:viewModel
                 withKeyPath:@"formattedLifePoints"
                     options:nil];    
  [self.fieldAstralEnergy bind:NSValueBinding
                      toObject:viewModel
                   withKeyPath:@"formattedAstralEnergy"
                       options:nil];  
  [self.fieldKarmaPoints bind:NSValueBinding
                     toObject:viewModel
                  withKeyPath:@"formattedKarmaPoints"
                      options:nil];                                              
  [self.imageViewPortrait setImage: [document.model portrait]];
  [self.imageViewPortrait setImageScaling: NSImageScaleProportionallyUpOrDown];                                                                                                          
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
  [self.fieldLevel bind:NSValueBinding toObject:document.model withKeyPath:@"level" options:nil];    
  [document.model addObserver:self forKeyPath: @"level" options:NSKeyValueObservingOptionNew context: NULL];
  [self.fieldAdventurePoints bind:NSValueBinding toObject:document.model withKeyPath:@"adventurePoints" options:nil];    
  [document.model addObserver:self forKeyPath: @"adventurePoints" options:NSKeyValueObservingOptionNew context: NULL];
  NSLog(@"End of populateBasicsTab");   
}

- (void)populateFightingTalentsTab
{
   DSACharacterDocument *document = (DSACharacterDocument *)self.document;
   DSACharacterHero *model = (DSACharacterHero *)document.model;

   NSTabViewItem *mainTabItem = [self.tabViewMain tabViewItemAtIndex:[self.tabViewMain indexOfTabViewItemWithIdentifier:@"item 2"]];
   NSRect subTabViewFrame = mainTabItem.view ? mainTabItem.view.bounds : NSMakeRect(0, 0, 400, 300);
   NSTabView *subTabView = [[NSTabView alloc] initWithFrame:subTabViewFrame];
   [subTabView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];

   NSMutableArray *fightingTalents = [NSMutableArray array];
   NSMutableSet *fightingCategories = [NSMutableSet set];

   // Enumerate talents to find all fighting talents
   [model.talents enumerateKeysAndObjectsUsingBlock:^(id key, DSAFightingTalent *obj, BOOL *stop)
     {
        if ([[obj category] isEqualToString:@"Kampftechniken"])
          {
             [fightingTalents addObject:obj];
             [fightingCategories addObject:[obj subCategory]];
          }
     }];

   // Sort the fighting categories alphabetically
   NSArray *sortedFightingCategories = [[fightingCategories allObjects] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

   // Sort the fighting talents by subCategory
   NSSortDescriptor *nameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
   NSArray *sortedFightingTalents = [fightingTalents sortedArrayUsingDescriptors:@[nameSortDescriptor]];
        
   // Iterate through sorted categories and create tabs for them
   for (NSString *category in sortedFightingCategories)
     {
        // Filter talents that belong to the current category
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(DSAFightingTalent *evaluatedObject, NSDictionary *bindings)
          {
            return [evaluatedObject.subCategory isEqualToString:category];
          }];
        NSArray *filteredTalents = [sortedFightingTalents filteredArrayUsingPredicate:predicate];
        
        // Call the helper method to add the tab for this category
        [self addTabForCategory:category inSubTabView:subTabView withItems:filteredTalents];
     }

   // Set the subTabView for item 2
   [mainTabItem setView:subTabView];
}

- (void)populateOtherTalentsTab
{
   DSACharacterDocument *document = (DSACharacterDocument *)self.document;
   DSACharacterHero *model = (DSACharacterHero *)document.model;
   
   NSTabViewItem *mainTabItem = [self.tabViewMain tabViewItemAtIndex:[self.tabViewMain indexOfTabViewItemWithIdentifier:@"item 3"]];
   NSRect subTabViewFrame = mainTabItem.view ? mainTabItem.view.bounds : NSMakeRect(0, 0, 400, 300);
   NSTabView *subTabView = [[NSTabView alloc] initWithFrame:subTabViewFrame];
   [subTabView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
    
   NSMutableArray *otherTalents = [NSMutableArray array];
   NSMutableSet *talentCategories = [NSMutableSet set];
    
   // Enumerate talents to find all categories excluding "Kampftechniken"
   [model.talents enumerateKeysAndObjectsUsingBlock:^(id key, DSAOtherTalent *obj, BOOL *stop)
     {
        if (![[obj category] isEqualToString:@"Kampftechniken"])
          {
             [otherTalents addObject: obj];
             [talentCategories addObject: [obj category]];
          }
     }];
    
   // Sort the talent categories alphabetically
   NSArray *sortedTalentCategories = [[talentCategories allObjects] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
   // Sort the other talents by name
   NSSortDescriptor *nameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
   NSArray *sortedOtherTalents = [otherTalents sortedArrayUsingDescriptors:@[nameSortDescriptor]];
    
   // Iterate through sorted categories and create tabs for them
   for (NSString *category in sortedTalentCategories)
     {
        // Filter talents that belong to the current category
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(DSAOtherTalent *evaluatedObject, NSDictionary *bindings)
          {
            return [evaluatedObject.category isEqualToString:category];
          }];
        NSArray *filteredTalents = [sortedOtherTalents filteredArrayUsingPredicate:predicate];
        
        // Call the helper method to add the tab for this category
        [self addTabForCategory:category inSubTabView:subTabView withItems:filteredTalents];
     }
    
   // Set the subTabView for the current tab
   [mainTabItem setView:subTabView];
}

- (void)populateProfessionsTab
{
   DSACharacterDocument *document = (DSACharacterDocument *)self.document;
   DSACharacterHero *model = (DSACharacterHero *)document.model;
   NSLog(@"populateProfessionsTab");
    
   NSTabViewItem *mainTabItem = [self.tabViewMain tabViewItemAtIndex: [self.tabViewMain indexOfTabViewItemWithIdentifier:@"item 5"]];
  
   if ([model professions] == nil)
     {
        NSLog(@"don't have professions, not showing professions tab");
        [self.tabViewMain removeTabViewItem:mainTabItem];
        return;
     }
    
   NSRect subTabViewFrame = mainTabItem.view ? mainTabItem.view.bounds : NSMakeRect(0, 0, 400, 300);
   NSTabView *subTabView = [[NSTabView alloc] initWithFrame:subTabViewFrame];
   [subTabView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
  
   NSMutableArray *professions = [NSMutableArray array];
   NSMutableSet *categories = [NSMutableSet set];
  
   // Enumerate professions to find all categories
   [model.professions enumerateKeysAndObjectsUsingBlock:^(id key, DSAOtherTalent *obj, BOOL *stop)
     {
        [professions addObject: obj];
        [categories addObject: [obj category]];
     }];
  
   // Sort the categories alphabetically
   NSArray *sortedCategories = [[categories allObjects] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
   // Sort the professions by name
   NSSortDescriptor *nameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
   NSArray *sortedProfessions = [professions sortedArrayUsingDescriptors:@[nameSortDescriptor]];
    
   // Iterate through sorted categories and create tabs for them
   for (NSString *category in sortedCategories)
     {
        // Filter professions that belong to the current category
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(DSAOtherTalent *evaluatedObject, NSDictionary *bindings)
          {
             return [evaluatedObject.category isEqualToString:category];
          }];
        NSArray *filteredProfessions = [sortedProfessions filteredArrayUsingPredicate:predicate];
        
        // Call the helper method to add the tab for this category
        [self addTabForCategory:category inSubTabView:subTabView withItems:filteredProfessions];
     }
  
   // Set the subTabView for the current tab
   [mainTabItem setView:subTabView];
}

- (void)populateMagicTalentsTab
{
   DSACharacterDocument *document = (DSACharacterDocument *)self.document;
   DSACharacterHero *model = (DSACharacterHero *)document.model;
   NSTabViewItem *mainTabItem = [self.tabViewMain tabViewItemAtIndex: [self.tabViewMain indexOfTabViewItemWithIdentifier:@"item 4"]];
 
   if (![model conformsToProtocol:@protocol(DSACharacterMagic)] && !model.specials)
     {
        NSLog(@"not being magic, not showing magic talents tab");
        [self.tabViewMain removeTabViewItem:mainTabItem];
        return;
     }
    
   NSRect subTabViewFrame = mainTabItem.view ? mainTabItem.view.bounds : NSMakeRect(0, 0, 400, 300);
   NSTabView *subTabView = [[NSTabView alloc] initWithFrame: subTabViewFrame];  
   [subTabView setAllowsTruncatedLabels: YES];
   [subTabView setControlSize:NSControlSizeSmall];
   [subTabView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
  
   NSMutableArray *spells = [NSMutableArray array];
   NSMutableSet *categories = [NSMutableSet set];
  
   // Enumerate talents to find all categories
   [model.spells enumerateKeysAndObjectsUsingBlock:^(id key, DSAOtherTalent *obj, BOOL *stop)
     {
        [spells addObject: obj];
        [categories addObject: [obj category]];
     }];
    
   // Sort spells by name
   NSSortDescriptor *nameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
   NSArray *sortedSpells = [spells sortedArrayUsingDescriptors:@[nameSortDescriptor]];
    
   // Sort categories alphabetically
   NSArray *sortedCategories = [[categories allObjects] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
   // Containers for categories that start with "Beschwörung" and "Verwandlung"
   NSMutableArray *beschwoerungCategories = [NSMutableArray array];
   NSMutableArray *verwandlungCategories = [NSMutableArray array];
    
   // Separate categories based on naming
   for (NSString *category in sortedCategories)
     {
        if ([category hasPrefix:@"Beschwörung"] || [category isEqualToString:@"Die Sieben Formeln der Zeit"])
          {
             [beschwoerungCategories addObject:category];
          }
        else if ([category hasPrefix:@"Verwandlung"])
          {
             [verwandlungCategories addObject:category];
          }
        else
          {
             // Non-grouped categories: filter spells and add tabs
             NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(DSAOtherTalent *evaluatedObject, NSDictionary *bindings)
               {
                  return [evaluatedObject.category isEqualToString:category];
               }];
             NSArray *filteredSpells = [sortedSpells filteredArrayUsingPredicate:predicate];
             [self addTabForCategory:category inSubTabView:subTabView withItems:filteredSpells];
          }
     }
    
   // Sort "Beschwörung" and "Verwandlung" categories alphabetically
   NSArray *sortedBeschwoerungCategories = [beschwoerungCategories sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
   NSArray *sortedVerwandlungCategories = [verwandlungCategories sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

   // Create grouped tabs for "Beschwörung" and "Verwandlung"
   if (sortedBeschwoerungCategories.count > 0)
     {
        [self addGroupedTabWithTitle:@"Beschwörung" categories:sortedBeschwoerungCategories inSubTabView:subTabView withSpells:sortedSpells];
     }
    
   if (sortedVerwandlungCategories.count > 0)
     {
        [self addGroupedTabWithTitle:@"Verwandlung" categories:sortedVerwandlungCategories inSubTabView:subTabView withSpells:sortedSpells];
     }
   
   // Set the subTabView for the current tab
   [mainTabItem setView:subTabView];
}


- (void)populateSpecialTalentsTab
{
   DSACharacterDocument *document = (DSACharacterDocument *)self.document;
   DSACharacterHero *model = (DSACharacterHero *)document.model;
   NSLog(@"populateSpecialTalentsTab");
   NSTabViewItem *mainTabItem = [self.tabViewMain tabViewItemAtIndex: [self.tabViewMain indexOfTabViewItemWithIdentifier:@"item 6"]];
  
   if ([model specials] == nil)
     {
        NSLog(@"don't have special talents, not showing special talents tab");
        [self.tabViewMain removeTabViewItem:mainTabItem];
        return;
     }
      
   NSRect subTabViewFrame = mainTabItem.view ? mainTabItem.view.bounds : NSMakeRect(0, 0, 400, 300);
   NSTabView *subTabView = [[NSTabView alloc] initWithFrame:subTabViewFrame];
   [subTabView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
  
   NSMutableArray *specials = [NSMutableArray array];
   NSMutableSet *categories = [NSMutableSet set];
  
   // Enumerate special talents to find all categories
   [model.specials enumerateKeysAndObjectsUsingBlock:^(id key, DSAOtherTalent *obj, BOOL *stop)
     {
        [specials addObject: obj];
        [categories addObject: [obj category]];
     }];
    
   // Sort specials by name
   NSSortDescriptor *nameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
   NSArray *sortedSpecials = [specials sortedArrayUsingDescriptors:@[nameSortDescriptor]];
    
   // Sort categories alphabetically
   NSArray *sortedCategories = [[categories allObjects] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
  
   // Add a tab for each sorted category with the corresponding talents
   for (NSString *category in sortedCategories)
     {
        // Filter talents belonging to the current category
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(DSAOtherTalent *evaluatedObject, NSDictionary *bindings)
          {
            return [evaluatedObject.category isEqualToString:category];
          }];
        NSArray *filteredSpecials = [sortedSpecials filteredArrayUsingPredicate:predicate];
        
        // Add the filtered talents under the corresponding category
        [self addTabForCategory:category inSubTabView:subTabView withItems:filteredSpecials];
     }
  
   // Set the subTabView for the current tab
   [mainTabItem setView:subTabView];
}

- (void)populateBiographyTab
{
   DSACharacterDocument *document = (DSACharacterDocument *)self.document;
   DSACharacterHero *model = (DSACharacterHero *)document.model;
   NSLog(@"populateBiographyTab %@ %@", [model birthPlace], [model legitimation]);
   
   NSTabViewItem *mainTabItem = [self.tabViewMain tabViewItemAtIndex: [self.tabViewMain indexOfTabViewItemWithIdentifier:@"item 7"]];
   
   NSRect subTabViewFrame = mainTabItem.view ? mainTabItem.view.bounds : NSMakeRect(0, 0, 400, 300);
   NSTabView *subTabView = [[NSTabView alloc] initWithFrame:subTabViewFrame];
   [subTabView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
   
   // --- First Tab: "Geburt" ---
   NSTabViewItem *innerTabItem1 = [[NSTabViewItem alloc] initWithIdentifier:_(@"Geburt")];
   innerTabItem1.label = _(@"Geburt");
    
   NSFlippedView *innerView1 = [[NSFlippedView alloc] initWithFrame:subTabView.bounds];
   [innerView1 setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];

   // Create a single NSTextView to hold the merged text
   CGFloat margin = 10.0;
   CGFloat width = subTabView.bounds.size.width - 2 * margin;
   NSRect textViewFrame = NSMakeRect(margin, margin, width, subTabView.bounds.size.height - 2 * margin);
   NSTextView *textView1 = [[NSTextView alloc] initWithFrame:textViewFrame];
   [textView1 setEditable:NO];     // Make it non-editable
   [textView1 setVerticallyResizable:YES];
   [textView1 setHorizontallyResizable:NO];
   [textView1 setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
   [textView1 setBackgroundColor:[NSColor lightGrayColor]];

   // Format the text as a bulleted list
   NSString *bulletList1 = [NSString stringWithFormat:@"• %@\n• %@\n• %@\n• %@", 
                           [model birthPlace], 
                           [model birthEvent], 
                           [model legitimation],
                           [self siblingsStringForCharacter: model]];

   // Create paragraph style for proper indentation of bullet points
   NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
   CGFloat bulletIndent = 15.0;  // Space from the left edge for the first line
   CGFloat textIndent = 25.0;    // Space for wrapped lines
   [paragraphStyle setFirstLineHeadIndent:bulletIndent];   // First line indentation (after the bullet)
   [paragraphStyle setHeadIndent:textIndent];              // Indentation for subsequent wrapped lines

   // Optional: Set line spacing for better readability
   [paragraphStyle setLineSpacing:4.0];

   // Create an attributed string with the bullet points and paragraph style
   NSFont *font = [NSFont systemFontOfSize:12.0];  // Use a system font of size 10
   NSMutableAttributedString *attrString1 = [[NSMutableAttributedString alloc] initWithString:bulletList1];
   [attrString1 addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [attrString1 length])];
   [attrString1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attrString1 length])];

   // Set the text in the NSTextView
   [textView1.textStorage setAttributedString:attrString1];

   // Add the NSTextView to the innerView
   [innerView1 addSubview:textView1];

   // Set the innerView as the view for the inner tab item
   [innerTabItem1 setView:innerView1];
   [subTabView addTabViewItem:innerTabItem1];
   
   // --- Second Tab: "Kindheit" ---
   NSTabViewItem *innerTabItem2 = [[NSTabViewItem alloc] initWithIdentifier:_(@"Kindheit")];
   innerTabItem2.label = _(@"Kindheit");

   NSFlippedView *innerView2 = [[NSFlippedView alloc] initWithFrame:subTabView.bounds];
   [innerView2 setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
   
   // Create a text view for childhood events with the same layout
   NSTextView *textView2 = [[NSTextView alloc] initWithFrame:textViewFrame];
   [textView2 setEditable:NO];
   [textView2 setVerticallyResizable:YES];
   [textView2 setHorizontallyResizable:NO];
   [textView2 setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
   [textView2 setBackgroundColor:[NSColor lightGrayColor]];

   // Compose bulleted list for childhood events
   NSMutableString *childhoodBullets = [[NSMutableString alloc] init];
   for (NSString *event in [model childhoodEvents]) {
       [childhoodBullets appendFormat:@"• %@\n", event];
   }

   // Create an attributed string with the bullet points and paragraph style
   NSMutableAttributedString *attrString2 = [[NSMutableAttributedString alloc] initWithString:childhoodBullets];
   [attrString2 addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [attrString2 length])];
   [attrString2 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attrString2 length])];

   // Set the text in the NSTextView
   [textView2.textStorage setAttributedString:attrString2];
   
   // Add the text view to the second tab
   [innerView2 addSubview:textView2];
   [innerTabItem2 setView:innerView2];
   [subTabView addTabViewItem:innerTabItem2];
   
   // Set the subTabView for the current tab
   [mainTabItem setView:subTabView];
}


- (void)XXXYpopulateBiographyTab
{
   DSACharacterDocument *document = (DSACharacterDocument *)self.document;
   DSACharacterHero *model = (DSACharacterHero *)document.model;
   NSLog(@"populateBiographyTab %@ %@", [model birthPlace], [model legitimation]);
   
   NSTabViewItem *mainTabItem = [self.tabViewMain tabViewItemAtIndex: [self.tabViewMain indexOfTabViewItemWithIdentifier:@"item 7"]];
   
   NSRect subTabViewFrame = mainTabItem.view ? mainTabItem.view.bounds : NSMakeRect(0, 0, 400, 300);
   NSTabView *subTabView = [[NSTabView alloc] initWithFrame:subTabViewFrame];
   [subTabView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
   
   NSTabViewItem *innerTabItem = [[NSTabViewItem alloc] initWithIdentifier: _(@"Geburt")];
   innerTabItem.label = _(@"Geburt");
    
   NSFlippedView *innerView = [[NSFlippedView alloc] initWithFrame:subTabView.bounds];
   [innerView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];

   // Create a single NSTextView to hold the merged text
   CGFloat margin = 10.0;
   CGFloat width = subTabView.bounds.size.width - 2 * margin;
   NSRect textViewFrame = NSMakeRect(margin, margin, width, subTabView.bounds.size.height - 2 * margin);
   NSTextView *textView = [[NSTextView alloc] initWithFrame:textViewFrame];
   [textView setEditable:NO];     // Make it non-editable
   [textView setVerticallyResizable:YES];
   [textView setHorizontallyResizable:NO];
   [textView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
   [textView setBackgroundColor:[NSColor lightGrayColor]];

   // Format the text as a bulleted list
   NSString *bulletList = [NSString stringWithFormat:@"• %@\n• %@\n• %@\n• %@", 
                           [model birthPlace], 
                           [model birthEvent], 
                           [model legitimation],
                           [self siblingsStringForCharacter: model]];

   // Create paragraph style for proper indentation of bullet points
   NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
   CGFloat bulletIndent = 15.0;  // Space from the left edge for the first line
   CGFloat textIndent = 25.0;    // Space for wrapped lines
   [paragraphStyle setFirstLineHeadIndent:bulletIndent];   // First line indentation (after the bullet)
   [paragraphStyle setHeadIndent:textIndent];              // Indentation for subsequent wrapped lines

   // Optional: Set line spacing for better readability
   [paragraphStyle setLineSpacing:4.0];

   // Create an attributed string with the bullet points and paragraph style
   NSFont *font = [NSFont systemFontOfSize:10.0];  // Use a system font of size 14
   NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:bulletList];
   [attrString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [attrString length])];
   [attrString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attrString length])];

   // Set the text in the NSTextView
   [textView.textStorage setAttributedString:attrString];

   // Add the NSTextView to the innerView
   [innerView addSubview:textView];

   // Set the innerView as the view for the inner tab item
   [innerTabItem setView:innerView];
   [subTabView addTabViewItem:innerTabItem];
   
   // --- Second Tab: "Kindheit" ---
   NSTabViewItem *innerTabItem2 = [[NSTabViewItem alloc] initWithIdentifier:_(@"Kindheit")];
   innerTabItem2.label = _(@"Kindheit");

   NSFlippedView *innerView2 = [[NSFlippedView alloc] initWithFrame:subTabView.bounds];
   [innerView2 setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
   
   // Create a text view for childhood events with the same layout
   NSTextView *childhoodTextView = [[NSTextView alloc] initWithFrame:NSMakeRect(10, 10, width, 100)];
   [childhoodTextView setEditable:NO];
   [childhoodTextView setBackgroundColor:[NSColor lightGrayColor]];

   // Compose bulleted list for childhood events
   NSMutableString *childhoodBullets = [[NSMutableString alloc] init];
   for (NSString *event in [model childhoodEvents]) {
       [childhoodBullets appendFormat:@"• %@\n", event];
   }
   [childhoodTextView setString:childhoodBullets];
   
   // Add the childhood events text view to the second tab
   [innerView2 addSubview:childhoodTextView];
   [innerTabItem2 setView:innerView2];
   [subTabView addTabViewItem:innerTabItem2];
   
   // Set the subTabView for the current tab
   [mainTabItem setView:subTabView];
}


// helper function used above in populateBiographyTab
- (NSString *)siblingsStringForCharacter:(DSACharacter *)character
{
    NSArray *siblings = [character siblings];
    NSString *name = [character name];
    NSString *pronoun = [[character sex] isEqualToString:_(@"männlich")] ? @"Er" : @"Sie";
    NSString *genderWord = [[character sex] isEqualToString:_(@"männlich")] ? @"der" : @"die";
    
    // If no siblings, return a simple message
    if ([siblings count] == 0) {
        return [NSString stringWithFormat:@"%@ hat keine Geschwister.", name];
    }
    
    // Initialize counters for siblings
    NSInteger olderBrothers = 0;
    NSInteger youngerBrothers = 0;
    NSInteger olderSisters = 0;
    NSInteger youngerSisters = 0;
    
    // Count the number of older/younger brothers and sisters
    for (NSDictionary *sibling in siblings) {
        NSString *age = sibling[@"age"];
        NSString *sex = sibling[@"sex"];
        
        if ([age isEqualToString:_(@"älter")]) {
            if ([sex isEqualToString:_(@"männlich")]) {
                olderBrothers++;
            } else {
                olderSisters++;
            }
        } else {  // "jünger"
            if ([sex isEqualToString:_(@"männlich")]) {
                youngerBrothers++;
            } else {
                youngerSisters++;
            }
        }
    }
    
    // Total number of children in the family
    NSInteger totalChildren = [siblings count] + 1;  // +1 to include the character
    NSInteger numberOfOlderSiblings = olderBrothers + olderSisters;
    NSInteger characterPosition = totalChildren - numberOfOlderSiblings;  // Position of the character among the siblings
    // Generate a detailed sibling description
    NSMutableString *resultString = [NSMutableString stringWithFormat:@"%@ ist %@ %ldte von %ld Kindern. ", name, genderWord, (long)characterPosition, (long)totalChildren];
    
    NSMutableArray *siblingDescriptions = [NSMutableArray array];
    
    // Build the description based on the sibling counts
    if (olderBrothers > 0) {
        NSString *olderBrothersString = [NSString stringWithFormat:@"%ld ältere%@ Br%@der", (long)olderBrothers, olderBrothers > 1 ? @"" : @"n", olderBrothers > 1 ? @"ü" : @"u"];
        [siblingDescriptions addObject:olderBrothersString];
    }
    
    if (olderSisters > 0) {
        NSString *olderSistersString = [NSString stringWithFormat:@"%ld ältere Schwester%@", (long)olderSisters, olderSisters > 1 ? @"n" : @""];
        [siblingDescriptions addObject:olderSistersString];
    }
    
    if (youngerBrothers > 0) {
        NSString *youngerBrothersString = [NSString stringWithFormat:@"%ld jüngere%@ Br%@der", (long)youngerBrothers, youngerBrothers > 1 ? @"" : @"n", youngerBrothers > 1 ? @"ü" : @"u"];
        [siblingDescriptions addObject:youngerBrothersString];
    }
    
    if (youngerSisters > 0) {
        NSString *youngerSistersString = [NSString stringWithFormat:@"%ld jüngere Schwester%@", (long)youngerSisters, youngerSisters > 1 ? @"n" : @""];
        [siblingDescriptions addObject:youngerSistersString];
    }
    
    // Append the sibling description
    if ([siblingDescriptions count] > 0) {
        [resultString appendFormat:@"%@ hat %@.", pronoun, [siblingDescriptions componentsJoinedByString:@", "]];
    }
    
    return resultString;
}

- (void)XXXpopulateBiographyTab
{
   DSACharacterDocument *document = (DSACharacterDocument *)self.document;
   DSACharacterHero *model = (DSACharacterHero *)document.model;
   NSLog(@"populateBiographyTab %@ %@", [model birthPlace], [model legitimation]);
   NSTabViewItem *mainTabItem = [self.tabViewMain tabViewItemAtIndex: [self.tabViewMain indexOfTabViewItemWithIdentifier:@"item 7"]];
   
      
   NSRect subTabViewFrame = mainTabItem.view ? mainTabItem.view.bounds : NSMakeRect(0, 0, 400, 300);
   NSTabView *subTabView = [[NSTabView alloc] initWithFrame:subTabViewFrame];
   [subTabView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
  
   
   NSTabViewItem *innerTabItem = [[NSTabViewItem alloc] initWithIdentifier: _(@"Geburt")];
   innerTabItem.label = _(@"Geburt");
    
   NSFlippedView *innerView = [[NSFlippedView alloc] initWithFrame:subTabView.bounds];
   [innerView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];    
   
   NSInteger Offset = 22;
   CGFloat width = subTabView.bounds.size.width - 20;
   NSRect fieldRect = NSMakeRect(10, Offset, width, 20);
   NSTextField *itemField = [[NSTextField alloc] initWithFrame:fieldRect];
   [itemField setIdentifier:@"itemFieldBirthplace"];
   [itemField setSelectable:NO];
   [itemField setEditable:NO];
   [itemField setBordered:NO];
   [itemField setBezeled:NO];
   [itemField setBackgroundColor:[NSColor lightGrayColor]];
   [itemField setStringValue: [model birthPlace]];
   [innerView addSubview:itemField];

   Offset += 22;
   fieldRect = NSMakeRect(10, Offset, width, 20);
   itemField = [[NSTextField alloc] initWithFrame:fieldRect];
   [itemField setIdentifier:@"itemFieldBirthEvent"];
   [itemField setSelectable:NO];
   [itemField setEditable:NO];
   [itemField setBordered:NO];
   [itemField setBezeled:NO];
   [itemField setBackgroundColor:[NSColor lightGrayColor]];
   [itemField setStringValue: [model birthEvent]];
   [innerView addSubview:itemField];    
      
   Offset += 22;
   fieldRect = NSMakeRect(10, Offset, width, 20);
   itemField = [[NSTextField alloc] initWithFrame:fieldRect];
   [itemField setIdentifier:@"itemFieldLegitimation"];
   [itemField setSelectable:NO];
   [itemField setEditable:NO];
   [itemField setBordered:NO];
   [itemField setBezeled:NO];
   [itemField setBackgroundColor:[NSColor lightGrayColor]];
   [itemField setStringValue: [model legitimation]];
   [innerView addSubview:itemField];     

   [innerTabItem setView:innerView];
   [subTabView addTabViewItem:innerTabItem];   
      
   // Set the subTabView for the current tab
   [mainTabItem setView:subTabView];
}

#pragma mark - Helper Methods

// Helper method to add an individual tab for a category
- (void)addTabForCategory:(NSString *)category inSubTabView:(NSTabView *)subTabView withItems:(NSArray *)items
{
  NSLog(@"addTabForCategory %@", category);
  NSTabViewItem *innerTabItem = [[NSTabViewItem alloc] initWithIdentifier:category];
  innerTabItem.label = category;
    
  NSFlippedView *innerView = [[NSFlippedView alloc] initWithFrame:subTabView.bounds];
  [innerView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];    

  NSString *categoryToCheck = nil; // To hold the category for comparison
  NSColor *fontColor;  
  NSInteger Offset = 0;
  for (DSAOtherTalent *item in items)
    {
      // Check the class type and assign categoryToCheck accordingly
      if ([item isKindOfClass:[DSAFightingTalent class]])
        {
          DSAFightingTalent *talentItem = (DSAFightingTalent *)item;
          categoryToCheck = talentItem.subCategory; // Use subCategory for this class
          fontColor = [NSColor blackColor];          
        }
      else if ([item isKindOfClass:[DSAOtherTalent class]])
        {
          DSAOtherTalent *otherTalentItem = (DSAOtherTalent *)item;
          categoryToCheck = otherTalentItem.category; // Use category for this class
          fontColor = [NSColor blackColor];          
        }
      else if ([item isKindOfClass:[DSAProfession class]])
        {
          DSAProfession *professionItem = (DSAProfession *)item;
          categoryToCheck = professionItem.category; // Use category for this class
          fontColor = [NSColor blackColor];
        }
      else if ([item isKindOfClass:[DSASpecialTalent class]])
        {
          DSASpecialTalent *specialTalentItem = (DSASpecialTalent *)item;
          categoryToCheck = specialTalentItem.category; // Use category for this class
          fontColor = [NSColor blackColor];
        }        
      else if ([item isKindOfClass:[DSASpell class]])
        {
          DSASpell *spellItem = (DSASpell *)item;
          categoryToCheck = spellItem.category; // Use category for this class
          if ([spellItem isActiveSpell])
            {
              fontColor = [NSColor blackColor];          
            }
          else
            {
              fontColor = [NSColor redColor];
            }
        }
      else
        {
          // Handle unknown class types if necessary
          NSLog(@"Unknown item class: %@", [item class]);
          continue; // Skip unknown classes
        }
                  
      if ([categoryToCheck isEqualToString:category])
        {      
          Offset += 22;
            
          NSRect fieldRect = NSMakeRect(10, Offset, 400, 20);
          NSTextField *itemField = [[NSTextField alloc] initWithFrame:fieldRect];
          [itemField setIdentifier:[NSString stringWithFormat:@"itemField%@", item]];
          [itemField setSelectable:NO];
          [itemField setEditable:NO];
          [itemField setBordered:NO];
          [itemField setBezeled:NO];
          [itemField setBackgroundColor:[NSColor lightGrayColor]];
          if ([item isMemberOfClass: [DSAFightingTalent class]])
            {
              [itemField setStringValue:[NSString stringWithFormat:@"%@ (%@)", item.name, item.maxUpPerLevel]];
              [itemField setTextColor: fontColor];                           
            }
          else if ([item isMemberOfClass: [DSASpecialTalent class]])
            {
              if ([(DSASpecialTalent *)item test])
                {
                  [itemField setStringValue:[NSString stringWithFormat:@"%@ (%@)", item.name, [item.test componentsJoinedByString:@"/"]]];
                }
              else
                {
                  [itemField setStringValue:[NSString stringWithFormat:@"%@", item.name]];
                }
              [itemField setTextColor: fontColor];                           
            }            
          else
            {
              [itemField setStringValue:[NSString stringWithFormat:@"%@ (%@) (%@)", item.name, [item.test componentsJoinedByString:@"/"], item.maxUpPerLevel]];
              [itemField setTextColor: fontColor];
              if ([item isKindOfClass:[DSASpell class]])
                {
                  DSASpell *spellItem = (DSASpell *)item;
                  [self.spellItemFieldMap setObject: itemField forKey: [spellItem name]];
                  [spellItem addObserver: self
                              forKeyPath: @"isActiveSpell"
                                 options: NSKeyValueObservingOptionNew 
                                 context: nil];
                }
              else
                {
                  NSLog(@"item is kind of class: %@", [item class]);
                }              
            }

          NSFont *boldFont = [NSFont boldSystemFontOfSize:[NSFont systemFontSize]];
          [itemField setFont:boldFont];
          [innerView addSubview:itemField];
            
          if (![item isMemberOfClass: [DSASpecialTalent class]])
            {
              NSRect fieldValueRect = NSMakeRect(420, Offset, 20, 20);
              NSTextField *itemFieldValue = [[NSTextField alloc] initWithFrame:fieldValueRect];
              [itemFieldValue setIdentifier:[NSString stringWithFormat:@"itemFieldValue%@", item]];
              [itemFieldValue setSelectable:NO];
              [itemFieldValue setEditable:NO];
              [itemFieldValue setBordered:NO];
              [itemFieldValue setBezeled:NO];
              [itemFieldValue setBackgroundColor:[NSColor lightGrayColor]];
              [itemFieldValue setStringValue:[item.level stringValue]];
              [itemFieldValue bind:NSValueBinding  
                          toObject:item
                       withKeyPath:@"level" 
                           options:@{NSContinuouslyUpdatesValueBindingOption: @YES, 
                                         NSValueTransformerNameBindingOption: @"RightAlignedStringTransformer"}];
              NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
              [paragraphStyle setAlignment:NSTextAlignmentRight];
              NSDictionary *attributes = @{NSParagraphStyleAttributeName: paragraphStyle};
              [itemFieldValue setAttributedStringValue:[[NSAttributedString alloc] initWithString:[item.level stringValue] attributes:attributes]];
              [innerView addSubview:itemFieldValue];
            }
        }
    }
  [innerTabItem setView:innerView];
  [subTabView addTabViewItem:innerTabItem];
}


// Helper method to add a grouped tab for categories that start with "Beschwörung" or "Verwandlung"
- (void)addGroupedTabWithTitle:(NSString *)title categories:(NSArray *)categories inSubTabView:(NSTabView *)subTabView withSpells:(NSArray *)spells
{
    NSTabViewItem *groupTabItem = [[NSTabViewItem alloc] initWithIdentifier:title];
    groupTabItem.label = title;
    
    NSRect groupedTabFrame = subTabView.bounds;
    NSTabView *groupedSubTabView = [[NSTabView alloc] initWithFrame:groupedTabFrame];
    [groupedSubTabView setAllowsTruncatedLabels:YES];
    [groupedSubTabView setControlSize:NSControlSizeSmall];
    [groupedSubTabView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
    
    // Add individual tabs for each sub-category inside the grouped tab
    for (NSString *category in categories)
    {
        [self addTabForCategory:category inSubTabView:groupedSubTabView withItems:spells];
    }
    
    // Set the grouped sub-tab view as the view for the groupTabItem
    [groupTabItem setView:groupedSubTabView];
    [subTabView addTabViewItem:groupTabItem];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
  DSACharacterDocument *document = (DSACharacterDocument *)self.document;
  DSACharacterHero *model = (DSACharacterHero *)document.model;    
  // Get the action (selector) associated with the menu item
  SEL menuItemAction = [menuItem action];
    
  if (menuItemAction)
    {

    }
    
    // Default validation behavior
    return YES;
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
  else if ([keyPath isEqualToString:@"isActiveSpell"])
    {
      DSASpell *spellItem = (DSASpell *)object;
      NSLog(@"spellItem in observeValueForKeyPath: %@", spellItem);  
      // Get the associated itemField using the spellItem
      NSTextField *itemField = [self.spellItemFieldMap objectForKey:[spellItem name]];
      if (itemField)
        {
          BOOL isActive = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
            
          if (isActive)
            {
              [itemField setTextColor:[NSColor blackColor]];  // Active spell color
            }
          else
            {
              [itemField setTextColor:[NSColor redColor]];    // Inactive spell color
            }
        }
      else
        {
          NSLog(@"Could not find associated itemField for spellItem: %@", spellItem.name);
        }
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
  DSACharacterHero *model = (DSACharacterHero *)document.model;
  if (!self.congratsPanel)
    {
      // Load the panel from the separate .gorm file
      [NSBundle loadNibNamed:@"DSACharacterLevelUp" owner:self];
    }
  // Set the font size of the fieldCongratsHeadline
  NSFont *currentFont = [self.fieldCongratsHeadline font];
  NSFont *biggerFont = [[NSFontManager sharedFontManager] convertFont:currentFont toSize:20.0]; // Set size to 20
  [self.fieldCongratsHeadline setFont:biggerFont];    
  [self.fieldCongratsMainText setStringValue: [NSString stringWithFormat: @"%@ hat soeben eine neue Stufe erreicht.", model.name]];
  [self.fieldCongratsMainTextLine2 setStringValue: _(@"Möchtest du jetzt steigern, oder später?")];
  [self.congratsPanel makeKeyAndOrderFront:nil];

  [self.buttonCongratsLater setHidden:NO];
  [self.buttonCongratsNow setTarget:self];
  [self.buttonCongratsNow setTitle: _(@"Jetzt")];
  [self.buttonCongratsNow setAction:@selector(levelUpBaseValues:)]; 
}

- (void)levelUpBaseValues:(id)sender
{
  DSACharacterDocument *document = (DSACharacterDocument *)self.document;
  DSACharacterHero *model = (DSACharacterHero *)document.model;
  // we may jump in here from the main menu
  if (!self.congratsPanel)
    {
      // Load the panel from the separate .gorm file
      [NSBundle loadNibNamed:@"DSACharacterLevelUp" owner:self];
    }
    
  // yes, we want to start that process NOW
  [model prepareLevelUp];
  [document updateChangeCount:NSChangeDone];
  
  // we don't need the congrats panel for now
  [self.congratsPanel close];
  
  // At initial character creation, we jump over raising base value
  // at all other levels, we do so...
  if ([model.level integerValue] == 0)
    {
      NSLog(@"going to call showLevelUpPositiveTraits!");
      [self showLevelUpPositiveTraits:nil];
      return;
    }  
   
  NSLog(@"Leveling up base energies and points...");
 
  NSDictionary *result = [model levelUpBaseEnergies];
  
  if ([result objectForKey: @"deltaLpAe"])
    {
      // we have a character that uses a single dice to roll LP and AE
      // and the user to decide, how to distribute it...
      [self showQuestionRegardingPointsDistribution: result];
      return;
    }
  
  NSString *resultingText = [[NSString alloc] init];
  
  if ([model isMagic])
    {
      resultingText = [NSString stringWithFormat: 
                       @"%@ hat die Lebensenergie um %@ und die Astralenergie um %@ gesteigert", 
                       model.name,
                       [result objectForKey: @"deltaLifePoints"], 
                       [result objectForKey: @"deltaAstralEnergy"]];
    }
  else if ([model isBlessedOne])
    {
      resultingText = [NSString stringWithFormat: 
                       @"%@ hat die Lebensenergie um %@ und die Karmaenergie um %@ gesteigert", 
                       model.name,
                       [result objectForKey: @"deltaLifePoints"], 
                       [result objectForKey: @"deltaKarmaPoints"]];    
    }
  else
    {
      resultingText = [NSString stringWithFormat: 
                       @"%@ hat die Lebensenergie um %@ gesteigert", 
                       model.name,
                       [result objectForKey: @"deltaLifePoints"]];    
    }
  [self.fieldCongratsMainTextLine2 setStringValue: resultingText];
  [self.buttonCongratsLater setHidden:YES];    

  [self.buttonCongratsNow setTarget:self];
  [self.buttonCongratsNow setAction:@selector(showLevelUpPositiveTraits:)];
  [self.buttonLevelUpDoIt setTitle: _(@"Weiter")];
  [self.congratsPanel makeKeyAndOrderFront:nil]; 
}

- (IBAction)showQuestionRegardingPointsDistribution:(id)sender
{
  DSACharacterDocument *document = (DSACharacterDocument *)self.document;
  DSACharacterHero *model = (DSACharacterHero *)document.model;

  if (!self.levelUpPanel)
    {
      // Load the panel from the separate .gorm file
      NSLog(@"showLevelUpPositiveTraits loading DSACharacterLevelUp.gorm");
      [NSBundle loadNibNamed:@"DSACharacterLevelUp" owner:self];
    }
  // Set the font size of the fieldCongratsHeadline
  NSFont *currentFont = [self.fieldLevelUpHeadline font];
  NSFont *biggerFont = [[NSFontManager sharedFontManager] convertFont:currentFont toSize:20.0]; // Set size to 20
  [self.fieldLevelUpHeadline setFont:biggerFont];    
  [self.fieldLevelUpHeadline setStringValue: @"Lebenspunkte und Astralenergie verteilen"];
  [self.fieldLevelUpHeadline.cell setLineBreakMode:NSLineBreakByWordWrapping];
  [self.fieldLevelUpHeadline.cell setUsesSingleLineMode:NO];
  NSLog(@"checking if sender is NSDictionary: %@", [sender class]);
  if ([sender isKindOfClass: [NSDictionary class]])
    {
        NSLog(@"sender is NSDictionary: %@", sender);
      if ([[(NSDictionary *)sender allKeys] containsObject: @"deltaLifePoints"] && [[(NSDictionary *)sender objectForKey: @"deltaLifePoints"] integerValue] > 0)
        {
          [self.fieldLevelUpMainText setStringValue: 
                       [NSString stringWithFormat: _(@"%@ hat %@ Lebenspunkte erhalten und kann weitere %@ Punkte auf Lebenspunkte und Astralenergie verteilen. Wieviele davon sollen auf Lebenspunkte verwendet werden?"),
                       model.name, [(NSDictionary *)sender objectForKey: @"deltaLifePoints"], model.tempDeltaLpAe ]];        
        }
      else
        {
          [self.fieldLevelUpMainText setStringValue: 
                           [NSString stringWithFormat: _(@"%@ kann %@ Punkte auf Lebenspunkte und Astralenergie verteilen. Wieviele davon sollen auf Lebenspunkte verwendet werden?"),
                           model.name, model.tempDeltaLpAe ]];        
        }
    }
  else
    {
      [self.fieldLevelUpMainText setStringValue: 
                       [NSString stringWithFormat: _(@"%@ kann %@ Punkte auf Lebenspunkte und Astralenergie verteilen. Wieviele davon sollen auf Lebenspunkte verwendet werden?"),
                       model.name, model.tempDeltaLpAe ]];
     }
  [self.popupLevelUpTop removeAllItems];                       
  for (NSInteger i = 0; i <= [model.tempDeltaLpAe integerValue]; i++)
    {
      [self.popupLevelUpTop addItemWithTitle: [NSString stringWithFormat: @"%li", i]];
    }
  [self.popupLevelUpTop setEnabled: YES];                        

  [self.popupLevelUpBottom setHidden: YES];  
  [self.fieldLevelUpFeedback setHidden: YES];
  [self.fieldLevelUpTrialsCounter setHidden: YES];  
  [self.buttonLevelUpDoIt setTarget:self];
  [self.buttonLevelUpDoIt setAction:@selector(distributeLpAe:)]; 
  [self.buttonLevelUpDoIt setTitle: _(@"Auswählen")];  
  [self.levelUpPanel makeKeyAndOrderFront:nil];  
}

- (IBAction) distributeLpAe:(id)sender
{
  DSACharacterDocument *document = (DSACharacterDocument *)self.document;
  DSACharacterHero *model = (DSACharacterHero *)document.model;
  
  model.lifePoints = [NSNumber numberWithInteger: [model.lifePoints integerValue] + [self.popupLevelUpTop integerValue]];
  model.currentLifePoints = [NSNumber numberWithInteger: [model.currentLifePoints integerValue] + [self.popupLevelUpTop integerValue]];
  model.astralEnergy = [NSNumber numberWithInteger: [model.astralEnergy integerValue] + [model.tempDeltaLpAe integerValue] - [self.popupLevelUpTop integerValue]];
  model.currentAstralEnergy = [NSNumber numberWithInteger: [model.currentAstralEnergy integerValue] + [model.tempDeltaLpAe integerValue] - [self.popupLevelUpTop integerValue]];
  model.tempDeltaLpAe = @0;
  
  [self showLevelUpPositiveTraits: nil];
  
}

// Action when the "Level Up" menu item is clicked
- (IBAction)showLevelUpPositiveTraits:(id)sender
{
  NSLog(@"showLevelUpPositiveTraits called");
  if (!self.levelUpPanel)
    {
      // Load the panel from the separate .gorm file
      NSLog(@"showLevelUpPositiveTraits loading DSACharacterLevelUp.gorm");
      [NSBundle loadNibNamed:@"DSACharacterLevelUp" owner:self];
    }
  // Set the font size of the fieldCongratsHeadline
  NSFont *currentFont = [self.fieldLevelUpHeadline font];
  NSFont *biggerFont = [[NSFontManager sharedFontManager] convertFont:currentFont toSize:20.0]; // Set size to 20
  [self.fieldLevelUpHeadline setFont:biggerFont];
  [self.fieldLevelUpHeadline setStringValue: _(@"Positive Eigenschaft erhöhen")];
  [self.fieldLevelUpMainText setStringValue: _(@"Eigenschaft auswählen")];
 
  [self.popupLevelUpTop setEnabled: YES];
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
  [self.congratsPanel close];
  //[[sender window] close];
}

- (void)levelUpPositiveTraits:(id)sender {
    NSLog(@"Leveling up positive traits...");
    // Your logic to handle leveling up positive traits goes here
    
    DSACharacterDocument *document = (DSACharacterDocument *)self.document;
    DSACharacterHero *model = (DSACharacterHero *)document.model;
    
    //[model levelUpBaseEnergies]; Hell, why was this in here???
    
    NSString *selectedTrait = [[self.popupLevelUpTop selectedItem] title];

    [self.popupLevelUpTop setEnabled: NO];
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
 
  [self.popupLevelUpTop setEnabled: YES];
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
  [self.levelUpPanel makeKeyAndOrderFront:nil];                         
}


- (void)levelDownNegativeTraits:(id)sender {
    NSLog(@"Leveling down negative traits...");
    // Your logic to handle leveling up positive traits goes here
    
    DSACharacterDocument *document = (DSACharacterDocument *)self.document;
    DSACharacterHero *model = (DSACharacterHero *)document.model;
    NSString *selectedTrait = [[self.popupLevelUpTop selectedItem] title];

    [self.popupLevelUpTop setEnabled: NO];
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
  [self.buttonLevelUpDoIt setAction:@selector(showQuestionRegardingVariableTries:)]; 
  [self.buttonLevelUpDoIt setTitle: _(@"Weiter")];      
}

- (IBAction)showQuestionRegardingVariableTries:(id)sender
{
  DSACharacterDocument *document = (DSACharacterDocument *)self.document;
  DSACharacterHero *model = (DSACharacterHero *)document.model;
  if ([model.maxLevelUpVariableTries integerValue] == 0)
    {
    
      NSLog(@"DSACharacterWindowController showQuestionRegardingVariableTries maxLevelUpVariableTries WAS 0");
    
      // nothing to ask, just copy over the values
      // but there might be archetypes out there, that may have a penalty on first level up talent tries, i.e. warrior
      if ([model.firstLevelUpTalentTriesPenalty integerValue] != 0)
        {
          model.maxLevelUpTalentsTriesTmp = [NSNumber numberWithInteger: [model.maxLevelUpTalentsTries integerValue] + [model.firstLevelUpTalentTriesPenalty integerValue]];
          model.firstLevelUpTalentTriesPenalty = @0;
        }
      else
        {
          model. maxLevelUpTalentsTriesTmp = [model. maxLevelUpTalentsTries copy];
        }
      model.maxLevelUpSpellsTriesTmp = [model.maxLevelUpSpellsTries copy];
      [self showLevelUpTalents: nil];
      return;
    }
  else
    {
      NSLog(@"DSACharacterWindowController showQuestionRegardingVariableTries maxLevelUpVariableTries WAS NOT 0");    
      [self.fieldLevelUpHeadline setStringValue: @"Steigerungsversuche verteilen"];
//      [self.fieldLevelUpMainText setAllowsMultipleLines: YES];      
      [self.fieldLevelUpHeadline.cell setLineBreakMode:NSLineBreakByWordWrapping];
      [self.fieldLevelUpHeadline.cell setUsesSingleLineMode:NO];
      [self.fieldLevelUpMainText setStringValue: 
                       [NSString stringWithFormat: @"%@ kann %@ Steigerungsversuche auf Talent oder Zaubersteigerungen verteilen. Wieviele davon sollen auf Talente verwendet werden?",
                       model.name, model.maxLevelUpVariableTries ]];
      [self.popupLevelUpTop removeAllItems];                       
      for (NSInteger i = 0; i <= [model.maxLevelUpVariableTries integerValue]; i++)
        {
          [self.popupLevelUpTop addItemWithTitle: [NSString stringWithFormat: @"%li", i]];
        }
      [self.popupLevelUpTop setEnabled: YES];                        
    }
  [self.popupLevelUpBottom setHidden: YES];  
  [self.fieldLevelUpFeedback setHidden: YES];
  [self.fieldLevelUpTrialsCounter setHidden: YES];  
  [self.buttonLevelUpDoIt setTarget:self];
  [self.buttonLevelUpDoIt setAction:@selector(distributeTalentTries:)]; 
  [self.buttonLevelUpDoIt setTitle: _(@"Auswählen")];  
  [self.levelUpPanel makeKeyAndOrderFront:nil];  
}

- (IBAction)distributeTalentTries:(id)sender
{
  DSACharacterDocument *document = (DSACharacterDocument *)self.document;
  DSACharacterHero *model = (DSACharacterHero *)document.model;
  
  model.maxLevelUpTalentsTriesTmp = [NSNumber numberWithInteger: 
                                        [model.maxLevelUpTalentsTries integerValue] + 
                                        [[[self.popupLevelUpTop selectedItem] title] integerValue]];
  model.maxLevelUpSpellsTriesTmp = [NSNumber numberWithInteger:  
                                        [model.maxLevelUpSpellsTries integerValue] +
                                        [model.maxLevelUpVariableTries integerValue] -
                                        [[[self.popupLevelUpTop selectedItem] title] integerValue]];
  [self showLevelUpTalents: nil];
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
    NSFont *currentFont = [self.fieldLevelUpHeadline font];
    NSFont *biggerFont = [[NSFontManager sharedFontManager] convertFont:currentFont toSize:20.0]; // Set size to 20
    [self.fieldLevelUpHeadline setFont:biggerFont];
    [self.fieldLevelUpHeadline setStringValue: _(@"Talente steigern")];
    [self.fieldLevelUpMainText setStringValue: _(@"Talent auswählen")];

    // Collect talent and spell categories
    NSMutableSet *talentCategories = [NSMutableSet set];
    NSMutableSet *spellCategories = [NSMutableSet set];  // For magical dabblers

    // Enumerate talents to find all categories
    [model.talents enumerateKeysAndObjectsUsingBlock:^(id key, DSAOtherTalent *obj, BOOL *stop) {
        [talentCategories addObject: [obj category]];
    }];

    // Enumerate spells to find all categories
    [model.spells enumerateKeysAndObjectsUsingBlock:^(id key, DSASpell *obj, BOOL *stop) {
        [spellCategories addObject: [obj category]];
    }];

    // Sort talentCategories and spellCategories alphabetically
    NSArray *sortedTalentCategories = [[talentCategories allObjects] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *sortedSpellCategories = [[spellCategories allObjects] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

    // Configure the popup menu
    [self.popupLevelUpTop setEnabled: YES];
    [self.popupLevelUpTop removeAllItems];
    
    // Add sorted talent categories
    [self.popupLevelUpTop addItemsWithTitles: sortedTalentCategories];
    
    // Add sorted spell categories (if any)
    if (sortedSpellCategories.count > 0 && [model isMagicalDabbler])
    {
        [self.popupLevelUpTop addItemsWithTitles: sortedSpellCategories];
    }

    // Set action for the popup
    [self.popupLevelUpTop setTarget:self];
    [self.popupLevelUpTop setAction:@selector(populateLevelUpBottomPopupWithTalents:)];

    [self.popupLevelUpBottom setHidden: NO];
    [self.popupLevelUpBottom setEnabled: YES];
    [self.popupLevelUpBottom setAutoenablesItems: NO];
    
    // Populate the bottom popup
    [self populateLevelUpBottomPopupWithTalents: nil];

    // Other UI configurations
    [self.fieldLevelUpFeedback setHidden: YES];
    [self.fieldLevelUpTrialsCounter setHidden: NO];
    [self.fieldLevelUpTrialsCounter setStringValue: [NSString stringWithFormat: @"Verbleibende Versuche: %@", model.maxLevelUpTalentsTriesTmp]];

    [self.buttonLevelUpDoIt setTarget:self];
    [self.buttonLevelUpDoIt setAction:@selector(levelUpTalent:)];
    [self.buttonLevelUpDoIt setTitle: _(@"Steigern")];
  
    [self.levelUpPanel makeKeyAndOrderFront:nil];
}

- (void)populateLevelUpBottomPopupWithTalents:(id)sender
{
    NSLog(@"populateLevelUpBottomPopupWithTalents called");
    DSACharacterDocument *document = (DSACharacterDocument *)self.document;
    DSACharacterHero *model = (DSACharacterHero *)document.model;  
    NSString *talentCategory = [[self.popupLevelUpTop selectedItem] title];
    
    // Store the previously selected item
    NSString *selectedItemTitle = [[self.popupLevelUpBottom selectedItem] title];
    
    // Remove all current items
    [self.popupLevelUpBottom removeAllItems];
    
    // Create arrays to hold sorted talents and spells
    NSMutableArray *sortedTalents = [NSMutableArray array];
    NSMutableArray *sortedSpells = [NSMutableArray array];
    
    // Collect talents in the given category
    [model.talents enumerateKeysAndObjectsUsingBlock:^(id key, DSAOtherTalent *obj, BOOL *stop) {
        if ([[obj category] isEqualTo: talentCategory]) {
            [sortedTalents addObject: obj];
        }
    }];
    
    // Collect spells in the given category (for magical dabblers)
    [model.spells enumerateKeysAndObjectsUsingBlock:^(id key, DSASpell *obj, BOOL *stop) {
        if ([[obj category] isEqualTo: talentCategory]) {
            [sortedSpells addObject: obj];
        }
    }];
    
    // Sort talents and spells alphabetically by their name
    NSArray *sortedTalentNames = [sortedTalents sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]];
    NSArray *sortedSpellNames = [sortedSpells sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]];
    
    // Add sorted talents to the popup
    for (DSAOtherTalent *talent in sortedTalentNames) {
        [self.popupLevelUpBottom addItemWithTitle:[talent name]];
        if ([model canLevelUpTalent:[model.talents objectForKey:[talent name]]]) {
            [[self.popupLevelUpBottom itemWithTitle:[talent name]] setEnabled:YES];
        } else {
            [[self.popupLevelUpBottom itemWithTitle:[talent name]] setEnabled:NO];
        }
    }
    
    // Add sorted spells to the popup (if applicable)
    for (DSASpell *spell in sortedSpellNames) {
        [self.popupLevelUpBottom addItemWithTitle:[spell name]];
        if ([model canLevelUpTalent:[model.spells objectForKey:[spell name]]]) {
            [[self.popupLevelUpBottom itemWithTitle:[spell name]] setEnabled:YES];
        } else {
            [[self.popupLevelUpBottom itemWithTitle:[spell name]] setEnabled:NO];
        }
    }
    
    // Try to re-select the previously selected item
    [self.popupLevelUpBottom selectItemWithTitle:selectedItemTitle];
    
    // If the selected item is disabled, select the first enabled item
    if (![[self.popupLevelUpBottom selectedItem] isEnabled]) {
        for (NSInteger i = 0; i < [self.popupLevelUpBottom numberOfItems]; i++) {
            if ([[self.popupLevelUpBottom itemAtIndex:i] isEnabled]) {
                [self.popupLevelUpBottom selectItemAtIndex:i];
                break;
            }
        }
    }
    
    // Update the popup button's display
    [self.popupLevelUpBottom setNeedsDisplay:YES];    
}

- (void)levelUpTalent:(id)sender
{
  DSACharacterDocument *document = (DSACharacterDocument *)self.document;
  DSACharacterHero *model = (DSACharacterHero *)document.model;
  BOOL result = NO;
  
  if ([[model.talents allKeys] containsObject: [[self.popupLevelUpBottom selectedItem] title]])
    {
      result = [model levelUpTalent: [model.talents objectForKey: [[self.popupLevelUpBottom selectedItem] title]]];
    }
  else
    { // special case the magical dabbler here, spells are considered as talents
      result = [model levelUpTalent: [model.spells objectForKey: [[self.popupLevelUpBottom selectedItem] title]]];    
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
  [self.fieldLevelUpTrialsCounter setStringValue: [NSString stringWithFormat: @"Verbleibende Versuche: %@", model.maxLevelUpTalentsTriesTmp]];
  [self populateLevelUpBottomPopupWithTalents: nil];
  if ([model.maxLevelUpTalentsTriesTmp integerValue] == 0)
    {
      [self.popupLevelUpTop setEnabled: NO];
      [self.popupLevelUpBottom setEnabled: NO];
      [self.buttonLevelUpDoIt setTarget:self];
      if ([model conformsToProtocol:@protocol(DSACharacterMagic)])
        {
          [self.buttonLevelUpDoIt setTitle: _(@"Weiter")]; 
          [self.buttonLevelUpDoIt setAction:@selector(showLevelUpSpells:)];  
        }
      else
        {
          [self.buttonLevelUpDoIt setTitle: _(@"Fertig")];
          [self.buttonLevelUpDoIt setAction:@selector(finishLevelUp:)];
        }
    }
}

- (IBAction)showLevelUpSpells:(id)sender
{
    NSLog(@"showLevelUpSpells called");
    DSACharacterDocument *document = (DSACharacterDocument *)self.document;
    DSACharacterHero *model = (DSACharacterHero *)document.model;  
    
    if (![model conformsToProtocol:@protocol(DSACharacterMagic)])
    {
        [self finishLevelUp:self];
        return;
    }

    if (!self.levelUpPanel)
    {
        // Load the panel from the separate .gorm file
        [NSBundle loadNibNamed:@"DSACharacterLevelUp" owner:self];
    }

    // Set the font size of the fieldCongratsHeadline
    NSFont *currentFont = [self.fieldLevelUpHeadline font];
    NSFont *biggerFont = [[NSFontManager sharedFontManager] convertFont:currentFont toSize:20.0]; // Set size to 20
    [self.fieldLevelUpHeadline setFont:biggerFont];
    [self.fieldLevelUpHeadline setStringValue: _(@"Zauberfertigkeiten steigern")];
    [self.fieldLevelUpMainText setStringValue: _(@"Spruch auswählen")];

    // Collect spell categories
    NSMutableSet *spellCategories = [NSMutableSet set];
    
    // Enumerate spells to find all categories
    [model.spells enumerateKeysAndObjectsUsingBlock:^(id key, DSASpell *obj, BOOL *stop) {
        [spellCategories addObject: [obj category]];
    }];  

    // Sort spellCategories alphabetically
    NSArray *sortedSpellCategories = [[spellCategories allObjects] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

    // Configure the popup menu with sorted spell categories
    [self.popupLevelUpTop setEnabled:YES];
    [self.popupLevelUpTop removeAllItems];
    [self.popupLevelUpTop addItemsWithTitles:sortedSpellCategories];
    [self.popupLevelUpTop setTarget:self];
    [self.popupLevelUpTop setAction:@selector(populateLevelUpBottomPopupWithSpells:)];

    [self.popupLevelUpBottom setHidden:NO];
    [self.popupLevelUpBottom setEnabled:YES];
    [self.popupLevelUpBottom setAutoenablesItems:NO];
    [self populateLevelUpBottomPopupWithSpells:nil];

    // Other UI configurations
    [self.fieldLevelUpFeedback setHidden:YES];
    [self.fieldLevelUpTrialsCounter setHidden:NO];
    [self.fieldLevelUpTrialsCounter setStringValue:[NSString stringWithFormat:@"Verbleibende Versuche: %@", model.maxLevelUpSpellsTriesTmp]];

    [self.buttonLevelUpDoIt setTarget:self];
    [self.buttonLevelUpDoIt setAction:@selector(levelUpSpell:)];
    [self.buttonLevelUpDoIt setTitle:_(@"Steigern")];

    [self.levelUpPanel makeKeyAndOrderFront:nil];
}

- (void)populateLevelUpBottomPopupWithSpells:(id)sender
{
    NSLog(@"populateLevelUpBottomPopupWithSpells called");
    DSACharacterDocument *document = (DSACharacterDocument *)self.document;
    DSACharacterHero *model = (DSACharacterHero *)document.model;
    NSString *spellCategory = [[self.popupLevelUpTop selectedItem] title];
    
    // Store the previously selected item
    NSString *selectedItemTitle = [[self.popupLevelUpBottom selectedItem] title];
    
    // Remove all current items
    [self.popupLevelUpBottom removeAllItems];
    
    // Create an array to hold sorted spells
    NSMutableArray *spells = [NSMutableArray array];
    
    // Collect spells that match the selected category
    [model.spells enumerateKeysAndObjectsUsingBlock:^(id key, DSASpell *obj, BOOL *stop) {
        if ([[obj category] isEqualTo: spellCategory]) {
            [spells addObject: obj];
        }
    }];
    
    // Sort the spells alphabetically by their name
    NSArray *sortedSpells = [spells sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]];
    
    // Add sorted spells to the popup
    for (DSASpell *spell in sortedSpells) {
        [self.popupLevelUpBottom addItemWithTitle:[spell name]];
        SEL canLevelUpSpell = @selector(canLevelUpSpell:);
        if ([model respondsToSelector: canLevelUpSpell]) {
            BOOL (*func)(id, SEL, DSASpell *) = (void *)objc_msgSend;
            if (func(model, canLevelUpSpell, [model.spells objectForKey:[spell name]])) {
                [[self.popupLevelUpBottom itemWithTitle:[spell name]] setEnabled:YES];
            } else {
                [[self.popupLevelUpBottom itemWithTitle:[spell name]] setEnabled:NO];
            }
        }
    }
    
    // Try to re-select the previously selected item
    [self.popupLevelUpBottom selectItemWithTitle:selectedItemTitle];
    
    // If the selected item is disabled, select the first enabled item
    if (![[self.popupLevelUpBottom selectedItem] isEnabled]) {
        for (NSInteger i = 0; i < [self.popupLevelUpBottom numberOfItems]; i++) {
            if ([[self.popupLevelUpBottom itemAtIndex:i] isEnabled]) {
                [self.popupLevelUpBottom selectItemAtIndex:i];
                break;
            }
        }
    }
    
    // Update the popup button's display
    [self.popupLevelUpBottom setNeedsDisplay:YES];
}

- (void)levelUpSpell:(id)sender
{
  DSACharacterDocument *document = (DSACharacterDocument *)self.document;
  DSACharacterHero *model = (DSACharacterHero *)document.model;
  BOOL result;
  
  SEL levelUpSpell = @selector(levelUpSpell:);
  
  if ([model respondsToSelector: levelUpSpell])
    {
      BOOL (*func)(id, SEL, DSASpell *) = (void *)objc_msgSend;
      result = func(model, levelUpSpell, [model.spells objectForKey: [[self.popupLevelUpBottom selectedItem] title]]);
//      result = [model levelUpSpell: [model.spells objectForKey: [[self.popupLevelUpBottom selectedItem] title]]];      
    }
  else
    {
      NSLog(@"DSACharacterDocument: levelUpSpell : The target character doesn't support: levelUpSpell?");
      result = NO;
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
  [self.fieldLevelUpTrialsCounter setStringValue: [NSString stringWithFormat: @"Verbleibende Versuche: %@", model.maxLevelUpSpellsTriesTmp]];
  [self populateLevelUpBottomPopupWithSpells: nil];
  if ([model.maxLevelUpSpellsTriesTmp integerValue] == 0)
    {
      [self.popupLevelUpTop setEnabled: NO];
      [self.popupLevelUpBottom setEnabled: NO];
      [self.buttonLevelUpDoIt setTarget:self];
      [self.buttonLevelUpDoIt setTitle: _(@"Fertig")];
      [self.buttonLevelUpDoIt setAction:@selector(finishLevelUp:)];
    }
}

- (IBAction)finishLevelUp: (id)sender
{
  DSACharacterDocument *document = (DSACharacterDocument *)self.document;
  DSACharacterHero *model = (DSACharacterHero *)document.model;
  
  [model finishLevelUp];
  [self.levelUpPanel close];
}

-(IBAction)manageMoney: (id)sender
{
  NSLog(@"DSACharacterWindowController manageMoney called!");
}

-(IBAction)useTalent: (id)sender
{
  NSLog(@"DSACharacterWindowController useTalent called!");
}

-(void)addAdventurePoints: (id)sender
{
  NSLog(@"DSACharacterWindowController addAdventurePoints called!");
  
  if (!self.adventurePointsPanel)
    {
      // Load the panel from the separate .gorm file
      [NSBundle loadNibNamed:@"DSAAdventurePoints" owner:self];
    }
  [self.fieldAdditionalAdventurePoints setBackgroundColor: [NSColor whiteColor]];
  [self.fieldAdditionalAdventurePoints setStringValue: @""];  
  [self.adventurePointsPanel makeKeyAndOrderFront:nil];  
}

-(IBAction)verifyAndFinishAddAdventurePoints: (id)sender
{
  NSLog(@"DSACharacterWindowController verifyAndFinishAddAdventurePoints called!");
  DSACharacterDocument *document = (DSACharacterDocument *)self.document;
  DSACharacterHero *model = (DSACharacterHero *)document.model;  

  NSString *inputString = [self.fieldAdditionalAdventurePoints stringValue];

  // Trim any spaces or newlines
  inputString = [inputString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  // Use NSScanner to validate if the input is a valid integer
  NSScanner *scanner = [NSScanner scannerWithString:inputString];
  int inputValue;
  BOOL isNumeric = [scanner scanInt:&inputValue] && [scanner isAtEnd];

  if (isNumeric && inputValue > 0)
    {
      NSLog(@"Input is a positive integer.");
      // You can proceed with the value, as it is a valid positive integer
      model.adventurePoints = [NSNumber numberWithInteger: [model.adventurePoints integerValue] + [inputString integerValue]];
      [document updateChangeCount: NSChangeDone];
      [self.adventurePointsPanel close];
    }
  else
    {
      NSLog(@"Input is not a positive integer.");
      // Handle the error (e.g., show a warning to the user)
      [self.fieldAdditionalAdventurePoints setBackgroundColor: [NSColor redColor]];
    }
  
}

- (void)closePanel:(id)sender {

    [[sender window] close];
}


@end
