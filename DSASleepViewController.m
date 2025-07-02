/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-07-02 16:57:13 +0200 by sebastia

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

#import "DSASleepViewController.h"

@implementation DSASleepViewController
- (void)windowDidLoad {
    NSLog(@"DSASleepViewController windowDidLoad called, window: %@", self.window);
    [super windowDidLoad];
    [self.fieldHours setStringValue: @"0 Stunden"];
    [self.buttonSleep setEnabled: NO];
}

- (IBAction)sliderValueChanged:(NSSlider *)sender {
    double value = sender.doubleValue;
    self.fieldHours.stringValue = [NSString stringWithFormat:@"%.0f Stunden", value];
    if (value > 0)
      {
        [self.buttonSleep setEnabled: YES];
      }
}

- (IBAction)sleepAction:(id)sender {
    NSLog(@"DSASleepViewController sleepAction");
    BOOL result = YES;

      
    if (self.completionHandler) {
        self.completionHandler(result);  // ⬅️ invoke handler before closing sheet
    }    
    [NSApp endSheet:self.window];
    [self.window orderOut:nil];
}

- (IBAction)cancelAction:(id)sender {
    [NSApp endSheet:self.window];
    [self.window orderOut:nil];
}
@end