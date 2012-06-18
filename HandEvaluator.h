//
//  HandEvaluator.h
//  PokerEval
//
//  Created by Seth Faxon on 9/6/09.
//  Copyright 2009 Seth Faxon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HandEvaluatorLookupTables.h"
#import "Card.h"

typedef enum HandTypes 
{
	HighCard = 0, 
	Pair = 1,
	TwoPair = 2,
	Trips = 3,
	Straight = 4,
	Flush = 5,
	FullHouse = 6,
	FourOfAKind = 7,
	StraightFlush = 8
} HandRankings;


@interface HandEvaluator : NSObject {
	unsigned int handval; 
	NSString *pocket; 
	NSString *board; 
}

-(id) initWithPocketAndBoard: (NSString *)pocketString andBoard: (NSString *)boardString;
-(id) initWithPocket: (NSString *)pocketString; 
-(id) init; 

-(NSString*) pocketCards; 
-(int) cardRank: (int)card; 
-(int) cardSuit: (int)card;
-(uint) evaluate: (unsigned long long)cards; 
-(uint) convertCardMaskToInt:(uint)cardMask;

@end

@interface HandEvaluator (hidden)



@end

