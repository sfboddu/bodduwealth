public class ContactTriggerHandler {
    
    public static void totalContactCount(List<Contact> conList){
        
        List<Account> accList = new List<Account>();
        set<Id> accId = new set<Id>();
        
        for(Contact con : conList){
            if(con.AccountId != null){
                accId.add(con.AccountId);
            }
        }
        for(Account acc : [SELECT Id,total_contact_count__c,(SELECT Id,AccountId FROM Contacts) FROM Account WHERE Id IN: accId]){
            acc.total_contact_count__c = acc.Contacts.size();
            accList.add(acc);


            // IT IS TO TEST THE CHANGE
        }
        update accList;
    }

}