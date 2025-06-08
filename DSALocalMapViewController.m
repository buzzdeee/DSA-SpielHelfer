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
#import "DSAMapCoordinate.h"
#import "DSAAdventure.h"
#import "DSAAdventureGroup.h"

@implementation DSALocalMapViewController

- (instancetype)initWithMode:(DSALocalMapViewMode)mode adventure:(DSAAdventure *)adventure {
    NSString *nibName = (mode == DSALocalMapViewModeGameMaster)
        ? @"DSALocalMapView"
        : @"DSALocalMapView_Adventure";

    self = [super initWithWindowNibName:nibName];
    if (self) {
        _viewMode = mode;
        _adventure = adventure;
    }
    NSLog(@"DSALocalMapViewController initWithMode called, returning self: %@", self);
    return self;
}

- (void)dealloc {
    NSLog(@"DSALocalMapViewController is being deallocated.");
    [[NSNotificationCenter defaultCenter] removeObserver:self]; 
}

- (void)windowDidLoad {
    [super windowDidLoad];
    NSLog(@"DSALocalMapViewController windowDidLoad called!");
    switch (self.viewMode) {
        case DSALocalMapViewModeGameMaster:
            [self setupGameMasterMode];
            break;

        case DSALocalMapViewModeAdventure:
            [self setupAdventureMode];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                         selector:@selector(redrawMap)
                                             name:@"DSAAdventureCharactersUpdated"
                                           object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                         selector:@selector(redrawMap)
                                             name:@"DSAAdventureLocationUpdated"
                                           object:nil];                                           
            break;
    }
}

#pragma mark - Game Master Mode
- (void) setupGameMasterMode
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
      [self setupGameMasterMode];
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

#pragma mark - Adventure Mode

- (void) redrawMap
{
  NSLog(@"DSALocalMapViewController redrawMap called!!!!");
  [self.adventureMapView setNeedsDisplay:YES];
}

- (void) setupAdventureMode
{
  NSLog(@"DSALocalMapViewController setupAdventureMode called!");
  DSAPosition *currentPosition = self.adventure.activeGroup.position;
  DSADirection heading = self.adventure.activeGroup.headingDirection;
  NSString *localLocationName = currentPosition.localLocationName;
  NSInteger level = currentPosition.mapCoordinate.level;
  
  DSALocations *sharedLocations = [DSALocations sharedInstance];
  DSALocalMapLevel *mapLevel = [sharedLocations getLocalLocationMapWithName: localLocationName
                                                                    ofLevel: level];
                                                                    
  [self.adventureMapView setMapArray: mapLevel.mapTiles];
  [self.adventureMapView setFrameSize:[self.adventureMapView intrinsicContentSize]];
  [self.adventureMapView setGroupPosition: currentPosition heading: heading];
  self.adventureMapView.adventure = self.adventure;
  [self.adventureMapView discoverVisibleTilesAroundPosition:currentPosition];
  [self.window makeFirstResponder:self.adventureMapView];
}

@end
