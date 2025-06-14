/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-09-07 23:41:00 +0200 by sebastia

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

#import <objc/message.h>
#import <objc/runtime.h>
#import "DSACharacterWindowController.h"
#import "DSACharacterDocument.h"
#import "DSACharacter.h"
#import "DSATalent.h"
#import "DSASpell.h"
#import "DSALiturgy.h"
#import "NSFlippedView.h"
#import "DSACharacterViewModel.h"
#import "DSACharacterStatusView.h"
#import "DSARightAlignedStringTransformer.h"
#import "DSAInventorySlotView.h"
#import "DSASpellResult.h"
#import "DSARegenerationResult.h"
#import "Utils.h"

@implementation DSACharacterWindowController

// don't do anything here
// we don't want the window loaded on application start
- (DSACharacterWindowController *)init
{
  NSLog(@"DSACharacterWindowController: init called");    
  self = [super init];
  if (self)
    {
      _observedKeyPaths = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsStrongMemory];
    }
  return self;
}

- (void)dealloc {
    NSLog(@"DSACharacterWindowController is being deallocated.");

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self closeAllAuxiliaryWindows];
    [[self window] close];

    NSLog(@"DSACharacterWindowController: removing observers");
    for (id object in self.observedKeyPaths) {
        //NSLog(@"DSACharacterWindowController: remove observer for object: %@", object);
        NSSet<NSString *> *keyPaths = [self.observedKeyPaths objectForKey:object];
        NSLog(@"DSACharacterWindowController: remove observer for keyPaths %@", keyPaths);
        for (NSString *keyPath in keyPaths) {
            NSLog(@"DSACharacterWindowController: remove observer for keyPath %@", keyPath);
            @try {
                [object removeObserver:self forKeyPath:keyPath];
            } @catch (NSException *exception) {
                NSLog(@"Exception removing observer: %@", exception);
            }
        }
    } 
    NSLog(@"DSACharacterWindowController: here at the end of dealloc");
    DSACharacterDocument *document = (DSACharacterDocument *)self.document;
    document.windowControllersCreated = NO;
    NSLog(@"DSACharacterWindowController: here at the VERY end of dealloc: %@", [NSNumber numberWithBool: document.windowControllersCreated]);
}


- (NSString *)windowNibName {
    return @"DSACharacter";  // Replace with your actual nib name
}

- (DSACharacterWindowController *)initWithWindowNibName:(NSString *)nibNameOrNil
{
  NSLog(@"DSACharacterWindowController initWithWindowNibName %@", nibNameOrNil);
  self = [super initWithWindowNibName:nibNameOrNil];
  NSLog(@"DSACharacterWindowController initWithWindowNibName self: %@", self);
  if (self)
    {
      NSLog(@"DSACharacterWindowController initialized with nib: %@", nibNameOrNil);
      self.spellItemFieldMap = [NSMutableDictionary dictionary];
      _observedKeyPaths = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsStrongMemory];
      // _observedKeyPaths = [NSMutableDictionary dictionary];
    }
  else
    {
      NSLog(@"DSACharacterWindowController had trouble initializing");
    }
  NSLog(@"DSACharacterWindowController initWithWindowNibName before returning self");  
  return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    NSLog(@"manageTempEnergiesPanel delegate: %@", [self.manageTempEnergiesPanel delegate]);
    // Add similar NSLogs for other auxiliary windows.
}


- (void)windowDidLoad
{
  [super windowDidLoad];
  // Perform additional setup after loading the window
  NSLog(@"DSACharacterWindowController: windowDidLoad called");
  // central KVO observers
  DSACharacterDocument *document = (DSACharacterDocument *)self.document;
  DSACharacter *model = (DSACharacter *)document.model;  
  // Register the value transformer
  //NSLog(@"HERE IN WINDOW DID LOAD THE MODEL: %@", model);
  [NSValueTransformer setValueTransformer:[[DSARightAlignedStringTransformer alloc] init] 
                                  forName:@"RightAlignedStringTransformer"];
    
    // Register for DSAInventoryChangedNotification specific to this document's model
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleInventoryUpdate)
                                                 name:@"DSAInventoryChangedNotification"
                                               object:model];
                                               
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleLogsMessage:)
                                                 name:@"DSACharacterEventLog"
                                               object:model];
                                                                                             
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleCharacterStateChange:)
                                                 name:@"DSACharacterStateChange"
                                               object:model];                                               
                                                       
    // Log the window
    if (!self.window) {
        NSLog(@"Error: No window found for DSACharacterWindowController!");
        return;
    }
    NSLog(@"Window: %@", self.window);

    // Log the content view
    NSView *contentView = (NSView *)self.window.contentView;
    if (!contentView) {
        NSLog(@"Error: No content view found!");
        // Set a default content view if missing
        contentView = [[NSView alloc] initWithFrame:self.window.frame];
        [self.window setContentView:contentView];
        NSLog(@"Content view has been set manually.");
    } else {
        NSLog(@"Window content view: %@", contentView);
    }
      
  NSLog(@"DSACharacterWindowController: before populateBasicsTab");                         
  [self populateBasicsTab];
  NSLog(@"DSACharacterWindowController: before populateFightingTalentsTab");
  [self populateFightingTalentsTab];
  NSLog(@"DSACharacterWindowController: before populateOtherTalentsTab");
  [self populateOtherTalentsTab];
  NSLog(@"DSACharacterWindowController: before populateProfessionsTab");
  [self populateProfessionsTab];
  NSLog(@"DSACharacterWindowController: before populateMagicTalentsTab");
  [self populateMagicTalentsTab];
  NSLog(@"DSACharacterWindowController: before populateSpecialTalentsTab");
  [self populateSpecialTalentsTab];
  NSLog(@"DSACharacterWindowController: before populateBiographyTab");
  [self populateBiographyTab];
  NSLog(@"DSACharacterWindowController: before handleAdventurePointsChange");
  [self handleAdventurePointsChange];
  NSLog(@"DSACharacterWindowController: after handleAdventurePointsChange");
}

- (void)closeAllAuxiliaryWindows {
    unsigned int propertyCount;
    objc_property_t *properties = class_copyPropertyList([self class], &propertyCount);

    NSLog(@"DSACharacterWindowController closeAllAuxiliaryWindows called");
    for (unsigned int i = 0; i < propertyCount; i++) {
        const char *propertyName = property_getName(properties[i]);
        NSString *name = [NSString stringWithUTF8String:propertyName];
        //NSLog(@"checking %@", name);

        id propertyValue = [self valueForKey:name];

        if ([propertyValue isKindOfClass:[NSWindow class]]) {
            NSPanel *panel = (NSPanel *)propertyValue;
            NSLog(@"checking panel: %@", panel);
            if (panel.isVisible) {
                NSLog(@"closing visible panel: %@", panel);
                [panel close];
            }
        }
    }
    free(properties);
}


- (BOOL)windowShouldClose:(NSWindow *)sender
{
    // Simply return YES to close the window without further checks.
    NSLog(@"DSACharacterWindowController windowShouldClose called!");
    return YES;
}

- (void)windowWillClose:(NSNotification *)notification {
    NSWindow *closingWindow = notification.object;
    DSACharacterDocument *doc = (DSACharacterDocument *)self.document;

    NSLog(@"DSACharacterWindowController willCloseWindow called, closing window: %@", closingWindow);
    if ([doc isMainWindow:closingWindow]) {
        NSLog(@"Main window is closing. Closing all auxiliary windows.");
        [self closeAllAuxiliaryWindows];
    }
}

- (void)addObserverForObject:(id)object keyPath:(NSString *)keyPath {
    [object addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:NULL];

    NSMutableSet<NSString *> *keyPaths = [self.observedKeyPaths objectForKey:object];
    if (!keyPaths) {
        keyPaths = [NSMutableSet set];
        [self.observedKeyPaths setObject:keyPaths forKey:object];
    }
    [keyPaths addObject:keyPath];
}


// just for debugging purposes...
- (void)logViewHierarchy:(NSView *)view level:(NSInteger)level {
    NSString *indentation = [@"" stringByPaddingToLength:level * 2 withString:@" " startingAtIndex:0];
    NSLog(@"%@%@ %@", indentation, view.className, NSStringFromRect(view.frame));

    for (NSView *subview in view.subviews) {
        [self logViewHierarchy:subview level:level + 1];
    }
}

// private method, used in windowDidLoad, to find menu items of interest
// iterates through submenus to find the correct one...
- (NSMenuItem *)menuItemWithTag:(NSInteger)tag inMenu:(NSMenu *)menu {
    for (NSMenuItem *item in [menu itemArray]) {
        if ([item tag] == tag) {
            return item;
        }
        if ([item submenu]) {
            NSMenuItem *subMenuItem = [self menuItemWithTag:tag inMenu:[item submenu]];
            if (subMenuItem) {
                return subMenuItem;
            }
        }
    }
    return nil;
}

- (void) populateBasicsTab
{
  DSACharacterDocument *document = (DSACharacterDocument *)self.document;

  [self.fieldName setStringValue: [document.model name]];
  [self.fieldTitle setStringValue: [document.model title]];  
  [self.fieldArchetype setStringValue: [document.model archetype]];
  [self.fieldOrigin setStringValue: [document.model origin]];
  [self.fieldSex setStringValue: [document.model sex]];
  [self.fieldHairColor setStringValue: [document.model hairColor]];  
  [self.fieldEyeColor setStringValue: [document.model eyeColor]];
  [self.fieldHeight setStringValue: [NSString stringWithFormat: @"%f", [document.model height]]];    
  [self.fieldWeight setStringValue: [NSString stringWithFormat: @"%f", [document.model weight]]];    
  [self.fieldBirthday setStringValue: [NSString stringWithFormat: @"%lu. %@ %lu %@", 
                                          (unsigned long)[[document.model birthday] day], 
                                          [[document.model birthday] monthName], 
                                          (unsigned long)[[document.model birthday] year], 
                                          [[document.model birthday] year] > 0 ? @"AF" : @"BF"]];  
  [self.fieldGod setStringValue: [document.model god]];      
  [self.fieldStars setStringValue: [document.model stars]];
  [self.fieldReligion setStringValue: [document.model religion]];      
  [self.fieldSocialStatus setStringValue: [document.model socialStatus]];  
  [self.fieldParents setStringValue: [document.model parents]];   
  
  [self.fieldMagicalDabbler setStringValue: [document.model isMagicalDabbler] ? _(@"Ja") : _(@"Nein")];
    
  if ([document.model element] && [document.model mageAcademy])
    {
      [self.fieldMageAcademy setStringValue: [NSString stringWithFormat: @"%@ (%@)", [document.model mageAcademy], [document.model element]]];
    }
  
  else if ([document.model element] && ![document.model mageAcademy])
    {
      [self.fieldMageAcademy setStringValue: [NSString stringWithFormat: @"%@", [document.model element]]];
      [self.fieldMageAcademyBold setStringValue: _(@"Element")];  
    }
  else if (![document.model element] && [document.model mageAcademy])
    {
      [self.fieldMageAcademy setStringValue: [document.model mageAcademy]];
    }
  else
    {
      [self.fieldMageAcademyBold setHidden: YES];
      [self.fieldMageAcademy setHidden: YES];
    }
  if ([document.model isMemberOfClass: [DSACharacterHeroHumanMage class]])
    {
      [self.fieldMageAcademyBold setStringValue: _(@"Magierakademie")];
    }
  else if ([document.model isMemberOfClass: [DSACharacterHeroHumanWarrior class]])
    {
      [self.fieldMageAcademyBold setStringValue: _(@"Kriegerakademie")];
    }
  else if ([document.model isMemberOfClass: [DSACharacterHeroDwarfGeode class]])
    {
      [self.fieldMageAcademyBold setStringValue: _(@"Geodische Schule")];
    }    
        
  // Create and configure your view model
  DSACharacterViewModel *viewModel = [[DSACharacterViewModel alloc] init];
  DSACharacterHero *model = (DSACharacterHero *)document.model;
  viewModel.model = model;  // Pass the entire model to the viewModel
  [self.fieldMoney bind:NSValueBinding
               toObject:viewModel
            withKeyPath:@"formattedWallet"
                options:nil];
  [self addObserverForObject: viewModel keyPath: @"formattedWallet"];
  [self.fieldLifePoints bind:NSValueBinding
                    toObject:viewModel
                 withKeyPath:@"formattedLifePoints"
                     options:nil];
  [self addObserverForObject: viewModel keyPath: @"formattedLifePoints"];    
  [self.fieldAstralEnergy bind:NSValueBinding
                      toObject:viewModel
                   withKeyPath:@"formattedAstralEnergy"
                       options:nil];
  [self addObserverForObject: viewModel keyPath: @"formattedAstralEnergy"]; 
  [self.fieldKarmaPoints bind:NSValueBinding
                     toObject:viewModel
                  withKeyPath:@"formattedKarmaPoints"
                      options:nil];
  [self addObserverForObject: viewModel keyPath: @"formattedKarmaPoints"];                                              
  [self.imageViewPortrait setImage: [document.model portrait]];
  [self.imageViewPortrait setImageScaling: NSImageScaleProportionallyUpOrDown];   
  NSLog(@"populateBasicsTab: before positive traits");                                                                                                       
  for (NSString *field in @[ @"MU", @"KL", @"IN", @"CH", @"FF", @"GE", @"KK" ])
    {
      NSString *fieldKey = [NSString stringWithFormat:@"field%@", field]; // Constructs "fieldAG", "fieldHA", etc.
      NSTextField *fieldControl = [self valueForKey:fieldKey]; // Dynamically retrieves self.fieldAG, self.fieldHA, etc.
      
      [fieldControl bind:NSValueBinding
                toObject:viewModel
             withKeyPath: [NSString stringWithFormat:@"formattedPositiveTraits.%@", field]
                 options: nil];
      [self addObserverForObject: viewModel keyPath: [NSString stringWithFormat:@"formattedPositiveTraits.%@", field]];
    }
  for (NSString *field in @[ @"AG", @"HA", @"RA", @"TA", @"NG", @"GG", @"JZ" ])
    {
      NSString *fieldKey = [NSString stringWithFormat:@"field%@", field]; // Constructs "fieldAG", "fieldHA", etc.
      NSTextField *fieldControl = [self valueForKey:fieldKey]; // Dynamically retrieves self.fieldAG, self.fieldHA, etc.

      [fieldControl bind:NSValueBinding
                toObject:viewModel
             withKeyPath: [NSString stringWithFormat:@"formattedNegativeTraits.%@", field]
                 options: nil];
      [self addObserverForObject: viewModel keyPath: [NSString stringWithFormat:@"formattedNegativeTraits.%@", field]];                                         
    }
  NSLog(@"BEFORE displaying the LOAD");
  [self.fieldLoad setStringValue: [NSString stringWithFormat: @"%.2f", [document.model load]]];
  [self.fieldEncumbrance setStringValue: [NSString stringWithFormat: @"%.0f", [document.model encumbrance]]];
  [self.fieldArmor setStringValue: [NSString stringWithFormat: @"%.0f", [document.model armor]]];
  NSLog(@"AFTER displaying the LOAD");  
  
  [self.fieldAttackBaseValue bind:NSValueBinding toObject:document.model withKeyPath:@"attackBaseValue" options:nil];    
  [self addObserverForObject: document.model keyPath: @"attackBaseValue"];
  [self.fieldCarryingCapacity bind:NSValueBinding toObject:document.model withKeyPath:@"carryingCapacity" options:nil];    
  [self addObserverForObject: document.model keyPath: @"carryingCapacity"];
  NSLog(@"DSACharacterWindowController populateBasicsTab: carryingCapacity: %lu", (unsigned long) document.model.carryingCapacity);
  [self.fieldDodge bind:NSValueBinding toObject:document.model withKeyPath:@"dodge" options:nil];    
  [self addObserverForObject: document.model keyPath: @"dodge"];
  [self.fieldEndurance bind:NSValueBinding toObject:document.model withKeyPath:@"endurance" options:nil];    
  [self addObserverForObject: document.model keyPath: @"endurance"];
  [self.fieldMagicResistance bind:NSValueBinding toObject:document.model withKeyPath:@"magicResistance" options:nil];    
  [self addObserverForObject: document.model keyPath: @"magicResistance"];
  [self.fieldParryBaseValue bind:NSValueBinding toObject:document.model withKeyPath:@"parryBaseValue" options:nil];    
  [self addObserverForObject: document.model keyPath: @"parryBaseValue"];
  [self.fieldRangedCombatBaseValue bind:NSValueBinding toObject:document.model withKeyPath:@"rangedCombatBaseValue" options:nil];    
  [self addObserverForObject: document.model keyPath: @"rangedCombatBaseValue"];            
  [self.fieldLevel bind:NSValueBinding toObject:document.model withKeyPath:@"level" options:nil];    
  [self addObserverForObject: document.model keyPath: @"level"];
  [self.fieldAdventurePoints bind:NSValueBinding toObject:document.model withKeyPath:@"adventurePoints" options:nil];    
  [self addObserverForObject: document.model keyPath: @"adventurePoints"];
  NSLog(@"AFTER adding all those observers....");
  [self populateInventory];
  
  NSLog(@"End of populateBasicsTab");   


}


