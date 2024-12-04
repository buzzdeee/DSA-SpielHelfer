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

#ifndef _DSAMAPVIEWCONTROLLER_H_
#define _DSAMAPVIEWCONTROLLER_H_

// DSAMapViewController.h
#import <AppKit/AppKit.h>
#import "DSAPannableScrollView.h"
#import "DSAListSelectorPopoverViewController.h"

@interface DSAMapViewController : NSWindowController <NSTextFieldDelegate>

@property (nonatomic, weak) IBOutlet DSAPannableScrollView *mapScrollView; // Connected in Gorm
@property (nonatomic, strong) DSAListSelectorPopoverViewController *listSelectorPopover;
@property (nonatomic, strong) NSImageView *mapImageView;
@property (nonatomic, strong) NSArray *locations;                 // stores the locations array read from Orte.json
@property (nonatomic, strong) NSDictionary *mageAcademies;
@property (nonatomic, strong) NSDictionary *warriorAcademies;
@property (nonatomic, assign) CGFloat currentZoomLevel;
@property (nonatomic, weak) IBOutlet NSSlider *sliderZoom;        // Slider for zooming
@property (nonatomic, weak) IBOutlet NSTextField *fieldLocationSearch; // Text field for location search

@property (strong) NSWindow *testWindow;
@property (strong, nonatomic) NSPopover *testPopover; // to be removed once testing done
@property (nonatomic, strong) NSPopover *listPopover;
//@property (nonatomic, strong) DSAListSelectorPopoverViewController *popoverContentVC;
@property (nonatomic, strong) DSAListSelectorPopoverViewController *listSelectorPopoverVC;

- (void)setupMapView; // Method to setup the map
- (void)jumpToLocationWithCoordinates:(NSPoint)coordinates; // Method to jump to a location

// Actions for slider and search
- (IBAction)zoomChanged:(id)sender; // Action for zoom slider
- (IBAction)searchLocation:(id)sender; // Action for search field

@end

#endif // _DSAMAPVIEWCONTROLLER_H_

;