/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-01-03 19:51:23 +0100 by sebastia

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

#import "DSANameGenerator.h"

@implementation DSANameGenerator

- (instancetype)initWithNameDictionary:(NSDictionary *)nameDictionary {
    self = [super init];
    if (self) {
        self.nameData = nameDictionary;
    }
    return self;
}

- (NSString *)getRandomElementFromArray:(NSArray *)array {
    if (!array || array.count == 0) {
        @throw [NSException exceptionWithName:@"InvalidArrayException" reason:@"Expected a non-empty array" userInfo:nil];
    }
    NSUInteger randomIndex = arc4random_uniform((uint32_t)array.count);
    return array[randomIndex];
}

- (NSString *)getFirstNameIsMale:(BOOL)isMale noble:(BOOL)noble {
    NSDictionary *regionSpecifics = self.nameData[@"regionSpecifics"];

    NSArray *maleFirstNames = self.nameData[@"maleFirstNames"];
    NSArray *femaleFirstNames = self.nameData[@"femaleFirstNames"];

    if (noble && [regionSpecifics[@"hasNobleFirstNames"] boolValue]) {
        maleFirstNames = self.nameData[@"nobleMaleFirstNames"];
        femaleFirstNames = self.nameData[@"nobleFemaleFirstNames"];
    }

    if (!maleFirstNames || !femaleFirstNames) {
        @throw [NSException exceptionWithName:@"InvalidDataException" reason:@"Missing name lists in region data" userInfo:nil];
    }

    NSString *firstName;
    if ([regionSpecifics[@"hasMultiFirstNames"] boolValue]) {
        // Generate multi-part first name (example logic)
        NSUInteger count = arc4random_uniform(2) + 1; // Randomly choose 1 or 2 parts
        NSMutableArray *nameParts = [NSMutableArray array];

        for (NSUInteger i = 0; i < count; i++) {
            NSString *part = isMale ? [self getRandomElementFromArray:maleFirstNames] : [self getRandomElementFromArray:femaleFirstNames];
            [nameParts addObject:part];
        }

        firstName = [nameParts componentsJoinedByString:@" "];
    } else {
        firstName = isMale ? [self getRandomElementFromArray:maleFirstNames] : [self getRandomElementFromArray:femaleFirstNames];
    }

    return firstName;
}

- (NSString *)getEpithet {
    NSDictionary *regionSpecifics = self.nameData[@"regionSpecifics"];

    if ([regionSpecifics[@"hasEpithets"] boolValue]) {
        NSArray *epithets = self.nameData[@"epithets"];
        return [self getRandomElementFromArray:epithets];
    }
    return @"";
}

- (NSString *)getClanName {
    NSDictionary *regionSpecifics = self.nameData[@"regionSpecifics"];

    if ([regionSpecifics[@"hasClanNames"] boolValue]) {
        NSArray *clanNames = self.nameData[@"clanNames"];
        if (arc4random_uniform(10) < 4)
          {
            return [self getRandomElementFromArray:clanNames];
          }
        else
          {
            return @"";
          }
    }
    return @"";
}

- (NSString *)getLastNameIsMale: (BOOL)isMale noble: (BOOL) isNoble {
    NSDictionary *regionSpecifics = self.nameData[@"regionSpecifics"];

    if (![regionSpecifics[@"hasNoLastName"] boolValue]) {
        NSMutableArray *lastNames;
      NSLog(@"WE HAVE LAST NAME!");
        if ([regionSpecifics[@"lastNamesAreAllFirstNames"] boolValue])
          {
            lastNames = [self.nameData[@"maleFirstNames"] mutableCopy];
            [lastNames addObjectsFromArray: self.nameData[@"femaleFirstNames"]];
          }
        else if (isNoble)
          {
            NSLog(@"WE ARE NOBLE");
            if ([regionSpecifics[@"nobleNamesAreLastNames"] boolValue] == YES)
              {
                NSLog(@"nobleNamesAreLastNames!!! YES");
                lastNames = self.nameData[@"lastNames"];
              }
            else
              {
                NSLog(@"nobleNamesAreLastNames!!! NO");
                lastNames = self.nameData[@"nobleNames"];
              }
          }
        else
          {
            lastNames = self.nameData[@"lastNames"];
          }
        NSMutableString *lastName = [[self getRandomElementFromArray:lastNames] mutableCopy];
        NSLog(@"HAVE THIS LAST NAME: %@", lastName);
        if ([regionSpecifics[@"hasGenderSpecificLastName"] boolValue])
          {
            NSLog(@"WE HAVE GENDER SPECIFIC LAST NAMES" );
            if (isMale)
              {
                NSUInteger randomIndex = arc4random_uniform((uint32_t)[self.nameData[@"lastNamesMaleSuffix"] count]);
                [lastName appendString: [self.nameData[@"lastNamesMaleSuffix"] objectAtIndex: randomIndex]];
              }
            else
              {
                NSUInteger randomIndex = arc4random_uniform((uint32_t)[self.nameData[@"lastNamesFemaleSuffix"] count]);
                [lastName appendString: [self.nameData[@"lastNamesFemaleSuffix"] objectAtIndex: randomIndex]];
              }
          }
        NSLog(@"do we have noble prefix: %@ %@", regionSpecifics[@"hasNoblePrefix"], self.nameData[@"noblePrefix"]);
        if (isNoble && [regionSpecifics[@"hasNoblePrefix"] boolValue])
          {
            NSLog(@"WE HAVE NOBLE PREFIX SPECIFIC LAST NAMES" );
            NSUInteger randomIndex = arc4random_uniform((uint32_t)[self.nameData[@"noblePrefix"] count]);
            lastName = [[NSString stringWithFormat: @"%@%@", [self.nameData[@"noblePrefix"] objectAtIndex: randomIndex], lastName] mutableCopy];
          }        
        return lastName;
    }
    return @"";
}

+ (NSString *)generateNameWithGender:(NSString *)gender isNoble:(BOOL)isNoble nameData:(NSDictionary *)nameData {
    DSANameGenerator *generator = [[DSANameGenerator alloc] initWithNameDictionary:nameData];

    BOOL isMale = [gender.lowercaseString isEqualToString: _(@"männlich")];
    NSString *firstName = [generator getFirstNameIsMale: isMale noble: isNoble];
    NSString *lastName = [generator getLastNameIsMale: isMale noble: isNoble];
    NSString *epithet = [generator getEpithet];
    NSString *clan = [generator getClanName];

    NSMutableArray *nameComponents = [NSMutableArray arrayWithObject:firstName];
    if (lastName.length > 0) {
        [nameComponents addObject:lastName];
    }
    if (epithet.length > 0) {
        [nameComponents addObject:epithet];
    }
    if (clan.length > 0) {
        [nameComponents addObject:clan];
    }
  
    return [nameComponents componentsJoinedByString:@" "];
}

@end
