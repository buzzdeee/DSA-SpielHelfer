/* All rights reserved */

#import "DSAAdventureWindowController.h"
#import "DSAAdventureDocument.h"
#import "DSACharacterDocument.h"
#import "DSACharacterPortraitView.h"
#import "DSACharacter.h"
#import "DSAAventurianDate.h"
#import "DSAAventurianCalendar.h"
#import "DSAAdventureClock.h"
#import "DSAClockAnimationView.h"
#import "DSAAdventure.h"
#import "DSAAdventureGroup.h"
#import "Utils.h"
#import "DSAActionIcon.h"

extern NSString * const DSACharacterHighlightedNotification;

/*
@interface DSAAdventureWindowController ()
@property (nonatomic, strong) NSTimer *dayTimeAnimationUpdateTimer;
@end
*/

@implementation DSAAdventureWindowController

- (DSAAdventureWindowController *)init
{
  NSLog(@"DSAAdventureWindowController: init called");    
  self = [super init];
  if (self)
    {
    }
  return self;
}

- (void)dealloc {
    NSLog(@"DSAAdventureWindowController is being deallocated.");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    NSLog(@"removing observer of DSAAdventureDocument!");
    [(DSAAdventureDocument *)self.document removeObserver:self forKeyPath:@"selectedCharacterDocument"];  
  
    NSLog(@"DSAAdventureWindowController finished with dealloc");  
}

- (void)close {
    NSLog(@"Window is being closed manually, cleaning up.");
    [self.window close];  // This ensures the window is properly closed
    [self.clockAnimationView removeFromSuperview];  // Manually remove the view
    self.clockAnimationView = nil;  // Set the reference to nil
}

- (void)windowWillClose:(NSNotification *)notification {
    // Remove observer before window closes
    NSLog(@"DSAAdventureWindowController windowWillClose: removing observer of DSAAdventureDocument!");
    if (self.document) {
        [self.document removeObserver:self forKeyPath:@"selectedCharacterDocument"];
    }
    [self.clockAnimationView removeFromSuperview];
    [self.clockAnimationView.gameClock.gameTimer invalidate];
    self.clockAnimationView.gameClock.gameTimer = nil;
    [self.clockAnimationView.updateTimer invalidate];
    self.clockAnimationView.updateTimer = nil;    
    self.clockAnimationView = nil;
    [self.clockAnimationView removeFromSuperview];
    self.window.contentView = nil;  // Force the window to release views

    //[super windowWillClose:notification];
}

- (DSAAdventureWindowController *)initWithWindowNibName:(NSString *)nibNameOrNil
{
  NSLog(@"DSAAdventureWindowController initWithWindowNibName %@", nibNameOrNil);
  self = [super initWithWindowNibName:nibNameOrNil];
  if (self)
    {
      NSLog(@"DSAAdventureWindowController initialized with nib: %@", nibNameOrNil);
    }
  else
    {
      NSLog(@"DSAAdventureWindowController had trouble initializing");
    }
    
  return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    NSLog(@"DSAAdventureWindowController: awakeFromNib called, Adding observers...");
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleCharacterChanges)
                                                 name:@"DSAAdventureCharactersUpdated"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateActionIcons)
                                                 name:@"DSAAdventureLocationUpdated"
                                               object:nil];                                               
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleLogsMessage:)
                                                 name:@"DSACharacterEventLog"
                                               object:nil];
                                               
    DSAAdventureDocument *adventureDoc = (DSAAdventureDocument *)self.document;
    [adventureDoc addObserver:self 
                   forKeyPath:@"selectedCharacterDocument" 
                      options:NSKeyValueObservingOptionNew 
                      context:nil];  
                                                                                              
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"Ranke_1" ofType:@"jpg"];                                               
    NSImage *image = imagePath ? [[NSImage alloc] initWithContentsOfFile:imagePath] : nil;
    self.imageHorizontalRuler0.image = image;
    self.imageHorizontalRuler1.image = image;   
    [self.imageHorizontalRuler0 setImageScaling:NSImageScaleAxesIndependently];
    [self.imageHorizontalRuler1 setImageScaling:NSImageScaleAxesIndependently];
    imagePath = [[NSBundle mainBundle] pathForResource:@"Ranke_2" ofType:@"jpg"];
    image = imagePath ? [[NSImage alloc] initWithContentsOfFile:imagePath] : nil;
    self.imageVerticalRuler0.image = image;
    [self.imageVerticalRuler0 setImageScaling:NSImageScaleAxesIndependently]; 
    imagePath = [[NSBundle mainBundle] pathForResource:@"DSA-Fanprojekt-Logo-gross" ofType:@"png"];
    image = imagePath ? [[NSImage alloc] initWithContentsOfFile:imagePath] : nil;
    self.imageLogo.image = image;    
    [self.imageLogo setImageScaling:NSImageScaleAxesIndependently];
    CGFloat width = self.imageHorizontalRuler0.frame.size.width;
    CGFloat height = self.imageHorizontalRuler0.frame.size.height;
    NSLog(@"imageHorizontalRuler0 dimensions: %.2f x %.2f", width, height);
    width = self.imageVerticalRuler0.frame.size.width;
    height = self.imageVerticalRuler0.frame.size.height;
    NSLog(@"imageVerticalRuler0 dimensions: %.2f x %.2f", width, height);
    [self updateMainImageView];
    [self handleCharacterChanges];
    [self setupActionIcons];
     
}

