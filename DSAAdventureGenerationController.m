/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-03-24 20:33:28 +0100 by sebastia

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

#import "DSAAdventureGenerationController.h"
#import "DSALocations.h"

@implementation DSAAdventureGenerationController

- (instancetype)init
{
  self = [super initWithWindowNibName:@"DSAAdventureGeneration"];
  if (self)
    {

    }
  return self;
}

- (void) startAdventureGeneration:(id)sender {
    NSLog(@"DSAAdventureGenerationController: startAdventureGeneration called");

    // Load available locations
    DSALocations *locations = [DSALocations sharedInstance];
    NSLog(@"DSAAdventureGenerationController startAdventureGeneration before getting location names");
    self.locationsArray = [locations locationNamesWithTemples];
    NSLog(@"DSAAdventureGenerationController startAdventureGeneration after getting location names");    
    self.filteredLocations = self.locationsArray;

    // OK & Cancel buttons
    [self.okButton setEnabled: NO];

    [[self window] makeKeyAndOrderFront: self];     
  
    //NSLog(@"DSAAdventureGenerationController startAdventureGeneration finished");
    
}

- (void) windowDidLoad
{
  [super windowDidLoad];
  self.locationField.usesDataSource = YES;
  self.locationField.delegate = self;
  self.locationField.dataSource = self;  
  //NSLog(@"DSAAdventureGenerationController: windowDidLoad locationField: %@", self.locationField);    
}

- (void)handleOKButton:(NSButton *)sender {
    NSString *selectedLocation = self.locationField.stringValue;
    
    if ([self.filteredLocations containsObject:selectedLocation]) { // Ensure it's a valid selection
        if (self.completionHandler) {
            self.completionHandler(selectedLocation);
        }
        //NSLog(@"DSAAdventureGenerationController handleOKButton before closing window");
        [sender.window close]; // Close panel
    }
}

- (void)handleCancelButton:(NSButton *)sender {
    if (self.completionHandler) {
        self.completionHandler(nil);
    }
    [sender.window close]; // Close panel
}

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)comboBox {
    //NSLog(@"DSAAdventureGenerationController numberOfItemsInComboBox called");
    return self.filteredLocations.count;
}

- (id)comboBox:(NSComboBox *)comboBox objectValueForItemAtIndex:(NSInteger)index {
    //NSLog(@"DSAAdventureGenerationController objectValueForItemAtIndex called");
    return self.filteredLocations[index];
}

- (void)comboBoxWillDismiss:(NSNotification *)notification {
    //NSLog(@"DSAAdventureGenerationController comboBoxWillDismiss called");
    NSString *text = [self.locationField stringValue];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", text];
    self.filteredLocations = [self.locationsArray filteredArrayUsingPredicate:predicate];
    [self.locationField reloadData];
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification {
    //NSLog(@"DSAAdventureGenerationController comboBoxSelectionDidChange called");
    NSInteger selectedIndex = [self.locationField indexOfSelectedItem];

    if (selectedIndex >= 0) {
        NSString *selectedItem = self.filteredLocations[selectedIndex]; // Get from filtered list
        //NSLog(@"comboBoxSelectionDidChange called: %@", selectedItem);
        
        // Ensure OK button is updated based on selection
        BOOL isValid = [self.locationsArray containsObject:selectedItem];
        [self.okButton setEnabled:isValid];
    }
}

- (void)controlTextDidChange:(NSNotification *)notification {
    NSString *input = [self.locationField stringValue];
    //DSALocations *locations = [DSALocations sharedInstance];
    
    // Filter locations
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH[c] %@", input];
    self.filteredLocations = [self.locationsArray filteredArrayUsingPredicate:predicate];

    // Refresh the combo box data
    [self.locationField reloadData];
    [self.locationField noteNumberOfItemsChanged]; // Ensure UI refresh

    // Enable OK button only if input exactly matches a known location
    //NSLog(@"controlTextDidChange: location: %@ ARRAY: %@", input, self.locationsArray);
    BOOL isValid = [self.locationsArray containsObject:input];
    [self.okButton setEnabled:isValid];
}


@end