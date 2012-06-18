//
//  HoldemHandDistribution.m
//  PokerEval
//
//  Created by Seth Faxon on 9/12/09.
//  Copyright 2009 Seth Faxon. All rights reserved.
//

#import "HoldemHandDistribution.h"
#import "Card.h"

// gheto way to define a private method
@interface HoldemHandDistribution (hidden) 
-(void) parseToken: (NSString*)token; 
@end

@implementation HoldemHandDistribution

-(id) initWithDeadCardsMask:(NSString *)hand deadCardMask:(unsigned long long)removeCardsMask {
	if (self = [super init]) {
		hands = [[NSMutableSet alloc] initWithCapacity:0];
		NSArray *elements = [hand componentsSeparatedByString:@","];
		NSString *token = [[NSString alloc] init]; 
		for (int i = 0; i < [elements count]; i++) {
			token = [elements objectAtIndex:i]; 
			//some specific hand check
			[self parseToken: token];
		}
//		[token release];
		[self deadCards:removeCardsMask];
	}
	return self;
}

-(id) initWithDeadCardString: (NSString *)hand deadCardString:(NSString *)removeCards {
	unsigned long long removeCardMask = 0UL; 
	NSArray *elements = [removeCards componentsSeparatedByString:@" "];
	for (int i = 0; i < [elements count]; i++) {
		removeCardMask = removeCardMask | 
        [Card makeCardFromChar:[[elements objectAtIndex:i] characterAtIndex:0] 
                       andSuit:[[elements objectAtIndex:i] characterAtIndex:1]];
	}
	return [self initWithDeadCardsMask:hand deadCardMask:removeCardMask]; 
}

-(id) init:(NSString *)hand {
	return [self initWithDeadCardsMask:hand deadCardMask:0UL];
}

-(void) deadCards: (unsigned long long)excludeMask {
	NSEnumerator *setEnum = [hands objectEnumerator]; 
	NSNumber *element; 
	NSMutableSet *toRemove = [[NSMutableSet alloc] initWithCapacity:0]; 
	
	while ((element = [setEnum nextObject]) != nil ) {
		if ( (excludeMask & [element longLongValue]) > 0 ) {
			NSLog(@"removing the hand: %llx", [element longLongValue]);
			[toRemove addObject:element]; 
		}
	}
	[hands minusSet:toRemove];
	[toRemove release];
	[element release];
}

-(uint) count {
	return [hands count];
}

@end


