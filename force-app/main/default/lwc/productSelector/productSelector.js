import { LightningElement, track, wire, api } from 'lwc';
import getProducts from '@salesforce/apex/ProductController.getProducts';
import saveOpportunityProducts from '@salesforce/apex/ProductController.saveOpportunityProducts';

export default class ProductSelector extends LightningElement {
    @api recordId; // Opportunity Id

    searchKey = '';
    selectedProducts = [];
    showModal = false;

    @track products = [];
    @track filteredProducts = [];
    @track editableProducts = [];

    productColumns = [
        { label: 'Product Name', fieldName: 'Name', type: 'text' },
        { label: 'Product Code', fieldName: 'ProductCode', type: 'text' },
        { label: 'List Price', fieldName: 'UnitPrice', type: 'currency' }
    ];

    // Load Products from Apex
    @wire(getProducts)
    wiredProducts({ data }) {
        if (data) {
            this.products = data;
            this.filteredProducts = data;
        }
    }

    handleSearchChange(event) {
        this.searchKey = event.target.value.toLowerCase();
        this.filteredProducts = this.products.filter(p =>
            p.Name.toLowerCase().includes(this.searchKey)
        );
    }

    handleProductSelection(event) {
        this.selectedProducts = event.detail.selectedRows;
    }

    openEditModal() {
        this.editableProducts = this.selectedProducts.map(item => ({
            ...item,
            Quantity: 1,
            SalesPrice: item.UnitPrice,
            Date: null
        }));
        this.showModal = true;
    }

    closeModal() {
        this.showModal = false;
    }

    handleQuantityChange(event) {
        const id = event.target.dataset.id;
        this.updateEditable(id, "Quantity", event.target.value);
    }

    handlePriceChange(event) {
        const id = event.target.dataset.id;
        this.updateEditable(id, "SalesPrice", event.target.value);
    }

    handleDateChange(event) {
        const id = event.target.dataset.id;
        this.updateEditable(id, "Date", event.target.value);
    }

    updateEditable(id, field, value) {
        this.editableProducts = this.editableProducts.map(prod =>
            prod.Id === id ? { ...prod, [field]: value } : prod
        );
    }

    removeLineItem(event) {
        const id = event.target.dataset.id;
        this.editableProducts = this.editableProducts.filter(prod => prod.Id !== id);
    }

    saveProducts() {
        saveOpportunityProducts({
            oppId: this.recordId,
            productData: JSON.stringify(this.editableProducts)
        }).then(() => {
            this.closeModal();
        });
    }
}