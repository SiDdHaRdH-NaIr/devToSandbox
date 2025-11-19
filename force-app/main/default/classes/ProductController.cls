public with sharing class ProductController {

    @AuraEnabled(cacheable=true)
    public static List<PricebookEntry> getProducts() {
        return [
            SELECT Id, Name, Product2Id, ProductCode, UnitPrice,
                   Pricebook2.Name, Pricebook2.IsActive
            FROM PricebookEntry
            WHERE Pricebook2.IsActive = TRUE
            LIMIT 500
        ];
    }

    @AuraEnabled
    public static void saveOpportunityProducts(Id oppId, String productData) {

        List<Object> rawList = (List<Object>) JSON.deserializeUntyped(productData);
        List<Map<String, Object>> rows = new List<Map<String, Object>>();

        for (Object obj : rawList) {
            rows.add((Map<String, Object>) obj);
        }

        List<OpportunityLineItem> items = new List<OpportunityLineItem>();

        for (Map<String, Object> row : rows) {

            Date serviceDt = null;
            if (row.get('Date') != null) {
                String dt = String.valueOf(row.get('Date'));

                try {
                    // yyyy-MM-dd or yyyy-MM-ddThh:mm:ss formats
                    if (dt.contains('T')) {
                        dt = dt.substring(0, dt.indexOf('T'));
                    }
                    serviceDt = Date.valueOf(dt);
                } 
                catch (Exception ex1) {
                    try {
                        // Fallback for Salesforce acceptable textual formats
                        serviceDt = Date.parse(dt);
                    }
                    catch (Exception ex2) {
                        serviceDt = null; // last fallback
                    }
                }
            }

            items.add(new OpportunityLineItem(
                OpportunityId = oppId,
                PricebookEntryId = (String) row.get('Id'),
                Quantity = (Decimal) row.get('Quantity'),
                UnitPrice = (Decimal) row.get('SalesPrice'),
                ServiceDate = serviceDt
            ));
        }

        insert items;
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getOpportunityProducts(Id oppId) {

        List<OpportunityLineItem> items = [
            SELECT Id, Quantity, UnitPrice,
                   PricebookEntry.Product2.Name
            FROM OpportunityLineItem
            WHERE OpportunityId = :oppId
        ];

        List<Map<String, Object>> results = new List<Map<String, Object>>();

        for (OpportunityLineItem oli : items) {
            results.add(new Map<String, Object>{
                'Id' => oli.Id,
                'ProductName' => oli.PricebookEntry.Product2.Name,
                'Quantity' => oli.Quantity,
                'UnitPrice' => oli.UnitPrice
            });
        }

        return results;
    }
}