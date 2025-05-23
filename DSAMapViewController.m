/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-11-02 21:28:34 +0100 by sebastia

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

#import "DSAMapViewController.h"
#import "DSAMapOverlayView.h"
#import "DSALocations.h"

@implementation DSAMapViewController 

- (instancetype)init
{
  self = [super initWithWindowNibName:@"DSAMapViewer"];
  if (self)
    {
      self.currentZoomLevel = 0.5; // Set the default zoom level, to be the same as in DSAMapOverlayView
    }
  return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    // NSLog(@"DSAMapViewController windowDidLoad called!");
    
    // Load the map image
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"Aventurien" ofType:@"jpg"];
    NSImage *mapImage = [[NSImage alloc] initByReferencingFile:imagePath];
    if (!mapImage) {
        NSLog(@"Failed to load map image.");
        return;
    }
    
    // NSLog(@"DSAMapViewController image loaded");
    
    // Use NSBitmapImageRep to get the original image dimensions
    NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithData:[mapImage TIFFRepresentation]];
    if (!bitmapRep) {
        NSLog(@"Failed to load bitmap representation of the image.");
        return;
    }
    
    NSSize originalSize = NSMakeSize(bitmapRep.pixelsWide, bitmapRep.pixelsHigh);
    // NSLog(@"Original image size (from NSBitmapImageRep): %@", NSStringFromSize(originalSize));
    
    // Create an NSImageView with the original image dimensions
    self.mapImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, originalSize.width, originalSize.height)];
    //NSLog(@"mapImageView rect: %@", NSStringFromRect(NSMakeRect(0, 0, originalSize.width, originalSize.height)));
    //NSLog(@"mapImageView size: %@", NSStringFromRect([self.mapImageView frame]));
    
    [self.mapImageView setImageAlignment:NSImageAlignTopLeft];
    [self.mapImageView setImageScaling:NSImageScaleProportionallyUpOrDown]; // Avoid any scaling
    [self.mapImageView setImage:mapImage];
    [self.mapImageView.image setSize:originalSize];
    // NSLog(@"Image size within mapImageView: %@", NSStringFromSize(self.mapImageView.image.size));
    
    // Set the NSImageView as the content view of the NSScrollView
    [self.mapScrollView setDocumentView:self.mapImageView];
     
    // Initialize the slider
    [self.sliderZoom setDoubleValue:self.currentZoomLevel];
    
    // NSLog(@"Initial slider value: %f minValue: %f, maxValue: %f", [self.sliderZoom doubleValue], [self.sliderZoom minValue], [self.sliderZoom maxValue]);
    
    // Set the initial scale of the image view based on the slider
    [self setImageViewScale:[self.sliderZoom doubleValue]]; // Apply initial zoom level
    
    // Hide scrollbars
    [self.mapScrollView setHasVerticalScroller:NO];
    [self.mapScrollView setHasHorizontalScroller:NO];
    [self.mapScrollView setAutohidesScrollers:NO];
    
    // Calculate the center of the image
    NSPoint centerCoordinates = NSMakePoint(originalSize.width / 2, originalSize.height / 2);
    
    // Jump to the center of the map
    [self jumpToLocationWithCoordinates:centerCoordinates];    
    
    // Load the locations
    [self loadLocations];

    
    // Load regions and streets data
    [self loadRegions];
    [self loadStreets];

    // Create and add region overlay
    DSARegionsOverlayView *regionsOverlay = [[DSARegionsOverlayView alloc] initWithFrame:self.mapImageView.bounds features:self.regions];
    if ([self.switchRegions state] == NSControlStateValueOff)
      {
        regionsOverlay.hidden = YES;
      }
    [self.mapScrollView addOverlay:regionsOverlay];

    // Create and add streets overlay
    DSAStreetsOverlayView *streetsOverlay = [[DSAStreetsOverlayView alloc] initWithFrame:self.mapImageView.bounds features:self.streets];
    if ([self.switchStreets state] == NSControlStateValueOff)
      {
        streetsOverlay.hidden = YES;
      }
    [self.mapScrollView addOverlay:streetsOverlay];    

    self.routePlanner = [[DSARoutePlanner alloc] initWithBundleFiles];
    DSARouteOverlayView  *routeOverlay = [[DSARouteOverlayView alloc] initWithFrame:self.mapImageView.bounds features:@[]];
    routeOverlay.hidden = YES; // Initially hidden until a route is calculated
    [self.mapScrollView addOverlay: routeOverlay];    
             

    // Set the delegate of the Comboboxes
    // Load available locations
    DSALocations *locations = [DSALocations sharedInstance];
    self.locationsArray = [locations locationNames];
    self.filteredLocations = self.locationsArray;    
    
    self.fieldLocationSearch.usesDataSource = YES;
    self.fieldLocationSearch.delegate = self;
    self.fieldLocationSearch.dataSource = self;
    self.fieldLocationDestination.usesDataSource = YES;
    self.fieldLocationDestination.delegate = self;
    self.fieldLocationDestination.dataSource = self;   
      
    // NSLog(@"Window loaded successfully.");
}

