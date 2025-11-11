/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-07-20 15:35:26 +0200 by sebastia

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

#ifndef _DSADEFINITIONS_H_
#define _DSADEFINITIONS_H_

#import <Foundation/Foundation.h>

#pragma mark - Executable Descriptor Protocol

@protocol DSAExecutableDescriptor <NSObject>

/// Reihenfolge der Ausführung.
/// Niedrigere Werte werden zuerst ausgeführt.
/// Gleiche Werte bedeuten "gleichzeitig / parallel".
@property (nonatomic, assign, readonly) NSInteger order;

@end


typedef NS_ENUM(NSInteger, DSAActionType) {
    DSAActionTypeUnknown = 0,
    DSAActionTypeGainItem,
    DSAActionTypeGainMoney,
    DSAActionTypeLeaveLocation,                      // leaving a position, i.e. a building or dungeon
    DSAActionTypeGainFood,
    DSAActionTypeGainWater,
    DSAActionTypeGainSpices,
    // weitere ActionTypes …
};

#pragma mark - Event Types

typedef NS_ENUM(NSInteger, DSAEventType) {
    DSAEventTypeUnknown = 0,
    DSAEventTypeLocationBan,                         // we're banned at a given Location/position
    // weitere EventTypes …
};


typedef NS_ENUM(NSInteger, LogSeverity) {
    LogSeverityInfo,
    LogSeverityHappy,
    LogSeverityWarning,
    LogSeverityCritical
};

typedef NS_ENUM(NSUInteger, DSASeverityLevel) {
    DSASeverityLevelNone = 0,
    DSASeverityLevelMild,
    DSASeverityLevelModerate,
    DSASeverityLevelSevere
};

typedef NS_ENUM(NSUInteger, DSAObjectMagicState) {
    DSAObjectMagicStateNone = 0,       // definitely not magic
    DSAObjectMagicStateUnknown,        // it's magic, but we don't know about it
    DSAObjectMagicStateMagic,          // we know it's magic, but no details (for example after Odem Arcanum)
    DSAObjectMagicStateMagicDetails,   // we know it's magic, and know it's details about it (for example after Analüs)
};

// Used in various actions, i.e. talents, spells, rituals etc.
// to give a hint to the UI what are the relevant targets to present to the user
typedef NS_ENUM(NSInteger, DSAActionTargetType) {
    DSAActionTargetTypeNone = 0,             // Kein Ziel notwendig, der Spruch weiss selbst, worauf er abzielt
    DSAActionTargetTypeAny,                  // Kann jeglicher DSACharacter oder DSAObject sein...
    DSAActionTargetTypeSelf,                 // actor == target
    DSAActionTargetTypeEnemy,                // Gegner
    DSAActionTargetTypeAlly,                 // Gruppenmitglied oder Verbündeter
    DSAActionTargetTypeHuman,                // Menschen
    DSAActionTargetTypeAnimal,               // Tiere
    DSAActionTargetTypeObject,               // Allgemein einzelnes Objekt
    DSAActionTargetTypeObjects,              // alle Objekte im Inventory aller Gruppenmitglieder
    DSAActionTargetTypeObjectLock,           // Schlösser von Türen oder Kisten etc.
    DSAActionTargetTypeActiveGroupMember,    // Gruppenmitglied
};

typedef NS_ENUM(NSUInteger, DSAActionResultValue)
{
  DSAActionResultNone,             // no result yet
  DSAActionResultSuccess,          // normal success
  DSAActionResultAutoSuccess,      // two times 1 as dice result
  DSAActionResultEpicSuccess,      // three times 1 as dice result
  DSAActionResultFailure,          // normal failure
  DSAActionResultAutoFailure,      // two times 20 as dice result
  DSAActionResultEpicFailure       // three times 20 as dice result
};


// The following is used to steer the DSAActionViewController
typedef NS_ENUM(NSInteger, DSAActionViewMode) {
    DSAActionViewModeTalent,
    DSAActionViewModeSpell,
    DSAActionViewModeRitual
};

// This is used to parameterize talents, spells etc. to allow the UI to ask the user for specific parameters.
typedef NS_ENUM(NSUInteger, DSAActionParameterType) {
    DSAActionParameterTypeInteger,
    DSAActionParameterTypeBoolean,
    DSAActionParameterTypeChoice,
    DSAActionParameterTypeText,
    DSAActionParameterTypeActiveGroup          // no need to ask the user
};

