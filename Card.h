//
//  Card.h
//  PokerEval
//
//  Created by Seth Faxon on 9/12/09.
//  Copyright 2009 Slash and Burn. All rights reserved.
//

#import <Foundation/Foundation.h>

static const uint CARD_RANK2     = 0;
static const uint CARD_RANK3     = 1;
static const uint CARD_RANK4     = 2; 
static const uint CARD_RANK5     = 3; 
static const uint CARD_RANK6     = 4; 
static const uint CARD_RANK7     = 5; 
static const uint CARD_RANK8     = 6; 
static const uint CARD_RANK9     = 7; 
static const uint CARD_RANK_TEN   = 8;
static const uint CARD_RANK_JACK  = 9;
static const uint CARD_RANK_QUEEN = 10;
static const uint CARD_RANK_KING  = 11;
static const uint CARD_RANK_ACE   = 12;

static const uint RANK_FIRST = 0;
static const uint RANK_LAST  = 12; 

static const uint CARD_SUIT_SPADES     = 3;
static const uint CARD_SUIT_HEARTS     = 2; 
static const uint CARD_SUIT_DIAMONDS   = 1; 
static const uint CARD_SUIT_CLUBS      = 0;

static const uint SUIT_LAST  = 3; 
static const uint SUIT_FIRST = 0; 

static const uint SPADE_OFFSET   = 16 * 3; 
static const uint HEART_OFFSET   = 16 * 2;
static const uint DIAMOND_OFFSET = 16 * 1;
static const uint CLUB_OFFSET    = 16 * 0;
static const uint SUIT_OFFSET_FIRST = 16 * 0; 
static const uint SUIT_OFFSET_LAST  = 16 * 3; 

static const uint HAND_VALUE_STRAIGHT_FLUSH = 8; 
static const uint HAND_VALUE_QUADS          = 7; 
static const uint HAND_VALUE_FULL_HOUSE     = 6;
static const uint HAND_VALUE_FLUSH          = 5; 
static const uint HAND_VALUE_STRAIGHT       = 4; 
static const uint HAND_VALUE_TRIPS          = 3;
static const uint HAND_VALUE_TWO_PAIR       = 2; 
static const uint HAND_VALUE_PAIR           = 1; 
static const uint HAND_VALUE_HIGH_CARD      = 0;

@interface Card : NSObject {
	
}
+(int) getRank: (unichar)card; 
+(int) getSuit: (unichar)card;
+(unsigned long long) makeCardFromChar: (unichar)rank andSuit:(unichar) suit; 
+(unsigned long long) makeCardFromInt: (int)rank andSuit:(int) suit;
+(unsigned long long) parseHand: (NSString*) hand; 
@end
