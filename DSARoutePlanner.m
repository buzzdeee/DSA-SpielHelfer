/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-03-19 22:19:06 +0100 by sebastia

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

#import "DSARoutePlanner.h"

@interface DSARoutePlanner ()

@property (nonatomic, strong) NSDictionary *routesData;
@property (nonatomic, strong) NSDictionary *locationsData;
@property (nonatomic, strong) NSMutableDictionary *graph;

@end

@implementation DSARoutePlanner

- (instancetype)initWithBundleFiles {
    self = [super init];
    if (self) {
        NSString *routesPath = [[NSBundle mainBundle] pathForResource:@"routes" ofType:@"geojson"];
        NSString *locationsPath = [[NSBundle mainBundle] pathForResource:@"Orte" ofType:@"json"];
        
        [self loadRoutesData:routesPath];
        [self loadLocationsData:locationsPath];
        [self buildGraph];
    }
    return self;
}

#pragma mark - Data Loading

- (void)loadRoutesData:(NSString *)filePath {
    NSLog(@"Loading routes data from: %@", filePath);
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    if (!data) {
        NSLog(@"❌ ERROR: Could not load routes data.");
        return;
    }
    self.routesData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSLog(@"✅ Routes data loaded successfully.");
}

- (void)loadLocationsData:(NSString *)filePath {
    NSLog(@"Loading locations data from: %@", filePath);
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    if (!data) {
        NSLog(@"❌ ERROR: Could not load locations data.");
        return;
    }
    self.locationsData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSLog(@"✅ Locations data loaded successfully.");
}

#pragma mark - Graph Construction

- (void)buildGraph {
    NSLog(@"🔧 Building road network graph...");
    self.graph = [NSMutableDictionary dictionary];

    NSUInteger roadCount = 0;
    for (NSDictionary *feature in self.routesData[@"features"]) {
        if (![feature[@"geometry"][@"type"] isEqualToString:@"LineString"]) {
            continue;
        }

        NSArray *coordinates = feature[@"geometry"][@"coordinates"];
        roadCount++;

        for (NSUInteger i = 0; i < coordinates.count - 1; i++) {
            NSArray *start = coordinates[i];
            NSArray *end = coordinates[i + 1];

            NSString *startKey = [NSString stringWithFormat:@"%@,%@", start[0], start[1]];
            NSString *endKey = [NSString stringWithFormat:@"%@,%@", end[0], end[1]];

            CGFloat distance = [self distanceBetweenPoint:start andPoint:end];

            if (!self.graph[startKey]) {
                self.graph[startKey] = [NSMutableDictionary dictionary];
            }
            if (!self.graph[endKey]) {
                self.graph[endKey] = [NSMutableDictionary dictionary];
            }

            self.graph[startKey][endKey] = @(distance);
            self.graph[endKey][startKey] = @(distance);
        }
    }
    NSLog(@"✅ Graph built successfully. Total roads processed: %lu, Total nodes: %lu", (unsigned long)roadCount, (unsigned long)self.graph.count);
}

#pragma mark - Pathfinding

- (NSArray<NSValue *> *)findShortestPathFrom:(NSString *)startName to:(NSString *)destinationName {
    NSLog(@"🚀 Starting pathfinding from '%@' to '%@'...", startName, destinationName);
    NSLog(@"🔍 Debug: self.locationsData: %@", self.locationsData);    

    NSDictionary *startLocation = [self locationForName:startName];
    NSDictionary *endLocation = [self locationForName:destinationName];

    if (!startLocation) {
        NSLog(@"❌ ERROR: Location '%@' not found in Orte.json", startName);
        return @[];
    }
    if (!endLocation) {
        NSLog(@"❌ ERROR: Location '%@' not found in Orte.json", destinationName);
        return @[];
    }

    NSLog(@"📍 Mapped locations: '%@' -> %@, '%@' -> %@", startName, startLocation, destinationName, endLocation);

    NSString *startKey = [self nearestRoadPointForLocation:@[@([startLocation[@"x"] floatValue]), @([startLocation[@"y"] floatValue])]];
    NSString *endKey = [self nearestRoadPointForLocation:@[@([endLocation[@"x"] floatValue]), @([endLocation[@"y"] floatValue])]];

    if (!startKey || !endKey) {
        NSLog(@"❌ ERROR: No nearby roads found for '%@' or '%@'.", startName, destinationName);
        return @[];
    }

    NSLog(@"🛣️ Nearest road points: Start: %@ -> %@, Destination: %@ -> %@", startName, startKey, destinationName, endKey);

    return [self dijkstraFrom:startKey to:endKey];
}