NSArray<NSString *> *DSAShopGeneralStoreCategories(void);
NSArray<NSString *> *DSAShopHerbsStoreCategories(void);
NSArray<NSString *> *DSAShopWeaponStoreCategories(void);

typedef NS_ENUM(NSInteger, DSAPoisonType) {
    DSAPoisonTypeUnknown = 0,
    DSAPoisonTypeOral,
    DSAPoisonTypeContact,
    DSAPoisonTypeWeapon,
    DSAPoisonTypeInhalation,
    DSAPoisonTypeInjection,
};

typedef NS_ENUM(NSUInteger, DSAIllnessStage) {
  DSAIllnessStageIncubation,
  DSAIllnessStageActiveUnknown,
  DSAIllnessStageActiveIdentified,
  DSAIllnessStageUnderTreatment,
  DSAIllnessStageChronicInactive,
  DSAIllnessStageChronicActive
};

typedef NS_ENUM(NSUInteger, DSAPoisonStage) {
    DSAPoisonStageApplied,           // Gift wurde appliziert, aber Latenz läuft noch
    DSAPoisonStageLatent,            // Wartet auf Wirkungseintritt (Beginn in KR/SR)
    DSAPoisonStageActive,            // Gift wirkt – regelmäßiger Schaden o.Ä.
    DSAPoisonStageExpired,           // Wirkung ist ausgelaufen
    DSAPoisonStageNeutralized,       // Durch Gegengift etc. neutralisiert
    DSAPoisonStageSuppressed         // Wirkung unterdrückt (z. B. Alchimie/Zauber), aber noch im Körper
};

typedef NS_ENUM(NSInteger, DSADrunkenLevel) {
  DSADrunkenLevelNone,           // Not drunken
  DSADrunkenLevelLight,          // lightly drunken
  DSADrunkenLevelMedium,         // a bit more drunken
  DSADrunkenLevelSevere          // severely drunken
};

typedef NS_ENUM(NSInteger, DSATimeInterval) {
    DSATimeIntervalUnknown = 0,
    DSATimeIntervalKR,          // Kampfrunde, ca. 5 Sekunden
    DSATimeIntervalSR,          // Spielrunde, ca. 1 Minute
    DSATimeIntervalMinute,
    DSATimeIntervalHour,
    DSATimeIntervalDay,
    DSATimeIntervalWeek,
    DSATimeIntervalMonth,
    DSATimeIntervalYear,
};

#pragma mark - DSAConsumption related typedefs

typedef NS_ENUM(NSInteger, DSAConsumptionType) {
    DSAConsumptionTypeUseOnce,   // 1x nutzbar -> verschwindet sofort
    DSAConsumptionTypeUseMany,   // x mal nutzbar -> maxUses > 1
    DSAConsumptionTypeUseForever,// unendlich nutzbar
    DSAConsumptionTypeExpiry     // Ablaufdatum (z.B. Gift)
};

typedef NS_ENUM(NSInteger, DSAConsumptionFailReason) {
    DSAConsumptionFailReasonNone = 0,   // Erfolg
    DSAConsumptionFailReasonNoUsesLeft, // Nutzungsanzahl aufgebraucht
    DSAConsumptionFailReasonExpired,    // Haltbarkeit abgelaufen
    DSAConsumptionFailReasonInvalidType // Unbekannt oder nicht nutzbar
};


// zentrale Liste aller Actions
#define DSA_USE_OBJECT_WITH_ACTION_TYPES \
    X(DSAUseObjectWithActionTypeSmoking) \
    X(DSAUseObjectWithActionTypePoisoning) \
    X(DSAUseObjectWithActionTypeWeaponMaintenance) \
    X(DSAUseObjectWithActionTypeConsuming)

// Enum-Definition
typedef NS_ENUM(NSInteger, DSAUseObjectWithActionType) {
#define X(name) name,
    DSA_USE_OBJECT_WITH_ACTION_TYPES
#undef X
};

/*
// To distinguish what should happen, when using one type of object with another
typedef NS_ENUM(NSInteger, DSAUseObjectWithActionType) {
    DSAUseObjectWithActionTypeSmoking = 0,   // Rauchen
    DSAUseObjectWithActionTypePoisoning,     // Vergiften
    DSAUseObjectWithActionTypeWeaponMaintenance // Haltbarkeit abgelaufen
};
*/

// Funktionsdeklarationen (für globalen Zugriff) implementiert in Utils.m
FOUNDATION_EXPORT NSString *NSStringFromDSAUseObjectWithActionType(DSAUseObjectWithActionType type);
FOUNDATION_EXPORT DSAUseObjectWithActionType DSAUseObjectWithActionTypeFromString(NSString *string);

