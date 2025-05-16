/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-04-13 21:06:14 +0200 by sebastia

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

#import "DSANPCGenerationController.h"
#import "Utils.h"
#import "DSANameGenerator.h"
#import "DSATrait.h"
#import "DSAInventoryManager.h"
#import "DSACharacterGenerator.h"

@implementation DSANPCGenerationController

- (instancetype)init
{
  self = [super initWithWindowNibName:@"DSANPCGenerator"];
  if (self)
    {
      self.generatedNpc = [[DSACharacter alloc] init];
                                                                                                                                    
    }
  return self;
}


- (void)startNpcGeneration: (id)sender
{
  [self windowDidLoad];
  [self showWindow:self];
  [[self window] makeKeyAndOrderFront: self];
  [self.popupCategories removeAllItems];
  [self.popupCategories addItemWithTitle: _(@"Kategorie wählen")];
  [self.popupCategories addItemsWithTitles: [Utils getAllNpcTypesCategories]];
   
  [self.popupTypes removeAllItems];
  [self.popupTypes addItemWithTitle: _(@"Typus wählen")];

  [self.popupSubtypes removeAllItems];
  [self.popupSubtypes addItemWithTitle: _(@"Subtypus wählen")];  

  [self.popupOrigins removeAllItems];
  [self.popupOrigins addItemWithTitle: _(@"Herkunft wählen")];
    
  [self.popupLevel removeAllItems];
  [self.popupLevel addItemWithTitle: _(@"Erfahrungsstufe wählen")];
  
  [self.popupCount removeAllItems];
  [self.popupCount addItemWithTitle: _(@"1")];  
//  [self.popupCount addItemWithTitle: _(@"2")];
//  [self.popupCount addItemWithTitle: _(@"3")];
   
  [self.popupTypes setEnabled: NO];   
  [self.popupTypes setAutoenablesItems: NO];
  [self.popupSubtypes setEnabled: NO];   
  [self.popupSubtypes setAutoenablesItems: NO];
  [self.popupOrigins setEnabled: NO];   
  [self.popupOrigins setAutoenablesItems: NO];    
  [self.popupLevel setEnabled: NO];   
  [self.popupLevel setAutoenablesItems: NO];      
  [self.popupCount setEnabled: NO];
  [self.popupCount setAutoenablesItems: NO];
  
  [self.buttonGenerate setEnabled: NO];
}

- (void)completeNpcGeneration
{
  if (self.completionHandler)
    {
      self.completionHandler(self.generatedNpc);
    }
  [self close]; // Close the character generation window
}

- (void)createNpc:(id)sender
{

  DSACharacterGenerator *generator = [[DSACharacterGenerator alloc] init];
  NSMutableDictionary *characterParameters = [[NSMutableDictionary alloc] init];

  NSString *selectedArchetype = [[self.popupTypes selectedItem] title];
  NSString *selectedSubtype = [[self.popupSubtypes selectedItem] title];
  NSString *selectedOrigin = [[self.popupOrigins selectedItem] title];
  NSString *selectedExperienceLevel = [[self.popupLevel selectedItem] title];
  
  NSLog(@"DSANPCGenerationController selectedOrigin: %@", selectedOrigin);

  [characterParameters setObject: selectedArchetype forKey: @"archetype"];
  if (![selectedSubtype isEqualToString: @"Subtypus wählen"])
    {
      [characterParameters setObject: selectedSubtype forKey: @"subarchetype"];
    }

  [characterParameters setObject: [NSNumber numberWithBool: YES] forKey: @"isNPC"];      // we only create characters here
  [characterParameters setObject: selectedOrigin forKey: @"origin"];
  [characterParameters setObject: selectedExperienceLevel forKey: @"experienceLevel"];

  DSACharacter *newCharacter = [generator generateCharacterWithParameters: characterParameters];
  
  self.generatedNpc = newCharacter;
  
  NSLog(@"DSANPCGenerationController: newCharacter: %@", newCharacter);
}

// depending on experience level, have to level up talents/spells etc.
// until better ideas, assume every talent starts with 0, and every spell starts at -5
// then just randomly level up talents and spells

- (void) levelUp
{

}

- (IBAction) popupCategorySelected: (id)sender
{
  if ([sender indexOfSelectedItem] == 0)
    {
      [self startNpcGeneration: self];
      return;
    }
NSLog(@"popupCategorySelected called!");  
  [self.popupTypes removeAllItems];
  [self.popupTypes addItemWithTitle: _(@"Typus wählen")];
  [self.popupTypes addItemsWithTitles: [Utils getAllNpcTypesForCategory: [[self.popupCategories selectedItem] title]]];
  [self.popupTypes setEnabled: YES];

  [self.popupSubtypes removeAllItems];
  [self.popupSubtypes addItemWithTitle: _(@"Subtypus wählen")];  
  [self.popupSubtypes setEnabled: NO];  
    
  [self.popupOrigins removeAllItems];
  [self.popupOrigins addItemWithTitle: _(@"Herkunft wählen")];  
  [self.popupOrigins setEnabled: NO];
  [self.popupLevel removeAllItems];
  [self.popupLevel addItemWithTitle: _(@"Erfahrungsstufe wählen")];  
  [self.popupLevel setEnabled: NO];
  [self.popupCount setEnabled: NO];
  [self.buttonGenerate setEnabled: NO];
}

