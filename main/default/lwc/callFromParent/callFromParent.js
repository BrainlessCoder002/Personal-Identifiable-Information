import { LightningElement } from 'lwc';
export default class callFromParent extends LightningElement 
{
    valueFromChild
    handleMessage(event){
        this.valueFromChild = event.detail;
    }
}