#pragma mark - DSASlot and Inventory related typedefs

typedef NS_ENUM(NSUInteger, DSASlotType) {
    DSASlotTypeGeneral,                         // can hold anything
    DSASlotTypeUnderwear,                       // will hold underwear
    DSASlotTypeBodyArmor,                       // holds armor on upper body
    DSASlotTypeHeadgear,                        // holds headgear, i.e. helmet, cap etc.
    DSASlotTypeShoes,                           // holds shoes
    DSASlotTypeNecklace,                        // holds necklaces, medaillons
    DSASlotTypeEarring,                         // holds earrings
    DSASlotTypeNosering,                        // holds noserings
    DSASlotTypeGlasses,                         // holds glasses
    DSASlotTypeMask,                            // holds mask
    DSASlotTypeBackpack,                        // holds backpacks on the back of character
    DSASlotTypeBackquiver,                      // holds quivers on the back of character
    DSASlotTypeSash,                            // holds Schärpe, or shoulder band
    DSASlotTypeArmArmor,                        // armor at the arms
    DSASlotTypeArmRing,                         // ring for the hand anckles
    DSASlotTypeGloves,                          // holds gloves at hands
    DSASlotTypeHip,                             // to hold belts etc.
    DSASlotTypeRing,                            // to hold rings on fingers
    DSASlotTypeVest,                            // to hold vests on upper body
    DSASlotTypeShirt,                           // to hold shirts, blouse etc.
    DSASlotTypeJacket,                          // to hold jackets, robe, etc.
    DSASlotTypeLegbelt,                         // to hold belt on legs
    DSASlotTypeLegArmor,                        // to hold armor on legs
    DSASlotTypeTrousers,                        // to hold trousers
    DSASlotTypeSocks,                           // to hold socks
    DSASlotTypeShoeaccessories,                 // to hold spurs, skies, snowshoes
    DSASlotTypeBag,                             // an ordinary bag, anything that can goes into a bag
    DSASlotTypeBasket,                          // an ordinary basket, holds anything that can go into a basket
    DSASlotTypeQuiver,                          // a quiver for arrows
    DSASlotTypeBoltbag,                         // a quiver/bag for bolts
    DSASlotTypeLiquid,                          // something to hold liquids
    DSASlotTypeSword,                           // a shaft to hold swords
    DSASlotTypeDagger,                          // a shaft to hold daggers 
    DSASlotTypeAxe,                             // a special thing to hold axes
    DSASlotTypeMoney,                           // to hold money
    DSASlotTypeTobacco,                         // to hold tobacco
    DSASlotTypeWater,
    // Add other specific types as needed
};

#pragma mark - DSAObject related typedefs

typedef NS_ENUM(NSUInteger, DSAObjectState)
{
  DSAObjectStateIsUnbreakable,                // object is not destroyable
  DSAObjectStateIsBroken,                     // object is broken
  DSAObjectStateIsPoisoned,                   // object is poisoned
  DSAObjectStateHasSpellActive,               // object has a magic spell activated
  DSAObjectStateIsMagicUnknown,               // object is magic, but it's unknown which spells/rituals are applied
  DSAObjectStateIsConsumable,                 // object can be consumed i.e. eaten or drunk
  DSAObjectStateIsDepletable,                 // can be used up, after a while, i.e. soap, ...
  DSAObjectStateIsAlcoholic,                  // contains alcohol
  DSAObjectStateHasShelfLife,                 // Objekt hat Verfallsdatum
  DSAObjectStateStabzauberFackel,             // torch Stabzauber is active
  DSAObjectStateStabzauberSeil,               // rope Stabzauber is active
  DSAObjectStateNoMoreStabzauber,             // Stabzauber 5 failed, no more Stabzauber possible
  DSAObjectStateStabzauberTierverwandlung,    // Stabzauber 6 verwandlung in Chamäleon oder Speikobra
  DSAObjectStateKugelzauberBrennglas,         // Kugelzauber 2, Kugel ist zu einem Brennglas verwandelt
  DSAObjectStateKugelzauberSchutzfeld,        // Kugelzauber 3, Kugel erzeugt Schutzfeld gegen Untote etc.
  DSAObjectStateKugelzauberWarnung,           // Kugelzauber 4, Warnung vor Haß und Mordlust
  DSAObjectStateIsNotMagic,                   // the object doesn't have any spells applied and therefore isn't magic
  DSAObjectStateIsMagicKnown,                 // we know that the object is magic, but no details (i.e. after Odem Arcanum)
  DSAObjectStateIsMagicKnownDetails,          // we know that the object is magic, and we know the details (i.e. after Analüs)
};

