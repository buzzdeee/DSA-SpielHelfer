/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-09-19 22:03:00 +0200 by sebastia

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

#import "DSACharacterViewModel.h"
#import "DSACharacterHero.h"

@implementation DSACharacterViewModel

- (void)setModel:(DSACharacterHero *)model {
    if (_model != model) {
        // Remove observers from the old model
        [_model removeObserver:self forKeyPath:@"lifePoints"];
        [_model removeObserver:self forKeyPath:@"currentLifePoints"];
        [_model removeObserver:self forKeyPath:@"astralEnergy"];
        [_model removeObserver:self forKeyPath:@"currentAstralEnergy"];
        [_model removeObserver:self forKeyPath:@"karmaPoints"];
        [_model removeObserver:self forKeyPath:@"currentKarmaPoints"];
        [_model removeObserver:self forKeyPath:@"money.D"];                
        [_model removeObserver:self forKeyPath:@"money.S"];
        [_model removeObserver:self forKeyPath:@"money.K"];
        [_model removeObserver:self forKeyPath:@"money.H"];        
        _model = model;
        
        // Add observers for the new model
        [_model addObserver:self forKeyPath:@"lifePoints" options:NSKeyValueObservingOptionNew context:NULL];
        [_model addObserver:self forKeyPath:@"currentLifePoints" options:NSKeyValueObservingOptionNew context:NULL];
        [_model addObserver:self forKeyPath:@"astralEnergy" options:NSKeyValueObservingOptionNew context:NULL];
        [_model addObserver:self forKeyPath:@"currentAstralEnergy" options:NSKeyValueObservingOptionNew context:NULL];
        [_model addObserver:self forKeyPath:@"karmaPoints" options:NSKeyValueObservingOptionNew context:NULL];
        [_model addObserver:self forKeyPath:@"currentKarmaPoints" options:NSKeyValueObservingOptionNew context:NULL];
        [_model addObserver:self forKeyPath:@"money.D" options:NSKeyValueObservingOptionNew context:NULL];
        [_model addObserver:self forKeyPath:@"money.S" options:NSKeyValueObservingOptionNew context:NULL];
        [_model addObserver:self forKeyPath:@"money.H" options:NSKeyValueObservingOptionNew context:NULL];
        [_model addObserver:self forKeyPath:@"money.K" options:NSKeyValueObservingOptionNew context:NULL];
                                                        
        // Synchronize the ViewModel's properties with the model's properties
        
        self.money = _model.money;
        [self updateFormattedMoney];
        
        self.lifePoints = _model.lifePoints;
        self.currentLifePoints = _model.currentLifePoints;     
        [self updateFormattedLifePoints];

        self.astralEnergy = _model.astralEnergy;
        self.currentAstralEnergy = _model.currentAstralEnergy;        
        [self updateFormattedAstralEnergy];

        self.karmaPoints = _model.karmaPoints;
        self.currentKarmaPoints = _model.currentKarmaPoints;        
        [self updateFormattedKarmaPoints];
                
                
    }
}

- (void)updateFormattedMoney
{
  NSLog(@"updateFormattedMoney %@", self.money);
  NSString *formattedString = [NSString stringWithFormat:@"%@D %@S %@H %@K",
                               self.money[@"D"] ?: @"0",
                               self.money[@"S"] ?: @"0",
                               self.money[@"H"] ?: @"0",
                               self.money[@"K"] ?: @"0"];
  NSLog(@"updateFormattedMoney %@", self.money);                               
  self.formattedMoney = formattedString;
}

- (void)updateFormattedLifePoints {
    NSString *formattedString = [NSString stringWithFormat:@"%@/%@",
                                 self.currentLifePoints ?: @0,
                                 self.lifePoints ?: @0];
    NSLog(@"updateFormattedLifePoints: %@", formattedString);                               
    self.formattedLifePoints = formattedString;
}

- (void) updateFormattedAstralEnergy
{
  NSString *formattedString = [NSString stringWithFormat:@"%@/%@",
                               self.currentAstralEnergy ?: @0,
                               self.astralEnergy ?: @0];
  NSLog(@"updateFormattedAstralEnergy: %@", formattedString);                                
  self.formattedAstralEnergy = formattedString;                               
}

- (void) updateFormattedKarmaPoints
{
  NSString *formattedString = [NSString stringWithFormat:@"%@/%@",
                               self.currentKarmaPoints ?: @0,
                               self.karmaPoints ?: @0];
  NSLog(@"updateFormattedKarmaPoints: %@", formattedString);                               
  self.formattedKarmaPoints = formattedString;                               
}

- (void)observeValueForKeyPath:(NSString *)keyPath 
                      ofObject:(id)object 
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change 
                       context:(void *)context
{
  NSLog(@"DSACharacterViewModel observeValueForKeyPath: %@", keyPath);
  if ([keyPath hasPrefix:@"money."])
    {
      [self updateFormattedMoney];
    }
        
  if ([keyPath isEqualToString:@"lifePoints"])
    {
      // Update ViewModel's lifePoints when model's lifePoints changes
      self.lifePoints = _model.lifePoints;
      [self updateFormattedLifePoints];
    }
  else if ([keyPath isEqualToString:@"currentLifePoints"])
    {
      // Update ViewModel's currentLifePoints when model's currentLifePoints changes
      self.currentLifePoints = _model.currentLifePoints;
      [self updateFormattedLifePoints];
    }  
  else if ([keyPath isEqualToString:@"astralEnergy"])
    {
      // Update ViewModel's lifePoints when model's lifePoints changes
      self.astralEnergy = _model.astralEnergy;
      [self updateFormattedAstralEnergy];
    } 
  else if ([keyPath isEqualToString:@"currentAstralEnergy"])
    {
      // Update ViewModel's currentLifePoints when model's currentLifePoints changes
      self.currentAstralEnergy = _model.currentAstralEnergy;
      [self updateFormattedAstralEnergy];
    } 
  else if ([keyPath isEqualToString:@"karmaPoints"])
    {
      // Update ViewModel's lifePoints when model's lifePoints changes
      self.karmaPoints = _model.karmaPoints;
      [self updateFormattedKarmaPoints];
    }
  else if ([keyPath isEqualToString:@"currentKarmaPoints"])
    {
      // Update ViewModel's currentLifePoints when model's currentLifePoints changes
      self.currentKarmaPoints = _model.currentKarmaPoints;
      [self updateFormattedKarmaPoints];
    }           
}

- (void)dealloc
{
  [_model removeObserver:self forKeyPath:@"money.D"];
  [_model removeObserver:self forKeyPath:@"money.S"];
  [_model removeObserver:self forKeyPath:@"money.H"];
  [_model removeObserver:self forKeyPath:@"money.K"];
    
  [_model removeObserver:self forKeyPath:@"lifePoints"];
  [_model removeObserver:self forKeyPath:@"currentLifePoints"];
  [_model removeObserver:self forKeyPath:@"AstralEnergy"];
  [_model removeObserver:self forKeyPath:@"currentAstralEnergy"];
  [_model removeObserver:self forKeyPath:@"karmaPoints"];
  [_model removeObserver:self forKeyPath:@"currentKarmaPoints"];
}

@end
