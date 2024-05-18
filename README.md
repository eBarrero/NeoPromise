### Overview
NeoPromise is a Salesforce Apex library that simplifies handling synchronous processes in a sequential, ordered and limiteless manner, much like JavaScript Promises. It streamlines task orchestration by ensuring each step follows the correct sequence.

### Features
- **Sequential Execution**: Execute synchronous processes sequentially, following a specific order.
- **Clear Code Design**: Promotes code that's clean and easy to understand.

### Usage
To start with NeoPromise, check out the examples in [NeoPromiseSample.cls](/main/force-app/main/default/classes/NeoPromiseSample.cls) and [NeoPromiseTest.cls](/main/force-app/main/default/classes/NeoPromiseTest.cls) for guidance on building promise chains and effectively handling errors.

### Stages

#### Stage 1: Implementation
(Example from `NeoPromiseSample.cls`)

1. Implement the class with the `NeoPromiseInterface` interface:
    ```apex
    public class NeoPromiseSample implements NeoPromiseInterface {
    ```
   
2. Create the `CLASS_NAME` constant:
    ```apex
    private static final String CLASS_NAME = 'NeoPromiseSample';
    ```
   
3. Define a private `PromiseRequest` class:
    ```apex
    private class PromiseRequest {
        public boolean throwError;
        public String description;
    }
    ```
   
4. Add the `newPromise` method:
    ```apex
    public static NeoPromise newPromise(boolean throwError, String description) {
        PromiseRequest request = new PromiseRequest();
        request.throwError = throwError;
        request.description = description;
        return new NeoPromise(CLASS_NAME, JSON.serialize(request));
    }
    ```
   
5. Implement the `executePromise` method:
    ```apex
    public static void executePromise(String singleParam, String jsonParam, Map<String, Object> variables) {        
        PromiseRequest request = (PromiseRequest) JSON.deserialize(jsonParam, PromiseRequest.class); 
        NeoPromiseSample.newCodeORlegacyCode(request.throwError, request.description);
    }
    ```

#### Stage 2: Invocation in the Promise Chain
Example of using `NeoPromise`:
```apex


@IsTest private static void ok1() {
    NeoPromise sampleThen    = NeoPromiseSample.NewPromise('Then');    // it will run
    NeoPromise sampleNext1   = NeoPromiseSample.NewPromise('Next');    // Sence sw is true  it will run
    NeoPromise sampleNext2   = NeoPromiseSample.NewPromise('Next');    // Sence sw is false it will NOT run 
    NeoPromise sampleError   = NeoPromiseSample.NewPromise('Error');   // Sence no error it will NOT run  
    NeoPromise sampleFinally = NeoPromiseSample.NewPromise('Finally'); // it will run 

    Test.startTest();
    new NeoPromiseFlow('FLOW_NAME')
        .then(sampleThen)
            .next(true, sampleNext1)  
            .next(false, sampleNext2)  
                .onError(sampleError)
            .finaly(sampleFinally)
        .execute();
    Test.stopTest();

    System.assertEquals(3, [SELECT count() FROM NeoPromiseQueue__c WHERE Done__c=true],  'ok1 - all promise ran except -Error- step');
    System.assertEquals(0, [SELECT count() FROM NeoPromiseQueue__c WHERE Error__c=true], 'ok1 - no one promise failed');
}
```

### Core Classes
- **NeoPromiseFlow.cls**: Main class providing promise-like chaining and execution features.
- **NeoPromise.cls**: Holds promise information.
- **NeoPromiseBatch.cls**: Manages batch execution of promises for large-scale tasks.
- **NeoPromiseInterface.cls**: Interface that each promise task must implement for execution.
- **NeoPromiseSample.cls**: Sample implementation demonstrating task creation for the promise chain.
- **NeoPromiseTest.cls**: Test Class.
- **NeoPromiseQueueTrigger.cls**: Handles logic for promise execution via the `NeoPromiseQueue__c` object.

### Object: NeoPromiseQueue__c
Defines custom object for the promise queue:
- **Name**: This field makes sure  execution order is accurate.
yyMMddHHmmss + XXX + YYY  
XXX  a random number
YYY sequential number within the flow
- **Class_Name__c**: The executing class's name. 
- **FlowName__c**: Stores the flow's name. 
- **SingleParam__c**: Represents a single parameter passed to a task.
- **JsonParam__c**: Contains JSON parameters for tasks.
- **Error__c**: Indicates the task throw an error .
- **Done__c**: Indicates task completion.
- **ScheduledJobId__c**: Stores the scheduled job ID.
- **FlowId__c**: Stores the flow ID.
- **JobId__c**: Stores the job ID.
- **ErrorDescription__c**: Detailed error description.
- **ScheduledAT__c**: (Future use) Stores the scheduled execution time.
- **Duration__c**: Duration of the task.

---






**The NeoPromiseSample class is an example of how to convert an 
inherited class into a class that can be executed as a promise**

---
**ORIGINAL CLASS**
```
/**
 * @description          : Original class
 * @author               : Neo
 * @group                : Neo
 * @last modified on     : 05-01-2024
 * @last modified by     : Eugenio
 * @test class assigned  : NeoPromiseTest
**/
public class NeoPromiseSample implements NeoPromiseInterface {

    /**
    * @description Sample method
    * @param throwError
    * @param description
    */        
    private static void newCodeORlegacyCode(boolean throwError, String description) {
        if (throwError) {
            throw new NeoException(NeoException.errors.MISSING_PARAMETER, description);
        }
    }

}
```
---
**AFTER PROMISE IMPLEMENTATION**
```
/**
 * @description          : Promise Class for testing
 * @author               : Neo
 * @group                : Neo
 * @last modified on     : 05-01-2024
 * @last modified by     : Eugenio
 * @test class assigned  : NeoPromiseTest
**/
public class NeoPromiseSample implements NeoPromiseInterface {
    private static final String CLASS_NAME = 'NeoPromiseSample';

    /**
    * @description Promise Request
    */        
    private class PromiseRequest {
        public boolean throwError;
        public String description;
    }    

    
    /**
    * @description Promise creator 
    * @param throwError
    * @param description
    * @return NeoPromise
    */         
    public static NeoPromise newPromise(boolean throwError, String description) {
        PromiseRequest request = new PromiseRequest();
        request.throwError = throwError;
        request.description = description;
        return new NeoPromise(CLASS_NAME,JSON.serialize(request));
    }    
    
    
    /**
    * @description overridden Promise Creator
    * @param description
    * @return NeoPromise
    */         
    public static NeoPromise newPromise(String description) {
        return newPromise(false, description);
    }

    /**
    * @description Promise execution method
    * @param singleParam
    * @param jsonParam
    * @param variables
    */        
    public static void executePromise(String singleParam, String jsonParam, Map<String, Object> variables  ) {        
        PromiseRequest request = (PromiseRequest) JSON.deserialize(jsonParam, PromiseRequest.class); 
        NeoPromiseSample.newCodeORlegacyCode(request.throwError, request.description);

    }
    
    /**
    * @description Sample method
    * @param throwError
    * @param description
    */        
    private static void newCodeORlegacyCode(boolean throwError, String description) {
        if (throwError) {
            throw new NeoException(NeoException.errors.MISSING_PARAMETER, description);
        }
    }
}
```
The test class emphasizes code clarity. Even though the promise flow is
extensive and conditional, the goal is for it to be easily readable.
```
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
```
---
