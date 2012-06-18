//
//  Card.m
//  PokerEval
//
//  Created by Seth Faxon on 9/12/09.
//  Copyright 2009 Slash and Burn. All rights reserved.
//

#import "Card.h"

@implementation Card

+(int) getRank:(unichar)card {
	int rank = -1; 
	switch (card ) {
		case 'A':
		case 'a': 
			rank = CARD_RANK_ACE; 
			break;
		case 'K':
		case 'k':
			rank = CARD_RANK_KING;
			break;
		case 'Q':
		case 'q': 
			rank = CARD_RANK_QUEEN; 
			break;
		case 'J':
		case 'j':
			rank = CARD_RANK_JACK;
			break;
		case 'T':
		case 't': 
			rank = CARD_RANK_TEN; 
			break;
		case '9':
			rank = CARD_RANK9;
			break;
		case '8': 
			rank = CARD_RANK8; 
			break;
		case '7':
			rank = CARD_RANK7;
			break;
		case '6':
			rank = CARD_RANK6;
			break;
		case '5': 
			rank = CARD_RANK5; 
			break;
		case '4':
			rank = CARD_RANK4;
			break;
		case '3':
			rank = CARD_RANK3;
			break;
		case '2': 
			rank = CARD_RANK2; 
			break;
		default:
			break;
	}
	return rank; 
}

+(int) getSuit:(unichar)card {
	int suit = -1;
	switch (card) {
		case 'S':
		case 's':
			suit = CARD_SUIT_SPADES; 
			break;
		case 'H':
		case 'h':
			suit = CARD_SUIT_HEARTS;
			break;
		case 'D':
		case 'd':
			suit = CARD_SUIT_DIAMONDS;
			break;
		case 'C':
		case 'c':
			suit = CARD_SUIT_CLUBS;
			break;
		default:
			break;
	}
	return suit; 
}

+(unsigned long long) makeCardFromChar: (unichar)rank andSuit:(unichar) suit {
	int i_suit = [self getSuit:suit];
	int i_rank = [self getRank:rank]; 
	return (0x1UL << (i_rank + i_suit * 16));
}
+(unsigned long long) makeCardFromInt: (int)rank andSuit:(int) suit {
	return (0x1UL << (rank + suit * 16));
}
+(unsigned long long) parseHand: (NSString *)hand {
	unsigned long long handMask = 0; 
	NSArray *cardStrings = [hand componentsSeparatedByString:@" "];
	
	for( int i = 0; i < [cardStrings count]; i++ ) {
		//NSLog(@"Card is %@", [cardStrings objectAtIndex:i]);
		int rank = -1; 
		int suit = -1;
		rank = (int)[self getRank:[[cardStrings objectAtIndex:i] characterAtIndex:0]];
		
		suit = (int)[self getSuit:[[cardStrings objectAtIndex:i] characterAtIndex:1]];
		
		// FIXME need to make sure rank and suit are valid
		handMask |= (0x1UL << (rank + suit * 16));
	}
	
	return handMask;
}

@end
