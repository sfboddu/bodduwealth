@isTest
private class ContactTriggerHandlerTest {
    @testSetup
    static void sampleSetup(){
        List<Account> accList = new List<Account>();
        for(Integer i=1;i<5;i++){
            Account acc = new Account();
            acc.Name = 'Test Account' + i;
            accList.add(acc);


            //IT IS TO TEST THE CHANGE
        }
        insert accList;
        
        List<Contact> conList = new List<Contact>();
        for(Account acc : accList){
            for(Integer i=1;i<3;i++){
                Contact con = new Contact();
                con.AccountId = acc.Id;
                con.LastName = 'test Contact' + i;
                conList.add(con);
            }
            
        }
        insert conList;
    }
    
    @isTest
    static void totalContactCountTest(){
        
        List<Account> accList = [SELECT Id,total_contact_count__c,(SELECT Id,AccountId FROM Contacts)
                                 FROM Account];
        
        List<Account> updatedAccounts = [SELECT Id,total_contact_count__c,(SELECT Id,AccountId FROM Contacts)
                                         FROM Account 
                                         WHERE Id =: accList[0].Id];
        System.assertEquals(updatedAccounts[0].total_contact_count__c , updatedAccounts[0].Contacts.size());
    }
    
    @isTest
    static void deleteTest(){
        
        List<Account> accList = [SELECT Id,total_contact_count__c,(SELECT Id,AccountId FROM Contacts)
                                 FROM Account];
        List<Contact> conList = [SELECT AccountId,Account.Id 
                                 FROM Contact WHERE AccountId =: accList[0].Id ];
        delete conList;
        
        List<Account> updatedAccounts = [SELECT Id,total_contact_count__c,(SELECT Id,AccountId FROM Contacts)
                                         FROM Account 
                                         WHERE Id =: accList[0].Id];
        System.assertEquals(updatedAccounts[0].total_contact_count__c , updatedAccounts[0].Contacts.size());
    }
    
    @isTest
    static void undeleteTest(){
        
        List<Account> accList = [SELECT Id,total_contact_count__c,(SELECT Id,AccountId FROM Contacts)
                                 FROM Account];
        List<Contact> conList = [SELECT AccountId,Account.Id 
                                 FROM Contact WHERE AccountId =: accList[0].Id ];
        delete conList;
        
        undelete conList;
        
        List<Account> updatedAccounts = [SELECT Id,total_contact_count__c,(SELECT Id,AccountId FROM Contacts)
                                         FROM Account 
                                         WHERE Id =: accList[1].Id];
        System.assertEquals(updatedAccounts[0].total_contact_count__c , updatedAccounts[0].Contacts.size());
    }
    
}