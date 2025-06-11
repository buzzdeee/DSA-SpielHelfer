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
    
    self.shoppingCart = [[DSAShoppingCart alloc] init];
    self.itemsPerPage = 10;
    self.currentPage = 0;
    [self.buttonConfirm setTitle: @"Feilschen"];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                         selector:@selector(handleCartUpdate)
                                             name:@"DSAShoppingCartUpdated"
                                           object:nil];
    [self updatePage];
}

- (void)dealloc {
    NSLog(@"DSAShopViewController deallocated.");
    [[NSNotificationCenter defaultCenter] removeObserver:self];  
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
            button.shoppingCart = self.shoppingCart;
            //button.cartCount = 0;
            NSLog(@"DSAShopViewController updatePage in for before update Display of the button");
            [button updateDisplay]; // Methode in DSAShopItemButton
            NSLog(@"DSAShopViewController updatePage in for after update Display of the button");
        } else {
            NSLog(@"DSAShopViewController updatePage in for in else");
            [button setHidden:YES];
            button.object = nil;
            //button.cartCount = 0;
        }
    }

    self.buttonPrevious.enabled = (self.currentPage > 0);
    self.buttonNext.enabled = ((self.currentPage + 1) * self.itemsPerPage < self.allItems.count);
    NSLog(@"DSAShopViewController updatePage before updateSum");
    [self updateCountAndSum];
    NSLog(@"DSAShopViewController updatePage at the very end");
}

- (void)updateCountAndSum {
    NSLog(@"DSAShopViewController updateCountAndSum called!!!");

    float total = [self.shoppingCart totalSum];
    
    self.fieldSum.stringValue = [NSString stringWithFormat:@"%.2f Silber", total];
    NSLog(@"DSAShopViewController updateCountAndSum before countAllObjects");
    NSInteger count = [self.shoppingCart countAllObjects];
    NSLog(@"DSAShopViewController updateCountAndSum after countAllObjects");
    NSString *countStr;
    if (count < 2)
      {
        countStr = @"Stück";
      }
    else
      {
        countStr = @"Stücke";
      }
    self.fieldCount.stringValue = [NSString stringWithFormat: @"%ld %@", (long int) count, countStr];

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

- (IBAction)buttonPreviousItems:(id)sender {
    if (self.currentPage > 0) {
        self.currentPage--;
        [self updatePage];
    }
}

- (IBAction)buttonNextItems:(id)sender {
    if ((self.currentPage + 1) * self.itemsPerPage < self.allItems.count) {
        self.currentPage++;
        [self updatePage];
    }
}

- (IBAction)buttonConfirm:(id)sender {
    NSLog(@"DSAShopViewController buttonConfirm");
    //[self updateCountAndSum];  // this may be superfluous, as we're going to close sheet anyways right?
    if (self.completionHandler) {
        self.completionHandler(self.shoppingCart);  // ⬅️ invoke handler before closing sheet
    }    
    [NSApp endSheet:self.window];
    [self.window orderOut:nil];
}

#pragma mark - Extern aufrufbar von Buttons

- (void)handleCartUpdate {
    NSLog(@"DSAShopViewController shopItemButtonDidUpdateCart called!!!");
    [self updateCountAndSum];
}

@end