- (void) setupActionIcons
{
    NSLog(@"DSAAdventureWindowController updateActionIcons called!!!!");

    DSAActionIcon *newIcon = [DSAActionIcon iconWithAction:@"addToGroup" andSize:@"128x128"];
    [self replaceView:self.imageActionIcon0 withView:newIcon];
    self.imageActionIcon0 = newIcon;
    
    newIcon = [DSAActionIcon iconWithAction:@"removeFromGroup" andSize:@"128x128"];
    [self replaceView:self.imageActionIcon1 withView:newIcon];
    self.imageActionIcon1 = newIcon;
    
    newIcon = [DSAActionIcon iconWithAction:@"splitGroup" andSize:@"128x128"];
    [self replaceView:self.imageActionIcon2 withView:newIcon];
    self.imageActionIcon2 = newIcon;    
}

- (void) updateActionIcons
{
    NSLog(@"DSAAdventureWindowController updateActionIcons called!!!!");

    [self.imageActionIcon0 updateAppearance];
    [self.imageActionIcon1 updateAppearance];
    [self.imageActionIcon2 updateAppearance];
    [self.imageActionIcon3 updateAppearance];
    [self.imageActionIcon4 updateAppearance];
    [self.imageActionIcon5 updateAppearance];
    [self.imageActionIcon6 updateAppearance];
    [self.imageActionIcon7 updateAppearance];                            
    [self.imageActionIcon8 updateAppearance];    
}

- (void)replaceView:(NSView *)oldView withView:(NSView *)newView {
    NSView *superview = oldView.superview;
    NSRect frame = oldView.frame;
    newView.frame = frame;
    [oldView removeFromSuperview];
    [superview addSubview:newView positioned:NSWindowAbove relativeTo:nil];
}

- (void) handleCharacterChanges {
    // Ensure we have a valid adventure document
    NSLog(@"DSAAdventureWindowController updatePartyPortraits called!!!");
    DSAAdventureDocument *adventureDoc = (DSAAdventureDocument *)self.document;
    if (!adventureDoc) return;
    NSLog(@"DSAAdventureWindowController updatePartyPortraits before the NSArray imageViews!!!");
    NSArray *imageViews = @[
        self.imagePartyMember0,
        self.imagePartyMember1,
        self.imagePartyMember2,
        self.imagePartyMember3,
        self.imagePartyMember4,
        self.imagePartyMember5
    ];

    NSArray *characters = adventureDoc.characterDocuments;
    NSLog(@"DSAAdventureWindowController updatePartyPortraits for the characters: %@!!!", characters);
    
    // Loop through up to 6 characters and assign portraits
    for (NSInteger i = 0; i < imageViews.count; i++) {
        NSLog(@"DSAAdventureWindowController handleCharacterChanges in the for loop");
        DSACharacterPortraitView *imageView = imageViews[i];

        if (i < characters.count) {
            NSLog(@"DSAAdventureWindowController handleCharacterChanges in main if in for loop");
            DSACharacterDocument *charDoc = characters[i];
            DSACharacter *character = charDoc.model;
            imageView.characterDocument = charDoc;
            imageView.image = [character portrait]; // Get portrait from model
            for (NSImageRep *rep in imageView.image.representations) {
    if ([rep hasAlpha]) {
        NSLog(@"Image rep supports alpha.");
    } else {
        NSLog(@"Image rep does NOT support alpha.");
    }
}
            if ([adventureDoc.model.activeGroup.partyMembers containsObject: character.modelID])
              {
                NSLog(@"DSAAdventureWindowController handleCharacterChanges: setting alpha value 1.0");
                imageView.alphaValue = 1.0;
                // imageView.image = [self imageWithAlpha:imageView.image alpha:1.0];
                [imageView setNeedsDisplay:YES];
              }
            else
              {
                NSLog(@"DSAAdventureWindowController handleCharacterChanges: setting alpha value 0.4");
                imageView.alphaValue = 0.4;
                // imageView.image = [self imageWithAlpha:imageView.image alpha:0.4]; // we'll loose the original colored image, would have to keep the original somewhere :/
                [imageView setNeedsDisplay:YES];
              }
            imageView.toolTip = [imageView toolTip];
        } else {
            NSLog(@"DSAAdventureWindowController handleCharacterChanges in main else in for loop");
            imageView.image = nil; // Clear unused slots
            imageView.characterDocument = nil;
            imageView.toolTip = @"";
        }
    }
    [self updateActionIcons];
}

