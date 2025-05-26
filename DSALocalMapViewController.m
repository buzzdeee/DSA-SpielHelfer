/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-05-18 22:28:26 +0200 by sebastia

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

#import "DSALocalMapViewController.h"
#import "DSALocalMapView.h"
#import "DSALocations.h"

@implementation DSALocalMapViewController
- (instancetype)init
{
  self = [super initWithWindowNibName:@"DSALocalMapView"];
  if (self)
    {
      [self.popupCategories removeAllItems];
      DSALocations *sharedLocations = [DSALocations sharedInstance];
      [self.popupCategories addItemsWithTitles: [sharedLocations getLocalLocationCategories]];      
    }
  return self;
}

- (void)awakeFromNib
{

  NSLog(@"DSALocalMapViewController awakeFromNib called");
  [self initializePopups];
}

- (void) initializePopups
{
  DSALocations *sharedLocations = [DSALocations sharedInstance];
  [self.popupCategories removeAllItems];
  [self.popupCategories addItemWithTitle: _(@"Kategorie wählen")];
  [self.popupCategories addItemsWithTitles: [sharedLocations getLocalLocationCategories]];
  [self.popupNames removeAllItems];
  [self.popupNames addItemWithTitle: _(@"Karte wählen")];
  [self.popupNames setEnabled: NO];
  [self.popupLevel removeAllItems];
  [self.popupLevel addItemWithTitle: _(@"Level wählen")];
  [self.popupLevel setEnabled: NO];
}

- (IBAction) popupCategoriesClicked: (id) sender
{
  NSLog(@"DSALocalMapViewController popupCategoriesClicked");
  if ([[[self.popupCategories selectedItem] title] isEqualToString: _(@"Kategorie wählen")])
    {
      [self initializePopups];
    }
  else
    {
      DSALocations *sharedLocations = [DSALocations sharedInstance];
      [self.popupNames addItemsWithTitles: [sharedLocations getLocalLocationNamesOfCategory: [[self.popupCategories selectedItem] title]]];
      [self.popupNames setEnabled: YES];
      [self.popupLevel removeAllItems];
      [self.popupLevel addItemWithTitle: _(@"Level wählen")];
      [self.popupLevel setEnabled: NO];
    }
}

- (IBAction) popupNamesClicked: (id) sender
{
  NSLog(@"DSALocalMapViewController popupNamesClicked");
  if ([[[self.popupNames selectedItem] title] isEqualToString: _(@"Kategorie wählen")])
    {
      [self.popupLevel removeAllItems];
      [self.popupLevel addItemWithTitle: _(@"Level wählen")];
      [self.popupLevel setEnabled: NO];      
    }
  else
    {
      DSALocations *sharedLocations = [DSALocations sharedInstance];
      [self.popupLevel removeAllItems];
      [self.popupLevel addItemWithTitle: _(@"Level wählen")];
      NSLog(@"DSALocalMapViewController popupNamesClicked going to get levels");
      NSArray *levels = [sharedLocations getLocalLocationMapLevelsOfMap: [[self.popupNames selectedItem] title]];
      NSLog(@"DSALocalMapViewController popupNamesClicked levels: %@", levels);
      [self.popupLevel addItemsWithTitles: levels];
      [self.popupLevel setEnabled: YES];
    }
}

- (IBAction) popupLevelClicked: (id) sender
{
  NSLog(@"DSALocalMapViewController popupLevelClicked");
  if ([[[self.popupLevel selectedItem] title] isEqualToString: _(@"Level wählen")])
    {
      self.localMapView = nil;
    }
  else
    {
      DSALocations *sharedLocations = [DSALocations sharedInstance];                           
      DSALocalMapLevel *mapLevel = [sharedLocations getLocalLocationMapWithName: [[self.popupNames selectedItem] title]
                                                                        ofLevel: [[[self.popupLevel selectedItem] title] integerValue]];
      [self.localMapView setMapArray: mapLevel.mapTiles];                     
      [self.localMapView setFrameSize:[self.localMapView intrinsicContentSize]];                                                         
    }

}
@end
