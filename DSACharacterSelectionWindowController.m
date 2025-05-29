/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-05-29 16:16:03 +0200 by sebastia

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

#import "DSACharacterSelectionWindowController.h"
#import "DSACharacter.h"

@implementation DSACharacterSelectionWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [self.popupCharacters removeAllItems];
    [self.popupCharacters addItemWithTitle: @"Charakter wählen"];
    for (DSACharacter *character in self.characters) {
        [self.popupCharacters addItemWithTitle:character.name];
    }
    [self.buttonRemove setEnabled: NO];
}

- (IBAction)characterSelectedAction:(id)sender {
    if (self.popupCharacters.indexOfSelectedItem == 0)
      {
        [self.buttonRemove setEnabled: NO];
      }
    else
      {
        [self.buttonRemove setEnabled: YES];
      }
}

- (IBAction)removeAction:(id)sender {
    // Since we introduce the "Character wählen" at index 0, we have to subtract 1 from the selection
    NSInteger selectedIndex = self.popupCharacters.indexOfSelectedItem - 1;
    NSLog(@"DSACharacterSelectionWindowController removeAction: selectedIndex: %@ name: %@", [NSNumber numberWithInteger: selectedIndex], [[self.popupCharacters selectedItem] title]);
    
    
    if (selectedIndex >= 0 && selectedIndex < self.characters.count) {
        DSACharacter *selected = self.characters[selectedIndex];
        if (self.completionHandler) {
            self.completionHandler(selected);
        }
    }

    // Close the sheet
    [NSApp endSheet:self.window];
}

- (IBAction)cancelAction:(id)sender {
    [NSApp endSheet:self.window];
}

@end