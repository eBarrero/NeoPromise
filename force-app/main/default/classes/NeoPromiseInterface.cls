/**
 * @description          : NeoPromise Interface
 * @author               : Eugenio Barrero
 * @last modified on     : 02-07-2024
 * @last modified by     : Eugenio
 * @test class assigned  : 
**/
public interface NeoPromiseInterface {
    /**
    * @description Promise execution method 
    * @param singleParam
    * @param jsonParam
    * @param variables
    */     
    void executePromise(String singleParam, String jsonParam, Map<String, Object> variables);
} 