- (void)loadLocations
{
  NSString *path = [[NSBundle mainBundle] pathForResource:@"Orte" ofType:@"json"];
  NSError *error;
    
  if (path)
    {
      NSData *data = [NSData dataWithContentsOfFile:path];
           
      NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        
      if (error)
        {
          NSLog(@"Error parsing JSON: %@", error.localizedDescription);
          return;
        }
        
      self.locations = jsonArray;
    }
  else
    {
      NSLog(@"Could not find Orte.json file.");
    }
    
  path = [[NSBundle mainBundle] pathForResource:@"Magierakademien" ofType:@"json"];
  self.mageAcademies = [NSJSONSerialization 
      JSONObjectWithData: [NSData dataWithContentsOfFile: path]
                 options: NSJSONReadingMutableContainers
                   error: &error];
                   
  path = [[NSBundle mainBundle] pathForResource:@"Kriegerakademien" ofType:@"json"];
  self.warriorAcademies = [NSJSONSerialization 
      JSONObjectWithData: [NSData dataWithContentsOfFile: path]
                 options: NSJSONReadingMutableContainers
                   error: &error];                   
                         
}

- (void)loadRegions {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Regionen" ofType:@"geojson"];
    if (!path) {
        NSLog(@"Regionen.geojson not found!");
        return;
    }
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSError *error;
    NSDictionary *geojson = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    if (error) {
        NSLog(@"Error parsing Regionen.geojson: %@", error.localizedDescription);
        return;
    }
    
    self.regions = geojson[@"features"]; // Save features for later drawing
    [self.mapImageView setNeedsDisplay:YES]; // Redraw the map
}

- (IBAction)toggleRegions:(id)sender {
    BOOL isVisible = ([sender state] == NSControlStateValueOn);
    for (DSAMapOverlayView *overlay in ((DSAPannableScrollView *)self.mapScrollView).overlays) {
        if ([overlay isKindOfClass:[DSARegionsOverlayView class]]) {
            overlay.hidden = !isVisible;
            break; // Found the Regions overlay, no need to continue
        }
    }
}

- (IBAction)calculateRoute:(id)sender {
    NSString *startLocation = self.fieldLocationSearch.stringValue;
    NSString *destinationLocation = self.fieldLocationDestination.stringValue;

    if (startLocation.length == 0 || destinationLocation.length == 0) {
        NSLog(@"Error: Start or destination field is empty.");
        return;
    }

    NSArray<NSValue *> *path = [self.routePlanner findShortestPathFrom:startLocation to:destinationLocation];

    if (!path || path.count < 2) {
        NSLog(@"No valid route found.");
        return;
    }

    NSLog(@"Route found! Updating overlay.");
    DSARouteOverlayView *routeOverlay;
    for (DSARouteOverlayView *overlay in ((DSAPannableScrollView *)self.mapScrollView).overlays) {
        if ([overlay isKindOfClass:[DSARouteOverlayView class]]) {
            overlay.hidden = NO;
            routeOverlay = overlay;
            break; // Found the Regions overlay, no need to continue
        }
    }    
    [routeOverlay updateRouteWithPoints:path];
}


- (void)loadStreets {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Strassen" ofType:@"geojson"];
    if (!path) {
        NSLog(@"Strassen.geojson not found!");
        return;
    }
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSError *error;
    NSDictionary *geojson = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    if (error) {
        NSLog(@"Error parsing Strassen.geojson: %@", error.localizedDescription);
        return;
    }
    
    self.streets = geojson[@"features"]; // Save features for later drawing
    [self.mapImageView setNeedsDisplay:YES]; // Redraw the map
}

