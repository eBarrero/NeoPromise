/**
 * @description  Test class to cover all Promise clases 
 * @author: Eugenio Barrero
 */ 
@isTest
public class NeoPromiseTest { 
    public static final boolean WILL_TRHOW_ERROR = true;
	@IsTest private static void ok1() {
		system.debug('ok1');
        
        NeoPromise sampleThen    = NeoPromiseSample.NewPromise('Then');     // it will run
        NeoPromise sampleNext1   = NeoPromiseSample.NewPromise('Next');     // Sence sw is true  it will run
        NeoPromise sampleNext2   = NeoPromiseSample.NewPromise('Next');     // Sence sw is false it will NOT run  
        NeoPromise sampleError   = NeoPromiseSample.NewPromise('Error');    // Sence no error it will NOT run  
        NeoPromise sampleFinally = NeoPromiseSample.NewPromise('Finally');  // it will run 
        
        Test.startTest();
        new NeoPromiseFlow('FLOW_NAME')
            .then(sampleThen)
                .next(true, sampleNext1)  
                .next(false, sampleNext2)  
                    .onError(sampleError)
                .finaly(sampleFinally)
            .execute();
        Test.stopTest();
        
        System.assertEquals(3, [SELECT count() FROM NeoPromiseQueue__c where Done__c=true],  'ok1 - all promise ran except -Error- step');
        System.assertEquals(0, [SELECT count() FROM NeoPromiseQueue__c where Error__c=true], 'ok1 - no one promise failed');
    }

    
	@IsTest private static void ok2() {
		system.debug('ok2');
        NeoPromise sampleThen    = NeoPromiseSample.NewPromise('Then');     				// it will run
        NeoPromise sampleNext    = NeoPromiseSample.NewPromise(WILL_TRHOW_ERROR, 'Next');   // it will run but will throw an error
        NeoPromise sampleError   = NeoPromiseSample.NewPromise('Error');    				// it will run because previous step had failed
        NeoPromise sampleFinally = NeoPromiseSample.NewPromise('Finally');  				// it will run
        
        Test.startTest();
        new NeoPromiseFlow('FLOW_NAME')
            .then(sampleThen)
                .next(sampleNext)
                    .onError(sampleError)
                .finaly(sampleFinally)
            .execute();
        Test.stopTest();
        
        System.assertEquals(3, [SELECT count() FROM NeoPromiseQueue__c where Done__c=true],  'ok2 "sampleThen", "sampleError" and "sampleFinally" did run');
        System.assertEquals(1, [SELECT count() FROM NeoPromiseQueue__c where Error__c=true], 'ok2 - just "sampleNext" ran and failed');
    }  
    
	@IsTest private static void ok3() {
		system.debug('ok3');        
        NeoPromise sampleThen    = NeoPromiseSample.NewPromise(WILL_TRHOW_ERROR, 'Then');   // it will run but will throw an error
        NeoPromise sampleNext    = NeoPromiseSample.NewPromise('Next');      				// it will NOT run because THEN has failed
        NeoPromise sampleError   = NeoPromiseSample.NewPromise('Error');     				// it will NOT run because THEN has failed  
        NeoPromise sampleFinally = NeoPromiseSample.NewPromise('Finally');   				// it will NOT run because THEN has failed  
        
        Test.startTest();
        new NeoPromiseFlow('FLOW_NAME')
            .then(sampleThen)
                .next(sampleNext)
                    .onError(sampleError)
                .finaly(sampleFinally)
            .execute();
        Test.stopTest();
        
		System.assertEquals(1, [SELECT count() FROM NeoPromiseQueue__c where Error__c=true], 'ok3 - "sampleThen" ran and failed');
        System.assertEquals(0, [SELECT count() FROM NeoPromiseQueue__c where Done__c=true],  'ok3 - none of them ran');
        
    }      

	@IsTest private static void ok4() { 
		system.debug('ok4');        
        NeoPromise sampleThen    = NeoPromiseSample.NewPromise('Then');     // Sence sw is false it will NOT run 
        NeoPromise sampleNext    = NeoPromiseSample.NewPromise('Next');     // Will not run
        NeoPromise sampleError   = NeoPromiseSample.NewPromise('Error');    // Will not run
        NeoPromise sampleFinally = NeoPromiseSample.NewPromise('Finally');  // Will not run

        NeoPromise sampleThen2    = NeoPromiseSample.NewPromise('Then');     // Sence sw is true it will run 
        NeoPromise sampleNext2    = NeoPromiseSample.NewPromise('Next');     // Will run
        NeoPromise sampleError2   = NeoPromiseSample.NewPromise('Error');    // Sence no error it will NOT run 
        NeoPromise sampleFinally2 = NeoPromiseSample.NewPromise('Finally');  // Will run        
        
        Test.startTest();
        new NeoPromiseFlow('FLOW_NAME')
            .then(false, sampleThen)
                .next(sampleNext)  
                    .onError(sampleError)
                .finaly(sampleFinally)
            .then(true, sampleThen2)
                .next(sampleNext2)  
                    .onError(sampleError2)
                .finaly(sampleFinally2)            
            .execute();
        Test.stopTest();
        
        System.assertEquals(3, [SELECT count() FROM NeoPromiseQueue__c where Done__c=true], 'ok4 - just "sampleThen2", "sampleNext2" and "sampleFinally2" ran ');
    }    
}