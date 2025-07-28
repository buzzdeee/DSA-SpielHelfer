/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-09-07 23:26:58 +0200 by sebastia

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
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 US.A
*/

#import "DSADocumentController.h"
#import "DSACharacterWindowController.h"
#import "DSAAdventureWindowController.h"
#import "DSACharacterDocument.h"
#import "DSAAdventureDocument.h"
#import "DSACharacter.h"

@implementation DSADocumentController

static DSADocumentController *sharedInstance = nil;
static NSObject *syncObject = nil; // A synchronization object

+ (DSADocumentController *)sharedDocumentController
{ 
  // Initialize the synchronization object if needed
  NSLog(@"DSADocumentController sharedDocumentController was called");
  if (syncObject == nil)
    {
      syncObject = [[NSObject alloc] init];
    }
    
  @synchronized(syncObject)
    {
      if (sharedInstance == nil)
        {
          // Obtain the current shared instance from the superclass
          sharedInstance = (DSADocumentController *)[super sharedDocumentController];
          [sharedInstance performCustomInitialization];
        }
    }
  return sharedInstance;
}

- (void)performCustomInitialization
{
  // Initialize the map with document type to window controller class mappings
  NSLog(@"DSADocumentController performCustomInitialization: setting up _documentTypeToWindowControllerMap!!!");
  _documentTypeToWindowControllerMap = @{
      @"DSACharacter": [DSACharacterWindowController class],
      @"DSAAdventure": [DSAAdventureWindowController class],
  };
  // Initialize the map with document type to model map
  _documentTypeToModelMap = @{
      @"DSACharacter": [DSACharacterDocument class],
      @"DSAAdventure": [DSAAdventureDocument class],
  };
}

- (Class)windowControllerClassForDocumentType:(NSString *)typeName
{
  NSLog(@"DSADocumentController: windowControllerClassForDocumentType %@", typeName);
  return self.documentTypeToWindowControllerMap[typeName];
}

- (Class)documentClassForType:(NSString *)typeName
{
  // Return the appropriate document class based on the document type
  NSLog(@"DSADocumentController: documentClassForType %@", typeName);
  return self.documentTypeToModelMap[typeName];  
}

- (NSArray<DSAAdventureDocument *> *)allAdventureDocuments {
    return [[self documents] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSDocument *doc, NSDictionary *bindings) {
        return [doc isKindOfClass:[DSAAdventureDocument class]];
    }]];
}


-(IBAction)levelUpBaseValues: (id)sender
{
  NSLog(@"DSADocumentController levelUpBaseValues called!");
  NSDocument *activeDocument = [self currentDocument];
  for (NSWindowController *windowController in [activeDocument windowControllers])
    {
      // Check if the window controller is of the specific subclass you're looking for
      if ([windowController isKindOfClass:[DSACharacterWindowController class]])
        {    
          // Cast the window controller to your custom class and call the method
          DSACharacterWindowController *characterWindowController = (DSACharacterWindowController *)windowController;
          [characterWindowController levelUpBaseValues:nil];
            
          // If you only expect one relevant window controller, you can break after finding it
          break;
        }
    }
}

-(IBAction)addAdventurePoints: (id)sender
{
  NSLog(@"DSADocumentController addAdventurePoints called!");
  NSDocument *activeDocument = [self currentDocument];
  for (NSWindowController *windowController in [activeDocument windowControllers])
    {
      // Check if the window controller is of the specific subclass you're looking for
      if ([windowController isKindOfClass:[DSACharacterWindowController class]])
        {    
          // Cast the window controller to your custom class and call the method
          DSACharacterWindowController *characterWindowController = (DSACharacterWindowController *)windowController;
          [characterWindowController addAdventurePoints:nil];
            
          // If you only expect one relevant window controller, you can break after finding it
          break;
        }
    }
}

-(IBAction)manageMoney: (id)sender
{
  NSLog(@"DSADocumentController manageMoney called!");
  NSDocument *activeDocument = [self currentDocument];
  for (NSWindowController *windowController in [activeDocument windowControllers])
    {
      // Check if the window controller is of the specific subclass you're looking for
      if ([windowController isKindOfClass:[DSACharacterWindowController class]])
        {    
          // Cast the window controller to your custom class and call the method
          DSACharacterWindowController *characterWindowController = (DSACharacterWindowController *)windowController;
          [characterWindowController manageMoney:nil];
            
          // If you only expect one relevant window controller, you can break after finding it
          break;
        }
    }
}

