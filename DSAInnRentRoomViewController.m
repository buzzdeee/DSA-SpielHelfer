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

- (NSString *)formattedPrice:(double)silver {
    int silverCoins = (int)silver;
    int heller = (int)round((silver - silverCoins) * 10); // 10 Heller = 1 Silber

    if (silverCoins > 0 && heller > 0) {
        return [NSString stringWithFormat:@"%dS %dH", silverCoins, heller];
    } else if (silverCoins > 0) {
        return [NSString stringWithFormat:@"%dS", silverCoins];
    } else {
        return [NSString stringWithFormat:@"%dH", heller];
    }
}

- (void)setRoomPrices:(NSDictionary<NSString *, NSNumber *> *)roomPrices {
    _roomPrices = roomPrices;

    [self.popupRooms removeAllItems];

    // Sortiere die Zimmernamen basierend auf dem Preis (aufsteigend)
    NSArray *sortedKeys = [roomPrices keysSortedByValueUsingComparator:^NSComparisonResult(NSNumber *price1, NSNumber *price2) {
        return [price1 compare:price2];
    }];

    NSMutableArray *items = [NSMutableArray array];
    for (NSString *roomName in sortedKeys) {
        double price = roomPrices[roomName].doubleValue;
        NSString *formatted = [self formattedPrice:price];
        [items addObject:[NSString stringWithFormat:@"%@ %@", roomName, formatted]];
    }

    [self.popupRooms addItemsWithTitles:items];
}

@end
