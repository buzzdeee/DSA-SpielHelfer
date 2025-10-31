/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-01-01 23:39:03 +0100 by sebastia

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

#import "DSADocumentController.h"
#import "DSACharacterDocument.h"
#import "DSAAdventureDocument.h"
#import "DSAAdventureWindowController.h"
#import "DSAAdventure.h"
#import "Utils.h"
#import "DSAAdventureClock.h"
#import "DSAAdventureGroup.h"

extern NSString * const DSACharacterHighlightedNotification;

@implementation DSAAdventureDocument

NSString * const DSACharacterHighlightedNotification = @"DSACharacterHighlightedNotification";

- (instancetype)init
{
  self = [super init];
  if (self)
    {
      // Initialize your document here
      if ([DSAAdventureManager sharedManager].currentAdventure != nil)
        {
          NSLog(@"DSAAdventureDocument init: another adventure is already running");
          self = nil;
          return self;
        }
      _model = [[DSAAdventure alloc] init];
      _characterDocuments = [[NSMutableArray alloc] init];
      [[NSNotificationCenter defaultCenter] addObserver:self
                                         selector:@selector(characterHighlighted:)
                                             name:DSACharacterHighlightedNotification
                                           object:nil];
      [DSAAdventureManager sharedManager].currentAdventure = self.model;
    }
  NSLog(@"DSAAdventureDocument init was called, the model: %@", self.model);  
  return self;
}

- (void)dealloc
{
  NSLog(@"DSAAdventureDocument is being deallocated.");
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  NSLog(@"DSAAdventureDocument finished dealloc.");  
}

- (void)close
{
    NSLog(@"DSAAdventureDocument close called!");
    if ([DSAAdventureManager sharedManager].currentAdventure == self.model) {
        [DSAAdventureManager sharedManager].currentAdventure = nil;
    }    
    [self.model.gameClock.gameTimer invalidate];
    self.model.gameClock.gameTimer = nil;
    self.model = nil;
    
    [super close];
}

- (NSString *)windowNibName
{
  NSLog(@"DSAAdventureDocument: windowNibName was called");
  // Return the name of the .gorm file that defines the document's UI
  return @"DSAAdventure";
}

// we don't want the windows to pop up on startup
- (void)makeWindowControllers
{ 
  if (self.windowControllersCreated)
    {
      NSLog(@"DSAAdventureDocument: windowControllers already created");
      return; // Don't create again
    }
    self.windowControllersCreated = YES;
  
  if ([self.model isMemberOfClass:[DSAAdventure class]])
    {
      DSAAdventureWindowController *windowController = [[DSAAdventureWindowController alloc] initWithWindowNibName:[self windowNibName]];
      [self addWindowController:windowController];
      
      NSLog(@"DSAAdventureDocument makeWindowControllers called, and it was DSAAdventure class" );
    }
  else
    {
      NSLog(@"DSAAdventureDocument makeWindowControllers called, and it was NOT a DSAAdventure class: %@", [self.model class]);
    }
}

