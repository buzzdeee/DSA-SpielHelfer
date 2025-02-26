/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-09-07 23:18:55 +0200 by sebastia

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

#import "AppDelegate.h"
#import "AppController.h"
//#import "TestDocumentController.h"

@implementation AppDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
  // Initialize app here
  
  NSLog(@"AppDelegate: applicationWillFinishLaunching: was called");
//  self.documentController = [TestDocumentController sharedDocumentController];  
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
  // Initialize app here
  NSLog(@"AppDelegate: applicationDidFinishLaunching: was called");
 
  self.appController = [[AppController alloc] init];  
  [self.appController setupApplication];
}

// Invoked just before the application terminates. 
// Use this method to perform cleanup tasks, save data, or release resources.
- (void)applicationWillTerminate:(NSNotification *)notification
{
  NSLog(@"AppDelegate: applicationWillTerminate: %@", notification);

  // [self.appController savePreferences];
}

// Asks the delegate whether the application should terminate. 
// Useful for prompting the user to save unsaved changes or cancel termination under certain conditions.
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
//    if ([self.appController hasUnsavedChanges])
//      {
        // Prompt the user to save changes
        // Return NSTerminateLater if waiting for user input
//        return NSTerminateCancel; // Or NSTerminateNow based on user response
//      }
    NSLog(@"AppDelegate: applicationShouldTerminate: %@", sender);
    return NSTerminateNow;
}

// Determines whether the application should quit when the last window is closed. 
// Returning YES makes the app quit automatically, which is common for utility applications.
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
  NSLog(@"applicationShouldTerminateAfterLastWindowClosed: was called");
  return NO; // Return YES if the app should quit after the last window closes
}

// Handles requests to open files, typically when the user double-clicks a 
// file associated with your app or drags a file onto the app icon.
- (void)application:(NSApplication *)sender openFiles:(NSArray<NSString *> *)filenames
{
  NSLog(@"AppDelegate: openFiles: was called");
//    for (NSString *filename in filenames)
//      {
        // Open each file using your NSDocumentController
//        [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:[NSURL fileURLWithPath:filename]
//                                                                               display:YES
//                                                                                 error:nil];
//     }
//    [sender replyToOpenOrPrint:NSApplicationDelegateReplySuccess];
}

// Handles opening multiple URLs (including files) in response to user actions.
- (void)application:(NSApplication *)application openURLs:(NSArray<NSURL *> *)urls
{
  NSLog(@"AppDelegate: openURLs: was called");
//    for (NSURL *url in urls)
//      {
        // Open each URL using your NSDocumentController
//        [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:url
//                                                                               display:YES
//                                                                                 error:nil];
//      }
}

// Called when the user tries to reopen the application (e.g., clicking the app icon in the Dock) 
// while it’s already running. Useful for restoring windows or bringing the app to the foreground.
- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
{
  NSLog(@"AppDelegate: applicationShouldHandleReopen: was called");
//  if (!flag)
//    {
      // No visible windows, so open a new document window
//      [[NSDocumentController sharedDocumentController] newDocument:self];
//    }
  return YES;
}

// Called when the application is about to become active. 
// Useful for refreshing UI elements or updating data when the app gains focus.
- (void)applicationWillBecomeActive:(NSNotification *)notification
{
  NSLog(@"AppDelegate: applicationWillBecomeActive: was called");

  // Prepare for activation
}

// Called when the application has become active. 
// Useful for refreshing UI elements or updating data when the app gains focus.
- (void)applicationDidBecomeActive:(NSNotification *)notification
{
  NSLog(@"AppDelegate: applicationDidBecomeActive: was called");
  // Refresh UI or data
}

// Called when the application is about to resign its active status. 
// Useful for pausing ongoing tasks or saving transient state.
- (void)applicationWillResignActive:(NSNotification *)notification
{
  NSLog(@"AppDelegate: applicationWillResignActive: was called");
  // Pause tasks or disable certain UI elements
}

// Called when the application has resigned its active status. 
// Useful for pausing ongoing tasks or saving transient state.
- (void)applicationDidResignActive:(NSNotification *)notification
{
  NSLog(@"AppDelegate: applicationDidResignActive: was called");
  // Perform actions after resigning active status
}

// Indicates whether the application supports secure state restoration. 
// Returning YES allows your app to participate in state restoration, 
// which can restore windows and their states after the app restarts.
- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app
{
  NSLog(@"AppDelegate: applicationSupportsSecureRestorableState: was called");
  return NO;
}


// Allows the delegate to encode additional information into the state restoration process.
- (void)application:(NSApplication *)app willEncodeRestorableState:(NSCoder *)state
{
  NSLog(@"AppDelegate: willEncodeRestorableState: was called");
  // Encode additional state information
}

// Allows the delegate to respond after the state has been decoded.
- (void)application:(NSApplication *)app didDecodeRestorableState:(NSCoder *)state
{
  NSLog(@"AppDelegate: didDecodeRestorableState: was called");
  // Decode and apply additional state information
}

// Handles registration for remote notifications (e.g., push notifications). 
// While more common in iOS, macOS applications can also use these for similar purposes.
- (void)application:(NSApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
  NSLog(@"AppDelegate: didRegisterForRemoteNotificationsWithDeviceToken: was called");
  // Send device token to server
}

// Handles registration for remote notifications (e.g., push notifications). 
// While more common in iOS, macOS applications can also use these for similar purposes.
- (void)application:(NSApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
  NSLog(@"AppDelegate: didFailToRegisterForRemoteNotificationsWithError: was called");
  // Handle the failure
}

// Handles a single URL opening request. Note that this method is 
// deprecated and replaced by application:openURLs: in newer macOS versions.
- (BOOL)application:(NSApplication *)sender handleOpenURL:(NSURL *)url
{
  NSLog(@"AppDelegate: handleOpenURL: was called");

  // Handle the URL
  return YES;
}

// Allows the delegate to customize error presentation to the user.
- (NSError *)application:(NSApplication *)app willPresentError:(NSError *)error
{
  NSLog(@"AppDelegate: willPresentError: was called");
  // Customize error before it’s presented
  return nil;
}

// Allows the delegate to customize to respond after an error has been presented to the user.
- (void)application:(NSApplication *)app didPresentError:(NSError *)error
{
  NSLog(@"AppDelegate: didPresentError: was called");
  // Perform actions after error presentation
}

@end