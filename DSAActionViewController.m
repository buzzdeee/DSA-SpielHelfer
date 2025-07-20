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
#import "DSASpell.h"

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
      case DSAActionViewModeRitual: {
        [self initializeViewForRituals];
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
  
  NSArray *actors = [self.activeGroup charactersAbleToUseTalentsIncludingNPCs: YES];
  [self.popupActors removeAllItems];
  for (DSACharacter *character in actors) {
    [self.popupActors addItemWithTitle:character.name];
    NSMenuItem *item = (NSMenuItem *)[self.popupActors lastItem];
    [item setRepresentedObject:character];
  }
  [self.popupActors selectItemAtIndex: 0];
  
  DSACharacter *selectedCharacter = (DSACharacter *)[[self.popupActors selectedItem] representedObject];
  
  [self.popupActions removeAllItems];
  for (DSATalent *talent in [selectedCharacter activeTalentsWithNames: self.talents]) {
    [self.popupActions addItemWithTitle:talent.name];
    NSMenuItem *item = (NSMenuItem *)[self.popupActions lastItem];
    [item setRepresentedObject:talent];
  }
  
  DSATalent *selectedTalent = (DSATalent *)[[self.popupActions selectedItem] representedObject];
  switch (selectedTalent.targetType)
    {
      case DSAActionTargetTypeNone: {
        [self disableTargets];
        break;
      }
      default: {
        [self enableTargetsForType: selectedTalent.targetType];
      }
    }
  self.buttonCancel.title = @"Abbrechen";
  self.buttonDoIt.title = @"Anwenden";
}

- (void) initializeViewForSpells
{
  self.window.title = @"Magie anwenden";
  self.fieldActionHeadline.stringValue = @"Magie anwenden";
  self.fieldActionQuestionWho.stringValue = @"Wer soll Magie anwenden?";
  self.fieldActionQuestionWhat.stringValue = @"Zauberspruch auswählen";
  self.fieldActionQuestionTarget.stringValue = @"Auf wen soll der Spruch angewendet werden?";
  
  NSArray *actors = [self.activeGroup charactersAbleToCastSpellsIncludingNPCs: YES];
  [self.popupActors removeAllItems];
  for (DSACharacter *character in actors) {
    [self.popupActors addItemWithTitle:character.name];
    NSMenuItem *item = (NSMenuItem *)[self.popupActors lastItem];
    [item setRepresentedObject:character];
  }
  [self.popupActors selectItemAtIndex: 0];
  
  DSACharacter *selectedCharacter = (DSACharacter *)[[self.popupActors selectedItem] representedObject];
  [self.popupActions removeAllItems];
  for (DSASpell *spell in [selectedCharacter activeSpellsWithNames: self.spells]) {
    [self.popupActions addItemWithTitle:spell.name];
    NSMenuItem *item = (NSMenuItem *)[self.popupActions lastItem];
    [item setRepresentedObject:spell];
  }
  
  DSASpell *selectedSpell = (DSASpell *)[[self.popupActions selectedItem] representedObject];
  switch (selectedSpell.targetType)
    {
      case DSAActionTargetTypeNone: {
        [self disableTargets];
        break;
      }
      default: {
        [self enableTargetsForType: selectedSpell.targetType];
      }
    }

  self.buttonCancel.title = @"Abbrechen";
  self.buttonDoIt.title = @"Anwenden";
}

- (void) initializeViewForRituals
{
  self.window.title = @"Ritual anwenden";
  self.fieldActionHeadline.stringValue = @"Ritual anwenden";
  self.fieldActionQuestionWho.stringValue = @"Wer soll ein Ritual anwenden?";
  self.fieldActionQuestionWhat.stringValue = @"Ritual auswählen";
  self.fieldActionQuestionTarget.stringValue = @"Auf wen soll das Ritual angewendet werden?";
  
  NSArray *actors = [self.activeGroup charactersAbleToCastRitualsIncludingNPCs: YES];
  [self.popupActors removeAllItems];
  for (DSACharacter *character in actors) {
    [self.popupActors addItemWithTitle:character.name];
    NSMenuItem *item = (NSMenuItem *)[self.popupActors lastItem];
    [item setRepresentedObject:character];
  }
  [self.popupActors selectItemAtIndex: 0];
  
  DSACharacter *selectedCharacter = (DSACharacter *)[[self.popupActors selectedItem] representedObject];
  
  [self.popupActions removeAllItems];
  for (DSASpell *spell in [selectedCharacter activeSpellsWithNames: self.rituals]) {
    [self.popupActions addItemWithTitle:spell.name];
    NSMenuItem *item = (NSMenuItem *)[self.popupActions lastItem];
    [item setRepresentedObject:spell];
  }

  DSASpell *selectedSpell = (DSASpell *)[[self.popupActions selectedItem] representedObject];
  switch (selectedSpell.targetType)
    {
      case DSAActionTargetTypeNone: {
        [self disableTargets];
        break;
      }
      default: {
        [self enableTargetsForType: selectedSpell.targetType];
      }
    }  
  self.buttonCancel.title = @"Abbrechen";
  self.buttonDoIt.title = @"Anwenden";
}


- (void) disableTargets
{
  [self.fieldActionQuestionTarget setHidden: YES];
  [self.popupTargets removeAllItems];
  [self.popupTargets setEnabled: NO];
  [self.popupTargets setHidden: YES];
}

- (void) enableTargetsForType: (DSAActionTargetType) targetType
{
  NSLog(@"DSAActionIconViewController enableTargetsForType NOT IMPLEMENTED YET");
}

- (IBAction)popupActorSelected:(id)sender
{
  DSACharacter *selectedCharacter = (DSACharacter *)[[self.popupActors selectedItem] representedObject];
  NSLog(@"DSAActionViewController popupActorSelected %@", selectedCharacter.name);
  [self.popupActions removeAllItems];
  
    switch (self.viewMode) {
      case DSAActionViewModeTalent: {
        for (DSATalent *talent in [selectedCharacter activeTalentsWithNames: self.talents]) {
          [self.popupActions addItemWithTitle:talent.name];
          NSMenuItem *item = (NSMenuItem *)[self.popupActions lastItem];
          [item setRepresentedObject:talent];
        }      
        break;
      }
      case DSAActionViewModeSpell: {
        for (DSASpell *spell in [selectedCharacter activeSpellsWithNames: self.spells]) {
          [self.popupActions addItemWithTitle:spell.name];
          NSMenuItem *item = (NSMenuItem *)[self.popupActions lastItem];
          [item setRepresentedObject:spell];
        }      
        break;
      }
      case DSAActionViewModeRitual: {
        for (DSASpell *ritual in [selectedCharacter activeRitualsWithNames: self.rituals]) {
          NSLog(@"DSAActionViewController popupActorSelected checking ritual: %@", ritual);
          [self.popupActions addItemWithTitle:ritual.name];
          NSMenuItem *item = (NSMenuItem *)[self.popupActions lastItem];
          [item setRepresentedObject:ritual];
        }      
        break;
      }      
    } 
}
- (IBAction)popupActionSelected:(id)sender
{

}
- (IBAction)popupTargetSelected:(id)sender
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
