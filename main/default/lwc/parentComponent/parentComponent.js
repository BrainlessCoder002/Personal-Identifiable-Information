import { LightningElement } from 'lwc';
export default class ParentComponent extends LightningElement 
{
    messageFromParent = ''
    handleChange(event){
        this.messageFromParent = event.target.value
    }
}