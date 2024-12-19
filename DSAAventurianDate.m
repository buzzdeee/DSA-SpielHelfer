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
        NSLog(@"DSAAventurianDate before hour");
        _hourName = [self hourNameForHour:hour];
        NSLog(@"DSAAventurianDate before weekdayName");
        _weekdayName = [self weekdayForAventurianDateWithYear: _year
                                                        month: _month
                                                          day: _day];
        NSLog(@"DSAAventurianDate before monthName: %lu", _month);                                                          
        _monthName = [self monthNameForMonth: month];
    }
    NSLog(@"DSAAventurianDate : initWithYear returning self: %@", self);
    return self;
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


- (void)encodeWithCoder:(NSCoder *)coder
{

  [coder encodeObject:@(self.year) forKey:@"year"];
  [coder encodeObject:@(self.month) forKey:@"month"];
  [coder encodeObject:@(self.year) forKey:@"day"];
  [coder encodeObject:@(self.month) forKey:@"hour"];
  [coder encodeObject:self.hourName forKey:@"hourName"];
  [coder encodeObject:self.weekdayName forKey:@"weekdayName"];
  [coder encodeObject:self.monthName forKey:@"monthName"];
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
      self.hourName = [coder decodeObjectForKey:@"hourName"];
      self.weekdayName = [coder decodeObjectForKey:@"weekdayName"];
      self.monthName = [coder decodeObjectForKey:@"monthName"];

    }
  return self;
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



@end