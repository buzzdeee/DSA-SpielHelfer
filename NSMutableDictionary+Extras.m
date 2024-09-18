/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-09-13 22:32:44 +0200 by sebastia

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

#import "NSMutableDictionary+Extras.h"

@implementation NSMutableDictionary (Extras)

- (void)setValue:(id)value forKeyHierarchy:(NSArray *) keys {
    NSUInteger lastKeyIndex = [keys count] - 1;
    NSMutableDictionary *currentDict = self;
    
    for (NSUInteger i = 0; i < lastKeyIndex; i++) {
        NSString *key = keys[i];
        NSMutableDictionary *nextDict = currentDict[key];
        
        // If the next dictionary doesn't exist, create it
        if (!nextDict || ![nextDict isKindOfClass:[NSMutableDictionary class]]) {
            nextDict = [NSMutableDictionary dictionary];
            currentDict[key] = nextDict;
        }
        
        currentDict = nextDict;
    }
    
    // Set the value for the final key KVO compliant    
    NSString *finalKey = keys[lastKeyIndex];
    [currentDict willChangeValueForKey:finalKey];
    currentDict[finalKey] = value;
    [currentDict willChangeValueForKey:finalKey];
}


- (void)setValue:(id)value forKeyPath:(NSString *)keyPath {
    NSLog(@"setValue:forKeyPath: SELF: %@", self);
    NSArray *keys = [keyPath componentsSeparatedByString:@"."];
    NSUInteger lastKeyIndex = [keys count] - 1;
    NSMutableDictionary *currentDict = self;
    
    
    NSLog(@"setValue:forKeyPath: keys: %@, lastKeyIndex: %lu", keys, lastKeyIndex);
    NSLog(@"setValue:forKeyPath: currentDict: %@", currentDict);
    for (NSUInteger i = 0; i < lastKeyIndex; i++) {
        NSString *key = keys[i];
        NSMutableDictionary *nextDict = [currentDict valueForKey:key];
        NSLog(@"setValue: forKeyPath: key %@", key);
        // If the next dictionary doesn't exist, create it
        if (!nextDict || ![nextDict isKindOfClass:[NSMutableDictionary class]]) {
            NSLog(@"creating nextDict!");
            nextDict = [NSMutableDictionary dictionary];
            [currentDict setValue:nextDict forKey:key]; // Use setValue:forKey: to ensure KVO compliance
        }
        
        currentDict = nextDict;
    }
    
    NSString *finalKey = keys[lastKeyIndex];
    
    // Trigger KVO notifications
    [currentDict willChangeValueForKey:finalKey];
    [currentDict setValue:value forKey:finalKey];
    [currentDict didChangeValueForKey:finalKey];
}

@end
