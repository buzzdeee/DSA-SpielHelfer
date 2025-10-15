/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-03-16 20:59:12 +0100 by sebastia

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

#import "DSAMapOverlayView.h"

@implementation DSAMapOverlayView

- (instancetype)initWithFrame:(NSRect)frame features:(NSArray *)features {
    if (self = [super initWithFrame:frame]) {
        _features = features;
        //NSLog(@"DSAMapOverlayView initialized correctly with %lu features!", (unsigned long)features.count);
        //NSLog(@"DSAMapOverlayView setting zoom factor to 0.5");
        _zoomFactor = 0.5; // to be the same as in DSAMapViewController
        self.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    // This base class does nothing - subclasses will implement their own drawing.
}

@end


@implementation DSARegionsOverlayView

- (instancetype)initWithFrame:(NSRect)frame features:(NSArray *)features {
    //NSLog(@"DSARegionsOverlayView initWithFrame:features called - Frame: %@", NSStringFromRect(frame));

    self = [super initWithFrame:frame features: features]; // Call the original initializer
    if (self) {
        _regionColors = [NSMutableDictionary dictionary]; // Initialize the dictionary
        //NSLog(@"DSARegionsOverlayView initialized correctly with %lu features!", (unsigned long)features.count);
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    //NSLog(@"DSARegionsOverlayView drawRect called with zoom factor: %f", self.zoomFactor);
    
    for (NSDictionary *feature in self.features) {
        NSDictionary *properties = feature[@"properties"];
        NSArray *coordinatesArray = feature[@"geometry"][@"coordinates"];

        if (![coordinatesArray isKindOfClass:[NSArray class]]) {
            NSLog(@"Invalid coordinate format for MultiPolygon.");
            continue;
        }

        NSBezierPath *path = [NSBezierPath bezierPath];

        for (NSArray *polygon in coordinatesArray) {
            for (NSArray *ring in polygon) {
                BOOL isFirstPoint = YES;

                for (int i = 0; i < ring.count; i++) {
                    id point = ring[i]; 
                    if (![point isKindOfClass:[NSArray class]] || [point count] < 2) {
                        continue;
                    }

                    CGFloat x = [point[0] floatValue] * self.zoomFactor; // Scale X
                    CGFloat y = [point[1] floatValue] * self.zoomFactor; // Scale Y

                    if (isFirstPoint) {
                        [path moveToPoint:NSMakePoint(x, y)];
                        isFirstPoint = NO;
                    } else {
                        [path lineToPoint:NSMakePoint(x, y)];
                    }
                }
                [path closePath];
            }
        }

        NSString *regionID = properties[@"region"];
        NSColor *regionColor = self.regionColors[regionID];
        if (!regionColor) {
            CGFloat randomRed = (arc4random() % 256) / 255.0;
            CGFloat randomGreen = (arc4random() % 256) / 255.0;
            CGFloat randomBlue = (arc4random() % 256) / 255.0;
            regionColor = [NSColor colorWithRed:randomRed green:randomGreen blue:randomBlue alpha:0.5];
            self.regionColors[regionID] = regionColor;
        }        

        [[NSColor blackColor] setStroke]; 
        [regionColor setFill];

        [path stroke];
        [path fill];

        //NSLog(@"Going to print region name");
        NSPoint centroid = [self calculateMultiPolygonCentroid:coordinatesArray];
        //NSLog(@"centroid: %@", NSStringFromPoint(centroid));

        NSString *regionName = properties[@"region"];
        if (regionName) {
            NSDictionary *attributes = @{NSFontAttributeName: [NSFont systemFontOfSize:25],
                                         NSForegroundColorAttributeName: [NSColor blackColor]};
            [regionName drawAtPoint:centroid withAttributes:attributes];
        }               
    }
}

// Helper method to calculate the centroid of a polygon
- (NSPoint)calculateMultiPolygonCentroid:(NSArray *)multiPolygon {
    CGFloat totalX = 0, totalY = 0;
    NSUInteger totalPoints = 0;

    for (NSArray *polygon in multiPolygon) {
        for (NSArray *ring in polygon) {
            for (NSArray *point in ring) {
                if (![point isKindOfClass:[NSArray class]] || point.count < 2) continue;

                totalX += [point[0] floatValue] * self.zoomFactor;
                totalY += [point[1] floatValue] * self.zoomFactor;
                totalPoints++;
            }
        }
    }

    if (totalPoints == 0) return NSMakePoint(0, 0);
    
    return NSMakePoint(totalX / totalPoints, totalY / totalPoints);
}

@end

@implementation DSAStreetsOverlayView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    //NSLog(@"DSAStreetsOverlayView drawRect called!!!!");
    for (NSDictionary *feature in self.features) {
        NSDictionary *properties = feature[@"properties"];
        NSString *streetType = properties[@"type"];
        NSArray *coordinatesArray = feature[@"geometry"][@"coordinates"];
        if (![coordinatesArray isKindOfClass:[NSArray class]]) {
            NSLog(@"Invalid coordinate format for MultiLineString.");
            continue;
        }

        NSBezierPath *path = [NSBezierPath bezierPath];

        for (NSArray *lineString in coordinatesArray) { // Iterate through each line in the MultiLineString
            BOOL isFirstPoint = YES;

            for (NSArray *point in lineString) {
                if (![point isKindOfClass:[NSArray class]] || point.count < 2) {
                    continue;
                }

                CGFloat x = [point[0] floatValue] * self.zoomFactor;
                CGFloat y = [point[1] floatValue] * self.zoomFactor;

                if (isFirstPoint) {
                    [path moveToPoint:NSMakePoint(x, y)];
                    isFirstPoint = NO;
                } else {
                    [path lineToPoint:NSMakePoint(x, y)];
                }
            }
        }

        // 🟢 Determine line width based on street type
        CGFloat lineWidth = [self lineWidthForStreetType:streetType];

        // 🟢 Set the stroke color and width
        //[[NSColor colorWithCalibratedWhite:0.1 alpha:0.8] setStroke]; // Dark grey
        [[NSColor redColor] setStroke];
        [path setLineWidth:lineWidth];
        [path stroke];
    }
}

// ✅ Helper function to get stroke width for street types
- (CGFloat)lineWidthForStreetType:(NSString *)streetType {
    if ([streetType isEqualToString:@"WEG"]) return 1.0;  // Small path
    if ([streetType isEqualToString:@"LS"]) return 2.0;   // Normal street
    if ([streetType isEqualToString:@"RS"]) return 3.0;   // Major road
    return 2.0; // Default width
}
@end

@implementation DSARouteOverlayView

- (void)updateRouteWithPoints:(NSArray<NSValue *> *)points {
    self.routePoints = points;
    [self setNeedsDisplay:YES]; // Trigger re-draw
}

- (void)fadeOut {
    self.hidden = YES;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    if (self.routePoints.count < 2) return;

    [[NSColor redColor] setStroke];

    NSBezierPath *path = [NSBezierPath bezierPath];
    path.lineWidth = 4.0; // Make the route stand out

    for (NSUInteger i = 0; i < self.routePoints.count; i++) {
        NSPoint point = [self.routePoints[i] pointValue];

        // Scale by zoom factor
        CGFloat x = point.x * self.zoomFactor;
        CGFloat y = point.y * self.zoomFactor;

        if (i == 0) {
            [path moveToPoint:NSMakePoint(x, y)];
        } else {
            [path lineToPoint:NSMakePoint(x, y)];
        }
    }

    [path stroke];
}

@end
