/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-06-12 21:42:00 +0200 by sebastia

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

#import "DSAShopBargainController.h"
#import "DSAAdventureGroup.h"
#import "DSACharacter.h"
#import "DSAActionResult.h"


@implementation DSAShopBargainController

- (void)windowDidLoad {
    NSLog(@"DSAShopBargainController windowDidLoad called, window: %@", self.window);
    [super windowDidLoad];
    [self.fieldBargainResult setStringValue: @""];
    self.bargainRound = 0;
    [self.popupCharacter removeAllItems];
    for (NSUUID *uuid in self.activeGroup.partyMembers)
      {
        DSACharacter *character = [DSACharacter characterWithModelID: uuid];
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle: [character name]
                                                      action: NULL
                                               keyEquivalent: @""];
        [item setRepresentedObject: character];
        [[self.popupCharacter menu] addItem: item];
      }
    for (NSUUID *uuid in self.activeGroup.npcMembers)
      {
        DSACharacter *character = [DSACharacter characterWithModelID: uuid];
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle: [character name]
                                                      action: NULL
                                               keyEquivalent: @""];
        [item setRepresentedObject: character];
        [[self.popupCharacter menu] addItem: item];
      }
    [self.popupCharacter selectItemAtIndex: 0];
}

- (IBAction)sliderValueChanged:(NSSlider *)sender {
    double value = sender.doubleValue;
    self.fieldPercentValue.stringValue = [NSString stringWithFormat:@"%.0f", value];
}

- (IBAction)buttonConfirmClicked:(id)sender {
    NSLog(@"DSAShopBargainController buttonConfirm");
    BOOL result = NO;
    DSACharacter *character = [[self.popupCharacter selectedItem] representedObject];
    DSAActionResult *talentResult;
    if ([self.fieldPercentValue.stringValue floatValue] == 0)
      {
        NSLog(@"DSAShopBargainController buttonConfirmClicked, 0%%, no need to bargain");
        talentResult = [[DSAActionResult alloc] init];
        talentResult.result = DSAActionResultEpicSuccess;
      }
    else
      {
        talentResult = [character useTalent: @"Feilschen" withPenalty: roundf([self.fieldPercentValue.stringValue floatValue] / 10)];
      }
    NSArray *failedBargainResponses = @[
      @"Das ist leider zu wenig – das kann ich nicht machen.",
      @"Da kommen wir heute wohl nicht ins Geschäft.",
      @"Tut mir leid, das ist mein letzter Preis.",
      @"Ich fürchte, da liegst du daneben.",
      @"Ich mache auch Verluste, wenn ich zu billig verkaufe.",
    
      @"Willst du’s geschenkt haben, oder was?!",
      @"Versuch’s beim nächsten Krämer – der verkauft vielleicht an Narren.",
      @"Mach keine Faxen, das ist ehrliche Ware!",
      @"Ich hab keine Zeit für solche Spielchen.",
      @"Wenn du kein Geld hast, dann schau nur, nicht handeln!",
    
      @"Ein echter Feilscher! Nur leider ohne Talent.",
      @"Hahaha – guter Witz! Aber ernsthaft jetzt: Mein Preis?",
      @"So billig? Dann musst du wohl selbst auf Schatzsuche gehen.",
      @"Für das Geld kriegst du nicht mal einen Apfel – ohne Wurm!",
    
      @"Bei den Zwölfen – du willst wohl meinen Ruin!",
      @"Thorwaler mögen’s hart, aber nicht dumm. Kein Handel.",
      @"Das ist kein Basar, das ist ein Geschäft!"
    ];    
    
    NSArray *successfulBargainResponses = @[
      @"Na schön, du hast mich überzeugt – der Handel steht!",
      @"Hmpf... du verhandelst gut. Abgemacht!",
      @"Für dich mach ich eine Ausnahme. Einverstanden.",
      @"Deal. Aber nur weil du heute so charmant bist.",
      @"Du treibst ein hartes Geschäft – aber ich mag das.",
    
      @"In Ordnung, aber erzähl niemandem, was du gezahlt hast.",
      @"Ha! Du hast Talent – das ist ein fairer Preis.",
      @"So sei es – die Zwölfe mögen deinen Handel segnen.",
      @"Also gut. Ich will nicht kleinlich sein.",
      @"Ein Handel unter Ehrenleuten – abgemacht!",
    
      @"Du solltest öfter hier vorbeikommen. Ich mag deinen Stil.",
      @"Schlag ein – Geschäft gemacht!",
      @"Ich hätte nicht gedacht, dass ich nachgebe… aber gut gemacht.",
      @"Du bist ein besserer Feilscher als ich dachte.",
      @"Ein guter Handel – für uns beide!"
    ];  
    if (talentResult.result == DSAActionResultSuccess ||
        talentResult.result == DSAActionResultAutoSuccess ||
        talentResult.result == DSAActionResultEpicSuccess)
      {
        [self.fieldBargainResult setStringValue: successfulBargainResponses[arc4random_uniform((uint32_t)successfulBargainResponses.count)]];
        result = YES;
      }
    
    if (result == NO)
      {
        [self.fieldBargainResult setStringValue: failedBargainResponses[arc4random_uniform((uint32_t)failedBargainResponses.count)]];
        self.bargainRound++;
        if (self.bargainRound < 3)
          {
            return;  // Three chances!!!
          }
      }
      
    if (self.completionHandler) {
        self.completionHandler(result);  // ⬅️ invoke handler before closing sheet
    }    
    [NSApp endSheet:self.window];
    [self.window orderOut:nil];
}
@end
