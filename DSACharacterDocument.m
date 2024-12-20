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
#import "DSACharacterMagic.h"
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

- (NSString *)windowNibName
{
  NSLog(@"DSACharacterDocument: windowNibName was called");
  // Return the name of the .gorm file that defines the document's UI
  return @"DSACharacter";
}

// we don't want the windows to pop up on startup
- (void)makeWindowControllers
{ 
  if (self.windowControllersCreated)
    {
      NSLog(@"DSACharacterDocument: windowControllers already created");
      return; // Don't create again
    }
    self.windowControllersCreated = YES;
  
  if (![self.model isMemberOfClass:[DSACharacter class]])
    {
      DSACharacterWindowController *windowController = [[DSACharacterWindowController alloc] initWithWindowNibName:[self windowNibName]];
      [self addWindowController:windowController];
      
      NSLog(@"DSACharacterDocument makeWindowControllers called, and it was DSACharacter class" );
    }
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
  [windowController showWindow:self];
    
  return YES;
}

- (void)printDocument:(id)sender
{
  NSInteger pages = 3;  // standard non-magical character
  if ([self.model conformsToProtocol:@protocol(DSACharacterMagic)])  // add pages for spells
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

@end



