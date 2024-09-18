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
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
*/

#import "DSADocumentController.h"
#import "DSACharacterWindowController.h"
#import "DSACharacterDocument.h"

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
      @"DSACharacter": [DSACharacterWindowController class]
  };
  // Initialize the map with document type to model map
  _documentTypeToModelMap = @{
      @"DSACharacter": [DSACharacterDocument class]
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

- (void)newDocument:(id)sender
{
  NSLog(@"DSADocumentController newDocument: was called");
  Class documentControllerClass;
  Class windowControllerClass;
  NSString *windowNibName;
    
  // Obtain the document class    
  if ([sender tag] == 0)
    {
//      NSLog(@"DSADocumentController newDocument: sender tag was 0");
      documentControllerClass = [self documentClassForType:@"DocType1"];
//      NSLog(@"DSADocumentController, newDocument: documentControllerClass: %@", documentControllerClass);
      windowControllerClass = [self windowControllerClassForDocumentType:@"DocType1"];        
      windowNibName = @"DSACharacter";
    }
  else
    {
      NSLog(@"DSADocumentController newDocument: sender tag was not null");       
    }
//  NSLog(@"DSADocumentController, newDocument: documentControllerClass: %@", documentControllerClass);      
  if (documentControllerClass)
    {
      // Create a new document instance, we assign subclasses
        
//      NSLog(@"DSADocumentController newDocument: I have a documentControllerClass %@", documentControllerClass);
//      NSLog(@"DSADocumentController newDocument: I have a windowControllerClass %@", windowControllerClass);        
        
      NSDocument *newDocument = [[documentControllerClass alloc] init];
        
      // Create and configure the window controller, actually subclasses as well
      NSWindowController *windowController = [[windowControllerClass alloc] initWithWindowNibName:windowNibName];
        
      // Add the window controller to the document
      [newDocument addWindowController:windowController];
        
      // Show the window
      [windowController.window makeKeyAndOrderFront:self];
        
      // Add the new document to the document controller
      [self addDocument:newDocument];
    }
  else
    {
      NSLog(@"Error: No document class found for type.");
    }
}
@end