typedef NS_ENUM(NSInteger, DSAObjectEffectType)
{
  DSAObjectEffectTypePoisoned                 // poison applied onto object
};

#pragma mark - DSACharacter related typedefs

typedef NS_ENUM(NSUInteger, DSACharacterState)
{
  DSACharacterStateWounded,                 // the character is wounded
  DSACharacterStateSick,                    // if the character is sick
  DSACharacterStateDrunken,                 // the level of drunkenes
  DSACharacterStatePoisoned,                // if the character is poisoned
  DSACharacterStateDead,                    // the character is dead
  DSACharacterStateUnconscious,             // the character is unconscious
  DSACharacterStateSpellbound,              // a spell was casted onto the character
  DSACharacterStateHunger,                  // level of hunger
  DSACharacterStateThirst,                  // level of thirst
};

typedef NS_ENUM(NSUInteger, DSASleepQuality)
{
    DSASleepQualityTerrible,    // z. B. in der Gosse, nass, voller Ungeziefer
    DSASleepQualityLousy,       // unbequem, laut, kalt – kaum erholsam
    DSASleepQualityMediocre,    // akzeptabel, aber nicht gut (z. B. Lager ohne Decke)
    DSASleepQualityNormal,      // Standardherberge oder Feldbett mit Decke
    DSASleepQualityGood,        // ruhiges Zimmer, gutes Bett, warm, trocken
    DSASleepQualityExcellent,   // luxuriöse Suite, Duftöle, Federn, evtl. Bonus durch Zauber o.ä.
    DSASleepQualityUnknown
};

typedef NS_ENUM(NSInteger, DSACharacterEffectType) {
    DSACharacterEffectTypeTraitBoost,                    // basic traits are boosted
    DSACharacterEffectTypeTalentBoost,                   // talents are boosted
    DSACharacterEffectTypeMagicBoost,                    // a spell is boosted, or all spells ???
    DSACharacterEffectTypeTalentAutoSuccess,             // Auto success for a given talent
    DSACharacterEffectTypeMRBoost,                       // Magic Resistance boost
    DSACharacterEffectTypeMagicProtection,               // protection against magic
    DSACharacterEffectTypeSeaProtection,                 // protection when travelling on the sea
    DSACharacterEffectTypeRemoveCurse,                   // this removes an applied curse
    DSACharacterEffectTypeCureDisease,                   // this heals a disease/illness
    DSACharacterEffectTypeRevive,                        // a character is revived from dead
    DSACharacterEffectTypeSatiation,                     // thirst and hunger will vanish
    DSACharacterEffectTypeNoHungerThirst,                // no hunger and thirst for a given amount of time
    DSACharacterEffectTypeHeal,                          // some LE get restored
    DSACharacterEffectTypeFullHeal,                      // full LE healing
    DSACharacterEffectTypeNightPeace,                    // sleep well at night, without attacks
    DSACharacterEffectTypeProtectionAgainstUndead,       // undeads won't harm
    DSACharacterEffectTypeFearOfDead,                    // TA goes down
    DSACharacterEffectTypeWeaponBlessing,                // weapon "healing" ;)
    DSACharacterEffectTypeUpgradeWeaponToMagic,          // weapon becomes magic
    DSACharacterEffectTypeEnchantWeapon,                 // weapon becomes magic
    DSACharacterEffectTypeRepairAndEnchant,              // weapon repaired and magic
    DSACharacterEffectTypePlaceholder,                   // what's that?
    DSACharacterEffectTypeRoomBooked,                    // has a room booked in an inn
    DSACharacterEffectTypeIllness,                       // character is sick/ill 
    DSACharacterEffectTypePoison,                        // character is poisoned
    DSACharacterEffectTypeDrunken,                       // character is drunken
    DSACharacterEffectTypeNothing
};

typedef NS_ENUM(NSInteger, DSALocalMapTileBuildingInnFillLevel) {
    DSALocalMapTileBuildingInnFillLevelEmpty = 0,        // almost no guests
    DSALocalMapTileBuildingInnFillLevelNormal = 1,       // average crowd
    DSALocalMapTileBuildingInnFillLevelBusy = 2,         // many guests
    DSALocalMapTileBuildingInnFillLevelPacked = 3        // completely full
};

