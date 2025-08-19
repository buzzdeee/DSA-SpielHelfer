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
#import "DSASlot.h"

@implementation DSAShopViewController

- (void)windowDidLoad {
    NSLog(@"DSAShopViewController windowDidLoad called, window: %@", self.window);
    [super windowDidLoad];
    
    if (!self.shoppingCart)
      {
        self.shoppingCart = [[DSAShoppingCart alloc] init];
      }
    if (self.mode == DSAShopModeBuy)
      {
        self.window.title = @"Kaufen";
      }
    else
      {
        self.window.title = @"Verkaufen";      
      }      
    self.itemsPerPage = 10;
    self.currentPage = 0;
    [self.buttonConfirm setTitle: @"Feilschen"];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                         selector:@selector(handleCartUpdate)
                                             name:@"DSAShoppingCartUpdated"
                                           object:nil];
    [self updatePage];
}

- (void)setMode:(DSAShopMode)mode {
    _mode = mode; // setze das ivar direkt

/*    if (mode == DSAShopModeBuy)
      {
        self.window.title = @"Kaufen";
      }
    else
      {
        self.window.title = @"Verkaufen";      
      }
  */  
    if (self.shoppingCart)
      {
        self.shoppingCart.mode = mode;
      }
    else
      {
        self.shoppingCart = [[DSAShoppingCart alloc] init];
        self.shoppingCart.mode = mode;
      }
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
    //NSLog(@"DSAShopViewController updatePage start index: %@", @(startIndex));
    
    NSInteger endIndex;
    NSArray *itemsToShow = nil;
    
    if (self.mode == DSAShopModeBuy) {
        endIndex = MIN(startIndex + self.itemsPerPage, self.allItems.count);
        //NSLog(@"DSAShopViewController updatePage end index: %@", @(endIndex));
        
        itemsToShow = [self.allItems subarrayWithRange:NSMakeRange(startIndex, endIndex - startIndex)];
    } else if (self.mode == DSAShopModeSell) {
        endIndex = MIN(startIndex + self.itemsPerPage, self.allSlots.count);
        //NSLog(@"DSAShopViewController updatePage end index: %@", @(endIndex));
        
        itemsToShow = [self.allSlots subarrayWithRange:NSMakeRange(startIndex, endIndex - startIndex)];
    }

    NSArray<DSAShopItemButton *> *buttons = [self visibleButtons];
    //NSLog(@"DSAShopViewController updatePage before for loop SHOP MODE %@", [NSNumber numberWithInteger: self.mode]);
    
    for (NSInteger i = 0; i < buttons.count; i++) {
        DSAShopItemButton *button = buttons[i];
        
        if (i < itemsToShow.count) {
            [button setHidden:NO];
            button.maxSilber = self.maxSilber;
            button.shoppingCart = self.shoppingCart;
            //NSLog(@"DSAShopViewController updatePage: Setting button.mode = %ld", (long)self.mode);
            button.mode = self.mode;

            if (self.mode == DSAShopModeBuy) {
                DSAObject *item = itemsToShow[i];
                NSLog(@"DSAShopViewController updatePage Buy Mode, set button.object from item: %@", item);
                button.object = item;
            } else if (self.mode == DSAShopModeSell) {
                DSASlot *slot = itemsToShow[i];
                button.object = slot.object;
                button.quantity = slot.quantity;
                button.slotID = [slot.slotID UUIDString];
            }

            //NSLog(@"DSAShopViewController updatePage in for before updateDisplay");
            [button updateDisplay];
            //NSLog(@"DSAShopViewController updatePage in for after updateDisplay");
        } else {
            //NSLog(@"DSAShopViewController updatePage in for in else");
            [button setHidden:YES];
            button.object = nil;
        }
    }

    self.buttonPrevious.enabled = (self.currentPage > 0);
    
    NSInteger totalItemCount = (self.mode == DSAShopModeBuy) ? self.allItems.count : self.allSlots.count;
    //NSLog(@"DSAShopViewController updatePage: totalItemCount %@", [NSNumber numberWithInteger: totalItemCount]);
    self.buttonNext.enabled = ((self.currentPage + 1) * self.itemsPerPage < totalItemCount);
    
    //NSLog(@"DSAShopViewController updatePage before updateCountAndSum");
    [self updateCountAndSum];
    //NSLog(@"DSAShopViewController updatePage at the very end");
}

- (void)updateCountAndSum {
    //NSLog(@"DSAShopViewController updateCountAndSum called!!!");

    float total = [self.shoppingCart totalSum];
    
    self.fieldSum.stringValue = [NSString stringWithFormat:@"%.2f Silber", total];
    //NSLog(@"DSAShopViewController updateCountAndSum before countAllObjects");
    NSInteger count = [self.shoppingCart countAllObjects];
    //NSLog(@"DSAShopViewController updateCountAndSum after countAllObjects");
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

    //NSLog(@"DSAShopViewController updateSum at the end");
}

- (float)priceForObject:(DSAObject *)object {
    //NSLog(@"DSAShopViewController updatePage called!!!");
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
    NSInteger totalItemCount = (self.mode == DSAShopModeBuy) ? self.allItems.count : self.allSlots.count;
    if ((self.currentPage + 1) * self.itemsPerPage < totalItemCount) {
        self.currentPage++;
        [self updatePage];
    }
}

- (IBAction)buttonConfirm:(id)sender {
    //NSLog(@"DSAShopViewController buttonConfirm");
    //[self updateCountAndSum];  // this may be superfluous, as we're going to close sheet anyways right?
    if (self.completionHandler) {
        self.completionHandler(self.shoppingCart);  // ⬅️ invoke handler before closing sheet
    }    
    [NSApp endSheet:self.window];
    [self.window orderOut:nil];
}

#pragma mark - Extern aufrufbar von Buttons

- (void)handleCartUpdate {
    //NSLog(@"DSAShopViewController shopItemButtonDidUpdateCart called!!!");
    [self updateCountAndSum];
}

@end
