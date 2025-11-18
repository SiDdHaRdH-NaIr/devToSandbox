@IsTest
public class OpportunityRelatedAccountTest {

    @IsTest
    static void testGetOpportunityRelatedAccounts() {

        // Create Accounts
        Account acc1 = new Account(Name = 'Test Account 1');
        Account acc2 = new Account(Name = 'Test Account 2');
        insert new List<Account>{ acc1, acc2 };

        // Create Opportunities
        Opportunity opp1 = new Opportunity(
            Name = 'Opp 1',
            StageName = 'Prospecting',
            Amount = 1000,
            CloseDate = Date.today(),
            AccountId = acc1.Id
        );

        Opportunity opp2 = new Opportunity(
            Name = 'Opp 2',
            StageName = 'Negotiation',
            Amount = 2000,
            CloseDate = Date.today(),
            AccountId = acc2.Id
        );

        Opportunity opp3 = new Opportunity(
            Name = 'Opp 3',
            StageName = 'Closed Won',
            Amount = 500,
            CloseDate = Date.today(),
            AccountId = acc1.Id
        );

        insert new List<Opportunity>{ opp1, opp2, opp3 };

        // Call the method
        Decimal total = OpportunityRelatedAccounts.getOpportunityRelatedAccounts();

        // Expected total: 1000 + 2000 + 500 = 3500
        System.assertEquals(3500, total, 
            'Total Opportunity Amount did not match expected value');
    }
}