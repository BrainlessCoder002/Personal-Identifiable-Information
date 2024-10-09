import { LightningElement } from "lwc";

export default class ConnectedCallbackExample extends LightningElement {
  connectedCallback() {
    // This doesn't work
    const div = this.template.querySelector("div");
  }
}