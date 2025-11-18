public class OpportunityFetchDetails {

    public static List<Opportunity> oppFetch(){
        
        Date todayDate = Date.Today();
        Date dateWithin = todayDate.addDays(30);
        List<Opportunity>oppList = [SELECT Id,Name,CloseDate,StageName FROM Opportunity
                                   WHERE CloseDate >= :todayDate
                                   AND CloseDate <= :dateWithin
                                   Order BY CloseDate ASC];
        return oppList;
        }
}