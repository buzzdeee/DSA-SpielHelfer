/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-06-17 21:54:09 +0200 by sebastia

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

#import "DSADonationViewController.h"
#import "DSAAdventureGroup.h"

@implementation DSADonationViewController
- (void)windowDidLoad {
    NSLog(@"DSADonationViewController windowDidLoad called, window: %@", self.window);
    [super windowDidLoad];
    [self.fieldFinalSilver setStringValue: @"0 Silberlinge"];
    float maxSilver = [self.activeGroup totalWealthOfGroup];
    [self.fieldMaxSilver setStringValue: [NSString stringWithFormat: @"%.2f S", maxSilver]];
    [self.sliderSilver setMaxValue: maxSilver];
    [self.sliderSilver setMinValue: 0.0];
    [self.buttonDonate setEnabled: NO];
}

- (IBAction)sliderValueChanged:(NSSlider *)sender {
    double value = sender.doubleValue;
    self.fieldFinalSilver.stringValue = [NSString stringWithFormat:@"%.2f Silberlinge", value];
    if (value > 0)
      {
        [self.buttonDonate setEnabled: YES];
      }
}

- (IBAction)buttonDonateClicked:(id)sender {
    NSLog(@"DSAShopBargainController buttonConfirm");
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
