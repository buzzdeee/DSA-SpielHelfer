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

#ifndef _DSAADVENTURECLOCK_H_
#define _DSAADVENTURECLOCK_H_

#import <Foundation/Foundation.h>
#import "DSAAventurianDate.h"

@interface DSAAdventureClock : NSObject <NSCoding>

typedef NS_ENUM(NSUInteger, DSAMoonPhase) {
    DSAMoonPhaseNewMoon = 0,     // Day 1
    DSAMoonPhaseWaxingCrescent,  // Days 2-7
    DSAMoonPhaseFirstQuarter,    // Day 8
    DSAMoonPhaseWaxingGibbous,   // Days 9-14
    DSAMoonPhaseFullMoon,        // Day 15
    DSAMoonPhaseWaningGibbous,   // Days 16-21
    DSAMoonPhaseLastQuarter,     // Day 22
    DSAMoonPhaseWaningCrescent   // Days 23-28
};

@property (nonatomic, strong) DSAAventurianDate *currentDate;
@property (nonatomic, assign) NSTimeInterval gameSpeedMultiplier; // 2.0 means 2x real-time
@property (nonatomic, strong) NSTimer *gameTimer;

- (void)startClock;
- (void)pauseClock;
- (void)advanceTimeByMinutes:(NSUInteger)minutes;
- (void)advanceTimeByHours:(NSUInteger)hours;
- (void)advanceTimeByDays:(NSUInteger)days;

//- (NSString *)monthNameForMonth:(DSAAventurianMonth)month;
//- (DSAAventurianMonth)monthForString:(NSString *)monthName;
- (NSUInteger)currentMonth;
- (NSUInteger)currentDay;
- (NSUInteger)currentHour;
- (NSUInteger)currentMinute;

- (DSAMoonPhase)currentMoonPhase;
- (NSString *)moonPhaseNameForPhase:(DSAMoonPhase)phase;

@end

#endif // _DSAADVENTURECLOCK_H_

