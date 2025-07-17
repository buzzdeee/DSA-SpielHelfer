/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-07-17 20:46:37 +0200 by sebastia

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

#import "DSAActionViewController.h"
#import "DSAAdventureGroup.h"
#import "DSACharacter.h"

@implementation DSAActionViewController
- (void)windowDidLoad {
    NSLog(@"DSAActionViewController windowDidLoad called, window: %@", self.window);
    [super windowDidLoad];
    
    switch (self.viewMode) {
      case DSAActionViewModeTalent: {
        [self initializeViewForTalents];
        break;
      }
      case DSAActionViewModeSpell: {
        [self initializeViewForSpells];
        break;
      }
    }
}

  - (void) initializeViewForTalents
{
  self.window.title = @"Talent anwenden";
  self.fieldActionHeadline.stringValue = @"Ein Talent anwenden";
  self.fieldActionQuestionWho.stringValue = @"Wer soll ein Talent anwenden?";
  self.fieldActionQuestionWhat.stringValue = @"Talent auswählen";
  self.fieldActionQuestionTarget.stringValue = @"Auf wen soll das Talent angewendet werden?";
  
  NSArray *characters = [self.activeGroup allCharacters];
  [self.popupActors removeAllItems];
  for (DSACharacter *character in characters) {
    [self.popupActors addItemWithTitle:character.name];
    NSMenuItem *item = (NSMenuItem *)[self.popupActors lastItem];
    [item setRepresentedObject:character];
  }
  [self.popupActors selectItemAtIndex: 0];
  
  [self.popupActions removeAllItems];
  for (DSATalent *talent in self.talents) {
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:talent.name
                                                  action:nil
                                           keyEquivalent:@""];
    // Verweise das Objekt direkt über `representedObject`
    [item setRepresentedObject:talent];

    [[self.popupActions menu] addItem:item];
  }
     
  [self.popupTargets removeAllItems];
  for (DSACharacter *character in characters) {
    [self.popupTargets addItemWithTitle:character.name];
    NSMenuItem *item = (NSMenuItem *)[self.popupTargets lastItem];
    [item setRepresentedObject:character];
  } 
  self.buttonCancel.title = @"Abbrechen";
  self.buttonDoIt.title = @"Anwenden";
  [self.buttonDoIt setEnabled: NO];
  
}

- (void) initializeViewForSpells
{

}

- (IBAction)buttonDoItAction:(id)sender {
    NSLog(@"DSAActionViewController sleepAction");
    BOOL result = YES;

      
    if (self.completionHandler) {
        self.completionHandler(result);  // ⬅️ invoke handler before closing sheet
    }    
    [NSApp endSheet:self.window];
    [self.window orderOut:nil];
}

- (IBAction)buttonCancelAction:(id)sender {
    [NSApp endSheet:self.window];
    [self.window orderOut:nil];
}
@end