- (void)populateInventory {
    DSACharacterDocument *document = (DSACharacterDocument *)self.document;
    NSLog(@"DSACharacterWindowController populateInventory called");

    DSAActionIcon *newIcon = [DSAActionIcon iconWithAction:@"examine" andSize:@"64x64"];
    [self replaceView:self.imageEye withView:newIcon];
    self.imageEye = newIcon;    

    newIcon = [DSAActionIcon iconWithAction:@"consume" andSize:@"64x64"];
    [self replaceView:self.imageMouth withView:newIcon];
    self.imageMouth = newIcon;        
    
    newIcon = [DSAActionIcon iconWithAction:@"dispose" andSize:@"64x64"];
    [self replaceView:self.imageTrash withView:newIcon];
    self.imageTrash = newIcon;    
    
    NSString *imagePath;
    NSImage *image;
    NSLog(@"after eye and mouth and trash");
    if ([document.model.sex isEqualToString: _(@"männlich")])
      {
        imagePath = [[NSBundle mainBundle] pathForResource:@"Male_shape" ofType:@"png"];
      }
    else
      {
        imagePath = [[NSBundle mainBundle] pathForResource:@"Female_shape" ofType:@"png"];
      }
    image = imagePath ? [[NSImage alloc] initWithContentsOfFile:imagePath] : nil;
    self.imageViewBodyShape.image = image;

    // Update general inventory slots
    [self updateInventorySlotsWithInventory:document.model.inventory
                          inventoryIdentifier:@"inventory"
                         startingSlotCounter:0];
      CGFloat hungerLevel = [document.model.statesDict[@(DSACharacterStateHunger)] floatValue];
      CGFloat thirstLevel = [document.model.statesDict[@(DSACharacterStateThirst)] floatValue];

      // Update bars
      [self updateBar:self.progressBarHunger withSeverity: hungerLevel];
      [self updateBar:self.progressBarThirst withSeverity: thirstLevel];
                               
    // NSLog(@"after general inventory");

    // [self addObserverForObject: document.model keyPath: @"statesDict"];
    
    // Update body part inventories
    NSInteger bodySlotCounter = 0; // Start a global body slot counter
    for (NSString *propertyName in document.model.bodyParts.inventoryPropertyNames) {
        DSAInventory *inventory = [document.model.bodyParts valueForKey:propertyName];
        // NSLog(@"DSACharacterWindowController populateInvenotry THE BODY SLOTS: %@", propertyName);
        bodySlotCounter = [self updateInventorySlotsWithInventory:inventory
                                              inventoryIdentifier:@"body"
                                              startingSlotCounter:bodySlotCounter];
    }
  [self updateCharacterStateView];
}

- (void)replaceView:(NSView *)oldView withView:(NSView *)newView {
    NSView *superview = oldView.superview;
    NSRect frame = oldView.frame;
    newView.frame = frame;
    [oldView removeFromSuperview];
    [superview addSubview:newView positioned:NSWindowAbove relativeTo:nil];
}


- (void)updateCharacterStateView {
  DSACharacterDocument *document = (DSACharacterDocument *)self.document;
  if (self.viewCharacterStatus == nil)
    {
      self.viewCharacterStatus = [[DSACharacterStatusView alloc] init];
    }
  [self.viewCharacterStatus setCharacter: document.model];
}
- (void)updateBar:(NSProgressIndicator *)bar withSeverity:(CGFloat) severity
{
  NSLog(@"UPDATING BAR, NEW SEVERITY: %f", severity);
  if (severity < 0 || severity > 1)
    {
      NSLog(@"DSACharacterWindowController updateBar: invalid severity %f", severity);
      return;
    }

    [bar setDoubleValue: severity];
}


- (void) handleInventoryUpdate {
  [self populateInventory];
  [self updateLoadDisplay];
  [self updateArmorDisplay];
  [self updateEncumbranceDisplay];
  [self.document updateChangeCount: NSChangeDone];  
}

- (void)handleCharacterStateChange:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    if (!userInfo) return;
    DSACharacterState state = [userInfo[@"state"] integerValue];
    NSNumber *value = userInfo[@"value"];
    switch (state)
      {
        case DSACharacterStateHunger:
          [self updateBar: self.progressBarHunger withSeverity: [value doubleValue]];
          break;
        case DSACharacterStateThirst:
          [self updateBar: self.progressBarThirst withSeverity: [value doubleValue]];
          break;
        case DSACharacterStateDead:
          if ([value boolValue] == YES)
            {
              [self handleCharacterDeath];
            }
          break;          
        default:
          NSLog(@"DSACharacterWindowController don't know how to handle state change for state %@", @(state));        
      }
   [self updateCharacterStateView];
   [self.document updateChangeCount: NSChangeDone];
}                                               
                                               

- (void)handleLogsMessage:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    if (!userInfo) return;
    
    LogSeverity severity = [userInfo[@"severity"] integerValue];
    NSString *message = userInfo[@"message"];
    
    if (!message) return;

    NSLog(@"Got message: %@", message);
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

// Updates all slots in the specified inventory
- (NSInteger)updateInventorySlotsWithInventory:(DSAInventory *)inventory
                           inventoryIdentifier:(NSString *)inventoryIdentifier
                          startingSlotCounter:(NSInteger)startingSlotCounter {
    NSInteger slotCounter = startingSlotCounter;
    DSACharacterDocument *document = (DSACharacterDocument *)self.document;
    //NSLog(@"DSACharacterWindowController  updateInventorySlotsWithInventory : updateInventorySlotsWithInventory: %@", inventoryIdentifier);
    for (NSInteger i = 0; i < inventory.slots.count; i++) {
        DSASlot *slot = inventory.slots[i];
        NSString *iconName = slot.object ? [NSString stringWithFormat:@"%@-64x64", [slot.object icon]] : nil;
        NSString *imagePath = iconName ? [[NSBundle mainBundle] pathForResource:iconName ofType:@"webp"] : nil;

        // Generate the name of the slot view from the identifier
        NSString *uiName = [NSString stringWithFormat:@"%@Slot%ld", inventoryIdentifier, (long)slotCounter];
        // NSLog(@"DSACharacterWindowController Updating UI for: %@", uiName);

        // Access the slot view (already a DSAInventorySlotView)
        DSAInventorySlotView *slotView = [self valueForKey:uiName];
        if (slotView) {
            //NSLog(@"DSACharacterWindowController Found slotView for %@, updating properties", uiName);

            // Update properties directly
            slotView.slot = slot;
            slotView.slotIndex = slotCounter;
            slotView.inventoryIdentifier = inventoryIdentifier;
            slotView.item = slot.object; // Set the item in the slot
            slotView.model = document.model;
            
            // Update the image
            NSImage *image = imagePath ? [[NSImage alloc] initWithContentsOfFile:imagePath] : nil;
            slotView.image = image;

            // Set drag-and-drop configuration
            [slotView setInitiatesDrag:YES];
            [slotView registerForDraggedTypes:@[NSStringPboardType]];

            // Update the quantity label
            [slotView updateQuantityLabelWithQuantity:slot.quantity];
            [slotView updateToolTip];           
        } else {
            NSLog(@"DSACharacterWindowController: updateInventorySlotsWithInventory  Slot view %@ not found, skipping update", uiName);
        }

        // Increment the slot counter for the next slot
        slotCounter++;
    }

    // Return the updated slot counter for chaining
    return slotCounter;
}

// Helper method for setting the image for a specific slot view
- (void)updateSlotImageForSlotView:(DSAInventorySlotView *)slotView withImageNamed:(NSString *)imageName {
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageName ofType:@"webp"];
    NSImage *image = imagePath ? [[NSImage alloc] initWithContentsOfFile:imagePath] : nil;
    slotView.image = image;
}

- (void)updateLoadDisplay {
    DSACharacterDocument *document = (DSACharacterDocument *)self.document;
    if (!document.model) return;

    // Calculate the total weight from the character model
    float totalLoad = [document.model load];

    // Update the UI field with the total weight
    self.fieldLoad.stringValue = [NSString stringWithFormat:@"%.2f", totalLoad];
    
    NSLog(@"Updated load display: %.2f", totalLoad);
}
- (void)updateEncumbranceDisplay {
    DSACharacterDocument *document = (DSACharacterDocument *)self.document;
    if (!document.model) return;

    // Calculate the total weight from the character model
    float totalEncumbrance = [document.model encumbrance];

    // Update the UI field with the total weight
    self.fieldEncumbrance.stringValue = [NSString stringWithFormat:@"%.0f", totalEncumbrance];
    
    NSLog(@"Updated encumbrance display: %.0f", totalEncumbrance);
}
- (void)updateArmorDisplay {
    DSACharacterDocument *document = (DSACharacterDocument *)self.document;
    if (!document.model) return;

    // Calculate the total weight from the character model
    float totalArmor = [document.model armor];

    // Update the UI field with the total weight
    self.fieldArmor.stringValue = [NSString stringWithFormat:@"%.0f", totalArmor];
    
    NSLog(@"Updated armor display: %.0f", totalArmor);
}

- (void)populateFightingTalentsTab
{
   DSACharacterDocument *document = (DSACharacterDocument *)self.document;
   DSACharacterHero *model = (DSACharacterHero *)document.model;

   NSTabViewItem *mainTabItem = [self.tabViewMain tabViewItemAtIndex:[self.tabViewMain indexOfTabViewItemWithIdentifier:@"item 2"]];
   NSRect subTabViewFrame = mainTabItem.view ? mainTabItem.view.bounds : NSMakeRect(0, 0, 400, 300);
   NSTabView *subTabView = [[NSTabView alloc] initWithFrame:subTabViewFrame];
   [subTabView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];

   NSMutableArray *fightingTalents = [NSMutableArray array];
   NSMutableSet *fightingCategories = [NSMutableSet set];

   // Enumerate talents to find all fighting talents
   [model.talents enumerateKeysAndObjectsUsingBlock:^(id key, DSAFightingTalent *obj, BOOL *stop)
     {
        if ([[obj category] isEqualToString:@"Kampftechniken"])
          {
             [fightingTalents addObject:obj];
             [fightingCategories addObject:[obj subCategory]];
          }
     }];

   // Sort the fighting categories alphabetically
   NSArray *sortedFightingCategories = [[fightingCategories allObjects] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

   // Sort the fighting talents by subCategory
   NSSortDescriptor *nameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
   NSArray *sortedFightingTalents = [fightingTalents sortedArrayUsingDescriptors:@[nameSortDescriptor]];
        
   // Iterate through sorted categories and create tabs for them
   for (NSString *category in sortedFightingCategories)
     {
        // Filter talents that belong to the current category
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(DSAFightingTalent *evaluatedObject, NSDictionary *bindings)
          {
            return [evaluatedObject.subCategory isEqualToString:category];
          }];
        NSArray *filteredTalents = [sortedFightingTalents filteredArrayUsingPredicate:predicate];
        
        // Call the helper method to add the tab for this category
        [self addTabForCategory:category inSubTabView:subTabView withItems:filteredTalents];
     }

   // Set the subTabView for item 2
   [mainTabItem setView:subTabView];
}

