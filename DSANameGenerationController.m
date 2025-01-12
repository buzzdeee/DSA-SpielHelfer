/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-01-10 23:31:28 +0100 by sebastia

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

#import "DSANameGenerationController.h"
#import "Utils.h"
#import "DSANameGenerator.h"

@implementation DSANameGenerationController

- (instancetype)init
{
  self = [super initWithWindowNibName:@"DSANameGeneration"];
  if (self)
    {
    }
  return self;
}

- (void)windowDidLoad {

    [self.popupOrigins removeAllItems];
    [self.popupOrigins addItemsWithTitles: [[DSANameGenerator getTypesOfNames] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    [self.popupGenders removeAllItems];
    [self.popupGenders addItemsWithTitles: @[_(@"männlich"), _(@"weiblich")]];
    [self.popupNobles removeAllItems];
    [self.popupNobles addItemsWithTitles: @[_(@"Nein"), _(@"Ja")]];
    
    [self.fieldName setStringValue: @""];
    
    NSLog(@"Window loaded successfully.");
}


-(IBAction) generate: (id) sender
{
  NSString *origin = [[self.popupOrigins selectedItem] title];
  NSString *gender = [[self.popupGenders selectedItem] title];
  BOOL isNoble = [[[self.popupNobles selectedItem] title] isEqualTo: _(@"Ja")] ? YES : NO;
  NSDictionary *nameData = [Utils getNamesForRegion: origin];

  [self.fieldName setStringValue: [DSANameGenerator generateNameWithGender: gender isNoble: isNoble nameData: nameData]];
}

@end
