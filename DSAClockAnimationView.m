/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-03-02 20:21:51 +0100 by sebastia

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

#import "DSAClockAnimationView.h"
#import "DSAAventurianCalendar.h"
#import "DSAAdventureClock.h"
#import "DSAAdventureDocument.h"
#import "DSAAdventureWindowController.h"
#import "DSAAdventure.h"

@implementation DSAClockAnimationView

// Initialization
- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //NSLog(@"DSAClockAnimationView initWithFrame called");
        // Sync initial values
        [self updateFromAdventureClock];                                                      
    }
    return self;
}

- (void)awakeFromNib
{
    //NSLog(@"DSAClockAnimationView awakeFromNib called");
    NSWindow *window = self.window;
    __weak DSAAdventureWindowController *windowController = (DSAAdventureWindowController *)window.windowController;
    if (windowController && windowController.document) {
        // Access the model's gameClock here
        DSAAdventureDocument *document = (DSAAdventureDocument*)windowController.document;
        // NSLog(@"DSAClockAnimationView awakeFromNib: Game Clock: %@", document.model.gameClock);
        self.gameClock = document.model.gameClock; 
        self.gameWeather = document.model.gameWeather;
    } else {
        NSLog(@"DSAClockAnimationView awakeFromNib: WindowController or document not available.");
    }        
    // Sync initial values
    [self updateFromAdventureClock];

    // Start the timer to update the view every minute     
    __weak typeof(self) weakSelf = self;                                              
    _updateTimer = [NSTimer scheduledTimerWithTimeInterval:60.0
                                                repeats:YES
                                                  block:^(NSTimer * _Nonnull timer) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            [timer invalidate];
            return;
        }
        [strongSelf timerUpdate];
    }];                                                                                                      
}

- (void) dealloc
{
    //NSLog(@"DSAClockAnimationView dealloc called");
    if (self.updateTimer) {
        [self.updateTimer invalidate];
        self.updateTimer = nil;
        //NSLog(@"DSAClockAnimationView: dealloc: Timer stopped.");
    }    
}

- (void) viewWillDisappear {
    // NSLog(@"DSAClockAnimationView viewWillDisappear called");
    [self.updateTimer invalidate];
    self.updateTimer = nil;
}

- (void)updateFromAdventureClock {
    // NSLog(@"DSAClockAnimationView updateFromAdventureClock called");
    
    if (self.gameClock.gameTimer) {
        // NSLog(@"DSAClockAnimationView updateFromAdventureClock: Timer reference exists.");
    } else {
        // NSLog(@"DSAClockAnimationView updateFromAdventureClock: Timer is nil, no need to update the UI.");
        return;
    }    
    
    DSAAventurianDate *currentDate = [self.gameClock currentDate];
    
    self.currentHour = currentDate.hour;
    self.currentMinute = currentDate.minute;
    self.currentMoonPhase = [self.gameClock currentMoonPhase];
}

- (void)timerUpdate {

    if (self.gameClock.gameTimer) {
        //NSLog(@"DSAClockAnimationView timerUpdate: Timer reference exists.");
    } else {
        //NSLog(@"DSAClockAnimationView timerUpdate: Timer is nil, no need to update the UI.");
        return;
    }
    
    DSAAventurianDate *currentDate = [self.gameClock currentDate];
    // NSLog(@"DSAClockAnimationView timerUpdate THE GAME CLOCK: %@", self.gameClock);
    // NSLog(@"DSAClockAnimationView timerUpdate self.superview: %@", self.superview);
//    DSAAdventureDocument *adventureDoc = (DSAAdventureDocument *)[[NSDocumentController sharedDocumentController] currentDocument];
//    self.gameWeather = adventureDoc.model.gameWeather;
    // NSLog(@"DSAClockAnimationView timerUpdate %@", currentDate);
    // NSLog(@"DSAClockAnimationView updateAnimationForHour weather: %@", self.gameWeather);
    [self updateAnimationForHour:currentDate.hour
                          minute:currentDate.minute
                       moonPhase:[self.gameClock currentMoonPhase]];
}

// Method to update the animation based on the hour and moon phase
- (void)updateAnimationForHour:(NSUInteger)hour 
                        minute:(NSUInteger)minute 
                     moonPhase:(DSAMoonPhase)moonPhase {
    //NSLog(@"DSAClockAnimationView updateAnimationForHour %@:%@", @(hour), @(minute));
    // NSLog(@"DSAClockAnimationView updateAnimationForHour weather: %@", self.gameWeather);
    if (self.gameClock.gameTimer) {
        //NSLog(@"DSAClockAnimationView updateAnimationForHour: Timer reference exists.");
    } else {
        //NSLog(@"DSAClockAnimationView updateAnimationForHour: Timer is nil, no need to update the UI.");
        return;
    }     
    self.currentHour = hour;
    self.currentMinute = minute;  // Store minute for smooth animation
    self.currentMoonPhase = moonPhase;
    
    [self setNeedsDisplay:YES]; // Redraw the view
}

