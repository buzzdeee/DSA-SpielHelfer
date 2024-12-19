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

#import "DSAAventurianCalendar.h"

@implementation DSAAventurianCalendar

// https://de.wiki-aventurica.de/wiki/Zw%C3%B6lfg%C3%B6ttlicher_Kalender


// Method to convert Gregorian Date to Aventurian Date
+ (DSAAventurianDate *)convertToAventurian:(NSDate *)gregorianDate {
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour) fromDate:gregorianDate];
    
    NSUInteger gregorianYear = components.year;
//    NSUInteger gregorianMonth = components.month;
//    NSUInteger gregorianDay = components.day;
    NSUInteger gregorianHour = components.hour;

    // Correct the Aventurian year calculation
    NSUInteger aventurianYear = ((gregorianYear - 1984) * 2) + 1000; // Basic Aventurian year calculation

    // Calculate the day of the year for the Gregorian date
    NSUInteger dayOfYear = [[NSCalendar currentCalendar] ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitYear forDate:gregorianDate];

    // If it's the second half of the year (after June 30th), increment the Aventurian year
    if (dayOfYear > 180) {
        aventurianYear += 1;
    }

    NSUInteger aventurianMonth = 0;
    NSUInteger aventurianDay = 0;

    if (dayOfYear > 180) {
        // Second half of the year, calculate day of the year in Aventurian calendar
        NSUInteger daysSinceJuly = dayOfYear - 180;
        NSUInteger aventurianDayOfYear = daysSinceJuly * 2; // Multiply by 2 as Aventurian days are twice as fast

        if (aventurianDayOfYear > 360) {  // If it crosses the Namenlose Tage
            aventurianMonth = DSAAventurianMonthNamenlos;
            aventurianDay = aventurianDayOfYear - 360;  // The last days are Namenlose
        } else {
            // Calculate the Aventurian month and day (after July 1st)
            aventurianMonth = (aventurianDayOfYear / 30) + 1; // Each month has approximately 30 days
            aventurianDay = (aventurianDayOfYear % 30) + 1;
        }
    } else {
        // First half of the year (before July), it's in the Namenlose days
        NSUInteger aventurianDayOfYear = dayOfYear * 2; // Days are doubled in Aventurian calendar
        if (aventurianDayOfYear > 360) {  // If it crosses the Namenlose Tage
            aventurianMonth = DSAAventurianMonthNamenlos;
            aventurianDay = aventurianDayOfYear - 360;  // The last days are Namenlose
        } else {
            // Calculate the Aventurian month and day (after July 1st)
            aventurianMonth = (aventurianDayOfYear / 30) + 1; // Each month has approximately 30 days
            aventurianDay = (aventurianDayOfYear % 30) + 1;
        }
    }

    // Convert hours from the Gregorian time to the Aventurian calendar
    NSUInteger aventurianHour = gregorianHour * 2;
    if (aventurianHour >= 24) {
        aventurianHour -= 24;
        aventurianDay += 1;
    }

    return [[DSAAventurianDate alloc] initWithYear:aventurianYear month:(DSAAventurianMonth)aventurianMonth day:aventurianDay hour:aventurianHour];
}

+ (NSUInteger)calculateAventurianAgeFromBirthDate:(DSAAventurianDate *)birthDate
                            currentAventurianDate:(DSAAventurianDate *)currentDate {
    // Calculate the initial age based on the year difference
    NSUInteger age = currentDate.year - birthDate.year;

    // If the current date is before the birthday in the current year, subtract 1
    if (currentDate.month < birthDate.month || 
        (currentDate.month == birthDate.month && currentDate.day < birthDate.day)) {
        age -= 1;
    }

    return age;
}

+ (NSUInteger)calculateAventurianAgeFromBirthDate:(DSAAventurianDate *)birthDate {
    // Get the current Gregorian date
    NSDate *currentDate = [NSDate date];
    
    // Convert the current Gregorian date to an Aventurian date
    DSAAventurianDate *currentAventurianDate = [self convertToAventurian:currentDate];
    
    // Calculate the age in Aventurian years
    NSUInteger age = currentAventurianDate.year - birthDate.year;
    
    // Check if the current date is before the person's birthday in the current year
    if (currentAventurianDate.month < birthDate.month || 
        (currentAventurianDate.month == birthDate.month && currentAventurianDate.day < birthDate.day)) {
        age -= 1; // If the birthday hasn't occurred yet this year, subtract 1 year
    }
    
    return age;
}