- (IBAction)toggleStreets:(id)sender {
    BOOL isVisible = ([sender state] == NSControlStateValueOn);

    for (DSAMapOverlayView *overlay in ((DSAPannableScrollView *)self.mapScrollView).overlays) {
        if ([overlay isKindOfClass:[DSAStreetsOverlayView class]]) {
            overlay.hidden = !isVisible;
            break;
        }
    }
}

- (NSPoint)coordinatesForLocation:(NSString *)locationName {
    // Iterate through the locations array to find the matching location name
    for (NSDictionary *location in self.locations) {
        if ([location[@"name"] isEqualToString:locationName]) {
            // Return the coordinates as NSPoint
            // NSLog(@"found location: %@ at %@", locationName, NSStringFromPoint(NSMakePoint([location[@"x"] floatValue], [location[@"y"] floatValue])));
            return NSMakePoint([location[@"x"] floatValue], [location[@"y"] floatValue]);
        }
    }
    NSLog(@"DSAMapViewController coordinatesForLocation: didn't find location: %@", locationName);
    return NSZeroPoint; // Return zero point if not found
}

- (IBAction)zoomChanged:(id)sender {
    double zoomFactor = [self.sliderZoom doubleValue]; // Get zoom factor from slider
    //NSLog(@"Slider changed, new zoom factor: %f", zoomFactor); // Log zoom factor
    
    // Only update if the zoom factor has changed
    if (fabs(zoomFactor - self.currentZoomLevel) > 0.001) { // Consider a small tolerance
        // NSLog(@"Slider changed, new zoom factor: %f", zoomFactor);
        self.currentZoomLevel = zoomFactor; // Update the current zoom level
        [self setImageViewScale:zoomFactor]; // Scale the image view based on slider value
    }
}

- (void)setImageViewScale:(CGFloat)scale {
    self.currentZoomLevel = scale; 
    // NSLog(@"setImageViewScale called with scale: %lf", scale);
    NSSize newSize = NSMakeSize(self.mapImageView.image.size.width * scale, 
                                self.mapImageView.image.size.height * scale);

    [self.mapImageView setFrame:NSMakeRect(0, 0, newSize.width, newSize.height)];

    // Update overlays
    for (DSAMapOverlayView *overlay in self.mapScrollView.overlays) {
        // NSLog(@"setImageViewScale setting zoom facter in overlay to %lf", scale);
        overlay.zoomFactor = scale;  // Pass zoom factor
        [overlay setFrame:NSMakeRect(0, 0, newSize.width, newSize.height)];
        [overlay setNeedsDisplay:YES]; 
    }

    [self.mapScrollView setDocumentView:self.mapImageView];

    NSRect visibleRect = [self.mapScrollView.contentView documentVisibleRect];
    NSPoint center = NSMakePoint(NSMidX(visibleRect), NSMidY(visibleRect));

    [[self.mapScrollView contentView] scrollToPoint:center];
    [self.mapScrollView reflectScrolledClipView:[self.mapScrollView contentView]];
}

- (void)searchLocation:(NSComboBox *) sender {
    NSString *locationName = [sender stringValue];
    
    // You would typically have a dictionary or array that maps location names to coordinates.
    // For simplicity, let’s assume we have a method to get the coordinates:
    NSPoint coordinates = [self coordinatesForLocation:locationName];
    
    if (!NSEqualPoints(coordinates, NSZeroPoint)) {
        [self jumpToLocationWithCoordinates:coordinates];
        [self showInfosForLocationWithName: locationName];
        // [self displayPopupForLocation:locationName atCoordinates:coordinates];
    } else {
        NSLog(@"DSAMapViewController searchLocation: Location not found: %@", locationName);
    }
}


