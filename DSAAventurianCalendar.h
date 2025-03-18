/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-12-19 18:32:38 +0100 by sebastia

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

#ifndef _DSAAVENTURIANCALENDAR_H_
#define _DSAAVENTURIANCALENDAR_H_

#import <Foundation/Foundation.h>
#import "DSAAventurianDate.h"

/*
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
*/
@interface DSAAventurianCalendar : NSObject

+ (DSAAventurianDate *)convertToAventurian:(NSDate *)gregorianDate;
+ (NSUInteger)calculateAventurianAgeFromBirthDate:(DSAAventurianDate *)birthDate
                            currentAventurianDate:(DSAAventurianDate *)currentDate;
// calculation against current gregorian system date                            
+ (NSUInteger)calculateAventurianAgeFromBirthDate:(DSAAventurianDate *)birthDate;

+ (NSInteger)calculateAventurianYearOfBirthFromCurrentDate:(DSAAventurianDate *)currentDate
                                        birthdayMonth:(DSAAventurianMonth)birthdayMonth
                                             birthdayDay:(NSUInteger)birthdayDay
                                            currentAge:(NSUInteger)currentAge;

+ (NSString *)monthNameForMonth:(DSAAventurianMonth)month;
+ (DSAAventurianMonth)monthForString:(NSString *)monthName;
/*
+ (NSUInteger)currentMonth;
+ (NSUInteger)currentDay;
+ (NSUInteger)currentHour;
+ (NSUInteger)currentMinute;


+ (DSAMoonPhase)currentMoonPhase;
+ (NSString *)moonPhaseNameForPhase:(DSAMoonPhase)phase;
*/
@end


#endif // _DSAAVENTURIANCALENDAR_H_

