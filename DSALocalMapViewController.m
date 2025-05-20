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
#import "Utils.h"
#import "DSALocalMapView.h"

@implementation DSALocalMapViewController
- (instancetype)init
{
  self = [super initWithWindowNibName:@"DSALocalMapView"];
  if (self)
    {
  [self.popupCategories removeAllItems];
  //[self.popupCategories addItemWithTitle: _(@"Kategorie wählen")];
  [self.popupCategories addItemsWithTitles: [Utils getMapCategories]];      
    }
  return self;
}
/*
+ (NSArray *) getMapCategories;
+ (NSArray *) getMapsNamesOfCategory: (NSString) *category;
+ (NSArray *) getMapLevelsOfMap: (NSString *) map ofCategory: (NSString *) category;
*/

- (void)awakeFromNib
{

  NSLog(@"DSALocalMapViewController awakeFromNib called");
  [self initializePopups];
}

- (void) initializePopups
{
  [self.popupCategories removeAllItems];
  [self.popupCategories addItemWithTitle: _(@"Kategorie wählen")];
  [self.popupCategories addItemsWithTitles: [Utils getMapCategories]];
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
      [self.popupNames addItemsWithTitles: [Utils getMapNamesOfCategory: [[self.popupCategories selectedItem] title]]];
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
      //[self.popupNames addItemsWithTitles: [Utils getMapNamesOfCategory: [[self.popupCategories selectedItem] title]]];
      //[self.popupNames setEnabled: YES];
      [self.popupLevel removeAllItems];
      [self.popupLevel addItemWithTitle: _(@"Level wählen")];
      NSLog(@"DSALocalMapViewController popupNamesClicked going to get levels");
      NSArray *levels = [Utils getMapLevelsOfMap: [[self.popupNames selectedItem] title] ofCategory: [[self.popupCategories selectedItem] title]];
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
/*      [self.localMapView showMap: [[self.popupNames selectedItem] title] 
                      ofCategory: [[self.popupCategories selectedItem] title] 
                           level: [[self.popupLevel selectedItem] title]]; */
      [self.localMapView setMapArray: [Utils getMapForLocation:[[self.popupNames selectedItem] title] 
                                                    ofCategory:[[self.popupCategories selectedItem] title] 
                                                         level:[[self.popupLevel selectedItem] title]]];
      [self.localMapView setFrameSize:[self.localMapView intrinsicContentSize]];                                                         
    }

}
@end