// using below method, we'd loose the original image, can't easily restore it like when using alphaValue :/
// we'd have to store the original image somewhere, and restore/replace it...
- (NSImage *)imageWithAlpha:(NSImage *)image alpha:(CGFloat)alpha {
    if (!image || alpha >= 1.0) return image;

    NSImage *fadedImage = [[NSImage alloc] initWithSize:image.size];
    [fadedImage lockFocus];
    [image drawAtPoint:NSZeroPoint
              fromRect:NSMakeRect(0, 0, image.size.width, image.size.height)
             operation:NSCompositeSourceOver
              fraction:alpha];
    [fadedImage unlockFocus];
    return fadedImage;
}

- (void)updateMainImageView
{
  DSAAdventureDocument *adventureDoc = (DSAAdventureDocument *)self.document;
  DSALocation *currentLocation = adventureDoc.model.activeGroup.location;
  if ([currentLocation isKindOfClass: [DSALocalMapLocation class]])
    {
      DSALocalMapLocation *localMapLocation = (DSALocalMapLocation *)currentLocation;
      NSInteger x = localMapLocation.x;
      NSInteger y = localMapLocation.y;
      NSInteger mapLevel = localMapLocation.level;
      DSALocalMap *locationMap = localMapLocation.locationMap;
      
      DSALocalMapLevel *currentMapLevel;
      for (DSALocalMapLevel *currentLevel in locationMap.mapLevels)
        {
           if (mapLevel == currentLevel.level)
             {
               currentMapLevel = currentLevel;
               break;
             }
        }
      DSALocalMapTile *currentTile = [[currentMapLevel.mapTiles objectAtIndex: y] objectAtIndex: x];
      NSLog(@"DSAAdventureWindowController updateMainImageView found currentTile: %@", currentTile);
      NSString *god;
      if ([currentTile isMemberOfClass: [DSALocalMapTileBuildingTemple class]])
        {
          god = [(DSALocalMapTileBuildingTemple *) currentTile god];
        }
     NSString *imageName = [NSString stringWithFormat:@"%@_Tempel_1.webp", god];

     NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageName ofType:nil];
     if (imagePath) {
          NSImage *image = [[NSImage alloc] initWithContentsOfFile:imagePath];
          [self.imageMain setImage:image];
      } else {
          NSLog(@"Image not found: %@", imageName);
      }      
    }
}

- (void)characterHighlighted:(DSACharacterDocument *) selectedCharacter {
    if (selectedCharacter) {

        NSLog(@"DSAAdventureWindowController characterHighlighted: %@", selectedCharacter.model.name);
    } else {
        // No character is selected
        NSLog(@"DSAAdventureWindowController characterHighlighted: deselected Character %@", selectedCharacter.model.name);
    }
}

