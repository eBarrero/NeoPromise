/**
 * @description          : Promise Class for testing
 * @author               : Eugenio Barrero
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