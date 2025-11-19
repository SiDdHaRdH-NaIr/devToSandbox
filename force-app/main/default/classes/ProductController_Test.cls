@IsTest
public class ProductController_Test {

    @TestSetup
    static void setupData() {

        // Get Standard Pricebook Id
        Id stdPBId = Test.getStandardPricebookId();

        // Activate it
        Pricebook2 pb = new Pricebook2(
            Id = stdPBId,
            IsActive = true
        );
        update pb;

        // Create Product
        Product2 prod = new Product2(
            Name = 'Test Product',
            ProductCode = 'P-100',
            IsActive = true
        );
        insert prod;

        // Create PricebookEntry
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = stdPBId,
            Product2Id = prod.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe;

        // Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today()
        );
        insert opp;
    }

    @IsTest
    static void testGetProducts() {

        Test.startTest();
        List<PricebookEntry> products = ProductController.getProducts();
        Test.stopTest();

        System.assert(products.size() > 0);
    }

    @IsTest
    static void testSaveOpportunityProducts() {

        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];

        // Send a complex datetime format to verify universal parser
        String jsonInput = 
            '[{"Id":"' + pbe.Id + '",' +
            '"Quantity":2,' +
            '"SalesPrice":100,' +
            '"Date":"' + Date.today() + 'T14:23:00.000Z"}]';

        Test.startTest();
        ProductController.saveOpportunityProducts(opp.Id, jsonInput);
        Test.stopTest();

        List<OpportunityLineItem> oliList = [
            SELECT Id, Quantity, UnitPrice, ServiceDate
            FROM OpportunityLineItem
            WHERE OpportunityId = :opp.Id
        ];

        System.assertEquals(1, oliList.size());
        System.assertEquals(2, oliList[0].Quantity);
        System.assertEquals(100, oliList[0].UnitPrice);
        System.assertEquals(Date.today(), oliList[0].ServiceDate, 
                            'Date parser should convert correctly');
    }

    @IsTest
    static void testGetOpportunityProducts() {

        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];

        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 5,
            UnitPrice = 200,
            ServiceDate = Date.today()
        );
        insert oli;

        Test.startTest();
        List<Map<String,Object>> result = ProductController.getOpportunityProducts(opp.Id);
        Test.stopTest();

        System.assertEquals(1, result.size());
        System.assertEquals(5, result[0].get('Quantity'));
        System.assertEquals(200, result[0].get('UnitPrice'));
    }
}