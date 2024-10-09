import { LightningElement, wire } from 'lwc';
import getContactsList from '@salesforce/apex/ContactsService.getContacts';
export default class practiceTrack extends LightningElement {
  //@track greetingMessage = 'World';//Before Spring ’20 to need to import track decorator & use it to make a field reactive
  greetingMessage = 'World';
 
  changeHandler(event) {
    this.greetingMessage = event.target.value;
  }

  @wire(getContactsList)
  Contacts;
}