- (IBAction) popupTypesSelected: (id)sender
{
  if ([sender indexOfSelectedItem] == 0)
    {
      [self.popupSubtypes removeAllItems];
      [self.popupSubtypes addItemWithTitle: _(@"Subtypus wählen")];  
      [self.popupSubtypes setEnabled: NO];
      [self.popupOrigins removeAllItems];
      [self.popupOrigins addItemWithTitle: _(@"Herkunft wählen")];  
      [self.popupOrigins setEnabled: NO];
      [self.popupLevel removeAllItems];
      [self.popupLevel addItemWithTitle: _(@"Erfahrungsstufe wählen")];  
      [self.popupLevel setEnabled: NO];
      [self.popupCount setEnabled: NO];
      [self.buttonGenerate setEnabled: NO];      
      return;
    }
NSLog(@"popupTypesSelected called!");
  NSArray *subtypes = [Utils getAllSubtypesForNpcType: [[self.popupTypes selectedItem] title]];
  [self.popupSubtypes removeAllItems];
  [self.popupSubtypes addItemWithTitle: _(@"Subtypus wählen")];
  if ([subtypes count] > 0)
    {
      [self.popupSubtypes addItemsWithTitles: subtypes];
      [self.popupSubtypes setEnabled: YES];
      [self.popupOrigins removeAllItems];
      [self.popupOrigins addItemWithTitle: _(@"Herkunft wählen")];  
      [self.popupOrigins setEnabled: NO];      
      [self.popupLevel removeAllItems];
      [self.popupLevel addItemWithTitle: _(@"Erfahrungsstufe wählen")];  
      [self.popupLevel setEnabled: NO];
      [self.popupCount setEnabled: NO];
      [self.buttonGenerate setEnabled: NO];      
    }
  else
    {
      [self.popupSubtypes setEnabled: NO];
      [self.popupOrigins removeAllItems];
      [self.popupOrigins addItemWithTitle: _(@"Herkunft wählen")];
      [self.popupOrigins addItemsWithTitles: [Utils getAllOriginsForNpcType: [[self.popupTypes selectedItem] title] ofSubtype: [[self.popupSubtypes selectedItem] title]]];
      [self.popupOrigins setEnabled: YES];
      [self.popupLevel removeAllItems];
      [self.popupLevel addItemWithTitle: _(@"Erfahrungsstufe wählen")];  
      [self.popupLevel setEnabled: NO];
      [self.popupCount setEnabled: NO];
      [self.buttonGenerate setEnabled: NO];     
    }
}

- (IBAction) popupSubtypesSelected: (id)sender
{
  if ([sender indexOfSelectedItem] == 0)
    {
      [self.popupOrigins removeAllItems];
      [self.popupOrigins addItemWithTitle: _(@"Herkunft wählen")];  
      [self.popupOrigins setEnabled: NO];
      [self.popupLevel removeAllItems];
      [self.popupLevel addItemWithTitle: _(@"Erfahrungsstufe wählen")];  
      [self.popupLevel setEnabled: NO];
      [self.popupCount setEnabled: NO];
      [self.buttonGenerate setEnabled: NO];    
      return;
    }
NSLog(@"popupSubtypesSelected called!");  
  [self.popupOrigins removeAllItems];
  [self.popupOrigins addItemWithTitle: _(@"Herkunft wählen")];
  [self.popupOrigins addItemsWithTitles: [Utils getAllOriginsForNpcType: [[self.popupTypes selectedItem] title] ofSubtype: [[self.popupSubtypes selectedItem] title]]];
  [self.popupOrigins setEnabled: YES];
  [self.popupLevel removeAllItems];
  [self.popupLevel addItemWithTitle: _(@"Erfahrungsstufe wählen")];  
  [self.popupLevel setEnabled: NO];
  [self.popupCount setEnabled: NO];
  [self.buttonGenerate setEnabled: NO];   
}

- (IBAction) popupOriginSelected: (id)sender
{
  if ([sender indexOfSelectedItem] == 0)
    {
      [self.popupLevel removeAllItems];
      [self.popupLevel addItemWithTitle: _(@"Erfahrungsstufe wählen")];  
      [self.popupLevel setEnabled: NO];
      [self.popupCount setEnabled: NO];
      [self.buttonGenerate setEnabled: NO];   
      return;
    }
  [self.popupLevel removeAllItems];
  [self.popupLevel addItemWithTitle: _(@"Erfahrungsstufe wählen")];
  [self.popupLevel addItemsWithTitles: [Utils getAllExperienceLevelsForNpcType: [[self.popupTypes selectedItem] title]]];
  [self.popupLevel setEnabled: YES];  
  [self.buttonGenerate setEnabled: NO];
     
}

- (IBAction) popupLevelSelected: (id)sender
{
  if ([sender indexOfSelectedItem] == 0)
    {
      [self.popupCount setEnabled: NO];    
      return;
    }
  [self.popupCount setEnabled: YES];
  [self.buttonGenerate setEnabled: YES];     
}



- (IBAction) buttonGenerateClicked: (id)sender
{
  NSLog(@"DSANPCGenerationController buttonGenerateClicked called");
  [self createNpc: sender];
  
  [self completeNpcGeneration];
}

@end
