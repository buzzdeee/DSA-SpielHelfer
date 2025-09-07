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

#import "DSAWeather.h"

@implementation DSAWeather

- (instancetype)init {
    return [self initWithTemperature: DSATempWarm 
                           windSpeed:DSAWindCalm 
                       cloudCoverage:DSACloudOvercast
                          fogDensity:DSAFogNone 
                       precipitation:DSAPrecipModerate];
}

- (instancetype)initWithTemperature:(DSATemperature)temp windSpeed:(DSAWind)wind cloudCoverage:(DSACloudCoverage)clouds fogDensity:(DSAFog)fog precipitation:(DSAPrecipitation)precipitation {
    self = [super init];
    if (self) {
        _temperature = temp;
        _windSpeed = wind;
        _cloudCoverage = clouds;
        _fogDensity = fog;
        _precipitation = precipitation;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInteger:_temperature forKey:@"temperature"];
    [coder encodeInteger:_windSpeed forKey:@"windSpeed"];
    [coder encodeInteger:_cloudCoverage forKey:@"cloudCoverage"];
    [coder encodeInteger:_fogDensity forKey:@"fogDensity"];
    
    
    [coder encodeInteger:_precipitation forKey:@"precipitation"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _temperature = [coder decodeIntegerForKey:@"temperature"];
        _windSpeed = [coder decodeIntegerForKey:@"windSpeed"];
        _cloudCoverage = [coder decodeIntegerForKey:@"cloudCoverage"];
        _fogDensity = [coder decodeIntegerForKey:@"fogDensity"];
        _precipitation = [coder decodeIntegerForKey:@"precipitation"];
    }
    return self;
}

- (NSString *)describeTemperature {
    switch (_temperature) {
        case DSATempFreezing: return @"Eiskalt";
        case DSATempCold: return @"Kalt";
        case DSATempCool: return @"Kühl";
        case DSATempWarm: return @"Warm";
        case DSATempHot: return @"Heiß";
    }
}

- (NSString *)describeWind {
    switch (_windSpeed) {
        case DSAWindNone: return @"Kein Wind";
        case DSAWindCalm: return @"Leichter Wind";
        case DSAWindLight: return @"Leichte Brise";
        case DSAWindModerate: return @"Mäßiger Wind";
        case DSAWindStrong: return @"Starker Wind";
    }
}

- (NSString *)describeCloudCoverage {
    switch (_cloudCoverage) {
        case DSACloudClear: return @"Klarer Himmel";
        case DSACloudPartlyCloudy: return @"Teilweise bewölkt";
        case DSACloudOvercast: return @"Bedeckter Himmel";
    }
}

- (NSString *)describeFog {
    switch (_fogDensity) {
        case DSAFogNone: return @"Kein Nebel";
        case DSAFogLight: return @"Leichter Nebel";
        case DSAFogDense: return @"Dichter Nebel";
    }
}

- (NSString *)describePrecipitation {
    NSString *precipitationType = (_temperature == DSATempFreezing) ? @"Schnee" : @"Regen";
    switch (_precipitation) {
        case DSAPrecipNone: return @"Kein Niederschlag";
        case DSAPrecipCalm: return [NSString stringWithFormat:@"Leichter %@", precipitationType];
        case DSAPrecipLight: return [NSString stringWithFormat:@"Mäßiger %@", precipitationType];
        case DSAPrecipModerate: return [NSString stringWithFormat:@"Starker %@", precipitationType];
        case DSAPrecipHeavy: return [NSString stringWithFormat:@"Heftiger %@", precipitationType];
    }
}

- (NSString *)weatherDescription {
    return [NSString stringWithFormat:@"%@. %@. %@. %@. %@.",
            [self describeTemperature],
            [self describeWind],
            [self describeCloudCoverage],
            [self describeFog],
            [self describePrecipitation]];
}

@end