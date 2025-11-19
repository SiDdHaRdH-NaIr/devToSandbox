import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getProducts from '@salesforce/apex/ProductController.getProducts';
import getOpportunityProducts from '@salesforce/apex/ProductController.getOpportunityProducts';
import saveOpportunityProducts from '@salesforce/apex/ProductController.saveOpportunityProducts';

export default class OpportunityLineItem extends LightningElement {
    @api recordId;

    lineItems = [];
    allProducts = [];
    filteredProducts = [];
    selectedProducts = [];
    step2Products = [];

    showStep1 = false;
    showStep2 = false;

    columns = [
        { label: "Product Name", fieldName: "ProductName" },
        { label: "Quantity", fieldName: "Quantity" },
        { label: "Sales Price", fieldName: "UnitPrice", type: "currency" }
    ];

    productColumns = [
        { label: "Product Name", fieldName: "Name" },
        { label: "Product Code", fieldName: "ProductCode" },
        { label: "List Price", fieldName: "UnitPrice", type: "currency" }
    ];

    connectedCallback() {
        this.loadOpportunityProducts();
        this.loadAllProducts();
    }

    loadOpportunityProducts() {
        getOpportunityProducts({ oppId: this.recordId }).then(
            result => (this.lineItems = result)
        );
    }

    loadAllProducts() {
        getProducts().then(result => {
            this.allProducts = result;
            this.filteredProducts = result;
        });
    }

    handleMenuAction(event) {
        if (event.detail.value === "add") this.showStep1 = true;
    }

    handleSearch(event) {
        const key = event.target.value.toLowerCase();
        this.filteredProducts = this.allProducts.filter(
            p => p.Name.toLowerCase().includes(key)
        );
    }

    handleProductSelection(event) {
        let rows = event.detail.selectedRows || [];
        this.selectedProducts = this.flatten(rows);
    }

    flatten(arr) {
        return arr.reduce(
            (flat, item) =>
                flat.concat(Array.isArray(item) ? this.flatten(item) : item),
            []
        );
    }

    closeStep1() {
        this.showStep1 = false;
    }

    openStep2() {
        const flat = this.flatten(this.selectedProducts);

        this.step2Products = flat.map(prod => ({
            Id: prod.Id,
            Quantity: 1,
            SalesPrice: prod.UnitPrice,
            Date: null
        }));

        this.showStep1 = false;
        this.showStep2 = true;
    }

    backToStep1() {
        this.showStep2 = false;
        this.showStep1 = true;
    }

    changeQuantity(event) {
        const id = event.target.dataset.id;
        const value = Number(event.target.value);

        this.step2Products = this.step2Products.map(p => {
            if (p.Id === id) p.Quantity = value;
            return p;
        });
    }

    changePrice(event) {
        const id = event.target.dataset.id;
        const value = Number(event.target.value);

        this.step2Products = this.step2Products.map(p => {
            if (p.Id === id) p.SalesPrice = value;
            return p;
        });
    }

    saveProducts() {
        const cleanPayload = JSON.stringify(this.flatten(this.step2Products));

        saveOpportunityProducts({
            oppId: this.recordId,
            productData: cleanPayload
        })
            .then(() => {
                this.showStep2 = false;
                this.loadOpportunityProducts();

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Success",
                        message: "Products added successfully",
                        variant: "success"
                    })
                );
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: error.body ? error.body.message : error.message,
                        variant: "error"
                    })
                );
            });
    }
}