- (BOOL)isMainWindow:(NSWindow *)window {
    for (NSWindowController *controller in self.windowControllers) {
        if (controller.window == window) {
            return YES; // This is the main document window
        }
    }
    return NO; // This is an ancillary window
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
  // Ensure the model exists       
  @try
    {
      if (!self.model)
        {
          if (outError)
            {
              *outError = [NSError errorWithDomain:NSCocoaErrorDomain
                                              code:NSFileWriteUnknownError
                                          userInfo:@{NSLocalizedDescriptionKey: @"No data to save"}];
            }
          return nil;
        }
        
      // Archive model object to NSData
      NSLog(@"DSAAdventureDocument dataOfType: %@ self.model: %@", typeName, self.model);
      NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.model requiringSecureCoding:NO error:outError];
        
      if (!data && outError)
        {
          NSLog(@"DSAAdventureDocument dataOfType: Archiving failed with error: %@", *outError);
          return nil;
        }
        
      NSLog(@"DSAAdventureDocument dataOfType: Successfully encoded the data");
      return data;
    }
  @catch (NSException *exception)
    {
      NSLog(@"DSAAdventureDocument dataOfType: Exception caught during archiving: %@", exception);
      if (outError)
        {
           *outError = [NSError errorWithDomain:NSCocoaErrorDomain
                                           code:NSFileWriteUnknownError
                                       userInfo:@{NSLocalizedDescriptionKey: [exception reason]}];
        }
      return nil;
    } 

}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
  NSLog(@"DSAAdventureDocument readFromData called... ABORTING!!!!");
  abort();
  
  // Unarchive the model from the data
  self.model = [NSKeyedUnarchiver unarchivedObjectOfClass:[DSAAdventure class] fromData:data error:outError];

  // If unarchiving fails, return NO and pass the error
  if (!self.model && outError)
    {
      return NO;
    }
  return YES;
}

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError **)outError
{ 
  NSLog(@"DSAAdventureDocument readFromURL called...");  
  // Load data from file
    {      
      NSData *data = [NSData dataWithContentsOfURL:url];
      if (!data)
        {
          NSLog(@"DSAAdventureManager readFromURL: Failed to read data from URL: %@", url);
          return NO;
        }
    
      // Unarchive model object from NSData
      self.model = [NSKeyedUnarchiver unarchivedObjectOfClass:[DSAAdventure class] fromData:data error:outError];
      if (!self.model)
        {
          NSLog(@"Failed to unarchive model");
          return NO;
        }
      [self loadCharacterDocuments];
      // Notify that the document has been successfully loaded
      [self updateChangeCount:NSChangeCleared];
    
      // Force initialization of the UI if lazy loading is used
      if (self.windowControllersCreated)
        {
          NSLog(@"DSAAdventureDocument readFromURL: windowControllers already created");
          //[windowController showWindow:self];
      
          return YES; // Don't create again
        }  
      self.windowControllersCreated = YES;  
      DSAAdventureWindowController *windowController = [[DSAAdventureWindowController alloc] initWithWindowNibName:[self windowNibName]];
      [self addWindowController:windowController];
      [windowController showWindow:self];
    }
  NSLog(@"DSAAdventureDocument readFromURL: AT THE END");   
  return YES;
}

- (BOOL)isDocumentEdited
{
    //NSLog(@"DSAAdventureDocument isDocumentEdited called!");
    BOOL edited = [super isDocumentEdited];
    //NSLog(@"DSAAdventureDocument isDocumentEdited returning: %@", edited ? @"YES" : @"NO");
    return edited;
}

- (BOOL)canCloseDocument
{
    //NSLog(@"DSAAdventureDocument canCloseDocument called!");

    NSWindow *closingWindow = [[NSApplication sharedApplication] keyWindow];
    if (![self isMainWindow: closingWindow])
      {
        return YES;
      }
    
    return [super canCloseDocument]; // Default behavior: Allow the standard save check.
}

- (NSInteger)runModalOpenPanel:(NSOpenPanel *)openPanel forTypes:(NSArray<NSString *> *)types {
    openPanel.allowedFileTypes = @[@"dsaa"];
    openPanel.allowsMultipleSelection = NO;
    NSURL *defaultDirectory = [Utils adventureStorageDirectory];
    if (defaultDirectory) {
        openPanel.directoryURL = defaultDirectory;
    }
    if ([openPanel runModal] == NSModalResponseOK) {
        return NSModalResponseOK;
    }    
    return NSModalResponseCancel;
}

- (NSInteger)runModalSavePanel:(NSSavePanel *)savePanel withAccessoryView:(NSView *)accessoryView {
    // Set default directory
    NSURL *defaultDirectory = [Utils adventureStorageDirectory];
    if (defaultDirectory) {
        savePanel.directoryURL = defaultDirectory;
    }
    if ([savePanel runModal] == NSModalResponseOK) {
        return NSModalResponseOK;
    }    
    return NSModalResponseCancel;
}


