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

- (BOOL)updateTaskScheduleToOnceWithTaskId
{
    //Change the schedule type to Once
//    NSDictionary * schedules    = @{
//                                      @"schedules":
//                                          @[
//
//                                              @{
//                                                  @"expire"         : @"P89D",
//                                                  @"scheduleType"   : @"once",
//                                                  @"taskID"         : @"2-APHHeartAge-7259AC18-D711-47A6-ADBD-6CFCECDED1DF"
//                                              },
//
//                                              @{
//                                                  @"expire"         : @"P89D",
//                                                  @"scheduleType"   : @"once",
//                                                  @"taskID"         : @"3-APHFitnessTest-00000000-1111-1111-1111-F810BE28D995"
//                                              },
//                                          ]
//                                      };
//
//    [APCSchedule updateSchedulesFromJSON:schedules[@"schedules"]
//                               inContext:self.dataSubstrate.persistentContext];
    
    

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
            goto errorOccurred;
        }
        
        APCScheduledTask*   tempScheduledTask   = nil;
        
        if (scheduledTasks.count > 0)
        {
            tempScheduledTask = [scheduledTasks firstObject];
        }
        
        BOOL                shouldCreate        = YES;

        //Delete all scheduled tasks that are recurring types
        for (APCScheduledTask *scheduledTask in scheduledTasks) {
            
            if (!scheduledTask.completed)
            {
                [self.dataSubstrate.persistentContext deleteObject:scheduledTask];
            } else {
                //If there are completed tasks keep them and set flag to not create additional scheduled tasks
                shouldCreate = NO;
            }
            
        }
        
        
        NSError*            MOCError            = nil;
        
        if (! [self.dataSubstrate.persistentContext save:&MOCError])
        {
            APCLogError2(MOCError);
            success = NO;
            goto errorOccurred;
        }

        
        //Update the schedule type to 'Once' from 'Recurring'
        
#warning TODO figure out how many days until expiration
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
        
        if ( shouldCreate )
        {
            APCScheduler*       scheduler               = [[APCScheduler alloc] initWithDataSubstrate:self.dataSubstrate];
            
            scheduler.referenceRange.startDate          = [[NSDate date] startOfDay];

            APCSchedule*        taskSchedule            = [APCSchedule cannedScheduleForTaskID:identifier
                                                                                     inContext:self.dataSubstrate.persistentContext];
            
            NSDate*             startDate               = [[NSDate date] startOfDay];
            
            [scheduler findOrCreateOneTimeScheduledTask:taskSchedule
                                                   task:tempScheduledTask.task
                                  andStartDateReference:startDate];
        }
    }
    
errorOccurred:
    
    return success;
}
@end
