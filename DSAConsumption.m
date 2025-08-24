/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-08-11 21:02:05 +0200 by sebastia

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

#import "DSAConsumption.h"
#include "DSAAventurianDate.h"
#include "DSAAdventureClock.h"
#include "DSAAdventure.h"

@implementation DSAConsumption

- (instancetype)initWithType:(DSAConsumptionType)type {
    if (self = [super init]) {
        _type = type;
        switch (type) {
            case DSAConsumptionTypeUseOnce:
                _maxUses = 1;
                _remainingUses = 1;
                break;
            case DSAConsumptionTypeUseMany:
                _maxUses = 1; // kann später erhöht werden
                _remainingUses = _maxUses;
                break;
            case DSAConsumptionTypeUseForever:
                _maxUses = 0; // 0 = unendlich
                _remainingUses = 0;
                break;
            case DSAConsumptionTypeExpiry:
                _shelfLifeDays = 0;
                break;
        }
    }
    _disappearWhenEmpty = NO;
    _isEatable = NO;
    _isDrinkable = NO;    
    _alcoholLevel = 0;
    _nutritionValue = 0.0;
    return self;
}

- (BOOL)useOnceWithDate:(DSAAventurianDate *)currentDate
                 reason:(DSAConsumptionFailReason *)reason
{                 
    NSLog(@"DSAConsumption useOnceWithDate going to set self.previousUses = self.remainingUses");
    self.previousUses = self.remainingUses;
    if (reason) *reason = DSAConsumptionFailReasonNone;
    
    switch (self.type) {
        case DSAConsumptionTypeUseForever:
            return YES;
            
        case DSAConsumptionTypeExpiry:
            if ([self isExpiredAtDate: currentDate]) {
                if (reason) *reason = DSAConsumptionFailReasonExpired;
                return NO;
            }
            return YES;
            
        case DSAConsumptionTypeUseOnce:
        case DSAConsumptionTypeUseMany:
            if (self.remainingUses > 0) {
                NSLog(@"DSAConsumption useOnceWithDate: remainingUses was > 0 going to subtract and return YES");
                self.remainingUses--;
                return YES;
            } else {
                NSLog(@"DSAConsumption useOnceWithDate: remainingUses was alread 0 going to return NO");
                if (reason) *reason = DSAConsumptionFailReasonNoUsesLeft;
                return NO;
            }
            
        default:
            if (reason) *reason = DSAConsumptionFailReasonInvalidType;
            return NO;
    }
}

- (void)resetCurrentUsageToMax
{
  self.remainingUses = self.maxUses;
  self.previousUses = self.maxUses;
}

- (BOOL)justDepleted {
    return (self.previousUses > 0 && self.remainingUses == 0 && self.maxUses >= 1);
}

- (BOOL)isExpiredAtDate:(DSAAventurianDate *)currentDate {
    if (self.type != DSAConsumptionTypeExpiry) return NO;
    if (!self.manufactureDate) return NO; // Not started yet
    if (!self.manufactureDate) return NO;
    
    DSAAventurianDate *expiry = [self.manufactureDate dateByAddingYears:0
                                                                   days:self.shelfLifeDays
                                                                  hours:0
                                                                minutes:0];
    return [currentDate isLaterThanDate:expiry];
}

- (void)activateExpiryForAdventure:(DSAAdventure *)adventure {
    if (self.type == DSAConsumptionTypeExpiry && !self.manufactureDate) {
        self.manufactureDate = [adventure.gameClock.currentDate copy];
    }
}

- (BOOL)isExpiryActive {
    return (self.type == DSAConsumptionTypeExpiry && self.manufactureDate != nil);
}

- (BOOL)canUseAtDate: (DSAAventurianDate *)currentDate
{
    switch (self.type) {
        case DSAConsumptionTypeUseForever:
            return YES;
        case DSAConsumptionTypeUseOnce:
        case DSAConsumptionTypeUseMany:
            return (self.remainingUses > 0);
        case DSAConsumptionTypeExpiry:
            return ![self isExpiredAtDate: currentDate];
    }
    return YES;
}

