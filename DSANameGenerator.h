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

#ifndef _DSANAMEGENERATOR_H_
#define _DSANAMEGENERATOR_H_

#import <Foundation/Foundation.h>

@interface DSANameGenerator : NSObject

@property (nonatomic, strong) NSDictionary *nameData;

// Initializer with name dictionary
- (instancetype)initWithNameDictionary:(NSDictionary *)nameDictionary;

// Utility methods
- (NSString *)getRandomElementFromArray:(NSArray *)array;
- (NSString *)getFirstNameIsMale:(BOOL)isMale noble:(BOOL)noble;
- (NSString *)getEpithet;
- (NSString *)getClanName;
- (NSString *)getLastNameIsMale: (BOOL)isMale noble: (BOOL) isNoble;

// Class method to generate a full name
+ (NSString *)generateNameWithGender: (NSString *)gender isNoble:(BOOL)isNoble nameData:(NSDictionary *)nameData;

@end


#endif // _DSANAMEGENERATOR_H_