// Override drawRect to handle custom drawing
- (void)drawRect:(NSRect)dirtyRect {
    NSLog(@"DSAClockAnimationView drawRect called %lu:%lu", self.currentHour, self.currentMinute);
    [super drawRect:dirtyRect];

    // Draw the sky background
    [self drawSky];

    // Draw the sun or moon based on the time of day
    if (self.currentHour >= 6 && self.currentHour < 18) {
        [self drawSun];
        [self drawClouds];
        [self drawPrecipitation];
        
        //[self drawFog];
    } else {
        [self drawStars];    
        [self drawMoon];
    }
}

// Draw the sky, transitioning based on the time of day
- (void)drawSky {
    NSColor *skyColor = [self skyColorForHour:self.currentHour minute: self.currentMinute];
    [skyColor setFill];
    NSRectFill(self.bounds);
}

- (void)drawPrecipitation {
    //NSLog(@"DSAClockAnimationView drawPrecipitation called");
    if (self.gameWeather.precipitation == DSAPrecipNone || self.gameWeather.precipitation == DSAPrecipCalm) {
        return;  // No precipitation, nothing to draw
    }
    
    // Set the color and size based on the precipitation level
    CGFloat opacity = 0.3; // Default opacity for light precipitation
    CGFloat particleSize = 5.0; // Default size for precipitation
    NSInteger numberOfParticles = 100; // Default number of particles

    // Adjust opacity and number of particles based on precipitation level
    if (self.gameWeather.precipitation == DSAPrecipLight) {
        opacity = 0.4;
        numberOfParticles = 150;
    } else if (self.gameWeather.precipitation == DSAPrecipModerate) {
        opacity = 0.6;
        numberOfParticles = 200;
    } else if (self.gameWeather.precipitation == DSAPrecipHeavy) {
        opacity = 0.8;
        numberOfParticles = 300;
    }
    
    // Draw precipitation depending on temperature: Snow if freezing, Rain otherwise
    if (self.gameWeather.temperature == DSATempFreezing) {
        // Draw snow
        [[NSColor whiteColor] setFill]; // Snow is white
        particleSize = 3.0; // Smaller particles for snow
    } else {
        // Draw rain
        [[NSColor colorWithCalibratedRed:0.5 green:0.5 blue:1 alpha:opacity] setFill]; // Light blue color for rain
        particleSize = 5.0; // Larger particles for rain
    }
    
    // Generate particles based on the weather conditions
    for (NSInteger i = 0; i < numberOfParticles; i++) {
        CGFloat xPos = arc4random_uniform(self.bounds.size.width);
        CGFloat yPos = arc4random_uniform(self.bounds.size.height);
        
        // Adjust the Y position for rain/snow particles to start from the top
        CGFloat yStart = self.bounds.size.height;  // Starting at the top of the NSRect
        
        // Create a particle
        // NSRect particleRect = NSMakeRect(xPos, yStart, particleSize, particleSize);
        NSRect particleRect = NSMakeRect(xPos, yPos, particleSize, particleSize);
        NSBezierPath *particlePath = [NSBezierPath bezierPathWithOvalInRect:particleRect];
        
        // Draw the particle
        [particlePath fill];
    }
}

- (void)drawFog {
    //NSLog(@"DSAClockAnimationView drawFog called");
    if (self.gameWeather.fogDensity == DSAFogNone) {
        return; // No fog
    }

    CGFloat fogOpacity = (self.gameWeather.fogDensity == DSAFogLight) ? 0.3 : 0.6;
    
    [[NSColor colorWithCalibratedWhite:0.8 alpha:fogOpacity] setFill];
    NSRectFillUsingOperation(self.bounds, NSCompositeSourceOver);
}

