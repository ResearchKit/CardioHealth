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
    NSDictionary * schedules    = @{
                                      @"schedules":
                                          @[

                                              @{
                                                  @"scheduleType"   : @"once",
                                                  @"taskID"         : @"2-APHHeartAge-7259AC18-D711-47A6-ADBD-6CFCECDED1DF"
                                              },

                                              @{
                                                  @"scheduleType"   : @"once",
                                                  @"taskID"         : @"3-APHFitnessTest-00000000-1111-1111-1111-F810BE28D995"
                                              },
                                          ]
                                      };
    
    [APCSchedule updateSchedulesFromJSON:schedules[@"schedules"]
                               inContext:self.dataSubstrate.persistentContext];
    
    

    [self findScheduledTaskAndClean: @[@"2-APHHeartAge-7259AC18-D711-47A6-ADBD-6CFCECDED1DF",
                                       @"3-APHFitnessTest-00000000-1111-1111-1111-F810BE28D995"]];

    
    return YES;
}


- (BOOL)findScheduledTaskAndClean:(NSArray *)tasksIdentifiers {
    
    BOOL success = YES;
    
    for (NSString* identifier in tasksIdentifiers)
    {
        
        //Retrieve the reference for today and tomorrow's scheduled tasks if they exist
        
        APCSchedule*        taskSchedule            = [APCSchedule cannedScheduleForTaskID:identifier
                                                                                 inContext:self.dataSubstrate.persistentContext];
        
        APCScheduledTask*   scheduleTaskForToday    = [APCScheduledTask scheduledTaskForStartOnDate:[[NSDate date] startOfDay]
                                                                                           schedule:taskSchedule
                                                                                          inContext:self.dataSubstrate.persistentContext];
        
        NSDate*             dateForTomorrow         = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay
                                                                                               value:1
                                                                                              toDate:[[NSDate date] startOfDay]
                                                                                             options:0];
        
        APCScheduledTask*   scheduleTaskForTomorrow = [APCScheduledTask scheduledTaskForStartOnDate:dateForTomorrow
                                                                                           schedule:taskSchedule
                                                                                          inContext:self.dataSubstrate.persistentContext];
        
        if (! [scheduleTaskForToday.completed boolValue])
        {
            [self.dataSubstrate.persistentContext deleteObject:scheduleTaskForToday];
        }
        
        if (scheduleTaskForTomorrow != nil)
        {
            [self.dataSubstrate.persistentContext deleteObject:scheduleTaskForTomorrow];
        }
        
        NSError* MOCError = nil;
        
        if (! [self.dataSubstrate.persistentContext save:&MOCError])
        {
            APCLogError2(MOCError);
            success = NO;
        }
        
        if ( [self returnAllAPCResultsWithTaskId:identifier] == nil || [self returnAllAPCResultsWithTaskId:identifier].count <= 0)
        //If there are no results update scheduled tasks as necessary
        {
            APCScheduler* scheduler = [[APCScheduler alloc] initWithDataSubstrate:self.dataSubstrate];
            [scheduler updateScheduledTasksIfNotUpdating:YES];
        }
    }
    
    return success;
}

- (NSArray *)returnAllAPCResultsWithTaskId:(NSString *)taskId {
    
    APCAppDelegate*     appDelegate         = (APCAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSFetchRequest*     request             = [APCScheduledTask request];

    
    NSPredicate*        predicate           = [NSPredicate predicateWithFormat:@"task.taskID == %@", taskId];
    
                        request.predicate   = predicate;
    
    NSError*            error               = nil;
    
    NSArray *           results             = [appDelegate.dataSubstrate.mainContext executeFetchRequest:request
                                                                                                   error:&error];
    
    if (error)
    {
        APCLogError2(error);
    }
    
    return results;
}

@end
