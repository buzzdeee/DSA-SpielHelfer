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

@implementation DSARoutePlanner

- (instancetype)initWithBundleFiles {
    if (self = [super init]) {
        [self loadLocationsFromBundle];
        _roadGraph = [NSMutableDictionary dictionary];
        [self loadGeoJSONFromBundle];
    }
    return self;
}

// Load Orte.json (locations)
- (void)loadLocationsFromBundle {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Orte" ofType:@"json"];
    if (!path) {
        NSLog(@"Error: Orte.json not found in bundle.");
        return;
    }

    NSData *data = [NSData dataWithContentsOfFile:path];
    NSError *error;
    NSArray *locationsArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];

    if (error) {
        NSLog(@"Error parsing Orte.json: %@", error.localizedDescription);
        return;
    }

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (NSDictionary *loc in locationsArray) {
        NSString *name = loc[@"name"];
        NSPoint position = NSMakePoint([loc[@"x"] floatValue], [loc[@"y"] floatValue]);
        dict[name] = [NSValue valueWithPoint:position];
    }

    _locations = [dict copy];
    NSLog(@"Loaded %lu locations from Orte.json", (unsigned long)_locations.count);
}

// Load Strassen.geojson (roads)
- (void)loadGeoJSONFromBundle {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Strassen" ofType:@"geojson"];
    if (!path) {
        NSLog(@"Error: Strassen.geojson not found in bundle.");
        return;
    }

    NSData *data = [NSData dataWithContentsOfFile:path];
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];

    if (error) {
        NSLog(@"Error parsing Strassen.geojson: %@", error.localizedDescription);
        return;
    }

    NSArray *features = json[@"features"];
    for (NSDictionary *feature in features) {
        NSDictionary *properties = feature[@"properties"];
        NSArray *multiLineString = feature[@"geometry"][@"coordinates"];

        for (NSArray *lineString in multiLineString) {
            [self processRoadSegment:lineString roadType:properties[@"type"]];
        }
    }
    NSLog(@"Loaded %lu roads from Strassen.geojson", (unsigned long)_roadGraph.count);
}

// Convert road segment into graph representation
- (void)processRoadSegment:(NSArray *)lineString roadType:(NSString *)roadType {
    if (lineString.count < 2) return; // A road must have at least two points

    for (NSUInteger i = 0; i < lineString.count - 1; i++) {
        NSArray *pointA = lineString[i];
        NSArray *pointB = lineString[i + 1];

        NSPoint posA = NSMakePoint([pointA[0] floatValue], [pointA[1] floatValue]);
        NSPoint posB = NSMakePoint([pointB[0] floatValue], [pointB[1] floatValue]);

        CGFloat distance = hypot(posB.x - posA.x, posB.y - posA.y); // Euclidean distance

        // Add edges bidirectionally
        [self addEdgeFrom:posA to:posB withDistance:distance];
        [self addEdgeFrom:posB to:posA withDistance:distance];
    }
}

// Adds an edge to the adjacency list
- (void)addEdgeFrom:(NSPoint)start to:(NSPoint)end withDistance:(CGFloat)distance {
    NSValue *startValue = [NSValue valueWithPoint:start];
    NSValue *endValue = [NSValue valueWithPoint:end];

    if (!_roadGraph[startValue]) {
        _roadGraph[startValue] = [NSMutableArray array];
    }
    [_roadGraph[startValue] addObject:@{ @"point": endValue, @"distance": @(distance) }];
}

// Find the shortest path using Dijkstra’s Algorithm
- (NSArray<NSValue *> *)findShortestPathFrom:(NSString *)startName to:(NSString *)destinationName {
    NSValue *startValue = _locations[startName];
    NSValue *endValue = _locations[destinationName];

    if (!startValue || !endValue) {
        NSLog(@"Error: Invalid start or destination name.");
        return nil;
    }

    NSMutableDictionary<NSValue *, NSNumber *> *distances = [NSMutableDictionary dictionary];
    NSMutableDictionary<NSValue *, NSValue *> *previousNodes = [NSMutableDictionary dictionary];
    NSMutableArray<NSValue *> *priorityQueue = [NSMutableArray array];

    for (NSValue *key in _roadGraph) {
        distances[key] = @(INFINITY);
        [priorityQueue addObject:key];
    }

    distances[startValue] = @0;

    while (priorityQueue.count > 0) {
        [priorityQueue sortUsingComparator:^NSComparisonResult(NSValue *a, NSValue *b) {
            return [distances[a] compare:distances[b]];
        }];

        NSValue *current = priorityQueue.firstObject;
        [priorityQueue removeObjectAtIndex:0];

        if ([current isEqualTo:endValue]) break;

        for (NSDictionary *neighbor in _roadGraph[current]) {
            NSValue *neighborPoint = neighbor[@"point"];
            CGFloat edgeDistance = [neighbor[@"distance"] floatValue];

            CGFloat alternativeDistance = [distances[current] floatValue] + edgeDistance;
            if (alternativeDistance < [distances[neighborPoint] floatValue]) {
                distances[neighborPoint] = @(alternativeDistance);
                previousNodes[neighborPoint] = current;
            }
        }
    }

    NSMutableArray<NSValue *> *path = [NSMutableArray array];
    for (NSValue *step = endValue; step; step = previousNodes[step]) {
        [path insertObject:step atIndex:0];
    }

    return path.count > 1 ? path : nil;
}

@end