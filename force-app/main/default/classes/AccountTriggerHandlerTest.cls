@isTest
private class AccountTriggerHandlerTest {
    
    
    @testSetup 
    static void sampleSetup(){
        
        List<Account> accList = new List<Account>();
        for(Integer i=1;i<10;i++){
            Account acc = new Account();
            acc.Name = 'test account' + i;
            acc.Industry = 'Media'; 
            acc.Active__c = 'Yes';
            acc.CustomerPriority__c = 'High';
            accList.add(acc);
        }
        
        
        
        // Account where Active__c = 'Yes' (should trigger addError)
        accList.add(new Account(Name = 'Active Account', Active__c = 'Yes'));
        
        // Account where Active__c = 'No' (should not trigger addError for sysadmin)
        accList.add(new Account(Name = 'Inactive Account', Active__c = 'No'));
        
        insert accList;
        
        List<Contact> conList = new List<Contact>();
        for(Account acc : accList ){
            Contact con = new Contact();
            con.AccountId = acc.Id;
            con.LastName = acc.Name;
            conList.add(con);
        }
        insert conList;
        
        
    }
    
    @isTest
    static void updateAccountTest(){
        List<Account> accList = [SELECT Id,Phone,Name 
                                 FROM Account];
        for(Account acc : accList){
            acc.Phone = '909045453';
        }
        update accList;
        
        List<Account> updatedAcc = [SELECT Id,Description,Phone 
                                    FROM Account 
                                    WHERE Id =: accList[0].Id];
        
        System.assertEquals('909045453',updatedAcc[0].Description);
        
        
    }
    @isTest
    static void createTaskTest(){
        
        List<Task> taskList = [SELECT WhatId,Subject,ActivityDate FROM Task WHERE Subject =: 'follow up' AND ActivityDate=: System.Today() + 7 ];
        List<Account> accList1 = [SELECT Id,Name,CustomerPriority__c FROM Account WHERE CustomerPriority__c =: 'High'];
        
        System.assertEquals(accList1[0].Id,taskList[0].WhatId);
    }
    
    @isTest
    static void updateContactTest(){
        List<Account> accList = [SELECT Id,Phone,Name 
                                 FROM Account WHERE Name LIKE 'test account%'];
        for(Account acc : accList){
            acc.Phone = '909045453';
        }
        update accList;
        
        List<Contact> updatedCon = [SELECT Id,AccountId,HomePhone 
                                    FROM Contact 
                                    WHERE AccountId =: accList[0].Id];
        System.assertEquals( accList[0].Phone, updatedCon[0].HomePhone );
        
        
    }
    
        @IsTest
    static void testPreventDeletion_SysAdminActiveYes() {
        // Retrieve the System Administrator profile
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

        // Create a System Administrator user
        User sysAdminUser = new User(
            Alias = 'sysadmin',
            Email = 'sysadmin@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'SysAdmin',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = sysAdminProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'sysadmin1@example.com'
        );
        insert sysAdminUser;

        // Run the test as System Administrator
        System.runAs(sysAdminUser) {
            List<Account> accList = [SELECT Id, Name ,Active__c FROM Account WHERE Active__c = 'Yes' AND Name = 'Active Account'];
            
            Test.startTest();
            // Call the method
            AccountTriggerHandler.preventDeletion(accList);
            Test.stopTest();

            // Check that addError was called because Active__c = 'Yes'
            System.assertEquals(1, accList[0].getErrors().size(), 'Expected error for Account with Active__c = Yes');
        }
    }
    
    @IsTest
    static void testPreventDeletion_SysAdminActiveNo() {
        // Retrieve the System Administrator profile
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

        // Create a System Administrator user
        User sysAdminUser = new User(
            Alias = 'sysadmin',
            Email = 'sysadmin@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'SysAdmin',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = sysAdminProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'sysadmin2@example.com'
        );
        insert sysAdminUser;

        // Run the test as System Administrator
        System.runAs(sysAdminUser) {
            List<Account> accList = [SELECT Id, Active__c FROM Account WHERE Active__c = 'No' AND Name = 'Inactive Account'];

            Test.startTest();
            // Call the method
            AccountTriggerHandler.preventDeletion(accList);
            Test.stopTest();

            // Check that addError was not called for System Administrator with Active__c = 'No'
            System.assertEquals(0, accList[0].getErrors().size(), 'Expected no error for Account with Active__c = No');
        }
    }
    
        @IsTest
    static void testPreventDeletion_NonSysAdmin() {
        // Retrieve a non-System Administrator profile (any profile except 'System Administrator')
        Profile nonSysAdminProfile = [SELECT Id FROM Profile WHERE Name != 'System Administrator' LIMIT 1];

        // Create a Non-System Administrator user
        User nonSysAdminUser = new User(
            Alias = 'nonadmin',
            Email = 'nonsysadmin@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'NonSysAdmin',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = nonSysAdminProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'nonsysadmin@example.com'
        );
        insert nonSysAdminUser;

        // Run the test as Non-System Administrator
        System.runAs(nonSysAdminUser) {
            List<Account> accList = [SELECT Id, Active__c FROM Account WHERE Active__c = 'No' AND (Name = 'Inactive Account' OR Name = 'Active Account')];

            Test.startTest();
            // Call the method
            AccountTriggerHandler.preventDeletion(accList);
            Test.stopTest();

            // Check that addError was called for Non-System Administrator user, even if Active__c = 'No'
            System.assertEquals(1, accList[0].getErrors().size(), 'Expected error for Non-System Administrator');
        }
    }


    
}