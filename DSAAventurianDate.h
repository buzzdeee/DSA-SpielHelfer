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

#import <Foundation/Foundation.h>

#import <Foundation/Foundation.h>

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


@interface DSAAventurianDate : NSObject <NSCoding>

@property (nonatomic, assign) NSInteger year;
@property (nonatomic, assign) DSAAventurianMonth month;
@property (nonatomic, assign) NSUInteger day;
@property (nonatomic, assign) NSUInteger hour;
@property (nonatomic, strong) NSString *hourName;
@property (nonatomic, strong) NSString *weekdayName;
@property (nonatomic, strong) NSString *monthName;

- (instancetype)initWithYear:(NSInteger)year month:(DSAAventurianMonth)month day:(NSUInteger)day hour:(NSUInteger)hour;

// Helper methods
- (NSString *)hourNameForHour:(NSUInteger)hour;
- (NSString *)weekdayForAventurianDateWithYear:(NSInteger)year month:(NSUInteger)month day:(NSUInteger)day;


@end



#endif // _DSAAVENTURIANDATE_H_

