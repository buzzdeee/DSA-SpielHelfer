/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-03-22 21:25:01 +0100 by sebastia

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

#import <Foundation/Foundation.h>
#import "DSALocations.h"

@implementation DSALocations

+ (instancetype)sharedInstance {
    static DSALocations *sharedInstance = nil;
    static NSObject *lock = nil;

    if (!lock) {
        lock = [[NSObject alloc] init];
    }

    @synchronized (lock) {
        if (!sharedInstance) {
            sharedInstance = [[self alloc] init];
            [sharedInstance loadLocationsFromJSON];
        }
    }

    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _locations = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)loadLocationsFromJSON {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Orte" ofType:@"json"];
    if (!path) {
        NSLog(@"Error: Orte.json not found!");
        return;
    }

    NSData *data = [NSData dataWithContentsOfFile:path];
    NSError *error = nil;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];

    if (error) {
        NSLog(@"Error parsing Orte.json: %@", error.localizedDescription);
        return;
    }

    @synchronized (self) {
        for (NSDictionary *dict in jsonArray) {
            DSALocation *location = [[DSALocation alloc] initWithDictionary:dict];
            [self.locations addObject:location];
        }
    }
}

- (void)addLocation:(DSALocation *)location {
    @synchronized (self) {
        if (![self.locations containsObject:location]) {
            [self.locations addObject:location];
        }
    }
}

- (void)removeLocationWithName:(NSString *)name {
    @synchronized (self) {
        DSALocation *locationToRemove = [self locationWithName:name];
        if (locationToRemove) {
            [self.locations removeObject:locationToRemove];
        }
    }
}

- (NSArray<NSString *> *)locationNames {
    NSMutableArray *names = [NSMutableArray array];
    for (DSALocation *location in self.locations) {
        [names addObject:location.name];
    }
    return [names copy];
}

- (DSALocation *)locationWithName:(NSString *)name {
    @synchronized (self) {
        for (DSALocation *location in self.locations) {
            if ([location.name isEqualToString:name]) {
                return location;
            }
        }
    }
    return nil; // Not found
}

- (NSArray<NSString *> *)locationNamesOfType:(NSString *)type {
    NSMutableArray *results = [NSMutableArray array];

    @synchronized (self) {
        for (DSALocation *location in self.locations) {
            if ([location.type isEqualToString:type]) {
                [results addObject:location.name];
            }
        }
    }

    return [results copy];
}

- (NSArray<NSString *> *)locationNamesOfTypes:(NSArray<NSString *> *)types {
    NSMutableArray *results = [NSMutableArray array];

    @synchronized (self) {
        for (DSALocation *location in self.locations) {
            if ([types containsObject:location.type]) {
                [results addObject:location.name];
            }
        }
    }

    return [results copy];
}

- (NSArray<NSString *> *)locationNamesOfTypes:(NSArray<NSString *> *)types matching:(NSString *)match {
    NSMutableArray *results = [NSMutableArray array];

    @synchronized (self) {
        for (DSALocation *location in self.locations) {
            if ([types containsObject:location.type] && [location.name containsString:match]) {
                [results addObject:location.name];
            }
        }
    }

    return [results copy];
}

@end
