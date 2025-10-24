/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-10-24 22:46:41 +0200 by sebastia

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

#import "DSAHuntOrHerbsViewController.h"
#import "DSAAdventure.h"
#import "DSAAdventureGroup.h"


@implementation DSAHuntOrHerbsViewController

- (void)windowDidLoad {
    NSLog(@"DSAHuntOrHerbsViewController windowDidLoad called, window: %@", self.window);
    [super windowDidLoad];
    switch (self.mode)
      {
        case DSAHuntOrHerbsViewModeHunt:
          self.window.title = @"Jagd";
          [self.fieldQuestionWho setStringValue: @"Wer soll auf die Jagd und nach Wasser suchen gehen?"];
          [self.fieldQuestionHours setStringValue: @"Für wie viele Stunden soll gejagt werden?"];
          break;
        case DSAHuntOrHerbsViewModeHerbs:
          self.window.title = @"Kräutersuche";
          [self.fieldQuestionWho setStringValue: @"Wer soll auf Kräutersuche gehen?"];
          [self.fieldQuestionHours setStringValue: @"Für wie viele Stunden soll nach Kräuter gesucht werden?"];
          break;
        default:
          NSLog(@"DSAHuntOrHerbsViewController windowDidLoad: unknown DSAHuntOrHerbsViewMode aborting!");
          abort();
          break;
      }
    DSAAdventure *adventure = [DSAAdventureManager sharedManager].currentAdventure;
    DSAAdventureGroup *activeGroup = adventure.activeGroup;
    [self.popupCharacters removeAllItems];
    for (NSUUID *uuid in activeGroup.partyMembers)
      {
        DSACharacter *character = [DSACharacter characterWithModelID: uuid];
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle: [character name]
                                                      action: NULL
                                               keyEquivalent: @""];
        [item setRepresentedObject: character];                                                              
        [[self.popupCharacters menu] addItem: item];
      }
    [self.popupCharacters selectItemAtIndex: 0];    
    [self.fieldHours setStringValue: @"0 Stunden"];
    [self.buttonConfirm setEnabled: NO];
}

- (IBAction)sliderValueChanged:(NSSlider *)sender {
    double value = sender.doubleValue;
    self.fieldHours.stringValue = [NSString stringWithFormat:@"%.0f Stunden", value];
    if (value > 0)
      {
        [self.buttonConfirm setEnabled: YES];
      }
}

- (IBAction)confirmAction:(id)sender {
    NSLog(@"DSAHuntOrHerbsViewController confirmAction");
    BOOL result = YES;

    if (self.completionHandler) {
        self.completionHandler(result);  // ⬅️ invoke handler before closing sheet
    }    
    [NSApp endSheet:self.window];
    [self.window orderOut:nil];
}

- (IBAction)cancelAction:(id)sender {
    [NSApp endSheet:self.window];
    [self.window orderOut:nil];
}

@end
