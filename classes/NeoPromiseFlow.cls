/**
 * @description          : NeoPromiseFlow 
 * @author               : Eugenio Barrero
 * @last modified on     : 05-01-2024
 * @last modified by     : Eugenio
 * @test class assigned  : NeoPromiseTest
**/ 
public without sharing class NeoPromiseFlow {
    private List<NeoPromise> promises;
    private String flowName;
    private String currentFlowId; 
    private integer sequence=0;
    private boolean thenJumped; 
    
    public static final integer P_THEN = 1;
    public static final integer P_NEXT = 2;
    public static final integer P_ON_ERROR = 3;
    public static final integer P_FINALLY = 4;

    

    /**
    * @description Constructor
    */        
    public NeoPromiseFlow() {
        this('NO NAME');
    }

    /**
    * @description Constructor
    * @param flowName String 
    */        
    public NeoPromiseFlow(String  flowName) {
        this.flowName = flowName;
        promises=new List<NeoPromise>();
        DateTime now = DateTime.now();
        currentFlowId =  now.format('yyMMddHHmmss') + String.valueOf(Math.mod(Math.abs(Crypto.getRandomInteger()), 1000)).leftPad(3,'0');        
    }



    /**
    * @description Add a promise to flow in "then" mode if sw is true
    * @param sw boolean
    * @param promise NeoPromise
    * @return NeoPromiseFlow
    */        
    public NeoPromiseFlow then(boolean sw, NeoPromise promise) {
        if (sw) {
            then(promise);
        } else {
            thenJumped = true;
        }
        return this;
    }
    /**
    * @description Add a promise to flow in "then" mode
    * @param promise NeoPromise
    * @return NeoPromiseFlow
    */        
    public NeoPromiseFlow then(NeoPromise promise) {
        thenJumped=false;
        DateTime now = DateTime.now();
        promise.config(currentFlowId,sequence++, P_THEN);    
        promises.add(promise);
        return this;
    }
    /**
    * @description Add a promise to flow in "next" mode
    * @param sw boolean    
    * @param promise NeoPromise
    * @return NeoPromiseFlow
    */           
    public NeoPromiseFlow next(boolean sw, NeoPromise promise) {
        if (sw) {
            next(promise);
        }
        return this;
    }
    /**
    * @description Add a promise to flow in "next" mode
    * @param promise NeoPromise
    * @return NeoPromiseFlow
    */           
    public NeoPromiseFlow next(NeoPromise promise) {
        if(!thenJumped) {
            promise.config(currentFlowId,sequence++, P_NEXT);    
            promises.add(promise);
        }
        return this;
    }
    /**
    * @description Add a promise to flow in "onError" mode
    * @param promise NeoPromise
    * @return NeoPromiseFlow
    */           
    public NeoPromiseFlow onError(NeoPromise promise) {
        if(!thenJumped) {
            promise.config(currentFlowId, sequence++, P_ON_ERROR);    
            promises.add(promise);
        }
        return this;
    }
    /**
    * @description Add a promise to flow in "finally" mode
    * @param promise NeoPromise
    * @return NeoPromiseFlow
    */           
    public NeoPromiseFlow finaly(NeoPromise promise) {
        if(!thenJumped) {
            promise.config(currentFlowId, sequence++, P_FINALLY);    
            promises.add(promise);
        }            
        return this;
    }
    /**
    * @description execute whole flow
    */           
    @SuppressWarnings('PMD.ApexCRUDViolation')
    public void execute() {
        if (promises.size()>0) {
            List<NeoPromiseQueue__c> neoPromiseQueue = new List<NeoPromiseQueue__c>();
            for (NeoPromise p: promises) {
                neoPromiseQueue.add(p.getPromiseQueue(flowName));
            }
            insert neoPromiseQueue;
        }
    }
}