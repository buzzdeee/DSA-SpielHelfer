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

#import "DSAAventurianDate.h"

@implementation DSAAventurianDate

// Anchor date: 1. Praios 1000 BF = Praiostag
static const NSInteger ANCHOR_YEAR = 1000;
static const NSInteger ANCHOR_MONTH = 1;
static const NSInteger ANCHOR_DAY = 1;
static const DSAAventurianWeekday ANCHOR_WEEKDAY = Praiostag;

- (instancetype)initWithYear:(NSInteger)year month:(DSAAventurianMonth)month day:(NSUInteger)day hour:(NSUInteger)hour {
    self = [super init];
    if (self) {
        _year = year;
        _month = month;
        _day = day;
        _hour = hour;
        _minute = 0;
    }
    NSLog(@"DSAAventurianDate : initWithYear returning self: %@", self);
    return self;
}

- (NSString *) hourName
{
  return [self hourNameForHour:self.hour];
}

- (NSString *) weekdayName
{
  return [self weekdayForAventurianDateWithYear: self.year
                                          month: self.month
                                            day: self.day];
}

- (NSString *) monthName
{
  return [self monthNameForMonth: self.month];
}

// Convert hour to hour name based on the Aventurian calendar
- (NSString *)hourNameForHour:(NSUInteger)hour {
    NSArray *hourNames = @[
        @"Praios", @"Rondra", @"Efferd", @"Travia", @"Boron", @"Hesinde",
        @"Firun", @"Tsa", @"Phex", @"Peraine", @"Ingerimm", @"Rahja",
        @"Praios", @"Rondra", @"Efferd", @"Travia", @"Boron", @"Hesinde",
        @"Firun", @"Tsa", @"Phex", @"Peraine", @"Ingerimm", @"Rahja"
    ];
    return hourNames[hour];
}

// Convert hour to hour name based on the Aventurian calendar
- (NSString *)monthNameForMonth:(DSAAventurianMonth)month {
    NSArray *monthNames = @[
        @"Praios", @"Rondra", @"Efferd", @"Travia", @"Boron", @"Hesinde",
        @"Firun", @"Tsa", @"Phex", @"Peraine", @"Ingerimm", @"Rahja"
    ];
    return monthNames[month - 1]; 
}


- (NSString *)weekdayForAventurianDateWithYear:(NSInteger)year month:(NSUInteger)month day:(NSUInteger)day {
    NSInteger totalDaysForGivenDate = (year - 1) * 365 + (month - 1) * 30 + day;
    NSInteger totalDaysForAnchorDate = (ANCHOR_YEAR - 1) * 365 + (ANCHOR_MONTH - 1) * 30 + ANCHOR_DAY;
    NSInteger daysSinceAnchor = totalDaysForGivenDate - totalDaysForAnchorDate;

    // since the reference day was a Sunday/Praiostag, start here with Praiostag
    NSArray *weekdays = @[@"Praiostag", @"Rohalstag", @"Feuertag", @"Wassertag", @"Windstag", @"Erdstag", @"Markttag"];
    NSUInteger weekdayIndex = (ANCHOR_WEEKDAY + daysSinceAnchor) % 7;
    return weekdays[weekdayIndex];
}

- (NSUInteger) daysInMonth: (DSAAventurianMonth) month
{
  switch (month) {
    case DSAAventurianMonthNamenlos: return 5;
    default: return 30;
  }
}

- (nullable DSAAventurianDate *)dateByAddingYears:(NSInteger)years
                                             days:(NSInteger)days
                                            hours:(NSInteger)hours
                                          minutes:(NSInteger)minutes
{

    // bail out, in case of negative values...
    if (years < 0 || days < 0 || hours < 0 || minutes < 0) {
        NSLog(@"DSAAventurianDate dateByAddingYears ... Error: negative values are not supported.");
        return nil; // or maybe return self to keep the current date?
    }

    // Lokale Kopien zur Bearbeitung
    NSInteger newYear = self.year + years;
    NSUInteger newDay = self.day + days;
    NSUInteger newHour = self.hour + hours;
    NSUInteger newMinute = self.minute + minutes;
    DSAAventurianMonth newMonth = self.month;

    // Minuten -> Stunden
    if (newMinute >= 60) {
        newHour += newMinute / 60;
        newMinute = newMinute % 60;
    }

    // Stunden -> Tage
    if (newHour >= 24) {
        newDay += newHour / 24;
        newHour = newHour % 24;
    }

    // Tage -> Monate (vereinfacht, je nach Monat unterschiedlich viele Tage)
    while (newDay > [self daysInMonth:newMonth]) {
        newDay -= [self daysInMonth:newMonth];
        newMonth += 1;
        if (newMonth > DSAAventurianMonthNamenlos) {
            newMonth = 1;
            newYear += 1;
        }
    }

    DSAAventurianDate *newDate = [[DSAAventurianDate alloc] init];
    newDate.year = newYear;
    newDate.month = newMonth;
    newDate.day = newDay;
    newDate.hour = newHour;
    newDate.minute = newMinute;

    return newDate;
}