- (void)removeCharacterDocumentForCharacter:(DSACharacter *)character {
    DSACharacterDocument *docToRemove = nil;

    for (DSACharacterDocument *doc in self.characterDocuments) {
        if ([doc.model.modelID isEqual:character.modelID]) {
            docToRemove = doc;
            break;
        }
    }

    if (docToRemove) {
        [self.characterDocuments removeObject:docToRemove];
        NSLog(@"Removed DSACharacterDocument for character %@", character.name);
    } else {
        NSLog(@"No character document found for character %@", character.name);
    }
}

- (void)addCharacterFromFile {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    openPanel.allowedFileTypes = @[@"dsac"]; // Using DSACharacter here doesn't work, have to use the file type...
    openPanel.directoryURL = [Utils characterStorageDirectory];
    openPanel.allowsMultipleSelection = NO;

    if ([openPanel runModal] == NSModalResponseOK) {
        NSURL *characterURL = openPanel.URL;
        NSLog(@"DSAAdventureDocument addCharacterFromFile: characterURL : %@", characterURL);
        [self addCharacterFromURL:characterURL];
    }
}

- (void)addCharacterFromURL:(NSURL *)characterURL {
    NSURL *baseDirURL = [Utils characterStorageDirectory];
    NSString *relativePath = [characterURL.path stringByReplacingOccurrencesOfString:baseDirURL.path withString:@""];
    if ([relativePath hasPrefix:@"/"]) {
        relativePath = [relativePath substringFromIndex:1];
    }

    // Step 1: Open the character document first (we need UUID to check)
    [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:characterURL
                                                                           display:NO
                                                                 completionHandler:^(NSDocument *document, BOOL wasOpened, NSError *error) {
        if (!error && [document isKindOfClass:[DSACharacterDocument class]]) {
            DSACharacterDocument *characterDoc = (DSACharacterDocument *)document;
            DSACharacter *character = characterDoc.model;
            NSString *uuidString = character.modelID.UUIDString;

            // Step 2: Check if this character is already tracked
            if (self.model.characterFilePaths[uuidString] != nil) {
                //NSLog(@"DSAAdventureDocument addCharacterFromURL : Character %@ already added to adventure.", uuidString);
                return;
            }

            // Step 3: Store relative path in dictionary
            self.model.characterFilePaths[uuidString] = relativePath;

            // Step 4: Ensure group exists
            if (self.model.groups.count == 0) {
                DSAAdventureGroup *initialGroup = [[DSAAdventureGroup alloc] init];
                [self.model.groups addObject:initialGroup];
            }

            // Step 5: Add character to group if not already present
            NSMutableArray<NSUUID *> *members = self.model.activeGroup.partyMembers;
            if (![members containsObject:character.modelID]) {
                [members addObject:character.modelID];
                [character activateExpiryForAllItemsWithDate:self.model.gameClock.currentDate];
            }

            // Step 6: Track document separately
            [self.characterDocuments addObject:characterDoc];

            [[NSNotificationCenter defaultCenter] postNotificationName:@"DSAAdventureCharactersUpdated" object:self];
        } else {
            NSLog(@"DSAAdventureDocument addCharacterFromURL: Failed to open character at %@: %@", characterURL, error);
        }
    }];
}

- (void)loadCharacterDocuments {
    self.characterDocuments = [NSMutableArray array];
    NSString *baseDir = [[Utils characterStorageDirectory] path];

    //NSLog(@"DSAAdventureDocument loadCharacterDocuments: self.model: %@", self.model.characterFilePaths);
    for (NSString *relativePath in [self.model.characterFilePaths allValues]) {
        NSString *fullPath = [baseDir stringByAppendingPathComponent:relativePath];
        //NSLog(@"DSAAdventureDocument loadCharacterDocuments: fullPath: %@", fullPath);
        NSURL *characterURL = [NSURL fileURLWithPath:fullPath];
        [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:characterURL
                                                                              display:NO
                                                                    completionHandler:^(NSDocument *document, BOOL wasOpened, NSError *error) {
            if (!error && [document isKindOfClass:[DSACharacterDocument class]]) {
                [self.characterDocuments addObject:(DSACharacterDocument *)document];
            }
        }];
    }
}

