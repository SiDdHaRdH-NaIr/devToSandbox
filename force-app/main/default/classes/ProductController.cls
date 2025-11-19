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

        List<Object> raw = (List<Object>) JSON.deserializeUntyped(productData);

        List<Map<String, Object>> rows = new List<Map<String, Object>>();
        for (Object obj : raw) {
            rows.add((Map<String, Object>) obj);
        }

        List<OpportunityLineItem> items = new List<OpportunityLineItem>();

        for (Map<String, Object> r : rows) {
            items.add(new OpportunityLineItem(
                OpportunityId = oppId,
                PricebookEntryId = (String) r.get('Id'),
                Quantity = (Decimal) r.get('Quantity'),
                UnitPrice = (Decimal) r.get('SalesPrice'),
                ServiceDate = (Date) r.get('Date')
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