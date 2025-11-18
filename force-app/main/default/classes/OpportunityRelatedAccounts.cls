public with sharing class OpportunityRelatedAccounts {

    public static Decimal getOpportunityRelatedAccounts() {

        Decimal totalAmount = 0;

        List<AggregateResult> results = [
            SELECT SUM(Amount) totalAmount 
            FROM Opportunity 
            GROUP BY AccountId
        ];

        for (AggregateResult ar : results) {
            totalAmount += (Decimal) ar.get('totalAmount');
        }

        return totalAmount;
    }
}