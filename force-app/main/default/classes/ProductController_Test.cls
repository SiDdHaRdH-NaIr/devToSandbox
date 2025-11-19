@IsTest
public class ProductController_Test {

    @TestSetup
    static void setup() {

        // Create Standard Pricebook (Activated)
        Pricebook2 pb = new Pricebook2(
            Name = 'Standard Pricebook',
            IsActive = true
        );
        insert pb;

        // Create Product
        Product2 p = new Product2(
            Name = 'Test Product',
            ProductCode = 'TP-001',
            IsActive = true
        );
        insert p;

        // Create Pricebook Entry
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pb.Id,
            Product2Id = p.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe;

        // Create Opportunity
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

        System.assert(!products.isEmpty(), 'Products should return at least 1 result');
    }

    @IsTest
    static void testSaveOpportunityProducts() {

        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];

        // Prepare JSON data
        String productDataJson = '[{"Id":"' + pbe.Id + '", "Quantity":2, "SalesPrice":100, "Date":"' + Date.today().format() + '"}]';

        Test.startTest();
        ProductController.saveOpportunityProducts(opp.Id, productDataJson);
        Test.stopTest();

        // Validate insertion
        List<OpportunityLineItem> items = [
            SELECT Id, Quantity, UnitPrice
            FROM OpportunityLineItem
            WHERE OpportunityId = :opp.Id
        ];

        System.assertEquals(1, items.size(), 'One OpportunityLineItem must be created');
        System.assertEquals(2, items[0].Quantity);
        System.assertEquals(100, items[0].UnitPrice);
    }

    @IsTest
    static void testGetOpportunityProducts() {

        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        PricebookEntry pbe = [SELECT Id, UnitPrice, Product2Id FROM PricebookEntry LIMIT 1];

        // Insert an OpportunityLineItem
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 3,
            UnitPrice = 150,
            ServiceDate = Date.today()
        );
        insert oli;

        Test.startTest();
        List<Map<String, Object>> results = ProductController.getOpportunityProducts(opp.Id);
        Test.stopTest();

        System.assertEquals(1, results.size(), 'Should return one Opportunity Product');
        System.assertEquals(3, results[0].get('Quantity'));
        System.assertEquals(150, results[0].get('UnitPrice'));
    }
}
