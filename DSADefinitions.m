/*
   Project: DSA-SpielHelfer

   Copyright (C) 2025 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2025-11-04 20:34:13 +0100 by sebastia

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

#import "DSADefinitions.h"

DSAActionContext const DSAActionContextResting = @"Rasten";
DSAActionContext const DSAActionContextPrivateRoom = @"Zimmer";
DSAActionContext const DSAActionContextTavern = @"Taverne";
DSAActionContext const DSAActionContextMarket = @"Markt";
DSAActionContext const DSAActionContextOnTheRoad = @"Unterwegs";
DSAActionContext const DSAActionContextReception = @"Rezeption";
DSAActionContext const DSAActionContextTravel = @"Reisen";
DSAActionContext const DSAActionContextTravelEncounter = @"ReiseBegegnung";

DSANotificationType const DSAAdventureTravelDidBeginNotification = @"DSAAdventureTravelDidBegin";
DSANotificationType const DSAAdventureTravelDidProgressNotification = @"DSAAdventureTravelDidProgress";
DSANotificationType const DSAAdventureTravelRestingNotification = @"DSAAdventureTravelResting";
DSANotificationType const DSAAdventureTravelDidEndNotification = @"DSAAdventureTravelDidEnd";
DSANotificationType const DSATravelEventTriggeredNotification = @"DSATravelEventTriggered";

DSANotificationType const DSAEncounterTriggeredNotification = @"DSAEncounterTriggered";
DSANotificationType const DSAEncounterWillStartNotification = @"DSAEncounterWillStart";
DSANotificationType const DSAEncounterManagerDidChangeTerrain = @"DSAEncounterManagerDidChangeTerrain";