- (void)encodeWithCoder:(NSCoder *)coder
{

  [coder encodeObject:@(self.year) forKey:@"year"];
  [coder encodeObject:@(self.month) forKey:@"month"];
  [coder encodeObject:@(self.day) forKey:@"day"];
  [coder encodeObject:@(self.hour) forKey:@"hour"];
  [coder encodeObject:@(self.minute) forKey:@"minute"];
  NSLog(@"DSAAventurianDate encodeWithCoder encoded: year %ld month %ld day %ld hour %ld minute %ld", self.year, self.month, self.day, self.hour, self.minute);
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
  self = [super init];
  if (self)
    {
      self.year = [[coder decodeObjectForKey:@"year"] integerValue];
      self.month = [[coder decodeObjectForKey:@"month"] integerValue];
      self.day = [[coder decodeObjectForKey:@"day"] integerValue];
      self.hour = [[coder decodeObjectForKey:@"hour"] integerValue];
      self.minute = [[coder decodeObjectForKey:@"minute"] integerValue];
      NSLog(@"DSAAventurianDate initWithCoder inited: year %ld month %ld day %ld hour %ld minute %ld", self.year, self.month, self.day, self.hour, self.minute);
    }
  return self;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[DSAAventurianDate class]]) {
        return NO;
    }

    DSAAventurianDate *otherDate = (DSAAventurianDate *)object;

    return self.year == otherDate.year &&
           self.month == otherDate.month &&
           self.day == otherDate.day &&
           self.hour == otherDate.hour &&
           self.minute == otherDate.minute;
}

- (NSUInteger)hash {
    NSUInteger hash = 17;
    hash = hash * 31 + self.year;
    hash = hash * 31 + self.month;
    hash = hash * 31 + self.day;
    hash = hash * 31 + self.hour;
    hash = hash * 31 + self.minute;
    return hash;
}

- (NSComparisonResult)compare:(DSAAventurianDate *)otherDate {
    if (self.year != otherDate.year) {
        return (self.year < otherDate.year) ? NSOrderedAscending : NSOrderedDescending;
    }
    if (self.month != otherDate.month) {
        return (self.month < otherDate.month) ? NSOrderedAscending : NSOrderedDescending;
    }
    if (self.day != otherDate.day) {
        return (self.day < otherDate.day) ? NSOrderedAscending : NSOrderedDescending;
    }
    if (self.hour != otherDate.hour) {
        return (self.hour < otherDate.hour) ? NSOrderedAscending : NSOrderedDescending;
    }
    if (self.minute != otherDate.minute) {
        return (self.minute < otherDate.minute) ? NSOrderedAscending : NSOrderedDescending;
    }

    return NSOrderedSame;
}

- (BOOL)isEarlierThanDate:(DSAAventurianDate *)otherDate {
    return [self compare:otherDate] == NSOrderedAscending;
}

- (BOOL)isLaterThanDate:(DSAAventurianDate *)otherDate {
    return [self compare:otherDate] == NSOrderedDescending;
}

- (BOOL)isBetweenDate:(DSAAventurianDate *)startDate andDate:(DSAAventurianDate *)endDate {
    NSComparisonResult startToEnd = [startDate compare:endDate];
    
    if (startToEnd == NSOrderedSame) {
        return [self compare:startDate] == NSOrderedSame;
    } else if (startToEnd == NSOrderedAscending) {
        return ([self compare:startDate] != NSOrderedAscending &&
                [self compare:endDate] != NSOrderedDescending);
    } else { // startDate is after endDate
        return ([self compare:endDate] != NSOrderedAscending &&
                [self compare:startDate] != NSOrderedDescending);
    }
}

- (NSString *)description
{
  NSMutableString *descriptionString = [NSMutableString stringWithFormat:@"%@:\n", [self class]];

  // Start from the current class
  Class currentClass = [self class];

  // Loop through the class hierarchy
  while (currentClass && currentClass != [NSObject class])
    {
      // Get the list of properties for the current class
      unsigned int propertyCount;
      objc_property_t *properties = class_copyPropertyList(currentClass, &propertyCount);

      // Iterate through all properties of the current class
      for (unsigned int i = 0; i < propertyCount; i++)
        {
          objc_property_t property = properties[i];
          const char *propertyName = property_getName(property);
          NSString *key = [NSString stringWithUTF8String:propertyName];
            
          // Get the value of the property using KVC (Key-Value Coding)
          id value = [self valueForKey:key];

          // Append the property and its value to the description string
          [descriptionString appendFormat:@"%@ = %@\n", key, value];
        }

      // Free the property list since it's a C array
      free(properties);

      // Move to the superclass
      currentClass = [currentClass superclass];
    }

  return descriptionString;
}

// Ignores readonly variables with the assumption
// they are all calculated

- (id)copyWithZone:(NSZone *)zone {
    DSAAventurianDate *copy = [[[self class] allocWithZone:zone] init];
    if (copy) {
        copy.year = self.year;
        copy.month = self.month;
        copy.day = self.day;
        copy.hour = self.hour;
        copy.minute = self.minute;
        // hourName, weekdayName, and monthName are readonly computed properties
        // so they don't need to be copied explicitly
    }
    return copy;
}

@end