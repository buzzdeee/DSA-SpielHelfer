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
#import "DSAAventurianDate.h"

@implementation DSAAdventureClock

- (instancetype)init {
    if (self = [super init]) {
        _gameSpeedMultiplier = DSAGameSpeedNormal;
        _currentDate = [[DSAAventurianDate alloc] initWithYear:1030
                                                         month:DSAAventurianMonthPraios
                                                           day:1
                                                          hour:6];
        [self startClock];
    }
    return self;
}

- (void)dealloc {
    [self.gameTimer invalidate];
}

#pragma mark - Clock Control

- (BOOL)isRunning {
    return self.gameTimer != nil;
}

- (void)startClock {
    if (!self.gameTimer) {
        __weak typeof(self) weakSelf = self;
        _gameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      repeats:YES
                                                        block:^(NSTimer * _Nonnull timer) {
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) return;
            [self updateGameTime];
        }];

        [[NSNotificationCenter defaultCenter] postNotificationName:@"DSAGameClockStarted"
                                                            object:self];
    }
}

- (void)pauseClock {
    if (self.gameTimer) {
        [self.gameTimer invalidate];
        self.gameTimer = nil;

        [[NSNotificationCenter defaultCenter] postNotificationName:@"DSAGameClockPaused"
                                                            object:self];
    }
}

#pragma mark - Game Speed

- (void)setGameSpeedMultiplier:(double)newMultiplier {
    if (_gameSpeedMultiplier != newMultiplier) {
        _gameSpeedMultiplier = newMultiplier;

        if (self.gameTimer) {
            [self pauseClock];
            [self startClock];
        }

        [[NSNotificationCenter defaultCenter] postNotificationName:@"DSAGameSpeedChanged"
                                                            object:self
                                                          userInfo:@{@"multiplier": @(newMultiplier)}];
    }
}

- (void)setTravelModeEnabled:(BOOL)enabled {
    [self setGameSpeedMultiplier:enabled ? DSAGameSpeedTravel : DSAGameSpeedNormal];
}

#pragma mark - Time Advancement

- (void)updateGameTime {
    [self advanceTimeBySeconds: _gameSpeedMultiplier sendNotification: NO];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"DSAGameTimeAdvanced"
                                                        object:self
                                                      userInfo:@{@"currentDate": [self.currentDate copy],
                                                                 @"advancedSeconds": @(_gameSpeedMultiplier) }];
}


- (void)advanceTimeBySeconds:(NSUInteger)seconds sendNotification:(BOOL)notify {
    NSUInteger totalMinutes = seconds / 60;
    if (totalMinutes > 0) {
        [self advanceTimeByMinutes:totalMinutes sendNotification:NO]; // Minuten werden intern weitergerechnet
    }

    NSUInteger leftoverSeconds = seconds % 60;
    if (leftoverSeconds > 0) {
        self->_residualSeconds += leftoverSeconds;
        if (self->_residualSeconds >= 60) {
            [self advanceTimeByMinutes:self->_residualSeconds / 60 sendNotification:NO];
            self->_residualSeconds %= 60;
        }
    }

    if (notify) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DSAGameTimeAdvanced"
                                                            object:self
                                                          userInfo:@{@"currentDate": [self.currentDate copy],
                                                                     @"advancedSeconds": @(seconds)}];
    }
}

- (void)advanceTimeByMinutes:(NSUInteger)minutes sendNotification:(BOOL)notify {
    NSUInteger newMinutes = self.currentDate.minute + minutes;
    self.currentDate.hour += newMinutes / 60;
    self.currentDate.minute = newMinutes % 60;

    if (self.currentDate.hour >= 24) {
        [self advanceTimeByDays:self.currentDate.hour / 24 sendNotification:NO];
        self.currentDate.hour %= 24;
    }

    if (notify) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DSAGameTimeAdvanced"
                                                            object:self
                                                          userInfo:@{@"currentDate": [self.currentDate copy],
                                                                     @"advancedSeconds": @(minutes*60)}];
    }
}

- (void)advanceTimeByHours:(NSUInteger)hours sendNotification:(BOOL)notify {
    self.currentDate.hour += hours;
    if (self.currentDate.hour >= 24) {
        [self advanceTimeByDays:self.currentDate.hour / 24 sendNotification:NO];
        self.currentDate.hour %= 24;
    }

    if (notify) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DSAGameTimeAdvanced"
                                                            object:self
                                                          userInfo:@{@"currentDate": [self.currentDate copy],
                                                                     @"advancedSeconds": @(hours*3600)}];
    }
}

- (void)advanceTimeByDays:(NSUInteger)days sendNotification:(BOOL)notify {
    self.currentDate.day += days;
    NSUInteger daysInMonth = 30;
    if (self.currentDate.day > daysInMonth) {
        self.currentDate.month += self.currentDate.day / daysInMonth;
        self.currentDate.day %= daysInMonth;
    }

    if (self.currentDate.month > DSAAventurianMonthNamenlos) {
        self.currentDate.year++;
        self.currentDate.month = DSAAventurianMonthPraios;
    }

    if (notify) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DSAGameTimeAdvanced"
                                                            object:self
                                                          userInfo:@{@"currentDate": [self.currentDate copy],
                                                                     @"advancedSeconds": @(days*24*3600)}];
    }
}

#pragma mark - Moon Phase

- (DSAMoonPhase)currentMoonPhase {
    NSUInteger d = self.currentDate.day;
    if (d == 1) return DSAMoonPhaseNewMoon;
    else if (d <= 7) return DSAMoonPhaseWaxingCrescent;
    else if (d <= 8) return DSAMoonPhaseFirstQuarter;
    else if (d <= 14) return DSAMoonPhaseWaxingGibbous;
    else if (d == 15) return DSAMoonPhaseFullMoon;
    else if (d <= 21) return DSAMoonPhaseWaningGibbous;
    else if (d == 22) return DSAMoonPhaseLastQuarter;
    return DSAMoonPhaseWaningCrescent;
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
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.currentDate forKey:@"currentDate"];
    [coder encodeInteger:self.residualSeconds forKey:@"residualSeconds"];
    [coder encodeDouble:self.gameSpeedMultiplier forKey:@"gameSpeedMultiplier"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _currentDate = [coder decodeObjectForKey:@"currentDate"];
        _residualSeconds = [coder decodeIntegerForKey:@"residualSeconds"];
        _gameSpeedMultiplier = [coder decodeDoubleForKey:@"gameSpeedMultiplier"];
        [self startClock];
    }
    return self;
}

#pragma mark - Current Accessors
- (NSUInteger)currentMonth { return self.currentDate.month; }
- (NSUInteger)currentDay { return self.currentDate.day; }
- (NSUInteger)currentHour { return self.currentDate.hour; }
- (NSUInteger)currentMinute { return self.currentDate.minute; }

@end