- (NSArray<NSValue *> *)findShortestPathFromXXX:(NSString *)startName to:(NSString *)destinationName {
    NSLog(@"🚀 Starting pathfinding from '%@' to '%@'...", startName, destinationName);

NSLog(@"self.locationsData: %@", self.locationsData);    
    
    NSArray *startLocation = self.locationsData[startName];
    NSArray *endLocation = self.locationsData[destinationName];

    NSLog(@"startLocation: %@, endLocation: %@", startLocation, endLocation);
    
    if (!startLocation) {
        NSLog(@"❌ ERROR: Location '%@' not found in Orte.json", startName);
        return @[];
    }
    if (!endLocation) {
        NSLog(@"❌ ERROR: Location '%@' not found in Orte.json", destinationName);
        return @[];
    }

    NSLog(@"📍 Mapped locations: '%@' -> %@, '%@' -> %@", startName, startLocation, destinationName, endLocation);

    NSString *startKey = [self nearestRoadPointForLocation:startLocation];
    NSString *endKey = [self nearestRoadPointForLocation:endLocation];

    if (!startKey || !endKey) {
        NSLog(@"❌ ERROR: No nearby roads found for '%@' or '%@'.", startName, destinationName);
        return @[];
    }

    NSLog(@"🛣️ Nearest road points: Start: %@ -> %@, Destination: %@ -> %@", startName, startKey, destinationName, endKey);

    return [self dijkstraFrom:startKey to:endKey];
}

- (NSString *)nearestRoadPointForLocation:(NSArray *)location {
    NSLog(@"🔍 Finding nearest road point for location: %@", location);
    CGFloat minDistance = CGFLOAT_MAX;
    NSString *nearestPointKey = nil;

    for (NSString *key in self.graph) {
        NSArray *coords = [key componentsSeparatedByString:@","];
        if (coords.count < 2) continue;

        NSArray *roadPoint = @[@([coords[0] floatValue]), @([coords[1] floatValue])];
        CGFloat distance = [self distanceBetweenPoint:location andPoint:roadPoint];

        if (distance < minDistance) {
            minDistance = distance;
            nearestPointKey = key;
        }
    }

    NSLog(@"✅ Nearest road point found: %@", nearestPointKey);
    return nearestPointKey;
}

- (NSArray<NSValue *> *)dijkstraFrom:(NSString *)startKey to:(NSString *)endKey {
    NSLog(@"🔄 Running Dijkstra's algorithm from %@ to %@...", startKey, endKey);

    NSMutableDictionary *distances = [NSMutableDictionary dictionary];
    NSMutableDictionary *previous = [NSMutableDictionary dictionary];
    NSMutableArray *queue = [NSMutableArray array];

    for (NSString *key in self.graph) {
        distances[key] = @(INFINITY);
        previous[key] = [NSNull null];
        [queue addObject:key];
    }
    distances[startKey] = @(0);

    while (queue.count > 0) {
        NSString *currentKey = [queue firstObject];
        for (NSString *node in queue) {
            if ([distances[node] floatValue] < [distances[currentKey] floatValue]) {
                currentKey = node;
            }
        }

        NSLog(@"📍 Processing node: %@ (distance: %@)", currentKey, distances[currentKey]);
        [queue removeObject:currentKey];

        if ([currentKey isEqualToString:endKey]) {
            NSLog(@"🏁 Destination reached: %@", endKey);
            break;
        }

        NSDictionary *neighbors = self.graph[currentKey];
        if (!neighbors) {
            NSLog(@"⚠️ No neighbors found for node %@", currentKey);
            continue;
        }

        for (NSString *neighbor in neighbors) {
            float alt = [distances[currentKey] floatValue] + [neighbors[neighbor] floatValue];

            if (alt < [distances[neighbor] floatValue]) {
                distances[neighbor] = @(alt);
                previous[neighbor] = currentKey;
                NSLog(@"🔄 Updated distance: %@ -> %@, new cost: %f", currentKey, neighbor, alt);
            }
        }
    }

    NSMutableArray<NSValue *> *path = [NSMutableArray array];
    NSString *step = endKey;

    NSLog(@"🔄 Starting path reconstruction from %@", endKey);
    while (step && ![step isEqual:[NSNull null]]) {
        NSArray *coords = [step componentsSeparatedByString:@","];
        if (coords.count < 2) {
            NSLog(@"❌ ERROR: Invalid coordinate format: %@", step);
            break;
        }

        NSPoint point = NSMakePoint([coords[0] floatValue], [coords[1] floatValue]);
        [path insertObject:[NSValue valueWithPoint:point] atIndex:0];
        NSLog(@"🛤️ Path step: %@ at %@", step, NSStringFromPoint(point));

        step = previous[step];
    }

    NSLog(@"✅ Pathfinding complete. Total steps: %lu", (unsigned long)path.count);
    return path;
}

#pragma mark - Utility Methods

// Helper function to find location by name
- (NSDictionary *)locationForName:(NSString *)locationName {
    for (NSDictionary *location in self.locationsData) {
        if ([location[@"name"] isEqualToString:locationName]) {
            return location;
        }
    }
    return nil; // Return nil if not found
}

- (CGFloat)distanceBetweenPoint:(NSArray *)p1 andPoint:(NSArray *)p2 {
    if (p1.count < 2 || p2.count < 2) {
        NSLog(@"❌ ERROR: Invalid coordinate format in distance calculation.");
        return CGFLOAT_MAX;
    }

    CGFloat dx = [p1[0] floatValue] - [p2[0] floatValue];
    CGFloat dy = [p1[1] floatValue] - [p2[1] floatValue];
    return sqrt(dx * dx + dy * dy);
}

@end