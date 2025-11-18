@IsTest
public class OpportunityFetchDetails_Test {

    @IsTest
    static void testOppFetch() {
        
        // Setup test data
        Date today = Date.today();
        Date within30 = today.addDays(10);   // should be included
        Date beyond30 = today.addDays(40);   // should NOT be included
        
        List<Opportunity> opps = new List<Opportunity>();
        
        // Opportunity within next 30 days
        opps.add(new Opportunity(
            Name = 'Inside Window',
            StageName = 'Prospecting',
            CloseDate = within30
        ));
        
        // Opportunity beyond 30 days
        opps.add(new Opportunity(
            Name = 'Outside Window',
            StageName = 'Prospecting',
            CloseDate = beyond30
        ));
        
        insert opps;
        
        // Call actual method
        List<Opportunity> result = OpportunityFetchDetails.oppFetch();
        
        // Validate results
        System.assertNotEquals(0, result.size(), 'Result list should not be empty');
        
        // Should only return records inside date window
        for (Opportunity o : result) {
            System.assert(
                o.CloseDate >= today && o.CloseDate <= today.addDays(30),
                'Returned an Opportunity with a CloseDate outside the allowed range'
            );
        }
        
        // Ensure only 1 inside-window opportunity is returned
        System.assertEquals(1, result.size(), 'Only one Opportunity should match the date filter');
    }
}