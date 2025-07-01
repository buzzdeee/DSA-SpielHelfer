/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-06-29 22:10:46 +0200 by sebastia

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

#ifndef _DSAPRICINGENGINE_H_
#define _DSAPRICINGENGINE_H_

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DSAServiceCategory) {
    DSAServiceCategoryInnRoom,
    DSAServiceCategoryMeal
};

typedef NS_ENUM(NSInteger, DSARoomType) {
    DSARoomTypeDormitory,
    DSARoomTypeSingle,
    DSARoomTypeSuite
};

typedef NS_ENUM(NSInteger, DSAMealQuality) {
    DSAMealQualitySimple,
    DSAMealQualityGood,
    DSAMealQualityFine,
    DSAMealQualityFeast
};

NS_ASSUME_NONNULL_BEGIN

@interface DSAPricingResult : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) float price;
@end

@interface DSAPricingEngine : NSObject

+ (DSAPricingResult *)priceForServiceCategory:(DSAServiceCategory)category
                                      subtype:(NSInteger)subtype
                                         seed:(NSString *)seed;

// reverse mapping of the diverse room type names to DSARoomType
+ (nullable NSNumber *)roomTypeFromName:(NSString *)name;
// reverse mapping of the diverse meals to DSAMealQuality
+ (nullable NSNumber *)mealQualityFromName:(NSString *)name;                                 
@end
NS_ASSUME_NONNULL_END
#endif // _DSAPRICINGENGINE_H_

