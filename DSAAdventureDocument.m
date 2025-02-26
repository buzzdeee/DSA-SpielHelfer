/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-01-01 23:39:03 +0100 by sebastia

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

#import "DSAAdventureDocument.h"
#import "DSAAdventureWindowController.h"
#import "DSAAdventure.h"

@implementation DSAAdventureDocument

- (instancetype)init
{
  self = [super init];
  if (self)
    {
      // Initialize your document here
      self.model = [[DSAAdventure alloc] init];                                         
    }
  NSLog(@"DSAAdventureDocument init was called, the model: %@", self.model);  
  return self;
}

- (void)dealloc
{
  NSLog(@"DSAAdventureDocument is being deallocated.");
}

- (void)close
{
    NSLog(@"DSAAdventureDocument close called!");
    [super close];
}

- (NSString *)windowNibName
{
  NSLog(@"DSAAdventureDocument: windowNibName was called");
  // Return the name of the .gorm file that defines the document's UI
  return @"DSAAdventure";
}

// we don't want the windows to pop up on startup
- (void)makeWindowControllers
{ 
  if (self.windowControllersCreated)
    {
      NSLog(@"DSAAdventureDocument: windowControllers already created");
      return; // Don't create again
    }
    self.windowControllersCreated = YES;
  
  if (![self.model isMemberOfClass:[DSAAdventure class]])
    {
      DSAAdventureWindowController *windowController = [[DSAAdventureWindowController alloc] initWithWindowNibName:[self windowNibName]];
      [self addWindowController:windowController];
      
      NSLog(@"DSAAdventureDocument makeWindowControllers called, and it was DSAAdventure class" );
    }
}

- (BOOL)isMainWindow:(NSWindow *)window {
    for (NSWindowController *controller in self.windowControllers) {
        if (controller.window == window) {
            return YES; // This is the main document window
        }
    }
    return NO; // This is an ancillary window
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
  // Ensure the model exists       
  @try
    {
      if (!self.model)
        {
          if (outError)
            {
              *outError = [NSError errorWithDomain:NSCocoaErrorDomain
                                              code:NSFileWriteUnknownError
                                          userInfo:@{NSLocalizedDescriptionKey: @"No data to save"}];
            }
          return nil;
        }
        
      // Archive model object to NSData
      NSLog(@"DSAAdventureDocument dataOfType: %@ self.model: %@", typeName, self.model);
      NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.model requiringSecureCoding:NO error:outError];
        
      if (!data && outError)
        {
          NSLog(@"Archiving failed with error: %@", *outError);
          return nil;
        }
        
      NSLog(@"Successfully encoded the data: %@", data);
      return data;
    }
  @catch (NSException *exception)
    {
      NSLog(@"Exception caught during archiving: %@", exception);
      if (outError)
        {
           *outError = [NSError errorWithDomain:NSCocoaErrorDomain
                                           code:NSFileWriteUnknownError
                                       userInfo:@{NSLocalizedDescriptionKey: [exception reason]}];
        }
      return nil;
    } 

}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
  // Unarchive the model from the data
  self.model = [NSKeyedUnarchiver unarchivedObjectOfClass:[DSAAdventure class] fromData:data error:outError];
    
  // If unarchiving fails, return NO and pass the error
  if (!self.model && outError)
    {
      return NO;
    }
 
  return YES;
}

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError **)outError
{    
  // Load data from file
  NSData *data = [NSData dataWithContentsOfURL:url];
  if (!data)
    {
      NSLog(@"Failed to read data from URL: %@", url);
      return NO;
    }
    
  // Unarchive model object from NSData
  self.model = [NSKeyedUnarchiver unarchivedObjectOfClass:[DSAAdventure class] fromData:data error:outError];
  if (!self.model)
    {
      NSLog(@"Failed to unarchive model");
      return NO;
    }
    
  // Notify that the document has been successfully loaded
  [self updateChangeCount:NSChangeCleared];
    
  // Force initialization of the UI if lazy loading is used
  if (self.windowControllersCreated)
    {
      NSLog(@"DSAAdventureDocument: windowControllers already created");
      //[windowController showWindow:self];
      
      return YES; // Don't create again
    }  
  self.windowControllersCreated = YES;  
  DSAAdventureWindowController *windowController = [[DSAAdventureWindowController alloc] initWithWindowNibName:[self windowNibName]];
  [self addWindowController:windowController];
  [windowController showWindow:self];
    
  return YES;
}

- (BOOL)isDocumentEdited
{
    NSLog(@"DSAAdventureDocument isDocumentEdited called!");
    BOOL edited = [super isDocumentEdited];
    NSLog(@"DSAAdventureDocument isDocumentEdited returning: %@", edited ? @"YES" : @"NO");
    return edited;
}

- (BOOL)canCloseDocument
{
    NSLog(@"DSAAdventureDocument canCloseDocument called!");

    NSWindow *closingWindow = [[NSApplication sharedApplication] keyWindow];
    if (![self isMainWindow: closingWindow])
      {
        return YES;
      }
    
/*    
    if ([closingWindow.windowController isKindOfClass:[DSAAdventureWindowController class]]) {
        if ([closingWindow.windowController != self.windowControllers[0]]) {
            NSLog(@"DSAAdventureDocument: Auxiliary window closing, bypassing save check.");
            return YES; // Allow the window to close without saving.
        }
    }
*/
    return [super canCloseDocument]; // Default behavior: Allow the standard save check.
}

@end



