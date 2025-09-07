/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-03-06 22:11:17 +0100 by sebastia

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

#ifndef _DSAWEATHER_H_
#define _DSAWEATHER_H_

#import "DSABaseObject.h"

@interface DSAWeather : DSABaseObject <NSCoding>

typedef NS_ENUM(NSInteger, DSAFog) {
    DSAFogNone,
    DSAFogLight,
    DSAFogDense
};

typedef NS_ENUM(NSInteger, DSAWind) {
    DSAWindNone,
    DSAWindCalm,
    DSAWindLight,
    DSAWindModerate,
    DSAWindStrong
};

typedef NS_ENUM(NSInteger, DSACloudCoverage) {
    DSACloudClear,
    DSACloudPartlyCloudy,
    DSACloudOvercast
};

typedef NS_ENUM(NSInteger, DSATemperature) {
    DSATempFreezing,
    DSATempCold,
    DSATempCool,
    DSATempWarm,
    DSATempHot
};

typedef NS_ENUM(NSInteger, DSAPrecipitation) {
    DSAPrecipNone,
    DSAPrecipCalm,
    DSAPrecipLight,
    DSAPrecipModerate,
    DSAPrecipHeavy
};

@property (nonatomic) DSATemperature temperature;
@property (nonatomic) DSAWind windSpeed;
@property (nonatomic) DSACloudCoverage cloudCoverage;
@property (nonatomic) DSAFog fogDensity;
@property (nonatomic) DSAPrecipitation precipitation;

- (instancetype)init;
- (instancetype)initWithTemperature:(DSATemperature)temp windSpeed:(DSAWind)wind cloudCoverage:(DSACloudCoverage)clouds fogDensity:(DSAFog)fog precipitation:(DSAPrecipitation)precipitation;
- (NSString *)weatherDescription;
- (NSString *)describeTemperature;
- (NSString *)describeWind;
- (NSString *)describeCloudCoverage;
- (NSString *)describeFog;
- (NSString *)describePrecipitation;

@end

#endif // _DSAWEATHER_H_

