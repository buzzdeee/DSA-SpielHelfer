/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-07-23 19:33:58 +0200 by sebastia

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

#import "DSAActionSliderQuestionController.h"

@implementation DSAActionSliderQuestionController
- (void)windowDidLoad {
    NSLog(@"DSAActionSliderQuestionController windowDidLoad called, window: %@", self.window);
    [super windowDidLoad];
 
    [self.buttonCancel setTitle: @"Abbrechen"];
    [self.buttonConfirm setTitle: @"Bestätigen"];
    [self.buttonConfirm setEnabled: NO];
}

- (IBAction)sliderValueChanged:(NSSlider *)sender
{
    double tickValue = [sender closestTickMarkValueToValue:sender.doubleValue];
    NSInteger value = (NSInteger)tickValue;

    NSLog(@"DSAActionSliderQuestionController sliderValueChanged: %@", @(value));
    NSLog(@"DSAActionSliderQuestionController sliderValueChanged  Slider: min=%ld max=%ld ticks=%ld", (long)self.sliderSlider.minValue, (long)self.sliderSlider.maxValue, (long)self.sliderSlider.numberOfTickMarks);
    self.fieldSliderValue.stringValue = [NSString stringWithFormat:@"%ld", (signed long)value];
    if (value > 0)
      {
        [self.buttonConfirm setEnabled: YES];
      }
}

- (IBAction)confirmAction:(id)sender {
    NSLog(@"DSAActionSliderQuestionController confirmAction");
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