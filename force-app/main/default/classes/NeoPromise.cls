/**
 * @description          : NeoPromise 
 * @author               : Eugenio Barrero
 * @last modified on     : 05-02-2024
 * @last modified by     : Eugenio
 * @test class assigned  : NeoPromiseTest
**/
public class NeoPromise {
    private NeoPromiseQueue__c promise;

    /**
    * @description Constructor
    * @param className
    * @param jsonParam
    */          
    public NeoPromise(String className, String jsonParam) {
        this(className,null,jsonParam);
    }

    /**
    * @description Constructor
    * @param className
    * @param singleParam
    * @param jsonParam
    */          
    public NeoPromise(String className,String singleParam, String jsonParam) {
        promise = new NeoPromiseQueue__c(Class_Name__c = className, singleParam__c = singleParam, JsonParam__c = jsonParam);
    }



    /**
    * @description set current promise 
    * @param flowId String
    * @param order integer
    * @param type integer
      called by NeoPromiseFlow
    */         
    public void config(String flowId, integer order, integer type) {
        promise.name = flowId + ('00' + String.valueOf(order)).right(3);
        promise.type__c = type;            
    }

    /**
    * @description getPromiseQueue
    * @param flowName String
    * @return NeoPromiseQueue__c 
    */            
    public NeoPromiseQueue__c getPromiseQueue(String flowName) {
        promise.flowName__c = flowName;
        return promise;
    }
} 