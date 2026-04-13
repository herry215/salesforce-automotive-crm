import { LightningElement, wire, track } from "lwc";
import getAssets from "@salesforce/apex/AssetDashboardController.getAssets";

export default class AssetDashboard extends LightningElement {
  @track assets;
  columns = [
    { label: "차량명", fieldName: "Name" },
    { label: "VIN", fieldName: "SerialNumber" },
    { label: "상태", fieldName: "Status" },
    { label: "법인 지역", fieldName: "Region__c" },
    { label: "출고일", fieldName: "InstallDate", type: "date" }
  ];

  @wire(getAssets)
  wiredAssets({ data, error }) {
    if (data) this.assets = data;
    if (error) console.error(error);
  }
}
