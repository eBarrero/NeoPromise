/**
 * @description          : NeoPromiseFlow 
 * @author               : Eugenio Barrero
 * @last modified on     : 04-05-2024
 * @last modified by     : Eugenio
 * @test class assigned  : NeoPromiseTest
**/ 
public class NeoPromiseBatch implements Database.batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

    private List<NeoPromiseQueue__c> proceses = new List<NeoPromiseQueue__c>();
    private Map<String, Object> variables; 
    private boolean flowError=false;   
    private boolean nextError=false;   

    /**
    * @description PromiseBatch - Start
    * @param bc Database.BatchableContext 
    * @return Database.QueryLocator
    */        
    @SuppressWarnings('PMD.ApexCRUDViolation')
    public Database.QueryLocator start(Database.BatchableContext bc) {
		
        List<NeoPromiseQueue__c> promisesToDeal = getPendingPromises();
        for (NeoPromiseQueue__c promise: promisesToDeal ) {
        	promise.JobId__c = bc.getJobId();    
        }
        update promisesToDeal;
        system.debug('Startbatch:' + promisesToDeal.size());
        return database.getquerylocator([
            SELECT id, name, SingleParam__c, JsonParam__c, Type__c, Class_Name__c, Error__c
            FROM NeoPromiseQueue__c
            WHERE jobId__c =: bc.getJobId()
            ORDER BY Name
        ]);
    }



    /**
    * @description PromiseBatch - Execute
    * @param bc Database.BatchableContext 
    * @param processes Database.QueryLocator
    */   
    @SuppressWarnings('PMD.ApexCRUDViolation, PMD.CyclomaticComplexity')
 	public void execute(Database.BatchableContext bc, List<NeoPromiseQueue__c> processes) {    
        system.debug('executebatch');
        for (NeoPromiseQueue__c process: processes) {

			
            if (process.Type__c==NeoPromiseFlow.P_THEN) {
                variables = new Map<String, Object>(); 
                flowError=false;
                nextError=false;
            }
            
            system.debug('execute:' + process.Name + ' : ' +  process.Class_Name__c);
            NeoPromiseInterface instance = (NeoPromiseInterface)Type.forName(process.Class_Name__c).newInstance();

            DateTime startAt = DateTime.now();
            try {
                if (process.Type__c==NeoPromiseFlow.P_THEN || 
                   (!flowError && ( 
                   (process.Type__c==NeoPromiseFlow.P_FINALLY ) || 
                   (process.Type__c==NeoPromiseFlow.P_ON_ERROR && nextError) ||   
                   (process.Type__c==NeoPromiseFlow.P_NEXT     && !nextError)
                   ))) {
                		instance.executePromise(process.singleParam__c, process.jsonParam__c, variables);
                        process.Done__c = true;
                   }
            } catch(NeoException ex) {
                system.debug(ex.getMessage());
                process.ErrorDescription__c = ex.getMessage();
                process.Error__c=true;
            } catch(Exception ex) {
                system.debug(ex.getMessage());
                process.ErrorDescription__c = ex.getMessage();
                process.Error__c=true;
            } 
            process.duration__c =   DateTime.now().getTime()-StartAt.getTime();
            process.StartAt__c = Time.newInstance(StartAt.hour(),StartAt.Minute(),StartAt.second(), StartAt.millisecond()  );
            if (process.Error__c) {
                if (process.Type__c==NeoPromiseFlow.P_THEN) {
                    flowError=true;
                }
                if (process.Type__c==NeoPromiseFlow.P_NEXT) {
                    nextError=true;
                }
            }    
    	}
        update processes;
    }
    
    /**
    * @description PromiseBatch - finish
    * @param bc Database.BatchableContext 
    */      
    public void finish(Database.BatchableContext bc) {
        List<NeoPromiseQueue__c> promisesToDeal = getPendingPromises(1);
        if (promisesToDeal.size()>0 && !Test.isRunningTest()) {
            Database.executeBatch(new NeoPromiseBatch(),1);
        }
    }


    /**
    * @description getPendingPromises
    * @return List<NeoPromiseQueue__c>
    */      
    private List<NeoPromiseQueue__c> getPendingPromises() {
        return getPendingPromises(1000);
    }

    /**
    * @description getPendingPromises
    * @param limite integer
    * @return List<NeoPromiseQueue__c>
    */      
    private List<NeoPromiseQueue__c> getPendingPromises(integer limite) {
        DateTime currentDateTime = DateTime.now().addMinutes(1);
        return [SELECT id 
                FROM NeoPromiseQueue__c
                WHERE 	Done__c 			= false AND
                JobId__c 			= null  AND
                ScheduledJobId__c 	= null  AND
                (ScheduledAT__c     = null  OR ScheduledAT__c <=:currentDateTime) 
                ORDER BY Name
                LIMIT :limite];
    }
}