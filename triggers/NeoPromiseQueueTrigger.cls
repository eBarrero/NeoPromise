/**
 * @description          : Promise Bath trigger
 * @author               : Neo
 * @group                : Neo
 * @last modified on     : 03-20-2024
 * @last modified by     : Eugenio
 * @test class assigned  : NeoPromiseTest 
**/  
@SuppressWarnings('PMD.ApexCRUDViolation, PMD.AvoidLogicInTrigger')
trigger NeoPromiseQueueTrigger on NeoPromiseQueue__c (after insert, after update) {
    if (trigger.isInsert ) {
        Integer jobs = [SELECT COUNT() FROM AsyncApexJob WHERE Jobtype = 'BatchApex' and apexclass.name = 'NeoPromiseBatch' and Status In ('Processing')];
        if (jobs==0) {
            integer batchs = (Test.isRunningTest())? 10 : 1;
	        Database.executeBatch(new NeoPromiseBatch(),batchs);
        }
    }
}