@implementation HoldemHandDistribution (hidden)
-(void) parseToken: (NSString *)token {
	unsigned long long card1, card2 = 0UL;
	switch ([token length]) {
		case 1: {
			int rank = [Card getRank:[token characterAtIndex:0]]; 
			for (int suit1 = SUIT_FIRST; suit1 <= SUIT_LAST; suit1++) {
				for (int suit2 = SUIT_FIRST; suit2 <= SUIT_LAST; suit2++) {
					for (int rank_second_card = RANK_FIRST; rank_second_card <= RANK_LAST; rank_second_card++) {
						card1 = (unsigned long long) [Card makeCardFromInt:rank andSuit:suit1]; 
						card2 = (unsigned long long) [Card makeCardFromInt:rank_second_card andSuit:suit2];
						if (card1 != card2) {
							[hands addObject:(NSNumber*) [NSNumber numberWithUnsignedLongLong:card1 | card2]];
						}
					}
				}
			}
		}// end case 1
			break;
		case 2: {
			if ([token characterAtIndex:0] == [token characterAtIndex:1]) {
				//unsigned long long card1, card2 = 0UL; 
				int rank = [Card getRank:[token characterAtIndex:0]];
				for (int suit1 = SUIT_FIRST; suit1 <= SUIT_LAST; suit1++) {
					for (int suit2 = suit1+1; suit2 <= SUIT_LAST; suit2++) {
						card1 = (unsigned long long) [Card makeCardFromInt:rank andSuit:suit1]; 
						card2 = (unsigned long long) [Card makeCardFromInt:rank andSuit:suit2];
						NSLog(@"storing: %llx", card1 | card2);
						[hands addObject:(NSNumber*) [NSNumber numberWithUnsignedLongLong:card1 | card2]];
					}
				}
			}
			else if ([token characterAtIndex:1] == 'x') { // Ax for any suit
				//goto case 1 for this
				[self parseToken:[token substringToIndex:1]]; 
			}
			else {
				// 54 any 4 or five of any suit 
				int rank_first_card = [Card getRank:[token characterAtIndex:0]];
				int rank_second_card = [Card getRank:[token characterAtIndex:1]]; 
				for (int suit1 = SUIT_FIRST; suit1 <= SUIT_LAST; suit1++) {
					for (int suit2 = SUIT_FIRST; suit2 <= SUIT_LAST; suit2++) {
						card1 = (unsigned long long) [Card makeCardFromInt:rank_first_card andSuit:suit1]; 
						card2 = (unsigned long long) [Card makeCardFromInt:rank_second_card andSuit:suit2];
						[hands addObject:(NSNumber*) [NSNumber numberWithUnsignedLongLong:card1 | card2]];
					}
				}
			}
            
		}// end case 2
			break;
		case 3: {
			// AKo or AKs 
			if ([token characterAtIndex:2] == 'o' || [token characterAtIndex:2] == 's') {
				bool suited = [token characterAtIndex:2] == 's'; 
				int rank_first_card = [Card getRank:[token characterAtIndex:0]];
				int rank_second_card = [Card getRank:[token characterAtIndex:1]];
				for (int suit1 = SUIT_FIRST; suit1 <= SUIT_LAST; suit1++) {
					for (int suit2 = SUIT_FIRST; suit2 <= SUIT_LAST; suit2++) {
						card1 = (unsigned long long) [Card makeCardFromInt:rank_first_card andSuit:suit1]; 
						card2 = (unsigned long long) [Card makeCardFromInt:rank_second_card andSuit:suit2];
						if (suited && suit1 == suit2) {
							[hands addObject:(NSNumber*) [NSNumber numberWithUnsignedLongLong:card1 | card2]];
						}
						else if (!suited && suit1 != suit2) {
							[hands addObject:(NSNumber*) [NSNumber numberWithUnsignedLongLong:card1 | card2]];
						}
						
					}
				}
			}
			else if ([token characterAtIndex:2] == '+') {
				// JJ+
				if ([token characterAtIndex:0] == [token characterAtIndex:1]) {
					int rank = [Card getRank:[token characterAtIndex:0]]; 
					for ( ; rank <= RANK_LAST; rank++ ) {
						for (int suit1 = SUIT_FIRST; suit1 <= SUIT_LAST; suit1++) {
							for (int suit2 = suit1+1; suit2 <= SUIT_LAST; suit2++) {
								card1 = (unsigned long long) [Card makeCardFromInt:rank andSuit:suit1]; 
								card2 = (unsigned long long) [Card makeCardFromInt:rank andSuit:suit2];
								[hands addObject:(NSNumber*) [NSNumber numberWithUnsignedLongLong:card1 | card2]];
							}
						}
					}
				} 
				// AJ+ = AJ AQ AK 
				// KJ+ = KJ KQ 
				else {
					int rank_first_card = [Card getRank:[token characterAtIndex:0]];
					int second_card_rank_start = [Card getRank:[token characterAtIndex:1]];
					for ( int second_card_rank = second_card_rank_start; second_card_rank <= rank_first_card; second_card_rank++ ) {
						if (second_card_rank != rank_first_card) {
							for (int suit1 = SUIT_FIRST; suit1 <= SUIT_LAST; suit1++) {
								for (int suit2 = SUIT_FIRST; suit2 <= SUIT_LAST; suit2++) {
									card1 = (unsigned long long) [Card makeCardFromInt:rank_first_card andSuit:suit1]; 
									card2 = (unsigned long long) [Card makeCardFromInt:second_card_rank andSuit:suit2];
									[hands addObject:(NSNumber*) [NSNumber numberWithUnsignedLongLong:card1 | card2]];
								}
							}
						}
					}
				}
			}
		}// end case 3
			break;
		case 4: {
			//simplified case for now of two cards, AhAd
			card1 = (unsigned long long) [Card parseHand:[token substringToIndex:2]]; 
			card2 = (unsigned long long) [Card parseHand:[token substringFromIndex:2]];
			[hands addObject:(NSNumber*) [NSNumber numberWithUnsignedLongLong:card1 | card2]];
		}
			break;
            
			break; 
		default:
			break;
	}// end switch
    
}

@end