- (BOOL) isAlcoholic
{
  return (self.alcoholLevel > 0);
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInteger:self.type forKey:@"type"];
    [coder encodeInteger:self.maxUses forKey:@"maxUses"];
    [coder encodeInteger:self.remainingUses forKey:@"remainingUses"];
    [coder encodeObject:self.manufactureDate forKey:@"manufactureDate"];
    [coder encodeInteger:self.shelfLifeDays forKey:@"shelfLifeDays"];
    [coder encodeBool:self.disappearWhenEmpty forKey:@"disappearWhenEmpty"];
    [coder encodeObject:self.transitionWhenEmpty forKey:@"transitionWhenEmpty"];
    [coder encodeBool:self.isDrinkable forKey:@"isDrinkable"];
    [coder encodeBool:self.isEatable forKey:@"isEatable"];
    [coder encodeInteger:self.alcoholLevel forKey:@"alcoholLevel"];
    [coder encodeObject:@(self.nutritionValue) forKey:@"nutritionValue"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        _type = [coder decodeIntegerForKey:@"type"];
        _maxUses = [coder decodeIntegerForKey:@"maxUses"];
        _remainingUses = [coder decodeIntegerForKey:@"remainingUses"];
        _manufactureDate = [coder decodeObjectForKey:@"manufactureDate"];
        _shelfLifeDays = [coder decodeIntegerForKey:@"shelfLifeDays"];
        _disappearWhenEmpty = [coder decodeBoolForKey:@"disappearWhenEmpty"];
        _transitionWhenEmpty = [coder decodeObjectForKey:@"transitionWhenEmpty"];
        _isDrinkable = [coder decodeBoolForKey:@"isDrinkable"];
        _isEatable = [coder decodeBoolForKey:@"isEatable"];
        _alcoholLevel = [coder decodeIntegerForKey:@"alcoholLevel"];
        _nutritionValue = [[coder decodeObjectForKey:@"nutritionValue"] floatValue];
    }
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    DSAConsumption *copy = [[[self class] allocWithZone:zone] initWithType:self.type];
    copy.maxUses = self.maxUses;
    copy.remainingUses = self.remainingUses;
    copy.manufactureDate = [self.manufactureDate copy];
    copy.shelfLifeDays = self.shelfLifeDays;
    copy.disappearWhenEmpty = self.disappearWhenEmpty;
    copy.transitionWhenEmpty = [self.transitionWhenEmpty copy];
    copy.isDrinkable = self.isDrinkable;
    copy.isEatable = self.isEatable;
    copy.alcoholLevel = self.alcoholLevel;
    copy.nutritionValue = self.nutritionValue;
    return copy;
}

- (NSString *)description {
    NSMutableString *desc = [NSMutableString stringWithFormat:@"<%@: %p>\n", NSStringFromClass([self class]), self];
    
    [desc appendFormat:@"  type: %ld\n", (long)self.type];
    
    [desc appendFormat:@"  maxUses: %ld\n", (long)self.maxUses];
    [desc appendFormat:@"  remainingUses: %ld\n", (long)self.remainingUses];
    
    if (self.manufactureDate) {
        [desc appendFormat:@"  manufactureDate: %@\n", self.manufactureDate];
    } else {
        [desc appendString:@"  manufactureDate: (nil)\n"];
    }
    
    [desc appendFormat:@"  shelfLifeDays: %ld\n", (long)self.shelfLifeDays];
    [desc appendFormat:@"  previousUses: %ld\n", (long)self.previousUses];
    
    [desc appendFormat:@"  disappearWhenEmpty: %@\n", self.disappearWhenEmpty ? @"YES" : @"NO"];
    
    if (self.transitionWhenEmpty) {
        [desc appendFormat:@"  transitionWhenEmpty: %@\n", self.transitionWhenEmpty];
    } else {
        [desc appendString:@"  transitionWhenEmpty: (nil)\n"];
    }
    
    [desc appendFormat:@"  isDrinkable: %@\n", self.isDrinkable ? @"YES" : @"NO"];
    [desc appendFormat:@"  isEatable: %@\n", self.isEatable ? @"YES" : @"NO"];
    
    [desc appendFormat:@"  alcoholLevel: %ld\n", (long)self.alcoholLevel];
    [desc appendFormat:@"  nutritionValue: %.2f\n", self.nutritionValue];
    
    return desc;
}

@end