- (void)drawClouds {
    //NSLog(@"DSAClockAnimationView drawClouds called");
    if (self.gameWeather.cloudCoverage == DSACloudClear) {
        return; // No clouds
    }

    NSInteger cloudCount = 5; // Default number of clouds
    CGFloat opacity = 0.2;    // Default opacity for clear sky
    
    // Adjust cloud count and opacity based on the cloud coverage
    if (self.gameWeather.cloudCoverage == DSACloudPartlyCloudy) {
        cloudCount = 10;
        opacity = 0.4;
    } else if (self.gameWeather.cloudCoverage == DSACloudOvercast) {
        cloudCount = 20;
        opacity = 0.6;
    }

    // Set the color with the opacity based on cloud coverage
    [[NSColor colorWithCalibratedWhite:1.0 alpha:opacity] setFill]; 

    // Draw clouds randomly within the NSRect
    for (NSInteger i = 0; i < cloudCount; i++) {
        CGFloat cloudWidth = arc4random_uniform(100) + 50; // Random width
        CGFloat cloudHeight = arc4random_uniform(50) + 30; // Random height
        CGFloat cloudX = arc4random_uniform(self.bounds.size.width);
        CGFloat cloudY = arc4random_uniform(self.bounds.size.height / 2); // Top half of the screen

        NSRect cloudRect = NSMakeRect(cloudX, cloudY, cloudWidth, cloudHeight);
        NSBezierPath *cloudPath = [NSBezierPath bezierPathWithOvalInRect:cloudRect];
        [cloudPath fill];
    }
}

// Determine the sky color based on the current hour and minute for smooth transitions
- (NSColor *)skyColorForHour:(NSUInteger)hour minute:(NSUInteger)minute {
    CGFloat t = (hour + minute / 60.0 - 6) / 12.0;  // Normalize time (0 to 1) for sunrise to sunset
    if (t < 0 || t > 1) return [NSColor blackColor];  // Don't draw outside valid range

    NSColor *dayColorStart = [NSColor colorWithCalibratedRed:0.2 green:0.4 blue:0.6 alpha:1];  // Darker early morning (6 AM)
    NSColor *dayColorEnd = [NSColor colorWithCalibratedRed:0.5 green:0.7 blue:1 alpha:1];      // Light blue day color (12 PM)
    
    // Night colors (dark version of the day colors)
    NSColor *nightColorStart = [NSColor colorWithCalibratedRed:0.1 green:0.1 blue:0.2 alpha:1];  // Darker night color (6 PM)
    NSColor *nightColorEnd = [NSColor colorWithCalibratedRed:0.05 green:0.05 blue:0.1 alpha:1];    // Very dark (5 AM)

    NSColor *skyColor;

    // Morning transition (6 AM - 7 AM)
    if (hour >= 6 && hour < 7) {
        CGFloat morningT = (hour + minute / 60.0 - 6) / 1.0;  // Normalize 6 AM to 7 AM
        skyColor = [self interpolateColorFrom:dayColorStart to:dayColorEnd progress:morningT];
    }
    // Evening transition (6 PM - 7 PM)
    else if (hour >= 18 && hour < 19) {
        CGFloat eveningT = (hour + minute / 60.0 - 18) / 1.0;  // Normalize 6 PM to 7 PM
        skyColor = [self interpolateColorFrom:nightColorStart to:nightColorEnd progress:eveningT];
    }
    // Daytime (7 AM - 5 PM)
    else if (hour >= 7 && hour < 17) {
        skyColor = dayColorEnd;  // Full daytime color
    }
    // Nighttime (5 PM - 6 AM)
    else {
        CGFloat nightT = (hour + minute / 60.0 - 18) / 12.0;  // Normalize for night (6 PM to 6 AM)
        skyColor = [self interpolateColorFrom:nightColorStart to:nightColorEnd progress:nightT];
    }

    return skyColor;
}

// Interpolating between two colors based on progress (0 - 1)
- (NSColor *)interpolateColorFrom:(NSColor *)startColor to:(NSColor *)endColor progress:(CGFloat)progress {
    CGFloat startRed, startGreen, startBlue, startAlpha;
    CGFloat endRed, endGreen, endBlue, endAlpha;
    
    [startColor getRed:&startRed green:&startGreen blue:&startBlue alpha:&startAlpha];
    [endColor getRed:&endRed green:&endGreen blue:&endBlue alpha:&endAlpha];
    
    CGFloat interpolatedRed = startRed + (endRed - startRed) * progress;
    CGFloat interpolatedGreen = startGreen + (endGreen - startGreen) * progress;
    CGFloat interpolatedBlue = startBlue + (endBlue - startBlue) * progress;
    CGFloat interpolatedAlpha = startAlpha + (endAlpha - startAlpha) * progress;

    return [NSColor colorWithCalibratedRed:interpolatedRed green:interpolatedGreen blue:interpolatedBlue alpha:interpolatedAlpha];
}