+ (NSInteger)calculateAventurianYearOfBirthFromCurrentDate:(DSAAventurianDate *)currentDate
                                        birthdayMonth:(DSAAventurianMonth)birthdayMonth
                                             birthdayDay:(NSUInteger)birthdayDay
                                            currentAge:(NSUInteger)currentAge {
    // Calculate the potential birth year
    NSUInteger birthYear = currentDate.year - currentAge;
    
    // Check if the birthday has already passed this year
    if (currentDate.month < birthdayMonth || 
        (currentDate.month == birthdayMonth && currentDate.day < birthdayDay)) {
        // If the birthday hasn't passed yet this year, subtract 1 from the birth year
        birthYear -= 1;
    }
    
    return birthYear;
}

// Method to get the name of the month in the Aventurian calendar
+ (NSString *)monthNameForMonth:(DSAAventurianMonth)month {
    switch (month) {
        case DSAAventurianMonthPraios: return @"Praios";
        case DSAAventurianMonthRondra: return @"Rondra";
        case DSAAventurianMonthEfferd: return @"Efferd";
        case DSAAventurianMonthTravia: return @"Travia";
        case DSAAventurianMonthBoron: return @"Boron";
        case DSAAventurianMonthHesinde: return @"Hesinde";
        case DSAAventurianMonthFirun: return @"Firun";
        case DSAAventurianMonthTsa: return @"Tsa";
        case DSAAventurianMonthPhex: return @"Phex";
        case DSAAventurianMonthPeraine: return @"Peraine";
        case DSAAventurianMonthIngerimm: return @"Ingerimm";
        case DSAAventurianMonthRahja: return @"Rahja";
        case DSAAventurianMonthNamenlos: return @"Tage des Namenlosen";
        default: return @"Unbekannt";
    }
}

// Method to get the Aventurian month enum from a month name string
+ (DSAAventurianMonth)monthForString:(NSString *)monthName {
    if ([monthName isEqualToString:@"Praios"]) {
        return DSAAventurianMonthPraios;
    } else if ([monthName isEqualToString:@"Rondra"]) {
        return DSAAventurianMonthRondra;
    } else if ([monthName isEqualToString:@"Efferd"]) {
        return DSAAventurianMonthEfferd;
    } else if ([monthName isEqualToString:@"Travia"]) {
        return DSAAventurianMonthTravia;
    } else if ([monthName isEqualToString:@"Boron"]) {
        return DSAAventurianMonthBoron;
    } else if ([monthName isEqualToString:@"Hesinde"]) {
        return DSAAventurianMonthHesinde;
    } else if ([monthName isEqualToString:@"Firun"]) {
        return DSAAventurianMonthFirun;
    } else if ([monthName isEqualToString:@"Tsa"]) {
        return DSAAventurianMonthTsa;
    } else if ([monthName isEqualToString:@"Phex"]) {
        return DSAAventurianMonthPhex;
    } else if ([monthName isEqualToString:@"Peraine"]) {
        return DSAAventurianMonthPeraine;
    } else if ([monthName isEqualToString:@"Ingerimm"]) {
        return DSAAventurianMonthIngerimm;
    } else if ([monthName isEqualToString:@"Rahja"]) {
        return DSAAventurianMonthRahja;
    } else if ([monthName isEqualToString:@"Tage des Namenlosen"]) {
        return DSAAventurianMonthNamenlos;
    } else {
        // If the string doesn't match any month, return a default or an invalid enum value
        return 0;  // Invalid month
    }
}

+ (NSUInteger)currentMonth {
    // Get the current date
    NSDate *currentDate = [NSDate date];

    // Convert the current Gregorian date to an Aventurian date
    DSAAventurianDate *aventurianDate = [self convertToAventurian:currentDate];

    // Return the current Aventurian month
    return aventurianDate.month;
}

+ (NSUInteger)currentDay {
    // Get the current date
    NSDate *currentDate = [NSDate date];

    // Convert the current Gregorian date to an Aventurian date
    DSAAventurianDate *aventurianDate = [self convertToAventurian:currentDate];

    // Return the current Aventurian day
    return aventurianDate.day;
}

@end
