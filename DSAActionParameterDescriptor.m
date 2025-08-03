/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-07-22 21:17:13 +0200 by sebastia

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

#import "DSAActionParameterDescriptor.h"

@implementation DSAActionParameterDescriptor

#pragma mark - Convenience Initializer

+ (instancetype)descriptorWithKey:(NSString *)key
                            label:(NSString *)label
                         helpText:(NSString *)helpText
                             type:(DSAActionParameterType)type
{
    DSAActionParameterDescriptor *desc = [[self alloc] init];
    desc.key = key;
    desc.label = label;
    desc.helpText = helpText;
    desc.type = type;
    desc.minValue = 0;
    desc.maxValue = 100;
    return desc;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.key forKey:@"key"];
    [coder encodeObject:self.label forKey:@"label"];
    [coder encodeObject:self.helpText forKey:@"helpText"];
    [coder encodeInteger:self.type forKey:@"type"];
    [coder encodeObject:self.choices forKey:@"choices"];
    [coder encodeInteger:self.minValue forKey:@"minValue"];
    [coder encodeInteger:self.maxValue forKey:@"maxValue"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _key = [coder decodeObjectOfClass:[NSString class] forKey:@"key"];
        _label = [coder decodeObjectOfClass:[NSString class] forKey:@"label"];
        _helpText = [coder decodeObjectOfClass:[NSString class] forKey:@"helpText"];
        _type = [coder decodeIntegerForKey:@"type"];
        _choices = [coder decodeObjectOfClass:[NSArray class] forKey:@"choices"];
        _minValue = [coder decodeIntegerForKey:@"minValue"];
        _maxValue = [coder decodeIntegerForKey:@"maxValue"];
    }
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    DSAActionParameterDescriptor *copy = [[[self class] allocWithZone:zone] init];
    copy.key = [self.key copy];
    copy.label = [self.label copy];
    copy.type = self.type;
    copy.choices = [self.choices copy];
    copy.minValue = self.minValue;
    copy.maxValue = self.maxValue;
    return copy;
}

- (NSString *)description {
    NSMutableString *desc = [NSMutableString stringWithFormat:
        @"<%@: %p>\n"
        @"  key: %@\n"
        @"  label: %@\n"
        @"  helpText: %@\n"
        @"  type: %ld\n",
        NSStringFromClass([self class]), self,
        self.key,
        self.label,
        self.helpText ?: @"(null)",
        (long)self.type
    ];

    // If choices are set
    if (self.choices) {
        [desc appendFormat:@"  choices: %@\n", [[self.choices allKeys] componentsJoinedByString:@", "]];
    }

    // Always include min/max (they are scalar, default to 0 if not set explicitly)
    [desc appendFormat:@"  minValue: %ld\n", (long)self.minValue];
    [desc appendFormat:@"  maxValue: %@\n", self.maxValue == NSIntegerMax ? @"context-dependent" : [@(self.maxValue) stringValue]];

    return [desc copy];
}

@end