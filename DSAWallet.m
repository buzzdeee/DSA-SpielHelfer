/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-06-13 21:27:58 +0200 by sebastia

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

#import "DSAWallet.h"

@implementation DSAWallet

#pragma mark - Initializer

- (instancetype)init {
    self = [super init];
    if (self) {
        _dukaten = 0;
        _silber = 0;
        _heller = 0;
        _kreuzer = 0;
    }
    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInteger:self.dukaten forKey:@"D"];
    [coder encodeInteger:self.silber forKey:@"S"];
    [coder encodeInteger:self.heller forKey:@"H"];
    [coder encodeInteger:self.kreuzer forKey:@"K"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _dukaten = [coder decodeIntegerForKey:@"D"];
        _silber = [coder decodeIntegerForKey:@"S"];
        _heller = [coder decodeIntegerForKey:@"H"];
        _kreuzer = [coder decodeIntegerForKey:@"K"];
    }
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    DSAWallet *copy = [[[self class] allocWithZone:zone] init];
    copy.dukaten = self.dukaten;
    copy.silber = self.silber;
    copy.heller = self.heller;
    copy.kreuzer = self.kreuzer;
    return copy;
}

#pragma mark - Description

- (NSString *)description {
    return [NSString stringWithFormat:@"D: %ld, S: %ld, H: %ld, K: %ld",
            (long)self.dukaten,
            (long)self.silber,
            (long)self.heller,
            (long)self.kreuzer];
}

#pragma mark - Helper (Konversion)

- (void)addSilber:(float)silber {
    NSInteger totalKreuzer = roundf(silber * 100); // 1 Silber = 100 Kreuzer

    NSInteger d = totalKreuzer / 1000;
    totalKreuzer %= 1000;

    NSInteger s = totalKreuzer / 100;
    totalKreuzer %= 100;

    NSInteger h = totalKreuzer / 10;
    totalKreuzer %= 10;

    NSInteger k = totalKreuzer;

    self.dukaten += d;
    self.silber += s;
    self.heller += h;
    self.kreuzer += k;
    
    [self normalize];
}

- (void)subtractSilber:(float)silber {
    NSInteger totalKreuzer = roundf(silber * 100); // Umrechnen in Kreuzer
    NSInteger currentTotal = roundf([self total] * 100);
    
    if (totalKreuzer > currentTotal) {
        NSLog(@"Warnung: Nicht genug Geld zum Abziehen!");
        totalKreuzer = currentTotal; // Alles abziehen
    }

    // Umwandeln des Gesamtgelds in Kreuzer, Subtrahieren, neu verteilen
    NSInteger remainingKreuzer = currentTotal - totalKreuzer;
    
    self.dukaten = remainingKreuzer / 1000;
    remainingKreuzer %= 1000;
    
    self.silber = remainingKreuzer / 100;
    remainingKreuzer %= 100;
    
    self.heller = remainingKreuzer / 10;
    self.kreuzer = remainingKreuzer % 10;
}

- (float)total {
    return self.dukaten * 10.0f +
           self.silber * 1.0f +
           self.heller * 0.1f +
           self.kreuzer * 0.01f;
}

// Optional: Überläufe korrigieren (z. B. 15 Heller -> 1 Silber + 5 Heller)
- (void)normalize {
    if (self.kreuzer >= 10) {
        self.heller += self.kreuzer / 10;
        self.kreuzer %= 10;
    }
    if (self.heller >= 10) {
        self.silber += self.heller / 10;
        self.heller %= 10;
    }
    if (self.silber >= 10) {
        self.dukaten += self.silber / 10;
        self.silber %= 10;
    }
}

@end