/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-11-08 22:02:41 +0100 by sebastia

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

#import "DSARegion.h"

@implementation DSARegion

- (instancetype)initWithFeature:(NSDictionary *)feature {
    self = [super init];
    if (self) {
        NSDictionary *props = feature[@"properties"];
        self.regionID = [NSString stringWithFormat:@"%@", props[@"id"]];
        self.name = props[@"region"];
        NSDictionary *geometry = feature[@"geometry"];
        self.polygons = geometry[@"coordinates"]; // direkt übernehmen
    }
    return self;
}

// Ray-Casting-Algorithmus für Punkt-in-Polygon-Test
- (BOOL)containsPointX:(double)x Y:(double)y {
    for (NSArray *multiPolygon in self.polygons) {
        for (NSArray *polygon in multiPolygon) {
            BOOL inside = NO;
            NSInteger j = polygon.count - 1;
            for (NSInteger i = 0; i < polygon.count; i++) {
                double xi = [polygon[i][0] doubleValue];
                double yi = [polygon[i][1] doubleValue];
                double xj = [polygon[j][0] doubleValue];
                double yj = [polygon[j][1] doubleValue];
                BOOL intersect = ((yi > y) != (yj > y)) &&
                                 (x < (xj - xi) * (y - yi) / (yj - yi + 1e-10) + xi);
                if (intersect) inside = !inside;
                j = i;
            }
            if (inside) return YES;
        }
    }
    return NO;
}

@end

@implementation DSARegionManager

static DSARegionManager *sharedManager = nil;

+ (instancetype)sharedManager
{
    if (sharedManager == nil) {
        sharedManager = [[self alloc] init];
    }
    return sharedManager;
}

- (id)init
{
    if (sharedManager != nil) {
        return sharedManager;
    }

    self = [super init];
    if (self) {
        // Hier kann Initialisierungscode hin
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Regionen" ofType:@"geojson"];
        if (path) {
            [self loadRegionsFromGeoJSON:path];
        } else {
            NSLog(@"DSARegionManager init: Regionen.geojson not found, aborting");
            abort();
        }
    }
    return self;
}

- (void)loadRegionsFromGeoJSON:(NSString *)path {
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (!data) return;
    
    NSDictionary *geojson = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSMutableArray *temp = [NSMutableArray array];
    for (NSDictionary *feature in geojson[@"features"]) {
        DSARegion *region = [[DSARegion alloc] initWithFeature:feature];
        [temp addObject:region];
    }
    self.regions = temp;
}

- (DSARegion *)regionForX:(double)x Y:(double)y {
    for (DSARegion *region in self.regions) {
        if ([region containsPointX:x Y:y]) {
            return region;
        }
    }
    return nil;
}

- (DSARegion *)regionWithName:(NSString *)regionName
{
    if (!regionName || regionName.length == 0)
        return nil;
    
    for (DSARegion *region in self.regions) {
        if ([region.name caseInsensitiveCompare:regionName] == NSOrderedSame) {
            return region;
        }
    }
    return nil;
}

- (NSArray<DSARegion *> *)allRegions
{
    return self.regions;
}

- (NSArray<NSDictionary *> *)allFeatures
{



    NSMutableArray *features = [NSMutableArray array];
    for (DSARegion *region in self.regions) {
        NSMutableDictionary *feature = [NSMutableDictionary dictionary];
        feature[@"type"] = @"Feature";
        feature[@"properties"] = @{@"id": region.regionID, @"region": region.name};
        feature[@"geometry"] = @{@"type": @"MultiPolygon", @"coordinates": region.polygons};
        [features addObject:feature];
    }
    return [features copy];
}

@end