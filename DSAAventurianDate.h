/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-12-19 18:30:58 +0100 by sebastia

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

#ifndef _DSAAVENTURIANDATE_H_
#define _DSAAVENTURIANDATE_H_

#import "DSABaseObject.h"

typedef NS_ENUM(NSUInteger, DSAAventurianMonth) {
    DSAAventurianMonthPraios = 1,
    DSAAventurianMonthRondra,
    DSAAventurianMonthEfferd,
    DSAAventurianMonthTravia,
    DSAAventurianMonthBoron,
    DSAAventurianMonthHesinde,
    DSAAventurianMonthFirun,
    DSAAventurianMonthTsa,
    DSAAventurianMonthPhex,
    DSAAventurianMonthPeraine,
    DSAAventurianMonthIngerimm,
    DSAAventurianMonthRahja,
    DSAAventurianMonthNamenlos = 13
};

typedef NS_ENUM(NSUInteger, DSAAventurianWeekday) {
    Windstag = 0,   // Donnerstag
    Erdstag = 1,    // Freitag
    Markttag = 2,   // Samstag
    Praiostag = 3,  // Sonntag
    Rohalstag = 4,  // Montag
    Feuertag = 5,   // Dienstag
    Wassertag = 6   // Mittwoch
};

typedef NS_ENUM(NSInteger, DSAAventurianSeason) {
    DSAAventurianSeasonSpring, // 1
    DSAAventurianSeasonSummer, // 2
    DSAAventurianSeasonAutumn, // 3
    DSAAventurianSeasonWinter  // 4
};

NS_ASSUME_NONNULL_BEGIN

@interface DSAAventurianDate : DSABaseObject <NSCoding>

@property (nonatomic, assign) NSInteger year;
@property (nonatomic, assign) DSAAventurianMonth month;
@property (nonatomic, assign) NSUInteger day;
@property (nonatomic, assign) NSUInteger hour;
@property (nonatomic, assign) NSUInteger minute;
@property (nonatomic, readonly) NSString *hourName;
@property (nonatomic, readonly) NSString *weekdayName;
@property (nonatomic, readonly) NSString *monthName;
@property (nonatomic, readonly) NSString *seasonName;

- (instancetype)initWithYear:(NSInteger)year month:(DSAAventurianMonth)month day:(NSUInteger)day hour:(NSUInteger)hour;

// Helper methods
- (NSString *)hourNameForHour:(NSUInteger)hour;
- (NSString *)weekdayForAventurianDateWithYear:(NSInteger)year month:(NSUInteger)month day:(NSUInteger)day;

- (NSUInteger) daysInMonth: (DSAAventurianMonth)month;   // returns the number of days in a given month
- (nullable DSAAventurianDate *)dateByAddingYears:(NSInteger)years    // calculates and returns a new date in the future
                                             days:(NSInteger)days
                                            hours:(NSInteger)hours
                                          minutes:(NSInteger)minutes;

// Compare dates with each other
- (BOOL)isEarlierThanDate:(DSAAventurianDate *)otherDate;
- (BOOL)isLaterThanDate:(DSAAventurianDate *)otherDate;
- (BOOL)isBetweenDate:(DSAAventurianDate *)startDate andDate:(DSAAventurianDate *)endDate;


- (NSString *) dateString;

@end

NS_ASSUME_NONNULL_END

#endif // _DSAAVENTURIANDATE_H_