- (void)jumpToLocationWithCoordinates:(NSPoint)coordinates {
    // 1. Flip the Y-coordinate to match the scroll view's coordinate system (origin at bottom-left)
    // CGFloat flippedY = self.mapImageView.image.size.height - coordinates.y;
    // NSPoint adjustedCoordinates = NSMakePoint(coordinates.x, flippedY);
    NSPoint adjustedCoordinates = NSMakePoint(coordinates.x, coordinates.y);
    
    // 2. Adjust coordinates based on the current zoom level
    CGFloat zoomFactor = [self.sliderZoom doubleValue]; // Assuming this is your zoom level slider value
    NSPoint scaledCoordinates = NSMakePoint(adjustedCoordinates.x * zoomFactor, adjustedCoordinates.y * zoomFactor);
    
    // 3. Calculate the offset to center the location in the scroll view's visible area
    NSScrollView *scrollView = self.mapScrollView;
    NSSize contentSize = scrollView.contentSize;
    
    // Calculate the point to scroll to such that the location is centered in the view
    NSPoint targetPoint = NSMakePoint(scaledCoordinates.x - contentSize.width / 2,
                                      scaledCoordinates.y - contentSize.height / 2);
    
    // 4. Clamp targetPoint to ensure it stays within the bounds of the scaled image view's frame
    NSRect imageBounds = self.mapImageView.bounds;
    if (targetPoint.x < imageBounds.origin.x) {
        targetPoint.x = imageBounds.origin.x;
    } else if (targetPoint.x + contentSize.width > NSMaxX(imageBounds)) {
        targetPoint.x = NSMaxX(imageBounds) - contentSize.width;
    }
    if (targetPoint.y < imageBounds.origin.y) {
        targetPoint.y = imageBounds.origin.y;
    } else if (targetPoint.y + contentSize.height > NSMaxY(imageBounds)) {
        targetPoint.y = NSMaxY(imageBounds) - contentSize.height;
    }

    // 5. Scroll to the calculated point
    [[scrollView contentView] scrollToPoint:targetPoint];
    [scrollView reflectScrolledClipView:[scrollView contentView]];
}

# pragma mark - NSCombobox related stuffs

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)comboBox {
    // NSLog(@"DSAAdventureGenerationController numberOfItemsInComboBox called");
    return self.filteredLocations.count;
}

- (id)comboBox:(NSComboBox *)comboBox objectValueForItemAtIndex:(NSInteger)index {
    // NSLog(@"DSAAdventureGenerationController objectValueForItemAtIndex called");
    return self.filteredLocations[index];
}

- (void)comboBoxWillDismiss:(NSNotification *)notification {
    // NSLog(@"DSAAdventureGenerationController comboBoxWillDismiss called Notification sender %@", notification.object);
    NSComboBox *comboBox = (NSComboBox *)notification.object;
    NSString *text = [comboBox stringValue];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", text];
    self.filteredLocations = [self.locationsArray filteredArrayUsingPredicate:predicate];
    [comboBox reloadData];
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification {
    // NSLog(@"DSAAdventureGenerationController comboBoxSelectionDidChange called");
    NSComboBox *comboBox = (NSComboBox *)notification.object;
    NSInteger selectedIndex = [comboBox indexOfSelectedItem];

    if (selectedIndex >= 0) {
        NSString *selectedItem = self.filteredLocations[selectedIndex]; // Get from filtered list
        // NSLog(@"comboBoxSelectionDidChange called: %@", selectedItem);
        
        // Ensure OK button is updated based on selection
        BOOL isValid = [self.locationsArray containsObject:selectedItem];
        //[self.okButton setEnabled:isValid];
        if (isValid)
          {
            [self searchLocation: comboBox];  
          }
    }
}

- (void)controlTextDidChange:(NSNotification *)notification {
    // NSLog(@"DSAAdventureGenerationController controlTextDidChange called Notification sender %@", notification.object);
    NSComboBox *comboBox = (NSComboBox *)notification.object;
    NSString *input = [comboBox stringValue];
    
    // Filter locations
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH[c] %@", input];
    self.filteredLocations = [self.locationsArray filteredArrayUsingPredicate:predicate];

    // Refresh the combo box data
    [comboBox reloadData];
    [comboBox noteNumberOfItemsChanged]; // Ensure UI refresh

    // Enable OK button only if input exactly matches a known location
    // NSLog(@"controlTextDidChange: location: %@ ARRAY: %@", input, self.locationsArray);
    BOOL isValid = [self.locationsArray containsObject:input];
    //[self.okButton setEnabled:isValid];
    if (isValid)
      {
        [self searchLocation: comboBox];
      }
}

- (void)showInfosForLocationWithName: (NSString *) name {
    NSLog(@"DSAMapViewController showInfosForLocationWithName %@", name);
    DSALocations *locations = [DSALocations sharedInstance];
    NSString *plainInfo = [locations plainInfoForLocationWithName: name];
    
    self.locationInfos.stringValue = plainInfo;
}

@end
