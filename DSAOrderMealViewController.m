/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-06-30 21:32:11 +0200 by sebastia

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

#import "DSAOrderMealViewController.h"

@implementation DSAOrderMealViewController
- (void)windowDidLoad {
    NSLog(@"DSAOrderMealViewController windowDidLoad called, window: %@", self.window);
    [super windowDidLoad];
    [self.popupMeals removeAllItems];
}

- (IBAction)confirmAction:(id)sender {
    NSLog(@"DSAOrderMealViewController confirmAction");
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

- (void)setMealPrices:(NSDictionary<NSString *, NSNumber *> *)mealPrices {
    _mealPrices = mealPrices;
    [self.popupMeals removeAllItems];

    // Sort meals based on price
    NSArray *sortedKeys = [mealPrices keysSortedByValueUsingComparator:^NSComparisonResult(NSNumber *price1, NSNumber *price2) {
        return [price1 compare:price2];
    }];

    // 1️⃣ Speichern der Namen, um später den Index zurück auf den Namen zu mappen
    self.mealDisplayNames = sortedKeys.copy;

    NSMutableArray *items = [NSMutableArray array];
    for (NSString *mealName in sortedKeys) {
        double price = mealPrices[mealName].doubleValue;
        NSString *formatted = [self formattedPrice:price];

        // 2️⃣ Sichtbar für den Spieler: Name + Preis
        [items addObject:[NSString stringWithFormat:@"%@ %@", mealName, formatted]];
    }

    [self.popupMeals addItemsWithTitles:items];
}
/*
- (void)setMealPrices:(NSDictionary<NSString *, NSNumber *> *)mealPrices {
    _mealPrices = mealPrices;
    [self.popupMeals removeAllItems];

    // sort meals based on price
    NSArray *sortedKeys = [mealPrices keysSortedByValueUsingComparator:^NSComparisonResult(NSNumber *price1, NSNumber *price2) {
        return [price1 compare:price2];
    }];

    NSMutableArray *items = [NSMutableArray array];
    for (NSString *mealName in sortedKeys) {
        double price = mealPrices[mealName].doubleValue;
        NSString *formatted = [self formattedPrice:price];
        [items addObject:[NSString stringWithFormat:@"%@ %@", mealName, formatted]];
    }

    [self.popupMeals addItemsWithTitles:items];
}
*/
@end
