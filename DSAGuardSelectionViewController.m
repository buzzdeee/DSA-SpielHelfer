/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-10-24 19:46:59 +0200 by sebastia

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

#import "DSAGuardSelectionViewController.h"
#import "DSAAdventure.h"
#import "DSAAdventureGroup.h"

@implementation DSAGuardSelectionViewController
- (void)windowDidLoad {
    NSLog(@"DSAGuardSelectionViewController windowDidLoad called, window: %@", self.window);
    DSAAdventure *adventure = [DSAAdventureManager sharedManager].currentAdventure;
    DSAAdventureGroup *activeGroup = adventure.activeGroup;
    [self.popupGuardOne removeAllItems];
    [self.popupGuardTwo removeAllItems];
    [self.popupGuardThree removeAllItems];        
    if (activeGroup.nightGuards != nil && [activeGroup.nightGuards count] == 3)
      {
         NSLog(@"DSAGuardSelectionViewController windowDidLoad activeGroup.nightGuards was NOT nil or count != 3");
         NSInteger counter = 0;
         NSInteger guardOne = 0;
         NSInteger guardTwo = 0;
         NSInteger guardThree = 0;                  
         for (NSUUID *uuid in activeGroup.partyMembers)
           {
             DSACharacter *character = [DSACharacter characterWithModelID: uuid];
             NSMenuItem *itemOne = [[NSMenuItem alloc] initWithTitle: [character name]
                                                              action: NULL
                                                       keyEquivalent: @""];
             NSMenuItem *itemTwo = [[NSMenuItem alloc] initWithTitle: [character name]
                                                              action: NULL
                                                       keyEquivalent: @""];
             NSMenuItem *itemThree = [[NSMenuItem alloc] initWithTitle: [character name]
                                                                action: NULL
                                                         keyEquivalent: @""];                                                       
                                                       
             [itemOne setRepresentedObject: character];                                                              
             [itemTwo setRepresentedObject: character];                                                              
             [itemThree setRepresentedObject: character];
             [[self.popupGuardOne menu] addItem: itemOne];
             [[self.popupGuardTwo menu] addItem: itemTwo];
             [[self.popupGuardThree menu] addItem: itemThree];             
             if ([uuid isEqualTo: [activeGroup.nightGuards objectAtIndex: 0]])
               {
                 guardOne = counter;
               }
             if ([uuid isEqualTo: [activeGroup.nightGuards objectAtIndex: 1]])
               {
                 guardTwo = counter;
               }
             if ([uuid isEqualTo: [activeGroup.nightGuards objectAtIndex: 2]])
               {
                 guardThree = counter;
               }
             counter++;
           }
         [self.popupGuardOne selectItemAtIndex: guardOne];
         [self.popupGuardTwo selectItemAtIndex: guardTwo];
         [self.popupGuardThree selectItemAtIndex: guardThree];                  
      }
    else
      {           
         NSLog(@"DSAGuardSelectionViewController windowDidLoad activeGroup.nightGuards was nil");            
         for (NSUUID *uuid in activeGroup.partyMembers)
           {
             DSACharacter *character = [DSACharacter characterWithModelID: uuid];
             NSMenuItem *itemOne = [[NSMenuItem alloc] initWithTitle: [character name]
                                                              action: NULL
                                                       keyEquivalent: @""];
             NSMenuItem *itemTwo = [[NSMenuItem alloc] initWithTitle: [character name]
                                                              action: NULL
                                                       keyEquivalent: @""];
             NSMenuItem *itemThree = [[NSMenuItem alloc] initWithTitle: [character name]
                                                                action: NULL
                                                         keyEquivalent: @""];                                                       
                                                       
             [itemOne setRepresentedObject: character];                                                              
             [itemTwo setRepresentedObject: character];                                                              
             [itemThree setRepresentedObject: character];
             [[self.popupGuardOne menu] addItem: itemOne];
             [[self.popupGuardTwo menu] addItem: itemTwo];
             [[self.popupGuardThree menu] addItem: itemThree];             
           }
         [self.popupGuardOne selectItemAtIndex: 0];
         [self.popupGuardTwo selectItemAtIndex: 0];
         [self.popupGuardThree selectItemAtIndex: 0];      
      }
      
      
    [super windowDidLoad];
}

- (IBAction)confirmAction:(id)sender {
    NSLog(@"DSAGuardSelectionViewController confirmAction");
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
