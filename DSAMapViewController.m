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

@implementation DSAMapViewController 

- (instancetype)init
{
  self = [super initWithWindowNibName:@"DSAMapViewer"];
  if (self)
    {
      self.currentZoomLevel = 0.5; // Set the default zoom level
    }
  return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    NSLog(@"DSAMapViewController windowDidLoad called!");
    
    // Load the map image
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"Aventurien" ofType:@"jpg"];
    NSImage *mapImage = [[NSImage alloc] initByReferencingFile:imagePath];
    if (!mapImage) {
        NSLog(@"Failed to load map image.");
        return;
    }
    
    NSLog(@"DSAMapViewController image loaded");
    
    // Use NSBitmapImageRep to get the original image dimensions
    NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithData:[mapImage TIFFRepresentation]];
    if (!bitmapRep) {
        NSLog(@"Failed to load bitmap representation of the image.");
        return;
    }
    
    NSSize originalSize = NSMakeSize(bitmapRep.pixelsWide, bitmapRep.pixelsHigh);
    NSLog(@"Original image size (from NSBitmapImageRep): %@", NSStringFromSize(originalSize));
    
    // Create an NSImageView with the original image dimensions
    self.mapImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, originalSize.width, originalSize.height)];
    NSLog(@"mapImageView rect: %@", NSStringFromRect(NSMakeRect(0, 0, originalSize.width, originalSize.height)));
    NSLog(@"mapImageView size: %@", NSStringFromRect([self.mapImageView frame]));
    
    [self.mapImageView setImageAlignment:NSImageAlignTopLeft];
    [self.mapImageView setImageScaling:NSImageScaleProportionallyUpOrDown]; // Avoid any scaling
    [self.mapImageView setImage:mapImage];
    [self.mapImageView.image setSize:originalSize];
    NSLog(@"Image size within mapImageView: %@", NSStringFromSize(self.mapImageView.image.size));
    
    // Set the NSImageView as the content view of the NSScrollView
    [self.mapScrollView setDocumentView:self.mapImageView];
     
    // Initialize the slider
    [self.sliderZoom setDoubleValue:self.currentZoomLevel];
    
    NSLog(@"Initial slider value: %f minValue: %f, maxValue: %f", [self.sliderZoom doubleValue], [self.sliderZoom minValue], [self.sliderZoom maxValue]);
    
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
    
    // Initialize the list selector popover controller
    self.listSelectorPopoverVC = [[DSAListSelectorPopoverViewController alloc] init];
    // Initialize the popover and set its contentViewController
    self.listPopover = [[NSPopover alloc] init];
    NSLog(@"ONE");
//    self.listPopover.contentViewController = self.listSelectorPopoverVC;
    NSLog(@"TWO");
    self.listPopover.behavior = NSPopoverBehaviorTransient;    

    // Set the selection handler
    __weak typeof(self) weakSelf = self;
    self.listSelectorPopover.locationSelected = ^(NSDictionary *location) {
        [weakSelf jumpToLocationWithCoordinates:NSMakePoint([location[@"x"] floatValue], [location[@"y"] floatValue])];
    };        
    
/*    __weak typeof(self) weakSelf = self;
    self.listSelectorPopoverVC.locationSelected = ^(NSDictionary *location) {
        [weakSelf jumpToLocationWithCoordinates:NSMakePoint([location[@"x"] floatValue], [location[@"y"] floatValue])];
        weakSelf.fieldLocationSearch.stringValue = location[@"name"];
        [weakSelf.listPopover performClose:nil]; // Close the popover
    };
  */  

    self.testPopover = [[NSPopover alloc] init];
    self.testPopover.behavior = NSPopoverBehaviorTransient;
//    self.testPopover.contentViewController = [[NSViewController alloc] init];
    NSLog(@"Popover initialized in windowDidLoad.");  

    // Set the delegate of the text field to listen for changes
    [self.fieldLocationSearch setDelegate:self];
  
    NSLog(@"Window loaded successfully.");
}

