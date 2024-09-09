/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-09-09 02:03:56 +0200 by sebastia

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

#import "Utils.h"

@implementation Utils

static Utils *sharedInstance = nil;

+ (instancetype)sharedInstance {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[self alloc] init];
            // Perform additional setup if needed
        }
    }
    return sharedInstance;
}

+ (NSDictionary *) parseDice: (NSString *) diceDefinition
{
  int count, points;
  NSMutableDictionary *dice = [[NSMutableDictionary alloc] init];
  //NSLog(@"HERE IN parseDice!!!");
  NSScanner *scanner = [NSScanner scannerWithString: diceDefinition];
  [scanner scanInt: &count];
  [scanner scanCharactersFromSet: [NSCharacterSet characterSetWithCharactersInString:@"W"] intoString: NULL];
  [scanner scanInt: &points];
  
  [dice setValue: [NSNumber numberWithInt: count] forKey: @"count"];
  [dice setValue: [NSNumber numberWithInt: points] forKey: @"points"];

  NSLog(@"Utils : parseDice returning dice: %@", dice);  
  return dice;
}

+ (NSDictionary *) parseConstraint: (NSString *) constraintDefinition
{
  int value;
  NSString *cvalue;
  NSMutableDictionary *constraint = [[NSMutableDictionary alloc] init];
  NSScanner *scanner = [NSScanner scannerWithString: constraintDefinition];
  [scanner scanInt: &value];
  [scanner scanCharactersFromSet: [NSCharacterSet characterSetWithCharactersInString:@"+-"] intoString: &cvalue];
  
  [constraint setValue: [NSNumber numberWithInt: value] forKey: @"value"];
  if ([cvalue isEqualToString: @"+"])
    {
      [constraint setValue: @"MAX" forKey: @"constraint"];
    }
  else
    {
      [constraint setValue: @"MIN" forKey: @"constraint"];
    }
    
  NSLog(@"Utils: parseConstraint returning Constraint: %@", constraint);
  return constraint;
}

+ (NSNumber *) rollDice: (NSString *) diceDefinition
{
  NSDictionary *dice = [NSDictionary dictionaryWithDictionary: [Utils parseDice: diceDefinition]];
  int result = 0;
  for (int i=0; i<[[dice objectForKey: @"count"] intValue];i++)
    {
      result += arc4random_uniform([[dice objectForKey: @"points"] intValue]) + 1;
    }
  return [NSNumber numberWithInt: result];
}

@end