- (BOOL)writeSafelyToURL:(NSURL *)url 
                  ofType:(NSString *)typeName 
        forSaveOperation:(NSSaveOperationType)saveOperation 
                   error:(NSError **)outError {
    
    //NSLog(@"DSAAdventureDocument: Writing safely to URL %@", url);

    // First, save all character documents
    for (DSACharacterDocument *charDoc in self.characterDocuments) {
        NSError *charSaveError = nil;
        if (![charDoc writeSafelyToURL:[charDoc fileURL] 
                                ofType:[charDoc fileType] 
                      forSaveOperation:saveOperation 
                                 error:&charSaveError]) {
            NSLog(@"DSAAdventureDocument writeSafelyToURL: Failed to save character: %@", charSaveError);
            if (outError) *outError = charSaveError;
            return NO; // Stop if any character fails to save
        }
    }

    // Now save the adventure document itself
    return [super writeSafelyToURL:url ofType:typeName forSaveOperation:saveOperation error:outError];
}

- (void)saveCharacterDocuments {
    for (DSACharacterDocument *charDoc in self.characterDocuments) {
        [charDoc saveToURL:[charDoc fileURL] 
                     ofType:[charDoc fileType]
           forSaveOperation:NSSaveOperation
                   delegate:self
            didSaveSelector:@selector(characterDocumentDidSave:success:contextInfo:)
               contextInfo:NULL];
    }
}

// Callback method for character document save
- (void)characterDocumentDidSave:(NSDocument *)document success:(BOOL)success contextInfo:(void *)contextInfo {
    if (!success) {
        NSLog(@"DSAAdventureDocument characterDocumentDidSave: Error saving character document: %@", document);
    }
}

// Save adventure document and characters together
- (void)saveDocumentWithCompletionHandler:(void (^)(NSError *))completionHandler {
    // Save character documents first
    [self saveCharacterDocuments];
    // NSLog(@"DSAAdventureDocument saveDocumentWithCompletionHandler: saving self: %@", self.model);
    // Save the adventure document itself
    [self saveToURL:[self fileURL] 
             ofType:[self fileType]
   forSaveOperation:NSSaveOperation
           delegate:self
    didSaveSelector:@selector(adventureDocumentDidSave:success:contextInfo:)
       contextInfo:(__bridge void *)completionHandler];
}

// Callback method for adventure document save
- (void)adventureDocumentDidSave:(NSDocument *)document success:(BOOL)success contextInfo:(void *)contextInfo {
    void (^completionHandler)(NSError *) = (__bridge void (^)(NSError *))contextInfo;
    if (!success) {
        NSError *error = [NSError errorWithDomain:@"DSAAdventureDocumentError"
                                             code:1
                                         userInfo:@{NSLocalizedDescriptionKey: @"Failed to save adventure document"}];
        completionHandler(error);
    } else {
        completionHandler(nil);
    }
}

- (void)characterHighlighted:(NSNotification *)notification {
    DSACharacterDocument *selectedCharacter = notification.object;

    if (selectedCharacter) {
        // Update the tracked selected character in the document
        self.selectedCharacterDocument = selectedCharacter;

        //NSLog(@"DSAAdventureDocument characterHighlighted: may want to do something after receiving the Notification...");
    } else {
        // No character is selected
        self.selectedCharacterDocument = nil;
        //NSLog(@"DSAAdventureDocument characterHighlighted: character was deselected...");
    }
}

- (void)pauseGameClock
{
  [[self.model gameClock] pauseClock];
}
- (void)startGameClock
{
  [[self.model gameClock] startClock];
}
- (void)advanceGameTimeByMinutes: (NSUInteger) minutes
{
  [[self.model gameClock] advanceTimeByMinutes: minutes sendNotification: YES];
}
- (void)advanceGameTimeByHours: (NSUInteger) hours
{
  [[self.model gameClock] advanceTimeByHours: hours sendNotification: YES];
}
- (void)advanceGameTimeByDays: (NSUInteger) days
{
  [[self.model gameClock] advanceTimeByDays: days sendNotification: YES];
}

@end



