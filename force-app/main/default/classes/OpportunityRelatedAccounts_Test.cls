@IsTest
public class OpportunityRelatedAccounts_Test {

    @IsTest
    static void testGetOpportunityRelatedAccounts() {

        // Create Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // Create Opportunities
        Opportunity opp1 = new Opportunity(
            Name = 'Opp 1',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Amount = 100,
            AccountId = acc.Id
        );

        Opportunity opp2 = new Opportunity(
            Name = 'Opp 2',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Amount = 200,
            AccountId = acc.Id
        );

        insert new List<Opportunity>{opp1, opp2};

        // Call the method
        Decimal result = OpportunityRelatedAccounts.getOpportunityRelatedAccounts();

        // Validate SUM (100 + 200 = 300)
        System.assertEquals(300, result, 'Total amount should be sum of opportunity amounts');
    }
}