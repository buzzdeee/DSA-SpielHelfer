/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-06-09 22:03:15 +0200 by sebastia

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

#import "DSAShopViewController.h"
#import "DSAShopItemButton.h"
#import "DSAObject.h"

@implementation DSAShopViewController

- (void)windowDidLoad {
    [super windowDidLoad];

    self.itemsPerPage = 10;
    self.currentPage = 0;

    [self updatePage];
}

- (NSArray<DSAShopItemButton *> *)visibleButtons {
    return @[self.buttonItem0, self.buttonItem1, self.buttonItem2,
             self.buttonItem3, self.buttonItem4, self.buttonItem5,
             self.buttonItem6, self.buttonItem7, self.buttonItem8,
             self.buttonItem9];
}

- (void)updatePage {
    NSInteger startIndex = self.currentPage * self.itemsPerPage;
    NSInteger endIndex = MIN(startIndex + self.itemsPerPage, self.allItems.count);
    NSArray<DSAObject *> *itemsToShow = [self.allItems subarrayWithRange:NSMakeRange(startIndex, endIndex - startIndex)];

    NSArray<DSAShopItemButton *> *buttons = [self visibleButtons];

    for (NSInteger i = 0; i < buttons.count; i++) {
        DSAShopItemButton *button = buttons[i];

        if (i < itemsToShow.count) {
            DSAObject *item = itemsToShow[i];
            [button setHidden:NO];
            button.object = item;
            button.cartCount = 0;
            [button updateDisplay]; // Methode in DSAShopItemButton
        } else {
            [button setHidden:YES];
            button.object = nil;
            button.cartCount = 0;
        }
    }

    self.buttonPrevious.enabled = (self.currentPage > 0);
    self.buttonNext.enabled = ((self.currentPage + 1) * self.itemsPerPage < self.allItems.count);

    [self updateSum];
}

- (void)updateSum {
    NSInteger sum = 0;

    for (DSAShopItemButton *button in [self visibleButtons]) {
        if (button.object && button.cartCount > 0) {
            NSInteger unitPrice = [self priceForObject:button.object];
            sum += unitPrice * button.cartCount;
        }
    }

    self.fieldSum.stringValue = [NSString stringWithFormat:@"%ld", (long)sum];
}

- (NSInteger)priceForObject:(DSAObject *)object {
    float price = object.price;
    if (self.mode == ShopModeBuy) {
        return (NSInteger)roundf(price);
    } else {
        return (NSInteger)roundf(price * 0.2f);
    }
}

- (IBAction)buttonPreviousClicked:(id)sender {
    if (self.currentPage > 0) {
        self.currentPage--;
        [self updatePage];
    }
}

- (IBAction)buttonNextClicked:(id)sender {
    if ((self.currentPage + 1) * self.itemsPerPage < self.allItems.count) {
        self.currentPage++;
        [self updatePage];
    }
}

- (IBAction)buttonConfirmClicked:(id)sender {
    NSInteger sum = 0;

    for (DSAShopItemButton *button in [self visibleButtons]) {
        if (button.object && button.cartCount > 0) {
            NSInteger unitPrice = [self priceForObject:button.object];
            NSInteger itemSum = unitPrice * button.cartCount;
            sum += itemSum;

            if (self.mode == ShopModeBuy) {
                // Füge Items zum Inventar hinzu
                // Ziehe Gold ab
            } else {
                // Entferne Items vom Inventar
                // Füge Gold hinzu
            }

            button.cartCount = 0;
            [button updateDisplay];
        }
    }

    [self updateSum];
}

#pragma mark - Extern aufrufbar von Buttons

- (void)shopItemButtonDidUpdateCart {
    [self updateSum];
}

@end
