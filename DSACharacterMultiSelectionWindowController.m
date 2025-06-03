/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-05-31 22:15:14 +0200 by sebastia

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

#import "DSACharacterMultiSelectionWindowController.h"
#import "DSACharacter.h"

@implementation DSACharacterMultiSelectionWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    NSInteger i = 0;
    for (DSACharacter *character in self.characters) {
        NSString *fieldName = [NSString stringWithFormat: @"switchCharacter%li", (unsigned long)i];
        NSLog(@"DSACharacterMultiSelectionWindowController character: %@", character.name);
        NSButton *switchfield = [self valueForKey: fieldName];
        [switchfield setHidden: NO];
        [switchfield setEnabled: YES];
        [switchfield setTitle: character.name];
        i++;
    }
    for (; i < 9; i++) {
        NSString *fieldName = [NSString stringWithFormat: @"switchCharacter%li", (unsigned long)i];
        NSButton *switchfield = [self valueForKey: fieldName];
        [switchfield setHidden: YES];
        [switchfield setEnabled: NO];
    }    
    [self.buttonSelect setEnabled: NO];
}



/*

      for (NSInteger i=0; i< 20; i++)
        {
          NSString *fieldName = [NSString stringWithFormat: @"switchMagicalDabbler%li", i];
          [[self valueForKey: fieldName] setHidden: YES];
          [[self valueForKey: fieldName] setEnabled: NO];          
        }

- (IBAction) buttonMagicalDabblerFinish: (id)sender
{

  NSLog(@"buttonMagicalDabblerFinish have to do the magical dabbler thing on the generated character...");
  
  if (self.magicalDabblerDiceResult >= 1 && self.magicalDabblerDiceResult <= 15)
    {
      [self.magicalDabblerInfo setObject: @[_(@"Schutzgeist"), _(@"Magisches Meisterhandwerk")] forKey: @"specialTalents"];

      NSMutableArray *newSpells = [[NSMutableArray alloc] init];
      for (NSInteger i=0; i <= 19; i++)
        {
          NSString *fieldName = [NSString stringWithFormat: @"switchMagicalDabbler%li", i];
          NSButton *button = [self valueForKey: fieldName];
          if ([button state] == 1)
            {
               NSLog(@"testing spell: %@", [button title]);
               [newSpells addObject: [button title]];
            }
        }
      [self.magicalDabblerInfo setObject: newSpells forKey: @"spells"];
    }
  else if (self.magicalDabblerDiceResult >= 16 && self.magicalDabblerDiceResult <= 19)
    {
       [self.magicalDabblerInfo setObject: @[_(@"Schutzgeist"), _(@"Magisches Meisterhandwerk")] forKey: @"specialTalents"];
    }
  else if (self.magicalDabblerDiceResult == 20)
    {
      for (NSInteger i=0; i< 2; i++)
        {
          NSString *fieldName = [NSString stringWithFormat: @"switchMagicalDabbler%li", i];
          NSButton *button = [self valueForKey: fieldName];          
          if ([button state] == 1)
            {
              [self.magicalDabblerInfo setObject: @[[button title]] forKey: @"specialTalents"];
              break;
            }
        }
    }
  NSLog(@"Going to create the character!");
  [self createCharacter:sender];    
  NSLog(@"Going to close the magical dabbler window");
  [self.windowMagicalDabbler close];
  NSLog(@"going to complete character generation");
  [self completeCharacterGeneration];  
}
*/

- (IBAction) characterSwitchToggled: (id)sender
{
  NSLog(@"switchMagicalDabblerSelected called %@", [sender title]);
  NSInteger counter = 0;
  for (NSInteger i=0; i<= 8; i++)
    {
      NSString *fieldName = [NSString stringWithFormat: @"switchCharacter%li", (unsigned long)i];
      if ([[self valueForKey: fieldName] state] == 1)
        {
          counter++;
        }
    }
  // second test, due to that it doesn't make sense to move all characters to a new group...
  if (counter > 0 && counter < [self.characters count])
    {
      [self.buttonSelect setEnabled: YES];
    }
  else
    {
      [self.buttonSelect setEnabled: NO];
    }
}


- (IBAction)selectAction:(id)sender {    
    NSMutableArray *selectedCharacters = [[NSMutableArray alloc] init];
  for (NSInteger i=0; i<= 8; i++)
    {
      NSString *fieldName = [NSString stringWithFormat: @"switchCharacter%li", (unsigned long)i];
      if ([[self valueForKey: fieldName] state] == 1)
        {
          [selectedCharacters addObject: self.characters[i]];
        }
    }
    
        
    if (selectedCharacters.count > 0) {
        if (self.completionHandler) {
            self.completionHandler(selectedCharacters);
        }
    }

    // Close the sheet
    [NSApp endSheet:self.window];
}

- (IBAction)cancelAction:(id)sender {
    [NSApp endSheet:self.window];
}


@end
