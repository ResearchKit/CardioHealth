//
//  APHTimer.h
//  CardioHealth
//
//  Created by Justin Warmkessel on 10/2/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Timer counts down from the specified amount in seconds
 
 */
@protocol APHTimerDelegate;

@interface APHTimer : NSObject

/**
 *  Designated initializer
 *
 *  @return instancetype
 */
- (instancetype)initWithTimeInterval:(NSTimeInterval)totalSeconds;

/**
 *  @brief start Starts the timer
 */
- (void)start;

/**
 *  @brief pause Pauses timer
 */
- (void)pause;

/**
 *  Delegate conforms to APHTimerDelegate.
 */
@property (weak, nonatomic) id <APHTimerDelegate> delegate;

@end

/*********************************************************************************/
//Protocol
/*********************************************************************************/
@protocol APHTimerDelegate <NSObject>

@optional

/**
 * @brief Location has failed to update.
 */
- (void)aphTimer:(APHTimer *)timer didUpdateCountDown:(NSString *)countdown;
- (void)aphTimer:(APHTimer *)timer didFinishCountingDown:(NSString *)countdown;

@end