/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-02-21 20:57:22 +0100 by sebastia

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

#import "DSACharacterStatusView.h"
#import "Utils.h"

@implementation DSACharacterStatusView {
    NSArray *_colors;
    NSArray *_stateKeys;
    NSInteger _hoveredCircleIndex;
    CGFloat _dotSize;
    CGFloat _minSpacing;
    CGFloat _startX;
    CGFloat _startY;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        _hoveredCircleIndex = -1;
        [self addTrackingRect:self.bounds owner:self userData:NULL assumeInside:NO];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    //[self registerForDraggedTypes:@[]]; // Register for tooltips here! This makes that all elements are empty...
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    if (!self.character) {
        return;
    }

    _stateKeys = @[
        @(DSACharacterStateWounded),
        @(DSACharacterStateSick),
        @(DSACharacterStateDrunken),
        @(DSACharacterStatePoisoned),
        @(DSACharacterStateDead),
        @(DSACharacterStateUnconscious),
        @(DSACharacterStateSpellbound)
    ];

    NSMutableArray *colorsMutable = [NSMutableArray array];
    for (NSNumber *stateKey in _stateKeys) {
        id stateValue = [self.character.statesDict objectForKey:stateKey];
        NSColor *color;
        if ([stateKey isEqualToNumber:@(DSACharacterStatePoisoned)] ||
            [stateKey isEqualToNumber:@(DSACharacterStateDead)] ||
            [stateKey isEqualToNumber:@(DSACharacterStateUnconscious)] ||
            [stateKey isEqualToNumber:@(DSACharacterStateSpellbound)]) {
            color = [Utils colorForBooleanState:[stateValue boolValue]];
        } else {
            color = [Utils colorForDSASeverity:[stateValue integerValue]];
        }
        [colorsMutable addObject:color];
    }
    _colors = [colorsMutable copy];

    NSUInteger dotCount = _colors.count;
    _minSpacing = 5.0;

    CGFloat availableWidth = dirtyRect.size.width - (_minSpacing * (dotCount - 1));
    _dotSize = MIN(availableWidth / dotCount, dirtyRect.size.height - 10.0);

    CGFloat totalContentWidth = (_dotSize * dotCount) + (_minSpacing * (dotCount - 1));
    _startX = (dirtyRect.size.width - totalContentWidth) / 2;
    _startY = (dirtyRect.size.height - _dotSize) / 2;

    CGFloat x = _startX;
    CGFloat y = _startY;

    for (NSColor *color in _colors) {
        NSBezierPath *circle = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(x, y, _dotSize, _dotSize)];
        [color setFill];
        [circle fill];
        x += _dotSize + _minSpacing;
    }
    // [self registerForDraggedTypes:@[]]; // Register for tooltips here! This makes the UI stuck
}

- (void)setCharacter:(DSACharacter *)character {
    _character = character;
    [self setNeedsDisplay:YES];
    [self displayIfNeeded];
}

- (void)mouseMoved:(NSEvent *)event {
    NSPoint mouseLocation = [self convertPoint:[event locationInWindow] fromView:nil];
    NSInteger hoveredIndex = -1;
    CGFloat x = _startX;

    for (NSInteger i = 0; i < _colors.count; i++) {
        NSRect circleRect = NSMakeRect(x, _startY, _dotSize, _dotSize);
        if (NSPointInRect(mouseLocation, circleRect)) {
            hoveredIndex = i;
            break;
        }
        x += _dotSize + _minSpacing;
    }

    if (hoveredIndex != _hoveredCircleIndex) {
        _hoveredCircleIndex = hoveredIndex;
        [self setToolTip:[self tooltipForIndex:hoveredIndex]];
    }
}

- (NSString *)tooltipForIndex:(NSInteger)index {
    if (index == -1) {
        return nil;
    }

    NSNumber *stateKey = _stateKeys[index];
    NSString *stateName;

    switch ([stateKey integerValue]) {
        case DSACharacterStateWounded:
            stateName = @"Wounded";
            break;
        case DSACharacterStateSick:
            stateName = @"Sick";
            break;
        case DSACharacterStateDrunken:
            stateName = @"Drunken";
            break;
        case DSACharacterStatePoisoned:
            stateName = @"Poisoned";
            break;
        case DSACharacterStateDead:
            stateName = @"Dead";
            break;
        case DSACharacterStateUnconscious:
            stateName = @"Unconscious";
            break;
        case DSACharacterStateSpellbound:
            stateName = @"Spellbound";
            break;
        default:
            stateName = @"Unknown";
            break;
    }

    return stateName;
}

- (void)mouseExited:(NSEvent *)event {
    _hoveredCircleIndex = -1;
    [self setToolTip:nil];
}

@end


/*
@implementation DSACharacterStatusView


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    NSLog(@"DSACharacterStatusView drawRect %@", [self.character.statesDict objectForKey:@(DSACharacterStateDead)]);

    if (!self.character) {
        return; // Avoid drawing if character is not set
    }    
        
    NSArray *colors = @[
        [Utils colorForDSASeverity:[[self.character.statesDict objectForKey:@(DSACharacterStateWounded)] integerValue]],
        [Utils colorForDSASeverity:[[self.character.statesDict objectForKey:@(DSACharacterStateSick)] integerValue]],
        [Utils colorForDSASeverity:[[self.character.statesDict objectForKey:@(DSACharacterStateDrunken)] integerValue]],
        [Utils colorForBooleanState:[[self.character.statesDict objectForKey:@(DSACharacterStatePoisoned)] boolValue]],
        [Utils colorForBooleanState:[[self.character.statesDict objectForKey:@(DSACharacterStateDead)] boolValue]],
        [Utils colorForBooleanState:[[self.character.statesDict objectForKey:@(DSACharacterStateUnconscious)] boolValue]],
        [Utils colorForBooleanState:[[self.character.statesDict objectForKey:@(DSACharacterStateSpellbound)] boolValue]]
    ];

    for (NSInteger i = 0; i < colors.count; i++) {
        NSLog(@"Dot %ld Color: %@", (long)i, colors[i]);
    }    
        
    NSUInteger dotCount = colors.count;
    CGFloat minSpacing = 5.0;
    
    // Get the available width
    CGFloat availableWidth = dirtyRect.size.width - (minSpacing * (dotCount - 1));

    // Calculate the maximum possible dot size
    CGFloat maxDotSize = availableWidth / dotCount;
    
    // Ensure dots do not exceed the view height
    CGFloat dotSize = MIN(maxDotSize, dirtyRect.size.height - 10.0); // Leave some padding at the top/bottom

    // Calculate the total width occupied by dots including spacing
    CGFloat totalContentWidth = (dotSize * dotCount) + (minSpacing * (dotCount - 1));
    
    // Compute starting X position to center dots horizontally
    CGFloat x = (dirtyRect.size.width - totalContentWidth) / 2;
    CGFloat y = (dirtyRect.size.height - dotSize) / 2; // Center vertically

    for (NSColor *color in colors) {
        NSBezierPath *circle = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(x, y, dotSize, dotSize)];
        [color setFill];
        [circle fill];
        x += dotSize + minSpacing;
    }
}

- (void)setCharacter:(DSACharacter *)character {
    _character = character;
    
    NSLog(@"DSACharacterStatusView THE CHARACTER STATES DICT: %@", character.statesDict);
    // Ensure the view updates once character is assigned
    [self setNeedsDisplay:YES];
    [self displayIfNeeded];
}

@end */