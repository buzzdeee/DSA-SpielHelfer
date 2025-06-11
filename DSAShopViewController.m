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
#import "DSAShoppingCart.h"
#import "DSAObject.h"

@implementation DSAShopViewController

- (void)windowDidLoad {
    NSLog(@"DSAShopViewController windowDidLoad called, window: %@", self.window);
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
    NSLog(@"DSAShopViewController updatePage called!!!");
    NSInteger startIndex = self.currentPage * self.itemsPerPage;
    NSLog(@"DSAShopViewController updatePage start index: %@", [NSNumber numberWithInteger: startIndex]);
    NSInteger endIndex = MIN(startIndex + self.itemsPerPage, self.allItems.count);
    NSLog(@"DSAShopViewController updatePage end index: %@", [NSNumber numberWithInteger: endIndex]);    
    NSArray<DSAObject *> *itemsToShow = [self.allItems subarrayWithRange:NSMakeRange(startIndex, endIndex - startIndex)];

    NSArray<DSAShopItemButton *> *buttons = [self visibleButtons];
    NSLog(@"DSAShopViewController updatePage before for loop");
    for (NSInteger i = 0; i < buttons.count; i++) {
        DSAShopItemButton *button = buttons[i];
        NSLog(@"DSAShopViewController updatePage in for loop itemsToShow.count: %@", [NSNumber numberWithInteger: itemsToShow.count]);
        if (i < itemsToShow.count) {
            DSAObject *item = itemsToShow[i];
            [button setHidden:NO];
            button.object = item;
            button.cartCount = 0;
            NSLog(@"DSAShopViewController updatePage in for before update Display of the button");
            [button updateDisplay]; // Methode in DSAShopItemButton
            NSLog(@"DSAShopViewController updatePage in for after update Display of the button");
        } else {
            NSLog(@"DSAShopViewController updatePage in for in else");
            [button setHidden:YES];
            button.object = nil;
            button.cartCount = 0;
        }
    }

    self.buttonPrevious.enabled = (self.currentPage > 0);
    self.buttonNext.enabled = ((self.currentPage + 1) * self.itemsPerPage < self.allItems.count);
    NSLog(@"DSAShopViewController updatePage before updateSum");
    [self updateSum];
    //[self showWindow:self.window];
    NSLog(@"DSAShopViewController updatePage at the very end");
}

- (void)updateSum {
    NSLog(@"DSAShopViewController updateSum called!!!");
    NSInteger sum = 0;

    for (DSAShopItemButton *button in [self visibleButtons]) {
        if (button.object && button.cartCount > 0) {
            NSInteger unitPrice = [self priceForObject:button.object];
            sum += unitPrice * button.cartCount;
        }
    }

    self.fieldSum.stringValue = [NSString stringWithFormat:@"%ld", (long)sum];
    NSLog(@"DSAShopViewController updateSum at the end");
}

- (float)priceForObject:(DSAObject *)object {
    NSLog(@"DSAShopViewController updatePage called!!!");
    float price = object.price;
    if (self.mode == DSAShopModeBuy) {
        return price;
    } else {
        return price * 0.2f;   // 20% of normal price is selling price
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

    DSAShoppingCart *shoppingCart = [[DSAShoppingCart alloc] init];

    NSLog(@"DSAShopViewController buttonConfirmClicked called!!!");
    for (DSAShopItemButton *button in [self visibleButtons]) {
        if (button.object && button.cartCount > 0) {
            float unitPrice = [self priceForObject:button.object];
            [shoppingCart addObject: button.object count: button.cartCount price: unitPrice];
        }
    }

    [self updateSum];  // this may be superfluous, as we're going to close sheet anyways right?
//    if (self.completionHandler) {
//        self.completionHandler(shoppingCart);  // ⬅️ invoke handler before closing sheet
//    }    
//    [NSApp endSheet:self.window];
}

#pragma mark - Extern aufrufbar von Buttons

- (void)shopItemButtonDidUpdateCart {
    NSLog(@"DSAShopViewController shopItemButtonDidUpdateCart called!!!");
    [self updateSum];
}

@end
