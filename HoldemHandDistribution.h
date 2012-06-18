//
//  HoldemHandDistribution.h
//  PokerEval
//
//  Created by Seth Faxon on 9/12/09.
//  Copyright 2009 Seth Faxon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HoldemHandDistribution : NSObject {
	NSMutableSet *hands;
}

-(id) initWithDeadCardsMask:(NSString *)hand deadCardMask:(unsigned long long)removeCardsMask;
-(id) initWithDeadCardString: (NSString *)hand deadCardString:(NSString *)removeCards; 
-(id) init: (NSString *)hand; 
-(void) deadCards: (unsigned long long)excludeMask;
-(uint) count; 

@end


