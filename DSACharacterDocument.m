/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-09-07 23:45:46 +0200 by sebastia

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

#import "DSACharacterDocument.h"
#import "DSACharacterWindowController.h"
#import "DSACharacter.h"
#import "DSACharacterPrintView.h"

@implementation DSACharacterDocument

@synthesize model = _model;

- (instancetype)init
{
  self = [super init];
  if (self)
    {
      // Initialize your document here
      self.model = [[DSACharacter alloc] init];                                         
    }
  NSLog(@"DSACharacterDocument init was called");  
  return self;
}

- (void)dealloc
{
  NSLog(@"DSACharacterDocument is being deallocated.");
}

- (void)close
{
    NSLog(@"DSACharacterDocument close called!");
    [super close];
}

- (NSString *)windowNibName
{
  NSLog(@"DSACharacterDocument: windowNibName was called");
  // Return the name of the .gorm file that defines the document's UI
  return @"DSACharacter";
}

// we don't want the windows to pop up on startup
- (void)makeWindowControllers
{ 
  NSLog(@"DSACharacterDocument makeWindowControllers");
  if (self.windowControllersCreated && [self.windowControllers count] > 0)
    {
      NSLog(@"DSACharacterDocument: windowControllers already created");
      return; // Don't create again
    }
    
  
  if (![self.model isMemberOfClass:[DSACharacter class]])
    {
      NSLog(@"DSACharacterDocument makeWindowControllers skipped window creation on load, but now GOING TO CREATE WINDOW Controller");
      DSACharacterWindowController *windowController = [[DSACharacterWindowController alloc] initWithWindowNibName:[self windowNibName]];
      [self addWindowController:windowController];
      self.windowControllersCreated = YES;
    }
  else
    {
      NSLog(@"DSACharacterDocument makeWindowControllers called, and it was DSACharacter class, NOT creating window Controller" );
    }
}

- (void)showCharacterWindow {
    NSLog(@"DSACharacterDocument showCharacterWindow: %@ %@", [NSNumber numberWithBool: self.windowControllersCreated], [NSNumber numberWithInteger: [self.windowControllers count]]);
    if (!self.windowControllersCreated || [self.windowControllers count] == 0) {
        NSLog(@"DSACharacterDocument showCharacterWindow BEFORE makeWindowControllers");
        [self makeWindowControllers]; // Manually create window controllers if not already created
        NSLog(@"DSACharacterDocument showCharacterWindow AFTER makeWindowControllers");
    }
    NSLog(@"DSACharacterDocument showCharacterWindow BEFORE showWindows");
    [self showWindows]; // Show the window only when explicitly requested
    NSLog(@"DSACharacterDocument showCharacterWindow AFTER showWindows");
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
      NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.model requiringSecureCoding:NO error:outError];
        
      if (!data && outError)
        {
          NSLog(@"DSACharacterDocument dataOfType: Archiving failed with error: %@", *outError);
          return nil;
        }
        
      NSLog(@"DSACharacterDocument dataOfType: Successfully encoded the data");
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
  self.model = [NSKeyedUnarchiver unarchivedObjectOfClass:[DSACharacter class] fromData:data error:outError];
    
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
  self.model = [NSKeyedUnarchiver unarchivedObjectOfClass:[DSACharacter class] fromData:data error:outError];
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
      NSLog(@"DSACharacterDocument: windowControllers already created");
      //[windowController showWindow:self];
      
      return YES; // Don't create again
    }  
  self.windowControllersCreated = YES;  
  DSACharacterWindowController *windowController = [[DSACharacterWindowController alloc] initWithWindowNibName:[self windowNibName]];
  [self addWindowController:windowController];
  // [windowController showWindow:self];
    
  return YES;
}

- (void)printDocument:(id)sender
{
  NSInteger pages = 3;  // standard non-magical character
  if ([self.model isMagic])  // add pages for spells
    {
      pages = 6;
    }
  else if ([self.model isMagicalDabbler])  // add page for spells and extras
    {
      pages = 4;
    }
  DSACharacterPrintView *printView = [[DSACharacterPrintView alloc] initWithFrame:NSMakeRect(0, 0, PAGE_WIDTH, PAGE_HEIGHT * pages)];
  printView.model = self.model; // Fill with your model data
  printView.pages = pages;

  NSPrintOperation *printOperation = [NSPrintOperation printOperationWithView:printView];
  [printOperation runOperation];
}


- (BOOL)isDocumentEdited
{
    //NSLog(@"DSACharacterDocument isDocumentEdited called!");
    BOOL edited = [super isDocumentEdited];
    //NSLog(@"DSACharacterDocument isDocumentEdited returning: %@", edited ? @"YES" : @"NO");
    return edited;
}

- (BOOL)canCloseDocument
{
    //NSLog(@"DSACharacterDocument canCloseDocument called!");

    NSWindow *closingWindow = [[NSApplication sharedApplication] keyWindow];
    if (![self isMainWindow: closingWindow])
      {
        return YES;
      }
    return [super canCloseDocument]; // Default behavior: Allow the standard save check.
}

@end



