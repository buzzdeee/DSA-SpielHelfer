/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-06-19 22:13:22 +0200 by sebastia

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

#import "DSAInnRentRoomViewController.h"

@implementation DSAInnRentRoomViewController
- (void)windowDidLoad {
    NSLog(@"DSAInnRentRoomViewController windowDidLoad called, window: %@", self.window);
    [super windowDidLoad];
    [self.popupRooms removeAllItems];
    [self.popupRooms addItemsWithTitles: @[@"Schlafsaal 5H", @"Einzelzimmer 2S", @"Suite 8S"]];
    [self.fieldNights setStringValue: @"0 Nächte"];
    [self.buttonRent setEnabled: NO];
}
- (IBAction)sliderValueChanged:(NSSlider *)sender {
    double value = sender.doubleValue;
    self.fieldNights.stringValue = [NSString stringWithFormat:@"%.0f Nächte", value];
    if (value > 0)
      {
        [self.buttonRent setEnabled: YES];
      }
}

- (IBAction)buttonRentClicked:(id)sender {
    NSLog(@"DSAInnRentRoomViewController buttonRentClicked");
    BOOL result = YES;

      
    if (self.completionHandler) {
        self.completionHandler(result);  // ⬅️ invoke handler before closing sheet
    }    
    [NSApp endSheet:self.window];
    [self.window orderOut:nil];
}

- (IBAction)buttonCancelClicked:(id)sender {
    [NSApp endSheet:self.window];
    [self.window orderOut:nil];
}
@end