-(IBAction)showEnergiesManagerPanel: (id)sender
{
  NSLog(@"DSADocumentController showEnergiesManagerPanel called!");
  NSDocument *activeDocument = [self currentDocument];
  for (NSWindowController *windowController in [activeDocument windowControllers])
    {
      // Check if the window controller is of the specific subclass you're looking for
      if ([windowController isKindOfClass:[DSACharacterWindowController class]])
        {    
          // Cast the window controller to your custom class and call the method
          DSACharacterWindowController *characterWindowController = (DSACharacterWindowController *)windowController;
          [characterWindowController showEnergiesManagerPanel:nil];
            
          // If you only expect one relevant window controller, you can break after finding it
          break;
        }
    }
}

-(IBAction)showApplyIllnessPanel: (id)sender
{
  NSLog(@"DSADocumentController showApplyIllnessPanel called!");
  NSDocument *activeDocument = [self currentDocument];
  for (NSWindowController *windowController in [activeDocument windowControllers])
    {
      // Check if the window controller is of the specific subclass you're looking for
      if ([windowController isKindOfClass:[DSACharacterWindowController class]])
        {    
          // Cast the window controller to your custom class and call the method
          DSACharacterWindowController *characterWindowController = (DSACharacterWindowController *)windowController;
          [characterWindowController showApplyIllnessPanel:nil];
            
          // If you only expect one relevant window controller, you can break after finding it
          break;
        }
    }
}

-(IBAction)showApplyPoisonPanel: (id)sender
{
  NSLog(@"DSADocumentController showApplyPoisonPanel called!");
  NSDocument *activeDocument = [self currentDocument];
  for (NSWindowController *windowController in [activeDocument windowControllers])
    {
      // Check if the window controller is of the specific subclass you're looking for
      if ([windowController isKindOfClass:[DSACharacterWindowController class]])
        {    
          // Cast the window controller to your custom class and call the method
          DSACharacterWindowController *characterWindowController = (DSACharacterWindowController *)windowController;
          [characterWindowController showApplyPoisonPanel:nil];
            
          // If you only expect one relevant window controller, you can break after finding it
          break;
        }
    }
}

-(IBAction)showUseTalentPanel: (id)sender
{
  NSLog(@"DSADocumentController showUseTalentPanel called!");
  NSDocument *activeDocument = [self currentDocument];
  for (NSWindowController *windowController in [activeDocument windowControllers])
    {
      // Check if the window controller is of the specific subclass you're looking for
      if ([windowController isKindOfClass:[DSACharacterWindowController class]])
        {    
          // Cast the window controller to your custom class and call the method
          DSACharacterWindowController *characterWindowController = (DSACharacterWindowController *)windowController;
          [characterWindowController showUseTalentPanel:nil];
            
          // If you only expect one relevant window controller, you can break after finding it
          break;
        }
    }
}

-(IBAction)showCastSpellPanel: (id)sender
{
  NSLog(@"DSADocumentController showCastSpellPanel called!");
  NSDocument *activeDocument = [self currentDocument];
  for (NSWindowController *windowController in [activeDocument windowControllers])
    {
      // Check if the window controller is of the specific subclass you're looking for
      if ([windowController isKindOfClass:[DSACharacterWindowController class]])
        {    
          // Cast the window controller to your custom class and call the method
          DSACharacterWindowController *characterWindowController = (DSACharacterWindowController *)windowController;
          [characterWindowController showCastSpellPanel:nil];
            
          // If you only expect one relevant window controller, you can break after finding it
          break;
        }
    }
}

-(IBAction)showRegenerateCharacterPanel: (id)sender
{
  NSLog(@"DSADocumentController regenerateCharacter called!");
  NSDocument *activeDocument = [self currentDocument];
  for (NSWindowController *windowController in [activeDocument windowControllers])
    {
      // Check if the window controller is of the specific subclass you're looking for
      if ([windowController isKindOfClass:[DSACharacterWindowController class]])
        {    
          // Cast the window controller to your custom class and call the method
          DSACharacterWindowController *characterWindowController = (DSACharacterWindowController *)windowController;
          [characterWindowController showRegenerateCharacterPanel:nil];
            
          // If you only expect one relevant window controller, you can break after finding it
          break;
        }
    }
}