- (void)controlTextDidChange:(NSNotification *)notification {
    if (notification.object == self.fieldLocationSearch) {
        NSLog(@"Search text changed.");

        // Show the retained popover
        @try {
            [self.testPopover showRelativeToRect:self.fieldLocationSearch.bounds
                                          ofView:self.fieldLocationSearch
                                   preferredEdge:0];
        }
        @catch (NSException *exception) {
            NSLog(@"Exception when trying to show popover: %@, %@", exception.name, exception.reason);
        }
    }
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

- (NSPoint)coordinatesForLocation:(NSString *)locationName {
    // Iterate through the locations array to find the matching location name
    for (NSDictionary *location in self.locations) {
        if ([location[@"name"] isEqualToString:locationName]) {
            // Return the coordinates as NSPoint
            NSLog(@"found location: %@ at %@", locationName, NSStringFromPoint(NSMakePoint([location[@"x"] floatValue], [location[@"y"] floatValue])));
            return NSMakePoint([location[@"x"] floatValue], [location[@"y"] floatValue]);
        }
    }
    NSLog(@"didn't find location: %@", locationName);
    return NSZeroPoint; // Return zero point if not found
}

- (IBAction)zoomChanged:(id)sender {
    double zoomFactor = [self.sliderZoom doubleValue]; // Get zoom factor from slider
    //NSLog(@"Slider changed, new zoom factor: %f", zoomFactor); // Log zoom factor
    
    // Only update if the zoom factor has changed
    if (fabs(zoomFactor - self.currentZoomLevel) > 0.001) { // Consider a small tolerance
        NSLog(@"Slider changed, new zoom factor: %f", zoomFactor);
        self.currentZoomLevel = zoomFactor; // Update the current zoom level
        [self setImageViewScale:zoomFactor]; // Scale the image view based on slider value
    }
}

- (void)setImageViewScale:(CGFloat)scale {
    NSSize originalSize = self.mapImageView.image.size;
    NSSize newSize = NSMakeSize(originalSize.width * scale, originalSize.height * scale);

    // Optional offsets for fine-tuning, adjust as needed
    CGFloat offsetX = 0; 
    CGFloat offsetY = 0; 

    NSLog(@"BORDER WIDTH: %lu", (unsigned long)[self.mapImageView imageFrameStyle]);

    // **Get the current visible rectangle in image coordinates**
    NSRect visibleRectInImage = [self.mapImageView convertRect:[self.mapScrollView.contentView documentVisibleRect]
                                                      fromView:self.mapScrollView.contentView];

    // **Log current frames and bounds for debugging**
    NSLog(@"NSScrollView frame: %@", NSStringFromRect(self.mapScrollView.frame));
    NSLog(@"NSScrollView bounds: %@", NSStringFromRect(self.mapScrollView.bounds));
    NSLog(@"NSImageView frame (before resizing): %@", NSStringFromRect(self.mapImageView.frame));
    NSLog(@"NSImageView bounds: %@", NSStringFromRect(self.mapImageView.bounds));
    NSLog(@"NSImage size: %@", NSStringFromSize(originalSize));

    // Resize the image view
    [self.mapImageView setFrame:NSMakeRect(0, 0, newSize.width, newSize.height)];
    [self.mapScrollView setDocumentView:self.mapImageView];

    NSLog(@"NSImageView frame (after resizing): %@", NSStringFromRect(self.mapImageView.frame));

    // **Calculate the center of the visible rectangle**
    NSPoint visibleCenterInImage = NSMakePoint(NSMidX(visibleRectInImage), NSMidY(visibleRectInImage));
    NSLog(@"Visible Center in Image: %@", NSStringFromPoint(visibleCenterInImage));

    // Calculate new origin point to keep the focus
    NSPoint newOrigin = NSMakePoint(
        visibleCenterInImage.x - visibleRectInImage.size.width / 2 + offsetX,
        visibleCenterInImage.y - visibleRectInImage.size.height / 2 + offsetY
    );

    // Ensure the new origin doesn't exceed the image bounds
    newOrigin.x = MAX(0, MIN(newOrigin.x, newSize.width - visibleRectInImage.size.width));
    newOrigin.y = MAX(0, MIN(newOrigin.y, newSize.height - visibleRectInImage.size.height));

    // Scroll to the adjusted origin point
    [[self.mapScrollView contentView] scrollToPoint:newOrigin];
    [self.mapScrollView reflectScrolledClipView:[self.mapScrollView contentView]];
    [self.mapScrollView setNeedsDisplay:YES];

    // Log the final calculated origin
    NSLog(@"Final origin point after adjustments: %@", NSStringFromPoint(newOrigin));
}

- (IBAction)searchLocation:(id)sender {
    NSString *locationName = [self.fieldLocationSearch stringValue];
    
    // You would typically have a dictionary or array that maps location names to coordinates.
    // For simplicity, let’s assume we have a method to get the coordinates:
    NSPoint coordinates = [self coordinatesForLocation:locationName];
    
    if (!NSEqualPoints(coordinates, NSZeroPoint)) {
        [self jumpToLocationWithCoordinates:coordinates];
        [self displayPopupForLocation:locationName atCoordinates:coordinates];
    } else {
        NSLog(@"Location not found: %@", locationName);
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

- (void)displayPopupForLocation:(NSString *)locationName atCoordinates:(NSPoint)coordinates {
    NSMutableString *popupText = [NSMutableString string];
    
    // Find the location in self.locations
    NSDictionary *location = nil;
    for (NSDictionary *loc in self.locations) {
        if ([loc[@"name"] isEqualToString:locationName]) {
            location = loc;
            break;
        }
    }
    
    if (!location) {
        NSLog(@"Error: Could not find location in locations array");
        return;
    }
    
    // Basic location info (from self.locations)
    [popupText appendFormat:@"%@ (%@)\n", location[@"name"], location[@"type"]];
    
    // Check self.warriorAcademies for additional data
    NSDictionary *warriorInfo = [self findEntryWithMatchingOrt:locationName inDictionary:self.warriorAcademies];
    if (warriorInfo) {
        [popupText appendFormat:@"Warrior Academy: %@\n", warriorInfo[@"Langer Name"]];
    }
    
    // Check self.mageAcademies for additional data
    NSDictionary *mageInfo = [self findEntryWithMatchingOrt:locationName inDictionary:self.mageAcademies];
    if (mageInfo) {
        [popupText appendFormat:@"Mage Academy:\n%@\nSpecialization: %@\nLeader: %@\n",
         mageInfo[@"Weltlicher Name"],
         mageInfo[@"Spezialgebiet"],
         mageInfo[@"Akademieleiter"]];
    }
    
    // Handle the case where no additional data is found
    if (!warriorInfo && !mageInfo) {
        [popupText appendString:@"No additional information available.\n"];
    }
    
    // Display the popup
    [self showPopupWithText:popupText atCoordinates:coordinates];
}

- (NSDictionary *)findEntryWithMatchingOrt:(NSString *)locationName inDictionary:(NSDictionary *)dictionary {
    for (NSString *key in dictionary) {
        NSDictionary *entry = dictionary[key];
        if ([entry[@"Ort"] isEqualToString:locationName]) {
            return entry;
        }
    }
    return nil; // Return nil if no match is found
}

- (void)showPopupWithText:(NSString *)text atCoordinates:(NSPoint)coordinates {
    // Create the popover
    NSPopover *popover = [[NSPopover alloc] init];
    popover.behavior = NSPopoverBehaviorTransient;
    
    NSLog(@"Going to show the popup!!!");
    
    // Create a simple NSTextField for the content
    NSTextField *textField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 250, 150)];
    textField.stringValue = text;
    textField.editable = NO;
    textField.bordered = NO;
    textField.backgroundColor = [NSColor clearColor];
    
    // Set the popover's content view controller
    NSViewController *popoverController = [[NSViewController alloc] init];
    popoverController.view = textField;
    popover.contentViewController = popoverController;
    
    // Convert map coordinates to view coordinates (accounting for flipping if needed)
    NSPoint viewCoordinates = [self.mapImageView convertPoint:coordinates toView:self.mapScrollView.contentView];
    
    // Display the popover near the location
    [popover showRelativeToRect:NSMakeRect(viewCoordinates.x, viewCoordinates.y, 100, 100)
                         ofView:self.mapScrollView
                  preferredEdge:0];
}

@end