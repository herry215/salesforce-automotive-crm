import { LightningElement, wire } from "lwc";
import getVehicles from "@salesforce/apex/VehicleDashboardController.getVehicles";

export default class VehicleDashboard extends LightningElement {
  @wire(getVehicles)
  vehicles;
}