-(IBAction)showRitualsPanel: (id)sender
{
  NSLog(@"DSADocumentController showRitualsPanel called!");
  NSDocument *activeDocument = [self currentDocument];
  for (NSWindowController *windowController in [activeDocument windowControllers])
    {
      // Check if the window controller is of the specific subclass you're looking for
      if ([windowController isKindOfClass:[DSACharacterWindowController class]])
        {    
          // Cast the window controller to your custom class and call the method
          DSACharacterWindowController *characterWindowController = (DSACharacterWindowController *)windowController;
          [characterWindowController showRitualsPanel:nil];
            
          // If you only expect one relevant window controller, you can break after finding it
          break;
        }
    }
}


// DSAAdventureDocument related methods
-(IBAction)addCharacterToAdventure: (id)sender
{
  NSLog(@"DSADocumentController addCharacterToAdventure called!");
  NSDocument *activeDocument = [self currentDocument];
  
  if ([activeDocument isMemberOfClass:[DSAAdventureDocument class]])
    {
      NSLog(@"DSADocumentController addCharacterToAdventure active Document is DSAAdventureDocument!");
      DSAAdventureDocument *activeAdventure = (DSAAdventureDocument *) activeDocument;
      [activeAdventure addCharacterFromFile];
    }
  else
    {
      NSLog(@"DSADocumentController addCharacterToAdventure: active document is not of class DSAAdventureDocument");
    }
}

-(IBAction)pauseGameClock: (id)sender
{
  NSLog(@"DSADocumentController pauseGameClock called!");
  NSDocument *activeDocument = [self currentDocument];
  
  if ([activeDocument isMemberOfClass:[DSAAdventureDocument class]])
    {
      DSAAdventureDocument *activeAdventure = (DSAAdventureDocument *) activeDocument;
      [activeAdventure pauseGameClock];
    }
  else
    {
      NSLog(@"DSADocumentController pauseGameClock: active document is not of class DSAAdventureDocument");
    }
}

-(IBAction)startGameClock: (id)sender
{
  NSLog(@"DSADocumentController startGameClock called!");
  NSDocument *activeDocument = [self currentDocument];
  
  if ([activeDocument isMemberOfClass:[DSAAdventureDocument class]])
    {
      DSAAdventureDocument *activeAdventure = (DSAAdventureDocument *) activeDocument;
      [activeAdventure startGameClock];
    }
  else
    {
      NSLog(@"DSADocumentController startGameClock: active document is not of class DSAAdventureDocument");
    }
}

-(IBAction)advanceGameTimeByFiveMinutes: (id)sender
{
  NSLog(@"DSADocumentController advanceGameTimeByFiveMinutes called!");
  NSDocument *activeDocument = [self currentDocument];
  
  if ([activeDocument isMemberOfClass:[DSAAdventureDocument class]])
    {
      DSAAdventureDocument *activeAdventure = (DSAAdventureDocument *) activeDocument;
      [activeAdventure advanceGameTimeByMinutes: 5];
    }
  else
    {
      NSLog(@"DSADocumentController advanceGameTimeByFiveMinutes: active document is not of class DSAAdventureDocument");
    }
}

-(IBAction)advanceGameTimeByOneHour: (id)sender
{
  NSLog(@"DSADocumentController advanceGameTimeByOneHour called!");
  NSDocument *activeDocument = [self currentDocument];
  
  if ([activeDocument isMemberOfClass:[DSAAdventureDocument class]])
    {
      DSAAdventureDocument *activeAdventure = (DSAAdventureDocument *) activeDocument;
      [activeAdventure advanceGameTimeByHours: 1];
    }
  else
    {
      NSLog(@"DSADocumentController advanceGameTimeByOneHour: active document is not of class DSAAdventureDocument");
    }
}

