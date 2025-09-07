/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-03-02 18:41:01 +0100 by sebastia

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

#import "DSAAdventureClock.h"

@implementation DSAAdventureClock

- (instancetype)init {
    if (self = [super init]) {
        _gameSpeedMultiplier = 4.0; // Game time runs at 2x speed
        _currentDate = [[DSAAventurianDate alloc] initWithYear:1030 
                                                         month:DSAAventurianMonthPraios 
                                                           day:1 
                                                          hour:6]; // Start date
    }
    return self;
}
- (void) dealloc
{
    NSLog(@"DSAAdventureClock dealloc called");
    if (self.gameTimer) {
        [self.gameTimer invalidate];
        self.gameTimer = nil;
        NSLog(@"DSAAdventureClock: Timer stopped.");
    }    
}

- (void)startClock {
    NSLog(@"DSAAdventureClock startClock called");
    if (!self.gameTimer) {
        NSLog(@"DSAAdventureClock startClock called, initializing gameTimer");

        __weak typeof(self) weakSelf = self;                                              
        _gameTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 / _gameSpeedMultiplier
                                                     repeats:YES
                                                       block:^(NSTimer * _Nonnull timer) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) {
                [timer invalidate];
                return;
            }
            [strongSelf updateGameTime];
        }];                                                         
    }
}

- (void)pauseClock {
    [self.gameTimer invalidate];
    self.gameTimer = nil;
}

- (void)updateGameTime {
    //NSLog(@"DSAAdventureClock updateGameTime: called (advance time by 1 minute)");
    [self advanceTimeByMinutes:1]; // Advances 1 minute of game time every 30 real seconds    
}

- (void)advanceTimeByMinutes:(NSUInteger)minutes {
    NSUInteger newMinutes = self.currentDate.minute + minutes;

    self.currentDate.hour += newMinutes / 60; // Only add full hours
    self.currentDate.minute = newMinutes % 60; // Set remaining minutes properly

    if (self.currentDate.hour >= 24) {
        self.currentDate.hour -= 24;
        [self advanceTimeByDays:1];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DSAGameTimeAdvanced"
                                                        object:self
                                                      userInfo:@{ @"currentDate": [self.currentDate copy] }];    
}

- (void)advanceTimeByHours:(NSUInteger)hours {
    //NSLog(@"DSAAdventureClock advanceTimeByHours hours before: %lu", self.currentDate.hour);
    self.currentDate.hour += hours;
    if (self.currentDate.hour >= 24) {
        [self advanceTimeByDays:self.currentDate.hour / 24];
        self.currentDate.hour %= 24;
    }
    //NSLog(@"DSAAdventureClock advanceTimeByHours hours after: %lu", self.currentDate.hour);
    //NSLog(@"DSAAdventureClock advanceTimeByHours : currentDate after: %@", self.currentDate);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DSAGameTimeAdvanced"
                                                        object:self
                                                      userInfo:@{ @"currentDate": [self.currentDate copy] }];    
}

- (void)advanceTimeByDays:(NSUInteger)days {
    self.currentDate.day += days;
    
    NSUInteger daysInMonth = 30; // Assuming 30 days per month
    if (self.currentDate.day > daysInMonth) {
        self.currentDate.month += self.currentDate.day / daysInMonth;
        self.currentDate.day = self.currentDate.day % daysInMonth;
    }
    
    if (self.currentDate.month > DSAAventurianMonthNamenlos) {
        self.currentDate.year += 1;
        self.currentDate.month = DSAAventurianMonthPraios;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DSAGameTimeAdvanced"
                                                        object:self
                                                      userInfo:@{ @"currentDate": [self.currentDate copy] }];    
}

- (void) encodeWithCoder:(NSCoder *)coder
{
  [coder encodeObject:self.currentDate forKey:@"currentDate"];
  [coder encodeDouble:self.gameSpeedMultiplier forKey:@"gameSpeedMultiplier"];
}

- (instancetype) initWithCoder:(NSCoder *)coder
{
  self = [super init];
  if (self)
    {
      _currentDate = [coder decodeObjectForKey:@"currentDate"];
      _gameSpeedMultiplier = [coder decodeDoubleForKey:@"gameSpeedMultiplier"];
    }
  return self;
}

- (NSUInteger)currentMonth {
    return self.currentDate.month;
}

- (NSUInteger)currentDay {
    return self.currentDate.day;
}

- (NSUInteger)currentHour {
    return self.currentDate.hour;
}

- (NSUInteger)currentMinute {
    return self.currentDate.minute;
}

- (DSAMoonPhase)currentMoonPhase {
    // Last 5 days of the year → No Moon
    if (self.currentDate.month == DSAAventurianMonthNamenlos) {
        return DSAMoonPhaseNewMoon;
    }
    
    NSUInteger dayOfMonth = self.currentDate.day;

    if (dayOfMonth == 1 || dayOfMonth == 2) return DSAMoonPhaseNewMoon;
    if (dayOfMonth >= 3 && dayOfMonth <= 8) return DSAMoonPhaseWaxingCrescent;
    if (dayOfMonth == 9) return DSAMoonPhaseFirstQuarter;
    if (dayOfMonth >= 10 && dayOfMonth <= 15) return DSAMoonPhaseWaxingGibbous;
    if (dayOfMonth == 16 || dayOfMonth == 17) return DSAMoonPhaseFullMoon;
    if (dayOfMonth >= 18 && dayOfMonth <= 23) return DSAMoonPhaseWaningGibbous;
    if (dayOfMonth == 24) return DSAMoonPhaseLastQuarter;
    if (dayOfMonth >= 26 && dayOfMonth <= 30) return DSAMoonPhaseWaningCrescent;
    
    return DSAMoonPhaseNewMoon; // Should never reach here, but just in case
}

- (NSString *)moonPhaseNameForPhase:(DSAMoonPhase)phase {
    switch (phase) {
        case DSAMoonPhaseNewMoon: return @"Neumond";
        case DSAMoonPhaseWaxingCrescent: return @"Zunehmende Sichel";
        case DSAMoonPhaseFirstQuarter: return @"Erstes Viertel";
        case DSAMoonPhaseWaxingGibbous: return @"Zunehmender Mond";
        case DSAMoonPhaseFullMoon: return @"Vollmond";
        case DSAMoonPhaseWaningGibbous: return @"Abnehmender Mond";
        case DSAMoonPhaseLastQuarter: return @"Letztes Viertel";
        case DSAMoonPhaseWaningCrescent: return @"Abnehmende Sichel";
    }
    NSLog(@"DSAAdventureClock moonPhaseNameForPhase unknown moon phase: %@ ABORTING", @(phase));
    abort();
    return @"Unbekannt";
}

@end