// used to describe origin/source of a wound
typedef NS_ENUM(NSInteger, DSAWoundSource) {
    DSAWoundSourceUnknown = 0,
    DSAWoundSourceWeapon,
    DSAWoundSourceAnimalBite,
    DSAWoundSourceClaw,
    DSAWoundSourceAccident,
    DSAWoundSourceBurn,
    DSAWoundSourcePoison,
    DSAWoundSourceMagic,
};

typedef NS_ENUM(NSUInteger, DSAShopMode) {
    DSAShopModeBuy,
    DSAShopModeSell
};

// in case the wound if of an animal, describe it here
typedef NS_ENUM(NSInteger, DSAAnimalType) {
    DSAAnimalTypeUnknown = 0,
    DSAAnimalTypeWolf,
    DSAAnimalTypeRat,
    DSAAnimalTypeBat,
    DSAAnimalTypeBear,
    DSAAnimalTypeDog,
    DSAAnimalTypeCat,
};

// See Enzyklopaedia Aventurica p. 69
typedef NS_ENUM(NSInteger, DSARouteType) {
    DSARouteTypeRS,        // "RS"
    DSARouteTypeLS,        // "LS"    
    DSARouteTypeWeg,       // "Weg"
    DSARouteTypeOffenesGelaendePfad,    // "Offenes Gelände, Pfad"
    DSARouteTypeOffenesGelaende,
    DSARouteTypeLichterWaldPfad,
    DSARouteTypeLichterWald,
    DSARouteTypeWaldPfad,
    DSARouteTypeWald,
    DSARouteTypeDichterWaldPfad,
    DSARouteTypeDichterWald,
    DSARouteTypeGebirgePassstrecke,    // Gebirgspass
    DSARouteTypeGebirgePfad,
    DSARouteTypeGebirgeKeinKlettern,
    DSARouteTypeHochgebirgeMitKlettern,
    DSARouteTypeRegenwaldPfad,
    DSARouteTypeRegenwald,
    DSARouteTypeRegenwaldGebirge,
    DSARouteTypeSumpfKnueppeldamm,
    DSARouteTypeSumpfPfad,
    DSARouteTypeSumpf,
    DSARouteTypeEisgebietFreieFlaeche,
    DSARouteTypeEisgebietTiefschnee,
    DSARouteTypeEisgebietEisflaeche,
    DSARouteTypeEisgebirgeGletscher,
    DSARouteTypeGeroellwueste,
    DSARouteTypeSandwueste,
    DSARouteTypeFaehre,                  // "Fähre"
    DSARouteTypeSeeschiff,
    DSARouteTypeFlussschiff,
};

typedef NS_ENUM(NSInteger, DSATravelEventType) {
    DSATravelEventNone = 0,
    DSATravelEventCombat,
    DSATravelEventAnimal,
    DSATravelEventMerchant,
    DSATravelEventTraveler,
    DSATravelEventTrailSign,
    DSATravelEventWeatherShift,
    DSATravelEventRoadObstacle,
    DSATravelEventScenery,
    DSATravelEventHerbs,
    DSATravelEventLost,
};

typedef NS_ENUM(NSInteger, DSAEncounterType) {
    DSAEncounterTypeUnknown = 0,
    DSAEncounterTypeHostile,
    DSAEncounterTypeAnimal,
    DSAEncounterTypeMerchant,
    DSAEncounterTypeHerbs,
    DSAEncounterTypeFriendlyNPC
};

typedef NSString * DSAActionContext;
extern DSAActionContext const DSAActionContextResting;
extern DSAActionContext const DSAActionContextPrivateRoom;
extern DSAActionContext const DSAActionContextTavern;
extern DSAActionContext const DSAActionContextMarket;
extern DSAActionContext const DSAActionContextOnTheRoad;
extern DSAActionContext const DSAActionContextReception;
extern DSAActionContext const DSAActionContextTravel;
extern DSAActionContext const DSAActionContextEncounter;

typedef NSString * DSANotificationType;
extern DSANotificationType const DSAAdventureTravelDidBeginNotification;
extern DSANotificationType const DSAAdventureTravelDidProgressNotification;
extern DSANotificationType const DSAAdventureTravelRestingNotification;
extern DSANotificationType const DSAAdventureTravelDidEndNotification;
extern DSANotificationType const DSATravelEventTriggeredNotification;

extern DSANotificationType const DSAEncounterTriggeredNotification; // posted by DSAEncounterManager
extern DSANotificationType const DSAEncounterWillStartNotification; // optional: before UI changes
extern DSANotificationType const DSAEncounterManagerDidChangeTerrain; // optional


#endif // _DSADEFINITIONS_H_

