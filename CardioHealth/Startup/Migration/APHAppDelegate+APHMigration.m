//
//  APHAppDelegate+APHMigration.m
//  MyHeart Counts 
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APHAppDelegate+APHMigration.h"

@implementation APHAppDelegate (APHMigration)

- (BOOL) performMigrationFromOneToTwoWithError:(NSError *__autoreleasing *)error{
    
    error = nil;
    
    BOOL success = [self updateTaskScheduleToOnceWithTaskId];
    
    return success;
}

-(BOOL) performMigrationFromThreeToFourWithError:(NSError * __autoreleasing *)__unused error
{
        return [self turnOnAllTaskReminders];
}

- (BOOL)updateTaskScheduleToOnceWithTaskId
{

    [self findScheduledTaskAndClean: @[@"2-APHHeartAge-7259AC18-D711-47A6-ADBD-6CFCECDED1DF",
                                       @"3-APHFitnessTest-00000000-1111-1111-1111-F810BE28D995"]];
    
    return YES;
}


- (BOOL)findScheduledTaskAndClean:(NSArray *)tasksIdentifiers {
    
    BOOL success = YES;
    
    for (NSString* identifier in tasksIdentifiers)
    {
        //Retrieve the reference for today and tomorrow's scheduled tasks if they exist
        NSFetchRequest*     request             = [APCScheduledTask request];
        request.predicate                       = [NSPredicate predicateWithFormat:@"task.taskID == %@", identifier];
        NSError*            error;
        NSArray*            scheduledTasks      = [self.dataSubstrate.persistentContext executeFetchRequest:request error:&error];
        
        if (error)
        {
            APCLogError2(error);
            success = NO;

            
        } else {
            
            APCScheduledTask*   tempScheduledTask           = nil;
            NSDate*             taskCreatedReferenceDate    = nil;
            
            if (scheduledTasks.count > 0)
            {
                tempScheduledTask = [scheduledTasks firstObject];
            }
            
            BOOL shouldCreate = YES;
            
            //Delete all scheduled tasks that are recurring types
            for (APCScheduledTask *scheduledTask in scheduledTasks) {
                
                if (!scheduledTask.completed)
                {
                    [self.dataSubstrate.persistentContext deleteObject:scheduledTask];
                } else {
                    //If there are completed tasks keep them and set flag to not create additional scheduled tasks
                    shouldCreate = NO;
                }
                
                taskCreatedReferenceDate = scheduledTask.task.createdAt;
            }
            
            
            NSError* MOCError = nil;
            
            if (! [self.dataSubstrate.persistentContext save:&MOCError])
            {
                APCLogError2(MOCError);
                success = NO;
            } else {
                
                //Update the schedule type to 'Once' from 'Recurring'
                [self updateSchedulesToOnce];
                
                
                if ( shouldCreate )
                {
                    APCScheduler*       scheduler               = [[APCScheduler alloc] initWithDataSubstrate:self.dataSubstrate];
                    APCSchedule*        taskSchedule            = [APCSchedule cannedScheduleForTaskID:identifier
                                                                                             inContext:self.dataSubstrate.persistentContext];
                    
                    NSDate*             taskReferenceDate       = [taskCreatedReferenceDate startOfDay];
                    NSDateComponents*   components              = [[NSDateComponents alloc] init];
                    [components setDay:8];
                    NSDate*             startDate               = [[NSCalendar currentCalendar] dateByAddingComponents:components
                                                                                                                toDate:taskReferenceDate
                                                                                                               options:0];
                    
                    if (startDate != nil)
                    {
                        [scheduler findOrCreateOneTimeScheduledTask:taskSchedule
                                                               task:tempScheduledTask.task
                                              andStartDateReference:startDate];
                    }
                }
            }
        }
    }
    
    return success;
}

- (void) updateSchedulesToOnce {
    //Update the schedule type to 'Once' from 'Recurring'
    NSDictionary * schedules    = @{
                                    @"schedules":
                                        @[
                                            
                                            @{
                                                @"expire"         : @"P89D",
                                                @"scheduleType"   : @"once",
                                                @"taskID"         : @"2-APHHeartAge-7259AC18-D711-47A6-ADBD-6CFCECDED1DF"
                                                },
                                            
                                            @{
                                                @"expire"         : @"P89D",
                                                @"scheduleType"   : @"once",
                                                @"taskID"         : @"3-APHFitnessTest-00000000-1111-1111-1111-F810BE28D995"
                                                },
                                            ]
                                    };
    
    [APCSchedule updateSchedulesFromJSON:schedules[@"schedules"]
                               inContext:self.dataSubstrate.persistentContext];
}

- (BOOL)turnOnAllTaskReminders
{
    //turn all task reminders on
    [self setUpTasksReminder];
    
    for (APCTaskReminder *reminder in self.tasksReminder.reminders) {
        if (![[NSUserDefaults standardUserDefaults]objectForKey:reminder.reminderIdentifier]) {
            [[NSUserDefaults standardUserDefaults]setObject:reminder.reminderBody forKey:reminder.reminderIdentifier];
        }
    }
    
    //Enable reminders if notifications permitted
    if ([[UIApplication sharedApplication] currentUserNotificationSettings].types != UIUserNotificationTypeNone){
        [self.tasksReminder setReminderOn:@YES];
    }

    [[NSUserDefaults standardUserDefaults]synchronize];
    
    return self.tasksReminder.reminders.count;
    
}
@end