// Draw random stars at night (7 PM - 5 AM)
- (void)drawStars {
    CGFloat hour = (CGFloat)self.currentHour;
    CGFloat minute = (CGFloat)self.currentMinute;
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    // Check if it's night time (7 PM - 5 AM)
    if ((hour >= 19 || hour < 5) || (hour == 19 && minute >= 0) || (hour == 5 && minute < 0)) {
        CGFloat starOpacity = 1.0;

        // Fade out stars at dawn (5 AM - 6 AM)
        if (hour >= 5 && hour < 6) {
            CGFloat fadeT = (hour + minute / 60.0 - 5) / 1.0;  // Normalize fade time (5 AM - 6 AM)
            starOpacity = 1.0 - fadeT;  // Stars will fade out as dawn approaches
        }
        // Fade in stars at dusk (6 PM - 7 PM)
        else if (hour >= 18 && hour < 19) {
            CGFloat fadeT = (hour + minute / 60.0 - 18) / 1.0;  // Normalize fade time (6 PM - 7 PM)
            starOpacity = fadeT;  // Stars will fade in as night approaches
        }

        // Draw stars randomly
        for (int i = 0; i < 50; i++) {  // 50 stars for example
            CGFloat x = arc4random_uniform(width);  // Random X position
            CGFloat y = arc4random_uniform(height);  // Random Y position
            CGFloat size = arc4random_uniform(2) + 1;  // Random size (1 or 2 pixels)
            
            NSColor *starColor = [NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:starOpacity];  // White stars

            [starColor setFill];
            NSRect starRect = NSMakeRect(x, y, size, size);
            NSBezierPath *starPath = [NSBezierPath bezierPathWithOvalInRect:starRect];
            [starPath fill];
        }
    }
}

// Draw the sun with proper horizon clipping
- (void)drawSun {
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    CGFloat sunSize = 40;

    // Convert hour + minutes into a fractional time
    CGFloat hourFraction = self.currentHour + (self.currentMinute / 60.0);

    // Normalize time for the sun cycle (6 AM to 6 PM → 0 to 1)
    CGFloat t = (hourFraction - 6) / 12.0;
    if (t < 0 || t > 1) return; // Don't draw sun outside this range

    // X position: Left edge starts at 6 AM, right edge ends at 6 PM
    CGFloat sunX = t * (width - sunSize);

    // Y position: Start **offscreen below** (-sunSize) → Move in an arc → End offscreen
    CGFloat sunY = (-sunSize) + (1.2 * height) * sin(t * M_PI);

    // Draw the sun
    NSImage *sunImage = [NSImage imageNamed:@"sun"];
    [sunImage drawInRect:NSMakeRect(sunX, sunY, sunSize, sunSize)];
}

// Draw the moon with correct horizon entry/exit
- (void)drawMoon {
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    CGFloat moonSize = 40;

    // Convert hour + minutes into a fractional time
    CGFloat hourFraction = self.currentHour + (self.currentMinute / 60.0);

    // Normalize time for the moon cycle (6 PM to 6 AM → 0 to 1)
    CGFloat t = (hourFraction >= 18) ? (hourFraction - 18) / 12.0 : (hourFraction + 6) / 12.0;
    if (t < 0 || t > 1) return; // Don't draw moon outside this range

    // X position: Left edge starts at 6 PM, right edge ends at 6 AM
    CGFloat moonX = t * (width - moonSize);

    // Y position: Start **offscreen below** (-moonSize) → Move in an arc → End offscreen
    CGFloat moonY = (-moonSize) + (1.2 * height) * sin(t * M_PI);

    // Get the moon image
    NSString *moonImagePath = [[NSBundle mainBundle] pathForResource:[self imageNameForMoonPhase:self.currentMoonPhase] ofType:@"png"];
    NSImage *moonImage = moonImagePath ? [[NSImage alloc] initWithContentsOfFile:moonImagePath] : nil;

    // Draw the moon
    if (moonImage) {
        [moonImage drawInRect:NSMakeRect(moonX, moonY, moonSize, moonSize)];
    }
}


// Get the image name corresponding to the current moon phase
- (NSString *)imageNameForMoonPhase:(DSAMoonPhase)phase {
    switch (phase) {
        case DSAMoonPhaseNewMoon: return @"moon_new";
        case DSAMoonPhaseWaxingCrescent: return @"moon_waxing_crescent";
        case DSAMoonPhaseFirstQuarter: return @"moon_first_quarter";
        case DSAMoonPhaseWaxingGibbous: return @"moon_waxing_gibbous";
        case DSAMoonPhaseFullMoon: return @"moon_full";
        case DSAMoonPhaseWaningGibbous: return @"moon_waning_gibbous";
        case DSAMoonPhaseLastQuarter: return @"moon_last_quarter";
        case DSAMoonPhaseWaningCrescent: return @"moon_waning_crescent";
    }
    return @"moon_full"; // Default to full moon
}

@end