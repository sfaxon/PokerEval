//
//  HandEvaluator.m
//  PokerEval
//
//  Created by Seth Faxon on 9/6/09.
//  Copyright 2009 Seth Faxon. All rights reserved.
//

#import "HandEvaluator.h"
#import "Card.h"

@implementation HandEvaluator


static const uint HANDTYPE_SHIFT   = 24;
static const uint OVER_CARD_SHIFT  = 20;
static const uint OVER_CARD_MASK   = 0x00F00000;
static const uint UNDER_CARD_SHIFT = 16;
static const uint UNDER_CARD_MASK  = 0x000F0000; 

//FIXME: this is worthless, pocket and board are not used
-(id)initWithPocketAndBoard:(NSString *)pocketString andBoard:(NSString *)boardString {
	if (self = [super init]) {
		pocket = pocketString; 
		board = boardString;
	}
	//[Card parseHand:[pocketString stringByAppendingString:boardString]];
	return self;
}

-(id)initWithPocket:(NSString *)pocketString {
	return [self initWithPocketAndBoard:pocketString andBoard:@""];
}

-(id)init {
	return [self initWithPocket:@""];
}

-(NSString*) pocketCards {
	return pocket; 
}

-(int) cardRank:(int)card {
	return card % 13; 
}
-(int) cardSuit:(int)card {
	return card / 13;
}

