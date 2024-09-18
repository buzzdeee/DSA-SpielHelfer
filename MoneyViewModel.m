/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-09-16 22:25:30 +0200 by sebastia

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

#import "MoneyViewModel.h"

@implementation MoneyViewModel

- (void)setMoney:(NSDictionary *)money {
    if (_money != money) {
        [_money removeObserver:self forKeyPath:@"D"];
        [_money removeObserver:self forKeyPath:@"S"];
        [_money removeObserver:self forKeyPath:@"H"];
        [_money removeObserver:self forKeyPath:@"K"];
        
        _money = money;
        
        [self addObserver:self forKeyPath:@"money.D" options:NSKeyValueObservingOptionNew context:NULL];
        [self addObserver:self forKeyPath:@"money.S" options:NSKeyValueObservingOptionNew context:NULL];
        [self addObserver:self forKeyPath:@"money.H" options:NSKeyValueObservingOptionNew context:NULL];
        [self addObserver:self forKeyPath:@"money.K" options:NSKeyValueObservingOptionNew context:NULL];
        
        [self updateFormattedMoney];
    }
}

- (void)updateFormattedMoney {
    NSString *formattedString = [NSString stringWithFormat:@"%@D %@S %@H %@K",
                                 self.money[@"D"] ?: @"0",
                                 self.money[@"S"] ?: @"0",
                                 self.money[@"H"] ?: @"0",
                                 self.money[@"K"] ?: @"0"];
    _formattedMoney = formattedString;
}

- (void)observeValueForKeyPath:(NSString *)keyPath 
                      ofObject:(id)object 
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change 
                       context:(void *)context {
    if ([keyPath hasPrefix:@"money."]) {
        [self updateFormattedMoney];
    }
}

@end
