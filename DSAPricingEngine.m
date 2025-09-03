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

#import "DSAPricingEngine.h"

@implementation DSAPricingResult
@end

@implementation DSAPricingEngine

+ (DSAPricingResult *)priceForServiceCategory:(DSAServiceCategory)category
                                      subtype:(NSInteger)subtype
                                         seed:(NSString *)seed
{
    switch (category) {
        case DSAServiceCategoryMeal:
            return [self mealPriceWithQuality:(DSAMealQuality)subtype seed:seed];
        case DSAServiceCategoryInnRoom:
            return [self roomPriceWithType:(DSARoomType)subtype seed:seed];
        default:
            return nil;
    }
}

#pragma mark - Internal Helpers

+ (DSAPricingResult *)mealPriceWithQuality:(DSAMealQuality)quality seed:(NSString *)seed {
    NSArray *names;
    float base = 0, range = 0;
    switch (quality) {
        case DSAMealQualitySimple:
            names = @[@"Linseneintopf", @"Graupensuppe", @"Brot mit Schmalz"];
            base = 0.3f; range = 0.2f; break;
        case DSAMealQualityGood:
            names = @[@"Krustenbraten", @"Geflügelragout", @"Fischplatte"];
            base = 0.8f; range = 0.7f; break;
        case DSAMealQualityFine:
            names = @[@"Wildgulasch", @"Hirschbraten", @"Täubchen mit Pastete"];
            base = 2.0f; range = 3.0f; break;
        case DSAMealQualityFeast:
            names = @[@"Fünf-Gänge-Menü", @"Festtafel", @"Bankett mit Wildschwein"];
            base = 5.0f; range = 5.0f; break;
        case DSAMealQualityUnknown:
            NSLog(@"DSAPricingEngine mealPriceWithQuality: unknown price quality, aborting");
            abort();
            break;
    }

    NSString *combinedSeed = [NSString stringWithFormat:@"meal-%@-%ld", seed, (long)quality];
    uint32_t hash = [self hashFromSeed:combinedSeed];
    NSUInteger index = hash % names.count;
    float price = base + ((hash % 10000) / 10000.0f) * range;
    
    DSAPricingResult *result = [DSAPricingResult new];
    result.name = names[index];
    result.price = roundf(price * 10.0f) / 10.0f;
    return result;
}

+ (DSAPricingResult *)roomPriceWithType:(DSARoomType)type seed:(NSString *)seed {
    NSDictionary *roomBasePrices = @{
        @(DSARoomTypeDormitory): @(0.5f),
        @(DSARoomTypeSingle): @(2.0f),
        @(DSARoomTypeSuite): @(8.0f)
    };

    NSDictionary *roomNames = @{
        @(DSARoomTypeDormitory): @[@"Schlafsaal", @"Gemeinschaftsraum", @"Matratzenlager"],
        @(DSARoomTypeSingle): @[@"Einzelzimmer", @"Kammer", @"Gästezimmer"],
        @(DSARoomTypeSuite): @[@"Suite", @"Fürstenzimmer", @"Königliche Suite"]
    };

    float base = [roomBasePrices[@(type)] floatValue];
    NSArray *names = roomNames[@(type)];

    NSString *combinedSeed = [NSString stringWithFormat:@"room-%@-%ld", seed, (long)type];
    uint32_t hash = [self hashFromSeed:combinedSeed];

    // Name deterministisch wählen
    NSUInteger index = hash % names.count;

    // Preis mit ±10% Variation berechnen
    float variation = base * 0.10f;
    float price = base - variation + ((hash % 10000) / 10000.0f) * (variation * 2);
    price = roundf(price * 10.0f) / 10.0f;

    DSAPricingResult *result = [DSAPricingResult new];
    result.name = names[index];
    result.price = price;
    return result;
}

+ (nullable NSNumber *)roomTypeFromName:(NSString *)name {
    static NSDictionary<NSString *, NSNumber *> *nameToType = nil;
    nameToType = @{
            // Dormitory
            @"Schlafsaal": @(DSARoomTypeDormitory),
            @"Gemeinschaftsraum": @(DSARoomTypeDormitory),
            @"Matratzenlager": @(DSARoomTypeDormitory),
            
            // Single
            @"Einzelzimmer": @(DSARoomTypeSingle),
            @"Kammer": @(DSARoomTypeSingle),
            @"Gästezimmer": @(DSARoomTypeSingle),
            
            // Suite
            @"Suite": @(DSARoomTypeSuite),
            @"Fürstenzimmer": @(DSARoomTypeSuite),
            @"Königliche Suite": @(DSARoomTypeSuite)
    };
    
    return nameToType[name];  // gibt NSNumber mit DSARoomType oder nil zurück
}

+ (nullable NSNumber *)mealQualityFromName:(NSString *)name {
    static NSDictionary<NSString *, NSNumber *> *nameToQuality = nil;
    nameToQuality = @{
            // Simple
            @"Linseneintopf": @(DSAMealQualitySimple),
            @"Graupensuppe": @(DSAMealQualitySimple),
            @"Brot mit Schmalz": @(DSAMealQualitySimple),

            // Good
            @"Krustenbraten": @(DSAMealQualityGood),
            @"Geflügelragout": @(DSAMealQualityGood),
            @"Fischplatte": @(DSAMealQualityGood),

            // Fine
            @"Wildgulasch": @(DSAMealQualityFine),
            @"Hirschbraten": @(DSAMealQualityFine),
            @"Täubchen mit Pastete": @(DSAMealQualityFine),

            // Feast
            @"Fünf-Gänge-Menü": @(DSAMealQualityFeast),
            @"Festtafel": @(DSAMealQualityFeast),
            @"Bankett mit Wildschwein": @(DSAMealQualityFeast)
    };
    
    return nameToQuality[name];  // NSNumber mit DSAMealQuality oder nil
}

+ (uint32_t)hashFromSeed:(NSString *)seed {
    const char *str = seed.UTF8String;
    uint32_t hash = 5381;
    int c;
    while ((c = *str++)) {
        hash = ((hash << 5) + hash) + c;
    }
    return hash;
}

@end