- (void)handleLogsMessage:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    if (!userInfo) return;
    
    LogSeverity severity = [userInfo[@"severity"] integerValue];
    NSString *message = userInfo[@"message"];
    
    if (!message) return;

    NSLog(@"DSAAdventureWindowController handleLogsMessage: Got message: %@", message);
    // Get timestamp
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss"];
    NSString *timestamp = [formatter stringFromDate:[NSDate date]];

    // Format log entry with bold timestamp
    NSMutableAttributedString *logEntry = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@", timestamp, message]];
    
    // Apply bold font to timestamp
    [logEntry addAttribute:NSFontAttributeName value:[NSFont boldSystemFontOfSize:12] range:NSMakeRange(0, timestamp.length)];

    // Apply color based on severity
    NSColor *textColor;
    switch (severity) {
        case LogSeverityInfo:
            textColor = [NSColor blackColor];
            break;
        case LogSeverityHappy:
            textColor = [NSColor blueColor];
            break;            
        case LogSeverityWarning:
            textColor = [NSColor brownColor];
            break;
        case LogSeverityCritical:
            textColor = [NSColor redColor];
            break;
    }
    
    [logEntry addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(timestamp.length + 1, message.length)];

    // Append to existing logs, ensuring we don't exceed the field’s capacity
    NSLog(@"That's the log entry: %@", logEntry);
    [self appendLogMessage:logEntry];
}

- (void)appendLogMessage:(NSAttributedString *)newLog {
    NSMutableAttributedString *existingLogs = [[NSMutableAttributedString alloc] initWithAttributedString:self.fieldLogs.attributedStringValue];

    // Store log entries as attributed strings
    NSMutableArray<NSAttributedString *> *logEntries = [NSMutableArray array];

    // Define regex pattern for timestamps (e.g., "12:34:56")
    NSString *timestampPattern = @"\\b\\d{2}:\\d{2}:\\d{2}\\b";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:timestampPattern options:0 error:nil];

    __block NSInteger lastMatchLocation = 0;
    NSArray<NSTextCheckingResult *> *matches = [regex matchesInString:existingLogs.string options:0 range:NSMakeRange(0, existingLogs.length)];

    // Extract log messages based on timestamp locations
    for (NSTextCheckingResult *match in matches) {
        if (match.range.location > lastMatchLocation) {
            NSRange entryRange = NSMakeRange(lastMatchLocation, match.range.location - lastMatchLocation);
            NSAttributedString *logEntry = [existingLogs attributedSubstringFromRange:entryRange];
            [logEntries addObject:logEntry];
        }
        lastMatchLocation = match.range.location; // Update last match location
    }

    // Add the last entry if not already added
    if (lastMatchLocation < existingLogs.length) {
        NSAttributedString *lastLog = [existingLogs attributedSubstringFromRange:NSMakeRange(lastMatchLocation, existingLogs.length - lastMatchLocation)];
        [logEntries addObject:lastLog];
    }

    // Add the new log entry
    [logEntries addObject:newLog];

    // Define max number of log entries allowed
    NSInteger maxEntries = 6; // Adjust as needed

    // Remove oldest entries if exceeding max
    while (logEntries.count > maxEntries) {
        [logEntries removeObjectAtIndex:0];
    }

    // Rebuild the attributed string **with newline checks**
    NSMutableAttributedString *updatedLogs = [[NSMutableAttributedString alloc] init];
    for (NSInteger i = 0; i < logEntries.count; i++) {
        // Append the log entry
        [updatedLogs appendAttributedString:logEntries[i]];

        // Only add a newline if the previous entry didn't end with one
        if (i < logEntries.count - 1) { // Avoid adding a newline after the last entry
            NSString *lastEntryString = [logEntries[i] string];
            if (![lastEntryString hasSuffix:@"\n"]) {
                [updatedLogs appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
            }
        }
    }

    // Update NSTextField while preserving formatting
    self.fieldLogs.attributedStringValue = updatedLogs;
}


- (void)observeValueForKeyPath:(NSString *)keyPath 
                       ofObject:(id)object 
                         change:(NSDictionary<NSKeyValueChangeKey,id> *)change 
                        context:(void *)context {
    
    if ([keyPath isEqualToString:@"selectedCharacterDocument"]) {
        DSAAdventureDocument *adventureDoc = (DSAAdventureDocument *)object;
        DSACharacterDocument *selectedCharacter = adventureDoc.selectedCharacterDocument;
        [self characterHighlighted: selectedCharacter];
    }
}
@end
