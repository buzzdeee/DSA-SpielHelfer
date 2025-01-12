/* 
   Project: DSA-SpielHelfer

   Author: Sebastian Reitenbach

   Created: 2024-09-07 23:14:39 +0200 by sebastia
   
   Application Controller
*/
 
#ifndef _PCAPPPROJ_APPCONTROLLER_H
#define _PCAPPPROJ_APPCONTROLLER_H

#import <AppKit/AppKit.h>

@class DSACharacterGenerationController;
@class DSAMapViewController;
@class DSAEquipmentListViewController;
@class DSANameGenerationController;

@interface AppController : NSObject



@property (strong) DSACharacterGenerationController *characterGenController;
@property (nonatomic, strong) DSAMapViewController *mapViewController; // Retain the map view controller
@property (nonatomic, strong) DSAEquipmentListViewController *equipmentListViewController; // Retain the equipment view controller
@property (nonatomic, strong) DSANameGenerationController *nameGenerationController; // Retain the equipment view controller
@property (nonatomic, weak) IBOutlet NSMenuItem *levelUpMenuItem;


+ (void)  initialize;

- (id) init;
- (void) dealloc;

- (void) showPrefPanel: (id)sender;

// called by the AppDelegate on startup
- (void)setupApplication;



@end

#endif