-(uint) evaluate: (unsigned long long)cards {
	uint retval = 0;
	uint four_mask, three_mask, two_mask = 0; 
	
	uint sc = (uint)((cards >> (CLUB_OFFSET)) & 0x1fffUL);
	uint sd = (uint)((cards >> (DIAMOND_OFFSET)) & 0x1fffUL);
	uint sh = (uint)((cards >> (HEART_OFFSET)) & 0x1fffUL);
	uint ss = (uint)((cards >> (SPADE_OFFSET)) & 0x1fffUL);
	
	uint ranks = sc | sd | sh | ss; 
	uint nRanks = bitCountTable[ranks]; 
	uint nCards = bitCountTable[sc] + bitCountTable[sd] + 
    bitCountTable[sh] + bitCountTable[ss]; 
	uint nDupRank = ((uint)(nCards - nRanks)); 
	
	if (nRanks >= 5) {
		if (bitCountTable[ss] >= 5 ) {
			if (straightTable[ss] != 0) {
				return (HAND_VALUE_STRAIGHT_FLUSH << HANDTYPE_SHIFT) + straightTable[ss];
			}
			else {
				retval = (HAND_VALUE_FLUSH << HANDTYPE_SHIFT) + topFiveCardsTable[ss];
			}
		} else if (bitCountTable[sh] >= 5) {
			if (straightTable[sh] != 0) {
				return (HAND_VALUE_STRAIGHT_FLUSH << HANDTYPE_SHIFT) + straightTable[sh];
			}
			else {
				retval = (HAND_VALUE_FLUSH << HANDTYPE_SHIFT) + topFiveCardsTable[sh];
			}
		} else if (bitCountTable[sd] >= 5) {
			if (straightTable[sd] != 0) {
				return (HAND_VALUE_STRAIGHT_FLUSH << HANDTYPE_SHIFT) + straightTable[sd];
			}
			else {
				retval = (HAND_VALUE_FLUSH << HANDTYPE_SHIFT) + topFiveCardsTable[sd];
			}
		} else if (bitCountTable[sc] >= 5) {
			if (straightTable[sc] != 0) {
				return (HAND_VALUE_STRAIGHT_FLUSH << HANDTYPE_SHIFT) + straightTable[sc];
			}
			else {
				retval = (HAND_VALUE_FLUSH << HANDTYPE_SHIFT) + topFiveCardsTable[sc];
			}
		} else {
			uint st = straightTable[ranks]; 
			if (st != 0) {
				retval = (HAND_VALUE_STRAIGHT << HANDTYPE_SHIFT) + st;
			}
		}
		/* 
		 Another win -- if there can't be a FH/Quads (nDupRank < 3), 
		 which is true most of the time when there is a made mask, then if we've
		 found a five card mask, just return.  This skips the whole process of
		 computing two_mask/three_mask/etc.
		 */
		if (retval != 0 && nDupRank < 3) {
			return retval; 
		}
        
	}
	/*
	 * By the time we're here, either: 
	 1) there's no five-card mask possible (flush or straight), or
	 2) there's a flush or straight, but we know that there are enough
	 duplicates to make a full house / quads possible.  
	 */
	switch (nDupRank) {
		case 0: // no pairs
			// shorten: (HAND_VALUE_HIGH_CARD << HANDTYPE_SHIFT) + topFiveCardsTable[ranks];  
			return topFiveCardsTable[ranks]; 
			break;
		case 1: // one pair
        {
            two_mask = ranks ^ (ss ^ sh ^ sd ^ sc); 
            
            retval = (uint) (HAND_VALUE_PAIR << HANDTYPE_SHIFT);
			
            retval += (uint) ([self convertCardMaskToInt: topFiveCardsTable[two_mask] ] << OVER_CARD_SHIFT);
            retval += two_mask ^ ranks; 
            return retval;
        }
			break;
		case 2: // two pair or trips, good times 
        {
            two_mask = ranks ^ (ss ^ sh ^ sd ^ sc); 
            if (two_mask != 0) { //two pair
                uint high_pair = 0; 
                uint low_pair  = 0;
                high_pair = highCardTable[two_mask];
                low_pair = highCardTable[two_mask ^ high_pair];
                
                retval = (uint) (HAND_VALUE_TWO_PAIR << HANDTYPE_SHIFT); 
                retval += (uint) ([self convertCardMaskToInt:highCardTable[high_pair]] << OVER_CARD_SHIFT);
                retval += (uint) ([self convertCardMaskToInt:highCardTable[low_pair]] << UNDER_CARD_SHIFT);
                retval += highCardTable[ranks ^ high_pair ^ low_pair];//get single kicker
            } else { // trips 
                uint trips       = 0;
                uint high_kicker = 0;
                uint low_kicker  = 0; 
                three_mask = ((sc & sd) | (sh & ss)) & ((sc & sh) | (sd & ss));
                trips = highCardTable[three_mask]; 
                high_kicker = highCardTable[ranks ^ trips]; 
                low_kicker  = highCardTable[(ranks ^ trips) ^ high_kicker];
                
                retval = (uint) (HAND_VALUE_TRIPS << HANDTYPE_SHIFT); 
                retval += (uint) ([self convertCardMaskToInt:trips] << OVER_CARD_SHIFT); 
                retval += high_kicker;
                retval += low_kicker; 
            }
            
        }
			break;
            
		default:
			/* Possible quads, fullhouse, straight or flush, or two pair */
			four_mask = sh & sd & sc & ss; 
			if (four_mask != 0) {
				uint quads = highCardTable[four_mask]; 
				retval = (uint) (HAND_VALUE_QUADS << HANDTYPE_SHIFT); 
				retval += (uint) ([self convertCardMaskToInt:quads] << OVER_CARD_SHIFT); 
				retval += highCardTable[ranks ^ quads]; 
				return retval; 
			}
			/* Technically, three_mask as defined below is really the set of
			 bits which are set in three or four of the suits, but since
			 we've already eliminated quads, this is OK */
			/* Similarly, two_mask is really two_or_four_mask, but since we've
			 already eliminated quads, we can use this shortcut */
			two_mask = ranks ^ (sc ^ sd ^ sh ^ ss); 
			if (bitCountTable[two_mask] != nDupRank) {
				/* Must be some trips then, which really means there is a 
				 full house since n_dups >= 3 */
				uint tc, t; 
				three_mask = ((sc & sd) | (sh & ss)) & ((sc & sh) | (sd & ss));
				tc = highCardTable[three_mask]; 
				t = (two_mask | three_mask) ^ (tc); 
				
				retval = (uint) (HAND_VALUE_FULL_HOUSE << HANDTYPE_SHIFT);
				retval += (uint) ([self convertCardMaskToInt:tc] << OVER_CARD_SHIFT); 
				retval += (uint) ([self convertCardMaskToInt:t] << UNDER_CARD_SHIFT); 
				return retval;
			}
			if (retval != 0) {
				return retval; 
			} 
			else {
				// three pair will get you here, stupid edge cases
				uint top_pair, under_pair, kicker; 
				top_pair = highCardTable[two_mask]; 
				under_pair = highCardTable[two_mask ^ top_pair]; 
				kicker = highCardTable[ranks ^ (top_pair | under_pair)]; 
				
				retval = (uint) (HAND_VALUE_TWO_PAIR << HANDTYPE_SHIFT); 
				retval += (uint) ([self convertCardMaskToInt:top_pair] << OVER_CARD_SHIFT); 
				retval += (uint) ([self convertCardMaskToInt:under_pair] << UNDER_CARD_SHIFT); 
				retval += kicker; 
				return retval; 
			}
            
			
			
			break;
	}
	return retval;
}

-(uint) convertCardMaskToInt:(uint)cardMask {
	switch (cardMask) {
		case 4096:
			return CARD_RANK_ACE;
			break;
		case 2048: 
			return CARD_RANK_KING;
			break;
		case 1024:
			return CARD_RANK_QUEEN;
			break;
		case 512:
			return CARD_RANK_JACK;
			break;
		case 256:
			return CARD_RANK_TEN;
			break;
		case 128:
			return CARD_RANK9;
			break;
		case 64:
			return CARD_RANK8;
			break;
		case 32:
			return CARD_RANK7;
			break;
		case 16:
			return CARD_RANK6;
			break;
		case 8:
			return CARD_RANK5;
			break;
		case 4:
			return CARD_RANK4;
			break;
		case 2:
			return CARD_RANK3;
			break;
		case 1:
			return CARD_RANK2;
			break;
		default:
			return 0;
			break;
	}
	return 0;
}

@end

@implementation HandEvaluator (hidden)


@end