- (void)populateOtherTalentsTab
{
   DSACharacterDocument *document = (DSACharacterDocument *)self.document;
   DSACharacterHero *model = (DSACharacterHero *)document.model;
   
   NSTabViewItem *mainTabItem = [self.tabViewMain tabViewItemAtIndex:[self.tabViewMain indexOfTabViewItemWithIdentifier:@"item 3"]];
   NSRect subTabViewFrame = mainTabItem.view ? mainTabItem.view.bounds : NSMakeRect(0, 0, 400, 300);
   NSTabView *subTabView = [[NSTabView alloc] initWithFrame:subTabViewFrame];
   [subTabView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
    
   NSMutableArray *otherTalents = [NSMutableArray array];
   NSMutableSet *talentCategories = [NSMutableSet set];
    
   // Enumerate talents to find all categories excluding "Kampftechniken"
   [model.talents enumerateKeysAndObjectsUsingBlock:^(id key, DSAOtherTalent *obj, BOOL *stop)
     {
        if (![[obj category] isEqualToString:@"Kampftechniken"])
          {
             [otherTalents addObject: obj];
             [talentCategories addObject: [obj category]];
          }
     }];
    
   // Sort the talent categories alphabetically
   NSArray *sortedTalentCategories = [[talentCategories allObjects] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
   // Sort the other talents by name
   NSSortDescriptor *nameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
   NSArray *sortedOtherTalents = [otherTalents sortedArrayUsingDescriptors:@[nameSortDescriptor]];
    
   // Iterate through sorted categories and create tabs for them
   for (NSString *category in sortedTalentCategories)
     {
        // Filter talents that belong to the current category
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(DSAOtherTalent *evaluatedObject, NSDictionary *bindings)
          {
            return [evaluatedObject.category isEqualToString:category];
          }];
        NSArray *filteredTalents = [sortedOtherTalents filteredArrayUsingPredicate:predicate];
        
        // Call the helper method to add the tab for this category
        [self addTabForCategory:category inSubTabView:subTabView withItems:filteredTalents];
     }
    
   // Set the subTabView for the current tab
   [mainTabItem setView:subTabView];
}

- (void)populateProfessionsTab
{
   DSACharacterDocument *document = (DSACharacterDocument *)self.document;
   DSACharacterHero *model = (DSACharacterHero *)document.model;
   NSLog(@"populateProfessionsTab");
    
   NSTabViewItem *mainTabItem = [self.tabViewMain tabViewItemAtIndex: [self.tabViewMain indexOfTabViewItemWithIdentifier:@"item 5"]];
  
   if ([model professions] == nil)
     {
        NSLog(@"don't have professions, not showing professions tab");
        [self.tabViewMain removeTabViewItem:mainTabItem];
        return;
     }
    
   NSRect subTabViewFrame = mainTabItem.view ? mainTabItem.view.bounds : NSMakeRect(0, 0, 400, 300);
   NSTabView *subTabView = [[NSTabView alloc] initWithFrame:subTabViewFrame];
   [subTabView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
  
   NSMutableArray *professions = [NSMutableArray array];
   NSMutableSet *categories = [NSMutableSet set];
  
   // Enumerate professions to find all categories
   [model.professions enumerateKeysAndObjectsUsingBlock:^(id key, DSAOtherTalent *obj, BOOL *stop)
     {
        [professions addObject: obj];
        [categories addObject: [obj category]];
     }];
  
   // Sort the categories alphabetically
   NSArray *sortedCategories = [[categories allObjects] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
   // Sort the professions by name
   NSSortDescriptor *nameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
   NSArray *sortedProfessions = [professions sortedArrayUsingDescriptors:@[nameSortDescriptor]];
    
   // Iterate through sorted categories and create tabs for them
   for (NSString *category in sortedCategories)
     {
        // Filter professions that belong to the current category
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(DSAOtherTalent *evaluatedObject, NSDictionary *bindings)
          {
             return [evaluatedObject.category isEqualToString:category];
          }];
        NSArray *filteredProfessions = [sortedProfessions filteredArrayUsingPredicate:predicate];
        
        // Call the helper method to add the tab for this category
        [self addTabForCategory:category inSubTabView:subTabView withItems:filteredProfessions];
     }
  
   // Set the subTabView for the current tab
   [mainTabItem setView:subTabView];
}

- (void)populateMagicTalentsTab
{
   DSACharacterDocument *document = (DSACharacterDocument *)self.document;
   DSACharacterHero *model = (DSACharacterHero *)document.model;
   NSTabViewItem *mainTabItem = [self.tabViewMain tabViewItemAtIndex: [self.tabViewMain indexOfTabViewItemWithIdentifier:@"item 4"]];
 
   if (model.spells == nil || [model.spells count] == 0)
     {
        NSLog(@"not being magic, not showing magic talents tab");
        [self.tabViewMain removeTabViewItem:mainTabItem];
        return;
     }
    
   NSRect subTabViewFrame = mainTabItem.view ? mainTabItem.view.bounds : NSMakeRect(0, 0, 400, 300);
   NSTabView *subTabView = [[NSTabView alloc] initWithFrame: subTabViewFrame];  
   [subTabView setAllowsTruncatedLabels: YES];
   [subTabView setControlSize:NSControlSizeSmall];
   [subTabView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
  
   NSMutableArray *spells = [NSMutableArray array];
   NSMutableSet *categories = [NSMutableSet set];
  
   // Enumerate talents to find all categories
   [model.spells enumerateKeysAndObjectsUsingBlock:^(id key, DSAOtherTalent *obj, BOOL *stop)
     {
        [spells addObject: obj];
        [categories addObject: [obj category]];
     }];
    
   // Sort spells by name
   NSSortDescriptor *nameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
   NSArray *sortedSpells = [spells sortedArrayUsingDescriptors:@[nameSortDescriptor]];
    
   // Sort categories alphabetically
   NSArray *sortedCategories = [[categories allObjects] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
   // Containers for categories that start with "Beschwörung" and "Verwandlung"
   NSMutableArray *beschwoerungCategories = [NSMutableArray array];
   NSMutableArray *verwandlungCategories = [NSMutableArray array];
    
   // Separate categories based on naming
   for (NSString *category in sortedCategories)
     {
        if ([category hasPrefix:@"Beschwörung"] || [category isEqualToString:@"Die Sieben Formeln der Zeit"])
          {
             [beschwoerungCategories addObject:category];
          }
        else if ([category hasPrefix:@"Verwandlung"])
          {
             [verwandlungCategories addObject:category];
          }
        else
          {
             // Non-grouped categories: filter spells and add tabs
             NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(DSAOtherTalent *evaluatedObject, NSDictionary *bindings)
               {
                  return [evaluatedObject.category isEqualToString:category];
               }];
             NSArray *filteredSpells = [sortedSpells filteredArrayUsingPredicate:predicate];
             [self addTabForCategory:category inSubTabView:subTabView withItems:filteredSpells];
          }
     }
    
   // Sort "Beschwörung" and "Verwandlung" categories alphabetically
   NSArray *sortedBeschwoerungCategories = [beschwoerungCategories sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
   NSArray *sortedVerwandlungCategories = [verwandlungCategories sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

   // Create grouped tabs for "Beschwörung" and "Verwandlung"
   if (sortedBeschwoerungCategories.count > 0)
     {
        [self addGroupedTabWithTitle:@"Beschwörung" categories:sortedBeschwoerungCategories inSubTabView:subTabView withSpells:sortedSpells];
     }
    
   if (sortedVerwandlungCategories.count > 0)
     {
        [self addGroupedTabWithTitle:@"Verwandlung" categories:sortedVerwandlungCategories inSubTabView:subTabView withSpells:sortedSpells];
     }
   
   // Set the subTabView for the current tab
   [mainTabItem setView:subTabView];
}


- (void)populateSpecialTalentsTab
{
   DSACharacterDocument *document = (DSACharacterDocument *)self.document;
   DSACharacterHero *model = (DSACharacterHero *)document.model;
   NSLog(@"DSACharacterWindowController: populateSpecialTalentsTab");
   NSTabViewItem *mainTabItem = [self.tabViewMain tabViewItemAtIndex: [self.tabViewMain indexOfTabViewItemWithIdentifier:@"item 6"]];
  
   if ([model specials] == nil)
     {
        NSLog(@"don't have special talents, not showing special talents tab");
        [self.tabViewMain removeTabViewItem:mainTabItem];
        return;
     }
      
   NSRect subTabViewFrame = mainTabItem.view ? mainTabItem.view.bounds : NSMakeRect(0, 0, 400, 300);
   NSTabView *subTabView = [[NSTabView alloc] initWithFrame:subTabViewFrame];
   [subTabView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
  
   NSMutableArray *specials = [NSMutableArray array];
   NSMutableSet *categories = [NSMutableSet set];

   // Enumerate special talents to find all categories
   NSLog(@"DSACharacterWindowController: populateSpecialTalentsTab before block enumeration %@", model.specials);
   
   [model.specials enumerateKeysAndObjectsUsingBlock:^(id key, DSAOtherTalent *obj, BOOL *stop)
     {
        NSLog(@"enumerating specials, found object: %@", obj);
        [specials addObject: obj];
        [categories addObject: [obj category]];
     }];
    
   // Sort specials by name
   NSLog(@"DSACharacterWindowController: populateSpecialTalentsTab after block enumeration");
   NSSortDescriptor *nameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
   NSArray *sortedSpecials = [specials sortedArrayUsingDescriptors:@[nameSortDescriptor]];
    
   // Sort categories alphabetically
   NSArray *sortedCategories = [[categories allObjects] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
   NSLog(@"populateSpecialTalentsTab before the for loop");  
   // Add a tab for each sorted category with the corresponding talents
   for (NSString *category in sortedCategories)
     {
        // Filter talents belonging to the current category
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(DSAOtherTalent *evaluatedObject, NSDictionary *bindings)
          {
            return [evaluatedObject.category isEqualToString:category];
          }];
        NSArray *filteredSpecials = [sortedSpecials filteredArrayUsingPredicate:predicate];
        
        // Add the filtered talents under the corresponding category
        [self addTabForCategory:category inSubTabView:subTabView withItems:filteredSpecials];
     }
  
   // Set the subTabView for the current tab
   NSLog(@"populateSpecialTalentsTab At the end of it");
   [mainTabItem setView:subTabView];
   NSLog(@"populateSpecialTalentsTab At the very end of it");   
}

- (void)populateBiographyTab
{
   DSACharacterDocument *document = (DSACharacterDocument *)self.document;
   DSACharacterHero *model = (DSACharacterHero *)document.model;
   NSLog(@"populateBiographyTab %@ %@", [model birthPlace], [model legitimation]);
   
   NSTabViewItem *mainTabItem = [self.tabViewMain tabViewItemAtIndex: [self.tabViewMain indexOfTabViewItemWithIdentifier:@"item 7"]];
   
   NSRect subTabViewFrame = mainTabItem.view ? mainTabItem.view.bounds : NSMakeRect(0, 0, 400, 300);
   NSTabView *subTabView = [[NSTabView alloc] initWithFrame:subTabViewFrame];
   [subTabView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
   
   // --- First Tab: "Geburt" ---
   NSTabViewItem *innerTabItem1 = [[NSTabViewItem alloc] initWithIdentifier:_(@"Geburt")];
   innerTabItem1.label = _(@"Geburt");
    
   NSFlippedView *innerView1 = [[NSFlippedView alloc] initWithFrame:subTabView.bounds];
   [innerView1 setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];

   // Create a single NSTextView to hold the merged text
   CGFloat margin = 10.0;
   CGFloat width = subTabView.bounds.size.width - 2 * margin;
   NSRect textViewFrame = NSMakeRect(margin, margin, width, subTabView.bounds.size.height - 2 * margin);
   NSTextView *textView1 = [[NSTextView alloc] initWithFrame:textViewFrame];
   [textView1 setEditable:NO];     // Make it non-editable
   [textView1 setVerticallyResizable:YES];
   [textView1 setHorizontallyResizable:NO];
   [textView1 setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
   [textView1 setBackgroundColor:[NSColor lightGrayColor]];

   // Format the text as a bulleted list
   NSString *bulletList1 = [NSString stringWithFormat:@"• %@\n• %@\n• %@\n• %@", 
                           [model birthPlace], 
                           [model birthEvent], 
                           [model legitimation],
                           [model siblingsString]];

   // Create paragraph style for proper indentation of bullet points
   NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
   CGFloat bulletIndent = 15.0;  // Space from the left edge for the first line
   CGFloat textIndent = 25.0;    // Space for wrapped lines
   [paragraphStyle setFirstLineHeadIndent:bulletIndent];   // First line indentation (after the bullet)
   [paragraphStyle setHeadIndent:textIndent];              // Indentation for subsequent wrapped lines

   // Optional: Set line spacing for better readability
   [paragraphStyle setLineSpacing:4.0];

   // Create an attributed string with the bullet points and paragraph style
   NSFont *font = [NSFont systemFontOfSize:12.0];  // Use a system font of size 10
   NSMutableAttributedString *attrString1 = [[NSMutableAttributedString alloc] initWithString:bulletList1];
   [attrString1 addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [attrString1 length])];
   [attrString1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attrString1 length])];

   // Set the text in the NSTextView
   [textView1.textStorage setAttributedString:attrString1];

   // Add the NSTextView to the innerView
   [innerView1 addSubview:textView1];

   // Set the innerView as the view for the inner tab item
   [innerTabItem1 setView:innerView1];
   [subTabView addTabViewItem:innerTabItem1];
   
   // --- Second Tab: "Kindheit" ---
   NSTabViewItem *innerTabItem2 = [[NSTabViewItem alloc] initWithIdentifier:_(@"Kindheit")];
   innerTabItem2.label = _(@"Kindheit");

   NSFlippedView *innerView2 = [[NSFlippedView alloc] initWithFrame:subTabView.bounds];
   [innerView2 setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
   
   // Create a text view for childhood events with the same layout
   NSTextView *textView2 = [[NSTextView alloc] initWithFrame:textViewFrame];
   [textView2 setEditable:NO];
   [textView2 setVerticallyResizable:YES];
   [textView2 setHorizontallyResizable:NO];
   [textView2 setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
   [textView2 setBackgroundColor:[NSColor lightGrayColor]];

   // Compose bulleted list for childhood events
   NSMutableString *childhoodBullets = [[NSMutableString alloc] init];
   for (NSString *event in [model childhoodEvents]) {
       [childhoodBullets appendFormat:@"• %@\n", event];
   }

   // Create an attributed string with the bullet points and paragraph style
   NSMutableAttributedString *attrString2 = [[NSMutableAttributedString alloc] initWithString:childhoodBullets];
   [attrString2 addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [attrString2 length])];
   [attrString2 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attrString2 length])];

   // Set the text in the NSTextView
   [textView2.textStorage setAttributedString:attrString2];
   
   // Add the text view to the second tab
   [innerView2 addSubview:textView2];
   [innerTabItem2 setView:innerView2];
   [subTabView addTabViewItem:innerTabItem2];
   
   // --- Third Tab: "Jugend" ---
   NSTabViewItem *innerTabItem3 = [[NSTabViewItem alloc] initWithIdentifier:_(@"Jugend")];
   innerTabItem3.label = _(@"Jugend");

   NSFlippedView *innerView3 = [[NSFlippedView alloc] initWithFrame:subTabView.bounds];
   [innerView3 setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
   
   // Create a text view for childhood events with the same layout
   NSTextView *textView3 = [[NSTextView alloc] initWithFrame:textViewFrame];
   [textView3 setEditable:NO];
   [textView3 setVerticallyResizable:YES];
   [textView3 setHorizontallyResizable:NO];
   [textView3 setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
   [textView3 setBackgroundColor:[NSColor lightGrayColor]];

   // Compose bulleted list for childhood events
   NSMutableString *youthBullets = [[NSMutableString alloc] init];
   for (NSString *event in [model youthEvents]) {
       [youthBullets appendFormat:@"• %@\n", event];
   }

   // Create an attributed string with the bullet points and paragraph style
   NSMutableAttributedString *attrString3 = [[NSMutableAttributedString alloc] initWithString:youthBullets];
   [attrString3 addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [attrString3 length])];
   [attrString3 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attrString3 length])];

   // Set the text in the NSTextView
   [textView3.textStorage setAttributedString:attrString3];
   
   // Add the text view to the second tab
   [innerView3 addSubview:textView3];
   [innerTabItem3 setView:innerView3];
   [subTabView addTabViewItem:innerTabItem3];
      
   // Set the subTabView for the current tab
   [mainTabItem setView:subTabView];
}

#pragma mark - Helper Methods

// Helper method to add an individual tab for a category
- (void)addTabForCategory:(NSString *)category inSubTabView:(NSTabView *)subTabView withItems:(NSArray *)items
{
  NSLog(@"addTabForCategory %@", category);
  NSTabViewItem *innerTabItem = [[NSTabViewItem alloc] initWithIdentifier:category];
  innerTabItem.label = category;
    
  NSFlippedView *innerView = [[NSFlippedView alloc] initWithFrame:subTabView.bounds];
  [innerView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];    

  NSString *categoryToCheck = nil; // To hold the category for comparison
  NSColor *fontColor;  
  NSInteger Offset = 0;
  for (DSAOtherTalent *item in items)
    {
      // Check the class type and assign categoryToCheck accordingly
      if ([item isKindOfClass:[DSAFightingTalent class]])
        {
          DSAFightingTalent *talentItem = (DSAFightingTalent *)item;
          categoryToCheck = talentItem.subCategory; // Use subCategory for this class
          fontColor = [NSColor blackColor];          
        }
      else if ([item isKindOfClass:[DSAOtherTalent class]])
        {
          DSAOtherTalent *otherTalentItem = (DSAOtherTalent *)item;
          categoryToCheck = otherTalentItem.category; // Use category for this class
          fontColor = [NSColor blackColor];          
        }
      else if ([item isKindOfClass:[DSAProfession class]])
        {
          DSAProfession *professionItem = (DSAProfession *)item;
          categoryToCheck = professionItem.category; // Use category for this class
          fontColor = [NSColor blackColor];
        }
      else if ([item isKindOfClass:[DSASpecialTalent class]])
        {
          DSASpecialTalent *specialTalentItem = (DSASpecialTalent *)item;
          categoryToCheck = specialTalentItem.category; // Use category for this class
          fontColor = [NSColor blackColor];
        } 
      else if ([item isKindOfClass:[DSALiturgy class]])
        {
          DSALiturgy *liturgyItem = (DSALiturgy *)item;
          categoryToCheck = liturgyItem.category; // Use category for this class
          fontColor = [NSColor blackColor];
        }               
      else if ([item isKindOfClass:[DSASpell class]])
        {
          DSASpell *spellItem = (DSASpell *)item;
          categoryToCheck = spellItem.category; // Use category for this class
          if ([spellItem isActiveSpell])
            {
              fontColor = [NSColor blackColor];          
            }
          else
            {
              fontColor = [NSColor redColor];
            }
        }
      else
        {
          // Handle unknown class types if necessary
          NSLog(@"Unknown item class: %@", [item class]);
          continue; // Skip unknown classes
        }
        
      if ([categoryToCheck isEqualToString:category])
        {      
          Offset += 22;
            
          NSRect fieldRect = NSMakeRect(10, Offset, 400, 20);
          NSTextField *itemField = [[NSTextField alloc] initWithFrame:fieldRect];
          [itemField setIdentifier:[NSString stringWithFormat:@"itemField%@", item]];
          [itemField setSelectable:NO];
          [itemField setEditable:NO];
          [itemField setBordered:NO];
          [itemField setBezeled:NO];
          [itemField setBackgroundColor:[NSColor lightGrayColor]];
          if ([item isMemberOfClass: [DSAFightingTalent class]])
            {
              [itemField setStringValue:[NSString stringWithFormat:@"%@ (%ld)", item.name, (signed long)item.maxUpPerLevel]];
              [itemField setTextColor: fontColor];                           
            }
          else if ([item isMemberOfClass: [DSASpecialTalent class]])
            {
              if ([(DSASpecialTalent *)item test])
                {
                  [itemField setStringValue:[NSString stringWithFormat:@"%@ (%@)", item.name, [item.test componentsJoinedByString:@"/"]]];
                }
              else
                {
                  [itemField setStringValue:[NSString stringWithFormat:@"%@", item.name]];
                }
              [itemField setTextColor: fontColor];                           
            }
          else if ([item isMemberOfClass: [DSALiturgy class]])
            {
              [itemField setStringValue:[NSString stringWithFormat:@"%@", item.name]];
              [itemField setTextColor: fontColor];
            }
          else
            {
              [itemField setStringValue:[NSString stringWithFormat:@"%@ (%@) (%ld)", item.name, [item.test componentsJoinedByString:@"/"], (signed long)item.maxUpPerLevel]];
              [itemField setTextColor: fontColor];
              if ([item isKindOfClass:[DSASpell class]])
                {
                  DSASpell *spellItem = (DSASpell *)item;
                  [self.spellItemFieldMap setObject: itemField forKey: [spellItem name]];
                  [self addObserverForObject: spellItem keyPath: @"isActiveSpell"];                                 
                }
              else
                {
                  // NSLog(@"item is kind of class: %@", [item class]);
                }              
            }

          NSFont *boldFont = [NSFont boldSystemFontOfSize:[NSFont systemFontSize]];
          [itemField setFont:boldFont];
          [innerView addSubview:itemField];
        
          if (!([item isMemberOfClass: [DSASpecialTalent class]] || [item isMemberOfClass: [DSALiturgy class]]))
            {
              NSRect fieldValueRect = NSMakeRect(420, Offset, 20, 20);
              NSTextField *itemFieldValue = [[NSTextField alloc] initWithFrame:fieldValueRect];
              [itemFieldValue setIdentifier:[NSString stringWithFormat:@"itemFieldValue%@", item]];
              [itemFieldValue setSelectable:NO];
              [itemFieldValue setEditable:NO];
              [itemFieldValue setBordered:NO];
              [itemFieldValue setBezeled:NO];
              [itemFieldValue setBackgroundColor:[NSColor lightGrayColor]];
              [itemFieldValue setStringValue: [NSString stringWithFormat: @"%ld", (signed long) item.level]];
              [itemFieldValue bind:NSValueBinding  
                          toObject:item
                       withKeyPath:@"level" 
                           options:@{NSContinuouslyUpdatesValueBindingOption: @YES, 
                                         NSValueTransformerNameBindingOption: @"RightAlignedStringTransformer"}];
              NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
              [paragraphStyle setAlignment:NSTextAlignmentRight];
              NSDictionary *attributes = @{NSParagraphStyleAttributeName: paragraphStyle};
              [itemFieldValue setAttributedStringValue:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat: @"%ld", (signed long) item.level] attributes:attributes]];
              [innerView addSubview:itemFieldValue];
            }
        }
    }
  [innerTabItem setView:innerView];
  [subTabView addTabViewItem:innerTabItem];
}


// Helper method to add a grouped tab for categories that start with "Beschwörung" or "Verwandlung"
- (void)addGroupedTabWithTitle:(NSString *)title categories:(NSArray *)categories inSubTabView:(NSTabView *)subTabView withSpells:(NSArray *)spells
{
    NSTabViewItem *groupTabItem = [[NSTabViewItem alloc] initWithIdentifier:title];
    groupTabItem.label = title;
    
    NSRect groupedTabFrame = subTabView.bounds;
    NSTabView *groupedSubTabView = [[NSTabView alloc] initWithFrame:groupedTabFrame];
    [groupedSubTabView setAllowsTruncatedLabels:YES];
    [groupedSubTabView setControlSize:NSControlSizeSmall];
    [groupedSubTabView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
    
    // Add individual tabs for each sub-category inside the grouped tab
    for (NSString *category in categories)
    {
        [self addTabForCategory:category inSubTabView:groupedSubTabView withItems:spells];
    }
    
    // Set the grouped sub-tab view as the view for the groupTabItem
    [groupTabItem setView:groupedSubTabView];
    [subTabView addTabViewItem:groupTabItem];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
  //DSACharacterDocument *document = (DSACharacterDocument *)self.document;
  //DSACharacterHero *model = (DSACharacterHero *)document.model;    
  // Get the action (selector) associated with the menu item
  // NSLog(@"DSACharacterWindowController validateMenuItem: %@ %lu", [menuItem title], (unsigned long)[menuItem tag]);
  SEL menuItemAction = [menuItem action];
    
  if (menuItemAction)
    {

    }
    
    // Default validation behavior
    return YES;
}


// KVO observer method
// to make this work, it needs: https://github.com/gnustep/libs-base/pull/444
// otherwise replace NSKeyValueChangeKey with NSString*
- (void)observeValueForKeyPath:(NSString *)keyPath 
                      ofObject:(id)object 
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change 
                       context:(void *)context
{
  NSLog(@"DSACharacterWindowController observeValueForKeyPath: %@", keyPath);
   
  if ([keyPath isEqualToString:@"adventurePoints"])
    {
      [self handleAdventurePointsChange];
    }
  else if ([keyPath isEqualToString:@"isActiveSpell"])
    {
      DSASpell *spellItem = (DSASpell *)object;
      // Get the associated itemField using the spellItem
      NSTextField *itemField = [self.spellItemFieldMap objectForKey:[spellItem name]];
      if (itemField)
        {
          BOOL isActive = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
            
          if (isActive)
            {
              [itemField setTextColor:[NSColor blackColor]];  // Active spell color
            }
          else
            {
              [itemField setTextColor:[NSColor redColor]];    // Inactive spell color
            }
        }
      else
        {
          NSLog(@"Could not find associated itemField for spellItem: %@", spellItem.name);
        }
    }
}

- (IBAction)handleAdventurePointsChange {
  DSACharacterDocument *document = (DSACharacterDocument *)self.document;
  NSLog(@"DSACharacterWindowController checking if the character can level up: %@", @([(DSACharacterHero *)document.model canLevelUp]));
  if ([(DSACharacterHero *)document.model canLevelUp])
    {
    
      NSDictionary *userInfo = @{ @"severity": @(LogSeverityHappy),
                                  @"message": [NSString stringWithFormat: @"%@ hat genug Abenteuerpunkte um in die nächste Stufe aufzusteigen.", document.model.name]
                                };
      [[NSNotificationCenter defaultCenter] postNotificationName: @"DSACharacterEventLog"
                                                          object: document.model
                                                        userInfo: userInfo];     
    
      // [self showCongratsPanel];
    }
}

- (IBAction)handleCharacterDeath {
  DSACharacterDocument *document = (DSACharacterDocument *)self.document;
  DSACharacterHero *model = (DSACharacterHero *)document.model;
  
  NSLog(@"HANDLING CHARACTER DEATH");
  
  if (!self.deadPanel)
    {
      // Load the panel from the separate .gorm file
      [NSBundle loadNibNamed:@"DSACharacterDead" owner:self];
    }
  [self.fieldCharacterDead setStringValue: [NSString stringWithFormat: @"%@ ist ins Reich Borons übergegangen.", model.name]];
  
  NSArray *imageArray = @[@"tot_1-512x512", @"tot_2-512x512"];
  NSString *imageName = [imageArray objectAtIndex: arc4random_uniform([imageArray count])];
  NSString *imagePath = [[NSBundle mainBundle] pathForResource: imageName ofType:@"webp"];
  NSImage *image = imagePath ? [[NSImage alloc] initWithContentsOfFile:imagePath] : nil;
  self.imageCharacterDead.image = image;  
  
  [self.deadPanel makeKeyAndOrderFront:nil];
  
}

- (void)showCongratsPanel
{
  DSACharacterDocument *document = (DSACharacterDocument *)self.document;
  DSACharacterHero *model = (DSACharacterHero *)document.model;
  if (!self.congratsPanel)
    {
      // Load the panel from the separate .gorm file
      [NSBundle loadNibNamed:@"DSACharacterLevelUp" owner:self];
    }
  // Set the font size of the fieldCongratsHeadline
  NSFont *currentFont = [self.fieldCongratsHeadline font];
  NSFont *biggerFont = [[NSFontManager sharedFontManager] convertFont:currentFont toSize:20.0]; // Set size to 20
  [self.fieldCongratsHeadline setFont:biggerFont];    
  [self.fieldCongratsMainText setStringValue: [NSString stringWithFormat: @"%@ hat soeben eine neue Stufe erreicht.", model.name]];
  [self.fieldCongratsMainTextLine2 setStringValue: _(@"Möchtest du jetzt steigern, oder später?")];
  [self.congratsPanel makeKeyAndOrderFront:nil];

  [self.buttonCongratsLater setHidden:NO];
  [self.buttonCongratsNow setTarget:self];
  [self.buttonCongratsNow setTitle: _(@"Jetzt")];
  [self.buttonCongratsNow setAction:@selector(levelUpBaseValues:)]; 
}

- (void)levelUpBaseValues:(id)sender
{
  DSACharacterDocument *document = (DSACharacterDocument *)self.document;
  DSACharacterHero *model = (DSACharacterHero *)document.model;
  // we may jump in here from the main menu
  if (!self.congratsPanel)
    {
      // Load the panel from the separate .gorm file
      [NSBundle loadNibNamed:@"DSACharacterLevelUp" owner:self];
    }
    
  // yes, we want to start that process NOW
  [model prepareLevelUp];
  [document updateChangeCount:NSChangeDone];
  
  // we don't need the congrats panel for now
  [self.congratsPanel close];
  
  // At initial character creation, we jump over raising base value
  // at all other levels, we do so...
  if (model.level == 0)
    {
      NSLog(@"going to call showLevelUpPositiveTraits!");
      [self showLevelUpPositiveTraits:nil];
      return;
    }  
   
  NSLog(@"Leveling up base energies and points...");
 
  NSDictionary *result = [model levelUpBaseEnergies];
  
  if ([result objectForKey: @"deltaLpAe"])
    {
      // we have a character that uses a single dice to roll LP and AE
      // and the user to decide, how to distribute it...
      [self showQuestionRegardingPointsDistribution: result];
      return;
    }
  
  NSString *resultingText = [[NSString alloc] init];
  
  if ([model isMagic])
    {
      resultingText = [NSString stringWithFormat: 
                       @"%@ hat die Lebensenergie um %@ und die Astralenergie um %@ gesteigert", 
                       model.name,
                       [result objectForKey: @"deltaLifePoints"], 
                       [result objectForKey: @"deltaAstralEnergy"]];
    }
  else if ([model isBlessedOne])
    {
      resultingText = [NSString stringWithFormat: 
                       @"%@ hat die Lebensenergie um %@ und die Karmaenergie um %@ gesteigert", 
                       model.name,
                       [result objectForKey: @"deltaLifePoints"], 
                       [result objectForKey: @"deltaKarmaPoints"]];    
    }
  else
    {
      resultingText = [NSString stringWithFormat: 
                       @"%@ hat die Lebensenergie um %@ gesteigert", 
                       model.name,
                       [result objectForKey: @"deltaLifePoints"]];    
    }
  [self.fieldCongratsMainTextLine2 setStringValue: resultingText];
  [self.buttonCongratsLater setHidden:YES];    

  [self.buttonCongratsNow setTarget:self];
  [self.buttonCongratsNow setAction:@selector(showLevelUpPositiveTraits:)];
  [self.buttonLevelUpDoIt setTitle: _(@"Weiter")];
  [self.congratsPanel makeKeyAndOrderFront:nil]; 
}

- (IBAction)showQuestionRegardingPointsDistribution:(id)sender
{
  DSACharacterDocument *document = (DSACharacterDocument *)self.document;
  DSACharacterHero *model = (DSACharacterHero *)document.model;

  if (!self.levelUpPanel)
    {
      // Load the panel from the separate .gorm file
      NSLog(@"showLevelUpPositiveTraits loading DSACharacterLevelUp.gorm");
      [NSBundle loadNibNamed:@"DSACharacterLevelUp" owner:self];
    }
  // Set the font size of the fieldCongratsHeadline
  NSFont *currentFont = [self.fieldLevelUpHeadline font];
  NSFont *biggerFont = [[NSFontManager sharedFontManager] convertFont:currentFont toSize:20.0]; // Set size to 20
  [self.fieldLevelUpHeadline setFont:biggerFont];    
  [self.fieldLevelUpHeadline setStringValue: @"Lebenspunkte und Astralenergie verteilen"];
  [self.fieldLevelUpHeadline.cell setLineBreakMode:NSLineBreakByWordWrapping];
  [self.fieldLevelUpHeadline.cell setUsesSingleLineMode:NO];
  if ([sender isKindOfClass: [NSDictionary class]])
    {
      if ([[(NSDictionary *)sender allKeys] containsObject: @"deltaLifePoints"] && [[(NSDictionary *)sender objectForKey: @"deltaLifePoints"] integerValue] > 0)
        {
          [self.fieldLevelUpMainText setStringValue: 
                       [NSString stringWithFormat: _(@"%@ hat %@ Lebenspunkte erhalten und kann weitere %ld Punkte auf Lebenspunkte und Astralenergie verteilen. Wieviele davon sollen auf Lebenspunkte verwendet werden?"),
                       model.name, [(NSDictionary *)sender objectForKey: @"deltaLifePoints"], model.tempDeltaLpAe ]];        
        }
      else
        {
          [self.fieldLevelUpMainText setStringValue: 
                           [NSString stringWithFormat: _(@"%@ kann %ld Punkte auf Lebenspunkte und Astralenergie verteilen. Wieviele davon sollen auf Lebenspunkte verwendet werden?"),
                           model.name, model.tempDeltaLpAe ]];        
        }
    }
  else
    {
      [self.fieldLevelUpMainText setStringValue: 
                       [NSString stringWithFormat: _(@"%@ kann %ld Punkte auf Lebenspunkte und Astralenergie verteilen. Wieviele davon sollen auf Lebenspunkte verwendet werden?"),
                       model.name, model.tempDeltaLpAe ]];
     }
  [self.popupLevelUpTop removeAllItems];                       
  for (NSInteger i = 0; i <= model.tempDeltaLpAe; i++)
    {
      [self.popupLevelUpTop addItemWithTitle: [NSString stringWithFormat: @"%li", i]];
    }
  [self.popupLevelUpTop setEnabled: YES];                        

  [self.popupLevelUpBottom setHidden: YES];  
  [self.fieldLevelUpFeedback setHidden: YES];
  [self.fieldLevelUpTrialsCounter setHidden: YES];  
  [self.buttonLevelUpDoIt setTarget:self];
  [self.buttonLevelUpDoIt setAction:@selector(distributeLpAe:)]; 
  [self.buttonLevelUpDoIt setTitle: _(@"Auswählen")];  
  [self.levelUpPanel makeKeyAndOrderFront:nil];  
}

- (IBAction) distributeLpAe:(id)sender
{
  DSACharacterDocument *document = (DSACharacterDocument *)self.document;
  DSACharacterHero *model = (DSACharacterHero *)document.model;
  
  model.lifePoints = model.lifePoints + [self.popupLevelUpTop integerValue];
  model.currentLifePoints = model.currentLifePoints + [self.popupLevelUpTop integerValue];
  model.astralEnergy = model.astralEnergy + model.tempDeltaLpAe - [self.popupLevelUpTop integerValue];
  model.currentAstralEnergy = model.currentAstralEnergy + model.tempDeltaLpAe - [self.popupLevelUpTop integerValue];
  model.tempDeltaLpAe = 0;
  
  [self showLevelUpPositiveTraits: nil];
  
}

// Action when the "Level Up" menu item is clicked
- (IBAction)showLevelUpPositiveTraits:(id)sender
{
  NSLog(@"showLevelUpPositiveTraits called");
  if (!self.levelUpPanel)
    {
      [NSBundle loadNibNamed:@"DSACharacterLevelUp" owner:self];
    }
  // Set the font size of the fieldCongratsHeadline
  NSFont *currentFont = [self.fieldLevelUpHeadline font];
  NSFont *biggerFont = [[NSFontManager sharedFontManager] convertFont:currentFont toSize:20.0]; // Set size to 20
  [self.fieldLevelUpHeadline setFont:biggerFont];
  [self.fieldLevelUpHeadline setStringValue: _(@"Positive Eigenschaft erhöhen")];
  [self.fieldLevelUpMainText setStringValue: _(@"Eigenschaft auswählen")];
 
  [self.popupLevelUpTop setEnabled: YES];
  [self.popupLevelUpTop removeAllItems];
  [self.popupLevelUpTop addItemsWithTitles: @[
                             _(@"Mut"),
                             _(@"Klugheit"),
                             _(@"Intuition"),
                             _(@"Charisma"),
                             _(@"Fingerfertigkeit"),
                             _(@"Gewandheit"),
                             _(@"Körperkraft")]];

  [self.fieldLevelUpFeedback setHidden: YES];
  [self.fieldLevelUpTrialsCounter setHidden: YES];                                                            
  [self.popupLevelUpBottom setHidden: YES];  
  [self.buttonLevelUpDoIt setTarget:self];
  [self.buttonLevelUpDoIt setAction:@selector(levelUpPositiveTraits:)];
  [self.levelUpPanel makeKeyAndOrderFront:nil];
  [self.congratsPanel close];
  //[[sender window] close];
}

- (void)levelUpPositiveTraits:(id)sender {
    NSLog(@"Leveling up positive traits...");
    // Your logic to handle leveling up positive traits goes here
    
    DSACharacterDocument *document = (DSACharacterDocument *)self.document;
    DSACharacterHero *model = (DSACharacterHero *)document.model;
    
    //[model levelUpBaseEnergies]; Hell, why was this in here???
    
    NSString *selectedTrait = [[self.popupLevelUpTop selectedItem] title];

    [self.popupLevelUpTop setEnabled: NO];
    BOOL result = NO;
    if ([selectedTrait isEqualTo: _(@"Mut")])
      {
        result = [model levelUpPositiveTrait: @"MU"];
      }
    else if ([selectedTrait isEqualTo: _(@"Klugheit")])
      {
        result = [model levelUpPositiveTrait: @"KL"];
      }
    else if ([selectedTrait isEqualTo: _(@"Intuition")])
      {
        result = [model levelUpPositiveTrait: @"IN"];
      }
    else if ([selectedTrait isEqualTo: _(@"Charisma")])
      {
        result = [model levelUpPositiveTrait: @"CH"];
      }
    else if ([selectedTrait isEqualTo: _(@"Fingerfertigkeit")])
      {
        result = [model levelUpPositiveTrait: @"FF"];
      }
    else if ([selectedTrait isEqualTo: _(@"Gewandheit")])
      {
        result = [model levelUpPositiveTrait: @"GE"];
      }
    else if ([selectedTrait isEqualTo: _(@"Körperkraft")])
      {
        result = [model levelUpPositiveTrait: @"KK"];
      }                              
      
  if (result)
    {
      [self.fieldLevelUpFeedback setStringValue: _(@"Geschafft!")];
      [self.fieldLevelUpFeedback setHidden: NO];
    }
  else
    {
      [self.fieldLevelUpFeedback setStringValue: _(@"Leider nicht geschafft.")];
      [self.fieldLevelUpFeedback setHidden: NO];    
    }
  [self.buttonLevelUpDoIt setTarget:self];
  [self.buttonLevelUpDoIt setAction:@selector(showLevelDownNegativeTraits:)]; 
  [self.buttonLevelUpDoIt setTitle: _(@"Weiter")];    
}

// Action when the "Level Up" menu item is clicked
- (IBAction)showLevelDownNegativeTraits:(id)sender
{
  NSLog(@"showLevelDownNegativeTraits");
  if (!self.levelUpPanel)
    {
      // Load the panel from the separate .gorm file
      [NSBundle loadNibNamed:@"DSACharacterLevelUp" owner:self];
    }
  // Set the font size of the fieldCongratsHeadline
  NSFont *currentFont = [self.fieldLevelUpHeadline font];
  NSFont *biggerFont = [[NSFontManager sharedFontManager] convertFont:currentFont toSize:20.0]; // Set size to 20
  [self.fieldLevelUpHeadline setFont:biggerFont];
  [self.fieldLevelUpHeadline setStringValue: _(@"Negative Eigenschaft senken")];
  [self.fieldLevelUpMainText setStringValue: _(@"Eigenschaft auswählen")];
 
  [self.popupLevelUpTop setEnabled: YES];
  [self.popupLevelUpTop removeAllItems];
  [self.popupLevelUpTop addItemsWithTitles: @[
                             _(@"Aberglaube"),
                             _(@"Höhenangst"),
                             _(@"Raumangst"),
                             _(@"Totenangst"),
                             _(@"Neugier"),
                             _(@"Goldgier"),
                             _(@"Jähzorn")]];
                             
  [self.fieldLevelUpFeedback setHidden: YES];
  [self.fieldLevelUpTrialsCounter setHidden: YES];                                                            
  [self.popupLevelUpBottom setHidden: YES];  
  [self.buttonLevelUpDoIt setTarget:self];
  [self.buttonLevelUpDoIt setAction:@selector(levelDownNegativeTraits:)]; 
  [self.buttonLevelUpDoIt setTitle: _(@"Senken")];    
  [self.levelUpPanel makeKeyAndOrderFront:nil];                         
}


- (void)levelDownNegativeTraits:(id)sender {
    NSLog(@"Leveling down negative traits...");
    // Your logic to handle leveling up positive traits goes here
    
    DSACharacterDocument *document = (DSACharacterDocument *)self.document;
    DSACharacterHero *model = (DSACharacterHero *)document.model;
    NSString *selectedTrait = [[self.popupLevelUpTop selectedItem] title];

    [self.popupLevelUpTop setEnabled: NO];
    BOOL result = NO;
    if ([selectedTrait isEqualTo: _(@"Aberglaube")])
      {
        result = [model levelDownNegativeTrait: @"AG"];
      }
    else if ([selectedTrait isEqualTo: _(@"Höhenangst")])
      {
        result = [model levelDownNegativeTrait: @"HA"];
      }
    else if ([selectedTrait isEqualTo: _(@"Raumangst")])
      {
        result = [model levelDownNegativeTrait: @"RA"];
      }
    else if ([selectedTrait isEqualTo: _(@"Totenangst")])
      {
        result = [model levelDownNegativeTrait: @"TA"];
      }
    else if ([selectedTrait isEqualTo: _(@"Neugier")])
      {
        result = [model levelDownNegativeTrait: @"NG"];
      }
    else if ([selectedTrait isEqualTo: _(@"Goldgier")])
      {
        result = [model levelDownNegativeTrait: @"GG"];
      }
    else if ([selectedTrait isEqualTo: _(@"Jähzorn")])
      {
        result = [model levelDownNegativeTrait: @"JZ"];
      }                              
      
  if (result)
    {
      [self.fieldLevelUpFeedback setStringValue: _(@"Geschafft!")];
      [self.fieldLevelUpFeedback setHidden: NO];
    }
  else
    {
      [self.fieldLevelUpFeedback setStringValue: _(@"Leider nicht geschafft.")];
      [self.fieldLevelUpFeedback setHidden: NO];    
    }
  [self.buttonLevelUpDoIt setTarget:self];
  [self.buttonLevelUpDoIt setAction:@selector(showQuestionRegardingVariableTries:)]; 
  [self.buttonLevelUpDoIt setTitle: _(@"Weiter")];      
}

- (IBAction)showQuestionRegardingVariableTries:(id)sender
{
  DSACharacterDocument *document = (DSACharacterDocument *)self.document;
  DSACharacterHero *model = (DSACharacterHero *)document.model;
  if (model.maxLevelUpVariableTries == 0)
    {
    
      NSLog(@"DSACharacterWindowController showQuestionRegardingVariableTries maxLevelUpVariableTries WAS 0");
    
      // nothing to ask, just copy over the values
      // but there might be archetypes out there, that may have a penalty on first level up talent tries, i.e. warrior
      if (model.firstLevelUpTalentTriesPenalty != 0)
        {
          model.maxLevelUpTalentsTriesTmp = model.maxLevelUpTalentsTries + model.firstLevelUpTalentTriesPenalty;
          model.firstLevelUpTalentTriesPenalty = 0;
        }
      else
        {
          model.maxLevelUpTalentsTriesTmp = model.maxLevelUpTalentsTries;
        }
      model.maxLevelUpSpellsTriesTmp = model.maxLevelUpSpellsTries;
      [self showLevelUpTalents: nil];
      return;
    }
  else
    {
      NSLog(@"DSACharacterWindowController showQuestionRegardingVariableTries maxLevelUpVariableTries WAS NOT 0");    
      [self.fieldLevelUpHeadline setStringValue: @"Steigerungsversuche verteilen"];
//      [self.fieldLevelUpMainText setAllowsMultipleLines: YES];      
      [self.fieldLevelUpHeadline.cell setLineBreakMode:NSLineBreakByWordWrapping];
      [self.fieldLevelUpHeadline.cell setUsesSingleLineMode:NO];
      [self.fieldLevelUpMainText setStringValue: 
                       [NSString stringWithFormat: @"%@ kann %ld Steigerungsversuche auf Talent oder Zaubersteigerungen verteilen. Wieviele davon sollen auf Talente verwendet werden?",
                       model.name, model.maxLevelUpVariableTries ]];
      [self.popupLevelUpTop removeAllItems];                       
      for (NSInteger i = 0; i <= model.maxLevelUpVariableTries; i++)
        {
          [self.popupLevelUpTop addItemWithTitle: [NSString stringWithFormat: @"%li", i]];
        }
      [self.popupLevelUpTop setEnabled: YES];                        
    }
  [self.popupLevelUpBottom setHidden: YES];  
  [self.fieldLevelUpFeedback setHidden: YES];
  [self.fieldLevelUpTrialsCounter setHidden: YES];  
  [self.buttonLevelUpDoIt setTarget:self];
  [self.buttonLevelUpDoIt setAction:@selector(distributeTalentTries:)]; 
  [self.buttonLevelUpDoIt setTitle: _(@"Auswählen")];  
  [self.levelUpPanel makeKeyAndOrderFront:nil];  
}

- (IBAction)distributeTalentTries:(id)sender
{
  DSACharacterDocument *document = (DSACharacterDocument *)self.document;
  DSACharacterHero *model = (DSACharacterHero *)document.model;
  
  model.maxLevelUpTalentsTriesTmp = model.maxLevelUpTalentsTries + [[[self.popupLevelUpTop selectedItem] title] integerValue];
  model.maxLevelUpSpellsTriesTmp = model.maxLevelUpSpellsTries + model.maxLevelUpVariableTries -[[[self.popupLevelUpTop selectedItem] title] integerValue];
  [self showLevelUpTalents: nil];
}

- (IBAction)showLevelUpTalents:(id)sender
{
    NSLog(@"showLevelUpTalents");
    DSACharacterDocument *document = (DSACharacterDocument *)self.document;
    DSACharacterHero *model = (DSACharacterHero *)document.model;
    
    if (!self.levelUpPanel)
    {
        // Load the panel from the separate .gorm file
        [NSBundle loadNibNamed:@"DSACharacterLevelUp" owner:self];
    }
    
    // Set the font size of the fieldCongratsHeadline
    NSFont *currentFont = [self.fieldLevelUpHeadline font];
    NSFont *biggerFont = [[NSFontManager sharedFontManager] convertFont:currentFont toSize:20.0]; // Set size to 20
    [self.fieldLevelUpHeadline setFont:biggerFont];
    [self.fieldLevelUpHeadline setStringValue: _(@"Talente steigern")];
    [self.fieldLevelUpMainText setStringValue: _(@"Talent auswählen")];

    // Collect talent and spell categories
    NSMutableSet *talentCategories = [NSMutableSet set];
    NSMutableSet *spellCategories = [NSMutableSet set];  // For magical dabblers

    // Enumerate talents to find all categories
    [model.talents enumerateKeysAndObjectsUsingBlock:^(id key, DSAOtherTalent *obj, BOOL *stop) {
        [talentCategories addObject: [obj category]];
    }];

    // Enumerate spells to find all categories
    [model.spells enumerateKeysAndObjectsUsingBlock:^(id key, DSASpell *obj, BOOL *stop) {
        [spellCategories addObject: [obj category]];
    }];

    // Sort talentCategories and spellCategories alphabetically
    NSArray *sortedTalentCategories = [[talentCategories allObjects] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *sortedSpellCategories = [[spellCategories allObjects] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

    // Configure the popup menu
    [self.popupLevelUpTop setEnabled: YES];
    [self.popupLevelUpTop removeAllItems];
    
    // Add sorted talent categories
    [self.popupLevelUpTop addItemsWithTitles: sortedTalentCategories];
    
    // Add sorted spell categories (if any)
    if (sortedSpellCategories.count > 0 && [model isMagicalDabbler])
    {
        [self.popupLevelUpTop addItemsWithTitles: sortedSpellCategories];
    }

    // Set action for the popup
    [self.popupLevelUpTop setTarget:self];
    [self.popupLevelUpTop setAction:@selector(populateLevelUpBottomPopupWithTalents:)];

    [self.popupLevelUpBottom setHidden: NO];
    [self.popupLevelUpBottom setEnabled: YES];
    [self.popupLevelUpBottom setAutoenablesItems: NO];
    
    // Populate the bottom popup
    [self populateLevelUpBottomPopupWithTalents: nil];

    // Other UI configurations
    [self.fieldLevelUpFeedback setHidden: YES];
    [self.fieldLevelUpTrialsCounter setHidden: NO];
    [self.fieldLevelUpTrialsCounter setStringValue: [NSString stringWithFormat: @"Verbleibende Versuche: %ld", (signed long)model.maxLevelUpTalentsTriesTmp]];

    [self.buttonLevelUpDoIt setTarget:self];
    [self.buttonLevelUpDoIt setAction:@selector(levelUpTalent:)];
    [self.buttonLevelUpDoIt setTitle: _(@"Steigern")];
  
    [self.levelUpPanel makeKeyAndOrderFront:nil];
}

- (void)populateLevelUpBottomPopupWithTalents:(id)sender
{
    NSLog(@"populateLevelUpBottomPopupWithTalents called");
    DSACharacterDocument *document = (DSACharacterDocument *)self.document;
    DSACharacterHero *model = (DSACharacterHero *)document.model;  
    NSString *talentCategory = [[self.popupLevelUpTop selectedItem] title];
    
    // Store the previously selected item
    NSString *selectedItemTitle = [[self.popupLevelUpBottom selectedItem] title];
    
    // Remove all current items
    [self.popupLevelUpBottom removeAllItems];
    
    // Create arrays to hold sorted talents and spells
    NSMutableArray *sortedTalents = [NSMutableArray array];
    NSMutableArray *sortedSpells = [NSMutableArray array];
    
    // Collect talents in the given category
    [model.talents enumerateKeysAndObjectsUsingBlock:^(id key, DSAOtherTalent *obj, BOOL *stop) {
        if ([[obj category] isEqualTo: talentCategory]) {
            [sortedTalents addObject: obj];
        }
    }];
    
    // Collect spells in the given category (for magical dabblers)
    [model.spells enumerateKeysAndObjectsUsingBlock:^(id key, DSASpell *obj, BOOL *stop) {
        if ([[obj category] isEqualTo: talentCategory]) {
            [sortedSpells addObject: obj];
        }
    }];
    
    // Sort talents and spells alphabetically by their name
    NSArray *sortedTalentNames = [sortedTalents sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]];
    NSArray *sortedSpellNames = [sortedSpells sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]];
    
    // Add sorted talents to the popup
    for (DSAOtherTalent *talent in sortedTalentNames) {
        [self.popupLevelUpBottom addItemWithTitle:[talent name]];
        if ([model canLevelUpTalent:[model.talents objectForKey:[talent name]]]) {
            [[self.popupLevelUpBottom itemWithTitle:[talent name]] setEnabled:YES];
        } else {
            [[self.popupLevelUpBottom itemWithTitle:[talent name]] setEnabled:NO];
        }
    }
    
    // Add sorted spells to the popup (if applicable)
    for (DSASpell *spell in sortedSpellNames) {
        [self.popupLevelUpBottom addItemWithTitle:[spell name]];
        if ([model canLevelUpTalent:[model.spells objectForKey:[spell name]]]) {
            [[self.popupLevelUpBottom itemWithTitle:[spell name]] setEnabled:YES];
        } else {
            [[self.popupLevelUpBottom itemWithTitle:[spell name]] setEnabled:NO];
        }
    }
    
    // Try to re-select the previously selected item
    [self.popupLevelUpBottom selectItemWithTitle:selectedItemTitle];
    
    // If the selected item is disabled, select the first enabled item
    if (![[self.popupLevelUpBottom selectedItem] isEnabled]) {
        for (NSInteger i = 0; i < [self.popupLevelUpBottom numberOfItems]; i++) {
            if ([[self.popupLevelUpBottom itemAtIndex:i] isEnabled]) {
                [self.popupLevelUpBottom selectItemAtIndex:i];
                break;
            }
        }
    }
    
    // Update the popup button's display
    [self.popupLevelUpBottom setNeedsDisplay:YES];    
}

- (void)levelUpTalent:(id)sender
{
  DSACharacterDocument *document = (DSACharacterDocument *)self.document;
  DSACharacterHero *model = (DSACharacterHero *)document.model;
  BOOL result = NO;
  
  if ([[model.talents allKeys] containsObject: [[self.popupLevelUpBottom selectedItem] title]])
    {
      result = [model levelUpTalent: [model.talents objectForKey: [[self.popupLevelUpBottom selectedItem] title]]];
    }
  else
    { // special case the magical dabbler here, spells are considered as talents
      result = [model levelUpTalent: [model.spells objectForKey: [[self.popupLevelUpBottom selectedItem] title]]];    
    }
  
  if (result)
    {
      [self.fieldLevelUpFeedback setStringValue: _(@"Geschafft!")];
      [self.fieldLevelUpFeedback setHidden: NO];
    }
  else
    {
      [self.fieldLevelUpFeedback setStringValue: _(@"Leider nicht geschafft.")];
      [self.fieldLevelUpFeedback setHidden: NO];    
    }
  [self.fieldLevelUpTrialsCounter setStringValue: [NSString stringWithFormat: @"Verbleibende Versuche: %ld", (signed long)model.maxLevelUpTalentsTriesTmp]];
  [self populateLevelUpBottomPopupWithTalents: nil];
  if (model.maxLevelUpTalentsTriesTmp == 0)
    {
      [self.popupLevelUpTop setEnabled: NO];
      [self.popupLevelUpBottom setEnabled: NO];
      [self.buttonLevelUpDoIt setTarget:self];
      if ([model isMagic])
        {
          [self.buttonLevelUpDoIt setTitle: _(@"Weiter")]; 
          [self.buttonLevelUpDoIt setAction:@selector(showLevelUpSpells:)];  
        }
      else
        {
          [self.buttonLevelUpDoIt setTitle: _(@"Fertig")];
          [self.buttonLevelUpDoIt setAction:@selector(finishLevelUp:)];
        }
    }
}

- (IBAction)showLevelUpSpells:(id)sender
{
    NSLog(@"showLevelUpSpells called");
    DSACharacterDocument *document = (DSACharacterDocument *)self.document;
    DSACharacterHero *model = (DSACharacterHero *)document.model;  
    
    if (![model isMagic])
    {
        [self finishLevelUp:self];
        return;
    }

    if (!self.levelUpPanel)
    {
        // Load the panel from the separate .gorm file
        [NSBundle loadNibNamed:@"DSACharacterLevelUp" owner:self];
    }

    // Set the font size of the fieldCongratsHeadline
    NSFont *currentFont = [self.fieldLevelUpHeadline font];
    NSFont *biggerFont = [[NSFontManager sharedFontManager] convertFont:currentFont toSize:20.0]; // Set size to 20
    [self.fieldLevelUpHeadline setFont:biggerFont];
    [self.fieldLevelUpHeadline setStringValue: _(@"Zauberfertigkeiten steigern")];
    [self.fieldLevelUpMainText setStringValue: _(@"Spruch auswählen")];

    // Collect spell categories
    NSMutableSet *spellCategories = [NSMutableSet set];
    
    // Enumerate spells to find all categories
    [model.spells enumerateKeysAndObjectsUsingBlock:^(id key, DSASpell *obj, BOOL *stop) {
        [spellCategories addObject: [obj category]];
    }];

    // there are characters out there, that have specials, that level up together with spells
    SEL levelUpSpecialsWithSpellsSelector = @selector(levelUpSpecialsWithSpells);
    if ([model respondsToSelector:levelUpSpecialsWithSpellsSelector])
      {
        BOOL shouldLevelUpSpecialsWithSpells = ((BOOL (*)(id, SEL))[model methodForSelector:levelUpSpecialsWithSpellsSelector])(model, levelUpSpecialsWithSpellsSelector);
        if (shouldLevelUpSpecialsWithSpells)
          {
            [model.specials enumerateKeysAndObjectsUsingBlock:^(id key, DSASpell *obj, BOOL *stop)
              {
                [spellCategories addObject: [obj category]];
              }];           
          }
      }    

    // Sort spellCategories alphabetically
    NSArray *sortedSpellCategories = [[spellCategories allObjects] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

    // Configure the popup menu with sorted spell categories
    [self.popupLevelUpTop setEnabled:YES];
    [self.popupLevelUpTop removeAllItems];
    [self.popupLevelUpTop addItemsWithTitles:sortedSpellCategories];
    [self.popupLevelUpTop setTarget:self];
    [self.popupLevelUpTop setAction:@selector(populateLevelUpBottomPopupWithSpells:)];

    [self.popupLevelUpBottom setHidden:NO];
    [self.popupLevelUpBottom setEnabled:YES];
    [self.popupLevelUpBottom setAutoenablesItems:NO];
    [self populateLevelUpBottomPopupWithSpells:nil];

    // Other UI configurations
    [self.fieldLevelUpFeedback setHidden:YES];
    [self.fieldLevelUpTrialsCounter setHidden:NO];
    [self.fieldLevelUpTrialsCounter setStringValue:[NSString stringWithFormat:@"Verbleibende Versuche: %ld", (signed long)model.maxLevelUpSpellsTriesTmp]];

    [self.buttonLevelUpDoIt setTarget:self];
    [self.buttonLevelUpDoIt setAction:@selector(levelUpSpell:)];
    [self.buttonLevelUpDoIt setTitle:_(@"Steigern")];

    [self.levelUpPanel makeKeyAndOrderFront:nil];
}

- (void)populateLevelUpBottomPopupWithSpells:(id)sender
{
    NSLog(@"populateLevelUpBottomPopupWithSpells called");
    DSACharacterDocument *document = (DSACharacterDocument *)self.document;
    DSACharacterHero *model = (DSACharacterHero *)document.model;
    NSString *spellCategory = [[self.popupLevelUpTop selectedItem] title];
    
    // Store the previously selected item
    NSString *selectedItemTitle = [[self.popupLevelUpBottom selectedItem] title];
    
    // Remove all current items
    [self.popupLevelUpBottom removeAllItems];
    
    // Create an array to hold sorted spells
    NSMutableArray *spells = [NSMutableArray array];
    NSMutableArray *specials = [NSMutableArray array];
    
    // Collect spells that match the selected category
    [model.spells enumerateKeysAndObjectsUsingBlock:^(id key, DSASpell *obj, BOOL *stop)
      {
        if ([[obj category] isEqualTo: spellCategory])
          {
            [spells addObject: obj];
          }
      }];
    NSArray *sortedSpells = [spells sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]];
    
    // there are characters out there, that have specials, that level up together with spells
    SEL levelUpSpecialsWithSpellsSelector = @selector(levelUpSpecialsWithSpells);
    if ([model respondsToSelector:levelUpSpecialsWithSpellsSelector])
      {
        BOOL shouldLevelUpSpecialsWithSpells = ((BOOL (*)(id, SEL))[model methodForSelector:levelUpSpecialsWithSpellsSelector])(model, levelUpSpecialsWithSpellsSelector);
        if (shouldLevelUpSpecialsWithSpells)
          {
            [model.specials enumerateKeysAndObjectsUsingBlock:^(id key, DSASpell *obj, BOOL *stop)
              {
                if ([[obj category] isEqualTo: spellCategory])
                  {
                    [specials addObject: obj];
                  }
              }];            
          }
      }

    // Sort the spells alphabetically by their name
    NSArray *sortedSpecials = [specials sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]];
    // Add sorted spells to the popup
    for (DSASpell *spell in sortedSpells) {
        [self.popupLevelUpBottom addItemWithTitle:[spell name]];
        SEL canLevelUpSpell = @selector(canLevelUpSpell:);
        if ([model respondsToSelector: canLevelUpSpell]) {
            BOOL (*func)(id, SEL, DSASpell *) = (void *)objc_msgSend;
            if (func(model, canLevelUpSpell, [model.spells objectForKey:[spell name]])) {
                [[self.popupLevelUpBottom itemWithTitle:[spell name]] setEnabled:YES];
            } else {
                [[self.popupLevelUpBottom itemWithTitle:[spell name]] setEnabled:NO];
            }
        }
    }
    // add eventual sorted specials to the popup as well
    for (DSASpell *special in sortedSpecials) {
        [self.popupLevelUpBottom addItemWithTitle:[special name]];
        SEL canLevelUpSpell = @selector(canLevelUpSpell:);
        if ([model respondsToSelector: canLevelUpSpell]) {
            BOOL (*func)(id, SEL, DSASpell *) = (void *)objc_msgSend;
            if (func(model, canLevelUpSpell, [model.specials objectForKey:[special name]])) {
                [[self.popupLevelUpBottom itemWithTitle:[special name]] setEnabled:YES];
            } else {
                [[self.popupLevelUpBottom itemWithTitle:[special name]] setEnabled:NO];
            }
        }
    }
    
        
    // Try to re-select the previously selected item
    [self.popupLevelUpBottom selectItemWithTitle:selectedItemTitle];
    
    // If the selected item is disabled, select the first enabled item
    if (![[self.popupLevelUpBottom selectedItem] isEnabled]) {
        for (NSInteger i = 0; i < [self.popupLevelUpBottom numberOfItems]; i++) {
            if ([[self.popupLevelUpBottom itemAtIndex:i] isEnabled]) {
                [self.popupLevelUpBottom selectItemAtIndex:i];
                break;
            }
        }
    }
    
    // Update the popup button's display
    [self.popupLevelUpBottom setNeedsDisplay:YES];
}

- (void)levelUpSpell:(id)sender
{
  DSACharacterDocument *document = (DSACharacterDocument *)self.document;
  DSACharacterHero *model = (DSACharacterHero *)document.model;
  NSString *spell = [[self.popupLevelUpBottom selectedItem] title];
  NSLog(@"DSACharacterWindowController levelUpSpell: %@", spell);
  BOOL result;
  
  SEL levelUpSpell = @selector(levelUpSpell:);
  
  if ([model respondsToSelector: levelUpSpell])
    {
      // first have to find out, if there are special talents that might be dealt with like spells as well
      BOOL shouldLevelUpSpecialsWithSpells = NO;
      SEL levelUpSpecialsWithSpellsSelector = @selector(levelUpSpecialsWithSpells);
      if ([model respondsToSelector:levelUpSpecialsWithSpellsSelector])
        {
          shouldLevelUpSpecialsWithSpells = ((BOOL (*)(id, SEL))[model methodForSelector:levelUpSpecialsWithSpellsSelector])(model, levelUpSpecialsWithSpellsSelector);
        }
      NSDictionary *containerToUse;
      if (shouldLevelUpSpecialsWithSpells)
        {
          NSLog(@"have to level up specials together with spells");
          if ([model.spells objectForKey: spell])
            {
              containerToUse = model.spells;
            }
          else
            {
              containerToUse = model.specials;
            }
        }
      else
        {
          NSLog(@"just leveling up my normal spells");          
          containerToUse = model.spells;
        }
      BOOL (*func)(id, SEL, DSASpell *) = (void *)objc_msgSend;
      result = func(model, levelUpSpell, [containerToUse objectForKey: spell]);
    }
  else
    {
      NSLog(@"DSACharacterDocument: levelUpSpell : The target character doesn't support: levelUpSpell?");
      result = NO;
    }
    
  if (result)
    {
      [self.fieldLevelUpFeedback setStringValue: _(@"Geschafft!")];
      [self.fieldLevelUpFeedback setHidden: NO];
    }
  else
    {
      [self.fieldLevelUpFeedback setStringValue: _(@"Leider nicht geschafft.")];
      [self.fieldLevelUpFeedback setHidden: NO];    
    }
  [self.fieldLevelUpTrialsCounter setStringValue: [NSString stringWithFormat: @"Verbleibende Versuche: %ld", (signed long)model.maxLevelUpSpellsTriesTmp]];
  [self populateLevelUpBottomPopupWithSpells: nil];
  if (model.maxLevelUpSpellsTriesTmp == 0)
    {
      [self.popupLevelUpTop setEnabled: NO];
      [self.popupLevelUpBottom setEnabled: NO];
      [self.buttonLevelUpDoIt setTarget:self];
      [self.buttonLevelUpDoIt setTitle: _(@"Fertig")];
      [self.buttonLevelUpDoIt setAction:@selector(finishLevelUp:)];
    }
}

- (IBAction)finishLevelUp: (id)sender
{
  DSACharacterDocument *document = (DSACharacterDocument *)self.document;
  DSACharacterHero *model = (DSACharacterHero *)document.model;
  
  [model finishLevelUp];
  [self.levelUpPanel close];
}

-(IBAction)manageMoney: (id)sender
{
  NSLog(@"DSACharacterWindowController manageMoney called!");
}

// character regeneration related methods
-(void)showRegenerateCharacterPanel: (id)sender
{
  NSLog(@"DSACharacterWindowController showRegenerateCharacterPanel called!");
       
  if (!self.regenerationPanel)
    {
      // Load the panel from the separate .gorm file
      [NSBundle loadNibNamed:@"DSARegenerateEnergies" owner:self];
    }
  [self.fieldRegenerationSleepHours setStringValue: @"8"];
  [self.fieldRegenerationResult setStringValue: @""];

  [self.regenerationPanel makeKeyAndOrderFront:nil];      
  
}

-(IBAction) regenerateEnergies: (id) sender
{
  DSACharacterDocument *document = (DSACharacterDocument *)self.document;
  DSACharacterHero *model = (DSACharacterHero *)document.model;
  
  DSARegenerationResult *result = [model regenerateBaseEnergiesForHours: [self.fieldRegenerationSleepHours integerValue]];
  
  NSMutableString *resultString = [[NSMutableString alloc] init];
  
  if (result.result != DSARegenerationResultSuccess)
    {
      [self.fieldRegenerationResult setStringValue: [DSARegenerationResult resultNameForResultValue: result.result]];
      return;
    }
  
  resultString = [NSMutableString stringWithFormat: @"%@ hat ", model.name];
  if (result.regenLE > 0)
    {
      [resultString appendString: [NSString stringWithFormat: @"%ld LE ", result.regenLE]];
      [document updateChangeCount: NSChangeDone];
    }
  if (model.isMagic && result.regenAE > 0)
    {
      [resultString appendString: [NSString stringWithFormat: @"und %ld AE ", result.regenAE]];
      [document updateChangeCount: NSChangeDone];
    }
  if (model.isBlessedOne && result.regenKE > 0)
    {
      [resultString appendString: [NSString stringWithFormat: @"und %ld KE ", result.regenKE]];
      [document updateChangeCount: NSChangeDone];
    }
  [resultString appendString: @"regeneriert."];
  
  [self.fieldRegenerationResult setStringValue: resultString];
}

// end of character regeneration related methods

// energies manager related methods
/*
@property (nonatomic, strong) IBOutlet NSPanel *manageTempEnergiesPanel;
@property (weak) IBOutlet NSTextField *fieldTempEnergiesAE;
@property (weak) IBOutlet NSTextField *fieldTempEnergiesKE;
@property (weak) IBOutlet NSTextField *fieldTempEnergiesLE;
@property (weak) IBOutlet NSSlider    *sliderTempEnergiesHunger;
@property (weak) IBOutlet NSSlider    *sliderTempEnergiesThirst;
@property (weak) IBOutlet NSPopUpButton *popupTempEnergiesWounded;
@property (weak) IBOutlet NSPopUpButton *popupTempEnergiesSick;
@property (weak) IBOutlet NSPopUpButton *popupTempEnergiesDrunk;
@property (weak) IBOutlet NSPopUpButton *popupTempEnergiesPoisoned;
@property (weak) IBOutlet NSPopUpButton *popupTempEnergiesDead;
@property (weak) IBOutlet NSPopUpButton *popupTempEnergiesUnconscious;
@property (weak) IBOutlet NSPopUpButton *popupTempEnergiesSpellbound;
*/
-(void)showEnergiesManagerPanel: (id)sender
{
  NSLog(@"DSACharacterWindowController showEnergiesManagerPanel called!");
  DSACharacterDocument *document = (DSACharacterDocument *)self.document;
  DSACharacterHero *model = (DSACharacterHero *)document.model;      
  if (!self.manageTempEnergiesPanel)
    {
      // Load the panel from the separate .gorm file
      [NSBundle loadNibNamed:@"DSAEnergiesManager" owner:self];
    }
  [self.fieldTempEnergiesAE setStringValue: [[NSNumber numberWithInteger: model.currentAstralEnergy] stringValue]];
  [self.fieldTempEnergiesKE setStringValue: [[NSNumber numberWithInteger: model.currentKarmaPoints] stringValue]];
  [self.fieldTempEnergiesLE setStringValue: [[NSNumber numberWithInteger: model.currentLifePoints] stringValue]];
  if (!model.isMagic && !model.isMagicalDabbler)
    {
      [self.fieldTempEnergiesAE setEnabled: NO];
    }
  else
    {
      [self.fieldTempEnergiesAE setEnabled: YES];    
    }  
  if (!model.isBlessedOne)
    {
      [self.fieldTempEnergiesKE setEnabled: NO];
    }
  else
    {
      [self.fieldTempEnergiesKE setEnabled: YES];
    }
  [self.sliderTempEnergiesHunger setFloatValue: [[model.statesDict objectForKey: @(DSACharacterStateHunger)] floatValue]];
  [self.sliderTempEnergiesThirst setFloatValue: [[model.statesDict objectForKey: @(DSACharacterStateThirst)] floatValue]];
  [self.popupTempEnergiesWounded removeAllItems];
  [self.popupTempEnergiesWounded addItemsWithTitles: @[ @"Nein", @"Leicht", @"Mittel", @"Schwer"]];
  [self.popupTempEnergiesWounded selectItemAtIndex: [[model.statesDict objectForKey: @(DSACharacterStateWounded)] integerValue]];
  [self.popupTempEnergiesSick removeAllItems];
  [self.popupTempEnergiesSick addItemsWithTitles: @[ @"Nein", @"Leicht", @"Mittel", @"Schwer"]];
  [self.popupTempEnergiesSick selectItemAtIndex: [[model.statesDict objectForKey: @(DSACharacterStateSick)] integerValue]];  
  [self.popupTempEnergiesDrunk removeAllItems];
  [self.popupTempEnergiesDrunk addItemsWithTitles: @[ @"Nein", @"Leicht", @"Mittel", @"Schwer"]];
  [self.popupTempEnergiesDrunk selectItemAtIndex: [[model.statesDict objectForKey: @(DSACharacterStateDrunken)] integerValue]];
  [self.popupTempEnergiesPoisoned removeAllItems];
  [self.popupTempEnergiesPoisoned addItemsWithTitles: @[ @"Nein", @"Leicht", @"Mittel", @"Schwer"]];  
  [self.popupTempEnergiesPoisoned selectItemAtIndex: [[model.statesDict objectForKey: @(DSACharacterStatePoisoned)] integerValue]];
  [self.popupTempEnergiesDead removeAllItems];
  [self.popupTempEnergiesDead addItemsWithTitles: @[ @"Nein", @"Ja"]];  
  [self.popupTempEnergiesDead selectItemAtIndex: [[model.statesDict objectForKey: @(DSACharacterStateDead)] integerValue]];
  [self.popupTempEnergiesUnconscious removeAllItems];
  [self.popupTempEnergiesUnconscious addItemsWithTitles: @[ @"Nein", @"Ja"]];
  [self.popupTempEnergiesUnconscious selectItemAtIndex: [[model.statesDict objectForKey: @(DSACharacterStateUnconscious)] integerValue]];
  [self.popupTempEnergiesSpellbound removeAllItems];
  [self.popupTempEnergiesSpellbound addItemsWithTitles: @[ @"Nein", @"Ja"]];
  [self.popupTempEnergiesSpellbound selectItemAtIndex: [[model.statesDict objectForKey: @(DSACharacterStateSpellbound)] integerValue]];    
  [self.manageTempEnergiesPanel makeKeyAndOrderFront:nil];    
    
}

-(IBAction) setTempEnergies: (id)sender
{

  NSLog(@"DSACharacterWindowController setTempEnergies called!");
  DSACharacterDocument *document = (DSACharacterDocument *)self.document;
  DSACharacterHero *model = (DSACharacterHero *)document.model;

  if (model.lifePoints >= [[self.fieldTempEnergiesLE stringValue] integerValue])
    {
    
      NSLog(@"setting life points");
      if ([[self.fieldTempEnergiesLE stringValue] integerValue] != model.currentLifePoints )
        {
           model.currentLifePoints = [[self.fieldTempEnergiesLE stringValue] integerValue];
           [document updateChangeCount: NSChangeDone];
        }
    }  
  else
    {
       NSLog(@"not setting life points");
    }
    
  if (model.isMagic || model.isMagicalDabbler)
    {
      if (model.astralEnergy >= [[self.fieldTempEnergiesAE stringValue] integerValue])
        {
          if ([[self.fieldTempEnergiesAE stringValue] integerValue] != model.currentAstralEnergy )
            {
              model.currentAstralEnergy = [[self.fieldTempEnergiesAE stringValue] integerValue];
              [document updateChangeCount: NSChangeDone];
            }
        }
    }
  if (model.isBlessedOne)
    {
      if (model.karmaPoints >= [[self.fieldTempEnergiesKE stringValue] integerValue])
        {
          if ([[self.fieldTempEnergiesKE stringValue] integerValue] != model.currentKarmaPoints )
            {
              model.currentKarmaPoints = [[self.fieldTempEnergiesKE stringValue] integerValue];
            }
        }
    }
  NSLog(@"DER HUNGER: %f", [self.sliderTempEnergiesHunger floatValue]);
  [model updateStatesDictState: (NSNumber *) @(DSACharacterStateHunger)
                     withValue: (NSNumber *) @([self.sliderTempEnergiesHunger floatValue])];  
  [model updateStatesDictState: (NSNumber *) @(DSACharacterStateThirst)
                     withValue: (NSNumber *) @([self.sliderTempEnergiesThirst floatValue])];
  [model updateStatesDictState: (NSNumber *) @(DSACharacterStateWounded)
                     withValue: (NSNumber *) @([self.popupTempEnergiesWounded indexOfSelectedItem])];                                          
  [model updateStatesDictState: (NSNumber *) @(DSACharacterStateSick)
                     withValue: (NSNumber *) @([self.popupTempEnergiesSick indexOfSelectedItem])];                     
  [model updateStatesDictState: (NSNumber *) @(DSACharacterStateDrunken)
                     withValue: (NSNumber *) @([self.popupTempEnergiesDrunk indexOfSelectedItem])];
  [model updateStatesDictState: (NSNumber *) @(DSACharacterStatePoisoned)
                     withValue: (NSNumber *) @([self.popupTempEnergiesPoisoned indexOfSelectedItem])];                     
  [model updateStatesDictState: (NSNumber *) @(DSACharacterStateDead)
                     withValue: (NSNumber *) @([self.popupTempEnergiesDead indexOfSelectedItem])];
  [model updateStatesDictState: (NSNumber *) @(DSACharacterStateUnconscious)
                     withValue: (NSNumber *) @([self.popupTempEnergiesUnconscious indexOfSelectedItem])];
  [model updateStatesDictState: (NSNumber *) @(DSACharacterStateSpellbound)
                     withValue: (NSNumber *) @([self.popupTempEnergiesSpellbound indexOfSelectedItem])];                                                     
}

// Use Talents related methods
-(void)showUseTalentPanel: (id)sender
{
  NSLog(@"DSACharacterWindowController showUseTalentPanel called!");
  DSACharacterDocument *document = (DSACharacterDocument *)self.document;
  DSACharacterHero *model = (DSACharacterHero *)document.model;      
  if (!self.useTalentPanel)
    {
      // Load the panel from the separate .gorm file
      [NSBundle loadNibNamed:@"DSAUseTalent" owner:self];
    }
  NSMutableSet *talentCategories = [NSMutableSet set];    
    // Enumerate talents to find all categories
  [model.talents enumerateKeysAndObjectsUsingBlock:^(id key, DSAOtherTalent *obj, BOOL *stop) {
      if (![[obj category] isEqualToString: (@"Kampftechniken")])
        {
          [talentCategories addObject: [obj category]];
        }
  }];
  NSArray *sortedTalentCategories = [[talentCategories allObjects] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
  [self.popupTalentCategorySelector setEnabled: YES];
  [self.popupTalentCategorySelector removeAllItems];
  [self.popupTalentCategorySelector addItemsWithTitles: sortedTalentCategories];
  [self.popupTalentCategorySelector setTarget:self];
  [self.popupTalentCategorySelector setAction:@selector(populateUseTalentsBottomPopupWithTalents:)];
  
  [self.popupTalentSelector setHidden: NO];
  [self.popupTalentSelector setEnabled: YES];
  [self.popupTalentSelector setAutoenablesItems: NO];
    
  // Populate the bottom popup
  [self populateUseTalentsBottomPopupWithTalents: nil];  
  
  [self.fieldTalentPenalty setBackgroundColor: [NSColor whiteColor]];
  [self.fieldTalentPenalty setStringValue: @"0"];
  [self.fieldTalentFeedback setHidden: YES];
  [self.useTalentPanel makeKeyAndOrderFront:nil];  
  
  [self.buttonTalentDoIt setTitle: _(@"Talentprobe")];
  [self.buttonTalentDoIt setTarget:self];
  [self.buttonTalentDoIt setAction:@selector(useTalent:)];  
  
  NSLog(@"DSACharacterWindowController finished showUseTalentPanel");
}

- (void)populateUseTalentsBottomPopupWithTalents:(id)sender
{

    NSLog(@"populateUseTalentsBottomPopupWithTalents called");
    
    DSACharacterDocument *document = (DSACharacterDocument *)self.document;
    DSACharacterHero *model = (DSACharacterHero *)document.model;  
    NSString *talentCategory = [[self.popupTalentCategorySelector selectedItem] title];
    
    // Store the previously selected item
    NSString *selectedItemTitle = [[self.popupTalentSelector selectedItem] title];
    
    // Remove all current items
    [self.popupTalentSelector removeAllItems];
    
    // Create arrays to hold sorted talents and spells
    NSMutableArray *sortedTalents = [NSMutableArray array];
    
    // Collect talents in the given category
    [model.talents enumerateKeysAndObjectsUsingBlock:^(id key, DSAOtherTalent *obj, BOOL *stop) {
        if ([[obj category] isEqualTo: talentCategory]) {
            [sortedTalents addObject: obj];
        }
    }];
    
    // Sort talents and spells alphabetically by their name
    NSArray *sortedTalentNames = [sortedTalents sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]];
    
    // Add sorted talents to the popup
    for (DSAOtherTalent *talent in sortedTalentNames) {
        [self. popupTalentSelector addItemWithTitle:[talent name]];
        [[self.popupTalentSelector itemWithTitle:[talent name]] setEnabled:YES];
    }

    // Try to re-select the previously selected item
    [self.popupTalentSelector selectItemWithTitle:selectedItemTitle];
    
    // If the selected item is disabled, select the first enabled item
    if (![[self.popupTalentSelector selectedItem] isEnabled]) {
        for (NSInteger i = 0; i < [self.popupTalentSelector numberOfItems]; i++) {
            if ([[self.popupTalentSelector itemAtIndex:i] isEnabled]) {
                [self.popupTalentSelector selectItemAtIndex:i];
                break;
            }
        }
    }
    
    // Update the popup button's display
    [self.popupTalentSelector setNeedsDisplay:YES];    
}

-(void)updateTalentPenalty: (id)sender
{
  NSLog(@"update talent penalty: sender tag: %lu", (unsigned long)[sender tag]);
  NSInteger delta = 0;
  if ([sender tag] == 0)
    {
      delta = -1;
    }
  else
    {
      delta = 1;
    }
  [self.fieldTalentPenalty setStringValue: [NSString stringWithFormat: @"%ld", (signed long) [self.fieldTalentPenalty integerValue] + delta]];
  
}

-(void)useTalent: (id)sender
{
  NSLog(@"use talent called!");
  DSACharacterDocument *document = (DSACharacterDocument *)self.document;
  DSACharacterHero *model = (DSACharacterHero *)document.model;  

  DSATalentResult *result;
  
  result = [model useTalent: [[self.popupTalentSelector selectedItem] title] withPenalty: [self.fieldTalentPenalty integerValue]];
  
  NSMutableString *diceResultString = [[NSMutableString alloc] init];
  for (NSDictionary *res in result.diceResults)
    {
      [diceResultString appendFormat: @"%@: %@ ", [res objectForKey: @"trait"], [res objectForKey: @"result"]];
    }
  
  NSMutableString *resultString = [NSMutableString stringWithFormat: @"%@, ( ", [DSATalentResult resultNameForResultValue: result.result]];
  [resultString appendString: diceResultString];
  [resultString appendFormat: @") verbliebene Talentpunkte: %ld", (signed long) result.remainingTalentPoints];
  
  [self.fieldTalentFeedback setStringValue: resultString];
  [self.fieldTalentFeedback setHidden: NO];
  [self.buttonTalentDoIt setTitle: _(@"Schließen")];
  [self.buttonTalentDoIt setTarget:self];
  [self.buttonTalentDoIt setAction:@selector(closeUseTalentsPanel:)];
  
}

-(void) closeUseTalentsPanel: (id) sender
{
  [self.useTalentPanel close];
}
// end of Use talents related methods

// casting spell related methods
-(void)showCastSpellPanel: (id)sender
{
  NSLog(@"DSACharacterWindowController showCastSpellPanel called!");

  DSACharacterDocument *document = (DSACharacterDocument *)self.document;
  DSACharacterHero *model = (DSACharacterHero *)document.model;      
  if (!self.castSpellPanel)
    {
      // Load the panel from the separate .gorm file
      [NSBundle loadNibNamed:@"DSACastSpell" owner:self];
    }
  NSMutableSet *spellCategories = [NSMutableSet set];    
    // Enumerate talents to find all categories
  [model.spells enumerateKeysAndObjectsUsingBlock:^(id key, DSASpell *obj, BOOL *stop) {
          [spellCategories addObject: [obj category]];
  }];
  NSArray *sortedSpellCategories = [[spellCategories allObjects] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
  [self.popupSpellCategorySelector setEnabled: YES];
  [self.popupSpellCategorySelector removeAllItems];
  [self.popupSpellCategorySelector addItemsWithTitles: sortedSpellCategories];
  [self.popupSpellCategorySelector setTarget:self];
  [self.popupSpellCategorySelector setAction:@selector(populateCastSpellBottomPopupWithSpells:)];
  
  [self.popupSpellSelector setHidden: NO];
  [self.popupSpellSelector setEnabled: YES];
  [self.popupSpellSelector setAutoenablesItems: NO];
    
  // Populate the bottom popup
  [self populateCastSpellBottomPopupWithSpells: nil];   
  
  [self.fieldSpellCreatorLevel setStringValue: @"0"];
  [self.fieldSpellMagicResistance setStringValue: @"0"];
  [self.fieldSpellDistance setStringValue: @"0"];
  [self.fieldSpellInvestedASP setStringValue: @"0"];
  [self.fieldSpellFeedback setHidden: YES];
  [self.fieldSpellFeedbackHeadline setHidden: YES];
  [self.castSpellPanel makeKeyAndOrderFront:nil];  
  
  [self.buttonSpellDoIt setTitle: _(@"Zauberprobe")];
  [self.buttonSpellDoIt setTarget:self];
  [self.buttonSpellDoIt setAction:@selector(castSpell:)];  
  
  NSLog(@"DSACharacterWindowController finished showCastSpellPanel");
 
}

- (void) castSpell: (id) sender
{
  DSACharacterDocument *document = (DSACharacterDocument *)self.document;
  DSACharacterHero *model = (DSACharacterHero *)document.model;
  DSACharacter *targetCharacter = [[DSACharacter alloc] init];
  DSACharacter *originCharacter = [[DSACharacter alloc] init];
  DSASpellResult *spellResult;

  targetCharacter.mrBonus = [self.fieldSpellMagicResistance integerValue];
  originCharacter.level = [self.fieldSpellCreatorLevel integerValue];
  
  spellResult = [model castSpell: [[self.popupSpellSelector selectedItem] title]
                       ofVariant: nil
               ofDurationVariant: nil
                        onTarget: targetCharacter
                      atDistance: [self.fieldSpellDistance integerValue]
                     investedASP: [self.fieldSpellInvestedASP integerValue] 
            spellOriginCharacter: originCharacter];

  NSMutableString *resultString = [NSMutableString stringWithFormat: @"%@", [DSASpellResult resultNameForResultValue: spellResult.result]];                        
  [self.fieldSpellFeedbackHeadline setStringValue: resultString];
  [self.fieldSpellFeedbackHeadline setHidden: NO];
  [self.fieldSpellFeedbackHeadline setStringValue: spellResult.resultDescription];
  [self.fieldSpellFeedbackHeadline setHidden: NO];   
}

- (void) populateCastSpellBottomPopupWithSpells:(id)sender
{

    NSLog(@"populateCastSpellBottomPopupWithSpells called");
    
    DSACharacterDocument *document = (DSACharacterDocument *)self.document;
    DSACharacterHero *model = (DSACharacterHero *)document.model;  
    NSString *spellCategory = [[self.popupSpellCategorySelector selectedItem] title];
    
    // Store the previously selected item
    NSString *selectedItemTitle = [[self.popupSpellSelector selectedItem] title];
    
    // Remove all current items
    [self.popupSpellSelector removeAllItems];
    
    // Create arrays to hold sorted talents and spells
    NSMutableArray *sortedSpells = [NSMutableArray array];
    
    // Collect talents in the given category
    [model.spells enumerateKeysAndObjectsUsingBlock:^(id key, DSASpell *obj, BOOL *stop) {
        if ([[obj category] isEqualTo: spellCategory]) {
            [sortedSpells addObject: obj];
        }
    }];
    
    // Sort talents and spells alphabetically by their name
    NSArray *sortedSpellNames = [sortedSpells sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]];
    
    // Add sorted talents to the popup
    for (DSASpell *spell in sortedSpellNames) {
        [self. popupSpellSelector addItemWithTitle:[spell name]];
        if ([spell isActiveSpell])
          {
            [[self.popupSpellSelector itemWithTitle:[spell name]] setEnabled:YES];
          }
        else
          {
            [[self.popupSpellSelector itemWithTitle:[spell name]] setEnabled:NO];
          }
    }

    // Try to re-select the previously selected item
    [self.popupSpellSelector selectItemWithTitle:selectedItemTitle];
    
    // If the selected item is disabled, select the first enabled item
    if (![[self.popupSpellSelector selectedItem] isEnabled]) {
        for (NSInteger i = 0; i < [self.popupSpellSelector numberOfItems]; i++) {
            if ([[self.popupSpellSelector itemAtIndex:i] isEnabled]) {
                [self.popupSpellSelector selectItemAtIndex:i];
                break;
            }
        }
    }
    
    // Update the popup button's display
    [self.popupSpellSelector setNeedsDisplay:YES];    
}


// end of casting spell related methods

-(void)addAdventurePoints: (id)sender
{
  NSLog(@"DSACharacterWindowController addAdventurePoints called!");
  
  if (!self.adventurePointsPanel)
    {
      // Load the panel from the separate .gorm file
      [NSBundle loadNibNamed:@"DSAAdventurePoints" owner:self];
    }
  [self.fieldAdditionalAdventurePoints setBackgroundColor: [NSColor whiteColor]];
  [self.fieldAdditionalAdventurePoints setStringValue: @""];  
  [self.adventurePointsPanel makeKeyAndOrderFront:nil];  
}

-(IBAction)verifyAndFinishAddAdventurePoints: (id)sender
{
  NSLog(@"DSACharacterWindowController verifyAndFinishAddAdventurePoints called!");
  DSACharacterDocument *document = (DSACharacterDocument *)self.document;
  DSACharacterHero *model = (DSACharacterHero *)document.model;  

  NSString *inputString = [self.fieldAdditionalAdventurePoints stringValue];

  // Trim any spaces or newlines
  inputString = [inputString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  // Use NSScanner to validate if the input is a valid integer
  NSScanner *scanner = [NSScanner scannerWithString:inputString];
  int inputValue;
  BOOL isNumeric = [scanner scanInt:&inputValue] && [scanner isAtEnd];

  if (isNumeric && inputValue > 0)
    {
      NSLog(@"Input is a positive integer.");
      // You can proceed with the value, as it is a valid positive integer
      model.adventurePoints = model.adventurePoints + [inputString integerValue];
      [document updateChangeCount: NSChangeDone];
      [self.adventurePointsPanel close];
    }
  else
    {
      NSLog(@"Input is not a positive integer.");
      // Handle the error (e.g., show a warning to the user)
      [self.fieldAdditionalAdventurePoints setBackgroundColor: [NSColor redColor]];
    }
  
}

- (void)closePanel:(id)sender {
    NSLog(@"DSACharacterWindowController closePanel called!");
    [[sender window] close];
}

// casting Rituals related methods
-(void)showRitualsPanel: (id)sender
{
  NSLog(@"DSACharacterWindowController showRitualsPanel called!");

  DSACharacterDocument *document = (DSACharacterDocument *)self.document;
  DSACharacterHero *model = (DSACharacterHero *)document.model;      
  if (!self.castRitualPanel)
    {
      // Load the panel from the separate .gorm file
      [NSBundle loadNibNamed:@"DSACastRitual" owner:self];
    }
  NSMutableSet *ritualCategories = [NSMutableSet set];    
    // Enumerate rituals to find all categories
  [model.specials enumerateKeysAndObjectsUsingBlock:^(id key, DSASpell *obj, BOOL *stop) {
          [ritualCategories addObject: [obj category]];
  }];
  NSArray *sortedRitualCategories = [[ritualCategories allObjects] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
  [self.popupRitualCategorySelector setEnabled: YES];
  [self.popupRitualCategorySelector removeAllItems];
  [self.popupRitualCategorySelector addItemsWithTitles: sortedRitualCategories];
  [self.popupRitualCategorySelector setTarget:self];
  [self.popupRitualCategorySelector setAction:@selector(populateCastRitualBottomPopupWithRituals:)];
  
  [self.popupRitualVariantSelector setEnabled: NO];
  [self.popupRitualVariantSelector removeAllItems];
  [self.popupRitualDurationVariantSelector setEnabled: NO];
  [self.popupRitualDurationVariantSelector removeAllItems];  
  [self.popupRitualCategorySelector setTarget:self];
  [self.popupRitualCategorySelector setAction:@selector(populateCastRitualBottomPopupWithRituals:)];  
  
  [self.popupRitualSelector setHidden: NO];
  [self.popupRitualSelector setEnabled: YES];
  [self.popupRitualSelector setTarget:self];
  [self.popupRitualSelector setAction:@selector(populateCastRitualVariantSelectorPopups:)];  
  [self.popupRitualSelector setAutoenablesItems: NO];

  [self.fieldRitualCreatorLevel setStringValue: @"0"];
  [self.fieldRitualMagicResistance setStringValue: @"0"];
  [self.fieldRitualDistance setStringValue: @"0"];
  [self.fieldRitualInvestedASP setStringValue: @"0"];  
  
      
  // Populate the bottom popup
  [self populateCastRitualBottomPopupWithRituals: nil];   
  
  [self.fieldRitualFeedback setHidden: YES];
  [self.fieldRitualFeedbackHeadline setHidden: YES];
  [self.castRitualPanel makeKeyAndOrderFront:nil];  
  
  [self.buttonRitualDoIt setTitle: _(@"Anwenden")];
  [self.buttonRitualDoIt setTarget:self];
  [self.buttonRitualDoIt setAction:@selector(castRitual:)];  
  
  NSLog(@"DSACharacterWindowController finished showRitualsPanel");
 
}

- (void) populateCastRitualBottomPopupWithRituals:(id)sender
{

    NSLog(@"populateCastRitualBottomPopupWithRituals called");
    
    DSACharacterDocument *document = (DSACharacterDocument *)self.document;
    DSACharacterHero *model = (DSACharacterHero *)document.model;  
    NSString *ritualCategory = [[self.popupRitualCategorySelector selectedItem] title];
    
    // Store the previously selected item
    NSString *selectedItemTitle = [[self.popupRitualSelector selectedItem] title];
    
    // Remove all current items
    [self.popupRitualSelector removeAllItems];
    
    // Create arrays to hold sorted talents and spells
    NSMutableArray *sortedRituals = [NSMutableArray array];
    
    // Collect talents in the given category
    [model.specials enumerateKeysAndObjectsUsingBlock:^(id key, DSASpell *obj, BOOL *stop) {
        if ([[obj category] isEqualTo: ritualCategory]) {
            [sortedRituals addObject: obj];
        }
    }];
    
    // Sort talents and spells alphabetically by their name
    NSArray *sortedRitualNames = [sortedRituals sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]];
    
    // Add sorted talents to the popup
    for (DSASpell *ritual in sortedRitualNames) {
        [self.popupRitualSelector addItemWithTitle: ritual.name];
        if ([model canCastRitualWithName: ritual.name])
          {
            [[self.popupRitualSelector itemWithTitle: ritual.name] setEnabled:YES];
          }
        else
          {
            [[self.popupRitualSelector itemWithTitle: ritual.name] setEnabled:NO];
          }
    }

    // Try to re-select the previously selected item
    [self.popupRitualSelector selectItemWithTitle:selectedItemTitle];
    
    // If the selected item is disabled, select the first enabled item
    if (![[self.popupRitualSelector selectedItem] isEnabled]) {
        for (NSInteger i = 0; i < [self.popupRitualSelector numberOfItems]; i++) {
            if ([[self.popupRitualSelector itemAtIndex:i] isEnabled]) {
                [self.popupRitualSelector selectItemAtIndex:i];
                break;
            }
        }
    }
    [self populateCastRitualVariantSelectorPopups: nil];
    // Update the popup button's display
    [self.popupRitualSelector setNeedsDisplay:YES];    
}

- (void) populateCastRitualVariantSelectorPopups:(id)sender
{
    DSACharacterDocument *document = (DSACharacterDocument *)self.document;
    DSACharacterHero *model = (DSACharacterHero *)document.model;
    
    NSArray *variants = [[model.specials objectForKey: [[self.popupRitualSelector selectedItem] title]] variants];
    NSArray *durationVariants = [[model.specials objectForKey: [[self.popupRitualSelector selectedItem] title]] durationVariants];
    if (variants && [variants count] > 0)
      {
        [self.popupRitualVariantSelector setEnabled: YES];
        [self.popupRitualVariantSelector removeAllItems];      
        [self.popupRitualVariantSelector addItemsWithTitles: variants];
      }
    else
      {
        [self.popupRitualVariantSelector setEnabled: NO];
        [self.popupRitualVariantSelector removeAllItems];      
      } 
    if (durationVariants && [durationVariants count] > 0)
      {
        [self.popupRitualDurationVariantSelector setEnabled: YES];
        [self.popupRitualDurationVariantSelector removeAllItems];      
        [self.popupRitualDurationVariantSelector addItemsWithTitles: durationVariants];
      }
    else
      {
        [self.popupRitualDurationVariantSelector setEnabled: NO];
        [self.popupRitualDurationVariantSelector removeAllItems];      
      }
   [self.popupRitualVariantSelector setNeedsDisplay:YES];         
   [self.popupRitualDurationVariantSelector setNeedsDisplay:YES];   
}

- (void) castRitual: (id) sender
{
  DSACharacterDocument *document = (DSACharacterDocument *)self.document;
  DSACharacterHero *model = (DSACharacterHero *)document.model;

  DSACharacter *targetCharacter = [[DSACharacter alloc] init];

  targetCharacter.mrBonus = [self.fieldRitualMagicResistance integerValue];  
  targetCharacter.name = @"Dummy Name";
  targetCharacter.level = [self.fieldRitualCreatorLevel integerValue];
  
  NSString *ritualName = [[self.popupRitualSelector selectedItem] title];
  NSString *ritualVariant;
  NSString *ritualDurationVariant;
  if ([self.popupRitualVariantSelector isEnabled])
    {
       ritualVariant = [[self.popupRitualVariantSelector selectedItem] title];
    }
  if ([self.popupRitualDurationVariantSelector isEnabled])
    {
       ritualDurationVariant = [[self.popupRitualDurationVariantSelector selectedItem] title];
    }
      
  DSASpellResult *spellResult = [model castRitual: ritualName
                                        ofVariant: ritualVariant
                                ofDurationVariant: ritualDurationVariant
                                         onTarget: targetCharacter
                                       atDistance: [self.fieldRitualDistance integerValue]
                                      investedASP: [self.fieldRitualInvestedASP integerValue]
                             spellOriginCharacter: nil];
  
  NSMutableString *resultString = [NSMutableString stringWithFormat: @"%@", [DSASpellResult resultNameForResultValue: spellResult.result]];
  [self.fieldRitualFeedbackHeadline setStringValue: resultString];
  [self.fieldRitualFeedbackHeadline setHidden: NO];  
  [self.fieldRitualFeedback setStringValue: spellResult.resultDescription];
  [self.fieldRitualFeedback setHidden: NO];   
}

// End of cast Rituals related methods





@end