-(IBAction)advanceGameTimeByOneDay: (id)sender
{
  NSLog(@"DSADocumentController advanceGameTimeByOneDay called!");
  NSDocument *activeDocument = [self currentDocument];
  
  if ([activeDocument isMemberOfClass:[DSAAdventureDocument class]])
    {
      DSAAdventureDocument *activeAdventure = (DSAAdventureDocument *) activeDocument;
      [activeAdventure advanceGameTimeByDays: 1];
    }
  else
    {
      NSLog(@"DSADocumentController advanceGameTimeByOneDay: active document is not of class DSAAdventureDocument");
    }
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
//NSLog(@"DSADocumentController validateMenuItem %@ %lu", [menuItem title], (unsigned long)[menuItem tag]);
// TAGS: 22: levelUp, 23: Geldbörse managen, 24: Talent anwenden, 25: Abenteuerpunkte hinzufügen, 26: Zaubern, 27: regenerieren, 28: Energien managen
// 29 Rituale
// Add Character to Adventure
      NSWindow *keyWindow = [NSApp keyWindow];
      NSResponder *firstResponder = [keyWindow firstResponder];

      if ([menuItem tag] == 22)
        { // Tag for the "Level Up" menu item
          if ([firstResponder isKindOfClass:[NSWindow class]])
            {
              if ([[(NSWindow *)firstResponder windowController] isKindOfClass:[DSACharacterWindowController class]])
                {
                   DSACharacterWindowController *windowController = [(NSWindow *)firstResponder windowController];
                   DSACharacterDocument *document = (DSACharacterDocument *) windowController.document;
                   return [(DSACharacterHero *)document.model canLevelUp];                 
                }
            }
          return NO;
        }
      else if ([menuItem tag] == 24)
        {  // Tag for "use Talent" menu item
          if ([firstResponder isKindOfClass:[NSWindow class]])
            {
              if ([[(NSWindow *)firstResponder windowController] isKindOfClass:[DSACharacterWindowController class]])
                {
                   DSACharacterWindowController *windowController = [(NSWindow *)firstResponder windowController];
                   DSACharacterDocument *document = (DSACharacterDocument *) windowController.document;
                   return [(DSACharacterHero *)document.model canUseTalents];                 
                }
            }
          return NO;        
        }        
      else if ([menuItem tag] == 26)
        {  // Tag for "cast Spell" menu item
          if ([firstResponder isKindOfClass:[NSWindow class]])
            {
              if ([[(NSWindow *)firstResponder windowController] isKindOfClass:[DSACharacterWindowController class]])
                {
                   DSACharacterWindowController *windowController = [(NSWindow *)firstResponder windowController];
                   DSACharacterDocument *document = (DSACharacterDocument *) windowController.document;
                   return [(DSACharacterHero *)document.model canCastSpells];                 
                }
            }
          return NO;        
        }
      else if ([menuItem tag] == 27)
        {  // Tag for "Regenerieren" menu item
          if ([firstResponder isKindOfClass:[NSWindow class]])
            {
              if ([[(NSWindow *)firstResponder windowController] isKindOfClass:[DSACharacterWindowController class]])
                {
                   DSACharacterWindowController *windowController = [(NSWindow *)firstResponder windowController];
                   DSACharacterDocument *document = (DSACharacterDocument *) windowController.document;
                   return [(DSACharacterHero *)document.model canRegenerate];                 
                }
            }
          return NO;        
        }
      else if ([menuItem tag] == 29)  // Rituale
        {
          if ([firstResponder isKindOfClass:[NSWindow class]])
            {
              if ([[(NSWindow *)firstResponder windowController] isKindOfClass:[DSACharacterWindowController class]])
                {
                   DSACharacterWindowController *windowController = [(NSWindow *)firstResponder windowController];
                   DSACharacterDocument *document = (DSACharacterDocument *) windowController.document;
                   return [(DSACharacterHero *)document.model canCastRituals];
                }
            }
          return NO;
        }
      else if ([menuItem tag] == 23 || [menuItem tag] == 25 || [menuItem tag] == 28)
        {
          if ([firstResponder isKindOfClass:[NSWindow class]])
            {
              if ([[(NSWindow *)firstResponder windowController] isKindOfClass:[DSACharacterWindowController class]])
                {
                 return YES;                 
                }
            }
          return NO;
        }
      else if ([menuItem tag] == 201 || [menuItem tag] == 202 || [menuItem tag] == 203 || [menuItem tag] == 204 ||
               [menuItem tag] == 205 || [menuItem tag] == 206)
        {
          if ([[(NSWindow *)firstResponder windowController] isKindOfClass:[DSAAdventureWindowController class]])
            {
              return YES;
            }
          else
            {
              return NO;
            }
        }
      else
        {
          return YES;
        }
      

  return [super validateMenuItem:menuItem];
}

@end